//
//  Settings.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 1.1.2025.
//

import Foundation

struct Config {
    static let title = "Balenet"
    static let siteURLString = "https://www.balenet.com"
    
    static var siteURL: URL {
        guard let url = URL(string: siteURLString) else {
            fatalError("Invalid site URL in configuration")
        }
        return url
    }
}
