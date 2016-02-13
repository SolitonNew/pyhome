<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();
    });

    function variable_settings(key) {
        show_window('var_edit_dialog?key=' + key);
    }

</script>

<table width="100%" height="100%" cellpadding="0" cellspacing="0">
<tr>
    <td>
        <div class="toolbar">
            <button onClick="variable_settings(-1);">Создать новую переменну...</button>
        </div>
    </td>
</tr>
<tr>
    <td height="100%" valign="top">
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
