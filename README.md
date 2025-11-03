A Swift static-site generator plus the full balenet.com source tree.

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
make publish   # Render and upload site/build/ via FTP (see .env section)
make clean     # Remove .build/
make clean-site# Remove site/build/
```

## FTP Publishing

`make publish` calls `scripts/publish.sh`, which expects FTP credentials in environment variables. Create an `.env` file in the repo root (ignored by git) or export them in your shell:

```
FTP_HOST=ftp.example.com
FTP_USER=your-user
FTP_PASSWORD=your-password
# optional:
# FTP_TARGET_DIR=/path/on/server
# FTP_SSL=false
```

`publish.sh` loads `.env` when present, then uses `lftp` to mirror `site/build/` to the remote server.

## Command-line Usage

```
USAGE: balenet-gen [--source <source>] [--output <output>]

OPTIONS:
  -s, --source <source>   Source directory containing content (defaults to current directory)
  -o, --output <output>   Output directory for generated site (default: build)
  -h, --help              Show help information.
```
