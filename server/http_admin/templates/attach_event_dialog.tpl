<script type="text/javascript">

    $('#popup_window_border').width(400);
    $('#popup_window_title').html("Attach as Event");


    $(document).ready(function() {
        $("#VARIABLE_EVENTS").ajaxForm(function(data) {
            if (data == "OK")
                hide_window();
            else
                alert(data); 
        }); 
    });
</script>

<form id="VARIABLE_EVENTS" action="attach_event_dialog" method="GET">
    <input id="FORM_QUERY" name="FORM_QUERY" type="hidden" value="attach">
    <input id="VAR_KEY" name="VAR_KEY" type="hidden" value="{{ widget('KEY') }}">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD></TD>
    </TR>    
    <TR>
        <TD>
            Variables:<br>
            <select id="VAR_LIST" name="VAR_LIST" style="width:100%;height:400px;" multiple>
                {{ widget('VAR_LIST') }}
            </select>
        </TD>
    </TR>
    <TR>
        <TD align="right" valign="bottom" height="60">
            <button type="submit">Save</button>
            <button type="button" onClick="hide_window()">Cancel</button>
        </TD>
    </TR>
    </table>
</form>
