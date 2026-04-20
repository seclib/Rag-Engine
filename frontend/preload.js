const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  sendMessage: (message) => ipcRenderer.invoke('send-message', message),
  selectFiles: () => ipcRenderer.invoke('select-files'),
  indexSources: (sources) => ipcRenderer.invoke('index-sources', sources),
  manageSkills: (action, skill) => ipcRenderer.invoke('manage-skills', action, skill),
});