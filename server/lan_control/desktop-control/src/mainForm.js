import settings from 'electron-settings';

const {app, BrowserWindow, Menu, MenuItem, dialog} = require('electron').remote;
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

let reconnectOn = false;

let reconnectInterval = setInterval(() => {
    if (!reconnectOn) {
        return ;
    }

    console.log('TRY CONNECT');

    let ip = settings.getSync('connect_ip');
    appID = settings.getSync('appID');
    if (!appID) {
        appID = -1;
    }
    
    if (socket) {
        clearInterval(syncTimer);
        clearInterval(schedulerTimer);
        socket.destroy();
        socket = null;
        socketQueue = new Array();
        socketData = '';
    }
    
    reconectCount++;

    hideMainControls();
    
    if ((reconectCount >= 3) && (!firstConnecting)) {
        reconnectOn = false;
        showLogin();
        reconectCount = 0;
        return ;
    }
    
    setWaiterTitle('Выполняется подключение...');
    
    socket = new net.Socket();
    
    socket.on('connect', () => {
        console.log('CONNECTED');
        
        reconnectOn = false;
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
            metaQuery('get media list', '');
            metaQuery('get groups list', '');
        }
    });
    
    socket.on('error', () => {
        console.log('ERROR');
        reconnectOn = true;
    });
    
    socket.on('close', () => {
        console.log('CLOSE CONNECT');
        reconnectOn = true;
    });
    
    socket.on('data', (data) => {
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
                case 'name':
                    break;
                case 'apps list':
                    showRegister(q[i].data);
                    break;
                case 'setvar':
                    break;
                case 'sync':
                    updateVariables(q[i].data);
                    break;
                case 'exe queue':  // ["994", "speech", "216", "notify", "спальня №3. свет включен"]
                    if (q[i].data.length > 0) {
                        showNotifications(q[i].data);
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
                case 'audio data':
                    storeAudioSpeech(q[i].packData, q[i].data[0][0]);
                    break;
                case 'get media folders':
                    if (settingsWindow) {
                        settingsWindow.send('get-media-folders', q[i].data[0][0]);
                    }
                    break;
                case 'set media folders':
                    break;
            }
        }
    });
    socket.connect(8090, ip);
    reconnectOn = false;
}, 1000);

function reconnect() {
    reconnectOn = true;
}

