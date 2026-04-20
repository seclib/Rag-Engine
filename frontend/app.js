const API_BASE = "http://localhost:8000";

// State
let activeSkills = [];
let currentView = 'chat';

// DOM Elements
const chatInput = document.getElementById('chat-input');
const sendBtn = document.getElementById('send-btn');
const chatMessages = document.getElementById('chat-messages');
const btnNewChat = document.getElementById('btn-new-chat');
const btnChat = document.getElementById('btn-chat');
const btnKnowledge = document.getElementById('btn-knowledge');
const btnSkills = document.getElementById('btn-skills');
const btnSettings = document.getElementById('btn-settings');
const themeToggle = document.getElementById('theme-toggle');
const views = document.querySelectorAll('.view');

// View Navigation
function showView(viewId) {
    views.forEach(v => v.classList.remove('active'));
    document.getElementById(`${viewId}-view`).classList.add('active');
    
    document.querySelectorAll('.nav-item').forEach(btn => btn.classList.remove('active'));
    document.getElementById(`btn-${viewId}`).classList.add('active');
    
    currentView = viewId;
    if (viewId === 'skills') loadSkills();
    if (viewId === 'knowledge') loadKnowledge();
}

btnChat.onclick = () => showView('chat');
btnKnowledge.onclick = () => showView('knowledge');
btnSkills.onclick = () => showView('skills');
btnSettings.onclick = () => showView('settings');

// New Chat
btnNewChat.onclick = () => {
    chatMessages.innerHTML = '';
    showView('chat');
};

// Theme Toggle
themeToggle.onchange = (e) => {
    document.body.setAttribute('data-theme', e.target.checked ? 'dark' : 'light');
};

// Chat Logic
async function sendMessage() {
    const text = chatInput.value.trim();
    if (!text) return;

    // Add user message
    addMessage(text, 'user');
    chatInput.value = '';
    chatInput.style.height = 'auto';

    // Show typing indicator
    const aiMsgDiv = addMessage('', 'ai');
    let aiContent = "";

    try {
        const response = await fetch(`${API_BASE}/query`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ text, skills: activeSkills })
        });
        
        const reader = response.body.getReader();
        const decoder = new TextDecoder();

        while (true) {
            const { value, done } = await reader.read();
            if (done) break;
            
            const chunk = decoder.decode(value);
            const lines = chunk.split("\n");
            
            for (const line of lines) {
                if (line.startsWith("data: ")) {
                    try {
                        const data = JSON.parse(line.slice(6));
                        aiContent += data.text;
                        aiMsgDiv.innerText = aiContent;
                        chatMessages.scrollTop = chatMessages.scrollHeight;
                    } catch (e) {
                        console.error("Error parsing stream chunk", e);
                    }
                }
            }
        }
    } catch (err) {
        aiMsgDiv.innerText = "Error connecting to backend.";
    }
}

function addMessage(text, role) {
    const div = document.createElement('div');
    div.className = `message ${role}`;
    div.innerText = text;
    chatMessages.appendChild(div);
    chatMessages.scrollTop = chatMessages.scrollHeight;
    return div;
}

sendBtn.onclick = sendMessage;
chatInput.onkeydown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
    }
};

// Auto-resize textarea
chatInput.oninput = () => {
    chatInput.style.height = 'auto';
    chatInput.style.height = chatInput.scrollHeight + 'px';
};

const addSourceBtn = document.getElementById('add-source-btn');
const rebuildIndexBtn = document.getElementById('rebuild-index-btn');

rebuildIndexBtn.onclick = async () => {
    if (!confirm("This will clear and re-index all files. Proceed?")) return;
    rebuildIndexBtn.innerText = "Rebuilding...";
    rebuildIndexBtn.disabled = true;
    try {
        await fetch(`${API_BASE}/knowledge/rebuild`, { method: 'POST' });
        alert("Rebuild started in background.");
    } catch (err) {
        alert("Error starting rebuild.");
    } finally {
        rebuildIndexBtn.innerText = "Rebuild Index";
        rebuildIndexBtn.disabled = false;
    }
};

