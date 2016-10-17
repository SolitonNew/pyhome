<script type="text/JavaScript">
    var stat_panel_@ID@_width = 0;
    var stat_panel_@ID@_height = 0;

    function stat_panel_@ID@_resize() {
        var o = document.getElementById('stat_panel_@ID@');
        if (o) {
            if (o.clientWidth == 0) return;
        
            var w = $('#stat_panel_@ID@_img').width();
            var h = $('#stat_panel_@ID@_img').height();
            if ((stat_panel_@ID@_width != w) || (stat_panel_@ID@_height != h))
                stat_panel_@ID@_refresh();
        }
    }

    function stat_panel_@ID@_refresh() {
        $('#stat_panel_@ID@_img').css('display', 'block');
        $('#stat_panel_@ID@_img').css('height', '100%');
        var w = $('#stat_panel_@ID@_img').width();           
        var h = $('#stat_panel_@ID@_img').height();
        stat_panel_@ID@_width = w;
        stat_panel_@ID@_height = h;        
        var p_h = $('#stat_panel_@ID@').height();
        var r = $('#stat_panel_range').prop('value');
        $('#stat_panel_@ID@_img').attr({src:'page5_1?FORM_QUERY=panel_img&start=' + stat_panel_start + '&width=' + w + '&height=' + h + '&range=' + r + '&panel_h=' + p_h + '&key=@ID@&rnd=' + Math.random()}).one('load', function () {
            $('#stat_panel_@ID@_img').css('left', '0px');
            stat_panel_@ID@_cur_update($('#stat_panel_cursor_@ID@').css('left').replace('px', ''), false);
        });

        var label = $('#stat_refresh_label');

        if (r == '-6 hour') {
            label.html('Автообновление каждые 30 сек.');
        } else {
            label.html('');
        }

        var w = $('#stat_panel_@ID@_img').width();
        $('#stat_panel_center_@ID@').css('left', ((w - 25) / 2) + 27 + 'px');
    }

    function stat_panel_@ID@_dialog() {
        show_window('stat_panel_dialog?key=@ID@');
    }

    var stat_panel_@ID@_scroll_left = false;
    function stat_panel_@ID@_down(event) {
        event.preventDefault();

        stat_panel_@ID@_cur_update(event.pageX, true);
        
        var img = $('#stat_panel_@ID@_img');
        stat_panel_@ID@_scroll_left = event.pageX;
    }

    function stat_panel_@ID@_move(event) {
        stat_panel_@ID@_cur_update(event.pageX, true);
        
        if (stat_panel_@ID@_scroll_left == false)
            return ;        
        for (var i = 0; i < stat_panels_ids.length; i++) {
            var img = $('#stat_panel_' + stat_panels_ids[i] + '_img');
            if (img)
                img.css('left', (event.pageX - stat_panel_@ID@_scroll_left) + 'px');
        }
    }    

    function stat_panel_@ID@_up(event) {
        if (stat_panel_@ID@_scroll_left == false)
            return ;
        var img = $('#stat_panel_@ID@_img');
        var dx = (img.width() - 50) / (event.pageX - stat_panel_@ID@_scroll_left);
        stat_panel_start -= Math.ceil(date_intervals[stat_panel_range.selectedIndex] / dx * 3600);
        refresh_stat_panels();
        stat_panel_@ID@_scroll_left = false;
    }

    function stat_panel_@ID@_cur_update(x, isStart) {
        var center_x = $('#stat_panel_center_@ID@').css('left').replace('px', '');
        var img = $('#stat_panel_@ID@_img');
        var dx = (img.width() - 50) / (center_x - x);
        var calc_x = stat_panel_start - Math.ceil(date_intervals[stat_panel_range.selectedIndex] / dx * 3600);

        var d = new Date();
        d.setTime(calc_x * 1000);

        var h = d.getHours();
        if (h < 10)
            h = '0' + h;
        else
            h = h + '';
        var m = d.getMinutes();
        if (m < 10)
            m = '0' + m;
        else
            m = m + '';
        
        $('#stat_panel_@ID@_cur_time').html(h + ':' + m);
        
        var img = $('#stat_panel_@ID@_img');
        var cur = $('#stat_panel_cursor_@ID@');
        if (x < 40 || x > img.width() - 10 || img.css('left') != '0px')
            cur.css('display', 'none');
        else {            
            cur.css('display', 'block');
        }
        
        cur.css('left', x + 'px');

        if (isStart) {
            for (var i = 0; i < stat_panels_ids.length; i++) {
                if (stat_panels_ids[i] != @ID@)
                    eval('stat_panel_' + stat_panels_ids[i] + '_cur_update(' + x + ', false)');
            }
        }
    }

    var stat_panel_@ID@_cur_load_x = -100000;

    function stat_panel_@ID@_cur_load() {
        var cur_x = $('#stat_panel_cursor_@ID@').css('left').replace('px', '');
        var center_x = $('#stat_panel_center_@ID@').css('left').replace('px', '');
        var img = $('#stat_panel_@ID@_img');

        var dx = (img.width() - 50) / (center_x - cur_x);
        var calc_x = stat_panel_start - Math.ceil(date_intervals[stat_panel_range.selectedIndex] / dx * 3600);
        
        if (stat_panel_@ID@_cur_load_x != calc_x) {
            stat_panel_@ID@_cur_load_x = calc_x;
            $.ajax({url:'page5_1?FORM_QUERY=panel_cursor&pos=' + calc_x + '&key=@ID@&rnd=' + Math.random()}).done(function (data) {
                var vals = data.split(',');
                for (var i = 0; i < 4; i++) {
                    $('#stat_panel_@ID@_val_' + (i + 1)).html(vals[i]);
                }
            });
        }

        setTimeout(stat_panel_@ID@_cur_load, 1000);
    }    

    $(document).ready(function () {
        stat_panel_@ID@_refresh();/*drop if append*/
        window.addEventListener('layoutResize', function (event) {
            stat_panel_@ID@_resize();
        });

        stat_panels_ids.push(@ID@);

        stat_panel_@ID@_cur_load();
    });
    