function startLoad() {
    setWaiterTitle('Запуск приложения...');

    let avol = settings.getSync('audioVolume');
    audioSpeechPlayerMuted = settings.getSync('audioMute');
    $('#audioMute').attr('aria-pressed', !audioSpeechPlayerMuted);
    $('#audioVolume')
        .on('input', (event) => {
            let avol = $(event.target).prop('value');
            settings.setSync('audioVolume', avol);
            audioSpeechSetVolume();
        })
        .prop('value', avol);

    $('#audioMute').on('click', (event) => {
        event.currentTarget.blur();
        audioSpeechPlayerMuted = $('#audioMute').attr('aria-pressed') == 'true';
        settings.setSync('audioMute', audioSpeechPlayerMuted);
        audioSpeechSetVolume();
    });
        
    $('#mediaVolume')
        .on('input', (event) => {
            settings.setSync('mediaVolume', $(event.target).prop('value'));
        })
        .prop('value', settings.getSync('mediaVolume'));
       
    $('#mediaMute').on('click', (event) => {
        event.currentTarget.blur();
        settings.setSync('mediaMute', !$('#mediaMute').attr('aria-pressed'));
    }); 

    // Контекстные меню для списков  --------------

    let win = remote.getCurrentWindow();
    win.webContents.on('context-menu', (e, params) => {
        let sel = getSelectedRecord();
        
        let menu = null;
        
        switch (sel.page) {
            case 1:
                if (sel.recID > -1) {
                    menu = new Menu();
                    let varOn = (getVariableAtId(sel.recID)[4] == '1.0');
                    menu.append(new MenuItem({label: 'Включить', click: page1_varOnClick, enabled: !varOn, }));
                    menu.append(new MenuItem({label: 'Включить позже...', click: page1_varOnAfterClick, enabled: !varOn, }));
                    menu.append(new MenuItem({label: 'Временно включить...', click: page1_varTempOnClick, enabled: !varOn, }));
                    menu.append(new MenuItem({type: 'separator'}));
                    menu.append(new MenuItem({label: 'Выключить', click: page1_varOffClick, enabled: varOn, }));
                    menu.append(new MenuItem({label: 'Выключить позже...', click: page1_varOffAfterClick, enabled: varOn, }));
                    menu.append(new MenuItem({label: 'Временно выключить...', click: page1_varTempOffClick, enabled: varOn, }));
                    
                    for (let i = 0; i < schedulerData.length; i++) {
                        if (schedulerData[i][7] == sel.recID) {
                            menu.append(new MenuItem({type: 'separator'}));
                            menu.append(new MenuItem({label: 'Отменить расписание', click: page1_varScheduleCancelClick}));
                            break;
                        }
                    }
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
                    menu.append(new MenuItem({type: 'separator'}));
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
    
    initHTTP();
    
    // --------------------------------------------
    
    reconnect();
    
    // --------------------------------------------
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

ipcRenderer.on('set-app-name', (event, data) => {
    metaQuery('name', data);
});

ipcRenderer.on('variable-scheduler', (event, data) => {
    let v = getVariableAtId(data.id);
    
    let comm = '';
    let action = '';
    let type = 4;
    let varID = v[0];

    switch (data.type) {
        case 'on-after-time': // Включить через (минут):
            comm = 'Включить "' + v[2] + '" через ' + data.value + ' минут';
            action = 'on("' + v[1] + '")';
            break;
        case 'on-and-off-after-time': // Включить временно на (минут):
            comm = 'Выключить "' + v[2] + '" через ' + data.value + ' минут';
            action = 'off("' + v[1] + '")';
            setVarValue(v[0], 1);
            break;
        case 'off-after-time': // Выключить через (минут):
            comm = 'Выключить "' + v[2] + '" через ' + data.value + ' минут';
            action = 'off("' + v[1] + '")';
            break;
        case 'off-and-on-after-time': // Выключить временно на (минут):
            comm = 'Включить "' + v[2] + '" через ' + data.value + ' минут';
            action = 'on("' + v[1] + '")';
            setVarValue(v[0], 0);
            break;
    }
    
    let date = new Date();
    date.setMinutes(date.getMinutes() + parseInt(data.value));
    
    let hh = date.getHours();
    if (hh < 10) {
        hh = '0' + hh;
    }
    let ii = date.getMinutes();
    if (ii < 10) {
        ii = '0' + ii;
    }
    let timeOfDay = hh + ':' + ii;
    
    let mm = date.getMonth() + 1;
    if (mm < 10) {
        mm = '0' + mm;
    }
    let dd = date.getDate();
    if (dd < 10) {
        dd = '0' + dd;
    }
    let days = dd + '-' + mm;

    let str = '-1' + String.fromCharCode(1) +
              comm + String.fromCharCode(1) +
              action + String.fromCharCode(1) +
              type + String.fromCharCode(1) +
              timeOfDay + String.fromCharCode(1) +
              days + String.fromCharCode(1) +
              varID;    
    
    metaQuery('edit scheduler', str);
    metaQuery('get scheduler list', '');
});

ipcRenderer.on('set-media-folders', (event, data) => {
    let str = data;
    metaQuery('set media folders', str);
});

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
        reconnect();
        return ;
    }
    socketQueue.push({
        packName: packName,
        packData: packData,
    });
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
        
        let p = socketQueue.shift(0, 1);
        
        resArray.push({
            packName: p.packName,
            packData: p.packData, 
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

function showNotifications(data) {   // ["994", "speech", "216", "notify", "спальня №3. свет включен"]
    for (let i = 0; i < data.length; i++) {
        let row = data[i];
        if (row[1] == 'speech') {
            let title = row[3];
            let icon = null;
            switch (row[3]) {
                case 'notify':
                    title = 'Информация';
                    icon = null;
                    break;
                case 'alarm':
                    title = 'Тревога!!!';
                    icon = __dirname + '/images/alarm.png';
                    break;
            }
            let body = row[4].replace(/\*/g, '');
            new window.Notification(title, {
                title: title,
                body: body,
                icon: icon,
            });
            
            audioSpeechAppendToQueue(row[3]);
            audioSpeechAppendToQueue(row[2]);
            
            audioSpeechPlayFirst();
        }
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

function setSilentInfo(val) {
    if (val == '1.0') {
        $('#silentInfo').text('[Тихий час]');
    } else {
        $('#silentInfo').text('');
    }
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
        showVariableScheduler(sel.recID, 'on-after-time');
    }
}

function page1_varTempOnClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        showVariableScheduler(sel.recID, 'on-and-off-after-time');
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
        showVariableScheduler(sel.recID, 'off-after-time');
    }
}

function page1_varTempOffClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        showVariableScheduler(sel.recID, 'off-and-on-after-time');
    }
}

function page1_varScheduleCancelClick(item) {
    let sel = getSelectedRecord();
    if (sel.page == 1 && sel.recID > -1) {
        for (let i = 0; i < schedulerData.length; i++) {
            if (schedulerData[i][7] == sel.recID) {
                ipcRenderer.send('delete-scheduler-record', schedulerData[i][0]);
                return ;
            }
        }
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








