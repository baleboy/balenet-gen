// Content model: posts, projects and topics.

export type ContentType = "post" | "project";

export const subFolder: Record<ContentType, string> = {
    post: "posts",
    project: "work",
};

export type Metadata = Record<string, string>;

/** A post has a `date`; a project has `order` and `image`. */
export function inferType(metadata: Metadata): ContentType {
    if (metadata.date !== undefined) return "post";
    if (metadata.order !== undefined && metadata.image !== undefined) return "project";
    throw new Error("Could not infer content item type");
}

export interface ContentItem {
    type: ContentType;
    title: string;
    html: string;
    /** Site-relative URL, e.g. `/posts/my-post/`. */
    path: string;
    topics: Topic[];
    isDraft: boolean;
    // post only
    date?: Date;
    // project only
    order?: number;
    headerImage?: string;
}

export interface Topic {
    name: string;
    slug: string;
    displayName: string;
    /** Stable CSS color class, so a topic gets the same color everywhere. */
    colorClass: string;
}

const topicColors = ["topic-blue", "topic-red", "topic-pink", "topic-green", "topic-teal", "topic-yellow"];

export function makeTopic(rawValue: string): Topic | undefined {
    const name = rawValue.trim();
    if (!name) return undefined;
    const slug = slugify(name);
    if (!slug) return undefined;

    let hash = 0;
    for (const char of slug) hash += char.codePointAt(0)!;

    return {
        name,
        slug,
        displayName: capitalize(name),
        colorClass: topicColors[hash % topicColors.length]!,
    };
}

/** Parses a comma-separated topic list, dropping duplicates (by slug). */
export function parseTopics(value: string | undefined): Topic[] {
    if (!value) return [];
    const seen = new Set<string>();
    const topics: Topic[] = [];
    for (const component of value.split(",")) {
        const topic = makeTopic(component);
        if (topic && !seen.has(topic.slug)) {
            seen.add(topic.slug);
            topics.push(topic);
        }
    }
    return topics;
}

function slugify(value: string): string {
    return value
        .toLowerCase()
        .replace(/[^\p{L}\p{M}\p{N} _-]/gu, "")
        .replace(/[_ ]/g, "-")
        .replace(/-{2,}/g, "-")
        .replace(/^-+|-+$/g, "");
}

/**
 * Uppercases the first letter of each word and lowercases the rest, like Swift's
 * `capitalized`: any non-letter except an apostrophe starts a new word ("3D Printing").
 */
function capitalize(value: string): string {
    return value
        .toLowerCase()
        .replace(/(^|[^\p{L}'])(\p{L})/gu, (_, sep: string, letter: string) => sep + letter.toUpperCase());
}

export function compareByName(a: Topic, b: Topic): number {
    return a.name.localeCompare(b.name, "en", { sensitivity: "base" });
}

/** Newest first; undated items sort last. */
export function sortByDateDescending(items: ContentItem[]): ContentItem[] {
    const time = (item: ContentItem) => item.date?.getTime() ?? Number.MIN_SAFE_INTEGER;
    return [...items].sort((a, b) => time(b) - time(a));
}
