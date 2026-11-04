import assert from "node:assert/strict";
import { test } from "node:test";
import { makeTopic, parseTopics } from "../src/content.ts";
import { parseMarkdown, splitFrontMatter } from "../src/markdown.ts";

test("front matter values are trimmed strings; colons in values are kept", () => {
    const { metadata, body } = splitFrontMatter("---\ntitle:  A: B \ndate: 2026-10-25\n---\nHello\n");
    assert.deepEqual(metadata, { title: "A: B", date: "2026-10-25" });
    assert.equal(body, "Hello\n");
});

test("text without front matter is all body", () => {
    assert.deepEqual(splitFrontMatter("# Hi\n"), { metadata: {}, body: "# Hi\n" });
});

test("youtube links ending in #embed become an embedded player", () => {
    const { html } = parseMarkdown("[Video](https://www.youtube.com/watch?v=abc_123#embed)");
    assert.match(html, /<iframe src="https:\/\/www\.youtube\.com\/embed\/abc_123"/);
    assert.doesNotMatch(html, /<a /);
});

test("other links are left alone", () => {
    const { html } = parseMarkdown("[Video](https://www.youtube.com/watch?v=abc)");
    assert.match(html, /<a href="https:\/\/www\.youtube\.com\/watch\?v=abc">Video<\/a>/);
});

test("standalone images are not wrapped in a paragraph", () => {
    assert.equal(parseMarkdown("![Alt](a.png)").html.trim(), '<img src="a.png" alt="Alt">');
    assert.match(parseMarkdown("Text ![Alt](a.png)").html, /^<p>Text <img/);
});

test("topics are slugged, capitalized and deduplicated", () => {
    assert.deepEqual(
        parseTopics("Gaming, VR, gaming, ,Retro_Games").map((t) => [t.slug, t.displayName]),
        [["gaming", "Gaming"], ["vr", "Vr"], ["retro-games", "Retro_Games"]],
    );
    // Matches Swift's String.capitalized, which the site used before
    assert.deepEqual(
        ["e-mail", "rock'n'roll", "3d printing", "dé jà"].map((name) => makeTopic(name)?.displayName),
        ["E-Mail", "Rock'n'roll", "3D Printing", "Dé Jà"],
    );
    assert.equal(makeTopic("gaming")?.colorClass, "topic-green");
});
