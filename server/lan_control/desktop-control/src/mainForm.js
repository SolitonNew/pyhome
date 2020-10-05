import settings from 'electron-settings';

const {BrowserWindow} = require('electron').remote;
const {ipcRenderer} = require('electron');
const net = require('net');
const iconv = require('iconv-lite');

let variableGroups = new Array();
let variables = new Array();   // ["156", "AQUA_PUMP", "Аквариум фильтр", "3", "0.0", "23"]
let socket = null;
let appID = -1;
let socketQueue = new Array();
let socketData = '';
let syncTimer = null;

function reconnect() {
    hideMainControls();
    
    let ip = settings.getSync('connect_ip');
    appID = settings.getSync('appID');
    if (!appID) {
        appID = -1;
    }
    
    if (socket != null) {
        clearInterval(syncTimer);
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
        
        for (let i = 0; i < q.length; i++) {    
            switch (q[i].packName) {
                case 'apps list':
                    showRegister(q[i].data);
                    break;
                case 'load variable group':
                    variableGroups = q[i].data;
                    break;
                case 'load variables':
                    variables = q[i].data;
                    
                    console.log(variables);
                    
                    buildVariables();
                    showMainControls();
                    syncTimer = setInterval(() => {
                        metaQuery('sync', '');
                        metaQuery('exe queue', '');
                        metaQuery('sessions', '');
                        metaQuery('media queue', '');
                    }, 500);
                    break;
                case 'setvar':
                    break;
                case 'sync':
                    updateVariables(q[i].data);
                    break;
                case 'exe queue':
                    if (q[i].data.length > 0) {
                        showNotications(q[i].data);
                    }
                    break;
                case 'sessions':
                    break;
                case 'media queue':
                    break;
            }
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
    let v;

    for (let i = 0; i < variables.length; i++) {
        let row = variables[i];
        switch (row[3]) {
            case '1':
            case '3':
                if (row[4] == '1.0') {
                    v = 'checked';
                } else {
                    v = '';
                }
                page1_a.push(
                    '<div class="list-item">' +
                        '<div class="item-label">' + row[2] + '</div>' +
                        '<div class="custom-control custom-switch">' +
                            '<input type="checkbox" class="custom-control-input" id="variable_' + row[0] + '" oninput="switchClick(' + row[0] + ')" ' + v + '>' +
                            '<label class="custom-control-label" for="variable_' + row[0] + '"></label>' +
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

function updateVariables(data) {

/* Array(5)
    0: "10108327"
    1: "95"
    2: "21.4"
    3: "4"
    4: "11" */
    
    //["156", "AQUA_PUMP", "Аквариум фильтр", "3", "0.0", "23"]
    
    for (let r = 0; r < data.length; r++) {
        for (let i = 0; i < variables.length; i++) {
            if (variables[i][0] == data[r][1]) {
                variables[i][4] = data[r][2];
                
                switch (variables[i][3]) {
                    case '1':
                    case '3':
                        if (variables[i][4] == '1.0') {
                            $('#variable_' + variables[i][0]).prop('checked', true);
                        } else {
                            $('#variable_' + variables[i][0]).prop('checked', false);
                        }
                        break;
                
                    case '4':
                    case '5':
                    case '10':
                        
                        break;
                        
                    case '7':
                    case '11':
                    case '13':
                        break;
                }
            }
        }
    }
    

}

function metaQuery(packName, packData) {
    socketQueue.push(packName);
    socket.write(iconv.encode(packName + String.fromCharCode(1) + packData + String.fromCharCode(2), 'win1251'));
}

function parseMetaQuery(data) {
    socketData += iconv.decode(data, 'win1251');
    let resArray = new Array();
    
    while (true) {    
        let end_i = socketData.indexOf(String.fromCharCode(2));
        
        let str = '';
        if (end_i >= 0) {
            str = socketData.substring(0, end_i);
            socketData = socketData.substring(end_i + 1);
        } else {
            break;
        }
        
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
        
        resArray.push({
            packName: socketQueue.shift(0, 1), 
            data: res
        });
    }
    return resArray;
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

function switchClick(id) {
    if ($('#variable_' + id).prop('checked')) {
        setVarValue(id, 1);
    } else {
        setVarValue(id, 0);
    }
}

function setVarValue(id, value) {
    let str = id + String.fromCharCode(1) + value;
    metaQuery('setvar', str);
}

function showNotications(data) {
    for (let i = 0; i < data.length; i++) {
        let row = data[i];
        new window.Notification(row[1], {title: row[1], body: row[4]});
    }
}

