<script type="text/javascript">
    $('#popup_window_border').width(450);
    $('#popup_window_title').html("Свойства панели");

    $(document).ready(function() {
        $("#STAT_PANEL_DIALOG").ajaxForm(function(data) {
            if (data == "OK") {
                hide_window();
                stat_panel_{{ widget('KEY') }}_refresh();
                $('#stat_panel_{{ widget('KEY') }}_label').html($('#stat_panel_name').prop('value'));                
                $('#stat_panel_{{ widget('KEY') }}_label_1').html($('#SERIES_1 option:selected').text());
                $('#stat_panel_{{ widget('KEY') }}_label_2').html($('#SERIES_2 option:selected').text());
                $('#stat_panel_{{ widget('KEY') }}_label_3').html($('#SERIES_3 option:selected').text());
                $('#stat_panel_{{ widget('KEY') }}_label_4').html($('#SERIES_4 option:selected').text());
            } else {
                alert(data);
            }
        }); 
    });
</script>

<form id="STAT_PANEL_DIALOG" action="stat_panel_dialog" method="GET">
    <input id="FORM_QUERY" name="FORM_QUERY" type="hidden" value="update">
    <input id="KEY" name="KEY" type="hidden" value="{{ widget('KEY') }}">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>    
    <TR>
        <TD>Название:</TD>
        <TD width="100%"><input id="stat_panel_name" name="NAME" value="{{ widget('NAME') }}"></TD>
    </TR>
    <TR>
        <TD>Вид:</TD>
        <TD>
            <select name="TYP">
                {{ widget('TYPS') }}
            </select>
        </TD>
    </TR>    
    <TR>
        <TD colspan="2" bgcolor="#ffffff">
            <table width="100%" cellpadding="0" cellspacing="10">
            <tr>
                <td width="100%">
                    <select id="SERIES_1" name="SERIES_1" style="width:100%;">{{ widget('SERIES_1') }}</select>
                </td>
                <td bgcolor="#ff0000">
                    <div style="width:30px;"></div>
                </td>                
            </tr>
            <tr>
                <td width="100%">
                    <select id="SERIES_2" name="SERIES_2" style="width:100%;">{{ widget('SERIES_2') }}</select>
                </td>
                <td bgcolor="#00A651">
                    <div style="width:30px;"></div>
                </td>
            </tr>
            <tr>
                <td width="100%">
                    <select id="SERIES_3" name="SERIES_3" style="width:100%;">{{ widget('SERIES_3') }}</select>
                </td>
                <td bgcolor="#0000ff">
                    <div style="width:30px;"></div>
                </td>
            </tr>
            <tr>
                <td width="100%">
                    <select id="SERIES_4" name="SERIES_4" style="width:100%;">{{ widget('SERIES_4') }}</select>
                </td>
                <td bgcolor="#ff00ff">
                    <div style="width:30px;"></div>
                </td>
            </tr>
            </table>
        </TD>
    </TR>
    <TR>
        <TD align="left" valign="bottom" height="60">
            
        </TD>    
        <TD align="right" valign="bottom" height="60">
            <button type="submit">Готово</button>
            <button type="button" onClick="hide_window()">Закрыть</button>
        </TD>
    </TR>
    </table>
</form>
