import React, { useState } from 'react';

function SettingsTab() {
  const [settings, setSettings] = useState({
    model: 'llama-2-7b',
    theme: 'light',
    dataRetention: true,
    autoSave: true,
    maxTokens: 2048,
    temperature: 0.7
  });

  const models = [
    { value: 'llama-2-7b', label: 'Llama 2 7B (Fast)' },
    { value: 'llama-2-13b', label: 'Llama 2 13B (Balanced)' },
    { value: 'llama-2-70b', label: 'Llama 2 70B (High Quality)' },
    { value: 'codellama-7b', label: 'CodeLlama 7B (Code Focused)' }
  ];

  const themes = [
    { value: 'light', label: 'Light' },
    { value: 'dark', label: 'Dark' },
    { value: 'auto', label: 'Auto (System)' }
  ];

  const updateSetting = (key, value) => {
    setSettings(prev => ({ ...prev, [key]: value }));
  };

  return (
    <div className="tab-content">
      <div className="tab-header">
        <h1 className="tab-title">Settings</h1>
        <p className="tab-subtitle">Customize your AI assistant experience</p>
      </div>

      <div style={{ maxWidth: '600px', margin: '0 auto' }}>
        {/* AI Model Section */}
        <section style={{ marginBottom: 'var(--space-8)' }}>
          <h2 style={{
            fontSize: 'var(--text-xl)',
            fontWeight: 'var(--font-semibold)',
            color: 'var(--color-text-primary)',
            marginBottom: 'var(--space-4)'
          }}>
            AI Model
          </h2>

          <div className="form-group">
            <label className="form-label">Model</label>
            <select
              className="form-input form-select"
              value={settings.model}
              onChange={(e) => updateSetting('model', e.target.value)}
            >
              {models.map(model => (
                <option key={model.value} value={model.value}>{model.label}</option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">Max Tokens: {settings.maxTokens}</label>
            <input
              type="range"
              min="512"
              max="4096"
              step="512"
              value={settings.maxTokens}
              onChange={(e) => updateSetting('maxTokens', parseInt(e.target.value))}
              style={{ width: '100%', marginTop: 'var(--space-2)' }}
            />
          </div>

          <div className="form-group">
            <label className="form-label">Temperature: {settings.temperature}</label>
            <input
              type="range"
              min="0"
              max="1"
              step="0.1"
              value={settings.temperature}
              onChange={(e) => updateSetting('temperature', parseFloat(e.target.value))}
              style={{ width: '100%', marginTop: 'var(--space-2)' }}
            />
          </div>
        </section>

        {/* Appearance Section */}
        <section style={{ marginBottom: 'var(--space-8)' }}>
          <h2 style={{
            fontSize: 'var(--text-xl)',
            fontWeight: 'var(--font-semibold)',
            color: 'var(--color-text-primary)',
            marginBottom: 'var(--space-4)'
          }}>
            Appearance
          </h2>

          <div className="form-group">
            <label className="form-label">Theme</label>
            <select
              className="form-input form-select"
              value={settings.theme}
              onChange={(e) => updateSetting('theme', e.target.value)}
            >
              {themes.map(theme => (
                <option key={theme.value} value={theme.value}>{theme.label}</option>
              ))}
            </select>
          </div>
        </section>

        {/* Privacy Section */}
        <section style={{ marginBottom: 'var(--space-8)' }}>
          <h2 style={{
            fontSize: 'var(--text-xl)',
            fontWeight: 'var(--font-semibold)',
            color: 'var(--color-text-primary)',
            marginBottom: 'var(--space-4)'
          }}>
            Privacy & Data
          </h2>

          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)', marginBottom: 'var(--space-4)' }}>
            <div
              className={`skill-toggle ${settings.dataRetention ? 'active' : ''}`}
              onClick={() => updateSetting('dataRetention', !settings.dataRetention)}
              style={{ margin: 0 }}
            ></div>
            <div>
              <div style={{ fontWeight: 'var(--font-medium)', color: 'var(--color-text-primary)' }}>
                Data Retention
              </div>
              <div style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)' }}>
                Keep conversation history for better context
              </div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
            <div
              className={`skill-toggle ${settings.autoSave ? 'active' : ''}`}
              onClick={() => updateSetting('autoSave', !settings.autoSave)}
              style={{ margin: 0 }}
            ></div>
            <div>
              <div style={{ fontWeight: 'var(--font-medium)', color: 'var(--color-text-primary)' }}>
                Auto-save Conversations
              </div>
              <div style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)' }}>
                Automatically save chat history
              </div>
            </div>
          </div>
        </section>

        {/* About Section */}
        <section>
          <h2 style={{
            fontSize: 'var(--text-xl)',
            fontWeight: 'var(--font-semibold)',
            color: 'var(--color-text-primary)',
            marginBottom: 'var(--space-4)'
          }}>
            About
          </h2>

          <div style={{
            backgroundColor: 'var(--color-bg-tertiary)',
            padding: 'var(--space-4)',
            borderRadius: 'var(--radius-md)',
            textAlign: 'center'
          }}>
            <div style={{ fontSize: 'var(--text-lg)', fontWeight: 'var(--font-semibold)', marginBottom: 'var(--space-1)' }}>
              Seclib AI Desktop
            </div>
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)', marginBottom: 'var(--space-3)' }}>
              Version 1.0.0
            </div>
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)' }}>
              Local AI assistant with RAG and skills system
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}

export default SettingsTab;