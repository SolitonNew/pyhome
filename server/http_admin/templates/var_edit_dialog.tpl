<script type="text/javascript">

    $('#popup_window_border').width(450);
    $('#popup_window_title').html("Свойства переменной");

    function variable_settings_change() {
        if ($('#VAR_TYPE').val() == 'variable' || $('#VAR_READ_ONLY').val() == '1')
            $('#value_row').css('display', 'table-row');
        else
            $('#value_row').css('display', 'none');

        if ($('#VAR_TYPE').val() == 'ow')
            $('#ow_row').css('display', 'table-row');
        else
            $('#ow_row').css('display', 'none');

        reload_channels();
    }

    function del_var() {
        alert('CONFIRM: Удалить переменную и всю историю по ней?', 'yes,no', function (res) {
            if (res == 'yes') {
                $('#FORM_QUERY').val('delete');
                $('#VARIABLE_SETTINGS').submit();
            }
        });
    }

    function reload_ow_devs() {
        var contr = $('#VAR_CONTROLLER').val();
        var ow_key = $('#VAR_OW_KEY').val();
        $.ajax({url:'var_edit_dialog?FORM_QUERY=reload_ow_devs&ow_key=' + ow_key + '&controller=' + contr}).done(function (data) {
            $('#VAR_OW').html(data);
        });
    }

    function reload_channels() {
        var channel = $('#CHANNEL_KEY').val();
        var var_type = $('#VAR_TYPE').val();
        var ow_key = $('#VAR_OW').val();
        $.ajax({url:'var_edit_dialog?FORM_QUERY=reload_channels&channel=' + channel + '&var_type=' + var_type + '&ow_key=' + ow_key}).done(function (data) {
            $('#VAR_CHANNEL').html(data);
            if (data == '') {
                $('#channel_row').css('display', 'none');
            } else {
                $('#channel_row').css('display', 'table-row');
            }
        });
    }

    function save_ow_key() {
        $('#VAR_OW_KEY').val($('#VAR_OW').val());
    }

    $(document).ready(function() {
        if ($('#VAR_KEY').val() == '-1')
            $('#del_button').css('display', 'none');
        
        variable_settings_change();

        $("#VARIABLE_SETTINGS").ajaxForm(function(data) {
            if (data == "OK") {
                hide_window();
                VARIABLE_LIST_refresh();
            } else
                alert(data); 
        }); 
    });
</script>

<form id="VARIABLE_SETTINGS" action="var_edit_dialog" method="GET">
    <input id="FORM_QUERY" name="FORM_QUERY" type="hidden" value="update">
    <input id="VAR_KEY" name="VAR_KEY" type="hidden" value="{{ widget('KEY') }}">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>
    <TR>
        <TD width="100">ID:</TD>
        <TD>
            {{ widget('KEY') }}
        </TD>
    </TR>
    <TR>
        <TD width="100">Контроллер:</TD>
        <TD>
            <select id="VAR_CONTROLLER" name="VAR_CONTROLLER" onChange="reload_ow_devs(); variable_settings_change()">
                {{ widget('VAR_CONTROLLER') }}
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Тип:</TD>
        <TD>
            <select id="VAR_TYPE" name="VAR_TYPE" onChange="variable_settings_change()">
                {{ widget('TYPE_LIST') }}
            </select>
        </TD>
    </TR>
    <TR id="ow_row">
        <TD valign="top">OW устройство:</TD>
        <TD>
            <input id="VAR_OW_KEY" name="VAR_OW_KEY" type="hidden" value="{{ widget('VAR_OW_KEY') }}">
            <select id="VAR_OW" name="VAR_OW" style="width:100%;" onChange="reload_channels();save_ow_key();">
                {{ widget('OW_LIST') }}
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Только чтение:</TD>
        <TD>
            <select id="VAR_READ_ONLY" name="VAR_READ_ONLY" onChange="variable_settings_change()">
                {{ widget('READ_ONLY_LIST') }}
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Название:</TD>
        <TD><input id="VAR_NAME" name="VAR_NAME" type="text" value="{{ widget('NAME') }}" onChange="variable_settings_change()" style="width:90%;"/></TD>
    </TR>
    <TR>
        <TD valign="top">Описание:</TD>
        <TD>
            <textarea id="VAR_COMM" name="VAR_COMM" style="width:100%;height:60px;">{{ widget('COMM') }}</textarea>
        </TD>
    </TR>
    <TR id="value_row">
        <TD>Значение:</TD>
        <TD><input id="VAR_VALUE" name="VAR_VALUE" type="text" value="{{ widget('VALUE') }}"/></TD>
    </TR>
    <TR id="channel_row">
        <TD>Канал:</TD>
        <TD>
            <input id="CHANNEL_KEY" type="hidden" value="{{ widget('CHANNEL_KEY') }}"/>
            <select id="VAR_CHANNEL" name="VAR_CHANNEL" style="width:80px">
                {{ widget('CHANNEL') }}
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Группа:</TD>
        <TD>
            <select id="VAR_GROUP" name="VAR_GROUP" style="width:100%">
                {{ widget('VAR_GROUP_TREE') }}
            </select>
        </TD>
    </TR>
    <TR>
        <TD>Устройство:</TD>
        <TD>
            <select id="VAR_CONTROL" name="VAR_CONTROL">
                {{ widget('VAR_CONTROL') }}
            </select>
        </TD>
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