</script>

<div id="stat_panel_@ID@" class="splitter_top" style="height:@HEIGHT@px;">
    <table width="100%" height="100%" cellpadding="5" cellspacing="0" style="cursor:default;" onMouseDown="return false;">
    <tr>
        <td id="stat_panel_@ID@_label">
           @LABEL@ 
        </td>
        <td align="right">
            <button onClick="stat_panel_@ID@_dialog();">Свойства панели...</button>
            <button onClick="del_stat_panel(@ID@);">Удалить</button>
        </td>
    </tr>
    <tr>
        <td style="position:relative;" colspan="2" height="100%">
            <div style="position:absolute;left:0px;top:0px;width:100%;height:100%;overflow:hidden;">
                <div id="stat_panel_center_@ID@" style="position:absolute;width:1px;height:100%;">
                    <div style="position:relative;width:1px;height:100%;background-color:#ff0000;opacity:0.5;margin-top:-16px;">
                    </div>
                </div>
                <div id="stat_panel_cursor_@ID@" style="position:absolute;height:100%;">
                    <div style="position:relative;width:2px;height:100%;background-color:#0000ff;opacity:0.5;margin-top:-16px;">
                    </div>

                    <div id="stat_panel_@ID@_cur_time" style="position:absolute;left:7px;top:5px;font-weight:bold;"></div>
                </div>
                <img id="stat_panel_@ID@_img" style="position:absolute;width:100%;height:100%;display:none;"
                    onMouseDown="stat_panel_@ID@_down(event)"
                    onMouseMove="stat_panel_@ID@_move(event)"
                    onMouseUp="stat_panel_@ID@_up(event)"
                    onMouseOut="stat_panel_@ID@_up(event)">                
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="2" align="center">
            <table>
            <tr>
                <td id="stat_panel_@ID@_val_1" style="background-color:#ff0000;width:20px;color:#ffffff;text-align:center;padding:2px 5px;"></td>
                <td id="stat_panel_@ID@_label_1">
                    @LABEL_1@
                </td>
                <td width="20"></td>
                <td id="stat_panel_@ID@_val_2" style="background-color:#00A651;width:20px;color:#ffffff;text-align:center;padding:2px 5px;"></td>
                <td id="stat_panel_@ID@_label_2">
                    @LABEL_2@
                </td>
                <td width="20"></td>
                <td id="stat_panel_@ID@_val_3" style="background-color:#0000ff;width:20px;color:#ffffff;text-align:center;padding:2px 5px;"></td>
                <td id="stat_panel_@ID@_label_3">
                    @LABEL_3@
                </td>
                <td width="20"></td>
                <td id="stat_panel_@ID@_val_4" style="background-color:#ff00ff;width:20px;color:#ffffff;text-align:center;padding:2px 5px;"></td>
                <td id="stat_panel_@ID@_label_4">
                    @LABEL_4@
                </td>
            </tr>
            </table>
        </td>
    </tr>
    </table>
</div>
