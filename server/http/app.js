$(document).ready(function () {
    use_splitters();
});

function use_splitters() {
    $('div.splitter_right').mousedown(start_splitter_drag);
    $('div.splitter_left').mousedown(start_splitter_drag);
    $('div.splitter_bottom').mousedown(start_splitter_drag);
    $('div.splitter_top').mousedown(start_splitter_drag);
}

// -------------------------------------------------

function show_window(url) {
    $('#popup_window_content').html('');
    $.ajax({url:url}).done(function (data) {
        $('#popup_window_content').html(data);
   	$('#popup_window').fadeIn(400);
    });
}

function hide_window() {
    $('#popup_window').fadeOut(400);
}

// -------------------------------------------------

var alert_handler = false;

function alert(data, btns, handler) {
    alert_handler = handler;

    var alert_title = 'Информация';
    if (data.indexOf('INFO: ') > -1) {
        alert_title = 'Информация';
	data = data.replace('INFO: ', '');
    } else if (data.indexOf('CONFIRM: ') > -1) {
        alert_title = 'Подтверждение';
   	data = data.replace('CONFIRM: ', '');
    } else if (data.indexOf('WARNING: ') > -1) {
        alert_title = 'Внимание';
	data = data.replace('WARNING: ', '');
    } else if (data.indexOf('ERROR: ') > -1) {
	alert_title = 'Ошибка';
	data = data.replace('ERROR: ', '');
    }

    $('#popup_alert_title').html(alert_title);
    $('#popup_alert_content').html(data);

    if (btns == null) btns = 'ok';

    if (btns.indexOf('ok') > -1)
        $('#alert_ok').css('display', 'inline');
    else
	$('#alert_ok').css('display', 'none');

    if (btns.indexOf('yes') > -1)
	$('#alert_yes').css('display', 'inline');
    else
	$('#alert_yes').css('display', 'none');

    if (btns.indexOf('no') > -1)
        $('#alert_no').css('display', 'inline');
    else
	$('#alert_no').css('display', 'none');

    if (btns.indexOf('cancel') > -1)
	$('#alert_cancel').css('display', 'inline');
    else
	$('#alert_cancel').css('display', 'none');
    
    $('#popup_alert').fadeIn(400);
} 

function alert_click(key) {
    $('#popup_alert').fadeOut(400);
    if (alert_handler)
        alert_handler(key);
}

// -------------------------------------------------

var splitterObj = False;
var splitterP = 0;
var splitterSize = 0;

function stop_mouse_events(e) {
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
};

function start_splitter_drag(e) {
    var border = 8;
    splitterObj = e.target;        
    off = $(splitterObj).offset();    

    if ($(splitterObj).hasClass('splitter_left')) {
        splitterP = e.pageX;
        splitterSize = $(splitterObj).width();
        if (splitterP < off.left + splitterSize - border) {
            return ;
        }
    } else
    if ($(splitterObj).hasClass('splitter_right')) {
        splitterP = e.pageX;
        splitterSize = $(splitterObj).width();
        if (splitterP > off.left + border) {            
            return ;
        }
    } else
    if ($(splitterObj).hasClass('splitter_top')) {
        splitterP = e.pageY;
        splitterSize = $(splitterObj).height();
        if (splitterP < off.top + splitterSize - border) {
            return ;
        }
    } else
    if ($(splitterObj).hasClass('splitter_bottom')) {
        splitterP = e.pageY;
        splitterSize = $(splitterObj).height();
        if (splitterP > off.top + border) {
            return ;
        }
    } else return ;

    stop_mouse_events(e);    

    $('#splitter_bg').css('cursor', $(splitterObj).css('cursor'));
    $('#splitter_bg').mousemove(move_splitter_drag);
    $('#splitter_bg').mouseup(stop_splitter_drag);    
    $('#splitter_bg').css('display', 'block');    
}

function move_splitter_drag(e) {
    var minSize = 100;
    if ($(splitterObj).hasClass('splitter_left')) {
        var w = splitterSize - (splitterP - e.pageX);
        if (w < minSize) w = minSize;
        $(splitterObj).width(w);
    } else
    if ($(splitterObj).hasClass('splitter_right')) {
        var w = splitterSize + (splitterP - e.pageX);
        if (w < minSize) w = minSize;
        $(splitterObj).width(w);
    } else
    if ($(splitterObj).hasClass('splitter_top')) {
        var w = splitterSize - (splitterP - e.pageY);
        if (w < minSize) w = minSize;
        $(splitterObj).height(w);
    } else
    if ($(splitterObj).hasClass('splitter_bottom')) {
        var w = splitterSize + (splitterP - e.pageY);
        if (w < minSize) w = minSize;
        $(splitterObj).height(w);
    }

    //stop_mouse_events(e);
    return false;
}

function stop_splitter_drag(sender) {
    var onAfterDrag = $(splitterObj).attr('onAfterDrag');
    $('#splitter_bg').css('display', 'none');
    if (onAfterDrag)
        eval(onAfterDrag);
        
    //stop_mouse_events(e);
    return false;
}

// -------------------------------------------------
