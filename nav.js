// The site switcher shared by every site under moilolon.com. Each site loads this file
// from https://moilolon.com/nav.js and places the element where its name would go:
//
//   <moilolon-nav current="dashboard"><a href="/">Dashboards</a></moilolon-nav>
//
// `current` is the id of the site showing it. What is written inside the element is
// what shows if this file does not load. A new site is a new entry in SITES: every
// site gets it on its next visit, with nothing to publish in them.
//
// The colours come from the page: the text is inherited and the panel follows the
// color-scheme. A page can set them with --moilolon-nav-surface, --moilolon-nav-text
// and --moilolon-nav-border.

(() => {
  const SITES = [
    { id: 'home', title: 'moilolon', url: 'https://moilolon.com/' },
    { id: 'portfolio', title: 'Portfolio', url: 'https://portfolio.moilolon.com/' },
    { id: 'dashboard', title: 'Dashboards', url: 'https://dashboard.moilolon.com/' },
  ];
  const LABEL = { en: 'Switch site', es: 'Cambiar de sitio' };

  const STYLES = `
    :host { position: relative; display: inline-block; font: inherit; color: inherit; }
    button {
      all: unset; box-sizing: border-box; display: inline-flex; align-items: center; gap: 0.35em;
      font: inherit; color: inherit; cursor: pointer; white-space: nowrap;
      padding: 0.2em 0.45em; margin: 0 -0.45em; border-radius: 8px;
    }
    button:hover, button[aria-expanded="true"] { background: color-mix(in srgb, currentColor 10%, transparent); }
    button:focus-visible, a:focus-visible { outline: 2px solid currentColor; outline-offset: 2px; }
    button svg { width: 0.9em; height: 0.9em; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; opacity: 0.6; transition: transform 0.15s; }
    button[aria-expanded="true"] svg { transform: rotate(180deg); }
    .panel {
      position: absolute; top: calc(100% + 8px); left: -0.45em; z-index: 1000; min-width: 220px;
      display: grid; gap: 2px; padding: 6px; border-radius: 12px;
      background: var(--moilolon-nav-surface, Canvas); color: var(--moilolon-nav-text, CanvasText);
      border: 1px solid var(--moilolon-nav-border, color-mix(in srgb, CanvasText 16%, transparent));
      box-shadow: 0 12px 32px rgb(0 0 0 / 0.18);
      font: 500 14px/1.3 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; letter-spacing: 0; text-align: left;
    }
    .panel[hidden] { display: none; }
    a { display: grid; grid-template-columns: 1fr auto; align-items: center; gap: 1px 12px; padding: 8px 10px; border-radius: 8px; color: inherit; text-decoration: none; }
    a:hover { background: color-mix(in srgb, currentColor 9%, transparent); }
    .host { grid-column: 1; font: 400 12px ui-monospace, "Cascadia Code", Consolas, monospace; opacity: 0.6; }
    .here { grid-column: 2; grid-row: 1 / span 2; width: 7px; height: 7px; border-radius: 50%; background: currentColor; opacity: 0.7; }
  `;

  class MoilolonNav extends HTMLElement {
    connectedCallback() {
      if (this.shadowRoot) return;
      const current = SITES.find((site) => site.id === this.getAttribute('current')) || SITES[0];
      const root = this.attachShadow({ mode: 'open' });
      root.innerHTML = `<style>${STYLES}</style>
        <button type="button" aria-haspopup="true" aria-expanded="false">
          <span>${current.title}</span>
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <nav class="panel" hidden>${SITES.map((site) => `
          <a href="${site.url}"${site === current ? ' aria-current="page"' : ''}>
            <span>${site.title}</span>
            <span class="host">${new URL(site.url).host}</span>
            ${site === current ? '<span class="here"></span>' : ''}
          </a>`).join('')}
        </nav>`;

      const button = root.querySelector('button');
      const panel = root.querySelector('.panel');
      const label = () => LABEL[(document.documentElement.lang || 'en').slice(0, 2)] || LABEL.en;
      const open = (show) => {
        panel.hidden = !show;
        button.setAttribute('aria-expanded', String(show));
      };
      button.setAttribute('aria-label', `${current.title}. ${label()}`);
      button.addEventListener('click', () => {
        // The page may have changed language since the element was drawn.
        button.setAttribute('aria-label', `${current.title}. ${label()}`);
        panel.setAttribute('aria-label', label());
        open(panel.hidden);
      });
      document.addEventListener('click', (event) => { if (!event.composedPath().includes(this)) open(false); });
      this.addEventListener('keydown', (event) => {
        if (event.key !== 'Escape' || panel.hidden) return;
        open(false);
        button.focus();
      });
    }
  }

  if (!customElements.get('moilolon-nav')) customElements.define('moilolon-nav', MoilolonNav);
})();
