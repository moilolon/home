# moilolon.com — Project Memory

Static home page at the root of the domain, served by Vercel from `main` with no build step. It
also serves `nav.js`, the site switcher every site under the domain loads.

`README.md` is the cover for visitors, laid out like every moilolon repo: *What this is*, *How
it works*, *Getting started* and the shared footer, with no folder tree, long code or roadmap.
The details below are for Claude.

## Structure

- `index.html` (the page, a `<a class="card">` per site; `half` and `tall` set how much of the
  grid it takes), `styles.css`, `main.js` (theme, language and every text, once per language,
  asked for with `data-i18n`), `nav.js`, `favicon.svg`.
- Theme and language are kept in the domain cookies `moilolon-theme` (`light`, `dark`) and
  `moilolon-lang` (`en`, `es`); every site reads them before its own saved settings and writes
  them on a change.
- `assets/draw-images.ps1` (`powershell -NoProfile -File assets/draw-images.ps1`) draws, from
  shapes, the README cover (`cover.png`), the icon (`icon.png`, also the project's icon in
  Orca) and the GitHub social preview (`social-preview.png`, uploaded by hand in Settings); redraw it when what it shows changes.
- **Adding a site:** its card in `index.html`, its texts in `main.js` and its entry in the
  `SITES` list of `nav.js`.
- `.github/workflows/links.yml` checks with lychee that the links of `index.html`, `nav.js` and
  the README still answer: on the 1st of each month and on a pull request that touches them. A
  link that cannot be checked (a request-only host) goes in its `--exclude` list. A 429 counts
  as an answer: Vercel's bot checkpoint gives it to the runners on the moilolon.com sites.

## `nav.js`

Defines `<moilolon-nav>`, loaded by every site from `https://moilolon.com/nav.js`:

```html
<script src="https://moilolon.com/nav.js" defer></script>
<moilolon-nav current="dashboard"><a href="/">Dashboards</a></moilolon-nav>
```

`current` is the site's id in `SITES`; the inner content shows if the file does not load. Text
colour is inherited and the panel follows the page's `color-scheme`; `--moilolon-nav-surface`,
`--moilolon-nav-text` and `--moilolon-nav-border` override them.

## Git

- **Commits:** English, imperative, sentence case, one line of at most 72 characters with no
  prefix and no trailing period (`Centre the content vertically`). A body only when the why is
  not obvious: a blank line, then lines wrapped at 72. No `Co-Authored-By` or other attribution.
- **Branches:** `<type>/<short-description>`, lowercase kebab-case, off `main`. Types: `feature`,
  `bugfix`, `docs`, `style`, `refactor`, `chore`.
- **Pull requests:** title like a commit; body with *What changes*, *Why* and *How to check it*.
  A change to `nav.js` reaches every site under the domain: say so in the body. Merged by
  squash, with the PR title and body as the commit.
- **`gh`:** always as `GH_TOKEN=$(gh auth token --user moilolon) gh …`, command by command. gh's
  active account is the work one, which must not act on this repo; do not switch it. `git`
  already uses `moilolon` through the `includeIf` of `C:/Developer/PERSONAL/`.
