// Development server: builds the site (drafts included), serves it, rebuilds on
// changes and reloads open browser tabs.
//
//   npm run dev [-- --port 8000] [-- --no-drafts] [-- --no-open]

import { spawn } from "node:child_process";
import { createReadStream, existsSync, statSync, watch } from "node:fs";
import { readFile } from "node:fs/promises";
import { createServer, type ServerResponse } from "node:http";
import path from "node:path";
import { parseArgs } from "node:util";

const { values } = parseArgs({
    options: {
        port: { type: "string", default: "8000" },
        "no-drafts": { type: "boolean", default: false },
        "no-open": { type: "boolean", default: false },
    },
});

const repoRoot = path.resolve(import.meta.dirname, "..");
const siteDir = path.join(repoRoot, "site");
const buildDir = path.join(siteDir, "build");
const watchedDirs = ["content", "static", "templates"].map((d) => path.join(siteDir, d)).concat(import.meta.dirname);
const port = Number(values.port);
const reloadPath = "/__livereload";

// Injected into served HTML only; never written to disk
const reloadScript = `<script>new EventSource("${reloadPath}").onmessage = () => location.reload();</script>`;

const mimeTypes: Record<string, string> = {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".xml": "application/xml; charset=utf-8",
    ".txt": "text/plain; charset=utf-8",
    ".svg": "image/svg+xml",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".gif": "image/gif",
    ".webp": "image/webp",
    ".ico": "image/x-icon",
    ".woff": "font/woff",
    ".woff2": "font/woff2",
    ".ttf": "font/ttf",
};

// --- Building --------------------------------------------------------------

let building = false;
let rebuildQueued = false;

/** Runs the generator in a fresh process, so changes to src/ are picked up too. */
function build(): Promise<boolean> {
    const args = [path.join(import.meta.dirname, "cli.ts"), "--source", siteDir, "--output", "build"];
    if (!values["no-drafts"]) args.push("--drafts");

    return new Promise((resolve) => {
        const started = Date.now();
        const child = spawn(process.execPath, args, { stdio: ["ignore", "ignore", "inherit"] });
        child.on("exit", (code) => {
            if (code === 0) console.log(`Built in ${Date.now() - started}ms`);
            else console.error("Build failed; serving the previous build");
            resolve(code === 0);
        });
    });
}

async function rebuild(): Promise<void> {
    if (building) {
        rebuildQueued = true;
        return;
    }
    building = true;
    const ok = await build();
    building = false;
    if (ok) notifyClients();
    if (rebuildQueued) {
        rebuildQueued = false;
        await rebuild();
    }
}

let debounce: NodeJS.Timeout | undefined;
for (const dir of watchedDirs) {
    watch(dir, { recursive: true }, (_event, filename) => {
        if (filename && path.basename(filename).startsWith(".")) return;
        clearTimeout(debounce);
        debounce = setTimeout(() => {
            console.log(`Changed: ${path.relative(repoRoot, path.join(dir, filename ?? ""))}`);
            void rebuild();
        }, 100);
    });
}

// --- Serving ---------------------------------------------------------------

const clients = new Set<ServerResponse>();

function notifyClients(): void {
    for (const client of clients) client.write("data: reload\n\n");
}

/** Maps a URL path to a file in the build directory, refusing to escape it. */
function resolveFile(urlPath: string): string | undefined {
    const file = path.join(buildDir, decodeURIComponent(urlPath));
    if (file !== buildDir && !file.startsWith(buildDir + path.sep)) return undefined;
    if (existsSync(file) && statSync(file).isDirectory()) return path.join(file, "index.html");
    return file;
}

const server = createServer(async (req, res) => {
    const urlPath = new URL(req.url ?? "/", "http://localhost").pathname;

    if (urlPath === reloadPath) {
        res.writeHead(200, { "Content-Type": "text/event-stream", "Cache-Control": "no-cache", Connection: "keep-alive" });
        res.write(": connected\n\n");
        clients.add(res);
        req.on("close", () => clients.delete(res));
        return;
    }

    // Directory URLs without a trailing slash would break relative image paths
    const file = resolveFile(urlPath);
    if (file?.endsWith("index.html") && !urlPath.endsWith("/") && !urlPath.endsWith(".html")) {
        res.writeHead(301, { Location: `${urlPath}/` }).end();
        return;
    }
    if (!file || !existsSync(file)) {
        res.writeHead(404, { "Content-Type": "text/plain" }).end(`Not found: ${urlPath}`);
        return;
    }

    const type = mimeTypes[path.extname(file).toLowerCase()] ?? "application/octet-stream";
    res.setHeader("Cache-Control", "no-store");
    if (type.startsWith("text/html")) {
        const html = await readFile(file, "utf8");
        const withReload = html.includes("</body>") ? html.replace("</body>", `${reloadScript}</body>`) : html + reloadScript;
        res.writeHead(200, { "Content-Type": type }).end(withReload);
    } else {
        res.writeHead(200, { "Content-Type": type });
        createReadStream(file).pipe(res);
    }
});

// --- Start -----------------------------------------------------------------

await build();
server.listen(port, () => {
    const url = `http://localhost:${port}/`;
    console.log(`Serving ${path.relative(repoRoot, buildDir)} at ${url}${values["no-drafts"] ? "" : " (drafts included)"}`);
    console.log("Watching for changes. Press Ctrl+C to stop.");
    if (!values["no-open"]) {
        const opener = process.platform === "darwin" ? "open" : "xdg-open";
        spawn(opener, [url], { stdio: "ignore", detached: true }).on("error", () => {}).unref();
    }
});
