let schedulerData = new Array();  // ["27", "Аквариум свет ВКЛ.", "on("AQUA_LED")", "2020-10-09 06:00:00", "6:00", "", "3", "0"]

function buildScheduler() {
    let ls = new Array();
    
    for (let i = 0; i < schedulerData.length; i++) {
        let o = schedulerData[i];
        
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
    }

    let item = $('#page4 div.list-item.selected');
    let selID = '';
    if (item.length == 1) {
        selID = item.prop('id');
    }

    let page = document.getElementById('page4');
    page.innerHTML = ls.join('');
    
    if (selID) {
        $('#page4 div.list-item#' + selID).addClass('selected');
    }
    
    $('#page4 div.list-item').on('click', (event) => {
        $('#page4 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
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
        webPreferences: {
            nodeIntegration: true,
        }
    });
  
    schedulerWindow.loadURL(`file://${__dirname}/schedulerForm.html`).then(() => {
        schedulerWindow.send('edit-scheduler-record', rec);
    });
  
    schedulerWindow.on('closed', () => {
        schedulerWindow = null;
    });
}
