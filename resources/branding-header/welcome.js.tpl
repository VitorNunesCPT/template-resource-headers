(function () {
  const config = __WELCOME_CONFIG__;
  const promptIcon = '<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18 21c4.9706 0 9-4.0294 9-9s-4.0294-9-9-9-9 4.0294-9 9 4.0294 9 9 9Z" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/><path d="M35 23c3.866 0 7-3.134 7-7s-3.134-7-7-7" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 42c0-7.1797 6.268-13 14-13h2c7.732 0 14 5.8203 14 13" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/><path d="M29 29c5.523 0 10 4.4772 10 10" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  const featureIcons = {
    video: '<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M6 10h28c2.2091 0 4 1.7909 4 4v17c0 2.2091-1.7909 4-4 4H6c-2.20914 0-4-1.7909-4-4V14c0-2.2091 1.79086-4 4-4Z" stroke="currentColor" stroke-width="3" stroke-linejoin="round"/><path d="M20 19.5 28 24l-8 4.5v-9Z" stroke="currentColor" stroke-width="3" stroke-linejoin="round"/><path d="M10 42h24" stroke="currentColor" stroke-width="3" stroke-linecap="round"/></svg>',
    clock: '<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M24 44c11.0457 0 20-8.9543 20-20S35.0457 4 24 4 4 12.9543 4 24s8.9543 20 20 20Z" stroke="currentColor" stroke-width="3"/><path d="M24 12v13h9" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/></svg>',
    lock: '<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 22h24c2.2091 0 4 1.7909 4 4v14c0 2.2091-1.7909 4-4 4H12c-2.20914 0-4-1.7909-4-4V26c0-2.2091 1.79086-4 4-4Z" stroke="currentColor" stroke-width="3"/><path d="M16 22v-6c0-4.4183 3.5817-8 8-8s8 3.5817 8 8v6" stroke="currentColor" stroke-width="3" stroke-linecap="round"/></svg>'
  };

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function highlightSofia(title) {
    return escapeHtml(title).replace(/SOFIA/g, '<strong>SOFIA</strong>');
  }

  function isWelcomeRoute() {
    const pathname = window.location.pathname || '/';
    return pathname === '/' || pathname.endsWith('/');
  }

  function sanitizeRoomName(value) {
    return value.trim().replace(/^\/+|\/+$/g, '').replace(/\s+/g, '-');
  }

  function buildRoomUrl(roomName) {
    const url = new URL(window.location.href);
    const basePath = url.pathname.endsWith('/') ? url.pathname : `${url.pathname}/`;
    url.pathname = `${basePath}${encodeURIComponent(roomName)}`;
    url.search = '';
    url.hash = '';
    return url.toString();
  }

  function renderFeatures() {
    return config.features.map((item) => `
      <article class="ts-welcome-card">
        <div class="ts-welcome-card-head">
          <div class="ts-welcome-card-icon" aria-hidden="true">${featureIcons[item.icon] || ''}</div>
          <h2 class="ts-welcome-card-title">${escapeHtml(item.title)}</h2>
        </div>
        <p class="ts-welcome-card-body">${escapeHtml(item.body)}</p>
      </article>
    `).join('');
  }

  function renderSteps() {
    return config.steps.items.map((item) => `
      <article class="ts-welcome-step">
        <p class="ts-welcome-step-number">${escapeHtml(item.number)}</p>
        <h3 class="ts-welcome-step-title">${highlightSofia(item.title)}</h3>
        <p class="ts-welcome-step-body">${escapeHtml(item.body)}</p>
      </article>
    `).join('');
  }

  function createWelcomePage() {
    const root = document.createElement('div');
    root.id = 'ts-welcome-page';
    root.innerHTML = `
      <div class="ts-welcome-shell">
        <section class="ts-welcome-hero">
          <h1 class="ts-welcome-title">${escapeHtml(config.title)}</h1>
          <p class="ts-welcome-subtitle">${escapeHtml(config.subtitle)}</p>
        </section>
        <section class="ts-welcome-panel">
          <div class="ts-welcome-prompt">
            <div class="ts-welcome-icon" aria-hidden="true">${promptIcon}</div>
            <p class="ts-welcome-prompt-text">${escapeHtml(config.prompt)}</p>
          </div>
          <div class="ts-welcome-form">
            <input id="ts-welcome-room-input" class="ts-welcome-input" type="text" inputmode="text" autocomplete="off" placeholder="${escapeHtml(config.placeholder)}" />
            <button id="ts-welcome-room-button" class="ts-welcome-button" type="button">${escapeHtml(config.buttonLabel)}</button>
            <p id="ts-welcome-room-error" class="ts-welcome-error" aria-live="polite"></p>
          </div>
        </section>
        <section class="ts-welcome-features">${renderFeatures()}</section>
        <section class="ts-welcome-steps">
          <h2 class="ts-welcome-steps-title">${escapeHtml(config.steps.title)}</h2>
          <div class="ts-welcome-step-grid">${renderSteps()}</div>
        </section>
      </div>
    `;
    return root;
  }

  function mountWelcomePage() {
    const reactRoot = document.getElementById('react');
    if (!reactRoot || !isWelcomeRoute()) {
      document.body.classList.remove('ts-welcome-page-active');
      return;
    }

    const current = document.getElementById('ts-welcome-page');
    if (current && current.parentElement === reactRoot) {
      document.body.classList.add('ts-welcome-page-active');
      return;
    }

    const root = createWelcomePage();
    reactRoot.replaceChildren(root);
    document.body.classList.add('ts-welcome-page-active');

    const input = root.querySelector('#ts-welcome-room-input');
    const button = root.querySelector('#ts-welcome-room-button');
    const error = root.querySelector('#ts-welcome-room-error');

    const submit = function submit() {
      const roomName = sanitizeRoomName(input.value);
      if (!roomName) {
        error.textContent = 'Informe o código da sala para continuar.';
        input.focus();
        return;
      }

      error.textContent = '';
      button.disabled = true;
      window.location.assign(buildRoomUrl(roomName));
    };

    button.addEventListener('click', submit);
    input.addEventListener('keydown', function onKeyDown(event) {
      if (event.key === 'Enter') {
        event.preventDefault();
        submit();
      }
    });
  }

  function boot() {
    mountWelcomePage();
    window.addEventListener('resize', mountWelcomePage);
    setInterval(mountWelcomePage, 1500);
  }

  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    boot();
  } else {
    window.addEventListener('DOMContentLoaded', boot, { once: true });
  }
})();
