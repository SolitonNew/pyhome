<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();
        stat_panel_autorefresh();        
    });

    function stat_panel_autorefresh() {
        var r = $('#stat_panel_range').prop('value');
        if (r == '-12 hour') {
            refresh_stat_panels();
        }
        setTimeout(stat_panel_autorefresh, 30000);
    }


    var date_intervals = [12, 24, 24 * 3, 24 * 7, 24 * 14, 24 * 30];
    var stat_panel_start = @START_TIME@;
    var stat_panels = [];
    var stat_panels_ids = [];

    function refresh_stat_panels() {
        for (var i = 0; i < stat_panels_ids.length; i++) {
            var st_refr = 'stat_panel_' + stat_panels_ids[i] + '_refresh';
            if (eval('typeof (' + st_refr + ')') == 'function')
                eval(st_refr + '()');
        }
    }

    function append_stat_panel() {
        $.ajax({url:'page5?FORM_QUERY=append_panel'}).done(function (data) {            
            var i1 = data.indexOf('stat_panel_');
            var i2 = data.indexOf('_', i1 + 11);
            var refresh_str = data.substr(i1, i2 - i1) + '_refresh()';
            data = data.replace(refresh_str + ';/*drop if append*/', '');
            var p = $(data);            
            p.css('display', 'none');
            $('#stat_panels').append(p);
            p.show(300, function () {eval(refresh_str)});
            use_splitters();            
        });
    }

    function del_stat_panel(key) {
        $.ajax({url:'page5?FORM_QUERY=del_panel&key=' + key}).done(function (data) {
            if (data == 'OK') {
                var p = $('#stat_panel_' + key);
                p.hide(300, function () {p.remove()});
            } else
                alert(data);
        });
    }    
    

</script>

<style type="text/css">
    #STATISTIC_PANELS_data td:hover {
        background-color:#ffffff;
    }
</style>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td style="position:relative;">
        <div class="toolbar">&nbsp;&nbsp;
            <select id="stat_panel_range" onChange="refresh_stat_panels()">
                <option value="-12 hour">12 часов</option>
                <option selected value="-1 day">1 день</option>
                <option value="-3 day">3 дня</option>
                <option value="-7 day">1 неделя</option>
                <option value="-14 day">2 недели</option>
                <option value="-30 day">1 месяц</option>
            </select>
            <button onClick="refresh_stat_panels();">Обновить</button>
            <span id="stat_refresh_label"></span>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;width:100%;height:100%;" valign="top">
        <div style="position:absolute;width:100%;height:100%;overflow:hidden;overflow-y:auto;">
            <div id="stat_panels">
            @STATISTIC_PANELS@
            </div>
            <p align="center" style="height:50px;">
                <button onClick="append_stat_panel();">Добавить новую панель</button>
            </p>
        </div>
    </td>
</tr>
</table>
