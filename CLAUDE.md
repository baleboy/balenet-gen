# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

balenet-gen is a static site generator written in TypeScript (Node) for generating www.balenet.com. It converts Markdown files with front matter into HTML pages using markdown-it.

## Commands

Requires Node 22.18+ (Node runs the `.ts` sources directly via type stripping; there is no compile step).

```bash
npm install          # once
npm run dev          # build with drafts, serve on http://localhost:8000, rebuild + live reload on changes
npm run build        # render site/ into site/build/ (drafts excluded)
npm test             # node:test suites in test/
npm run typecheck    # tsc --noEmit
npm run deploy       # build, then push site/build/ to the gh-pages branch (scripts/publish.sh)
npm run clean        # remove site/build/
```

`npm run dev` options: `npm run dev -- --port 3000 --no-drafts --no-open`.

CLI: `node src/cli.ts --source <dir> --output <dir relative to source> [--templates <dir>] [--drafts]`.

Because type stripping only erases types, avoid TypeScript-only runtime syntax (`enum`, `namespace`, parameter properties); `erasableSyntaxOnly` in tsconfig enforces this. Relative imports use the `.ts` extension.

## Architecture

- **src/cli.ts** — argument parsing (`node:util` parseArgs), entry point.
- **src/site.ts** — `StaticSite.build()`: deletes the build dir, copies `static/`, generates posts and projects, homepage, topic pages, projects page, about page and `sitemap.xml`.
- **src/content.ts** — `ContentItem` model (posts and projects share one shape), type inference, topics (slug, display name, hash-derived color class).
- **src/markdown.ts** — front matter parsing and markdown-it with two plugins: YouTube `#embed` links become iframes, and image-only paragraphs render without `<p>`.
- **src/template.ts** — `TemplateEngine`: fills `{{placeholder}}` HTML templates from `site/templates/`.
- **src/dev.ts** — dev server: runs the CLI in a child process on each change (so src/ edits apply too), serves `site/build/` and pushes reloads over server-sent events. The reload script is injected at serve time only, never written to disk.
- **src/config.ts** — site title and URL.

### Content Processing

Each subfolder of `content/posts/` or `content/work/` is one item. All `.md` files in it are parsed; every other entry (images, subfolders) is copied next to the generated `index.html`. Drafts are detected before anything is written, so a skipped draft leaves nothing in the build.

### Directory Structure

```
site/
├── static/          # CSS, images, favicon (copied as-is to build/)
├── templates/       # HTML templates with {{placeholders}}
└── content/
    ├── about.md
    ├── posts/<folder>/<any>.md + assets
    └── work/<folder>/<any>.md + assets
```

### Metadata Format

Front matter is simple `key: value` lines between `---` fences (plain strings, not YAML).

**Posts** require `title` and `date` (YYYY-MM-DD); optional `topics` (comma-separated).

**Projects** require `title`, `order` (integer, higher first) and `image` (header image filename in the project folder).

**Drafts** (posts or projects): add `draft: true`. Drafts are skipped by default (no page, no index/topic/sitemap entry, no assets copied). `npm run dev` includes them, with a banner on the page and a badge in lists; `npm run build`/`deploy` never do. Use `--drafts` on the CLI to include them explicitly.

## Testing

`test/build.test.ts` builds `site/` and a copy of `Fixtures/basic-site/` into a temp directory and checks the output (including draft handling). `test/markdown.test.ts` covers front matter, the markdown plugins and topics.

## Deployment

`.github/workflows/publish.yml` runs on push to `main` on `ubuntu-latest`: `npm ci`, typecheck, tests, then `npm run deploy`.
