<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();

        window.addEventListener("VARIABLE_GROUPS_selected", function (event) {
            if (_VARIABLE_GROUPS_selected_key && _VARIABLE_GROUPS_selected_key != 1) {
                VARIABLE_LIST_filter = 'GROUP_ID in (' + _VARIABLE_GROUPS_selected_addAttr + ')';
            } else {
                VARIABLE_LIST_filter = '';
            }
            VARIABLE_LIST_refresh();
        });
    });

    function variable_settings(key) {
        if (key == -1) {
            show_window('var_edit_dialog?key=-1&default_group=' + _VARIABLE_GROUPS_selected_key);
        } else {
            show_window('var_edit_dialog?key=' + key);
        }
    }

</script>

<table width="100%" height="100%" cellpadding="0" cellspacing="0">
<tr>
    <td colspan="2">
        <div class="toolbar">
            <button onClick="variable_settings(-1);">Создать новую переменну...</button>
            <button onClick="if (_VARIABLE_LIST_selected_key) variable_settings(_VARIABLE_LIST_selected_key);">Свойства выбраной переменной...</button>
        </div>
    </td>
</tr>
<tr>
    <td>
        <div class="splitter_left" style="width:200px;">
            @VARIABLE_GROUPS@
        </div>
    </td>
    <td width="100%" height="100%" valign="top">
        @VARIABLE_LIST@
    </td>
</tr>
</table>

<script type="text/javascript">
    function refresh_timer() {
        VARIABLE_LIST_refresh();
        setTimeout(refresh_timer, 1000);
    };

    refresh_timer();
</script>
