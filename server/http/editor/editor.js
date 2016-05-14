var editor_char_w = 8.25;
var editor_char_h = 23;
var editor_focused = false;
var editor_selected_line = false;
var editor_selected_line_index = -1;
var editor_selected_char = 0;
var editor_lines = [];
var editor_selected_line_start = 0;
var editor_selected_char_start = 0;
var editor_mouse_down = false;
var editor_shift = false;
var editor_selected = false;
var editor_clip_temp = '';

var editor_keys = ['def',
            'class',
            'if',
            'else',
            'for',
            'in',
            'range',
            'len',
            'hash',
            'max',
            'min',
            'try',
            'except',
            'print'];

var editor_spec_chars = [' ', ',', '.', '(', ')', '[', ']', ':', ';'];

$(document).ready(function() {
    var s = '';
    for (var i = 0; i < 100; i++) s += 'W';
    $('#editor_etalon_char').html(s);    
    editor_char_w = $('#editor_etalon_char').innerWidth() / 100;
    window.editor_content = $('#editor_content');
    window.editor_area = $('#editor_area');
    window.editor_content_selection = $('#editor_content_selection');
    
    editor_insert_line(0, '', 0);
    editor_time_cursor();

    editor_area.focusin(function (event) {
        editor_focused = true;
        $('#editor_cursor').css('display', 'block');
    });

    editor_area.focusout(function (event) {
        editor_focused = false;
        $('#editor_cursor').css('display', 'none');
    });

    editor_area.keydown(function (event) {
        var s = editor_lines[editor_selected_line_index];
        //alert(event.which + '');
        //console.log(event);
        switch (event.which) {
            case 16: // Shift
                editor_shift = true;
                editor_selected_line_start = editor_selected_line_index;
                editor_selected_char_start = editor_selected_char;
                break;
            case 38: // Up
                if (event.shiftKey && !editor_selected)
                    editor_start_sel();
                editor_select_line(editor_selected_line_index - 1);
                return false;
            case 40: // Down
                if (event.shiftKey && !editor_selected)
                    editor_start_sel();
                editor_select_line(editor_selected_line_index + 1);
                return false;
            case 37: // Left
                if (event.shiftKey && !editor_selected)
                    editor_start_sel();
                editor_selected_char--;
                if (editor_selected_char < 0) {
                    if (editor_selected_line_index > 0) {
                        editor_selected_char = editor_lines[editor_selected_line_index - 1].length;
                        editor_select_line(editor_selected_line_index - 1);
                    } else {
                        editor_selected_char = 0;
                    }
                } else {
                    editor_update_cursor();
                }
                return false;
            case 39: // Right
                if (event.shiftKey && !editor_selected)
                    editor_start_sel();
                editor_selected_char++;
                if (editor_selected_char > s.length) {
                    if (editor_selected_line_index < editor_lines.length - 1) {
                        editor_selected_char = 0;
                        editor_select_line(editor_selected_line_index + 1);
                    } else {
                        editor_selected_char = s.length;
                    }
                } else {
                    editor_update_cursor();
                }
                return false;
            case 13: // Enter
                var t = s.substring(editor_selected_char);
                s = s.substring(0, editor_selected_char);
                editor_lines[editor_selected_line_index] = s;
                editor_update_line();
                var tab = '';
                if (s.length > 0) {
                    for (var i = 0; i < s.length; i++) {
                        if (s[i] != ' ')
                            break;
                        tab += ' ';
                    }                    
                }
                if (s[s.length - 1] == ':')
                    tab += '    ';
                t = tab + t;
                editor_insert_line(editor_selected_line_index, t, tab.length);
                editor_update_line();                
                
                return false;
            case 46: // Del
                if (editor_selected_char < s.length) {
                    s = s.substring(0, editor_selected_char) +
                        s.substring(editor_selected_char + 1);
                    editor_set_line_text(s);
                } else {
                    if (editor_selected_line_index < editor_lines.length - 1) {
                        var c = editor_selected_char;
                        editor_selected_line_index++;
                        var t = editor_lines[editor_selected_line_index];
                        editor_del_line();
                        editor_selected_char = c;
                        editor_select_line(editor_selected_line_index - 1);
                        editor_lines[editor_selected_line_index] = s + t;
                        editor_update_line();
                    }
                }
                return false;
            case 9: // Tab
                editor_paste('    ');
                return false;
            case 8: // Back
                if (editor_selected_char > 0) {
                    s = s.substring(0, editor_selected_char - 1) +
                        s.substring(editor_selected_char);
                    editor_selected_char--;
                    editor_set_line_text(s);
                } else {
                    if (editor_selected_line_index > 0) {
                        editor_del_line();
                        editor_selected_char = editor_lines[editor_selected_line_index].length;
                        editor_lines[editor_selected_line_index] += s;
                        editor_update_line();
                        editor_update_cursor();
                    }
                }
                return false;
            case 36: // Home
                if (event.shiftKey && !editor_selected)
                    editor_start_sel();
                editor_selected_char = 0;
                editor_update_cursor();
                return false;
            case 35: // End
                if (event.shiftKey && !editor_selected)
                    editor_start_sel();
                editor_selected_char = editor_lines[editor_selected_line_index].length;
                editor_update_cursor();
                return false;
        }
    });

    editor_area.keyup(function (event) {
        switch (event.which) {
            case 16: // Shift
                editor_shift = false;
                break;
            case 86:
                if (event.ctrlKey)
                    editor_paste(editor_area.val());
                break;
        }

        if (event.shiftKey == false) {
            editor_selected = false;
        }
        
        editor_area.val('');
    });

    editor_area.keypress(function (event) {
        var s = editor_lines[editor_selected_line_index];        
        s = s.substring(0, editor_selected_char) +
            String.fromCharCode(event.keyCode) +
            s.substring(editor_selected_char);
            editor_selected_char++;                
        editor_lines[editor_selected_line_index] = s;
        editor_update_line();
    });

    $('#editor_mouse').mousedown(function (event) {
        var w = $('#editor_nums').width();
        editor_mouse_down = true;
        editor_selected_char = Math.round((event.offsetX - 5 - w) / editor_char_w);
        if (editor_selected_char < 0)
            editor_selected_char = 0;
        editor_select_line(Math.floor(event.offsetY / 23));
        editor_start_sel();
        $('#editor_cursor').css('display', 'block');
        editor_area.focus();
        editor_update_selection();
        return false;
    });

    $('#editor_mouse').mousemove(function (event) {
        if (editor_mouse_down) {
            var w = $('#editor_nums').width();
            editor_selected_char = Math.round((event.offsetX - 5 - w) / editor_char_w);
            if (editor_selected_char < 0)
                editor_selected_char = 0;
            editor_select_line(Math.floor(event.offsetY / 23));
            $('#editor_cursor').css('display', 'block');
            //editor_area.focus();
            editor_update_selection();
            return false;
        }
    });

    $('#editor_mouse').mouseup(function (event) {
        editor_selected = false;
        editor_mouse_down = false;
    });

    $('#editor_mouse').mouseout(function (event) {
        editor_selected = false;
        editor_mouse_down = false;
    });    

    editor_open('for i in range(10):' + String.fromCharCode(13) + '    print("123")');
});

