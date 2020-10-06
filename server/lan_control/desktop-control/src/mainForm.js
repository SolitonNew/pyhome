import settings from 'electron-settings';

const {BrowserWindow} = require('electron').remote;
const {ipcRenderer} = require('electron');
const net = require('net');
const iconv = require('iconv-lite');

let variableGroups = new Array();  // (4) ["1", "Дом", "None", "0"]
let variables = new Array();       // ["156", "AQUA_PUMP", "Аквариум фильтр", "3", "0.0", "23"]
let socket = null;
let appID = -1;
let socketQueue = new Array();
let socketData = '';
let syncTimer = null;

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
                                case '7': // Термостат
                                    nv = Math.round(parseFloat(v[4])) - 1;
                                    if (nv < 0) {
                                        nv = 0;
                                    }
                                    $('#variable_' + sel.recID).width((nv * 10) + '%');
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
                                case '7': // Термостат
                                    nv = Math.round(parseFloat(v[4])) + 1;
                                    if (nv > 10) {
                                        nv = 10;
                                    }
                                    $('#variable_' + sel.recID).width((nv * 10) + '%');
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
                        break;
                    case 5:
                        break;
                }   
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
                        break;
                    case 5:
                        break;
                }   
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
        socket.destroy();
        socketQueue = new Array();
        socketData = '';
    }
    
    socket = new net.Socket();
    socket.connect(8090, ip);
    
    socket.on('connect', () => {
        socketQueue = new Array();
        socketData = '';    
        firstConnecting = true;
        reconectCount = 0;
        if (appID == -1) {
            metaQuery('apps list', '');
        } else {
            metaQuery('load variable group', '');
            metaQuery('load variables', appID);
        }
    });
    
    socket.on('error', () => {
        console.log('ERROR');
    });
    
    socket.on('close', (hadError) => {
        console.log('CLOSE');
        setTimeout(reconnect, 3000);
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

    // ["1", "Дом", "None", "0"]    
    // ["156", "AQUA_PUMP", "Аквариум фильтр", "3", "0.0", "23"]
    
    // Сортируем группы по row[3]
    
    let loop = true;
    while (loop) {
        loop = false;
        for (let i = 0; i < variableGroups.length - 1; i++) {
            if (variableGroups[i][3] > variableGroups[i + 1][3]) {
                let row = variableGroups[i];
                variableGroups[i] = variableGroups[i + 1];
                variableGroups[i + 1] = row;
                loop = true;
            }
        }
    }
    
    
    let items = new Array();
    
    for (let g = 0; g < variableGroups.length; g++) {
        if (variableGroups[g][2] == 'None' || variableGroups[g][2] == '1')  {
            let g_row = {
                isGroup: true,
                name: variableGroups[g][1],
            }
            items.push(g_row);
           
            // Определяем вложения по дереву
            
            let ids = new Array();
            function getChilds(id) {
                ids.push(id);
                for (let i = 0; i < variableGroups.length; i++) {
                    if (variableGroups[i][2] == id) {
                        ids.push(variableGroups[i][0]);
                        getChilds(variableGroups[i][0]);
                    }
                }    
            }
            
            if (variableGroups[g][2] == '1') {
                getChilds(variableGroups[g][0]);
            } else {
                ids.push(variableGroups[g][0]);
            }
            
            // Формируем список подчиненных переменных
            
            for (let v = 0; v < variables.length; v++) {
                if (ids.indexOf(variables[v][5]) > -1) {
                    let v_row = {
                        id: variables[v][0],
                        isGroup: false,
                        name: variables[v][2],
                        typ: variables[v][3],
                        value: variables[v][4],
                    }
                    items.push(v_row);
                }
            }
        }
    }
    
    // Хелперы
    
    function addGroup(page_a, name) {
        page_a.push(
            '<div class="list-item-group">' +
                '<div style="position: absolute;width:100%;border-bottom: 1px solid #cccccc;"></div>' +
                '<div class="item-label">' + name + '</div>' +
            '</div>'
        );        
    }
    
    function addSwitch(page_a, id, name, value) {
        let v = '';
        if (value == '1.0') {
            v = 'checked';
        }
        page_a.push(
            '<div id="recID_' + id + '" class="list-item">' +
                '<div class="item-label">' + name + '</div>' +
                '<div class="custom-control custom-switch">' +
                    '<input type="checkbox" class="custom-control-input" id="variable_' + id + '" oninput="switchClick(' + id + ')" ' + v + '>' +
                    '<label class="custom-control-label" for="variable_' + id + '"></label>' +
                '</div>' +
            '</div>'
        );        
    }
    
    function addTemperature(page_a, id, name, value) {       
        // Проверяем есть ли термостаты с таким же именем
        
        let terIndex = -1;
        for (let i = 0; i < variables.length; i++) {
            if ((variables[i][3] == '5') && (variables[i][2] == name)) {
                terIndex = i;
                break;
            }
        }
        
        if (terIndex == -1) {
            if (value == 'None') {
                page_a.push(
                    '<div id="recID_' + id + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                    '</div>'
                );
            } else {
                page_a.push(
                    '<div id="recID_' + id + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                        '<div class="variable-text-value"><span id="variable_' + id + '" class="variable-short-value">' + value + '</span>°C</div>' +
                    '</div>'
                );
            }        
        } else {
            let varTer = variables[terIndex];
            
            if (value == 'None') {
                page_a.push(
                    '<div id="recID_' + varTer[0] + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                        '<div class="variable-term-value">' +
                            '<span class="arrow-no-sel">&#9668;</span>' + 
                            '<span id="variable_' + varTer[0] + '">' + Math.round(parseFloat(varTer[4])) + '</span>' +
                            '<span class="arrow-no-sel">&#9658;</span>' +
                        '</div>' +
                        '<div class="variable-text-value"></div>' +
                    '</div>'
                );
            } else {
                page_a.push(
                    '<div id="recID_' + varTer[0] + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                        '<div class="variable-term-value">' +
                            '<span class="arrow-no-sel">&#9668;</span>' +
                            '<span id="variable_' + varTer[0] + '">' + Math.round(parseFloat(varTer[4])) + '</span>' +
                            '<span class="arrow-no-sel">&#9658;</span>' +
                        '</div>' +
                        '<div class="variable-text-value"><span id="variable_' + id + '" class="variable-short-value">' + value + '</span>°C</div>' +
                    '</div>'
                );            
            }
        }
    }
    
    function addFan(page_a, id, name, value) {
        let v = parseFloat(value) * 10;
        page_a.push(
            '<div id="recID_' + id + '" class="list-item">' +
                '<div class="item-label">' + name + '</div>' +
                '<div class="progress volume-bar" style="width:70px;">' +
                    '<div id="variable_' + id +'" class="progress-bar" style="width:' + v + '%"></div>' +
                '</div>' + 
            '</div>'
        );
    }
    
    function addShortValue(page_a, id, name, value, deg) {
        let v = value;
        if (value == 'None') {
            page_a.push(
                '<div id="recID_' + id + '" class="list-item">' +
                    '<div class="item-label">' + name + '</div>' +
                '</div>'
            );  
        } else {
            page_a.push(
                '<div id="recID_' + id + '" class="list-item">' +
                    '<div class="item-label">' + name + '</div>' +
                    '<div class="variable-text-value"><span id="variable_' + id + '" class="variable-short-value">' + v + '</span>' + deg + '</div>' +
                '</div>'
            );      
        }  
    }
    
    // Распределяем переменные по страницам    
    
    let page1_a = new Array();
    let page2_a = new Array();
    let page3_a = new Array();
    
    for (let i = 0; i < items.length; i++) {
        // PAGE 1  --------------------
        if (items[i].isGroup) {
            if ((page1_a.length > 0) && (page1_a[page1_a.length - 1].indexOf('list-item-group') > -1)) {
                page1_a.pop();
            }
            addGroup(page1_a, items[i].name);
        } else {
            switch (items[i].typ) {
                case '1':  // Свет
                case '3':  // Розетка
                    addSwitch(page1_a, items[i].id, items[i].name, items[i].value);
                    break;
            }
        }
    
        // PAGE 2  --------------------
        if (items[i].isGroup) {
            if ((page2_a.length > 0) && (page2_a[page2_a.length - 1].indexOf('list-item-group') > -1)) {
                page2_a.pop();
            }
            addGroup(page2_a, items[i].name);
        } else {
            switch (items[i].typ) {
                case '4':  // Термометр
                    addTemperature(page2_a, items[i].id, items[i].name, items[i].value);
                    break;
                case '10': // Гигрометр
                    addShortValue(page2_a, items[i].id, items[i].name, items[i].value, '%');
                    break;
                case '5':  // Термостат
                    break;
            }            
        }
        
        // PAGE 3  --------------------
        if (items[i].isGroup) {
            if ((page3_a.length > 0) && (page3_a[page3_a.length - 1].indexOf('list-item-group') > -1)) {
                page3_a.pop();
            }
            addGroup(page3_a, items[i].name);
        } else {
            switch (items[i].typ) {
                case '7':  // Вентилятор
                    addFan(page3_a, items[i].id, items[i].name, items[i].value);
                    break;
                case '11': // Датчик газа
                    addShortValue(page3_a, items[i].id, items[i].name, items[i].value, 'ppm');
                    break;
                case '13': // Датчик атмосферного давления
                    addShortValue(page3_a, items[i].id, items[i].name, items[i].value, 'mm');
                    break;
            }
        }
    }
    
    if ((page1_a.length > 0) && (page1_a[page1_a.length - 1].indexOf('list-item-group') > -1)) {
        page1_a.pop();
    }
    
    if ((page2_a.length > 0) && (page2_a[page2_a.length - 1].indexOf('list-item-group') > -1)) {
        page2_a.pop();
    }
    
    if ((page3_a.length > 0) && (page3_a[page3_a.length - 1].indexOf('list-item-group') > -1)) {
        page3_a.pop();
    }
    
    page1.innerHTML = page1_a.join('');
    page2.innerHTML = page2_a.join('');
    page3.innerHTML = page3_a.join('');
    
    $('#page1 div.list-item').on('click', (event) => {
        $('#page1 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
    
    $('#page2 .list-item').on('click', (event) => {
        $('#page2 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
    
    $('#page3 .list-item').on('click', (event) => {
        $('#page3 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
    
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
            let id = variables[i][0];
            if (id == data[r][1]) {
                variables[i][4] = data[r][2];
                let v;
                
                switch (variables[i][3]) {
                    case '1':  // Свет
                    case '3':  // Розетки
                        if (variables[i][4] == '1.0') {
                            $('#variable_' + id).prop('checked', true);
                        } else {
                            $('#variable_' + id).prop('checked', false);
                        }
                        break;
                
                    case '4':  // Термометр
                    case '10':  // Гигрометр
                        $('#variable_' + id).text(variables[i][4]);
                        break;
                    case '5': // Термостат
                        $('#variable_' + id).text(Math.round(parseFloat(variables[i][4])));
                        break;
                        
                    case '7':  // Вентилятор
                        v = parseFloat(variables[i][4]) * 10;
                        $('#variable_' + id).width(v + '%');
                        break;
                    case '11': // Датчик газа
                    case '13': // Датчик атмосферного давления
                        $('#variable_' + id).text(variables[i][4]);
                        break;
                }
            }
        }
    }
    

}

function metaQuery(packName, packData) {
    if (socketQueue.length > 10) {
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
        new window.Notification(row[1], {title: row[1], body: row[4]});
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
            break;
        case 5:
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





