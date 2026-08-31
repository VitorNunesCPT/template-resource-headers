:root {
  --ts-header-h: __HEADER_HEIGHT__;
}

#ts-brand-header {
  position: fixed;
  inset: 0 0 auto 0;
  height: var(--ts-header-h);
  background: __HEADER_BG__;
  z-index: 20;
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  align-items: center;
  justify-items: center;
  gap: __HEADER_DESKTOP_GAP__;
  padding: 4px __HEADER_DESKTOP_PADDING_X__;
  box-sizing: border-box;
  border-bottom: 1px solid #dedede;
}

#ts-brand-header .ts-slot {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 0;
  width: 100%;
}

#ts-brand-header .ts-slot img {
  width: auto;
  max-width: 100%;
  object-fit: contain;
  display: block;
}

#ts-brand-header .ts-slot.fallback {
  font: 700 12px/1.2 Arial, sans-serif;
  color: #1d1d1d;
  text-align: center;
  letter-spacing: 0.2px;
}

body.ts-branding-enabled #react {
  margin-top: var(--ts-header-h) !important;
  height: calc(100vh - var(--ts-header-h)) !important;
}

@media (max-width: __HEADER_MOBILE_BREAKPOINT__px) {
  #ts-brand-header {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: __HEADER_MOBILE_GAP__;
    padding: 4px __HEADER_MOBILE_PADDING_X__;
  }

  #ts-brand-header .ts-slot.is-hidden-mobile {
    display: none;
  }
}
