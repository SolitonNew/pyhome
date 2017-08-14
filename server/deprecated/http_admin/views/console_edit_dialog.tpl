<script type="text/javascript">

    $('#popup_window_border').width(450);
    $('#popup_window_title').html("Свойства консоли");

    function del_console() {
        alert('CONFIRM: Удалить консоль?', 'yes,no', function (res) {
            if (res == 'yes') {
                $('#FORM_QUERY').val('delete');
                $('#CONSOLE_SETTINGS').submit();
            }
        });
    }

    $(document).ready(function() {
        if ($('#KEY').val() == '-1')
            $('#del_button').css('display', 'none');

        $("#CONSOLE_SETTINGS").ajaxForm(function(data) {
            if (data == "OK") {
                hide_window();
                CONSOLE_LIST_refresh();
            } else
                alert(data); 
        }); 
    });
</script>

<form id="CONSOLE_SETTINGS" action="console_edit_dialog" method="GET">
    <input id="FORM_QUERY" name="FORM_QUERY" type="hidden" value="update">
    <input id="KEY" name="KEY" type="hidden" value="@KEY@">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>
    <TR>
        <TD>Название:</TD>
        <TD><input id="NAME" name="NAME" type="text" value="@NAME@" style="width:90%;"/></TD>
    </TR>
    <TR>
        <TD valign="top">Описание:</TD>
        <TD>
            <textarea id="COMM" name="COMM" style="width:100%;height:60px;">@COMM@</textarea>
        </TD>
    </TR>
    <TR>
        <TD>Тип:</TD>
        <TD>
            <select id="TYP" name="TYP">
                @TYP@
            </select>
        </TD>
    </TR>
    <TR>
        <TD>PINCODE:</TD>
        <TD><input id="PINCODE" name="PINCODE" type="text" value="@PINCODE@"/></TD>
    </TR>
    <TR>
        <TD align="left" valign="bottom" height="60">
            <button id="del_button" type="button" onClick="del_console();">Удалить</button>
        </TD>    
        <TD align="right" valign="bottom" height="60">
            <button type="submit">Готово</button>
            <button type="button" onClick="hide_window()">Закрыть</button>
        </TD>
    </TR>
    </table>
</form>
