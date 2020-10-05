import settings from 'electron-settings';

const {BrowserWindow} = require('electron').remote;
const {ipcRenderer} = require('electron');
const net = require('net');
const iconv = require('iconv-lite');

let variableGroups = new Array();
let variables = new Array();
let socket = null;
let appID = -1;
let socketQueue = new Array();
let socketData = '';

function reconnect() {
    hideMainControls();
    
    let ip = settings.getSync('connect_ip');
    appID = settings.getSync('appID');
    if (!appID) {
        appID = -1;
    }
    
    if (socket != null) {
        socket.destroy();
        socketQueue = new Array();
        socketData = '';
    }
    
    socket = new net.Socket();
    socket.connect(8090, ip);
    
    socket.on('connect', () => {
        if (appID == -1) {
            metaQuery('apps list', '');
        } else {
            metaQuery('load variable group', '');
            metaQuery('load variables', appID);
        }
    });
    
    socket.on('data', (data) => {
        let q = parseMetaQuery(data);
        
        if (!q) return ;
        
        switch (q.packName) {
            case 'apps list':
                showRegister(q.data);
                break;
            case 'load variable group':
                variableGroups = q.data;
                break;
            case 'load variables':
                variables = q.data;
                buildVariables();
                showMainControls();
                break;
        }
    });        
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

let registerWindow;

function showRegister(data) {
    registerWindow = new BrowserWindow({
        width: 400,
        height: 200,
        autoHideMenuBar: true,
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

function buildVariables() {
    let page1 = document.getElementById('page1');
    let page2 = document.getElementById('page2');
    let page3 = document.getElementById('page3');
        
    //1: ok := (o.typ in [1, 3]); 
    //4: ok := (o.typ in [4, 5, 10]); 
    //7: ok := (o.typ in [7, 11, 13]);
    
    let page1_a = new Array();
    let page2_a = new Array();
    let page3_a = new Array();

    for (let i = 0; i < variables.length; i++) {
        let row = variables[i];
        switch (row[3]) {
            case '1':
            case '3':
                page1_a.push(
                    '<div class="list-item">' +
                        '<div class="item-label">' + row[2] + '</div>' +
                        '<div class="custom-control custom-switch">' +
                            '<input type="checkbox" class="custom-control-input" id="page1_btn_' + row[0] + '">' +
                            '<label class="custom-control-label" for="page1_btn_' + row[0] + '"></label>' +
                        '</div>' +
                    '</div>'
                );
                break;
                
            case '4':
            case '5':
            case '10':
                page2_a.push(
                    '<div class="list-item">' +
                        '<div class="item-label">' + row[2] + '</div>' +
                    '</div>'
                );
                break;
                
            case '7':
            case '11':
            case '13':
                page3_a.push(
                    '<div class="list-item">' +
                        '<div class="item-label">' + row[2] + '</div>' +
                    '</div>'
                );
                break;
        }    
    }
    
    page1.innerHTML = page1_a.join('');
    page2.innerHTML = page2_a.join('');
    page3.innerHTML = page3_a.join('');
}

function updateVariables() {

}

function metaQuery(packName, packData) {
    socketQueue.push(packName);
    socket.write(packName + String.fromCharCode(1) + packData + String.fromCharCode(2));
}

function parseMetaQuery(data) {
    socketData += iconv.decode(data, 'win1251');
    
    let end_i = socketData.indexOf(String.fromCharCode(2));
    
    let str = '';
    if (end_i >= 0) {
        str = socketData.substring(0, end_i);
        socketData = socketData.substring(end_i + 1);
    }
    
    if (!str) return null;
    
    let a = str.split(String.fromCharCode(1));
    let n = a[0];
    let count = Math.trunc((a.length - 2) / n);
    let i = 1;
    let res = new Array();
    for (let r = 0; r < count; r++) {
        let row = new Array();
        for (let c = 0; c < n; c++) {
            row[c] = a[i];
            i++;
        }
        res.push(row);
    }
    return {
        packName: socketQueue.shift(0, 1), 
        data: res
    };
}

function hideMainControls() {
    document.getElementById('pageTabs').style.visibility = 'hidden';
    document.getElementById('pages').style.visibility = 'hidden';
    document.getElementById('bottomToolBar1').style.visibility = 'hidden';
    document.getElementById('bottomToolBar2').style.visibility = 'hidden';
}

function showMainControls() {
    document.getElementById('pageTabs').style.visibility = '';
    document.getElementById('pages').style.visibility = '';
    document.getElementById('bottomToolBar1').style.visibility = '';
    document.getElementById('bottomToolBar2').style.visibility = '';
}

