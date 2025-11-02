//
//  Template.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 8.1.2025.
//

import Foundation

struct Template {
    enum TemplateError: Error, LocalizedError {
        case missingTemplateDirectory([URL])
        case failedToLoadTemplate(String)
        
        var errorDescription: String? {
            switch self {
            case .missingTemplateDirectory(let candidates):
                let paths = candidates.map(\.path).joined(separator: ", ")
                return "Could not locate templates directory. Checked: \(paths)"
            case .failedToLoadTemplate(let name):
                return "Failed to load template \(name)"
            }
        }
    }
    
    let title: String
    
    private let headerTemplate: String
    private let footerTemplate: String
    private let homepageTemplate: String
    private let postItemTemplate: String
    private let projectsTemplate: String
    private let projectCardTemplate: String
    private let postTemplate: String
    private let projectTemplate: String
    
    init(title: String, directory: URL) throws {
        self.title = title
        
        headerTemplate = try Template.loadTemplate(named: "header.html", in: directory)
        footerTemplate = try Template.loadTemplate(named: "footer.html", in: directory)
        homepageTemplate = try Template.loadTemplate(named: "homepage.html", in: directory)
        postItemTemplate = try Template.loadTemplate(named: "post_item.html", in: directory)
        projectsTemplate = try Template.loadTemplate(named: "projects.html", in: directory)
        projectCardTemplate = try Template.loadTemplate(named: "project_card.html", in: directory)
        postTemplate = try Template.loadTemplate(named: "post.html", in: directory)
        projectTemplate = try Template.loadTemplate(named: "project.html", in: directory)
    }
    
    func getPage(withContent content: String) -> String {
        let header = render(headerTemplate, with: ["title": title])
        return header + content + footerTemplate
    }
    
    func getHomePage(intro: String, postlist: [ContentItem]) -> String {
        let posts = postlist.map { post in
            render(
                postItemTemplate,
                with: [
                    "path": post.path,
                    "title": post.title,
                    "date": dateToString(post.date ?? Date())
                ]
            )
        }.joined()
        
        let body = render(
            homepageTemplate,
            with: [
                "intro": intro,
                "posts": posts
            ]
        )
        return getPage(withContent: body)
    }
    
    func getProjectsPage(intro: String, projectlist: [ContentItem]) -> String {
        let projects = projectlist.map { project in
            render(
                projectCardTemplate,
                with: [
                    "path": project.path,
                    "image": project.headerImage ?? "",
                    "title": project.title
                ]
            )
        }.joined()
        
        let body = render(
            projectsTemplate,
            with: [
                "intro": intro,
                "projects": projects
            ]
        )
        return getPage(withContent: body)
    }
    
    func getPost(post: ContentItem) -> String {
        let body = render(
            postTemplate,
            with: [
                "title": post.title,
                "date": dateToString(post.date ?? Date()),
                "body": post.html
            ]
        )
        return getPage(withContent: body)
    }
    
    func getProject(project: ContentItem) -> String {
        let body = render(
            projectTemplate,
            with: [
                "title": project.title,
                "body": project.html
            ]
        )
        return getPage(withContent: body)
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func render(_ template: String, with data: [String: String]) -> String {
        var result = template
        for (key, value) in data {
            result = result.replacingOccurrences(
                of: "{{\(key)}}",
                with: value
            )
        }
        return result
    }
    
    private static func loadTemplate(named name: String, in directory: URL) throws -> String {
        let url = directory.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw TemplateError.failedToLoadTemplate(name)
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}

extension Template {
    static func resolveTemplateDirectory(providedPath: String?, sourceURL: URL) throws -> URL {
        let preferredDirectories = preferredTemplateDirectories(
            for: sourceURL,
            providedPath: providedPath
        )
        
        for directory in preferredDirectories {
            if directory.isExistingDirectory {
                return directory
            }
        }
        
        throw TemplateError.missingTemplateDirectory(preferredDirectories)
    }
    
    private static func preferredTemplateDirectories(for sourceURL: URL, providedPath: String?) -> [URL] {
        var candidates: [URL] = []
        
        if let providedPath {
            let providedURL: URL
            if providedPath.hasPrefix("/") {
                providedURL = URL(fileURLWithPath: providedPath)
            } else {
                providedURL = URL(fileURLWithPath: providedPath, relativeTo: sourceURL)
            }
            candidates.append(providedURL.standardizedFileURL)
        }
        
        candidates.append(sourceURL.appendingPathComponent("templates").standardizedFileURL)
        
        let executableURL = URL(fileURLWithPath: CommandLine.arguments.first ?? "")
        let executableDirectory = executableURL.deletingLastPathComponent()
        candidates.append(executableDirectory.appendingPathComponent("templates").standardizedFileURL)
        
        let sourceDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("templates")
        candidates.append(sourceDirectory.standardizedFileURL)
        
        // Deduplicate while preserving order
        var seen: Set<URL> = []
        let uniqueCandidates = candidates.filter { candidate in
            if seen.contains(candidate) {
                return false
            }
            seen.insert(candidate)
            return true
        }
        return uniqueCandidates
    }
}

private extension URL {
    var isExistingDirectory: Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
