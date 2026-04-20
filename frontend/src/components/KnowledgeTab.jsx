import React, { useState, useCallback } from 'react';

function KnowledgeTab() {
  const [sources, setSources] = useState([
    { name: 'project_docs.pdf', size: '2.4 MB', status: 'ready', type: 'pdf' },
    { name: 'api_reference.md', size: '156 KB', status: 'ready', type: 'md' },
    { name: 'user_manual.docx', size: '5.1 MB', status: 'processing', type: 'docx' }
  ]);
  const [isDragOver, setIsDragOver] = useState(false);

  const handleDragOver = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(true);
  }, []);

  const handleDragLeave = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(false);
  }, []);

  const handleDrop = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(false);

    const files = Array.from(e.dataTransfer.files);
    // TODO: Process dropped files
    console.log('Dropped files:', files);
  }, []);

  const handleFileSelect = async () => {
    // Use Electron dialog to select files
    try {
      const files = await window.electronAPI.selectFiles();
      setSources(prev => [...prev, ...files.map(file => ({
        name: file.name,
        size: formatFileSize(file.size),
        status: 'processing',
        type: file.name.split('.').pop().toLowerCase()
      }))]);
    } catch (error) {
      console.error('File selection failed:', error);
    }
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const removeSource = (index) => {
    setSources(prev => prev.filter((_, i) => i !== index));
  };

  const getFileIcon = (type) => {
    const icons = {
      pdf: '📄',
      md: '📝',
      docx: '📃',
      txt: '📄',
      default: '📄'
    };
    return icons[type] || icons.default;
  };

  const getStatusBadge = (status) => {
    const badges = {
      processing: { text: 'Processing', class: 'processing' },
      ready: { text: 'Ready', class: 'ready' },
      error: { text: 'Error', class: 'error' }
    };
    return badges[status] || badges.processing;
  };

  return (
    <div className="tab-content">
      <div className="tab-header">
        <h1 className="tab-title">Knowledge Base</h1>
        <p className="tab-subtitle">Upload documents to enhance AI responses with your knowledge</p>
      </div>

      <div className="knowledge-grid">
        <div
          className={`upload-zone ${isDragOver ? 'drag-over' : ''}`}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={handleFileSelect}
        >
          <span className="upload-icon">📤</span>
          <div className="upload-text">Drop files here or click to browse</div>
          <div className="upload-subtext">Supports PDF, MD, DOCX, TXT files</div>
        </div>

        <div className="file-list">
          {sources.map((source, index) => {
            const status = getStatusBadge(source.status);
            return (
              <div key={index} className="file-item">
                <span className="file-icon">{getFileIcon(source.type)}</span>
                <div className="file-info">
                  <div className="file-name">{source.name}</div>
                  <div className="file-meta">{source.size}</div>
                </div>
                <span className={`file-status ${status.class}`}>{status.text}</span>
                <button
                  className="file-remove"
                  onClick={() => removeSource(index)}
                  title="Remove file"
                >
                  ×
                </button>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default KnowledgeTab;