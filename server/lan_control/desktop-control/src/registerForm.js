import settings from 'electron-settings';

const {ipcRenderer} = require('electron');

ipcRenderer.on('show-register-window', (event, data) => {
    let ls = document.getElementById('login');
    for (let i = 0; i < data.length; i++) {
        ls.options[i] = new Option(data[i][1], data[i][0]);
    }
});

function startLoad() {    
    //
}

function closeWindow() {
    window.close();
}

function saveWindow() {
    let appID = document.getElementById('login').value;
    settings.setSync('appID', appID);
    ipcRenderer.send('connect-params-changed', '');
    
    window.close();
}
