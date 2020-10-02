import settings from 'electron-settings';

const {ipcRenderer} = require('electron');

let login = document.getElementById('connect_login');
let ip = document.getElementById('connect_ip');
let mediaList = document.getElementById('mediaList');
let mediaListData = new Array();

function startLoad() {    
    login.value = settings.getSync('connect_login');
    ip.value = settings.getSync('connect_ip');
    
    mediaListData = settings.getSync('medias');
    if (mediaListData) {
        for (let i = 0; i < mediaListData.length; i++) {
            mediaList.options[i] = new Option(mediaListData[i], '')
        }
    } else {
        mediaListData = new Array();
    }
}

function closeWindow() {
    window.close();
}

function saveConfogLogin() {
    settings.setSync('connect_login', login.value);
}

function saveConfigIp() {
    settings.setSync('connect_ip', ip.value);
    ipcRenderer.send('connect-params-changed');
}

function addMedia() {
    ipcRenderer.send('open-dir-dialog');
}

ipcRenderer.on('selected-directory', (event, files) => {
    for (let i = 0; i < files.length; i++) {
        mediaList.options[mediaListData.length] = new Option(files[i], '');
        mediaListData.push(files[i]);
    }    
    settings.setSync('medias', mediaListData);
});

function delMedia() {
    for (let i = mediaList.options.length - 1; i > -1; i--) {
        if (mediaList.options[i].selected) {
            mediaList.options[i] = null;
            mediaListData.splice(i, 1);
        }
    }
    settings.setSync('medias', mediaListData);
}
