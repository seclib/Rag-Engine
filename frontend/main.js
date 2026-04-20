const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const isDev = process.env.NODE_ENV === 'development';

function createWindow() {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    titleBarStyle: 'hiddenInset', // Premium Mac-like feel
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  if (isDev) {
    win.loadURL('http://localhost:5173'); // Vite dev server
    win.webContents.openDevTools();
  } else {
    win.loadFile(path.join(__dirname, 'dist/index.html'));
  }

  win.setMenu(null);
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// IPC handlers for backend communication
ipcMain.handle('send-message', async (event, message) => {
  // Call backend API
  // For now, mock response
  return { response: 'This is a mock AI response.' };
});

ipcMain.handle('select-files', async () => {
  const { dialog } = require('electron');
  const result = await dialog.showOpenDialog({
    properties: ['openFile', 'openDirectory', 'multiSelections']
  });
  return result.filePaths;
});

ipcMain.handle('index-sources', async (event, sources) => {
  // Call backend to index
  console.log('Indexing sources:', sources);
});

ipcMain.handle('manage-skills', async (event, action, skill) => {
  // Manage skills
  console.log('Skill action:', action, skill);
});
  sendButton.addEventListener("click", () => {
    const message = userInput.value.trim();
    if (message) {
      appendMessage("user", message);
      userInput.value = "";
      simulateResponse(message);
    }
  });

  // Append message to chat history
  function appendMessage(sender, message) {
    const messageElement = document.createElement("div");
    messageElement.className = sender;
    messageElement.textContent = message;
    chatHistory.appendChild(messageElement);
    chatHistory.scrollTop = chatHistory.scrollHeight;
  }

  // Simulate AI response
  function simulateResponse(message) {
    setTimeout(() => {
      appendMessage("ai", `Response to: ${message}`);
    }, 1000);
  }

  // Sidebar button handlers
  addKnowledgeButton.addEventListener("click", () => {
    knowledgeModal.classList.remove("hidden");
  });

  addSkillButton.addEventListener("click", () => {
    skillModal.classList.remove("hidden");
  });

  settingsButton.addEventListener("click", () => {
    alert("Settings clicked");
  });

  // Close modal handlers
  closeKnowledgeModal.addEventListener("click", () => {
    knowledgeModal.classList.add("hidden");
  });

  closeSkillModal.addEventListener("click", () => {
    skillModal.classList.add("hidden");
  });

  // Handle skill form submission
  const skillForm = document.getElementById("skill-form");
  skillForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const skillData = {
      name: document.getElementById("skill-name").value,
      description: document.getElementById("skill-description").value,
      prompt: document.getElementById("skill-prompt").value,
    };
    console.log("Skill added:", skillData);
    skillModal.classList.add("hidden");
  });
});
