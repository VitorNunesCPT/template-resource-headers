body.ts-welcome-page-active {
  background: linear-gradient(180deg, __WELCOME_BACKGROUND_START__ 0%, __WELCOME_BACKGROUND_END__ 100%);
}

body.ts-branding-enabled.ts-welcome-page-active #react {
  margin-top: var(--ts-header-h) !important;
  height: auto !important;
  min-height: calc(100vh - var(--ts-header-h));
}

#ts-welcome-page {
  min-height: calc(100vh - var(--ts-header-h));
  padding: 8px 20px 36px;
  box-sizing: border-box;
  color: __WELCOME_TEXT_COLOR__;
  font-family: "Segoe UI", Arial, sans-serif;
}

#ts-welcome-page .ts-welcome-shell {
  width: min(100%, 1234px);
  margin: 0 auto;
}

#ts-welcome-page .ts-welcome-hero {
  text-align: center;
  margin-bottom: 20px;
}

#ts-welcome-page .ts-welcome-title {
  margin: 0;
  font-size: 30px;
  line-height: 1.2;
  font-weight: 700;
  letter-spacing: 0;
}

#ts-welcome-page .ts-welcome-subtitle {
  margin: 4px auto 0;
  max-width: 920px;
  font-size: 16px;
  line-height: 1.45;
  color: __WELCOME_MUTED_COLOR__;
}

#ts-welcome-page .ts-welcome-panel,
#ts-welcome-page .ts-welcome-card,
#ts-welcome-page .ts-welcome-steps {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(31, 41, 55, 0.12);
}

#ts-welcome-page .ts-welcome-panel {
  padding: 16px;
}

#ts-welcome-page .ts-welcome-prompt {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

#ts-welcome-page .ts-welcome-icon {
  color: __WELCOME_PRIMARY_COLOR__;
  flex: 0 0 auto;
}

#ts-welcome-page .ts-welcome-icon svg {
  width: 28px;
  height: 28px;
  display: block;
  stroke: currentColor;
}

#ts-welcome-page .ts-welcome-prompt-text {
  margin: 0;
  font-size: 16px;
  line-height: 1.35;
  color: __WELCOME_MUTED_COLOR__;
}

#ts-welcome-page .ts-welcome-form {
  display: grid;
  gap: 12px;
}

#ts-welcome-page .ts-welcome-input {
  width: 100%;
  min-height: 46px;
  border-radius: 8px;
  border: 1px solid #cfd7e5;
  background: #ffffff;
  padding: 0 10px;
  box-sizing: border-box;
  font-size: 16px;
  color: __WELCOME_TEXT_COLOR__;
  outline: none;
}

#ts-welcome-page .ts-welcome-input::placeholder {
  color: #98a2b3;
}

#ts-welcome-page .ts-welcome-input:focus {
  border-color: __WELCOME_PRIMARY_COLOR__;
  box-shadow: 0 0 0 4px rgba(63, 99, 209, 0.14);
}

#ts-welcome-page .ts-welcome-button {
  width: 100%;
  min-height: 44px;
  border: 0;
  border-radius: 999px;
  background: __WELCOME_PRIMARY_COLOR__;
  color: #ffffff;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 140ms ease, box-shadow 140ms ease, opacity 140ms ease;
  box-shadow: 0 8px 18px rgba(63, 99, 209, 0.24);
}

#ts-welcome-page .ts-welcome-button:hover {
  transform: translateY(-1px);
}

#ts-welcome-page .ts-welcome-button:active {
  transform: translateY(0);
}

#ts-welcome-page .ts-welcome-button:disabled {
  cursor: not-allowed;
  opacity: 0.7;
}

#ts-welcome-page .ts-welcome-error {
  min-height: 24px;
  margin-top: -8px;
  font-size: 15px;
  color: #b42318;
}

#ts-welcome-page .ts-welcome-features,
#ts-welcome-page .ts-welcome-step-grid {
  display: grid;
  gap: 16px;
}

#ts-welcome-page .ts-welcome-features {
  grid-template-columns: repeat(3, minmax(0, 1fr));
  margin-top: 24px;
}

#ts-welcome-page .ts-welcome-card {
  padding: 16px 14px;
}

#ts-welcome-page .ts-welcome-card-head {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

#ts-welcome-page .ts-welcome-card-icon {
  color: __WELCOME_PRIMARY_COLOR__;
  flex: 0 0 auto;
}

