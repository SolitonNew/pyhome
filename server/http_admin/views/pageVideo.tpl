<script type="text/javascript">

    $(document).ready(function () {
        use_splitters();
        window.addEventListener('CAMERA_LIST_selected', function (event) {
            var key = _CAMERA_LIST_selected_key;
            if (key) {
                
            }
        });
        
    });

    function create_camera() {

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
        <img src="rtsp://192.168.40.3:554/user=admin&password=&channel=1&stream=1.sdp?real_stream--rtp-caching=1000">
        @CAMERA_VIEW@
    </td>
</tr>
</table>
