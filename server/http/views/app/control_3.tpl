<script type="text/javascript">
    $(document).ready(function () {
        attachCellMouse('cell_@NUM@', 'click_@NUM@(event)');
        set_val_@NUM@(@VALUE@);
        window.addEventListener('resizeControls', resizeControl_@NUM@);
        resizeControl_@NUM@();
    });

    function resizeControl_@NUM@() {
        var cell = $('#cell_@NUM@');
        var img = $('#img_@NUM@');
        var label = $('#label_@NUM@');
        var w = cell.width();
        var h = cell.height();
        var size = Math.min(w, h);

        var img_size = size / 2;
        
        img.width(img_size);
        img.height(img_size);
        img.css("left", (w - img_size) / 2 + 'px');
        img.css("top", (h - img_size) / 2 - h / 10 + 'px');

        label.css('font-size', size / 7);
        label.css("top", h - label.height() - h / 10 + 'px');
    }

    var curr_value_@NUM@ = 0;

    function set_val_@NUM@(val) {
        curr_value_@NUM@ = Math.ceil(val)
        var img = $('#img_@NUM@');
        if (curr_value_@NUM@ == 1)
            img.attr('src', 'views/app/control_@CONTROL@_1.png');
        else
            img.attr('src', 'views/app/control_@CONTROL@_0.png');
    }

    function click_@NUM@(event) {        
        event.preventDefault();
        if (touchBlock) return ;
        
        cellAnimClick('cell_@NUM@');
        
        val = curr_value_@NUM@
        if (val == 1)
            val = 0;
        else
            val = 1;
        $.ajax({url:'app?FORM_QUERY=@CONTROL@&key=@ID@&value=' + val}).done(function(data) {
            set_val_@NUM@(data);
        });
    }
    
</script>

<style type="text/css">
    div.cell_switch img {
        position:absolute;
    }

    div.cell_switch div {
        position:absolute;
        width:100%;
    }

    div.cell_switch {        
        background-color:#00aaaa;
    }
</style>

<div id="cell_@NUM@" class="cell cell_switch">
<img id="img_@NUM@">
<div id="label_@NUM@">@LABEL@</div>
</div>
