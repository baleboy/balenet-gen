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
    
    var subFolder: String {
        switch self {
            case .post: return "posts"
            case .project: return "work"
        }
    }
}

struct ContentItem {

    let type: ContentItemType

    // common to all items
    let title: String
    let html: String
    let path: String

    // post specific
    let date: Date?
    
    // project specific
    let order: Int?
    let headerImage: String?
    
    // Factory
    static func post(title: String, date: Date, path: String, html: String) -> ContentItem {
        ContentItem(
            type: .post,
            title: title,
            html: html,
            path: path,
            date: date,
            order: nil,
            headerImage: nil
        )
    }
    
    static func project(title: String, order: Int, path: String, image: String, html: String) -> ContentItem {
        ContentItem(
            type: .project,
            title: title,
            html: html,
            path: path,
            date: nil,
            order: order,
            headerImage: image
        )
    }
}



