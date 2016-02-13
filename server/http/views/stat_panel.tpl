<script type="text/JavaScript">
    function stat_panel_@ID@_refresh() {
        var w = $('#stat_panel_@ID@_img').width();
        var h = $('#stat_panel_@ID@_img').height();
        var p_h = $('#stat_panel_@ID@').height();
        var r = $('#stat_panel_@ID@_range').prop('value');
        $('#stat_panel_@ID@_img').attr({src:'page5?FORM_QUERY=panel_img&width=' + w + '&height=' + h + '&range=' + r + '&panel_h=' + p_h + '&key=@ID@&rnd=' + Math.random()});
    }

    function stat_panel_@ID@_dialog() {
        show_window('stat_panel_dialog?key=@ID@');
    }

    $(document).ready(function () {
        stat_panel_@ID@_refresh();
    });
</script>

<div id="stat_panel_@ID@" class="splitter_top" style="height:@HEIGHT@px;" onAfterDrag="stat_panel_@ID@_refresh()">
    <table width="100%" height="100%" cellpadding="5" cellspacing="0" style="cursor:default;">
    <tr>
        <td id="stat_panel_@ID@_label">
           @LABEL@ 
        </td>
        <td align="right">
            <select id="stat_panel_@ID@_range" onChange="stat_panel_@ID@_refresh()">
                <option value="-12 hour">12 часов</option>
                <option selected value="-1 day">1 день</option>
                <option value="-3 day">3 дня</option>
                <option value="-7 day">1 неделя</option>
                <option value="-14 day">2 недели</option>
                <option value="-30 day">1 месяц</option>
            </select>
            <button onClick="stat_panel_@ID@_refresh();">Обновить</button>
            <button onClick="stat_panel_@ID@_dialog();">Свойства панели...</button>
            <button onClick="del_stat_panel(@ID@);">Удалить</button>
        </td>
    </tr>
    <tr>
        <td style="position:relative;" colspan="2" height="100%">
            <div style="position:absolute;left:0px;top:0px;width:100%;height:100%;overflow:hidden;">
                <img id="stat_panel_@ID@_img" style="position:absolute;width:100%;height:100%;">
            </div>
        </td>
    <tr>
    </table>
</div>
