//
//  main.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 8.12.2024.
//

import Foundation

let sourcePath = "/Users/baleboy/websites/balenet-gen/content"
let outputPath = "/Users/baleboy/websites/balenet-gen/public"
let postsFoldername = "posts"

struct Post {
    let title: String
    let date: Date
    let folder: String
    let content: String
}

enum ParsingError: Error {
    case missingFrontMatter
    case invalidDate
}

var posts: [Post] = []

let fileManager = FileManager.default

// 1. parsing

let folders = try fileManager.contentsOfDirectory(atPath: sourcePath + "/" + postsFoldername)

for folder in folders {
    guard !folder.hasPrefix(".") else { continue }
    let postPath = sourcePath + "/" + postsFoldername + "/" + folder
    let files = try fileManager.contentsOfDirectory(atPath: postPath)
    for file in files {
        if file.hasSuffix(".md") {
        // parse front matter
            let post = try parsePost(filePath: postPath + "/" + file)
            posts.append(post)
            break; // only parse the first MD file
        }
    }
}

// parses a markdown document representing a post. The format is:
// +++
// title = "AI designed this app"
// date = "2024-04-14"
// +++
// content
func parsePost(filePath: String) throws -> Post {
    let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
    let components = fileContent.components(separatedBy: "+++")
    guard components.count == 3 else {
        throw ParsingError.missingFrontMatter
    }
    let frontMatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
    let content = components[2].trimmingCharacters(in: .whitespacesAndNewlines)

    let (title, date) = try parseFrontMatter(frontMatter)

    return Post(title: title, date: date, folder: String(filePath.split(separator: "/").last ?? ""), content: content)
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

// 1. read the first .md file found
// 2. extract data from MD (date, title, folder name, content)
// 3. store in Post object
// 4. append to posts array

// 2. Generating

// start generating HTML index page (header)

// for each post in posts starting from the newest
// 1. generate folder /public/posts/{post.folder}
// 2. create HTML content as header + content + footer and save as index.html
// 3. save in folder
// 4. add link in index page

// add footer
// save index

let sortedPosts = posts.sorted { $0.date > $1.date }

for post in sortedPosts {
    print("\(post.date): \(post.title)")
}

