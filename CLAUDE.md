# moilolon.com — Project Memory

Static home page at the root of the domain, served by Vercel from `main` with no build step. It
also serves `nav.js`, the site switcher every site under the domain loads. What each file does is
in `README.md`.

## Git

- **Commits:** English, imperative, sentence case, one line of at most 72 characters with no
  prefix and no trailing period (`Centre the content vertically`). A body only when the why is
  not obvious: a blank line, then lines wrapped at 72. No `Co-Authored-By` or other attribution.
- **Branches:** `<type>/<short-description>`, lowercase kebab-case, off `main`. Types: `feature`,
  `bugfix`, `docs`, `style`, `refactor`, `chore`.
- **Pull requests:** title like a commit; body with *What changes*, *Why* and *How to check it*.
  A change to `nav.js` reaches every site under the domain: say so in the body. Merged by
  squash, with the PR title and body as the commit.
