A static-site generator for my personal website, www.balenet.com, written in TypeScript and run directly by Node (no build step).

## Layout

```
src/                  # Generator sources (cli, site, template, markdown, dev server)
test/                 # node:test suites
site/                 # Live site content, templates, static assets, build output
├── content/          # Markdown posts and pages
├── static/           # CSS, images, fonts… copied verbatim
├── templates/        # HTML templates with {{placeholders}}
└── build/            # Generated HTML (gitignored)
Fixtures/basic-site/  # Minimal site used by the tests
scripts/publish.sh    # Pushes site/build/ to the gh-pages branch
```

## Commands

Requires Node 22.18 or newer.

```
npm install        # Install dependencies (once)
npm run dev        # Build with drafts, serve on localhost:8000, live reload on changes
npm run build      # Render site/ into site/build/
npm test           # Run the tests
npm run typecheck  # Type-check with tsc
npm run deploy     # Build and push site/build/ to the gh-pages branch
npm run clean      # Remove site/build/
```

`npm run dev` accepts `-- --port <n>`, `-- --no-drafts` and `-- --no-open`.

## Drafts

Add `draft: true` to a post's or project's front matter to keep it out of the published site. `npm run dev` shows drafts with a banner; `npm run build` and `npm run deploy` skip them entirely.

## GitHub Pages Publishing

Pushing to `main` runs `.github/workflows/publish.yml`, which installs dependencies, runs the tests and calls `npm run deploy`. That renders the site into `site/build/` and pushes it to the `gh-pages` branch using a temporary git worktree.

Before the first publish:

1. Enable GitHub Pages for this repository, selecting the `gh-pages` branch and the root folder.
2. If you use a custom domain, keep it in `site/static/CNAME` so every publish preserves the mapping.

You can override the branch or commit message:

```
GITHUB_PAGES_BRANCH=production-pages \
GITHUB_PAGES_COMMIT_MESSAGE="Publish site for launch" \
npm run deploy
```

## Command-line Usage

```
USAGE: node src/cli.ts [--source <source>] [--output <output>] [--templates <dir>] [--drafts]

OPTIONS:
  -s, --source <source>     Source directory containing content (default: current directory)
  -o, --output <output>     Output directory, relative to source (default: build)
  -t, --templates <dir>     Template directory, relative to source (default: <source>/templates)
      --drafts              Include items marked 'draft: true' in their front matter
  -h, --help                Show help information.
```
