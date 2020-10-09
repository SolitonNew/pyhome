import settings from 'electron-settings';

const {BrowserWindow, Menu, MenuItem, dialog} = require('electron').remote;
const remote = require('electron').remote;
const {ipcRenderer} = require('electron');
const net = require('net');
const iconv = require('iconv-lite');
const path = require('path');

const SOCKET_QUEUE_LIMIT = 24;

let socket = null;
let appID = -1;
let socketQueue = new Array();
let socketData = '';
let syncTimer = null;
let schedulerTimer = null;

let firstConnecting = false;
let reconectCount = 0;

window.addEventListener('keydown', (event) => {   
    let sel;    
    let v, nv;
    let rec1, rec2;
    
    switch (event.code) {
        case 'Space':
            sel = getSelectedRecord();
            if (sel) {
                switch (sel.page) {
                    case 1:
                        if (sel.recID > 0) {
                            if ($('#variable_' + sel.recID).prop('checked')) {
                                $('#variable_' + sel.recID).prop('checked', false);
                                setVarValue(sel.recID, 0);
                            } else {
                                $('#variable_' + sel.recID).prop('checked', true);
                                setVarValue(sel.recID, 1);
                            }
                        }
                        break;
                    case 4:
                        break;
                    case 5:
                        break; 
                }
            }
            break;
            
        case 'ArrowLeft':
            sel = getSelectedRecord();
            if (sel) {
                v = getVariableAtId(sel.recID);
                if (v) {
                    switch (sel.page) {
                        case 1:
                            if ($('#variable_' + sel.recID).prop('checked')) {
                                $('#variable_' + sel.recID).prop('checked', false);
                                setVarValue(sel.recID, 0);
                            }
                            break;
                        case 2:
                            switch (v[3]) {
                                case '5': // Термостат
                                    nv = Math.round(parseFloat(v[4])) - 1;
                                    if (nv < 15) {
                                        nv = 15;
                                    }
                                    $('#variable_' + sel.recID).text(nv);
                                    setVarValue(sel.recID, nv);
                                    break;
                            }
                            break;
                        case 3:
                            switch (v[3]) {
                                case '7': // Вентиляция
                                    nv = Math.round(parseFloat(v[4])) - 1;
                                    if (nv < 0) {
                                        nv = 0;
                                    }
                                    $('#variable_' + sel.recID).prop('value', nv * 10);
                                    setVarValue(sel.recID, nv);
                                    break;
                            }
                            break;
                        case 4:
                            break;
                        case 5:
                            break; 
                    }       
                }   
                event.preventDefault();     
            }
            break;
            
        case 'ArrowRight':
            sel = getSelectedRecord();
            if (sel) {
                v = getVariableAtId(sel.recID);
                if (v) {
                    switch (sel.page) {
                        case 1:
                            if ($('#variable_' + sel.recID).prop('checked') == false) {
                                $('#variable_' + sel.recID).prop('checked', true);
                                setVarValue(sel.recID, 1);
                            }
                            break;
                        case 2:
                            switch (v[3]) {
                                case '5': // Термостат
                                    nv = Math.round(parseFloat(v[4])) + 1;
                                    if (nv > 30) {
                                        nv = 30;
                                    }
                                    $('#variable_' + sel.recID).text(nv);
                                    setVarValue(sel.recID, nv);
                                    break;
                            }
                            break;
                        case 3:
                            switch (v[3]) {
                                case '7': // Вентиляция
                                    nv = Math.round(parseFloat(v[4])) + 1;
                                    if (nv > 10) {
                                        nv = 10;
                                    }
                                    $('#variable_' + sel.recID).prop('value', nv * 10);
                                    setVarValue(sel.recID, nv);
                                    break;
                            }
                            break;
                        case 4:
                            break;
                        case 5:
                            break; 
                    }       
                }  
                event.preventDefault();   
            }
            break;
            
        case 'ArrowUp':
            sel = getSelectedRecord();
            if (sel) {
                function recUp(pageID) {
                    rec1 = $('#' + pageID + ' .selected');
                    rec2 = rec1.prev();
                    if (rec2.hasClass('list-item-group')) {
                        rec2 = rec2.prev();
                    }
                    
                    if (rec2.hasClass('list-item')) {
                        rec1.removeClass('selected');
                        rec2.addClass('selected');
                    }
                }
            
                switch (sel.page) {
                    case 1:
                        recUp('page1');
                        break;
                    case 2:
                        recUp('page2');
                        break;
                    case 3:
                        recUp('page3');
                        break;
                    case 4:
                        recUp('page4');
                        break;
                    case 5:
                        recUp('page5');
                        break;
                }
                event.preventDefault();  
            }
            break;
            
        case 'ArrowDown':
            sel = getSelectedRecord();
            if (sel) {
                function recDown(pageID) {
                    rec1 = $('#' + pageID + ' .selected');
                    rec2 = rec1.next();
                    if (rec2.hasClass('list-item-group')) {
                        rec2 = rec2.next();
                    }
                    
                    if (rec2.hasClass('list-item')) {
                        rec1.removeClass('selected');
                        rec2.addClass('selected');
                    }
                }
                switch (sel.page) {
                    case 1:
                        recDown('page1');
                        break;
                    case 2:
                        recDown('page2');
                        break;
                    case 3:
                        recDown('page3');
                        break;
                    case 4:
                        recDown('page4');
                        break;
                    case 5:
                        recDown('page5');
                        break;
                }
                event.preventDefault();   
            }
            break;
            
        case 'Enter':
            break;
    }
});

