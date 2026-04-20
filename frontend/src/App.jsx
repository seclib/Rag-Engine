import React, { useState } from 'react';
import Sidebar from './components/Sidebar';
import ChatArea from './components/ChatArea';
import InputBar from './components/InputBar';
import KnowledgeTab from './components/KnowledgeTab';
import SkillsTab from './components/SkillsTab';
import SettingsTab from './components/SettingsTab';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('chat');
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: 'Hello! I\'m your local AI assistant. I can help you with coding, analysis, and have access to your knowledge base. What would you like to work on today?'
    }
  ]);
  const [isStreaming, setIsStreaming] = useState(false);

  const sendMessage = async (message) => {
    const userMessage = { role: 'user', content: message };
    setMessages(prev => [...prev, userMessage]);

    setIsStreaming(true);
    try {
      // Call backend via IPC
      const response = await window.electronAPI.sendMessage(message);
      setIsStreaming(false);

      const assistantMessage = { role: 'assistant', content: response.response };
      setMessages(prev => [...prev, assistantMessage]);
    } catch (error) {
      setIsStreaming(false);
      const errorMessage = {
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.'
      };
      setMessages(prev => [...prev, errorMessage]);
    }
  };

  return (
    <div className="app">
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />
      <div className="main">
        {activeTab === 'chat' && (
          <>
            <ChatArea messages={messages} isStreaming={isStreaming} />
            <InputBar onSend={sendMessage} disabled={isStreaming} />
          </>
        )}
        {activeTab === 'knowledge' && <KnowledgeTab />}
        {activeTab === 'skills' && <SkillsTab />}
        {activeTab === 'settings' && <SettingsTab />}
      </div>
    </div>
  );
}

export default App;