<div align="center">

# 🏠 moilolon.com

**My home page: one place that links to everything I make**

[![Open the site](https://img.shields.io/badge/Open%20the%20site-moilolon.com-8B7BFF?style=for-the-badge&logo=vercel&logoColor=white)](https://moilolon.com/)

[![No build](https://img.shields.io/badge/HTML%20%C2%B7%20CSS%20%C2%B7%20JS-no%20build-E34F26?style=for-the-badge&logo=html5&logoColor=white)](#-how-it-works)
[![Vercel](https://img.shields.io/badge/Hosted%20on-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://vercel.com/)

</div>

---

## ✨ What this is

A single static page at the root of the domain. It is only a way in: a card per site
that lives under it.

| | Site | What it is |
|---|---|---|
| 👨🏻‍💻 | [portfolio.moilolon.com](https://portfolio.moilolon.com) | Experience, projects and a contact form |
| 📊 | [dashboard.moilolon.com](https://dashboard.moilolon.com) | Dashboards of home data |

---

## 📁 Structure

```text
home/
├── 🏠 index.html     The page
├── 🎨 styles.css     Dark and light themes, the card grid, the backdrop
├── 🧩 main.js        Theme, language and the texts in English and Spanish
├── 🧭 nav.js         The site switcher every site under the domain loads
└── 🖼️ favicon.svg
```

---

## 🚀 How it works

- **No build and no dependencies.** What is on the `main` branch is the site; Vercel
  serves the files as they are. The only thing loaded from outside is the Geist font.
- **Visits and speed.** The page loads Vercel Web Analytics and Speed Insights, which
  are enabled per project in Vercel.
- **Dark and light.** It starts in the theme of the system and the button at the top
  switches it. The choice is saved in the browser.
- **English and Spanish.** It starts in the language of the browser. Every text lives
  in `main.js`, once per language, and the HTML asks for it with `data-i18n`.
- **Adding a site** is a new `<a class="card">` in `index.html`, its texts in
  `main.js` and its entry in the `SITES` list of `nav.js`. `half` and `tall` set how
  much of the grid it takes.
- **One switcher for every site.** `nav.js` defines the `<moilolon-nav>` element: the
  name of the current site, which opens the list of all of them. The other sites load
  it from here, so a change to the list reaches them with nothing to publish there:

  ```html
  <script src="https://moilolon.com/nav.js" defer></script>
  <moilolon-nav current="dashboard"><a href="/">Dashboards</a></moilolon-nav>
  ```

  `current` is the id of the site in `SITES`, and what is written inside shows if the
  file does not load. The text colour is inherited and the panel follows the page's
  `color-scheme`; `--moilolon-nav-surface`, `--moilolon-nav-text` and
  `--moilolon-nav-border` set them by hand.

To try it locally:

```bash
python -m http.server 8766
```

Then open `http://localhost:8766/`.
