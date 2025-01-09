//
//  main.swift
//  balenet-gen
//
//  Created by Francesco Balestrieri on 8.12.2024.
//

// Generate the Balenet (www.balenet.com) website from markdown sources.
//

import Foundation

let site = StaticSite(title: Settings.title)
site.generate()
