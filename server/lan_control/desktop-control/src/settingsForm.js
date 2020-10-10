import settings from 'electron-settings';
const {ipcRenderer} = require('electron');
const {dialog} = require('electron').remote;
const remote = require('electron').remote;

let login = document.getElementById('connect_login');
let ip = document.getElementById('connect_ip');
let mediaList = document.getElementById('mediaList');
let mediaListData = new Array();

function startLoad() {
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

function clearSettings() {
    dialog.showMessageBox(remote.getCurrentWindow(), {
        type: 'question',
        title: 'Подтверждение',
        message: 'Сбросить настройки приложения к значениям по умолчанию?',
        buttons: ['Yes', 'No'],
    }).then((res) => {
        if (res.response == 0) {
            ipcRenderer.send('clear-all-settings');
        }
    });
}


function saveAppInfo() {
    ipcRenderer.send('set-app-name', $('#app_info').val());
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

ipcRenderer.on('get-app-info-data', (event, data) => {
    $('#app_info').val(data[0][0]);
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
