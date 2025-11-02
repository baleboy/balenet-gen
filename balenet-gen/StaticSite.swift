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
    
    init(title: String, sourceURL: URL, buildURL: URL, templateDirectory: URL) throws {
        
        self.title = title
        self.sourceURL = sourceURL
        self.buildURL = buildURL
        self.contentURL = sourceURL.appendingPathComponent("content")
        self.projectsURL = contentURL.appendingPathComponent("work")
        
        template = try Template(title: title, directory: templateDirectory)
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
        
        let postlist = try generateItemsFromDirectory(type: .post).sorted {
            ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast)
        }
        let homepageHTML = template.getHomePage(postlist: postlist)
        let homepageURL = buildURL.appendingPathComponent("index.html")
        try homepageHTML.write(
            to: homepageURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func generateProjectsPage() throws {
        let projectlist = try generateItemsFromDirectory(type: .project).sorted {
            ($0.order ?? 0) > ($1.order ?? 0)
        }
        
        let pageHTML = template.getProjectsPage(projectlist: projectlist)
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
    
    func generateItemsFromDirectory(type: ContentItemType) throws -> [ContentItem] {
        var itemList: [ContentItem] = []
        let folderURL = contentURL.appendingPathComponent(type.subFolder)
        
        let subFolderURLs = try fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        )
        
        for folderURL in subFolderURLs {
            let folder = folderURL.lastPathComponent
            
            // Get all files in the current post directory
            let fileURLs = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: []
            )
            
            // Create appropriate subfolder in build directory
            let buildFolderURL = buildURL.appendingPathComponent(type.subFolder)
                .appendingPathComponent(folder)
            try fileManager.createDirectory(
                at: buildFolderURL,
                withIntermediateDirectories: true
            )
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "md" {
                    let contentItem = try generateHtmlFromMarkdown(
                        folder: folder,
                        markdownURL: fileURL
                    )
                    itemList.append(contentItem)
                } else {
                    // copy post asset files to build folder
                    let destinationURL = buildFolderURL.appendingPathComponent(fileURL.lastPathComponent)
                    try fileManager.copyItem(
                        at: fileURL,
                        to: destinationURL
                    )
                }
            }
        }
        
        return itemList
    }
    
    func parseItem(folder: String, markdownURL: URL) throws -> ContentItem {
        let content = try String(contentsOf: markdownURL, encoding: .utf8)
        let parsed = parser.parse(content)
        let type = try ContentItemType.infer(from: parsed.metadata)
        
        let title = parsed.metadata["title"] ?? "Untitled"
        let path = "/\(type.subFolder)/\(folder)/"
        let html = parsed.html
        
        switch type {
        case .post:
            let dateString = parsed.metadata["date"] ?? ""
            let date = dateFormatter.date(from: dateString) ?? Date()
            return .post(title: title, date: date, path: path, html: html)
        case .project:
            let orderString = parsed.metadata["order"] ?? ""
            let order = Int(orderString) ?? 0
            let image = "\(folder)/\(parsed.metadata["image"] ?? "")"
            return .project(title: title, order: order, path: path, image: image, html: html)
        }
    }
    
    func generateHtmlFromMarkdown(folder: String, markdownURL: URL) throws -> ContentItem {
        
        let item = try parseItem(folder: folder, markdownURL: markdownURL)
        
        let buildFolderURL = buildURL.appendingPathComponent(item.type.subFolder).appendingPathComponent(folder)
        
        let pageHtml: String
        switch item.type {
        case .post:
            pageHtml = template.getPost(post: item)
        case .project:
            pageHtml = template.getProject(project: item)
        }
        let buildFileURL = buildFolderURL.appendingPathComponent("index.html")
        try pageHtml.write(to: buildFileURL, atomically: true, encoding: .utf8)
        
        return item
    }
}
