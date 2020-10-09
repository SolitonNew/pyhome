let videoWindow;

function showVideo() {
    if (videoWindow) {
        videoWindow.focus();
        return ;
    }

    videoWindow = new BrowserWindow({
        width: 960,
        height: 590,
        autoHideMenuBar: true,
        show: true,
        frame: false,
        webPreferences: {
            nodeIntegration: true,
        }
    });
  
    videoWindow.loadURL(`file://${__dirname}/videoForm.html`);
  
    videoWindow.on('closed', () => {
        videoWindow = null;
    });
}
