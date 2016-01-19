<script type="text/javascript">
    $(document).ready(function () {
        use_scrollers();
    });
</script>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td colspan="2" style="position:relative;">
        <div class="toolbar">
            <button onClick="alert('Новый скрипт')">Новый скрипт...</button>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;height:100%;">
        <div class="splitter_left" style="width:300px;">
            @SCRIPT_LIST@
        </div>
    </td>
    <td style="position:relative;width:100%;height:100%;">
        @SCRIPT_VIEW_TABS@
    </td>
</tr>
</table>
