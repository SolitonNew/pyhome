let loginWindow;

function showLogin() {
    loginWindow = new BrowserWindow({
        width: 400,
        height: 200,
        autoHideMenuBar: true,
        modal: true,
        resizable: false,
        webPreferences: {
            nodeIntegration: true,
        },
        frame: false,
        icon: __dirname + '/images/login.png',
    });
    
    loginWindow.loadURL(`file://${__dirname}/loginForm.html`);
}
