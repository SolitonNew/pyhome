let registerWindow;

function showRegister(data) {
    registerWindow = new BrowserWindow({
        width: 400,
        height: 200,
        autoHideMenuBar: true,
        modal: true,
        resizable: false,
        webPreferences: {
            nodeIntegration: true,
        },
        frame: false,
        icon: __dirname + '/images/icon.png',
    });
    
    registerWindow.loadURL(`file://${__dirname}/registerForm.html`).then(() => {
        registerWindow.send('show-register-window', data);
    });
}

