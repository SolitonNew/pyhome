import settings from 'electron-settings';

const {ipcRenderer} = require('electron');

function startLoad() {
    let str = settings.getSync('connect_ip');
    if (!str) {
        str = '';
    }
    document.getElementById('connect_ip').value = str;
}

function saveWindow() {
    settings.setSync('connect_ip', document.getElementById('connect_ip').value);
    ipcRenderer.send('connect-params-changed');
    window.close();
}

function closeWindow() {
    window.close();
}
