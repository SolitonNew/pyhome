<script type="text/javascript">
    $(document).ready(function () {
        use_scrollers();
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
            <button onClick="STATISTICS_refresh();">Обновить чарт</button>
        </div>
    </td>
</tr>
<tr>
    <td height="100%" valign="top">
        @VARIABLE_LIST@
    </td>
</tr>
<tr>
    <td>
        <div class="splitter_bottom" style="height:150px;">
            <div style="cursor:default;position:absolute;top:0px;overflow:hidden;width:100%;height:100%;background-color:#fff;">
            @STATISTICS@
            </div>
        </div>
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
