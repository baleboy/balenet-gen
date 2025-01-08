//
//  HtmlGenerator.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 15.12.2024.
//

import Foundation
import Ink

struct StaticSite {
    let fileManager = FileManager.default
    let style = """
            body {
                font-family: Verdana, Geneva, sans-serif;
                padding: 20px;
                background-color: #000000;
                color: #33ff33; /* Classic green phosphor color */
            }
    a {
        color: #90ff90; /* Lighter green for links */
        text-decoration: none;
    }
    
    a:visited {
        color: #55bb55; /* Darker green for visited links */
    }
    
    .title a {
        color: #33ff33; /* Keep the title the original bright green */
        font-size: 36px;
        text-transform: uppercase;
    }
    
    .navigation a {
        color: #33ff33; /* Keep navigation the original bright green */
    }
    
    /* Hover effect for all links */
    a:hover {
        background-color: #33ff33;
        color: #000000;
    }
        img {
            max-width: 90%; /* Width margin */
            max-height: 90vh; /* Height limit: 90% of viewport height */
            height: auto; /* Maintain aspect ratio */
            width: auto; /* Allow image to scale down below max-width if needed */
            display: block;
            margin: 20px auto;
            object-fit: contain; /* Ensures image maintains aspect ratio within constraints */
        }
    .container {
        max-width: 800px; /* or whatever width you prefer */
        margin: 0 auto; /* centers the container */
        padding: 0 20px; /* keeps content from touching edges on mobile */
    }
    .title {
        text-align: center;
        margin-bottom: 20px;
    }
    
    .title a {
        font-size: 36px;
        text-decoration: none;
        color: inherit;
    }
    
    .footer{
    text-align: center;
        }
    
    .navigation {
        display: flex;
        justify-content: center;
        gap: 20px; /* Space between navigation links */
    }
    
    .navigation a {
        text-decoration: none;
        color: inherit;
    }
    """
    
    func header(style: String) -> String {
        """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Balenet</title>
        <meta charset="UTF-8">
        <style>
        \(style)
        </style>
      </head>
      <body>
        <div class="container"
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
    }
    
    let footer = """
        <!-- Footer -->
        <div class="footer">
            <p>Copyright &copy Francesco Balestrieri 2022-2024</p>
        </div>   
        </div>
      </body>
    </html>
    """
    
    let intro = "<p>Welcome to Balenet, personal website of Francesco Balestrieri. Here you can find my thoughts about various topics, but mostly software engineering and pizza.</p>"
    
    func generate(from content: Content, to publicPath: String) {
        
        do {
            let publicURL = URL(fileURLWithPath: publicPath)
            // Delete public directory if it exists
            if fileManager.fileExists(atPath: publicPath) {
                try fileManager.removeItem(at: publicURL)
            }
            try generatePostsHtml(posts: content.posts, to: publicPath)
            try generateIndexHtml(to: publicPath, posts: content.posts)
            try generatePostsHtml(posts: content.projects, to: publicPath + "/work")
            try generateIndexHtml(to: publicPath + "/work", posts: content.projects)
            try generateAboutHtml(from: content.aboutPage, to: publicPath + "/about")
        } catch {
            print("Error generating HTML: \(error)")
        }
    }
    
    func generatePostsHtml(posts: [Post], to publicPath: String) throws {
        
        var parser = MarkdownParser()
        parser.addModifier(.youtubeEmbed())
        
        for post in posts {
            
            // Create the post directory
            let postDir = URL(fileURLWithPath: publicPath)
                .appendingPathComponent(post.folder)
            
            try fileManager.createDirectory(
                at: postDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            // copy asset files
            for assetPath in post.assetPaths {
                let assetName = assetPath.lastPathComponent
                let destPath = postDir.appendingPathComponent(assetName)
                try fileManager.copyItem(at: assetPath, to: destPath)
            }
            
            // Generate HTML content
            let htmlContent = header(style: style) + parser.html(from: post.content) + footer
            
            // Save as index.html in the post directory
            let indexPath = postDir.appendingPathComponent("index.html")
            try htmlContent.write(
                to: indexPath,
                atomically: true,
                encoding: .utf8
            )
            
        }
        
        
    }
    
    func generateIndexHtml(to publicPath: String, posts: [Post]) throws {
        var HtmlIndex = header(style: style) + intro;
        
        for post in posts {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: post.date)
            HtmlIndex += "<p>\(dateString): <a href=\"\(post.folder)\">\(post.title)</a></p>"
        }
        
        HtmlIndex += footer
        
        try HtmlIndex.write(to: URL(fileURLWithPath: publicPath + "/index.html"), atomically: true, encoding: .utf8)
    }
    
    func generateAboutHtml(from aboutPage: Post?, to publicPath: String) throws {
        guard let about = aboutPage else {
            fatalError("About page not found")
        }
        var parser = MarkdownParser()
        parser.addModifier(.youtubeEmbed())
        let aboutHtml = header(style: style) + parser.html(from: about.content) + footer
        
        // Create the about directory
        let aboutDir = URL(fileURLWithPath: publicPath)
        try fileManager.createDirectory(
            at: aboutDir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let aboutPath = aboutDir.appendingPathComponent("index.html")
        try aboutHtml.write(
            to: aboutPath,
            atomically: true,
            encoding: .utf8
        )
    }
    
}

extension Modifier {
    static func youtubeEmbed() -> Modifier {
        return Modifier(target: .links) { html, markdown in
            // Only process links that end with #embed
            guard html.contains("#embed") else {
                return html
            }
            
            let pattern = "(?:youtube\\.com\\/watch\\?v=|youtu\\.be\\/)([a-zA-Z0-9_-]+)"
            
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
                  let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)),
                  let videoIdRange = Range(match.range(at: 1), in: html) else {
                return html
            }
            
            let videoId = String(html[videoIdRange])
            return """
                <div class="video-container">
                    <iframe src="https://www.youtube.com/embed/\(videoId)" 
                            frameborder="0" 
                            allowfullscreen>
                    </iframe>
                </div>
                """
        }
    }
}
