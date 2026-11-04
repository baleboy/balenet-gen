#!/usr/bin/env node
// balenet-gen: generate the Balenet (www.balenet.com) website from markdown sources.

import path from "node:path";
import { parseArgs } from "node:util";
import { config } from "./config.ts";
import { StaticSite } from "./site.ts";
import { TemplateEngine } from "./template.ts";

const usage = `USAGE: balenet-gen [--source <source>] [--output <output>] [--templates <dir>] [--drafts]

OPTIONS:
  -s, --source <source>     Source directory containing content (default: current directory)
  -o, --output <output>     Output directory, relative to source (default: build)
  -t, --templates <dir>     Template directory, relative to source (default: <source>/templates)
      --drafts              Include items marked 'draft: true' in their front matter
  -h, --help                Show help information.`;

function main(): void {
    const { values } = parseArgs({
        options: {
            source: { type: "string", short: "s" },
            output: { type: "string", short: "o", default: "build" },
            templates: { type: "string", short: "t" },
            drafts: { type: "boolean", default: false },
            help: { type: "boolean", short: "h", default: false },
        },
    });

    if (values.help) {
        console.log(usage);
        return;
    }

    const sourceDir = path.resolve(values.source ?? process.cwd());
    const buildDir = path.resolve(sourceDir, values.output);

    console.log(`Generating site from ${sourceDir} to ${buildDir}`);

    new StaticSite({
        title: config.title,
        baseURL: config.siteURL,
        sourceDir,
        buildDir,
        templateDir: TemplateEngine.resolveDirectory(sourceDir, values.templates),
        includeDrafts: values.drafts,
    }).build();
}

try {
    main();
} catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : error}`);
    process.exitCode = 1;
}
