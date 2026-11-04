// Markdown parsing: front matter + markdown-it with site-specific plugins.

import markdownIt, { type MarkdownIt, type StateCore } from "markdown-it";
import type { Metadata } from "./content.ts";

export interface ParsedMarkdown {
    metadata: Metadata;
    html: string;
}

const md = markdownIt({ html: true }).use(youtubeEmbed).use(unwrapImages);

export function parseMarkdown(source: string): ParsedMarkdown {
    const { metadata, body } = splitFrontMatter(source);
    return { metadata, html: md.render(body) };
}

/**
 * Parses a front matter block of simple `key: value` lines between `---` fences.
 * Values are plain strings (no YAML typing). A line without a colon continues
 * the previous value.
 */
export function splitFrontMatter(source: string): { metadata: Metadata; body: string } {
    const text = source.replace(/^﻿/, "").replace(/\r\n/g, "\n");
    const match = /^---\n([\s\S]*?)\n?^---[ \t]*(?:\n|$)/m.exec(text);
    if (!match || match.index !== 0) return { metadata: {}, body: text };

    const metadata: Metadata = {};
    let lastKey: string | undefined;
    for (const line of match[1]!.split("\n")) {
        const trimmed = line.trim();
        if (!trimmed) continue;
        const colon = trimmed.indexOf(":");
        if (colon === -1) {
            if (lastKey !== undefined) metadata[lastKey] += " " + trimmed;
            continue;
        }
        const key = trimmed.slice(0, colon).trim();
        const value = trimmed.slice(colon + 1).trim();
        if (value) {
            metadata[key] = value;
            lastKey = key;
        }
    }
    return { metadata, body: text.slice(match[0].length) };
}

const youtubeId = /(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)/;

/**
 * Turns YouTube links ending in `#embed` into an embedded player:
 * `[Video](https://youtube.com/watch?v=ID#embed)`
 */
function youtubeEmbed(md: MarkdownIt): void {
    md.core.ruler.push("youtube_embed", (state: StateCore) => {
        for (const block of state.tokens) {
            const children = block.children;
            if (block.type !== "inline" || !children) continue;

            for (let i = 0; i < children.length; i++) {
                const open = children[i]!;
                const href = String(open.attrGet("href") ?? "");
                if (open.type !== "link_open" || !href.includes("#embed")) continue;

                const id = youtubeId.exec(href)?.[1];
                if (!id) continue;

                let close = i + 1;
                while (close < children.length && children[close]!.type !== "link_close") close++;

                const embed = new state.Token("html_inline", "", 0);
                embed.content = [
                    `<div class="video-container">`,
                    `    <iframe src="https://www.youtube.com/embed/${id}" `,
                    `            frameborder="0" `,
                    `            allowfullscreen>`,
                    `    </iframe>`,
                    `</div>`,
                ].join("\n");
                children.splice(i, close - i + 1, embed);
            }
        }
    });
}

/**
 * Renders paragraphs that contain only images without the `<p>` wrapper, so
 * images get their own block spacing (see `.post-body img` in style.css).
 */
function unwrapImages(md: MarkdownIt): void {
    md.core.ruler.push("unwrap_images", (state: StateCore) => {
        const tokens = state.tokens;
        for (let i = 1; i < tokens.length - 1; i++) {
            const inline = tokens[i]!;
            const open = tokens[i - 1]!;
            const close = tokens[i + 1]!;
            if (inline.type !== "inline" || open.type !== "paragraph_open" || close.type !== "paragraph_close") continue;

            const children = inline.children ?? [];
            const onlyImages =
                children.some((c) => c.type === "image") &&
                children.every(
                    (c) => c.type === "image" || c.type === "softbreak" || (c.type === "text" && !c.content.trim()),
                );
            if (onlyImages) {
                open.hidden = true;
                close.hidden = true;
            }
        }
    });
}
