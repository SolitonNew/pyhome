<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();

        window.addEventListener("STAT_VAR_LIST_selected", function () {
            stat_var_date_change();
        });
    });

    function stat_var_date_change() {
        var date = $('#stat_var_date').val();
        var value = $('#stat_var_value').val();
        
        if (_STAT_VAR_LIST_selected_key && date != '') {
            STAT_VAR_DATA_filter = 'CHANGE_DATE >= "' + date + '" and CHANGE_DATE <= DATE_ADD("' + date + '", INTERVAL 1 DAY) and VARIABLE_ID = ' + _STAT_VAR_LIST_selected_key;
            if (value != '') {
                try {
                    eval('1 ' + value)
                    STAT_VAR_DATA_filter += ' and VALUE ' + value;
                } catch (e) {}
            }
        } else {
            STAT_VAR_DATA_filter = '';
        }
        STAT_VAR_DATA_refresh();
    }

    function stat_var_date_delete() {
        var key = _STAT_VAR_DATA_selected_key;
        $.ajax({url:'page5_2?FORM_QUERY=delete&key=' + key}).done(function (data) {
            if (data == 'OK') {
                STAT_VAR_DATA_refresh();
            } else {
                alert(data);
            }
        });
    }
    
</script>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td style="position:relative;" colspan="2">
        <div class="toolbar">&nbsp;&nbsp;            
            Daily variable change history
            <input id="stat_var_date" type="date" onChange="stat_var_date_change();">
            when value
            <input id="stat_var_value" type="text" onChange="stat_var_date_change();" style="width:60px;">
            <button style="margin-left:50px;" onClick="stat_var_date_delete()">Delete selected record</button>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;height:100%;" valign="top">
        <div class="splitter_left" style="width:350px;">
            {{ widget('STAT_VAR_LIST') }}
        </div>
    </td>
    <td style="position:relative;width:100%;height:100%;" valign="top">
        {{ widget('STAT_VAR_DATA') }}
    </td>    
</tr>
</table>
