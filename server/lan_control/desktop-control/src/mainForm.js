const {BrowserWindow} = require('electron').remote;
const {ipcRenderer} = require('electron');
import settings from 'electron-settings';

let variables = new Array();

function reconnect() {
    document.getElementById('pageTabs').style.visibility = 'hidden';
    document.getElementById('pages').style.visibility = 'hidden';
    document.getElementById('bottomToolBar1').style.visibility = 'hidden';
    document.getElementById('bottomToolBar2').style.visibility = 'hidden';
    
    alert('RECONNECT');

    document.getElementById('pageTabs').style.visibility = '';
    document.getElementById('pages').style.visibility = '';
    document.getElementById('bottomToolBar1').style.visibility = '';
    document.getElementById('bottomToolBar2').style.visibility = '';
}

function startLoad() {    
    reconnect();
}

function closeWindow() {
    window.close();
}

ipcRenderer.on('connect-params-changed', (event) => {
    reconnect();
});

let loginWindow;

function showLogin() {
    loginWindow = new BrowserWindow({
        width: 400,
        height: 200,
        autoHideMenuBar: true,
        webPreferences: {
            nodeIntegration: true,
        },
        frame: false,
        icon: __dirname + '/images/icon.png',
    });
    
    loginWindow.loadURL(`file://${__dirname}/loginForm.html`);
}

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
        webPreferences: {
            nodeIntegration: true,
        }
    });
  
    settingsWindow.loadURL(`file://${__dirname}/settingsForm.html`);
  
    settingsWindow.on('closed', () => {
        settingsWindow = null;
    });
}

let videoWindow;

function showVideo() {
    if (videoWindow) {
        videoWindow.focus();
        return ;
    }

    videoWindow = new BrowserWindow({
        width: 800,
        height: 600,
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

function showPage(num) {
    let tabs = document.getElementById('pageTabs').children;
    
    for (let i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove('active');
    }
    
    let tab = document.getElementById('tab' + num);
    tab.classList.add('active');    
    
    tab.blur();

    let pages = document.getElementById('pageContent').children;

    for (let i = 0; i < pages.length; i++) {
        pages[i].classList.remove('active');
        pages[i].classList.remove('show');
    }

    let page = document.getElementById('page' + num);
    page.classList.add('show');
    page.classList.add('active');
}

function buildPage1() {
    var a = new Array();

    for (let i = 0; i < 10; i++) {
        let s = '<div class="list-item">' +
                '<div class="item-label">VARIABLE_' + i + '</div>' +
                '<div class="custom-control custom-switch">' +
                '<input type="checkbox" class="custom-control-input" id="customSwitch' + i + '">' +
                '<label class="custom-control-label" for="customSwitch' + i + '"></label>' +
                '</div>' +
                '</div>';
        a.push(s);
    }

    let page = document.getElementById('page1');
    page.innerHTML = a.join('');
}

function buildVariables() {
    for (let i = 0; i < variables.length; i++) {
        
    
    
    }
}

function updateVariables() {

}


