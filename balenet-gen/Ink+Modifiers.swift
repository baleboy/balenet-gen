//
//  Ink+Modifiers.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 9.1.2025.
//

import Foundation
import Ink

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