function editor_start_sel() {
    editor_selected_line_start = editor_selected_line_index;
    editor_selected_char_start = editor_selected_char;
    editor_selected = true;
}

function editor_paste(text) {
    var s = editor_lines[editor_selected_line_index];
    s1 = s.substring(0, editor_selected_char);
    s2 = s.substring(editor_selected_char);
    s = s1 + text + s2;
    editor_lines[editor_selected_line_index] = s;
    editor_selected_char += text.length;
    editor_update_line();    
}

function editor_set_line_text(text) {
    if (editor_lines[editor_selected_line_index] != text) {
        editor_lines[editor_selected_line_index] = text;
        editor_update_line();
    }
}

function editor_update_line() {
    if (editor_selected_line) {
        var s = editor_lines[editor_selected_line_index];        
        // Подсветка синтаксиса
        var a = [''];
        for (var i = 0; i < s.length; i++) {
            if (editor_spec_chars.indexOf(s.charAt(i)) > -1) {
                a.push(s.charAt(i));
                a.push('');
            } else {
                a[a.length - 1] += s.charAt(i);
            }
        }

        //console.log(a);
        
        for (var i = 0; i < a.length; i++) {
            if (a[i] == ' ') {
                a[i] = '&nbsp;';
            } else
            if (editor_keys.indexOf(a[i]) > -1) {
                a[i] = '<span style="color:#0000ff">' + a[i] + '</span>';
            }
        }
        s = a.join('');
        // -----------------------------        

        editor_selected_line.html(s);
    }
    editor_update_cursor();
}

function editor_replace_str(str, from, to) {
    while (true) {
        var len = str.length;
        str = str.replace(from, to);
        if (len == str.length)
            break;
    }
    return str;
}

function editor_insert_line(index, text, off) {    
    var row = $('<div class="editor_line"></div>');
    
    if (index < editor_lines.length - 1) {
        row.insertAfter(editor_selected_line);
        editor_lines.splice(index + 1, 0, text);
    } else {
        //index--;
        editor_content.append(row);
        editor_lines.push(text);
    }
    
    editor_recalc_nums();    
    editor_select_line(index + 1);
    editor_selected_char = off;    
    editor_update_cursor();
}

