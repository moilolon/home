// Theme, language and the light that follows the pointer over the cards.
// Loaded in <head> so theme and language are set before the first paint; start() runs
// at the end of <body>, when the page is there.

const STRINGS = {
  en: {
    language: 'Language',
    theme: 'Switch between light and dark',
    sites: 'Sites',
    'portfolio.title': 'Portfolio',
    'portfolio.text': 'Who I am and what I do for work.',
    'dashboards.title': 'Dashboards',
    'dashboards.text': 'Data from home, drawn.',
  },
  es: {
    language: 'Idioma',
    theme: 'Cambiar entre claro y oscuro',
    sites: 'Sitios',
    'portfolio.title': 'Portfolio',
    'portfolio.text': 'Quién soy y a qué me dedico.',
    'dashboards.title': 'Dashboards',
    'dashboards.text': 'Datos de casa, dibujados.',
  },
};

// Theme and language are shared with the other sites under moilolon.com through two
// cookies of the whole domain, moilolon-theme (light, dark) and moilolon-lang (en, es).
// The cookie wins over what this browser saved for this site alone; away from the
// domain (trying it locally) only the browser storage is used.
const SHARED = /(^|\.)moilolon\.com$/.test(location.hostname);

function cookie(key) {
  const found = document.cookie.match(new RegExp(`(?:^|; )moilolon-${key}=([^;]*)`));
  return found ? found[1] : null;
}

function stored(key) {
  try { return cookie(key) || localStorage.getItem(key); } catch (error) { return null; }
}

function store(key, value) {
  if (SHARED) document.cookie = `moilolon-${key}=${value}; domain=.moilolon.com; path=/; max-age=31536000; samesite=lax; secure`;
  try { localStorage.setItem(key, value); } catch (error) { /* no storage: it holds for this visit only */ }
}

const systemDark = () => matchMedia('(prefers-color-scheme: dark)').matches;

let lang = STRINGS[stored('lang')] ? stored('lang') : ((navigator.language || 'en').toLowerCase().startsWith('es') ? 'es' : 'en');
let theme = ['light', 'dark'].includes(stored('theme')) ? stored('theme') : (systemDark() ? 'dark' : 'light');

document.documentElement.lang = lang;
document.documentElement.dataset.theme = theme;

function applyTexts() {
  document.documentElement.lang = lang;
  document.querySelectorAll('[data-i18n]').forEach((el) => { el.textContent = STRINGS[lang][el.dataset.i18n]; });
  document.querySelectorAll('[data-i18n-label]').forEach((el) => { el.setAttribute('aria-label', STRINGS[lang][el.dataset.i18nLabel]); });
  document.querySelectorAll('#lang button').forEach((b) => b.classList.toggle('current', b.dataset.lang === lang));
}

function start() {
  applyTexts();
  document.getElementById('year').textContent = new Date().getFullYear();

  document.getElementById('lang').addEventListener('click', (event) => {
    const button = event.target.closest('button[data-lang]');
    if (!button) return;
    lang = button.dataset.lang;
    store('lang', lang);
    applyTexts();
  });

  document.getElementById('theme').addEventListener('click', () => {
    theme = theme === 'dark' ? 'light' : 'dark';
    store('theme', theme);
    document.documentElement.dataset.theme = theme;
  });

  // Each card lights up under the pointer: the position goes to CSS as --x and --y.
  document.querySelectorAll('.card').forEach((card) => {
    card.addEventListener('pointermove', (event) => {
      const frame = card.getBoundingClientRect();
      card.style.setProperty('--x', `${event.clientX - frame.left}px`);
      card.style.setProperty('--y', `${event.clientY - frame.top}px`);
    });
  });
}
