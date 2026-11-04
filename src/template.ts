// HTML generation from the `{{placeholder}}` templates in <source>/templates.

import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { sortByDateDescending, type ContentItem, type Topic } from "./content.ts";

const templateNames = [
    "header",
    "footer",
    "homepage",
    "post_item",
    "projects",
    "project_card",
    "post",
    "project",
    "topic",
] as const;

type TemplateName = (typeof templateNames)[number];

const months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
];

/** Formats as "25 October 2026" (or "25 October"). Dates are UTC. */
export function formatDate(date: Date, includeYear = true): string {
    const dayMonth = `${date.getUTCDate()} ${months[date.getUTCMonth()]}`;
    return includeYear ? `${dayMonth} ${date.getUTCFullYear()}` : dayMonth;
}

/** Replaces `{{key}}` / `{{ key }}` in one pass; unknown placeholders are left alone. */
function fill(template: string, data: Record<string, string>): string {
    return template.replace(/\{\{ ?([a-z_]+) ?\}\}/g, (token, key: string) =>
        Object.hasOwn(data, key) ? data[key]! : token,
    );
}

export class TemplateEngine {
    private readonly title: string;
    private readonly templates: Record<TemplateName, string>;

    constructor(title: string, directory: string) {
        this.title = title;
        this.templates = Object.fromEntries(
            templateNames.map((name) => {
                const file = path.join(directory, `${name}.html`);
                if (!existsSync(file)) throw new Error(`Failed to load template ${name}.html`);
                return [name, readFileSync(file, "utf8")];
            }),
        ) as Record<TemplateName, string>;
    }

    /** `providedPath` is relative to the source directory; defaults to `<source>/templates`. */
    static resolveDirectory(sourceDir: string, providedPath?: string): string {
        const directory = path.resolve(sourceDir, providedPath ?? "templates");
        if (!existsSync(directory)) throw new Error(`Could not locate templates directory: ${directory}`);
        return directory;
    }

    renderPage(content: string, navigationTopics: Topic[]): string {
        const header = fill(this.templates.header, {
            title: this.title,
            topics_navigation: renderTopicsNavigation(navigationTopics),
        });
        const footer = fill(this.templates.footer, {
            title: this.title,
            year: String(new Date().getFullYear()),
        });
        return header + content + footer;
    }

    renderHomePage(posts: ContentItem[], navigationTopics: Topic[]): string {
        const sections = groupByYear(posts)
            .map(([year, yearPosts]) => {
                const items = yearPosts.map((post) => this.renderPostListItem(post, false)).join("");
                return `<section class="post-group">
    <h3 class="post-year">${year}</h3>
    <ul class="post-list">
    ${items}
    </ul>
</section>`;
            })
            .join("\n");

        const body = fill(this.templates.homepage, {
            post_groups: sections,
            topics_navigation: renderTopicsNavigation(navigationTopics),
        });
        return this.renderPage(body, navigationTopics);
    }

    renderProjectsPage(projects: ContentItem[], navigationTopics: Topic[]): string {
        const cards = projects
            .map((project) =>
                fill(this.templates.project_card, {
                    path: project.path,
                    image: project.headerImage ?? "",
                    title: project.title,
                    draft_badge: draftBadge(project),
                }),
            )
            .join("");
        return this.renderPage(fill(this.templates.projects, { projects: cards }), navigationTopics);
    }

    renderPost(post: ContentItem, navigationTopics: Topic[]): string {
        const body = fill(this.templates.post, {
            title: post.title,
            date: formatDate(post.date ?? new Date()),
            body: post.html,
            topics: renderTopicLabels(post.topics),
            draft_banner: draftBanner(post),
        });
        return this.renderPage(body, navigationTopics);
    }

    renderProject(project: ContentItem, navigationTopics: Topic[]): string {
        const body = fill(this.templates.project, {
            title: project.title,
            body: project.html,
            draft_banner: draftBanner(project),
        });
        return this.renderPage(body, navigationTopics);
    }

    renderTopicPage(topic: Topic, posts: ContentItem[], navigationTopics: Topic[]): string {
        const body = fill(this.templates.topic, {
            topic_name: topic.displayName,
            posts: posts.map((post) => this.renderPostListItem(post, true)).join(""),
            topics_navigation: renderTopicsNavigation(navigationTopics),
        });
        return this.renderPage(body, navigationTopics);
    }

    private renderPostListItem(post: ContentItem, includeYear: boolean): string {
        return fill(this.templates.post_item, {
            path: post.path,
            title: post.title,
            date: formatDate(post.date ?? new Date(), includeYear),
            topics: renderTopicLabels(post.topics),
            draft_badge: draftBadge(post),
        });
    }
}

function draftBanner(item: ContentItem): string {
    return item.isDraft ? `<div class="draft-banner">Draft &mdash; not published</div>` : "";
}

function draftBadge(item: ContentItem): string {
    return item.isDraft ? `<span class="draft-badge">Draft</span>` : "";
}

function renderTopicLabels(topics: Topic[]): string {
    if (topics.length === 0) return "";
    const labels = topics
        .map((t) => `<a class="topic-label ${t.colorClass}" href="/topics/${t.slug}/">${t.displayName}</a>`)
        .join(" ");
    return `<span class="topic-labels">${labels}</span>`;
}

function renderTopicsNavigation(topics: Topic[]): string {
    if (topics.length === 0) return "";
    const items = topics
        .map((t) => `<li class="nav-topic ${t.colorClass}"><a href="/topics/${t.slug}/">${t.displayName}</a></li>`)
        .join("");
    return `<ul class="topics-nav">${items}</ul>`;
}

/** Groups posts by year, newest year first, posts newest first within each year. */
function groupByYear(posts: ContentItem[]): [string, ContentItem[]][] {
    const buckets = new Map<string, ContentItem[]>();
    for (const post of posts) {
        const year = String((post.date ?? new Date()).getUTCFullYear());
        buckets.set(year, [...(buckets.get(year) ?? []), post]);
    }
    return [...buckets]
        .map(([year, yearPosts]): [string, ContentItem[]] => [year, sortByDateDescending(yearPosts)])
        .sort(([a], [b]) => b.localeCompare(a));
}
