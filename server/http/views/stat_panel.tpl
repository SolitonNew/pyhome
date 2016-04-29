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
        $('#stat_panel_@ID@_img').attr({src:'page5?FORM_QUERY=panel_img&start=' + stat_panel_start + '&width=' + w + '&height=' + h + '&range=' + r + '&panel_h=' + p_h + '&key=@ID@&rnd=' + Math.random()}).one('load', function () {
            $('#stat_panel_@ID@_img').css('left', '0px');
        });

        var label = $('#stat_refresh_label');

        if (r == '-12 hour') {
            label.html('Автообновление каждые 30 сек.');
        } else {
            label.html('');
        }
    }

    function stat_panel_@ID@_dialog() {
        show_window('stat_panel_dialog?key=@ID@');
    }

    var stat_panel_@ID@_scroll_left = false;
    function stat_panel_@ID@_down(event) {
        event.preventDefault();
        var img = $('#stat_panel_@ID@_img');
        stat_panel_@ID@_scroll_left = event.pageX;
    }

    function stat_panel_@ID@_move(event) {
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

    $(document).ready(function () {
        stat_panel_@ID@_refresh();/*drop if append*/
        window.addEventListener('layoutResize', function (event) {
            stat_panel_@ID@_resize();
        });

        stat_panels_ids.push(@ID@);
    });
    
</script>

<div id="stat_panel_@ID@" class="splitter_top" style="height:@HEIGHT@px;">
    <table width="100%" height="100%" cellpadding="5" cellspacing="0" style="cursor:default;">
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
                <img id="stat_panel_@ID@_img" style="position:absolute;width:100%;height:100%;display:none;"
                    onMouseDown="stat_panel_@ID@_down(event)"
                    onMouseMove="stat_panel_@ID@_move(event)"
                    onMouseUp="stat_panel_@ID@_up(event)"
                    onMouseOut="stat_panel_@ID@_up(event)">
            </div>
        </td>
    <tr>
    </table>
</div>
