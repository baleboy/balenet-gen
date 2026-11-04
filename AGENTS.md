# Repository Guidelines

## Project Structure & Module Organization
The generator lives in `src/`: `cli.ts` parses arguments, `site.ts` orchestrates file IO and rendering, `template.ts` fills the HTML templates, `markdown.ts` handles front matter and markdown-it plugins, `content.ts` holds the content model and topics, and `dev.ts` is the live-reload dev server. Site configuration (title, URL) is in `config.ts`. Content, templates and static assets live under `site/`; generated output goes to `site/build/` and must not be committed.

## Build, Test, and Development Commands
- `npm run dev` — build with drafts, serve on localhost:8000, rebuild and reload on changes.
- `npm run build` — render `site/` into `site/build/`.
- `npm test` — run the `node:test` suites in `test/`.
- `npm run typecheck` — run `tsc` (no emit).
- `npm run deploy` — build and push `site/build/` to `gh-pages`.

Node runs the `.ts` files directly; there is no compile step.

## Coding Style & Naming Conventions
Use 4-space indentation and keep lines under ~120 characters. `PascalCase` for types and classes, `camelCase` for functions and variables. Only erasable TypeScript syntax is allowed (no `enum`, `namespace` or parameter properties), and relative imports include the `.ts` extension. HTML markup belongs in `site/templates/` or `template.ts`, not scattered through other modules.

## Content Metadata
Front matter is `key: value` lines between `---` fences. Posts need `title` and `date` (YYYY-MM-DD) and may have a comma-separated `topics` list, which becomes `/topics/<slug>/` pages. Projects need `title`, `order` and `image`. `draft: true` keeps an item out of published builds.

## Testing Guidelines
Run `npm run typecheck && npm test` before committing. End-to-end tests build into a temp directory; add fixture content under `Fixtures/` rather than depending on specific posts in `site/` where possible.
