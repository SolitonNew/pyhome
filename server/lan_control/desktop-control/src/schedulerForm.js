const {ipcRenderer} = require('electron');

let recordID = -1;
let schedulerVariableID = 0;

ipcRenderer.on('edit-scheduler-record', (event, data) => {
    if (data[0]) {
        recordID = data[0];
    } else {
        $('#schedulerButtonDel').hide();
    }
    
    if (data[6] == null) {
        data[6] = 0;
    }
    
    $('#schedulerComm').val(data[1]);
    $('#schedulerAction').val(data[2]);
    $('#schedulerType').val(data[6]).trigger('change');
    $('#schedulerTimeOfDay').val(data[4]);
    $('#schedulerDays').val(data[5]);
});

function startLoad() {
    $('#schedulerType').on('change', (event) => {
        switch (event.target.value) {
            case '0':
                $('#schedulerDaysLabel').text('');
                $('#schedulerDaysRow').hide();
                break;
            case '1':
                $('#schedulerDaysLabel').text('Дни недели:');
                $('#schedulerDaysRow').show();
                break;
            case '2':
                $('#schedulerDaysLabel').text('Дни месяца:');
                $('#schedulerDaysRow').show();
                break;
            case '3':
                $('#schedulerDaysLabel').text('Дни года:');
                $('#schedulerDaysRow').show();
                break;
            case '4':
                $('#schedulerDaysLabel').text('Дни года:');
                $('#schedulerDaysRow').show();
                break;
        }
    }).trigger('change');
}

function runAction() {
    ipcRenderer.send('run-scheduler-action', $('#schedulerAction').val());
}

function closeWindow() {
    window.close();
}

function saveWindow() {
    let data = {
        id: recordID,
        comm: $('#schedulerComm').val(),
        action: $('#schedulerAction').val(),
        type: $('#schedulerType').val(),
        timeOfDay: $('#schedulerTimeOfDay').val(),
        days: $('#schedulerDays').val(),
    };
    
    let error_timeOfDay = false;
    let error_days = false;
    
    switch ($('#schedulerType').val()) {
        case '0':
            error_timeOfDay = (data.timeOfDay == '');
            break;
        case '1':
            error_timeOfDay = (data.timeOfDay == '');
            error_days = (data.days == '');
            break;
        case '2':
            error_timeOfDay = (data.timeOfDay == '');
            error_days = (data.days == '');
            break;
        case '3':
            error_timeOfDay = (data.timeOfDay == '');
            error_days = (data.days == '');
            break;
        case '4':
            error_timeOfDay = (data.timeOfDay == '');
            error_days = (data.days == '');
            break;
    }

    if (error_timeOfDay) {
        alert('Поле "' + $('#schedulerTimeOfDayLabel').text() + '" должно быть непустым.');    
        return ;
    }
    
    if (error_days) {
        alert('Поле "' + $('#schedulerDaysLabel').text() + '" должно быть непустым.');    
        return ;
    }

    ipcRenderer.send('edit-scheduler-record', data);
    window.close();
}

function delWindow() {
    ipcRenderer.send('delete-scheduler-record', recordID);
    window.close();
}
