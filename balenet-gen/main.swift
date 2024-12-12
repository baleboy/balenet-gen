//
//  main.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 8.12.2024.
//

// Generate the Balenet (www.balenet.com) website from markdown sources.
//
// The input directory should be structured as follows:
//
// /content/
// |
// +- post-1/some-post.md
// +- post-2/some-other-post.md
// ...
//
// If there are multiple .md files only the first one will be processed.
//
// The generated HTML will be:
//
// /public/
// |
// +- index.html
// +- post-1/index.html
// +- post-2/index.html
// ...
// A post's markdown should include a front matter in this format:
//
// +++
// +++
// title = "<post title>"
// date = "YYYY-MM-DD"
// +++
// <post content>
//

import Foundation
import Ink

let contentPath = "/Users/baleboy/websites/balenet-gen/content"
let publicPath = "/Users/baleboy/websites/balenet-gen/test/public"
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
let parser = MarkdownParser()


// 1. parsing

let folders = try fileManager.contentsOfDirectory(atPath: contentPath + "/" + postsFoldername)

for folder in folders {
    guard !folder.hasPrefix(".") else { continue }
    let postPath = contentPath + "/" + postsFoldername + "/" + folder
    let files = try fileManager.contentsOfDirectory(atPath: postPath)
    for file in files {
        if file.hasSuffix(".md") {
            let post = try parsePost(filePath: postPath + "/" + file, folder: folder)
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
func parsePost(filePath: String, folder: String) throws -> Post {
    let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
    let components = fileContent.components(separatedBy: "+++")
    guard components.count == 3 else {
        throw ParsingError.missingFrontMatter
    }
    let frontMatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
    let content = components[2].trimmingCharacters(in: .whitespacesAndNewlines)

    let (title, date) = try parseFrontMatter(frontMatter)

    return Post(title: title, date: date, folder: folder, content: content)
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

let header = """
<!DOCTYPE html>
<html>
  <head>
    <title>Balenet</title>
    <meta charset="UTF-8">
    <style>
    img {
        max-width: 90%; /* Width margin */
        max-height: 90vh; /* Height limit: 90% of viewport height */
        height: auto; /* Maintain aspect ratio */
        width: auto; /* Allow image to scale down below max-width if needed */
        display: block;
        margin: 20px auto;
        object-fit: contain; /* Ensures image maintains aspect ratio within constraints */
    }
    </style>
  </head>
  <body>
    <!-- Title -->
    <div class="title">
      <a href="/">Balenet</a>
    </div>

    <!-- Navigation -->
    <div class="navigation">
      <a href="/work/">Work</a>
      <a href="/about/">About</a>
    </div>
"""

let footer = """
    <!-- Footer -->
    <div class="footer">
        <p>Copyright &copy Francesco Balestrieri 2022-2024</p>
    </div>      
  </body>
</html>
"""

let sortedPosts = posts.sorted { $0.date > $1.date }
let publicURL = URL(fileURLWithPath: publicPath)
// Delete public directory if it exists
if fileManager.fileExists(atPath: publicPath) {
    try fileManager.removeItem(at: publicURL)
}

var HtmlIndex = header;

for post in sortedPosts {
            
        // Create the post directory
        let postDir = URL(fileURLWithPath: publicPath)
        .appendingPathComponent(post.folder)
        
        try fileManager.createDirectory(
            at: postDir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        // Generate HTML content
        let htmlContent = header + parser.html(from: post.content) + footer
        
        // Save as index.html in the post directory
        let indexPath = postDir.appendingPathComponent("index.html")
        try htmlContent.write(
            to: indexPath,
            atomically: true,
            encoding: .utf8
        )
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: post.date)
        // add to index.html
        HtmlIndex += "<p>\(dateString): <a href=\"/\(post.folder)\">\(post.title)</a></p>"
    }

HtmlIndex += footer
let indexPath = publicURL.appendingPathComponent("index.html")
try HtmlIndex.write(to: indexPath, atomically: true, encoding: .utf8)

