//
//  HtmlGenerator.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 15.12.2024.
//

import Foundation
import Ink

private struct RenderTarget {
    let item: ContentItem
    let outputDirectory: URL
}

struct StaticSite {
    let title: String
    let template: TemplateEngine
    let baseURL: URL
    
    let fileManager = FileManager.default
    
    let parser: MarkdownParser = {
        var parser = MarkdownParser()
        parser.addModifier(.youtubeEmbed())
        return parser
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let sourceURL: URL
    let buildURL: URL
    let contentURL: URL
    let projectsURL: URL
    
    init(title: String, baseURL: URL, sourceURL: URL, buildURL: URL, templateDirectory: URL) throws {
        
        self.title = title
        self.baseURL = baseURL
        self.sourceURL = sourceURL
        self.buildURL = buildURL
        self.contentURL = sourceURL.appendingPathComponent("content")
        self.projectsURL = contentURL.appendingPathComponent("work")
        
        template = try TemplateEngine(title: title, directory: templateDirectory)
    }
    
    enum ParsingError: Error {
        case missingFrontMatter
        case invalidDate
    }
    
    func build() {

        do {
            deleteBuildDirectory()
            copyStaticFiles()

            let postTargets = try generateItemsFromDirectory(type: .post)
            let posts = postTargets.map(\.item)
            let sortedPosts = sortPostsByDate(posts)
            let topicIndex = buildTopicIndex(from: posts)
            let navigationTopics = topicIndex.keys.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

            try render(renderTargets: postTargets, navigationTopics: navigationTopics)

            let projectTargets = try generateItemsFromDirectory(type: .project)
            let projects = projectTargets.map(\.item).sorted {
                ($0.order ?? 0) > ($1.order ?? 0)
            }

            try render(renderTargets: projectTargets, navigationTopics: navigationTopics)

            let devlogTargets = try generateDevlogItems()
            let devlogEntries = devlogTargets.map(\.item)
            let devlogIndex = buildDevlogIndex(from: devlogEntries)

            try render(renderTargets: devlogTargets, navigationTopics: navigationTopics)

            try generateHomepage(postlist: sortedPosts, navigationTopics: navigationTopics)
            try generateTopicPages(topicIndex: topicIndex, navigationTopics: navigationTopics)
            try generateProjectsPage(projectlist: projects, navigationTopics: navigationTopics)
            try generateDevlogPages(devlogIndex: devlogIndex, navigationTopics: navigationTopics)
            try generateDevlogsIndexPage(devlogIndex: devlogIndex, navigationTopics: navigationTopics)
            try generateAboutPage(navigationTopics: navigationTopics)
            try generateSitemap(
                posts: sortedPosts,
                projects: projects,
                topicIndex: topicIndex,
                devlogIndex: devlogIndex
            )
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
    
    func generateHomepage(postlist: [ContentItem], navigationTopics: [Topic]) throws {
        let homepageHTML = template.renderHomePage(
            postlist: postlist,
            navigationTopics: navigationTopics
        )
        let homepageURL = buildURL.appendingPathComponent("index.html")
        try homepageHTML.write(
            to: homepageURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func generateProjectsPage(projectlist: [ContentItem], navigationTopics: [Topic]) throws {
        let pageHTML = template.renderProjectsPage(
            projectlist: projectlist,
            navigationTopics: navigationTopics
        )
        let targetURL = buildURL.appendingPathComponent("work/index.html")
        try pageHTML.write(
            to: targetURL,
            atomically: true,
            encoding: .utf8
        )
    }

    func generateTopicPages(topicIndex: [Topic: [ContentItem]], navigationTopics: [Topic]) throws {
        guard !topicIndex.isEmpty else { return }

        let topicsDirectory = buildURL.appendingPathComponent("topics")
        try fileManager.createDirectory(at: topicsDirectory, withIntermediateDirectories: true)

        let sortedTopics = topicIndex.keys.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        for topic in sortedTopics {
            guard let posts = topicIndex[topic] else { continue }
            let pageHTML = template.renderTopicPage(
                topic: topic,
                postlist: posts,
                navigationTopics: navigationTopics
            )
            let topicDirectory = topicsDirectory.appendingPathComponent(topic.slug)
            try fileManager.createDirectory(at: topicDirectory, withIntermediateDirectories: true)
            let fileURL = topicDirectory.appendingPathComponent("index.html")
            try pageHTML.write(
                to: fileURL,
                atomically: true,
                encoding: .utf8
            )
        }
    }

    func generateDevlogPages(devlogIndex: [String: [ContentItem]], navigationTopics: [Topic]) throws {
        guard !devlogIndex.isEmpty else { return }

        let devlogDirectory = buildURL.appendingPathComponent("devlog")
        try fileManager.createDirectory(at: devlogDirectory, withIntermediateDirectories: true)

        let sortedProjects = devlogIndex.keys.sorted()

        for project in sortedProjects {
            guard let entries = devlogIndex[project] else { continue }

            // Get description from any entry that has one
            let description = entries.first(where: { $0.description != nil })?.description

            let pageHTML = template.renderDevlogPage(
                projectName: project.capitalized,
                entries: entries,
                description: description,
                navigationTopics: navigationTopics
            )
            let projectDirectory = devlogDirectory.appendingPathComponent(project)
            try fileManager.createDirectory(at: projectDirectory, withIntermediateDirectories: true)
            let fileURL = projectDirectory.appendingPathComponent("index.html")
            try pageHTML.write(
                to: fileURL,
                atomically: true,
                encoding: .utf8
            )
        }
    }

    func generateDevlogsIndexPage(devlogIndex: [String: [ContentItem]], navigationTopics: [Topic]) throws {
        guard !devlogIndex.isEmpty else { return }

        let pageHTML = template.renderDevlogsIndexPage(
            devlogIndex: devlogIndex,
            navigationTopics: navigationTopics
        )
        let devlogDirectory = buildURL.appendingPathComponent("devlog")
        try fileManager.createDirectory(at: devlogDirectory, withIntermediateDirectories: true)
        let fileURL = devlogDirectory.appendingPathComponent("index.html")
        try pageHTML.write(
            to: fileURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func generateAboutPage(navigationTopics: [Topic]) throws {
        let markdownURL = contentURL.appendingPathComponent("about.md")
        let markdown = try String(contentsOf: markdownURL, encoding: .utf8)
        let aboutHTML = template.renderPage(
            withContent: parser.html(from: markdown),
            navigationTopics: navigationTopics
        )
        
        let aboutFolderURL = buildURL.appendingPathComponent("about")
        
        try fileManager.createDirectory(at: aboutFolderURL, withIntermediateDirectories: true)
        let aboutFileURL = aboutFolderURL.appendingPathComponent("index.html")
        try aboutHTML.write(
            to: aboutFileURL,
            atomically: true,
            encoding: .utf8
        )
    }

    private func render(renderTargets: [RenderTarget], navigationTopics: [Topic]) throws {
        for target in renderTargets {
            let pageHtml: String
            switch target.item.type {
            case .post:
                pageHtml = template.renderPost(post: target.item, navigationTopics: navigationTopics)
            case .project:
                pageHtml = template.renderProject(project: target.item, navigationTopics: navigationTopics)
            case .devlog:
                pageHtml = template.renderDevlogEntry(entry: target.item, navigationTopics: navigationTopics)
            }

            let buildFileURL = target.outputDirectory.appendingPathComponent("index.html")
            try pageHtml.write(
                to: buildFileURL,
                atomically: true,
                encoding: .utf8
            )
        }
    }

    private func sortPostsByDate(_ posts: [ContentItem]) -> [ContentItem] {
        posts.sorted {
            ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast)
        }
    }

    private func buildTopicIndex(from posts: [ContentItem]) -> [Topic: [ContentItem]] {
        var grouped: [Topic: [ContentItem]] = [:]
        for post in posts {
            for topic in post.topics {
                grouped[topic, default: []].append(post)
            }
        }

        var sortedIndex: [Topic: [ContentItem]] = [:]
        for (topic, topicPosts) in grouped {
            sortedIndex[topic] = sortPostsByDate(topicPosts)
        }

        return sortedIndex
    }

    private func buildDevlogIndex(from entries: [ContentItem]) -> [String: [ContentItem]] {
        var grouped: [String: [ContentItem]] = [:]
        for entry in entries {
            guard let project = entry.project, !project.isEmpty else { continue }
            grouped[project, default: []].append(entry)
        }

        var sortedIndex: [String: [ContentItem]] = [:]
        for (project, projectEntries) in grouped {
            sortedIndex[project] = sortPostsByDate(projectEntries)
        }

        return sortedIndex
    }
    
    private func generateItemsFromDirectory(type: ContentItemType) throws -> [RenderTarget] {
        var targets: [RenderTarget] = []
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
                    let item = try parseItem(folder: folder, markdownURL: fileURL)
                    let target = RenderTarget(
                        item: item,
                        outputDirectory: buildFolderURL
                    )
                    targets.append(target)
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

        return targets
    }

    private func generateDevlogItems() throws -> [RenderTarget] {
        var targets: [RenderTarget] = []
        let devlogsURL = contentURL.appendingPathComponent("devlogs")

        // Check if devlogs directory exists
        guard fileManager.fileExists(atPath: devlogsURL.path) else {
            return targets
        }

        // Get project folders (first level)
        let projectFolderURLs = try fileManager.contentsOfDirectory(
            at: devlogsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        )

        for projectFolderURL in projectFolderURLs {
            let projectSlug = projectFolderURL.lastPathComponent

            // Get entry folders within each project (second level)
            let entryFolderURLs = try fileManager.contentsOfDirectory(
                at: projectFolderURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )

            for entryFolderURL in entryFolderURLs {
                let entrySlug = entryFolderURL.lastPathComponent

                // Get all files in the entry directory
                let fileURLs = try fileManager.contentsOfDirectory(
                    at: entryFolderURL,
                    includingPropertiesForKeys: [.isRegularFileKey],
                    options: []
                )

                // Create build directory for this entry
                let buildFolderURL = buildURL
                    .appendingPathComponent("devlogs")
                    .appendingPathComponent(projectSlug)
                    .appendingPathComponent(entrySlug)
                try fileManager.createDirectory(
                    at: buildFolderURL,
                    withIntermediateDirectories: true
                )

                for fileURL in fileURLs {
                    if fileURL.pathExtension == "md" {
                        // Parse with combined path
                        let combinedPath = "\(projectSlug)/\(entrySlug)"
                        let item = try parseItem(folder: combinedPath, markdownURL: fileURL)
                        let target = RenderTarget(
                            item: item,
                            outputDirectory: buildFolderURL
                        )
                        targets.append(target)
                    } else {
                        // Copy entry asset files to build folder
                        let destinationURL = buildFolderURL.appendingPathComponent(fileURL.lastPathComponent)
                        try fileManager.copyItem(
                            at: fileURL,
                            to: destinationURL
                        )
                    }
                }
            }
        }

        return targets
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
            let topics = Topic.parseList(from: parsed.metadata["topics"])
            return .post(title: title, date: date, path: path, html: html, topics: topics)
        case .project:
            let orderString = parsed.metadata["order"] ?? ""
            let order = Int(orderString) ?? 0
            let image = "\(folder)/\(parsed.metadata["image"] ?? "")"
            return .project(title: title, order: order, path: path, image: image, html: html)
        case .devlog:
            let dateString = parsed.metadata["date"] ?? ""
            let date = dateFormatter.date(from: dateString) ?? Date()
            let topics = Topic.parseList(from: parsed.metadata["topics"])
            let project = parsed.metadata["project"] ?? ""
            let github = parsed.metadata["github"]
            let description = parsed.metadata["description"]
            return .devlog(title: title, date: date, path: path, html: html, project: project, topics: topics, github: github, description: description)
        }
    }
    
}

extension StaticSite {
    private struct SitemapEntry {
        let path: String
        let lastModified: Date?
    }
    
    fileprivate func generateSitemap(posts: [ContentItem], projects: [ContentItem], topicIndex: [Topic: [ContentItem]], devlogIndex: [String: [ContentItem]]) throws {
        var entries: [SitemapEntry] = []

        let latestPostDate = posts.first?.date
        entries.append(SitemapEntry(path: "/", lastModified: latestPostDate))
        entries.append(SitemapEntry(path: "/about/", lastModified: nil))
        entries.append(SitemapEntry(path: "/work/", lastModified: nil))

        if !devlogIndex.isEmpty {
            let latestDevlogDate = devlogIndex.values.flatMap { $0 }.max {
                ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast)
            }?.date
            entries.append(SitemapEntry(path: "/devlog/", lastModified: latestDevlogDate))
        }

        for post in posts {
            entries.append(SitemapEntry(path: post.path, lastModified: post.date))
        }

        for project in projects {
            entries.append(SitemapEntry(path: project.path, lastModified: nil))
        }

        let sortedTopics = topicIndex.keys.sorted {
            $0.slug.localizedCaseInsensitiveCompare($1.slug) == .orderedAscending
        }
        for topic in sortedTopics {
            let topicPosts = topicIndex[topic] ?? []
            let lastModified = topicPosts.first?.date
            entries.append(SitemapEntry(path: "/topics/\(topic.slug)/", lastModified: lastModified))
        }

        let sortedProjects = devlogIndex.keys.sorted()
        for projectSlug in sortedProjects {
            let devlogEntries = devlogIndex[projectSlug] ?? []
            let lastModified = devlogEntries.first?.date
            entries.append(SitemapEntry(path: "/devlog/\(projectSlug)/", lastModified: lastModified))

            for entry in devlogEntries {
                entries.append(SitemapEntry(path: entry.path, lastModified: entry.date))
            }
        }

        let sitemapEntries = entries.compactMap { entry -> String? in
            guard let location = URL(string: entry.path, relativeTo: baseURL)?.absoluteURL else {
                print("Skipping invalid sitemap entry for path \(entry.path)")
                return nil
            }
            var xml = "    <url>\n        <loc>\(location.absoluteString)</loc>\n"
            if let lastModified = entry.lastModified {
                xml += "        <lastmod>\(dateFormatter.string(from: lastModified))</lastmod>\n"
            }
            xml += "    </url>"
            return xml
        }.joined(separator: "\n")

        let sitemap = """
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
\(sitemapEntries)
</urlset>
"""

        let sitemapURL = buildURL.appendingPathComponent("sitemap.xml")
        try sitemap.write(to: sitemapURL, atomically: true, encoding: .utf8)
    }
}
