<script type="text/javascript">

    $('#popup_window_border').width(450);
    $('#popup_window_title').html("Properties of the Schedule Record ");

    function scheduler_settings_change() {        
        switch ($('#SCHEDULER_INTERVAL_TYPE').val()) {
            case '0':
                $('#d_of_t').css('display', 'none');
                break;
            case '1':
                $('#d_of_t').css('display', 'table-row');
                $('#d_of_t_type').html('Week');
                break;
            case '2':
                $('#d_of_t').css('display', 'table-row');
                $('#d_of_t_type').html('Month');
                break;
            case '3':
                $('#d_of_t').css('display', 'table-row');
                $('#d_of_t_type').html('Year');
                break;
        }
    }

    function del_scheduler() {
        alert('CONFIRM: Are You Sure?', 'yes,no', function (res) {
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
    <input id="SCHEDULER_KEY" name="SCHEDULER_KEY" type="hidden" value="{{ widget('KEY') }}">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>
    <TR>
        <TD valign="top" width="85">Description:</TD>
        <TD>
            <textarea id="SCHEDULER_COMM" name="SCHEDULER_COMM" style="width:100%;height:60px;">{{ widget('COMM') }}</textarea>
        </TD>
    </TR>
    <TR>
        <form id="scheduler_command_form" action="scheduler_edit_dialog" method="GET">
        <TD valign="top">Action:</TD>
        <TD>
            <table cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="2">
                    <textarea id="SCHEDULER_ACTION" name="SCHEDULER_ACTION" style="width:100%;height:60px;">{{ widget('ACTION') }}</textarea>
                </td>
            </tr>
            <tr>
                <td>
                    <select id="SCHEDULER_ENABLE" name="SCHEDULER_ENABLE">
                        {{ widget('SCHEDULER_ENABLE_LIST') }}
                    </select>
                </td>
                <td align="right">
                    <button onClick="test_scheduler();return false;">Action Test</button>
                </td>
            </tr>
            </table>
        </TD>
        </form>
    </TR>
    <TR>
        <TD>Repeat:</TD>
        <TD>
            <select id="SCHEDULER_INTERVAL_TYPE" name="SCHEDULER_INTERVAL_TYPE" onChange="scheduler_settings_change()">
                {{ widget('INTERVAL_TYPE_LIST') }}
            </select>
        </TD>
    </TR>
    <TR>
        <TD valign="top">Time of Day</TD>
        <TD>
            <textarea id="SCHEDULER_INTERVAL_TIME_OF_DAY" name="SCHEDULER_INTERVAL_TIME_OF_DAY" style="width:100%;height:60px;">{{ widget('INTERVAL_TIME_OF_DAY') }}</textarea>
        </TD>
    </TR>
    <TR id="d_of_t">
        <TD valign="top">Days of <span id="d_of_t_type"></span></TD>
        <TD>
            <textarea id="SCHEDULER_INTERVAL_DAY_OF_TYPE" name="SCHEDULER_INTERVAL_DAY_OF_TYPE" style="width:100%;height:60px;">{{ widget('INTERVAL_DAY_OF_TYPE') }}</textarea>
        </TD>
    </TR>
    <TR>
        <TD align="left" valign="bottom" height="60">
            <button id="del_button" type="button" onClick="del_scheduler();">Delete</button>
        </TD>    
        <TD align="right" valign="bottom" height="60">
            <button type="submit">Save</button>
            <button type="button" onClick="hide_window()">Cancel</button>
        </TD>
    </TR>
    </table>
</form>
