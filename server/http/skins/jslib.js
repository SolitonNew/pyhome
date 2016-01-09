function init_page() {
    refresh_variables();
    refresh_change_log();

    $('div.splitter_right').mousedown(start_splitter_drag);
    $('div.splitter_left').mousedown(start_splitter_drag);
    $('div.splitter_bottom').mousedown(start_splitter_drag);
    $('div.splitter_top').mousedown(start_splitter_drag);
}



// -------------------------------------------------

var splitterObj = False;
var splitterP = 0;
var splitterSize = 0;

function start_splitter_drag(e) {
    off = $(e.currentTarget).offset();
    
    splitterObj = e.currentTarget;    

    if ($(splitterObj).hasClass('splitter_left')) {
        splitterP = e.pageX;
        splitterSize = $(splitterObj).width();
        if (splitterP < off.left + splitterSize - 8)
            return False;
    } else
    if ($(splitterObj).hasClass('splitter_right')) {
        splitterP = e.pageX;
        splitterSize = $(splitterObj).width();
        if (splitterP > off.left + 8)
            return False;        
    } else
    if ($(splitterObj).hasClass('splitter_top')) {
        splitterP = e.pageY;
        splitterSize = $(splitterObj).height();
        if (splitterP < off.top + splitterSize - 8)
            return False;
    } else
    if ($(splitterObj).hasClass('splitter_bottom')) {
        splitterP = e.pageY;
        splitterSize = $(splitterObj).height();
        if (splitterP > off.top + 8)
            return False;                
    }

    $('#splitter_bg').css('cursor', $(splitterObj).css('cursor'));
    $('#splitter_bg').mousemove(move_splitter_drag);
    $('#splitter_bg').mouseup(stop_splitter_drag);    
    $('#splitter_bg').css('display', 'block');    
}

function move_splitter_drag(e) {
    if ($(splitterObj).hasClass('splitter_left')) {
        var w = splitterSize + (splitterP - e.pageX);
        $(splitterObj).width(w);
    } else
    if ($(splitterObj).hasClass('splitter_right')) {
        var w = splitterSize + (splitterP - e.pageX);
        $(splitterObj).width(w);
    } else
    if ($(splitterObj).hasClass('splitter_top')) {
        var w = splitterSize + (splitterP - e.pageY);
        $(splitterObj).height(w);
    } else
    if ($(splitterObj).hasClass('splitter_bottom')) {
        var w = splitterSize + (splitterP - e.pageY);
        $(splitterObj).height(w);
    }
}

function stop_splitter_drag(sender) {
    $('#splitter_bg').css('display', 'none');
}

// -------------------------------------------------

function refresh_variables() {
    $.ajax({url:'variable_data', success:refresh_variables_handler});
    setTimeout(refresh_variables, 1000);
}

function refresh_variables_handler(data) {
    $("#grid_data").html(data);
}

function refresh_change_log() {
    $.ajax({url:'change_log', success:refresh_change_log_handler});
    setTimeout(refresh_change_log, 1000);
}

function refresh_change_log_handler(data) {
    $("#log_container").html(data);
}

function set_variable_value(key, val) {
    $.ajax({url:'set_variable_value?id=' + key + '&val=' + val});
}

function show_window(url) {
    //$('#popup_window').css('display', 'block');
    $('#popup_window_content').html('');
    $.ajax({url:url, success:show_window_handler});
}

function show_window_handler(data) {
    $('#popup_window_content').html(data);
    $('#popup_window').fadeIn(400);
}

function hide_window() {
    $('#popup_window').fadeOut(400);
}

function controllers_dialog() {
    show_window('dialog_controllers.html');
}

function variable_settings(key) {
    show_window('variable_settings?form=view&key=' + key);
}

function utilites_dialog() {
    show_window('system_utilites?form=view');
}
