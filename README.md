# Eventora site

Static legal pages for Eventora, served by GitHub Pages: `/privacy/` and `/terms/`.

Regenerate from the app repo (`docs/legal`):

    GRIEVANCE_EMAIL=you@example.com ./build.sh ../HALL

Needs deno. Commit the generated HTML and push to `main`. No JS, trackers or external assets.
