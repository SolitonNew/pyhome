import { app, BrowserWindow } from 'electron';
import settings from 'electron-settings';

const os = require('os');
let platform = os.platform();

if (require('electron-squirrel-startup')) {
    app.quit();
}

let mainWindow;

const createWindow = () => {
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
        autoHideMenuBar: true,
        webPreferences: {
            nodeIntegration: true,
        },
        frame: false,
        icon: __dirname + '/images/icon.png',
    });

    mainWindow.loadURL(`file://${__dirname}/index.html`);

    mainWindow.on('closed', () => {
        mainWindow = null;
        app.quit();
    });

    mainWindow.on('resize', () => {
        settings.setSync('size', mainWindow.getSize());
    });

    mainWindow.on('move', () => {
        let pos = mainWindow.getPosition();
        settings.setSync('position', pos);
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
