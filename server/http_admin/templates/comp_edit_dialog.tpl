<script type="text/javascript">

    $('#popup_window_border').width(400);
    $('#popup_window_title').html("Свойства компонента");

    function del_comp() {
        alert('CONFIRM: Удалить компонент?', 'yes,no', function (res) {
            if (res == 'yes') {
                $('#FORM_QUERY').val('delete');
                $('#COMP_SETTINGS').submit();
            }
        });
    }

    $(document).ready(function() {
        $("#COMP_SETTINGS").ajaxForm(function(data) {
            if (data == "OK") {
                hide_window();
                CONSOLE_DESIGN_refresh();
            } else
                alert(data); 
        }); 
    });
</script>

<form id="COMP_SETTINGS" action="comp_edit_dialog" method="GET">
    <input id="FORM_QUERY" name="FORM_QUERY" type="hidden" value="update">
    <input id="KEY" name="KEY" type="hidden" value="@KEY@">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>
    <TR>
        <TD>Ширина:</TD>
        <TD><input id="WIDTH" name="WIDTH" type="text" value="@WIDTH@"/></TD>
    </TR>
    <TR>
        <TD>Высота:</TD>
        <TD><input id="HEIGHT" name="HEIGHT" type="text" value="@HEIGHT@"/></TD>
    </TR>
    <TR>
        <TD align="left" valign="bottom" height="60">
            <button id="del_button" type="button" onClick="del_comp();">Удалить</button>
        </TD>    
        <TD align="right" valign="bottom" height="60">
            <button type="submit">Готово</button>
            <button type="button" onClick="hide_window()">Закрыть</button>
        </TD>
    </TR>
    </table>
</form>
