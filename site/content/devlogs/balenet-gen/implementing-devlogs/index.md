---
title: A devlog entry about devlogs
date: 2025-01-17
project: balenet-gen
---

Added a complete devlog system to track development progress for personal projects. This keeps project-specific updates separate from regular blog posts while maintaining the same clean aesthetic.

## Why Devlogs?

Regular blog posts are polished, longer pieces about specific topics. Devlogs are shorter, more conversational updates about what I'm working on. They're meant to be quick notes about progress, problems solved, and things learned while building a project.

## Content Structure

Devlogs use a two-level directory structure under `content/devlogs/`:

```
content/devlogs/
  project-slug/
    entry-1/
      index.md
    entry-2/
      index.md
```

This is different from posts (which are one level deep) because devlogs are organized by project first, then by individual entries.

## Metadata

Each devlog entry requires:
- `title`: Entry title
- `date`: Entry date (YYYY-MM-DD)
- `project`: Project slug (used to group entries)

Optional metadata:
- `topics`: Comma-separated topics (for categorization)
- `github`: GitHub repository URL (shows icon next to project name)
- `description`: Project description (shown on devlog index, only needed on one entry per project)

## Generated Pages

The system generates three types of pages:

1. **Main devlog index** (`/devlog/`): Lists all projects with devlogs, showing entry counts and GitHub links
2. **Project devlog** (`/devlog/project-name/`): Lists all entries for a specific project, with optional description
3. **Individual entries** (`/devlogs/project-name/entry-name/`): Full entry page with back link to project devlog

## Implementation Details

**ContentItem types**: Added `.devlog` as a third content type alongside `.post` and `.project`. Devlogs are identified by having both `date` and `project` metadata.

**Specialized scanning**: Created `generateDevlogItems()` to handle the two-level directory structure. It iterates through project folders first, then entry folders within each project.

**Index building**: `buildDevlogIndex()` groups entries by project slug and sorts chronologically (newest first).

**Templates**: Created three templates:
- `devlogs_index.html`: Main index listing projects
- `devlog.html`: Project-specific entry list with description
- `devlog_entry.html`: Individual entry page
- `devlog_item.html` and `devlog_project_item.html`: List item templates

**Styling**: Reused existing `.post-list` and `.post-heading` classes so devlogs match the site's aesthetic. Added `.project-description` for the project description paragraph.

**Navigation**: Added "Devlogs" button to the navbar using the same topic-label styling as "Work".

## What Works Well

The two-level structure keeps things organized. Having the project slug in the metadata (rather than inferring it from the directory) makes it explicit and prevents errors.

Reusing the post list styling means devlogs fit naturally into the site's design without custom CSS.

The optional metadata approach (github, description) means you can add these details to any entry and they'll be picked up for the project-level page.

## Future Ideas

Could add filtering by topic on the main devlog index. Could also show the latest entry date for each project instead of just the count.

Might be nice to generate RSS feeds for individual project devlogs, so people can subscribe to updates for specific projects they're interested in.
