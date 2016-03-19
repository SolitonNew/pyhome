<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();
    });

    var stat_panels = [];

    function append_stat_panel() {
        $.ajax({url:'page5?FORM_QUERY=append_panel'}).done(function (data) {
            var p = $(data);
            p.css('display', 'none');
            $('#stat_panels').append(p);
            p.show();
            use_splitters();            
        });
    }

    function del_stat_panel(key) {
        $.ajax({url:'page5?FORM_QUERY=del_panel&key=' + key}).done(function (data) {
            if (data == 'OK') {
                var p = $('#stat_panel_' + key);
                p.hide(300).done(function () {p.remove()});
            } else
                alert(data);
        });
    }    
    

</script>

<style type="text/css">
    #STATISTIC_PANELS_data td:hover {
        background-color:#ffffff;
    }
</style>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td style="position:relative;">
        <div class="toolbar">
            
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;width:100%;height:100%;" valign="top">
        <div style="position:absolute;width:100%;height:100%;overflow:hidden;overflow-y:auto;">
            <div id="stat_panels">
            @STATISTIC_PANELS@
            </div>
            <p align="center" style="height:50px;">
                <button onClick="append_stat_panel();">Добавить новую панель</button>
            </p>
        </div>
    </td>
</tr>
</table>