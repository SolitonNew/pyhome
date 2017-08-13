<script type="text/javascript">

    $(document).ready(function () {
        use_splitters();
        window.addEventListener('CAMERA_LIST_selected', function (event) {
            var key = _CAMERA_LIST_selected_key;
            if (key) {
                $.ajax({url: 'pageVideo?FORM_QUERY=URL&key=' + key}).done(function(data) {
                    play_camera(data);
                });
            }
        });
        
    });

    function play_camera(url) {
        var vlc = document.getElementById('vlc');
        vlc.playlist.stop();
        vlc.playlist.clear();
        
        var track = vlc.playlist.add(url, '', '');
        vlc.playlist.play();
    }
    
</script>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td colspan="3" style="position:relative;">
        <div class="toolbar">
            <button onClick="create_camera();">Добавить новую камеру...</button>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;height:100%;">
        <div class="splitter_left" style="width:150px;">
            @CAMERA_LIST@
        </div>
    </td>
    <td style="position:relative;width:100%;height:100%;">
        <embed type="application/x-vlc-plugin" pluginspage="http://www.videolan.org"
        width=100%
        height=100%
        id="vlc"/>
    </td>
</tr>
</table>
