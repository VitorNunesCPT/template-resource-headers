(function () {
  const desktopLogos = __HEADER_DESKTOP_LOGOS__;
  const mobileLogos = __HEADER_MOBILE_LOGOS__;
  const logoStyles = __LOGO_STYLES__;

  function isWelcomeRoute() {
    const pathname = window.location.pathname || '/';
    return pathname === '/' || pathname.endsWith('/');
  }

  function removeHeader() {
    const current = document.getElementById('ts-brand-header');
    if (current) {
      current.remove();
    }
    document.body.classList.remove('ts-branding-enabled');
  }

  function ensureHeader() {
    if (!document.body) {
      return;
    }

    if (!isWelcomeRoute()) {
      removeHeader();
      return;
    }

    const current = document.getElementById('ts-brand-header');
    if (current && current.dataset.logos === desktopLogos.join(',')) {
      return;
    }
    if (current) {
      current.remove();
    }

    const header = document.createElement('div');
    header.id = 'ts-brand-header';
    header.dataset.logos = desktopLogos.join(',');

    desktopLogos.forEach((filename) => {
      const slot = document.createElement('div');
      slot.className = 'ts-slot';
      if (!mobileLogos.includes(filename)) {
        slot.classList.add('is-hidden-mobile');
      }

      const image = document.createElement('img');
      const style = logoStyles[filename];
      image.src = `/branding/${filename}`;
      image.alt = filename;
      image.style.maxHeight = style.maxHeight;
      if (style.width) {
        image.style.width = style.width;
      }
      image.addEventListener('error', function onError() {
        slot.classList.add('fallback');
        slot.textContent = filename;
      }, { once: true });

      slot.appendChild(image);
      header.appendChild(slot);
    });

    document.body.appendChild(header);
    document.body.classList.add('ts-branding-enabled');
  }

  function boot() {
    ensureHeader();
    window.addEventListener('resize', ensureHeader);
    setInterval(ensureHeader, 1500);
  }

  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    boot();
  } else {
    window.addEventListener('DOMContentLoaded', boot, { once: true });
  }
})();
