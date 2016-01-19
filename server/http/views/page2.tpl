<script type="text/javascript">
    $(document).ready(function () {
        use_scrollers();
    });

    function create_script() {
        $.ajax({url:'page2?FORM_QUERY=create_script'}).done(function (data) {
            a = data.split(';');
            SCRIPT_VIEW_TABS_append(a[0], 'scripteditor?key=' + a[1]);
            SCRIPT_LIST_refresh();                
        });
    }
    
</script>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td colspan="2" style="position:relative;">
        <div class="toolbar">
            <button onClick="create_script();">Новый скрипт...</button>
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
