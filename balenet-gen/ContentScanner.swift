//
//  ContentScanner.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 15.12.2024.
//

import Foundation

struct Post {
    let title: String
    let date: Date
    let folder: String
    let content: String
    let assets: [String]
}

enum ParsingError: Error {
    case missingFrontMatter
    case invalidDate
}

struct ContentScanner {
    let contentPath = "/Users/baleboy/websites/balenet-gen/content"
    let postsRoot = "posts"
    let fileManager = FileManager.default

    var posts: [Post] = []
    
    
    mutating func scanPosts() throws {
        let folders = try fileManager.contentsOfDirectory(atPath: contentPath + "/" + postsRoot)

        for folder in folders {
            guard !folder.hasPrefix(".") else { continue } // skip hidden folders
            
            let postPath = contentPath + "/" + postsRoot + "/" + folder
            let files = try fileManager.contentsOfDirectory(atPath: postPath)
            var assets: [String] = []
            var markdownName: String?
            
            for file in files {
                if file.hasSuffix(".md") && markdownName == nil {
                    markdownName = file
                } else {
                    assets.append(file)
                }
            }
                
            if let filename = markdownName {
                let post = try parsePost(filePath: postPath + "/" + filename, folder: folder, assets: assets)
                posts.append(post)
            } else {
                print("\(postPath): no markdown file found, skipping")
                continue
            }
        }

        posts = posts.sorted { $0.date > $1.date }
    }
    
    func parsePost(filePath: String, folder: String, assets: [String]) throws -> Post {
        let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
        let components = fileContent.components(separatedBy: "+++")
        guard components.count == 3 else {
            throw ParsingError.missingFrontMatter
        }
        let frontMatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let content = components[2].trimmingCharacters(in: .whitespacesAndNewlines)

        let (title, date) = try parseFrontMatter(frontMatter)

        return Post(title: title, date: date, folder: folder, content: content, assets: assets)
    }

    func parseFrontMatter(_ frontMatter: String) throws -> (title: String, date: Date) {
        var title = ""
        var dateString = ""
        
        for line in frontMatter.components(separatedBy: .newlines) {
            let parts = line.components(separatedBy: "=").map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { continue }
            let key = parts[0]
            let value = parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
            switch key {
            case "title":
                title = value
            case "date":
                dateString = value
            default:
                break
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else {
            throw ParsingError.invalidDate
        }
        
        return (title: title, date: date)
    }

}
