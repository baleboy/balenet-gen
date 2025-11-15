//
//  Content.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 11.1.2025.
//

import Foundation

enum ContentItemType {
    case post
    case project
    case devlog

    static func infer(from metadata: [String: String]) throws -> ContentItemType {
        // Check for distinctive metadata
        if let dateValue = metadata["date"], let projectValue = metadata["project"], !projectValue.isEmpty {
            return .devlog
        } else if metadata["date"] != nil {
            return .post
        } else if metadata["order"] != nil && metadata["image"] != nil {
            return .project
        }
        throw GenerationError(message: "Could not infer content item type")
    }

    var subFolder: String {
        switch self {
            case .post: return "posts"
            case .project: return "work"
            case .devlog: return "devlogs"
        }
    }
}

struct Topic: Hashable {
    let name: String
    let slug: String
    
    var displayName: String {
        name.capitalized
    }
    
    init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let slugValue = Topic.slugify(trimmed)
        guard !slugValue.isEmpty else { return nil }
        
        name = trimmed
        slug = slugValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(slug)
    }
    
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        lhs.slug == rhs.slug
    }
}

extension Topic {
    static func parseList(from metadataValue: String?) -> [Topic] {
        guard let metadataValue else { return [] }
        
        var uniqueTopics: [Topic] = []
        var seenTopics: Set<Topic> = []
        
        for component in metadataValue.split(separator: ",") {
            let rawValue = String(component)
            guard let topic = Topic(rawValue: rawValue) else { continue }
            if seenTopics.insert(topic).inserted {
                uniqueTopics.append(topic)
            }
        }
        
        return uniqueTopics
    }
    
    private static func slugify(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " -_"))
        let filteredScalars = value.lowercased().unicodeScalars.filter { scalar in
            allowed.contains(scalar)
        }
        
        var slug = String(String.UnicodeScalarView(filteredScalars))
        slug = slug.replacingOccurrences(of: "_", with: "-")
        slug = slug.replacingOccurrences(of: " ", with: "-")
        
        while slug.contains("--") {
            slug = slug.replacingOccurrences(of: "--", with: "-")
        }
        
        slug = slug.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return slug
    }
}

struct ContentItem {

    let type: ContentItemType

    // common to all items
    let title: String
    let html: String
    let path: String
    let topics: [Topic]

    // post specific
    let date: Date?

    // project specific
    let order: Int?
    let headerImage: String?

    // devlog specific
    let project: String?
    let github: String?
    let description: String?

    // Factory
    static func post(title: String, date: Date, path: String, html: String, topics: [Topic]) -> ContentItem {
        ContentItem(
            type: .post,
            title: title,
            html: html,
            path: path,
            topics: topics,
            date: date,
            order: nil,
            headerImage: nil,
            project: nil,
            github: nil,
            description: nil
        )
    }

    static func project(title: String, order: Int, path: String, image: String, html: String) -> ContentItem {
        ContentItem(
            type: .project,
            title: title,
            html: html,
            path: path,
            topics: [],
            date: nil,
            order: order,
            headerImage: image,
            project: nil,
            github: nil,
            description: nil
        )
    }

    static func devlog(title: String, date: Date, path: String, html: String, project: String, topics: [Topic], github: String?, description: String?) -> ContentItem {
        ContentItem(
            type: .devlog,
            title: title,
            html: html,
            path: path,
            topics: topics,
            date: date,
            order: nil,
            headerImage: nil,
            project: project,
            github: github,
            description: description
        )
    }
}