function reconnect() {
    reconectCount++;

    hideMainControls();
    
    if ((reconectCount > 10) && (!firstConnecting)) {
        showLogin();
        reconectCount = 0;
        return ;
    }
    
    let ip = settings.getSync('connect_ip');
    appID = settings.getSync('appID');
    if (!appID) {
        appID = -1;
    }
    
    if (socket != null) {
        clearInterval(syncTimer);
        clearInterval(schedulerTimer);
        socket.destroy();
        socketQueue = new Array();
        socketData = '';
    }
    
    socket = new net.Socket();
    socket.connect(8090, ip);
    
    socket.on('connect', () => {
        setWaiterTitle('Выполняется подключение...');
    
        socketQueue = new Array();
        socketData = '';    
        firstConnecting = true;
        reconectCount = 0;
        if (appID == -1) {
            metaQuery('apps list', '');
        } else {
            metaQuery('load variable group', '');
            metaQuery('load variables', appID);
            metaQuery('get scheduler list', '');
            metaQuery('get media exts', '');
            metaQuery('get media folders', '');
            metaQuery('get media list', '');
            metaQuery('get groups list', '');
        }
    });
    
    socket.on('error', () => {
        console.log('ERROR');
    });
    
    socket.on('close', (hadError) => {
        console.log('CLOSE');
        setTimeout(reconnect, 3000);
    });
    
    function runSync() {
        showMainControls();
        syncTimer = setInterval(() => {
            metaQuery('sync', '');
            metaQuery('exe queue', '');
            metaQuery('sessions', '');
            metaQuery('media queue', '');
        }, 500);
        
        schedulerTimer = setInterval(() => {
            metaQuery('get scheduler list', '');
        }, 1000);
    }
    
    socket.on('data', (data) => {
        let q = parseMetaQuery(data);
        
        for (let i = 0; i < q.length; i++) {
            switch (q[i].packName) {                   
                case 'load variable group':
                    variableGroups = q[i].data;
                    setWaiterTitle('Загрузка списка устройств...');
                    break;
                case 'load variables':
                    variables = q[i].data;
                    buildVariables();
                    setWaiterTitle('Загрузка расписания...');
                    break;
                case 'get scheduler list':
                    schedulerData = q[i].data;
                    buildScheduler();
                    setWaiterTitle('Загрузка медиаданных...');
                    break;
                case 'get media exts':
                    mediaExts = q[i].data;
                    break;
                case 'get media folders':
                    break;
                case 'get media list':
                    mediaData = q[i].data;
                    buildMedia();
                    break;
                case 'get groups list':   // Media
                    mediaGroups = q[i].data;
                    runSync();
                    break;
                    
                case 'get app info':
                    if (settingsWindow) {
                        settingsWindow.send('get-app-info-data', q[i].data);
                    }
                    break;
                case 'apps list':
                    showRegister(q[i].data);
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
                case 'get app info':
                    break;
                case 'get groups cross':  // Media
                    break;
                case 'edit scheduler':
                    buildScheduler();
                    break;
                case 'del scheduler':
                    buildScheduler();
                    break;
                case 'execute':
                    break;
            }
        }
    });        
}

