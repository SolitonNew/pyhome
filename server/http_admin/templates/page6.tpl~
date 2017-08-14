<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();
    });

    function scheduler_settings(key) {
        if (key == -1) {
            show_window('scheduler_edit_dialog?key=-1');
        } else {
            show_window('scheduler_edit_dialog?key=' + key);
        }
    }

</script>

<table width="100%" height="100%" cellpadding="0" cellspacing="0">
<tr>
    <td>
        <div class="toolbar">
            <button onClick="scheduler_settings(-1);">Создать новую запись...</button>
            <button onClick="if (_SCHEDULER_LIST_selected_key) scheduler_settings(_SCHEDULER_LIST_selected_key);">Свойства выбраной записи...</button>
        </div>
    </td>
</tr>
<tr>
    <td valign="top" width="100%" height="100%">
        {{ widget('SCHEDULER_LIST') }}
    </td>
</tr>
</table>

<script type="text/javascript">
    function sched_refresh_timer() {
        SCHEDULER_LIST_refresh();
        setTimeout(sched_refresh_timer, 20000);
    };

    sched_refresh_timer();
</script>
