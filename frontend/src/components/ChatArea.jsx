import React, { useEffect, useRef } from 'react';

function ChatArea({ messages, isStreaming }) {
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, isStreaming]);

  const renderMessageContent = (content) => {
    // Simple code block detection and rendering
    const parts = content.split(/(```[\s\S]*?```)/g);

    return parts.map((part, index) => {
      if (part.startsWith('```') && part.endsWith('```')) {
        const code = part.slice(3, -3);
        const lines = code.split('\n');
        const language = lines[0].trim();
        const codeContent = lines.slice(1).join('\n');

        return (
          <div key={index} className="code-block">
            <div className="code-block-header">
              <span className="code-language">{language || 'text'}</span>
              <button className="code-copy-btn" onClick={() => navigator.clipboard.writeText(codeContent)}>
                📋
              </button>
            </div>
            <pre><code>{codeContent}</code></pre>
          </div>
        );
      }
      return <span key={index}>{part}</span>;
    });
  };

  return (
    <div className="chat-container">
      <div className="chat-messages">
        {messages.map((msg, index) => (
          <div key={index} className={`message ${msg.role}`}>
            <div className="message-bubble">
              {renderMessageContent(msg.content)}
            </div>
          </div>
        ))}

        {isStreaming && (
          <div className="message assistant">
            <div className="message-bubble">
              <div className="streaming-indicator">
                <span>AI is thinking</span>
                <div className="typing-dots">
                  <div className="typing-dot"></div>
                  <div className="typing-dot"></div>
                  <div className="typing-dot"></div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
      <div ref={messagesEndRef} />
    </div>
  );
}

export default ChatArea;