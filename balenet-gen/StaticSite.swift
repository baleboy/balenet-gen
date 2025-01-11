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
    
    let parser: MarkdownParser = {
        var parser = MarkdownParser()
        parser.addModifier(.youtubeEmbed())
        return parser
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let sourceURL: URL
    let buildURL: URL
    let contentURL: URL
    let projectsURL: URL
    
    init(title: String, sourceURL: URL, buildURL: URL) {
        
        self.title = title
        self.sourceURL = sourceURL
        self.buildURL = buildURL
        self.contentURL = sourceURL.appendingPathComponent("content")
        self.projectsURL = contentURL.appendingPathComponent("work")
        
        template = Template(title: title)
    }
    
    enum ParsingError: Error {
        case missingFrontMatter
        case invalidDate
    }

    func build() {
        
        do {
            deleteBuildDirectory()
            copyStaticFiles()
            try generateHomepage()
            try generateProjectsPage()
            generateAboutPage()
        } catch {
            fatalError("Error generating HTML: \(error)")
        }
    }
    
    func deleteBuildDirectory() {
        guard fileManager.fileExists(atPath: buildURL.path) else { return }
        
        do {
            try fileManager.removeItem(at: buildURL)
        } catch {
            print("Error deleting build directory: \(error)")
            // or handle the error in some other way
        }
    }
    
    func copyStaticFiles() {
        let staticURL = sourceURL.appendingPathComponent("static")
        do {
            try fileManager.copyItem(at: staticURL, to: buildURL)
        } catch {
            fatalError("Could not copy static files: \(error)")
        }
    }
    
    func generateHomepage() throws {
        
        let postlist = try generatePosts()
        
        let homepageHTML = template.getHomePage(intro: Settings.introText, postlist: postlist)
        let homepageURL = buildURL.appendingPathComponent("index.html")
        try homepageHTML.write(
            to: homepageURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func generateProjectsPage() throws {
        let projectlist = try generateProjects()
        
        let pageHTML = template.getProjectsPage(intro: Settings.projectsIntroText, projectlist: projectlist)
        let targetURL = buildURL.appendingPathComponent("work/index.html")
        try pageHTML.write(
            to: targetURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func generateAboutPage() {
        do {
            let markdownURL = contentURL.appendingPathComponent("about.md")
            let markdown = try String(contentsOf: markdownURL, encoding: .utf8)
            let aboutHTML = template.getPage(withContent: parser.html(from: markdown))
        
            let aboutFolderURL = buildURL.appendingPathComponent("about")

            try fileManager.createDirectory(at: aboutFolderURL, withIntermediateDirectories: true)
            let aboutFileURL = aboutFolderURL.appendingPathComponent("index.html")
            try aboutHTML.write(
                to: aboutFileURL,
                atomically: true,
                encoding: .utf8
            )
        } catch {
            fatalError("Error creating about page: \(error)")
        }
    }
    
    // generate posts and return an HTML list of the posts
    
    func generatePosts() throws -> [PostItem] {
        var postList: [PostItem] = []
        let postsURL = contentURL.appendingPathComponent("posts")
        // Use URL-based directory enumeration
        let subFolderURLs = try fileManager.contentsOfDirectory(
            at: postsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles  // This replaces our manual hidden folder check
        )
        
        for folderURL in subFolderURLs {
            let folder = folderURL.lastPathComponent
            
            // Get all files in the current post directory
            let fileURLs = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: []
            )
            
            // Create post subfolder in build directory
            let buildPostURL = buildURL.appendingPathComponent("posts")
                                     .appendingPathComponent(folder)
            try fileManager.createDirectory(
                at: buildPostURL,
                withIntermediateDirectories: true
            )
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "md" {
                    let postItem = try generatePostHtml(
                        folder: folder,
                        markdownURL: fileURL
                    )
                    postList.append(postItem)
                } else {
                    // copy post asset files to build folder
                    let destinationURL = buildPostURL.appendingPathComponent(fileURL.lastPathComponent)
                    try fileManager.copyItem(
                        at: fileURL,
                        to: destinationURL
                    )
                }
            }
        }
        
        return postList.sorted { $0.date > $1.date }
    }
    
    func parsePost(folder: String, markdownURL: URL) throws -> PostItem {
        let postContent = try String(contentsOf: markdownURL, encoding: .utf8)
        let parsed = parser.parse(postContent)
        
        guard let dateString = parsed.metadata["date"],
              let title = parsed.metadata["title"] else {
            throw ParsingError.missingFrontMatter
        }
        
        guard let date = dateFormatter.date(from: dateString) else {
            throw ParsingError.invalidDate
        }

        return PostItem(title: title, date: date, path: "/posts/\(folder)/", html: parsed.html)
    }
    
    func generatePostHtml (folder: String, markdownURL: URL) throws -> PostItem {

        let postItem = try parsePost(folder: folder, markdownURL: markdownURL)

        let buildPostURL = buildURL.appendingPathComponent("posts").appendingPathComponent(folder)
        
        let postHtml = template.getPost(post: postItem)
        let buildFileURL = buildPostURL.appendingPathComponent("index.html")
        try postHtml.write(to: buildFileURL, atomically: true, encoding: .utf8)

        return postItem
    }
        
    func generateProjects() throws -> [ProjectItem] {
       var projectList: [ProjectItem] = []
       
       // Use URL-based directory enumeration
       let subFolderURLs = try fileManager.contentsOfDirectory(
           at: projectsURL,
           includingPropertiesForKeys: [.isDirectoryKey],
           options: .skipsHiddenFiles
       )
       
       for folderURL in subFolderURLs {
           let folder = folderURL.lastPathComponent
           
           // Get all files in the current project directory
           let fileURLs = try fileManager.contentsOfDirectory(
               at: folderURL,
               includingPropertiesForKeys: [.isRegularFileKey],
               options: []
           )
           
           // Create project subfolder in build directory
           let buildProjectURL = buildURL.appendingPathComponent("work")
                                       .appendingPathComponent(folder)
           try fileManager.createDirectory(
               at: buildProjectURL,
               withIntermediateDirectories: true
           )
           
           for fileURL in fileURLs {
               if fileURL.pathExtension == "md" {
                   let projectItem = try generateProjectHtml(
                       folder: folder,
                       markdownURL: fileURL
                   )
                   projectList.append(projectItem)
               } else {
                   // copy project asset files to build folder
                   let destinationURL = buildProjectURL.appendingPathComponent(fileURL.lastPathComponent)
                   try fileManager.copyItem(
                       at: fileURL,
                       to: destinationURL
                   )
               }
           }
       }
       
       return projectList.sorted { $0.order > $1.order }
    }
    
    func parseProject(folder: String, markdownURL: URL) throws -> ProjectItem {
        let projectContent = try String(contentsOf: markdownURL, encoding: .utf8)
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
        
        let html = parsed.html
        
        let projectItem = ProjectItem(title: title, order: order, image: "\(folder)/\(image)", path: "/work/\(folder)/", html: html)
        return projectItem
    }
    
    func generateProjectHtml (folder: String, markdownURL: URL) throws -> ProjectItem {
        let projectItem = try parseProject(folder: folder, markdownURL: markdownURL)
        
        let buildProjectURL = buildURL.appendingPathComponent("work").appendingPathComponent(folder)


        let projectHtml = template.getProject(project: projectItem)
        let buildFileURL = buildProjectURL.appendingPathComponent("index.html")
        try projectHtml.write(to: buildFileURL, atomically: true, encoding: .utf8)

        return projectItem
    }
}
