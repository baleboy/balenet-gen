# Repository Guidelines

## Project Structure & Module Organization
The CLI source lives in `balenet-gen/`, with `BuildCommand.swift` handling argument parsing and `StaticSite.swift` orchestrating file IO and rendering. Configurable text and metadata defaults sit in `Config.swift`; reusable presentation logic is kept in `Template.swift` and `Ink+Modifiers.swift`. The Xcode project `balenet-gen.xcodeproj` is the canonical build definition, and the `Makefile` proxies common actions. Generated output is written to `build/` relative to the chosen source tree; `.build/` is an intermediate derived-data directory and should not be committed.

## Build, Test, and Development Commands
- `make build` — invokes `xcodebuild` in Release mode into `.build/`.
- `make install PREFIX=/custom/path` — copies the Release binary into the specified `bin`.
- `make clean` — removes `.build/` to ensure a fresh build.
After a build, run `./.build/Build/Products/Release/balenet-gen --help` to smoke-test argument parsing. For ad-hoc generation, point the tool at a content root: `./.build/Build/Products/Release/balenet-gen -s ./example-site -o ./example-site/build`.

## Coding Style & Naming Conventions
Use 4-space indentation and keep lines under ~120 characters. Follow Swift API Design Guidelines: `UpperCamelCase` for types (`StaticSite`), `lowerCamelCase` for functions and properties (`generateHomepage`). Group related helpers with `extension` blocks when adding behavior. Prefer explicit `guard` or `switch` over implicit optionals to keep failure paths obvious. Any new string or HTML templates belong in `Template.swift` or a dedicated helper rather than inline literals.

## Tagging & Content Metadata
Front matter supports a comma-separated `tags` key (e.g. `tags: work, software`). Keep tag names short and meaningful—the generator normalises them into `/tags/<slug>/` routes, surfaces them on the home page, each post, and exposes a tag index under `/tags/`.

## Testing Guidelines
There is no XCTest target yet; changes are validated by running the generator against real content. Before opening a PR, execute `make build` and render a sample tree (for example `./.build/Build/Products/Release/balenet-gen -s ../balenet-content -o build`) to catch regressions in parsing or HTML output. When adding automated tests, scaffold an XCTest target under `balenet-genTests` and mirror content fixtures inside a `Fixtures/` folder so they can be reused in future cases.

## Commit & Pull Request Guidelines
Use short, imperative commit messages (`Add homepage pagination`) similar to the existing history. Keep unrelated changes in separate commits. PRs should state the user-visible effect, reference any issue, and enumerate manual verification steps (commands run, sample source/output paths). Attach screenshots only when the generated HTML changes layout or styling.