function startLoad() {
    let avol = settings.getSync('audioVolume');
    $('#audioVolume')
        .on('input', (event) => {
            let avol = $(event.target).prop('value');
            settings.setSync('audioVolume', avol);
            //$('#audioSpeech').prop('volume', avol / 100);
        })
        .prop('value', avol);
    //$('#audioSpeech').prop('volume', avol / 100);
    
    $('#mediaVolume')
        .on('input', (event) => {
            settings.setSync('mediaVolume', $(event.target).prop('value'));
        })
        .prop('value', settings.getSync('mediaVolume'));
        

    // Контекстные меню для списков  --------------

    let win = remote.getCurrentWindow();
    win.webContents.on('context-menu', (e, params) => {
        let sel = getSelectedRecord();
        
        let menu = null;
        
        
        switch (sel.page) {
            case 1:
                if (sel.recID > -1) {
                    menu = new Menu();
                    menu.append(new MenuItem({label: 'Включить', click: page1_varOnClick}));
                    menu.append(new MenuItem({label: 'Включить позже...', click: page1_varOnAfterClick}));
                    menu.append(new MenuItem({label: 'Временно включить...', click: page1_varTempOnClick}));
                    menu.append(new MenuItem({type: 'separator'}));
                    menu.append(new MenuItem({label: 'Выключить', click: page1_varOffClick}));
                    menu.append(new MenuItem({label: 'Выключить позже...', click: page1_varOffAfterClick}));
                    menu.append(new MenuItem({label: 'Временно выключить...', page1_varTempOffClick}));
                    menu.append(new MenuItem({type: 'separator'}));
                    menu.append(new MenuItem({label: 'Отменить расписание', page1_varScheduleCancelClick}));
                }
                break;
            case 2:
            case 3:
                break;
            case 4:
                menu = new Menu();
                menu.append(new MenuItem({label: 'Создать...', click: page4_addClick}));
                if (sel.recID > -1) {
                    menu.append(new MenuItem({label: 'Изменить...', click: page4_editClick}));
                    menu.append(new MenuItem({label: 'Удалить', click: page4_delClick}));
                    menu.append(new MenuItem({type: 'separator'}));
                    menu.append(new MenuItem({label: 'Выполнить действие', click: page4_runClick}));
                }
                break;
            case 5:
                menu = new Menu();
                if (sel.recID > -1) {
                    menu.append(new MenuItem({label: 'Проиграть'}));
                    menu.append(new MenuItem({label: 'Пауза'}));
                    menu.append(new MenuItem({label: 'Остановить'}));
                    menu.append(new MenuItem({type: 'separator'}));
                    menu.append(new MenuItem({label: 'О записи...'}));
                    menu.append(new MenuItem({label: 'Перенести воспроизведение на...', submenu: []}));
                    menu.append(new MenuItem({type: 'separator'}));
                    menu.append(new MenuItem({label: 'Добавить в плейлист...', submenu: []}));
                    menu.append(new MenuItem({label: 'Удалить из плейлиста'}));
                    menu.append(new MenuItem({type: 'separator'}));
                }
                menu.append(new MenuItem({label: 'Обновить библиотеку медии'}));
                break;
        }

        if (menu) {        
            menu.popup(win);
        }
    });
    
    // --------------------------------------------
    
    
    reconnect();
}

function closeWindow() {
    window.close();
}

function minimizeWindow() {
    let w = remote.getCurrentWindow();
    w.minimize();  
}

ipcRenderer.on('connect-params-changed', (event) => {
    reconnect();
});

ipcRenderer.on('run-scheduler-action', (event, data) => {
    metaQuery('execute', data);
});

ipcRenderer.on('edit-scheduler-record', (event, data) => {
    let str = data.id + String.fromCharCode(1) +
              data.comm + String.fromCharCode(1) +
              data.action + String.fromCharCode(1) +
              data.type + String.fromCharCode(1) +
              data.timeOfDay + String.fromCharCode(1) +
              data.days + String.fromCharCode(1) +
              '0';    
    
    metaQuery('edit scheduler', str);
    metaQuery('get scheduler list', '');
});

ipcRenderer.on('delete-scheduler-record', (event, data) => {
    dialog.showMessageBox(remote.getCurrentWindow(), {
        type: "question",
        title: 'Подтверждение',
        message: 'Удалить запись расписания?',
        buttons: ["Yes", "No"],
    }).then((res) => {
        switch (res.response) {
            case 0:
                metaQuery('del scheduler', data);
                metaQuery('get scheduler list', '');
                break;
            case 1:
                break;
        }
    });
});


let loginWindow;

