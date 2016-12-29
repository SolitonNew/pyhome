<script type="text/javascript">
    $(document).ready(function () {
        set_val_@NUM@(@VALUE@);
        window.addEventListener('resizeControls', resizeControl_@NUM@);
        resizeControl_@NUM@();
    });

    function resizeControl_@NUM@() {
        var cell = $('#cell_@NUM@');
        var val_cell = $('#val_@NUM@');
        var val_deg = $('#val_deg_@NUM@');
        var c_cell = $('#c_@NUM@');
        var label = $('#label_@NUM@');
        var w = cell.width();
        var h = cell.height();
        var size = Math.min(w, h);

        val_cell.css('font-size', size / 2);
        val_cell.css("left", (w - val_cell.width()) / 2 + 'px');
        var ttt = (h - val_cell.height()) / 2 - h / 10;
        val_cell.css("top", ttt + 'px');

        val_deg.css('font-size', size / 5);
        val_deg.css("left", (w + val_cell.width()) / 2 + 'px');
        val_deg.css("top", ttt + val_cell.height() - val_deg.height() - size / 25 + 'px');

        c_cell.css('font-size', size / 7);
        c_cell.css("left", (w + val_cell.width()) / 2 + 'px');
        c_cell.css("top", val_cell.css('top'));        

        label.css('font-size', size / 7);
        label.css("top", h - label.height() - h / 10 + 'px');
    }

    function set_val_@NUM@(val) {
        var minus = (val < 0)
        val = Math.abs(val);
        var val_s = Math.round(val * 10) / 10 + '';
        var val_num = val_s;
        var val_deg = '.0';
        if (val_s.indexOf('.') > 0) {
            val_num = val_s.substr(0, val_s.length - 2);
            if (minus) {
                val_num = '-' + val_num;
            }
            val_deg = '.' + val_s.substr(val_s.length - 1, 1);
        }
        
        var cell = $('#val_@NUM@');
        cell.html(val_num);

        var deg = $('#val_deg_@NUM@');
        deg.html(val_deg);
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
<div id="val_deg_@NUM@"></div>
<div id="c_@NUM@">°C</div>
<div id="label_@NUM@" style="width:100%;">@LABEL@</div>
</div>
