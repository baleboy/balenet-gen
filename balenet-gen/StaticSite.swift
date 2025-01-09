//
//  HtmlGenerator.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 15.12.2024.
//

import Foundation
import Ink

struct StaticSite {
    let title: String
    let template: Template
    
    let fileManager = FileManager.default
    var parser = MarkdownParser()
    
    
    init(title: String) {
        template = Template(title: title)
        self.title = title
        parser.addModifier(.youtubeEmbed())
    }
    
    enum ParsingError: Error {
        case missingFrontMatter
        case invalidDate
    }

    func generate() {
        
        do {
            // delete build directory if it exists
            let buildURL = URL(fileURLWithPath: Settings.buildPath)
            if fileManager.fileExists(atPath: Settings.buildPath) {
                try fileManager.removeItem(at: buildURL)
            }
            
            // copy static files to build root
            try fileManager.copyItem(at: URL(fileURLWithPath: Settings.staticPath), to: buildURL)

            try generateAboutPage()
            
            let projectList = try generateProjects()
            try generateProjectsPage(projectList)
            
            let postlist = try generatePosts()
            try generateHomepage(postlist)
            
        } catch {
            print("Error generating HTML: \(error)")
        }
    }
    
    struct PostItem {
        let title: String
        let date: Date
        let path: String
    }

    func generateHomepage(_ postlist: [PostItem]) throws {
        let homepageHTML = template.getHomePage(intro: Settings.introText, postlist: postlist)
        let homepagePath = Settings.buildPath + "/index.html"
        try homepageHTML.write(
            toFile: homepagePath,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func generateAboutPage() throws {
        let filePath = Settings.contentPath + "/about.md"
        let aboutContent = try String(contentsOfFile: filePath, encoding: .utf8)
        let aboutHTML = template.getPage(withContent: parser.html(from: aboutContent))
        
        let aboutDirectoryPath = Settings.buildPath + "/about"
        try fileManager.createDirectory(atPath: aboutDirectoryPath, withIntermediateDirectories: true)
        let aboutFilePath = aboutDirectoryPath + "/index.html"
        try aboutHTML.write(
            toFile: aboutFilePath,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func generateProjectsPage(_ projectlist: [ProjectItem]) throws {
        let pageHTML = template.getProjectsPage(intro: Settings.projectsIntroText, projectlist: projectlist)
        let path = Settings.buildPath + "/work/index.html"
        try pageHTML.write(
            toFile: path,
            atomically: true,
            encoding: .utf8
        )
    }
    
    // generate posts and return an HTML list of the posts
    
    func generatePosts() throws -> [PostItem] {
        
        var postList: [PostItem] = []
        
        let postsPath = Settings.postsPath
        let subFolders = try fileManager.contentsOfDirectory(atPath: postsPath)
        for folder in subFolders {
            guard !folder.hasPrefix(".") else { continue } // skip hidden folders
            
            let currentPostPath = postsPath + "/" + folder
            let files = try fileManager.contentsOfDirectory(atPath: currentPostPath)
            
            // create post subfolder in build directory
            let buildPostPath = Settings.buildPath + "/posts/\(folder)"
            try fileManager.createDirectory(atPath: buildPostPath, withIntermediateDirectories: true)
            
            for file in files {
                if file.hasSuffix(".md") {
                    let postItem = try generatePostHtml(folder: folder, markdownPath: currentPostPath + "/" + file)
                    postList.append(postItem)
                } else {
                    // copy post asset files to build folder
                    let buildFilePath = buildPostPath + "/" + file
                    try fileManager.copyItem(atPath: currentPostPath + "/" + file, toPath: buildFilePath)
                }
            }
        }

        return postList.sorted { $0.date > $1.date }
    }
    
    func generatePostHtml (folder: String, markdownPath: String) throws -> PostItem {
        let postContent = try String(contentsOfFile: markdownPath, encoding: .utf8)
        let parsed = parser.parse(postContent)
        
        guard let dateString = parsed.metadata["date"],
              let title = parsed.metadata["title"] else {
            throw ParsingError.missingFrontMatter
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else {
            throw ParsingError.invalidDate
        }
        
        let buildPostPath = Settings.buildPath + "/posts/\(folder)"
        let postItem = PostItem(title: title, date: date, path: "/posts/\(folder)/")

        
        let postHtml = template.getPost(title: postItem.title, date: postItem.date,  content: parsed.html)
        let buildFilePath = buildPostPath + "/index.html"
        try postHtml.write(toFile: buildFilePath, atomically: true, encoding: .utf8)

        return postItem
    }
    
    struct ProjectItem {
        let title: String
        let order: Int
        let image: String
        let path: String
    }
    
    func generateProjects() throws -> [ProjectItem] {
        
        var projectList: [ProjectItem] = []
        
        let projectsPath = Settings.projectsPath
        let subFolders = try fileManager.contentsOfDirectory(atPath: projectsPath)
        for folder in subFolders {
            guard !folder.hasPrefix(".") else { continue } // skip hidden folders
            
            let currentProjectPath = projectsPath + "/" + folder
            let files = try fileManager.contentsOfDirectory(atPath: currentProjectPath)
            
            let buildPostPath = Settings.buildPath + "/work/\(folder)"
            try fileManager.createDirectory(atPath: buildPostPath, withIntermediateDirectories: true)
            
            for file in files {
                if file.hasSuffix(".md") {
                    let projectItem = try generateProjectHtml(folder: folder, markdownPath: currentProjectPath + "/" + file)
                    projectList.append(projectItem)
                } else {
                    // copy post asset files to build folder
                    let buildFilePath = buildPostPath + "/" + file
                    try fileManager.copyItem(atPath: currentProjectPath + "/" + file, toPath: buildFilePath)
                }
            }
        }

        return projectList.sorted { $0.order > $1.order }
    }
    
    func generateProjectHtml (folder: String, markdownPath: String) throws -> ProjectItem {
        let projectContent = try String(contentsOfFile: markdownPath, encoding: .utf8)
        let parsed = parser.parse(projectContent)
        
        guard let title = parsed.metadata["title"],
              let orderString = parsed.metadata["order"],
              let image = parsed.metadata["image"] else {
            print("Missing fields in front matter in folder \(folder)")
            throw ParsingError.missingFrontMatter
        }
        
        guard let order = Int(orderString) else {
            print("Could not parse order")
            throw ParsingError.missingFrontMatter
        }
        
        let buildProjectPath = Settings.buildPath + "/work/\(folder)"
        let projectItem = ProjectItem(title: title, order: order, image: "\(folder)/\(image)", path: "/work/\(folder)/")

        let projectHtml = template.getProject(title: projectItem.title, content: parsed.html)
        let buildFilePath = buildProjectPath + "/index.html"
        try projectHtml.write(toFile: buildFilePath, atomically: true, encoding: .utf8)

        return projectItem
    }
}
