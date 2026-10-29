#!/usr/bin/env bash
# Regenerates index.html, privacy/index.html, terms/index.html from the app repo's docs/legal.
# Usage: ./build.sh [path-to-app-repo]   (default: ../HALL). Needs deno.
# Optional env: GRIEVANCE_EMAIL (replaces [GRIEVANCE EMAIL]); EFFECTIVE_DATE (default below).
set -euo pipefail
cd "$(dirname "$0")"
SRC="${1:-../HALL}/docs/legal"
export SRC GRIEVANCE_EMAIL="${GRIEVANCE_EMAIL:-}" EFFECTIVE_DATE="${EFFECTIVE_DATE:-22 October 2026}"
mkdir -p privacy terms
"${DENO:-$HOME/.deno/bin/deno}" run --allow-read --allow-write --allow-env --allow-net=registry.npmjs.org,npm.jsr.io - <<'TS'
import { marked } from "npm:marked@12.0.2";
const env = Deno.env.get.bind(Deno.env);
const email = env("GRIEVANCE_EMAIL")!;
const date = env("EFFECTIVE_DATE")!;
const page = (title: string, css: string, body: string) =>
  `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<link rel="stylesheet" href="${css}style.css">
</head>
<body>
<main>
${body}
</main>
</body>
</html>
`;
const nav = (p: string) =>
  `<nav><a class="brand" href="${p}"><img src="${p}logo-mark.png" alt="" width="30" height="32">Eventora</a><a href="${p}privacy/">Privacy Policy</a><a href="${p}terms/">Terms of Use</a></nav>`;
const doc = async (file: string, title: string, out: string) => {
  let md = await Deno.readTextFile(`${env("SRC")}/${file}`);
  md = md.replace(/^\s*<!--[\s\S]*?-->\s*/, "").replaceAll("[EFFECTIVE DATE]", date);
  if (email) md = md.replaceAll("[GRIEVANCE EMAIL]", email);
  await Deno.writeTextFile(out, page(`${title} | Eventora`, "../",
    `${nav("../")}\n<article class="card">\n${marked.parse(md)}</article>`));
};
await doc("privacy-policy.md", "Privacy Policy", "privacy/index.html");
await doc("terms-of-use.md", "Terms of Use", "terms/index.html");
const contact = email
  ? `Questions or complaints: <a href="mailto:${email}">${email}</a>.`
  : `Contact details are in the <a href="privacy/">Privacy Policy</a>.`;
await Deno.writeTextFile("index.html", page("Eventora", "",
  `${nav("")}
<div class="card">
<h1>Eventora</h1>
<p>Eventora is a hall booking app for the Udupi area. It helps you find community and event halls, check availability and book a date. Read our <a href="privacy/">Privacy Policy</a> and <a href="terms/">Terms of Use</a>. ${contact}</p>
</div>`));
TS
