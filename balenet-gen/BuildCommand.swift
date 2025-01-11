import Foundation
import ArgumentParser

struct BuildCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "balenet-gen",
        abstract: "Generate static website from markdown files"
    )
    
    @Option(
        name: .shortAndLong,
        help: "Source directory containing content (defaults to current directory)"
    )
    var source: String?
    
    @Option(
        name: .shortAndLong,
        help: "Output directory for generated site"
    )
    var output: String = "build"
    
    func run() throws {
        let sourceURL = URL(fileURLWithPath: source ?? FileManager.default.currentDirectoryPath)
        
        let outputURL = URL(fileURLWithPath: output, relativeTo: sourceURL)
        
        print("Generating site from \(sourceURL.path) to \(outputURL.path)")
        
        let site = StaticSite(
            title: Config.title,
            sourceURL: sourceURL,
            buildURL: outputURL
        )
        site.build()
    }
}
