// End-to-end tests: build a site into a temp directory and inspect the output.

import assert from "node:assert/strict";
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { after, describe, test } from "node:test";
import { config } from "../src/config.ts";
import { StaticSite } from "../src/site.ts";
import { TemplateEngine } from "../src/template.ts";

const repoRoot = path.resolve(import.meta.dirname, "..");
const scratch = mkdtempSync(path.join(tmpdir(), "balenet-gen-test-"));
after(() => rmSync(scratch, { recursive: true, force: true }));

function build(sourceDir: string, name: string, includeDrafts = false) {
    const buildDir = path.join(scratch, name);
    new StaticSite({
        title: config.title,
        baseURL: config.siteURL,
        sourceDir,
        buildDir,
        templateDir: TemplateEngine.resolveDirectory(sourceDir),
        includeDrafts,
        log: () => {},
    }).build();
    return (file: string) => readFileSync(path.join(buildDir, file), "utf8");
}

describe("real site", () => {
    const read = build(path.join(repoRoot, "site"), "site");

    test("homepage lists posts grouped by year", () => {
        const home = read("index.html");
        assert.match(home, /Book notes: Smart & Gets Things Done/);
        assert.match(home, /href="\/topics\/gaming\/"/);
        assert.match(home, /class="post-year"/);
    });

    test("topic page lists its posts with colored labels", () => {
        const gaming = read("topics/gaming/index.html");
        assert.match(gaming, /It took me 236 hours but I finished Elden Ring!/);
        // Label carries a hash-derived color class (topic-<color>), so don't pin it
        assert.match(gaming, /class="topic-label topic-[a-z]+" href="\/topics\/gaming\/"/);
    });

    test("about page is rendered inside the layout", () => {
        assert.match(read("about/index.html"), /<main>/);
    });

    test("sitemap uses absolute URLs", () => {
        assert.match(read("sitemap.xml"), /<loc>https:\/\/www\.balenet\.com\/posts\/elden-ring\/<\/loc>/);
    });
});

describe("drafts", () => {
    // Copy the fixture and add a draft post with an asset
    const source = path.join(scratch, "draft-source");
    cpSync(path.join(repoRoot, "Fixtures/basic-site"), source, { recursive: true });
    const draftDir = path.join(source, "content/posts/wip");
    mkdirSync(draftDir);
    writeFileSync(
        path.join(draftDir, "index.md"),
        "---\ntitle: Work in progress\ndate: 2025-02-01\ntopics: secret\ndraft: true\n---\n\nNot yet.\n",
    );
    writeFileSync(path.join(draftDir, "photo.jpg"), "");

    test("are skipped by default, leaving nothing in the build", () => {
        const read = build(source, "drafts-off");
        assert.ok(!existsSync(path.join(scratch, "drafts-off/posts/wip")));
        assert.doesNotMatch(read("index.html"), /Work in progress/);
        assert.doesNotMatch(read("sitemap.xml"), /\/posts\/wip\//);
        assert.ok(!existsSync(path.join(scratch, "drafts-off/topics/secret")));
    });

    test("are included with a banner and badge when requested", () => {
        const read = build(source, "drafts-on", true);
        assert.match(read("posts/wip/index.html"), /class="draft-banner"/);
        assert.ok(existsSync(path.join(scratch, "drafts-on/posts/wip/photo.jpg")));
        assert.match(read("index.html"), /Work in progress[\s\S]*class="draft-badge"/);
        assert.doesNotMatch(read("posts/hello/index.html"), /draft-banner/);
    });
});
