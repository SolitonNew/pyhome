import {app, BrowserWindow} from 'electron';
import settings from 'electron-settings';

const {dialog, ipcMain} = require('electron');
const os = require('os');

let platform = os.platform();

if (require('electron-squirrel-startup')) {
    app.quit();
}

let mainWindow;

const createWindow = () => {
    // Проверяем есть ли куда подключаться

    var size = settings.getSync('size');
    if (!size) {
        size = new Array(300, 600);
    }

    var position = settings.getSync('position');
    if (!position) {
        position = new Array(100, 100);
    }

    mainWindow = new BrowserWindow({
        x: position[0],
        y: position[1],
        width: size[0],
        height: size[1],
        minWidth: 250,
        minHeight: 600,
        autoHideMenuBar: true,
        webPreferences: {
            nodeIntegration: true,
        },
        frame: false,
        icon: __dirname + '/images/logo.png',
    });

    mainWindow.loadURL(`file://${__dirname}/mainForm.html`);
    
    mainWindow.on('resize', () => {
        settings.setSync('size', mainWindow.getSize());
    });

    mainWindow.on('move', () => {
        let pos = mainWindow.getPosition();
        settings.setSync('position', pos);
    });

    mainWindow.on('closed', () => {
        mainWindow = null;
        app.quit();
    });
};

app.on('ready', createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (mainWindow === null) {
        createWindow();
    }
});

ipcMain.on('open-dir-dialog', (event) => {
    dialog.showOpenDialog({properties: ['openFile', 'openDirectory']}).then((result) => {
        event.sender.send('selected-directory', result.filePaths);    
    });
});

ipcMain.on('connect-params-changed', (event) => {
    mainWindow.send('connect-params-changed');
});

ipcMain.on('close-app', (event) => {
    app.quit();
});

ipcMain.on('run-scheduler-action', (event, data) => {
    mainWindow.send('run-scheduler-action', data);
});

ipcMain.on('edit-scheduler-record', (event, data) => {
    mainWindow.send('edit-scheduler-record', data);
});

ipcMain.on('delete-scheduler-record', (event, data) => {
    mainWindow.send('delete-scheduler-record', data);
});

ipcMain.on('clear-all-settings', (event, data) => {
    settings.unsetSync();
    app.relaunch();
    app.quit();
});

ipcMain.on('set-app-name', (event, data) => {
    mainWindow.send('set-app-name', data);
});

ipcMain.on('variable-scheduler', (event, data) => {
    mainWindow.send('variable-scheduler', data);
});

ipcMain.on('set-media-folders', (event, data) => {
    mainWindow.send('set-media-folders', data);
});




