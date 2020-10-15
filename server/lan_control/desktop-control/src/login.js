let loginWindow;

function showLogin() {
    loginWindow = new BrowserWindow({
        width: 400,
        height: 200,
        autoHideMenuBar: true,
        modal: true,
        resizable: false,
        frame: false,
        icon: __dirname + '/images/login.png',
        webPreferences: {
            nodeIntegration: true,
        },
    });
    
    loginWindow.loadURL(`file://${__dirname}/loginForm.html`);
}
