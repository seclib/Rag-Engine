import React, { useState, useRef, useEffect } from 'react';

function InputBar({ onSend, disabled }) {
  const [input, setInput] = useState('');
  const textareaRef = useRef(null);

  const adjustTextareaHeight = () => {
    const textarea = textareaRef.current;
    if (textarea) {
      textarea.style.height = 'auto';
      textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';
    }
  };

  useEffect(() => {
    adjustTextareaHeight();
  }, [input]);

  const handleSend = () => {
    if (input.trim() && !disabled) {
      onSend(input);
      setInput('');
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const handleAttach = () => {
    // TODO: Implement file attachment
    console.log('Attach file clicked');
  };

  return (
    <div className="input-container">
      <div className="input-wrapper">
        <div className="input-form">
          <textarea
            ref={textareaRef}
            className="input-field"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Ask me anything..."
            disabled={disabled}
            rows={1}
          />
          <div className="input-actions">
            <button
              className="attach-btn"
              onClick={handleAttach}
              disabled={disabled}
              title="Attach file"
            >
              📎
            </button>
            <button
              className="send-btn"
              onClick={handleSend}
              disabled={disabled || !input.trim()}
              title="Send message"
            >
              →
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default InputBar;