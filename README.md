A Swift static-site generator for my personal website, www.balenet.com.

## Layout

```
balenet-gen/          # Swift generator sources (TemplateEngine, StaticSite, etc.)
site/                 # Live site content, templates, static assets, build output
├── content/          # Markdown posts and pages
├── static/           # CSS, images, fonts… copied verbatim
├── templates/        # Runtime-loaded HTML templates used by TemplateEngine
└── build/            # Generated HTML (gitignored)
scripts/              # Helper scripts (test.sh, publish.sh)
```

Templates are pure HTML with `{{placeholders}}` that the generator replaces at runtime. Because they live under `site/templates`, the version used for the live site and for local development is always in sync.

## Make Targets

```
make build     # Compile the Swift generator into .build/…/balenet-gen
make render    # Build + render the real site into site/build/
make serve     # Render then serve site/build/ via python3 -m http.server
make test      # Run the end-to-end test script against site/
make publish   # Render and push site/build/ to the gh-pages branch for GitHub Pages
make clean     # Remove .build/
make clean-site# Remove site/build/
```

## GitHub Pages Publishing

`make publish` compiles the generator, renders the site into `site/build/`, and pushes that directory to the `gh-pages` branch using a temporary git worktree.

Before running it the first time:

1. Enable GitHub Pages for this repository, selecting the `gh-pages` branch and the root folder. Pages will create the initial branch if it doesn’t exist.
2. If you use a custom domain, create or update `site/static/CNAME` with the domain so that every publish keeps the mapping.

With that in place:

```
make publish
```

The script will reuse the existing branch (creating it on demand), commit the rendered files, and push them to origin. You can override the branch or commit message without editing the script:

```
GITHUB_PAGES_BRANCH=production-pages \
GITHUB_PAGES_COMMIT_MESSAGE="Publish site for launch" \
make publish
```

## Command-line Usage

```
USAGE: balenet-gen [--source <source>] [--output <output>]

OPTIONS:
  -s, --source <source>   Source directory containing content (defaults to current directory)
  -o, --output <output>   Output directory for generated site (default: build)
  -h, --help              Show help information.
```
