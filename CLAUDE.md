# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

balenet-gen is a static site generator written in Swift for generating www.balenet.com. It converts Markdown files with front matter into HTML pages using the Ink parser library by John Sundell.

## Building and Running

This is an Xcode-based Swift project.

### Prerequisites

Ensure xcode-select points to Xcode.app (not Command Line Tools):

```bash
# Check current setting
xcode-select -p

# If it shows /Library/Developer/CommandLineTools, point it to Xcode
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### Build and Run

Build and run using Xcode or command line:

```bash
# Build in Xcode (Cmd+B) or via command line
xcodebuild -project balenet-gen.xcodeproj -scheme balenet-gen build

# Run the generator
./balenet-gen --source <content-directory> --output <build-directory>

# Default usage (source is current directory, output is ./build)
./balenet-gen
```

### Installing System-Wide

Use the Makefile to build and install:

```bash
# Build the project
make

# Build and install to /usr/local/bin (requires sudo)
make install

# Install to custom location
make install PREFIX=~/.local

# Uninstall
make uninstall

# Clean build artifacts
make clean
```

After installation, run `balenet-gen` from anywhere without the `./` prefix.

## Development Workflow

### Watch Mode (Auto-rebuild on Changes)

Use `fswatch` to automatically rebuild when content changes:

```bash
# Install fswatch (if not already installed)
brew install fswatch

# Watch content and static directories, rebuild on changes
fswatch -o content/ static/ | xargs -n1 -I{} ./balenet-gen --source . --output build
```

Alternative using a script (`watch.sh`):
```bash
#!/bin/bash
echo "Watching for changes..."
fswatch -o content/ static/ | while read num; do
    echo "Changes detected, rebuilding..."
    ./balenet-gen --source . --output build
    echo "Build complete!"
done
```

## Architecture

### Core Components

**StaticSite** (StaticSite.swift:11) - Main generator orchestrator
- Coordinates the entire site generation process
- Manages file system operations (copy static files, create directories)
- Uses Ink parser with custom modifiers for Markdown processing
- Generates four types of pages: homepage, projects page, about page, and individual content items

**ContentItem** (ContentItem.swift:32) - Unified content model
- Represents both posts and projects using a single struct with optional fields
- Type is inferred from metadata: `date` indicates a post, `order` + `image` indicates a project
- Factory methods: `ContentItem.post()` and `ContentItem.project()`
- Posts have: title, date, path, html
- Projects have: title, order, path, headerImage, html

**TemplateEngine** (Template.swift:10) - HTML generation
- Generates all HTML output using string interpolation
- Provides: `renderHomePage()`, `renderProjectsPage()`, `renderPost()`, `renderProject()`, `renderPage()`
- Contains common header/footer with site navigation and styling

**BuildCommand** (BuildCommand.swift:4) - CLI entry point
- Uses Swift ArgumentParser for command-line interface
- Accepts `--source` and `--output` options
- Entry point in main.swift:13 calls `BuildCommand.main()`

### Content Processing Flow

1. **StaticSite.build()** orchestrates the process (StaticSite.swift:50):
   - Deletes existing build directory
   - Copies static files from `static/` to build output
   - Generates homepage (sorted posts by date descending)
   - Generates projects page (sorted by order descending)
   - Generates about page from `content/about.md`

2. **generateItemsFromDirectory()** (StaticSite.swift:131):
   - Scans `content/posts/` or `content/work/` subdirectories
   - For each folder: processes Markdown, copies assets
   - Returns list of ContentItem objects for index generation

3. **parseItem()** (StaticSite.swift:180):
   - Parses Markdown with Ink parser
   - Infers type from metadata using `ContentItemType.infer()`
   - Creates appropriate ContentItem (post or project)

4. **generateHtmlFromMarkdown()** (StaticSite.swift:202):
   - Calls parseItem() to get ContentItem
   - Uses Template to generate HTML based on type
   - Writes `index.html` to appropriate folder in build directory

### Directory Structure

Expected source directory layout:
```
source/
├── static/          # CSS, images, favicon (copied as-is to build/)
├── content/
│   ├── about.md     # About page content
│   ├── posts/       # Blog posts
│   │   └── post-folder/
│   │       ├── index.md    # Post markdown with date metadata
│   │       └── [assets]    # Post-specific images/files
│   └── work/        # Projects
│       └── project-folder/
│           ├── index.md    # Project markdown with order/image metadata
│           └── [assets]    # Project-specific images/files
```

### Metadata Format

**Posts** require:
- `title`: Post title
- `date`: YYYY-MM-DD format

**Projects** require:
- `title`: Project title
- `order`: Integer for sorting (higher = appears first)
- `image`: Filename of header image (relative to project folder)

### Custom Ink Modifiers

**youtubeEmbed()** (Ink+Modifiers.swift:12) - Converts YouTube links ending with `#embed` into embedded iframe players. Example: `[Video](https://youtube.com/watch?v=ID#embed)`

## Configuration

**Config.swift** contains hardcoded site configuration:
- Site title
- Homepage intro text
- Projects page intro text

To modify site text, edit Config.swift constants.
