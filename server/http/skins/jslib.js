function init_page() {
    refresh_change_log();
    show_page(1);

    attach_classes_handlers();
}

function attach_classes_handlers() {
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
    var border = 8;
    splitterObj = e.target;        
    off = $(splitterObj).offset();    

    if ($(splitterObj).hasClass('splitter_left')) {
        splitterP = e.pageX;
        splitterSize = $(splitterObj).width();
        if (splitterP < off.left + splitterSize - border)
            return False;
    } else
    if ($(splitterObj).hasClass('splitter_right')) {
        splitterP = e.pageX;
        splitterSize = $(splitterObj).width();
        if (splitterP > off.left + border)
            return False;        
    } else
    if ($(splitterObj).hasClass('splitter_top')) {
        splitterP = e.pageY;
        splitterSize = $(splitterObj).height();
        if (splitterP < off.top + splitterSize - border)
            return False;
    } else
    if ($(splitterObj).hasClass('splitter_bottom')) {
        splitterP = e.pageY;
        splitterSize = $(splitterObj).height();
        if (splitterP > off.top + border)
            return False;                
    }

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
        var w = splitterSize + (splitterP - e.pageY);
        if (w < minSize) w = minSize;
        $(splitterObj).height(w);
    } else
    if ($(splitterObj).hasClass('splitter_bottom')) {
        var w = splitterSize + (splitterP - e.pageY);
        if (w < minSize) w = minSize;
        $(splitterObj).height(w);
    }
}

function stop_splitter_drag(sender) {
    $('#splitter_bg').css('display', 'none');
}

// -------------------------------------------------

function refresh_change_log() {
    $.ajax({url:'change_log', success:refresh_change_log_handler});
    setTimeout(refresh_change_log, 1000);
}

function refresh_change_log_handler(data) {
    $("#log_container").html(data);
}

// -------------------------------------------------

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

// -------------------------------------------------

function show_page(index) {
    for (var i = 1; i < 20; i++) {
        o = $('#page_' + i)
        if (o) {
            o.hide();
            $('#tab_' + i).css('background-color', '#fff');
            $('#tab_' + i).css('color', '#000');
        }
    }

    o = $('#page_' + index).show();
    
    $('#tab_' + index).css('background-color', '#aaa');
    $('#tab_' + index).css('color', '#fff');

    if (o.html() == '') 
        $.ajax({url:o.attr("url")}).done(function (data) {o.html(data); attach_classes_handlers();});
}

// -------------------------------------------------

function variable_settings(key) {
    show_window('variable_settings?form=view&key=' + key);
}

function utilites_dialog() {
    show_window('system_utilites?form=view');
}
