<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();
    });

    function refresh_stat() {
        $.ajax({url:'page5_3?FORM_QUERY=recalc_stat'}).done(function (data) {
            if (data == 'OK')
                POWER_TABLE_refresh();
        });
    }
    
</script>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td style="position:relative;">
        <div class="toolbar">
            <button onClick="refresh_stat();">Обновить</button>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;width:100%;height:100%;" valign="top">
        @POWER_TABLE@
    </td>    
</tr>
</table>
