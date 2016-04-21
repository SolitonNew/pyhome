<script type="text/javascript">
    $(document).ready(function () {
        window.addEventListener('resizeControls', resizeControl_@NUM@);
        resizeControl_@NUM@();
    });

    function resizeControl_@NUM@() {
        var cell = $('#cell_@NUM@');
        var label = $('#label_@NUM@');
        var w = cell.width();
        var h = cell.height();
        var size = Math.min(w, h);

        label.css('font-size', size / 7);
        label.css("top", h - label.height() - h / 10 + 'px');
    }    
</script>

<style type="text/css">
    div.cell_camera div {
        position:absolute;
        width:100%;
    }

    div.cell_camera {        
        background-color:#000000;
    }

</style>

<div id="cell_@NUM@" class="cell cell_camera" onMouseDown=" return false;">
<div id="label_@NUM@">@LABEL@</div>
</div>
