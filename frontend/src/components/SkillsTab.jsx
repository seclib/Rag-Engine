import React, { useState } from 'react';

function SkillsTab() {
  const [skills, setSkills] = useState([
    {
      id: 1,
      name: 'Code Analysis',
      description: 'Analyze code for bugs, performance issues, and best practices',
      icon: '🔍',
      enabled: true,
      category: 'Development'
    },
    {
      id: 2,
      name: 'Summarizer',
      description: 'Create concise summaries of long documents and conversations',
      icon: '📝',
      enabled: false,
      category: 'Productivity'
    },
    {
      id: 3,
      name: 'Bug Fixer',
      description: 'Automatically detect and suggest fixes for common programming errors',
      icon: '🐛',
      enabled: true,
      category: 'Development'
    },
    {
      id: 4,
      name: 'Repo Explorer',
      description: 'Navigate and understand large codebases with intelligent search',
      icon: '📂',
      enabled: false,
      category: 'Development'
    }
  ]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newSkill, setNewSkill] = useState({
    name: '',
    description: '',
    category: 'General'
  });

  const toggleSkill = (id) => {
    setSkills(prev => prev.map(skill =>
      skill.id === id ? { ...skill, enabled: !skill.enabled } : skill
    ));
  };

  const addSkill = () => {
    if (newSkill.name.trim() && newSkill.description.trim()) {
      const skill = {
        id: Date.now(),
        ...newSkill,
        icon: '⚡',
        enabled: true
      };
      setSkills(prev => [...prev, skill]);
      setNewSkill({ name: '', description: '', category: 'General' });
      setShowAddModal(false);
    }
  };

  const categories = ['General', 'Development', 'Productivity', 'Creative', 'Research'];

  return (
    <div className="tab-content">
      <div className="tab-header">
        <h1 className="tab-title">AI Skills</h1>
        <p className="tab-subtitle">Enable specialized capabilities to enhance your AI assistant</p>
      </div>

      <div className="skills-grid">
        {skills.map((skill) => (
          <div key={skill.id} className="skill-card">
            <div className="skill-header">
              <div className="skill-icon">{skill.icon}</div>
              <div
                className={`skill-toggle ${skill.enabled ? 'active' : ''}`}
                onClick={() => toggleSkill(skill.id)}
                title={skill.enabled ? 'Disable skill' : 'Enable skill'}
              ></div>
            </div>
            <div className="skill-info">
              <h3 className="skill-name">{skill.name}</h3>
              <p className="skill-description">{skill.description}</p>
              {skill.enabled && <span className="skill-status">Active</span>}
            </div>
          </div>
        ))}
      </div>

      <button className="add-skill-btn" onClick={() => setShowAddModal(true)} title="Add new skill">
        +
      </button>

      {showAddModal && (
        <div className="modal-overlay" onClick={() => setShowAddModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">Add New Skill</h2>
              <p className="modal-subtitle">Create a custom skill for your AI assistant</p>
            </div>

            <div className="modal-body">
              <div className="form-group">
                <label className="form-label">Skill Name</label>
                <input
                  type="text"
                  className="form-input"
                  placeholder="e.g., Code Reviewer"
                  value={newSkill.name}
                  onChange={(e) => setNewSkill(prev => ({ ...prev, name: e.target.value }))}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Description</label>
                <textarea
                  className="form-input form-textarea"
                  placeholder="Describe what this skill does..."
                  value={newSkill.description}
                  onChange={(e) => setNewSkill(prev => ({ ...prev, description: e.target.value }))}
                  rows={3}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Category</label>
                <select
                  className="form-input form-select"
                  value={newSkill.category}
                  onChange={(e) => setNewSkill(prev => ({ ...prev, category: e.target.value }))}
                >
                  {categories.map(category => (
                    <option key={category} value={category}>{category}</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="modal-actions">
              <button className="btn btn-secondary" onClick={() => setShowAddModal(false)}>
                Cancel
              </button>
              <button
                className="btn btn-primary"
                onClick={addSkill}
                disabled={!newSkill.name.trim() || !newSkill.description.trim()}
              >
                Add Skill
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default SkillsTab;