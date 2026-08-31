(function () {
  const logos = [
    {
      cls: 'l1',
      src: '/branding/logo-telessaude.png',
      alt: 'Telessaude Maranhao UFMA',
      fallback: 'Telessaude Maranhao UFMA'
    },
    {
      cls: 'l2',
      src: '/branding/logo-sted.png',
      alt: 'STED',
      fallback: 'STED'
    },
    {
      cls: 'l3',
      src: '/branding/logo-rute.png',
      alt: 'Telessaude Brasil Redes',
      fallback: 'Telessaude Brasil Redes'
    },
    {
      cls: 'l4',
      src: '/branding/logo-brasil.png',
      alt: 'Governo Federal Brasil',
      fallback: 'Governo Federal Brasil'
    }
  ];

  function ensureHeader() {
    if (document.getElementById('ts-brand-header') || !document.body) {
      return;
    }

    const header = document.createElement('div');
    header.id = 'ts-brand-header';

    logos.forEach((logo) => {
      const slot = document.createElement('div');
      slot.className = `ts-slot ${logo.cls}`;

      const img = document.createElement('img');
      img.src = logo.src;
      img.alt = logo.alt;

      img.addEventListener('error', function onError() {
        slot.classList.add('fallback');
        slot.textContent = logo.fallback;
      }, { once: true });

      slot.appendChild(img);
      header.appendChild(slot);
    });

    document.body.appendChild(header);
    document.body.classList.add('ts-branding-enabled');
  }

  function boot() {
    ensureHeader();
    setInterval(ensureHeader, 1500);
  }

  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    boot();
  } else {
    window.addEventListener('DOMContentLoaded', boot, { once: true });
  }
})();
