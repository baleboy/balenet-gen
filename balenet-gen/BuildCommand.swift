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
    
    @Option(
        name: .shortAndLong,
        help: "Template directory (defaults to <source>/templates or bundled defaults)"
    )
    var templates: String?
    
    func run() throws {
        let sourceURL = URL(fileURLWithPath: source ?? FileManager.default.currentDirectoryPath)
        
        let outputURL = URL(fileURLWithPath: output, relativeTo: sourceURL)
        let templateDirectory = try TemplateEngine.resolveTemplateDirectory(
            providedPath: templates,
            sourceURL: sourceURL
        )
        
        print("Generating site from \(sourceURL.path) to \(outputURL.path)")
        
        let site = try StaticSite(
            title: Config.title,
            baseURL: Config.siteURL,
            sourceURL: sourceURL,
            buildURL: outputURL,
            templateDirectory: templateDirectory
        )
        site.build()
    }
}
