<script type="text/javascript">
    $(document).ready(function () {
        attachCellMouse('cell_@NUM@_up', 'click_@NUM@(event, true)');
        attachCellMouse('cell_@NUM@_down', 'click_@NUM@(event, false)');
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

    var curr_value_@NUM@ = @VALUE@;

    function set_val_@NUM@(val) {
        curr_value_@NUM@ = val;
        var cell = $('#val_@NUM@');
        cell.html(val);
        resizeControl_@NUM@();
    }

    function click_@NUM@(event, inc) {
        event.preventDefault();
        if (touchBlock) return ;
        val = curr_value_@NUM@;
        if (inc) {
            cellAnimClick('cell_@NUM@_up', true);
            val++;
        } else {
            val--;
            cellAnimClick('cell_@NUM@_down', true);
        }
        $.ajax({url:'?FORM_QUERY=@CONTROL@&key=@ID@&value=' + val}).done(function(data) {
            set_val_@NUM@(data);            
        });
    }
</script>

<style type="text/css">
    div.cell_termostat table {
        position:absolute;
        top:0px;
        left:0px;
    }

    div.cell_termostat div {
        position:absolute;        
    }

    div.cell_termostat {        
        background-color:#aaaa00;
    }

    div.cell_termostat_up, div.cell_termostat_down {
        left:0px;
        top:0px;
        width:100%;
        height:100%;
        background-color:#000000;
        opacity:0;
    }
</style>

<div id="cell_@NUM@" class="cell cell_termostat">
<div id="val_@NUM@"></div>
<div id="c_@NUM@">°C</div>
<div id="label_@NUM@" style="width:100%;">@LABEL@</div>
<table width="100%" height="100%" cellpadding="0" cellspacing="0">
<tr>
    <td style="position:relative;">
        <div id="cell_@NUM@_up" class="cell_termostat_up"></div>
    </td>
</tr>
<tr>
    <td style="position:relative;">
        <div id="cell_@NUM@_down" class="cell_termostat_down"></div>
    </td>
</tr>
</table>
</div>
