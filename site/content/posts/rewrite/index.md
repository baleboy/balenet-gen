---
title: Claude rewrote my static generator in Typescript, and I barely had time for a coffee
date:  2026-11-05
topics: AI, devlog
---

[I wrote the static generator for this blog in Swift almost two years ago](/posts/generator/). At the time I was trying to learn iOS programming and while I used Claude (the web chat interface) to help me, I tried to write the code by hand or at least understand it. The whole thing was a bit clunky, required XCode to build and was scripted via Makefile, but it did the job and, most importantly, it was MINE.

Fast-forward to today and there is no point in learning any language anymore given that Claude Code does all the work. I needed to implement a new feature to support draft posts, which Claude did in minutes, but when publishing the new version to Github, things started to fail. It turns out that Mac OS hosts, which xcodebuild requires obviously, are a scarce resource in Github Actions and often time out. What to do? In another time I would have tried to figure out how to run a Swift compiler on Ubuntu, but in this day an age there was a much "simpler" solution: rewrite the whole thing in Typescript on Node! I gave Claude Code the job and it started chugging along in auto mode, I went to make coffee and by the time I was back... it was done! Everything worked perfectly, I even have hot reload that was missing from the previous version, and the whole thing builds in a fraction of the time on a generic Linux host.

Why Typescript/Node? Apparently (again, according to Claude) it has the best support for Markdown, and agents know very well how to write it. It could have been Rust, Golang or Python but for a project this size it doesn't really matter.

The whole experience was both exhilarating and depressing. What is the point of learning any language, or let alone create a new one? Have we reached peak language? And what about all those years spent studying computer science? And most important of all, come next year how will all this have changed? Crazy stuff!