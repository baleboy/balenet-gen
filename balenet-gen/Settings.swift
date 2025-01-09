//
//  Settings.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 1.1.2025.
//

struct Settings {
    static let title = "Balenet"

    static let sourcePath = "/Users/francesco.balestrieri/Documents/balenet"
    
    static let contentPath = sourcePath + "/content"
    static let postsPath = contentPath + "/posts"
    static let projectsPath = contentPath + "/work"
    static let staticPath = sourcePath + "/static"
    
    static let buildPath = sourcePath + "/build"

    static let introText = """
        Welcome to Balenet, personal website of Francesco Balestrieri. Here you can find my thoughts about various topics, but mostly software engineering and pizza.
        """
    
    static let projectsIntroText = """
        A list of the projects I have worked on during my career.
    """
}
