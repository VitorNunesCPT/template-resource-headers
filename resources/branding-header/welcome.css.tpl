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
  padding: 40px clamp(20px, 4vw, 56px) 56px;
  box-sizing: border-box;
  color: __WELCOME_TEXT_COLOR__;
  font-family: "Segoe UI", Arial, sans-serif;
}

#ts-welcome-page .ts-welcome-shell {
  width: min(100%, 1460px);
  margin: 0 auto;
}

#ts-welcome-page .ts-welcome-hero {
  text-align: center;
  margin-bottom: 28px;
}

#ts-welcome-page .ts-welcome-title {
  margin: 0;
  font-size: clamp(42px, 5vw, 64px);
  line-height: 1.05;
  font-weight: 800;
  letter-spacing: -0.03em;
}

#ts-welcome-page .ts-welcome-subtitle {
  margin: 20px auto 0;
  max-width: 1200px;
  font-size: clamp(22px, 2.2vw, 28px);
  line-height: 1.45;
  color: __WELCOME_MUTED_COLOR__;
}

#ts-welcome-page .ts-welcome-panel,
#ts-welcome-page .ts-welcome-card,
#ts-welcome-page .ts-welcome-steps {
  background: #ffffff;
  border-radius: 24px;
  box-shadow: 0 12px 30px rgba(31, 41, 55, 0.12);
}

#ts-welcome-page .ts-welcome-panel {
  padding: 28px 32px 32px;
}

#ts-welcome-page .ts-welcome-prompt {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
}

#ts-welcome-page .ts-welcome-icon {
  color: __WELCOME_PRIMARY_COLOR__;
  flex: 0 0 auto;
}

#ts-welcome-page .ts-welcome-icon svg {
  width: 48px;
  height: 48px;
  display: block;
  stroke: currentColor;
}

#ts-welcome-page .ts-welcome-prompt-text {
  margin: 0;
  font-size: clamp(24px, 2vw, 32px);
  line-height: 1.35;
  color: __WELCOME_MUTED_COLOR__;
}

#ts-welcome-page .ts-welcome-form {
  display: grid;
  gap: 24px;
}

#ts-welcome-page .ts-welcome-input {
  width: 100%;
  min-height: 92px;
  border-radius: 22px;
  border: 1px solid #cfd7e5;
  background: #ffffff;
  padding: 0 24px;
  box-sizing: border-box;
  font-size: clamp(24px, 2vw, 30px);
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
  min-height: 90px;
  border: 0;
  border-radius: 999px;
  background: __WELCOME_PRIMARY_COLOR__;
  color: #ffffff;
  font-size: clamp(24px, 2vw, 32px);
  font-weight: 600;
  cursor: pointer;
  transition: transform 140ms ease, box-shadow 140ms ease, opacity 140ms ease;
  box-shadow: 0 18px 30px rgba(63, 99, 209, 0.26);
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
  gap: 28px;
}

#ts-welcome-page .ts-welcome-features {
  grid-template-columns: repeat(3, minmax(0, 1fr));
  margin-top: 28px;
}

#ts-welcome-page .ts-welcome-card {
  padding: 28px 26px;
}

#ts-welcome-page .ts-welcome-card-head {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 18px;
}

#ts-welcome-page .ts-welcome-card-icon {
  color: __WELCOME_PRIMARY_COLOR__;
  flex: 0 0 auto;
}

#ts-welcome-page .ts-welcome-card-icon svg {
  width: 54px;
  height: 54px;
  display: block;
  stroke: currentColor;
}

#ts-welcome-page .ts-welcome-card-title {
  margin: 0;
  font-size: clamp(22px, 1.8vw, 30px);
  line-height: 1.2;
  color: __WELCOME_PRIMARY_COLOR__;
}

#ts-welcome-page .ts-welcome-card-body,
#ts-welcome-page .ts-welcome-step-body {
  margin: 0;
  font-size: clamp(18px, 1.5vw, 24px);
  line-height: 1.45;
  color: __WELCOME_MUTED_COLOR__;
}

#ts-welcome-page .ts-welcome-steps {
  margin-top: 32px;
  padding: 38px 26px 30px;
}

#ts-welcome-page .ts-welcome-steps-title {
  margin: 0 0 28px;
  text-align: center;
  font-size: clamp(34px, 3vw, 48px);
  line-height: 1.1;
  font-weight: 800;
}

#ts-welcome-page .ts-welcome-step-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

#ts-welcome-page .ts-welcome-step {
  padding: 12px 18px 0;
  text-align: center;
}

#ts-welcome-page .ts-welcome-step-number {
  margin: 0 0 18px;
  font-size: clamp(36px, 3vw, 48px);
  line-height: 1;
  font-weight: 700;
  color: __WELCOME_PRIMARY_COLOR__;
}

#ts-welcome-page .ts-welcome-step-title {
  margin: 0 0 16px;
  font-size: clamp(24px, 2vw, 34px);
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
    padding: 24px;
  }
}

@media (max-width: __HEADER_MOBILE_BREAKPOINT__px) {
  #ts-welcome-page {
    padding: 24px 14px 40px;
  }

  #ts-welcome-page .ts-welcome-hero {
    margin-bottom: 22px;
  }

  #ts-welcome-page .ts-welcome-title {
    font-size: 34px;
  }

  #ts-welcome-page .ts-welcome-subtitle {
    margin-top: 14px;
    font-size: 19px;
  }

  #ts-welcome-page .ts-welcome-panel {
    border-radius: 20px;
    padding: 20px 16px 22px;
  }

  #ts-welcome-page .ts-welcome-prompt {
    gap: 14px;
    margin-bottom: 18px;
    align-items: flex-start;
  }

  #ts-welcome-page .ts-welcome-icon svg {
    width: 36px;
    height: 36px;
  }

  #ts-welcome-page .ts-welcome-prompt-text {
    font-size: 18px;
  }

  #ts-welcome-page .ts-welcome-form {
    gap: 18px;
  }

  #ts-welcome-page .ts-welcome-input,
  #ts-welcome-page .ts-welcome-button {
    min-height: 64px;
    font-size: 20px;
  }

  #ts-welcome-page .ts-welcome-input {
    border-radius: 18px;
    padding: 0 18px;
  }

  #ts-welcome-page .ts-welcome-card,
  #ts-welcome-page .ts-welcome-steps {
    border-radius: 20px;
  }

  #ts-welcome-page .ts-welcome-card {
    padding: 22px 18px;
  }

  #ts-welcome-page .ts-welcome-card-head {
    align-items: flex-start;
    margin-bottom: 14px;
  }

  #ts-welcome-page .ts-welcome-card-icon svg {
    width: 40px;
    height: 40px;
  }

  #ts-welcome-page .ts-welcome-card-title {
    font-size: 20px;
  }

  #ts-welcome-page .ts-welcome-card-body,
  #ts-welcome-page .ts-welcome-step-body {
    font-size: 17px;
  }

  #ts-welcome-page .ts-welcome-steps {
    margin-top: 24px;
    padding: 28px 18px 20px;
  }

  #ts-welcome-page .ts-welcome-steps-title {
    font-size: 28px;
    margin-bottom: 22px;
  }

  #ts-welcome-page .ts-welcome-step {
    padding: 0;
  }

  #ts-welcome-page .ts-welcome-step-number {
    font-size: 34px;
    margin-bottom: 14px;
  }

  #ts-welcome-page .ts-welcome-step-title {
    font-size: 22px;
    margin-bottom: 12px;
  }
}
