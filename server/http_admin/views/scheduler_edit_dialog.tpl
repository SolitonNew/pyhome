<script type="text/javascript">

    $('#popup_window_border').width(450);
    $('#popup_window_title').html("Свойства записи расписания");

    function scheduler_settings_change() {        
        switch ($('#SCHEDULER_INTERVAL_TYPE').val()) {
            case '0':
                $('#d_of_t').css('display', 'none');
                break;
            case '1':
                $('#d_of_t').css('display', 'table-row');
                $('#d_of_t_type').html('недели');
                break;
            case '2':
                $('#d_of_t').css('display', 'table-row');
                $('#d_of_t_type').html('месяца');
                break;
            case '3':
                $('#d_of_t').css('display', 'table-row');
                $('#d_of_t_type').html('года');
                break;
        }
    }

    function del_scheduler() {
        alert('CONFIRM: Удалить запись в расписании?', 'yes,no', function (res) {
            if (res == 'yes') {
                $('#FORM_QUERY').val('delete');
                $('#SCHEDULER_SETTINGS').submit();
            }
        });
    }

    function test_scheduler() {
        $('#FORM_QUERY').val('test');
        $("#SCHEDULER_SETTINGS").submit();
    }

    $(document).ready(function() {
        if ($('#SCHEDULER_KEY').val() == '-1')
            $('#del_button').css('display', 'none');
        
        scheduler_settings_change();

        $("#SCHEDULER_SETTINGS").ajaxForm(function(data) {
            if (data == "OK") {                
                if ($('#FORM_QUERY').val() != 'test') {
                    hide_window();
                    SCHEDULER_LIST_refresh();
                }
            } else
                alert(data);

            $('#FORM_QUERY').val('update');
        });
    });
</script>

<form id="SCHEDULER_SETTINGS" action="scheduler_edit_dialog" method="GET">
    <input id="FORM_QUERY" name="FORM_QUERY" type="hidden" value="update">
    <input id="SCHEDULER_KEY" name="SCHEDULER_KEY" type="hidden" value="@KEY@">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>
    <TR>
        <TD valign="top" width="75">Описание:</TD>
        <TD>
            <textarea id="SCHEDULER_COMM" name="SCHEDULER_COMM" style="width:100%;height:60px;">@COMM@</textarea>
        </TD>
    </TR>
    <TR>
        <form id="scheduler_command_form" action="scheduler_edit_dialog" method="GET">
        <TD valign="top">Действие:</TD>
        <TD>
            <textarea id="SCHEDULER_ACTION" name="SCHEDULER_ACTION" style="width:100%;height:60px;">@ACTION@</textarea>
            <p align="right" style="padding:0; margin:0px;">
                <button onClick="test_scheduler();return false;">Тест действия</button>
            <p>
        </TD>
        </form>
    </TR>
    <TR>
        <TD>Повторять:</TD>
        <TD>
            <select id="SCHEDULER_INTERVAL_TYPE" name="SCHEDULER_INTERVAL_TYPE" onChange="scheduler_settings_change()">
                @INTERVAL_TYPE_LIST@
            </select>
        </TD>
    </TR>
    <TR>
        <TD valign="top">Время дня</TD>
        <TD>
            <textarea id="SCHEDULER_INTERVAL_TIME_OF_DAY" name="SCHEDULER_INTERVAL_TIME_OF_DAY" style="width:100%;height:60px;">@INTERVAL_TIME_OF_DAY@</textarea>
        </TD>
    </TR>
    <TR id="d_of_t">
        <TD valign="top">Дни <span id="d_of_t_type"></span></TD>
        <TD>
            <textarea id="SCHEDULER_INTERVAL_DAY_OF_TYPE" name="SCHEDULER_INTERVAL_DAY_OF_TYPE" style="width:100%;height:60px;">@INTERVAL_DAY_OF_TYPE@</textarea>
        </TD>
    </TR>
    <TR>
        <TD align="left" valign="bottom" height="60">
            <button id="del_button" type="button" onClick="del_scheduler();">Удалить</button>
        </TD>    
        <TD align="right" valign="bottom" height="60">
            <button type="submit">Готово</button>
            <button type="button" onClick="hide_window()">Закрыть</button>
        </TD>
    </TR>
    </table>
</form>