function editor_del_line() {
    index = editor_selected_line_index;
    if (index < 0 || index > editor_lines.length - 1 || editor_lines.length < 2)
        return ;    
    editor_lines.splice(index, 1);
    editor_selected_line.remove();
    editor_selected_line_index--;
    editor_select_line(editor_selected_line_index);
    editor_recalc_nums();    
}

function editor_recalc_nums() {
    var s = '';
    for (var i = 0; i < editor_lines.length; i++) {
        s += '<div class="editor_line_num">' + (i + 1) + '</div>';
    }
    $('#editor_nums').html(s);
}

function editor_time_cursor() {    
    if (editor_focused) {        
        var cur = $('#editor_cursor');
        if (cur.css('display') == 'block') {
            cur.css('display', 'none');
        } else {
        cur.css('display', 'block');
        }
    }
    setTimeout(editor_time_cursor, 600);
}

function editor_update_cursor() {
    if (editor_focused) {
        var cur = $('#editor_cursor');
        cur.css('left', (editor_selected_char * editor_char_w + 5) + 'px');
        cur.css('top', (editor_selected_line_index * editor_char_h) + 'px');
        cur.css('display', 'block');
        editor_update_selection();
    }
}

function editor_select_line(index) {
    if (index < 0) {
        index = 0;
        editor_selected_char = 0;
    }

    if (index > editor_lines.length - 1) {
        index = editor_lines.length - 1;
        editor_selected_char = editor_lines[index].length;
    }
        
    if (editor_selected_line)
        editor_selected_line.removeClass("editor_line_sel");
    editor_selected_line_index = index;
    editor_selected_line = $('#editor_content div:eq(' + index + ')');
    if (editor_selected_char > editor_lines[editor_selected_line_index].length)
        editor_selected_char = editor_lines[editor_selected_line_index].length;
    editor_update_cursor();

    editor_selected_line.addClass("editor_line_sel");
}

function editor_gen_select_row(line, c_min, c_max) {
    var c_w = (c_max - c_min) * editor_char_w;    
    var c_x = c_min * editor_char_w + 5;    
    var l = line * 23;
    editor_clip_temp += editor_lines[line].substr(c_min, c_max - c_min) + '\n';
    return '<div class="editor_selection" style="left:' + c_x + 'px;top:' + l + 'px;width:' + c_w +'px"></div>';    
}

function editor_update_selection() {
    editor_content_selection.html('');
    editor_clip_temp = '';

    if (!editor_selected) return ;
    
    if (editor_selected_line_start == editor_selected_line_index) {
        var x1 = Math.min(editor_selected_char_start, editor_selected_char);
        var x2 = Math.max(editor_selected_char_start, editor_selected_char);
        editor_content_selection.html(editor_gen_select_row(editor_selected_line_index, x1, x2));
    } else
    if (editor_selected_line_start < editor_selected_line_index) {
        var s = editor_gen_select_row(editor_selected_line_start,
                                      editor_selected_char_start,
                                      editor_lines[editor_selected_line_start].length + 1);
        for (var i = editor_selected_line_start + 1; i < editor_selected_line_index; i++) {
            var z = editor_lines[i] + ' ';
            s += editor_gen_select_row(i, 0, z.length);
        }
        s += editor_gen_select_row(editor_selected_line_index,
                                   0, editor_selected_char);
        editor_content_selection.html(s);
    } else {
        var s = editor_gen_select_row(editor_selected_line_index,
                                      editor_selected_char,
                                      editor_lines[editor_selected_line_index].length + 1);
        for (var i = editor_selected_line_index + 1; i < editor_selected_line_start; i++) {
            var z = editor_lines[i] + ' ';
            s += editor_gen_select_row(i, 0, z.length);
        }
        s += editor_gen_select_row(editor_selected_line_start,
                                   0, editor_selected_char_start);
        editor_content_selection.html(s);
    }

    editor_area.val(editor_clip_temp);
    editor_area.select();
}

function editor_open(text) {
    var a = text.split(String.fromCharCode(13));
    editor_selected_line_index = -1;
    editor_content.html('');
    editor_lines = [];
    for (var i = 0; i < a.length; i++) {        
        editor_insert_line(i - 1, a[i], 0);
        editor_update_line();
    }
    editor_select_line(0);
}

function editor_save() {
    return editor_lines.join('\n');
}

function editor_paste(text) {
    editor_clear();
    alert(text);
}

function editor_clear() {
    
}
