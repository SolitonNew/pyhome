let schedulerData = new Array();  // ["27", "Аквариум свет ВКЛ.", "on("AQUA_LED")", "2020-10-09 06:00:00", "6:00", "", "3", "0"]

let prevSchedulerHTML = '';

function buildScheduler() {
    let ls = new Array();
    
    for (let i = 0; i < schedulerData.length; i++) {
        let o = schedulerData[i];
        
        switch (o[6]) {
            case '0':
            case '1':
            case '2':
            case '3':
                ls.push(
                    '<div id="schedID_' + o[0] + '" class="list-item">' +
                        '<img class="scheduler-img" src="./images/10_' + o[6] + '.png">' +
                        '<div class="scheduler-text">' +
                            '<div class="scheduler-name">' + o[1] + '</div>' +
                            '<div class="scheduler-range">' + o[4] + '</div>' +
                        '</div>' +
                        '<div class="sheduler-date">' + o[3] + '</div>' +
                    '</div>'
                );    
                break;
            case '4':
                ls.push(
                    '<div id="schedID_' + o[0] + '" class="list-item">' +
                        '<img class="scheduler-img" src="./images/10_' + o[6] + '.png">' +
                        '<div class="scheduler-text">' +
                            '<div class="scheduler-name">' + o[1] + '</div>' +
                            '<div class="scheduler-range">' + o[4] + '</div>' +
                        '</div>' +
                    '</div>'
                );    
                break;
        }
    }

    let item = $('#page4 div.list-item.selected');
    let selID = '';
    if (item.length == 1) {
        selID = item.prop('id');
    }

    let page = document.getElementById('page4');
    let html = ls.join('');
    
    if (prevSchedulerHTML !== html) {
        prevSchedulerHTML = html;
        page.innerHTML = html;
        
        if (selID) {
            $('#page4 div.list-item#' + selID).addClass('selected');
        }
        
        $('#page4 div.list-item').on('click', (event) => {
            $('#page4 .selected').removeClass('selected');
            $(event.currentTarget).addClass('selected');
        });
        
        // Обновляем списко переменных на первой странице
        
        $('#page1 .scheduler').removeClass('scheduler');
        for (let i = 0; i < schedulerData.length; i++) {
            if (schedulerData[i][7] > 0) {
                $('#page1 #recID_' + schedulerData[i][7]).addClass('scheduler');
            }
        }
        
        // ----------------------------------------------
    }
}

let schedulerWindow;

function showScheduler(recID) {
    if (schedulerWindow) {
        schedulerWindow.focus();
        return ;
    }
    
    let rec = new Array();
    for (let i = 0; i < schedulerData.length; i++) {
        if (schedulerData[i][0] == recID) {
            rec = schedulerData[i];
            break;
        }
    }

    schedulerWindow = new BrowserWindow({
        width: 600,
        height: 600,
        autoHideMenuBar: true,
        show: true,
        frame: false,
        modal: true,
        resizable: false,
        webPreferences: {
            nodeIntegration: true,
        },
        icon: __dirname + '/images/login.png',
    });
  
    schedulerWindow.loadURL(`file://${__dirname}/schedulerForm.html`).then(() => {
        schedulerWindow.send('edit-scheduler-record', rec);
    });
  
    schedulerWindow.on('closed', () => {
        schedulerWindow = null;
    });
}

let variableScheduler;

function showVariableScheduler(id, type) {
    if (variableScheduler) {
        variableScheduler.focus();
        return ;
    }
    
    variableScheduler = new BrowserWindow({
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
    
    variableScheduler.loadURL(`file://${__dirname}/variableSchedulerForm.html`).then(() => {
        variableScheduler.send('window-init', {
            type: type, 
            id: id,
        });
    });
    
    variableScheduler.on('closed', () => {
        variableScheduler = null;
    });
}