function showLogin() {
    loginWindow = new BrowserWindow({
        width: 400,
        height: 200,
        autoHideMenuBar: true,
        modal: true,
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
        modal: true,
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
        modal: true,
        webPreferences: {
            nodeIntegration: true,
        }
    });
  
    settingsWindow.loadURL(`file://${__dirname}/settingsForm.html`).then(() => {
        metaQuery('get app info', appID);
    });
  
    settingsWindow.on('closed', () => {
        settingsWindow = null;
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

function metaQuery(packName, packData) {
    if (socketQueue.length > SOCKET_QUEUE_LIMIT) {
        console.log('SOCKET QUEUE');
        reconnect();
        return ;
    }
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
    $('#pageTabs').hide();
    $('#pages').hide();
    $('#bottomToolBar1').hide();
    $('#bottomToolBar2').hide();
    
    $('#waiter').show();
}

function showMainControls() {
    $('#waiter').hide();

    $('#pageTabs').show();
    $('#pages').show();
    $('#bottomToolBar1').show();
    $('#bottomToolBar2').show();
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
    
    for (let i = 0; i < variables.length; i++) {
        if (variables[i][0] == id) {
            variables[i][4] = value;
            break;
        }
    }
}

function showNotications(data) {
    for (let i = 0; i < data.length; i++) {
        let row = data[i];
        let str = row[4].replace(/\*/g, '');
        new window.Notification(row[1], {
            title: row[1], 
            body: str,
        });
    }
}

function getSelectedRecord() {
    let page = -1;
    let rec;
    let recID = -1;
    
    page = $('#pageContent .active').index();
    if (page > -1) {
        page++;
    }
        
    switch (page) {
        case 1:
            rec = $('#page1 .selected');
            if (rec && rec.attr('id')) {
                recID = rec.attr('id').substring(6);
            }
            break;
        case 2:
            rec = $('#page2 .selected');
            if (rec && rec.attr('id')) {
                recID = rec.attr('id').substring(6);
            }
            break;
        case 3:
            rec = $('#page3 .selected');
            if (rec && rec.attr('id')) {
                recID = rec.attr('id').substring(6);
            }
            break;
        case 4:
            rec = $('#page4 .selected');
            if (rec && rec.attr('id')) {
                recID = rec.attr('id').substring(8);
            }
            break;
        case 5:
            rec = $('#page5 .selected');
            if (rec && rec.attr('id')) {
                recID = rec.attr('id').substring(8);
            }
            break;
    }
    
    return {
        page: page, 
        recID: recID
    }
}

function getVariableAtId(id) {
    for (let i = 0; i < variables.length; i++) {
        if (variables[i][0] == id) {
            return variables[i];
        }
    }
    return null;
}

function setSilentInfo(val) {
    if (val == '1.0') {
        $('#silentInfo').text('[Тихий час]');
    } else {
        $('#silentInfo').text('');
    }
}

function playSound() {
    let src = 'file://' + path.resolve('./src/audio/1.mp3');
    var bMusic = new Audio(src);
	bMusic.play();
}

function setWaiterTitle(text) {
    $('#waiterText').text(text);
}

function page1_varOnClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        let v = getVariableAtId(sel.recID);
        if (v[4] == '0.0') {
            setVarValue(sel.recID, 1);
            $('#variable_' + sel.recID).prop('checked', true);
        }
    }
}

function page1_varOnAfterClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        dialog.showMessageBox(remote.getCurrentWindow(), {
            type: "warning",
            title: 'Включить через (минут)',
            message: 'Включить через (минут), Включить через (минут), Включить через (минут), Включить через (минут) Включить через (минут)',
            buttons: ["OK"],
        });
    }
}

function page1_varTempOnClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        prompt('Включить временно на (минут)', '5');
    }
}

function page1_varOffClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        let v = getVariableAtId(sel.recID);
        if (v[4] == '1.0') {
            setVarValue(sel.recID, 0);
            $('#variable_' + sel.recID).prop('checked', false);
        }
    }
}

function page1_varOffAfterClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        prompt('Выключить через (минут)', '5');
    }
}

function page1_varTempOffClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        prompt('Выключить временно на (минут)', '5');
    }
}

function page1_varScheduleCancelClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        
    }
}

function page4_addClick(item) {
    showScheduler(-1);
}

function page4_editClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 4 && sel.recID > -1) {
        showScheduler(sel.recID);
    }
}

function page4_delClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 4 && sel.recID > -1) {
        ipcRenderer.send('delete-scheduler-record', sel.recID);
    }
}

function page4_runClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 4 && sel.recID > -1) {
        let comm = null;
        for (let i = 0; i < schedulerData.length; i++) {
            if (schedulerData[i][0] == sel.recID) {
                comm = schedulerData[i][2];
                break;
            }
        }
        if (comm) {
            dialog.showMessageBox(remote.getCurrentWindow(), {
                type: "question",
                title: 'Подтверждение',
                message: 'Выполнить действие расписания?',
                buttons: ["Yes", "No"],
            }).then((res) => {
                switch (res.response) {
                    case 0:
                        metaQuery('execute', comm);
                        break;
                    case 1:
                        break;
                }
            });
        }
    }
}







