// Orchestrates site generation: content -> HTML pages, assets, sitemap.

import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import path from "node:path";
import {
    compareByName,
    inferType,
    parseTopics,
    sortByDateDescending,
    subFolder,
    type ContentItem,
    type ContentType,
    type Topic,
} from "./content.ts";
import { parseMarkdown } from "./markdown.ts";
import { TemplateEngine } from "./template.ts";

export interface SiteOptions {
    title: string;
    baseURL: string;
    sourceDir: string;
    buildDir: string;
    templateDir: string;
    includeDrafts?: boolean;
    /** Defaults to console.log; pass `() => {}` to silence. */
    log?: (message: string) => void;
}

interface RenderTarget {
    item: ContentItem;
    outputDir: string;
}

type TopicIndex = Map<string, { topic: Topic; posts: ContentItem[] }>;

export class StaticSite {
    private readonly options: Required<SiteOptions>;
    private readonly template: TemplateEngine;
    private readonly contentDir: string;

    constructor(options: SiteOptions) {
        this.options = { includeDrafts: false, log: console.log, ...options };
        this.template = new TemplateEngine(options.title, options.templateDir);
        this.contentDir = path.join(options.sourceDir, "content");
    }

    build(): void {
        const { buildDir, sourceDir } = this.options;
        rmSync(buildDir, { recursive: true, force: true });
        cpSync(path.join(sourceDir, "static"), buildDir, { recursive: true });

        const postTargets = this.generateItems("post");
        const posts = sortByDateDescending(postTargets.map((t) => t.item));
        const topicIndex = buildTopicIndex(posts);
        const navigationTopics = sortedTopics(topicIndex, compareByName);

        const projectTargets = this.generateItems("project");
        const projects = projectTargets.map((t) => t.item).sort((a, b) => (b.order ?? 0) - (a.order ?? 0));

        this.render([...postTargets, ...projectTargets], navigationTopics);
        this.write("index.html", this.template.renderHomePage(posts, navigationTopics));
        this.generateTopicPages(topicIndex, navigationTopics);
        this.write("work/index.html", this.template.renderProjectsPage(projects, navigationTopics));
        this.generateAboutPage(navigationTopics);
        this.write("sitemap.xml", this.sitemap(posts, projects, topicIndex));
    }

    /**
     * Each subfolder of content/posts or content/work is one item: its markdown is
     * parsed and every other entry (images, subfolders) is copied alongside the page.
     */
    private generateItems(type: ContentType): RenderTarget[] {
        const targets: RenderTarget[] = [];
        const typeDir = path.join(this.contentDir, subFolder[type]);

        for (const folder of visibleEntries(typeDir).filter((e) => e.isDirectory())) {
            const folderDir = path.join(typeDir, folder.name);
            const entries = visibleEntries(folderDir);

            // Parse first, so drafts can be skipped before anything is written
            const items = entries
                .filter((e) => e.isFile() && e.name.endsWith(".md"))
                .map((e) => this.parseItem(folder.name, path.join(folderDir, e.name)));

            if (items.some((item) => item.isDraft)) {
                if (!this.options.includeDrafts) {
                    this.options.log(`Skipping draft: ${subFolder[type]}/${folder.name}`);
                    continue;
                }
                this.options.log(`Including draft: ${subFolder[type]}/${folder.name}`);
            }

            const outputDir = path.join(this.options.buildDir, subFolder[type], folder.name);
            mkdirSync(outputDir, { recursive: true });
            targets.push(...items.map((item) => ({ item, outputDir })));

            for (const entry of entries.filter((e) => !e.name.endsWith(".md"))) {
                cpSync(path.join(folderDir, entry.name), path.join(outputDir, entry.name), { recursive: true });
            }
        }
        return targets;
    }

