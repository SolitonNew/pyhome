import settings from 'electron-settings';

const {ipcRenderer} = require('electron');

function startLoad() {
    document.getElementById('connect_ip').value = settings.getSync('connect_ip');
}

function saveWindow() {
    settings.setSync('connect_ip', document.getElementById('connect_ip').value);
    ipcRenderer.send('connect-params-changed');
    window.close();
}

function closeWindow() {
    window.close();
}
