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
    let assetPaths: [URL]
}

enum ParsingError: Error {
    case missingFrontMatter
    case invalidDate
}

struct Content {
    var contentPath = ""
    let postsFolder = "posts"
    let projectsFolder = "work"
    let aboutFolder = "about"
    
    let fileManager = FileManager.default

    var posts: [Post] = []
    var projects: [Post] = []
    var aboutPage: Post?
    
    mutating func read(from contentPath: String) throws {
        self.contentPath = contentPath
        try posts = scanFolder(contentPath + "/" + postsFolder)
        try projects = scanFolder(contentPath + "/" + projectsFolder)
        try aboutPage = parsePost(rootFolder: contentPath, filename: "index.md", folder: aboutFolder, assetFiles: [])
    }
    
    mutating func scanFolder(_ rootFolder: String) throws -> [Post] {

        var result = [Post]()
        let subFolders = try fileManager.contentsOfDirectory(atPath: rootFolder)
        for folder in subFolders {
            guard !folder.hasPrefix(".") else { continue } // skip hidden folders
            
            let thisPostPath = rootFolder + "/" + folder
            let files = try fileManager.contentsOfDirectory(atPath: thisPostPath)
            var assetFiles: [String] = []
            var markdownFilename: String?
            
            for file in files {
                if file.hasSuffix(".md") && markdownFilename == nil {
                    markdownFilename = file
                } else {
                    assetFiles.append(file)
                }
            }
                
            if let filename = markdownFilename {
                let post = try parsePost(rootFolder: rootFolder, filename: filename, folder: folder, assetFiles: assetFiles)
                result.append(post)
            } else {
                print("\(thisPostPath): no markdown file found, skipping")
                continue
            }
        }

        return result.sorted { $0.date > $1.date }
    }
    
    func parsePost(rootFolder: String, filename: String, folder: String, assetFiles: [String]) throws -> Post {
        let filePath = rootFolder + "/" + folder + "/" + filename
        let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
        let components = fileContent.components(separatedBy: "+++")
        guard components.count == 3 else {
            throw ParsingError.missingFrontMatter
        }
        let frontMatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let content = components[2].trimmingCharacters(in: .whitespacesAndNewlines)

        let (title, date) = try parseFrontMatter(frontMatter)

        let assetPaths = assetFiles.map { asset in
            URL(fileURLWithPath: rootFolder)
                .appendingPathComponent(folder)
                .appendingPathComponent(asset)
        }
        
        return Post(title: title, date: date, folder: folder, content: content, assetPaths: assetPaths)
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
