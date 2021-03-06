let settingsWindow;

function showSettings() {
    if (settingsWindow) {
        settingsWindow.focus();
        return ;
    }

    settingsWindow = new BrowserWindow({
        width: 600,
        height: 500,
        autoHideMenuBar: true,
        show: true,
        frame: false,
        modal: true,
        resizable: false,
        webPreferences: {
            nodeIntegration: true,
        }
    });
  
    settingsWindow.loadURL(`file://${__dirname}/settingsForm.html`).then(() => {
        metaQuery('get app info', appID);
        metaQuery('get media folders', '');
    });
  
    settingsWindow.on('closed', () => {
        settingsWindow = null;
    });
}
