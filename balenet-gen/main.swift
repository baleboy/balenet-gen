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

var content = Content()
try content.read(from: "/Users/baleboy/websites/balenet-gen/content")

let site = StaticSite()
site.generate(content: content, toFolder: "/Users/baleboy/websites/balenet-gen/test/public")