addSourceBtn.onclick = () => {
    const input = document.createElement('input');
    input.type = 'file';
    input.onchange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;
        
        const formData = new FormData();
        formData.append('file', file);
        
        addMessage(`Indexing ${file.name}...`, 'user');
        try {
            const res = await fetch(`${API_BASE}/knowledge/add`, {
                method: 'POST',
                body: formData
            });
            const data = await res.json();
            addMessage(`Started indexing ${file.name}. It will be available shortly.`, 'ai');
            loadKnowledge();
        } catch (err) {
            addMessage("Error uploading file.", 'ai');
        }
    };
    input.click();
};

async function loadKnowledge() {
    const list = document.getElementById('source-list');
    list.innerHTML = 'Loading sources...';
    try {
        const res = await fetch(`${API_BASE}/knowledge/list`);
        const sources = await res.json();
        list.innerHTML = '';
        sources.forEach(src => {
            const div = document.createElement('div');
            div.className = 'source-item';
            div.innerHTML = `<span>${src}</span> <button onclick="removeSource('${src}')">Remove</button>`;
            list.appendChild(div);
        });
    } catch (err) {
        list.innerHTML = 'Error loading sources.';
    }
}

async function removeSource(filename) {
    if (!confirm(`Are you sure you want to remove ${filename}?`)) return;
    try {
        await fetch(`${API_BASE}/knowledge/remove/${filename}`, { method: 'DELETE' });
        loadKnowledge();
    } catch (err) {
        alert("Error removing source.");
    }
}

// Skills Logic
const addSkillBtn = document.getElementById('add-skill-btn');
const skillModal = document.getElementById('skill-modal');
const closeModal = document.getElementById('close-modal');
const saveSkillBtn = document.getElementById('save-skill');

addSkillBtn.onclick = () => skillModal.classList.add('active');
closeModal.onclick = () => skillModal.classList.remove('active');

saveSkillBtn.onclick = async () => {
    const name = document.getElementById('skill-name').value;
    const description = document.getElementById('skill-desc').value;
    const prompt = document.getElementById('skill-prompt').value;
    
    if (!name || !prompt) {
        alert("Name and Prompt are required.");
        return;
    }
    
    saveSkillBtn.innerText = "Saving...";
    saveSkillBtn.disabled = true;
    
    try {
        await fetch(`${API_BASE}/skills/add`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, description, prompt })
        });
        skillModal.classList.remove('active');
        loadSkills();
    } catch (err) {
        alert("Error saving skill.");
    } finally {
        saveSkillBtn.innerText = "Save Skill";
        saveSkillBtn.disabled = false;
    }
};

async function loadSkills() {
    const list = document.getElementById('skills-list');
    list.innerHTML = 'Loading skills...';
    try {
        const res = await fetch(`${API_BASE}/skills`);
        const skills = await res.json();
        list.innerHTML = '';
        skills.forEach(skill => {
            const div = document.createElement('div');
            div.className = 'skill-card';
            div.innerHTML = `
                <h3>${skill.name}</h3>
                <p>${skill.description}</p>
                <label class="switch">
                    <input type="checkbox" ${skill.enabled ? 'checked' : ''} onchange="toggleSkill('${skill.id}', this.checked)">
                    <span class="slider"></span>
                </label>
            `;
            list.appendChild(div);
        });
    } catch (err) {
        list.innerHTML = 'Error loading skills.';
    }
}

async function toggleSkill(id, enabled) {
    if (enabled) {
        if (!activeSkills.includes(id)) activeSkills.push(id);
    } else {
        activeSkills = activeSkills.filter(sid => sid !== id);
    }
    
    try {
        await fetch(`${API_BASE}/skills/toggle?skill_id=${id}&enabled=${enabled}`, {
            method: 'POST'
        });
    } catch (err) {
        console.error("Error syncing skill state.");
    }
}

// Initialize
showView('chat');
console.log("Seclib AI Frontend Initialized");
