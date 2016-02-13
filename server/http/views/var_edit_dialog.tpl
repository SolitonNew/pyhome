<script type="text/javascript">

    $('#popup_window_border').width(450);
    $('#popup_window_title').html("Свойства переменной");

    function variable_settings_change() {
        if ($('#VAR_TYPE').val() == 'variable')
            $('#value_row').css('display', 'table-row');
        else
            $('#value_row').css('display', 'none');

        if ($('#VAR_TYPE').val() == 'ow')
            $('#ow_row').css('display', 'table-row');
        else
            $('#ow_row').css('display', 'none');        
    }

    function del_var() {
        alert('CONFIRM: Удалить переменную и всю историю по ней?', 'yes,no', function (res) {
            if (res == 'yes') {
                $('#FORM_QUERY').val('delete');
                $('#VARIABLE_SETTINGS').submit();
            }
        });
    }

    $(document).ready(function() {
        if ($('#VAR_KEY').val() == '-1')
            $('#del_button').css('display', 'none');
        
        variable_settings_change();

        $("#VARIABLE_SETTINGS").ajaxForm(function(data) {
            if (data == "OK")
                hide_window();
            else
                alert(data); 
        }); 
    });
</script>

<form id="VARIABLE_SETTINGS" action="var_edit_dialog" method="GET">
    <input id="FORM_QUERY" name="FORM_QUERY" type="hidden" value="update">
    <input id="VAR_KEY" name="VAR_KEY" type="hidden" value="@KEY@">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>    
    <TR>
        <TD>Контроллер:</TD>
        <TD>
            <select id="VAR_CONTROLLER" name="VAR_CONTROLLER" onChange="variable_settings_change()">
                @VAR_CONTROLLER@
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Тип:</TD>
        <TD>
            <select id="VAR_TYPE" name="VAR_TYPE" onChange="variable_settings_change()">
                @TYPE_LIST@
            </select>
        </TD>
    </TR>
    <TR id="ow_row">
        <TD valign="top">OW устройство:</TD>
        <TD>
            <select id="VAR_OW" name="VAR_OW" style="width:100%;">
                @OW_LIST@
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Только чтение:</TD>
        <TD>
            <select id="VAR_READ_ONLY" name="VAR_READ_ONLY" onChange="variable_settings_change()">
                @READ_ONLY_LIST@
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Название:</TD>
        <TD><input id="VAR_NAME" name="VAR_NAME" type="text" value="@NAME@" onChange="variable_settings_change()" style="width:90%;"/></TD>
    </TR>
    <TR>
        <TD valign="top">Описание:</TD>
        <TD>
            <textarea id="VAR_COMM" name="VAR_COMM" style="width:100%;height:60px;">@COMM@</textarea>
        </TD>
    </TR>
    <TR id="value_row">
        <TD>Значение:</TD>
        <TD><input id="VAR_VALUE" name="VAR_VALUE" type="text" value="@VALUE@"/></TD>
    </TR>
    <TR>
        <TD>Канал:</TD>
        <TD><input id="VAR_CHANNEL" name="VAR_CHANNEL" type="text" value="@CHANNEL@"/></TD>
    </TR>
    <TR>
        <TD align="left" valign="bottom" height="60">
            <button id="del_button" type="button" onClick="del_var();">Удалить</button>
        </TD>    
        <TD align="right" valign="bottom" height="60">
            <button type="submit">Готово</button>
            <button type="button" onClick="hide_window()">Закрыть</button>
        </TD>
    </TR>
    </table>
</form>
