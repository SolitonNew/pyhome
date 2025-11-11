const {ipcRenderer} = require('electron');
const {dialog} = require('electron').remote;
const remote = require('electron').remote;

let variableID = -1;
let variableSchedulerType = '';

function startLoad() {
    
}

function closeWindow() {
    window.close();
}

function okWindow() {
    let val = $('#value').val();
    
    if (val) {
        ipcRenderer.send('variable-scheduler', {
            type: variableSchedulerType,
            id: variableID,
            value: val,
        });
        window.close();
    } else {
        dialog.showMessageBox(remote.getCurrentWindow(), {
            type: 'warning',
            title: 'Внимание',
            message: 'Значение временного интервала должно быть непустым.',
            buttons: ['OK'],
        });
    }
}

ipcRenderer.on('window-init', (event, data) => {
    variableID = data.id;
    variableSchedulerType = data.type;

    let str = '';
    switch (data.type) {
        case 'on-after-time':
            str = 'Включить через (минут):';
            break;
        case 'on-and-off-after-time':
            str = 'Включить временно на (минут):';
            break;
        case 'off-after-time':
            str = 'Выключить через (минут):';
            break;
        case 'off-and-on-after-time':
            str = 'Выключить временно на (минут):';
            break;
    }
    $('#valueLabel').text(str);
    $('#value').val('5');
});





