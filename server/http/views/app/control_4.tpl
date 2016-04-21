<script type="text/javascript">
    $(document).ready(function () {
        set_val_@NUM@(@VALUE@);
        window.addEventListener('resizeControls', resizeControl_@NUM@);
        resizeControl_@NUM@();
    });

    function resizeControl_@NUM@() {
        var cell = $('#cell_@NUM@');
        var val_cell = $('#val_@NUM@');
        var c_cell = $('#c_@NUM@');
        var label = $('#label_@NUM@');
        var w = cell.width();
        var h = cell.height();
        var size = Math.min(w, h);

        val_cell.css('font-size', size / 2);
        val_cell.css("left", (w - val_cell.width()) / 2 + 'px');
        val_cell.css("top", (h - val_cell.height()) / 2 - h / 10 + 'px');

        c_cell.css('font-size', size / 7);
        c_cell.css("left", (w + val_cell.width()) / 2 - size / 20 + 'px');
        c_cell.css("top", val_cell.css('top'));        

        label.css('font-size', size / 7);
        label.css("top", h - label.height() - h / 10 + 'px');
    }

    function set_val_@NUM@(val) {
        var cell = $('#val_@NUM@');
        cell.html(Math.ceil(val));
        resizeControl_@NUM@();
    }    
</script>

<style type="text/css">
    div.cell_termometr div {
        position:absolute;        
    }

    div.cell_termometr {        
        background-color:#aa0000;
    }
</style>

<div id="cell_@NUM@" class="cell cell_termometr" onMouseDown="return false;">
<div id="val_@NUM@"></div>
<div id="c_@NUM@">°C</div>
<div id="label_@NUM@" style="width:100%;">@LABEL@</div>
</div>