    parseItem(folder: string, markdownFile: string): ContentItem {
        const { metadata, html } = parseMarkdown(readFileSync(markdownFile, "utf8"));
        const type = inferType(metadata);
        const common = {
            type,
            title: metadata.title ?? "Untitled",
            html,
            path: `/${subFolder[type]}/${folder}/`,
            isDraft: isTruthy(metadata.draft),
        };

        if (type === "post") {
            return { ...common, date: parseDate(metadata.date) ?? new Date(), topics: parseTopics(metadata.topics) };
        }
        return {
            ...common,
            topics: [],
            order: Number.parseInt(metadata.order ?? "", 10) || 0,
            headerImage: `${folder}/${metadata.image ?? ""}`,
        };
    }

    private render(targets: RenderTarget[], navigationTopics: Topic[]): void {
        for (const { item, outputDir } of targets) {
            const html =
                item.type === "post"
                    ? this.template.renderPost(item, navigationTopics)
                    : this.template.renderProject(item, navigationTopics);
            writeFileSync(path.join(outputDir, "index.html"), html);
        }
    }

    private generateTopicPages(topicIndex: TopicIndex, navigationTopics: Topic[]): void {
        for (const topic of navigationTopics) {
            const posts = topicIndex.get(topic.slug)!.posts;
            this.write(`topics/${topic.slug}/index.html`, this.template.renderTopicPage(topic, posts, navigationTopics));
        }
    }

    private generateAboutPage(navigationTopics: Topic[]): void {
        const { html } = parseMarkdown(readFileSync(path.join(this.contentDir, "about.md"), "utf8"));
        const page = this.template.renderPage(`<div class="post-body">${html}</div>`, navigationTopics);
        this.write("about/index.html", page);
    }

    private sitemap(posts: ContentItem[], projects: ContentItem[], topicIndex: TopicIndex): string {
        const entries: { path: string; lastModified?: Date }[] = [
            { path: "/", lastModified: posts[0]?.date },
            { path: "/about/" },
            { path: "/work/" },
            ...posts.map((p) => ({ path: p.path, lastModified: p.date })),
            ...projects.map((p) => ({ path: p.path })),
            ...sortedTopics(topicIndex, (a, b) => a.slug.localeCompare(b.slug)).map((topic) => ({
                path: `/topics/${topic.slug}/`,
                lastModified: topicIndex.get(topic.slug)!.posts[0]?.date,
            })),
        ];

        const urls = entries
            .map(({ path: entryPath, lastModified }) => {
                const location = new URL(entryPath, this.options.baseURL).href;
                const lastmod = lastModified ? `        <lastmod>${isoDate(lastModified)}</lastmod>\n` : "";
                return `    <url>\n        <loc>${location}</loc>\n${lastmod}    </url>`;
            })
            .join("\n");

        return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;
    }

    /** Writes a file relative to the build directory, creating parent folders. */
    private write(relativePath: string, contents: string): void {
        const file = path.join(this.options.buildDir, relativePath);
        mkdirSync(path.dirname(file), { recursive: true });
        writeFileSync(file, contents);
    }
}

function visibleEntries(directory: string) {
    if (!existsSync(directory)) return [];
    return readdirSync(directory, { withFileTypes: true })
        .filter((e) => !e.name.startsWith("."))
        .sort((a, b) => a.name.localeCompare(b.name));
}

/** Posts per topic (keyed by slug), newest first. Expects `posts` already sorted. */
function buildTopicIndex(posts: ContentItem[]): TopicIndex {
    const index: TopicIndex = new Map();
    for (const post of posts) {
        for (const topic of post.topics) {
            const entry = index.get(topic.slug) ?? { topic, posts: [] };
            entry.posts.push(post);
            index.set(topic.slug, entry);
        }
    }
    return index;
}

function sortedTopics(index: TopicIndex, compare: (a: Topic, b: Topic) => number): Topic[] {
    return [...index.values()].map((e) => e.topic).sort(compare);
}

/** Parses `YYYY-MM-DD` as a UTC date. */
function parseDate(value: string | undefined): Date | undefined {
    const match = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(value ?? "");
    if (!match) return undefined;
    return new Date(Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3])));
}

function isoDate(date: Date): string {
    return date.toISOString().slice(0, 10);
}

function isTruthy(value: string | undefined): boolean {
    return ["true", "yes", "1"].includes(value?.trim().toLowerCase() ?? "");
}