#ts-welcome-page .ts-welcome-card-icon svg {
  width: 24px;
  height: 24px;
  display: block;
  stroke: currentColor;
}

#ts-welcome-page .ts-welcome-card-title {
  margin: 0;
  font-size: 16px;
  line-height: 1.2;
  font-weight: 600;
  color: __WELCOME_PRIMARY_COLOR__;
}

#ts-welcome-page .ts-welcome-card-body,
#ts-welcome-page .ts-welcome-step-body {
  margin: 0;
  font-size: 14px;
  line-height: 1.45;
  color: __WELCOME_MUTED_COLOR__;
}

#ts-welcome-page .ts-welcome-steps {
  margin-top: 16px;
  padding: 18px 26px 16px;
}

#ts-welcome-page .ts-welcome-steps-title {
  margin: 0 0 28px;
  text-align: center;
  font-size: 18px;
  line-height: 1.1;
  font-weight: 700;
}

#ts-welcome-page .ts-welcome-step-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

#ts-welcome-page .ts-welcome-step {
  padding: 8px 18px 0;
  text-align: center;
}

#ts-welcome-page .ts-welcome-step-number {
  margin: 0 0 8px;
  font-size: 18px;
  line-height: 1;
  font-weight: 700;
  color: __WELCOME_PRIMARY_COLOR__;
}

#ts-welcome-page .ts-welcome-step-title {
  margin: 0 0 8px;
  font-size: 14px;
  line-height: 1.2;
  font-weight: 700;
}

#ts-welcome-page .ts-welcome-step-title strong {
  color: __WELCOME_PRIMARY_COLOR__;
  font-weight: 700;
}

@media (max-width: 1200px) {
  #ts-welcome-page .ts-welcome-features,
  #ts-welcome-page .ts-welcome-step-grid {
    grid-template-columns: 1fr;
  }

  #ts-welcome-page .ts-welcome-panel {
    padding: 16px;
  }
}

@media (max-width: __HEADER_MOBILE_BREAKPOINT__px) {
  #ts-welcome-page {
    padding: 16px 16px 32px;
  }

  #ts-welcome-page .ts-welcome-hero {
    margin-bottom: 24px;
  }

  #ts-welcome-page .ts-welcome-title {
    font-size: 30px;
  }

  #ts-welcome-page .ts-welcome-subtitle {
    margin-top: 4px;
    font-size: 16px;
  }

  #ts-welcome-page .ts-welcome-panel {
    border-radius: 12px;
    padding: 16px;
  }

  #ts-welcome-page .ts-welcome-prompt {
    gap: 12px;
    margin-bottom: 16px;
    align-items: flex-start;
  }

  #ts-welcome-page .ts-welcome-icon svg {
    width: 28px;
    height: 28px;
  }

  #ts-welcome-page .ts-welcome-prompt-text {
    font-size: 16px;
  }

  #ts-welcome-page .ts-welcome-form {
    gap: 12px;
  }

  #ts-welcome-page .ts-welcome-input,
  #ts-welcome-page .ts-welcome-button {
    min-height: 46px;
    font-size: 16px;
  }

  #ts-welcome-page .ts-welcome-input {
    border-radius: 8px;
    padding: 0 10px;
  }

  #ts-welcome-page .ts-welcome-card,
  #ts-welcome-page .ts-welcome-steps {
    border-radius: 12px;
  }

  #ts-welcome-page .ts-welcome-card {
    padding: 16px 14px;
  }

  #ts-welcome-page .ts-welcome-card-head {
    align-items: flex-start;
    margin-bottom: 12px;
  }

  #ts-welcome-page .ts-welcome-card-icon svg {
    width: 24px;
    height: 24px;
  }

  #ts-welcome-page .ts-welcome-card-title {
    font-size: 18px;
  }

  #ts-welcome-page .ts-welcome-card-body,
  #ts-welcome-page .ts-welcome-step-body {
    font-size: 14px;
  }

  #ts-welcome-page .ts-welcome-steps {
    margin-top: 16px;
    padding: 18px 18px 16px;
  }

  #ts-welcome-page .ts-welcome-steps-title {
    font-size: 18px;
    margin-bottom: 18px;
  }

  #ts-welcome-page .ts-welcome-step {
    padding: 0;
  }

  #ts-welcome-page .ts-welcome-step-number {
    font-size: 18px;
    margin-bottom: 8px;
  }

  #ts-welcome-page .ts-welcome-step-title {
    font-size: 14px;
    margin-bottom: 8px;
  }
}
