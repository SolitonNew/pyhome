let schedulerData = new Array();  // ["27", "Аквариум свет ВКЛ.", "on("AQUA_LED")", "2020-10-09 06:00:00", "6:00", "", "0", "0"]

function buildScheduler() {
    let ls = new Array();
    
    for (let i = 0; i < schedulerData.length; i++) {
        let o = schedulerData[i];
        
        ls.push(
            '<div id="schedID_' + o[0] + '" class="list-item">' +
                '<img class="scheduler-img" src="./images/10_0.png">' +
                '<div class="scheduler-text">' +
                    '<div class="scheduler-name">' + o[1] + '</div>' +
                    '<div class="scheduler-range">' + o[4] + '</div>' +
                '</div>' +
                '<div class="sheduler-date">' + o[3] + '</div>' +
            '</div>'
        );    
    }

    let page = document.getElementById('page4');
    page.innerHTML = ls.join('');
    
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
  
    schedulerWindow.loadURL(`file://${__dirname}/schedulerForm.html`);
  
    schedulerWindow.on('closed', () => {
        schedulerWindow = null;
    });
}
