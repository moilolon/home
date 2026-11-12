// Theme, language and the light that follows the pointer over the cards.
// Loaded in <head> so theme and language are set before the first paint; start() runs
// at the end of <body>, when the page is there.

const STRINGS = {
  en: {
    language: 'Language',
    theme: 'Switch between light and dark',
    location: 'A Coruña, Spain',
    hello: "Hi, I'm Moisés.",
    tagline: 'I build online stores.',
    lead: 'Salesforce Commerce Cloud developer with more than ten years in web development. This is where everything I make starts.',
    'portfolio.title': 'Portfolio',
    'portfolio.text': 'Experience, projects and the technologies I work with. And a form to get in touch.',
    'dashboards.title': 'Dashboards',
    'dashboards.text': 'Data from home, drawn. It starts with how grocery prices change.',
    'github.text': 'The code of all this, and a few tools.',
    'linkedin.text': 'Where I work and where I have worked.',
    'contact.title': 'Contact',
    'contact.text': 'Write to me from the form on the portfolio.',
    opensource: 'Open source',
    'zedxml.text': 'XML syntax highlighting for the Zed editor.',
    'dotfiles.text': 'A two-line, powerline-style prompt for Git Bash on Windows.',
    footer: 'Plain HTML, CSS and JS. No build.',
  },
  es: {
    language: 'Idioma',
    theme: 'Cambiar entre claro y oscuro',
    location: 'A Coruña, España',
    hello: 'Hola, soy Moisés.',
    tagline: 'Construyo tiendas online.',
    lead: 'Desarrollador de Salesforce Commerce Cloud con más de diez años en desarrollo web. Aquí empieza todo lo que hago.',
    'portfolio.title': 'Portfolio',
    'portfolio.text': 'Experiencia, proyectos y las tecnologías con las que trabajo. Y un formulario para escribirme.',
    'dashboards.title': 'Dashboards',
    'dashboards.text': 'Datos de casa, dibujados. Empieza por cómo cambian los precios de la compra.',
    'github.text': 'El código de todo esto, y alguna herramienta.',
    'linkedin.text': 'Dónde trabajo y dónde he trabajado.',
    'contact.title': 'Contacto',
    'contact.text': 'Escríbeme desde el formulario del portfolio.',
    opensource: 'Código abierto',
    'zedxml.text': 'Resaltado de sintaxis XML para el editor Zed.',
    'dotfiles.text': 'Un prompt de dos líneas, estilo powerline, para Git Bash en Windows.',
    footer: 'HTML, CSS y JS a mano. Sin compilación.',
  },
};

function stored(key) {
  try { return localStorage.getItem(key); } catch (error) { return null; }
}

function store(key, value) {
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
