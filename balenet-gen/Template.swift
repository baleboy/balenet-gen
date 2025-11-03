//
//  Template.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 8.1.2025.
//

import Foundation

struct TemplateEngine {
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
    private let topicTemplate: String
    
    init(title: String, directory: URL) throws {
        self.title = title
        
        headerTemplate = try TemplateEngine.loadTemplate(named: "header.html", in: directory)
        footerTemplate = try TemplateEngine.loadTemplate(named: "footer.html", in: directory)
        homepageTemplate = try TemplateEngine.loadTemplate(named: "homepage.html", in: directory)
        postItemTemplate = try TemplateEngine.loadTemplate(named: "post_item.html", in: directory)
        projectsTemplate = try TemplateEngine.loadTemplate(named: "projects.html", in: directory)
        projectCardTemplate = try TemplateEngine.loadTemplate(named: "project_card.html", in: directory)
        postTemplate = try TemplateEngine.loadTemplate(named: "post.html", in: directory)
        projectTemplate = try TemplateEngine.loadTemplate(named: "project.html", in: directory)
        topicTemplate = try TemplateEngine.loadTemplate(named: "topic.html", in: directory)
    }
    
    func renderPage(withContent content: String, navigationTopics: [Topic]) -> String {
        let header = render(
            headerTemplate,
            with: [
                "title": title,
                "topics_navigation": renderTopicsNavigation(navigationTopics)
            ]
        )
        let footer = render(
            footerTemplate,
            with: [
                "title": title,
                "year": currentYear()
            ]
        )
        return header + content + footer
    }
    
    func renderHomePage(postlist: [ContentItem], navigationTopics: [Topic]) -> String {
        let posts = postlist.map(renderPostListItem).joined()
        
        let body = render(
            homepageTemplate,
            with: [
                "posts": posts
            ]
        )
        return renderPage(withContent: body, navigationTopics: navigationTopics)
    }
    
    func renderProjectsPage(projectlist: [ContentItem], navigationTopics: [Topic]) -> String {
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
                "projects": projects
            ]
        )
        return renderPage(withContent: body, navigationTopics: navigationTopics)
    }
    
    func renderPost(post: ContentItem, navigationTopics: [Topic]) -> String {
        let body = render(
            postTemplate,
            with: [
                "title": post.title,
                "date": dateToString(post.date ?? Date()),
                "body": post.html,
                "topics": renderTopicLabels(for: post.topics)
            ]
        )
        return renderPage(withContent: body, navigationTopics: navigationTopics)
    }
    
    func renderProject(project: ContentItem, navigationTopics: [Topic]) -> String {
        let body = render(
            projectTemplate,
            with: [
                "title": project.title,
                "body": project.html
            ]
        )
        return renderPage(withContent: body, navigationTopics: navigationTopics)
    }
    
    func renderTopicPage(topic: Topic, postlist: [ContentItem], navigationTopics: [Topic]) -> String {
        let posts = postlist.map(renderPostListItem).joined()
        let body = render(
            topicTemplate,
            with: [
                "topic_name": topic.displayName,
                "posts": posts
            ]
        )
        return renderPage(withContent: body, navigationTopics: navigationTopics)
    }
    
    private func renderPostListItem(_ post: ContentItem) -> String {
        render(
            postItemTemplate,
            with: [
                "path": post.path,
                "title": post.title,
                "date": dateToString(post.date ?? Date()),
                "topics": renderTopicLabels(for: post.topics)
            ]
        )
    }
    
    private func renderTopicLabels(for topics: [Topic]) -> String {
        guard !topics.isEmpty else { return "" }
        
        let labels = topics.map { topic in
            "<a class=\"topic-label\" href=\"/topics/\(topic.slug)/\">\(topic.displayName)</a>"
        }.joined(separator: " ")
        
        return "<span class=\"topic-labels\">\(labels)</span>"
    }
    
    private func renderTopicsNavigation(_ topics: [Topic]) -> String {
        guard !topics.isEmpty else { return "" }
        
        return topics.map { topic in
            "<li class=\"nav-topic\"><a href=\"/topics/\(topic.slug)/\">\(topic.displayName)</a></li>"
        }.joined()
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func currentYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    private func render(_ template: String, with data: [String: String]) -> String {
        var result = template
        for (key, value) in data {
            let tokens = [
                "{{\(key)}}",
                "{{ \(key) }}",
                "{{\(key) }}",
                "{{ \(key)}}"
            ]
            for token in tokens {
                result = result.replacingOccurrences(of: token, with: value)
            }
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

extension TemplateEngine {
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
