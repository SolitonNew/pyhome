<script type="text/javascript">
    $(document).ready(function () {
        use_splitters();
        refresh_stat();
    });

    function refresh_stat() {
        $('#CONTENT').html("Загрузка данных...")
        $.ajax({url:'page5_3?FORM_QUERY=refresh'}).done(function (data) {
            $('#CONTENT').html(data)
        });
    }
    
</script>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td style="position:relative;" colspan="2">
        <div class="toolbar">
            <button onClick="refresh_stat();">Обновить</button>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;width:100%;height:100%;" valign="top">
        <div style="position:relative;padding:0px;overflow:auto;width:100%;height:100%;">
        <div id="CONTENT" style="padding:20px;">
        </div> 
        </div>
    </td>    
</tr>
</table>
