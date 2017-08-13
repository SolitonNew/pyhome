<script type="text/javascript">
    var comp_size = 80;

    function CONSOLE_DESIGN_refresh() {
        var key = _CONSOLE_LIST_selected_key;
        if (key) {
            $.ajax({url:'page4?FORM_QUERY=DESIGN&key=' + key}).done(function(data) {
                $('#CONSOLE_DESIGN').html(data);
            });
        }        
    }

    $(document).ready(function () {
        use_splitters();
        
        window.addEventListener('CONSOLE_LIST_selected', function (event) {
            CONSOLE_DESIGN_refresh();
        });
    });

    function edit_console(key) {
        $.ajax({url:'page4?FORM_QUERY=show_console&key=' + key}).done(function (data) {
            if (data == "OK")
                CONSOLE_LIST_refresh();
            else
                alert(data);
        });
    }

    function console_settings(key) {        
        show_window('console_edit_dialog?key=' + key);
    }

    var drag_comp_key = false;
    var is_move_comp = false;

    function start_comp_drag(event, key, label, w, h) {
        var sc = '<div id="comp_container">' + label + '</div>';
        var bg = $('body').append('<div id="drag_background" style="position:absolute;left:0px;top:0px;width:100%;height:100%;cursor:default;" onMouseUp="end_comp_drag(event);" onMouseMove="update_comp_position(event);">' + sc + '</div>');
        update_comp_position(event);
        drag_comp_key = key;
            
        if (w) $('#comp_container').width(w);
        else $('#comp_container').width(comp_size);
            
        if (h) $('#comp_container').height(h);
        else $('#comp_container').height(comp_size);
    }

    var selected_comp = false;

    function update_comp_position(event) {
        var cell = find_comp_cell_at(event.clientX, event.clientY);
        if (cell) {
            $('.comp_hover').removeClass('comp_hover');
            $(cell).addClass('comp_hover');
            selected_comp = cell;
        } else {
            $('.comp_hover').removeClass('comp_hover');
            selected_comp = false;
        }
        
        var comp = $('#comp_container');
        wh = comp_size / 2;
        comp.css('left', (event.clientX - wh) + 'px');
        comp.css('top', (event.clientY - wh) + 'px');        
    }

    function find_comp_cell_at(x, y) {
        for (var o = 0; o < 2; o++) {
            for (var r = 0; r < 15; r++) {
                for (var c = 0; c < 15; c++) {
                    var cell = $('#comp_' + o + '_' + r + '_' + c);
                    if (cell) {
                        var pos = cell.offset();
                        if (pos) {
                            if ((x > pos.left) && (y > pos.top) &&
                                (x < pos.left + cell.width()) && (y < pos.top + cell.height()))
                                return cell;
                        }
                    }
                }
            }
        }
        return false;
    }

    function end_comp_drag(event) {        
        if (selected_comp) {
            var v = selected_comp.attr('id').split('_');
            var key = drag_comp_key;
            var row = v[2];
            var col = v[3];
            var cons = _CONSOLE_LIST_selected_key;
            var orient = v[1];
            var q = 'insert_comp';
            if (is_move_comp)
                q = 'move_comp';
            var isCopy = '0';
            if (event.ctrlKey)
                isCopy = '1';
            $.ajax('page4?FORM_QUERY=' + q + '&var=' + key + '&row=' + row + '&col=' + col + '&console=' + cons + '&orientation=' + orient + '&copy=' + isCopy).done(function(data) {
                $('#drag_background').remove();
                CONSOLE_DESIGN_refresh();
                if (data != "OK")
                    alert(data);
            });            
        } else {
            $('#drag_background').remove();
            if (is_move_comp) {
                var key = drag_comp_key;
                $.ajax('comp_edit_dialog?FORM_QUERY=delete&KEY=' + key).done(function(data) {
                    CONSOLE_DESIGN_refresh();
                    if (data != "OK")
                        alert(data);
                });            
            }
        }
        comp_mouse_x = false;
        comp_mouse_y = false;
        is_move_comp = false;
    }

    var comp_mouse_x = false;
    var comp_mouse_y = false;

    function comp_mouse_down(event, key) {
        comp_mouse_x = event.clientX;
        comp_mouse_y = event.clientY;
    }

    function comp_mouse_move(obj, event, key, label) {
        if (!comp_mouse_x || !comp_mouse_y) return false;
        
        if (Math.abs(comp_mouse_x - event.clientX) > 10 ||
            Math.abs(comp_mouse_y - event.clientY) > 10) {
            is_move_comp = true;
            var l = $(obj).html();
            var w = $(obj).width();            
            var h = $(obj).height();
            start_comp_drag(event, key, l, w, h);
        }
    }

    function comp_mouse_up(event, key) {
        comp_mouse_x = false;
        comp_mouse_y = false;
        show_window('comp_edit_dialog?KEY=' + key);
    }
    
</script>

<style type="text/css">
    #comp_container {
        position:absolute;
        background-color:#777777;
        opacity:0.5;
        text-align: center;
        color:#ffffff;
    }

    div.CONSOLE_PALETTE_cell {
        width:80px;
        height:80px;
        background-color:#eeeeee;
        display:inline-block;
        margin-left:1px;
        margin-top:1px;
        text-align:center;
        padding: 0px;
        overflow: hidden;
        line-height:0.9;
        float:left;
    }

    div.comp_item {
        position:absolute;
        background-color:#999999;
        text-align:center;
        color:#ffffff;
    }

    div.comp_hover {
        opacity:0.5;
    }

    .design_table tr td div {
        width:80px;
        height:80px;
        background-color: #dddddd;
    }
</style>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td colspan="3" style="position:relative;">
        <div class="toolbar">
            <button onClick="console_settings(-1);">Создать новую консоль...</button>
            <button onClick="console_settings(_CONSOLE_LIST_selected_key);">Свойства выбраной консоли...</button>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;height:100%;">
        <div class="splitter_left" style="width:200px;">
            @CONSOLE_LIST@
        </div>
    </td>
    <td align="center" style="position:relative;width:100%;height:100%;background-color:#efefef;">        
        <div id="CONSOLE_DESIGN" style="position:absolute;left:0px;top:0px;width:100%;height:100%;overflow:auto;">
        </div>
    </td>
    <td>
        <div id="CONSOLE_PALETTE" class="splitter_right" style="width:260px;">            
            @CONSOLE_PALETTE@
        </div>
    </td>
</tr>
</table>
