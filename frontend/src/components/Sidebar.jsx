import React from 'react';

function Sidebar({ activeTab, setActiveTab }) {
  const navItems = [
    { id: 'chat', label: 'Chats', icon: '💬' },
    { id: 'knowledge', label: 'Knowledge', icon: '📚' },
    { id: 'skills', label: 'Skills', icon: '⚡' },
    { id: 'settings', label: 'Settings', icon: '⚙️' }
  ];

  const handleNewChat = () => {
    // Reset messages and create new chat
    setActiveTab('chat');
    // TODO: Implement new chat logic
  };

  return (
    <div className="sidebar">
      <div className="sidebar-header">
        <h1 className="sidebar-title">Seclib AI</h1>
        <p className="sidebar-subtitle">Local AI Assistant</p>
      </div>

      <nav className="sidebar-nav">
        {navItems.map((item) => (
          <button
            key={item.id}
            className={`nav-item ${activeTab === item.id ? 'active' : ''}`}
            onClick={() => setActiveTab(item.id)}
          >
            <span className="nav-item-icon">{item.icon}</span>
            {item.label}
          </button>
        ))}
      </nav>

      <button className="new-chat-btn" onClick={handleNewChat}>
        <span>+</span>
        New Chat
      </button>
    </div>
  );
}

export default Sidebar;