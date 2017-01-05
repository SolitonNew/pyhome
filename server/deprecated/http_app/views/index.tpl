<!DOCTYPE html>
<HTML>
<HEAD>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <script type="text/javascript" src="jquery-2.1.4.js"></script>
    <script type="text/javascript" src="jquery.json.js"></script>
    <script type="text/javascript" src="jquery.form.js"></script>
    <meta name="viewport" content="width=device-width">
    
<script type="text/javascript">
    $(document).ready(function () {
        resize_controls();
        window.addEventListener("mousedown", globalMouseDown);
        window.addEventListener("mousemove", globalMouseMove);
        window.addEventListener("mouseup", globalMouseUp);
        window.addEventListener("resize", resize_controls);

        window.addEventListener("touchstart", globalTouchStart);
        window.addEventListener("touchmove", globalTouchMove);
        window.addEventListener("touchend", globalTouchEnd);
        window.addEventListener("orientationchange", function() {
            $('#main_container').css('opacity', 0);
        });
    });

    function globalMouseDown(event) {
        event.preventDefault();
    }

    function globalMouseMove(event) {
        event.preventDefault();
    }

    function globalMouseUp(event) {
        event.preventDefault();
    }

    var touch_x = false;
    var touch_y = false;
    var touchBlock = false;

    function globalTouchStart(event) {
        event.preventDefault();
        touchBlock = false;
        touch_x = event.targetTouches[0].pageX;
        touch_y = event.targetTouches[0].pageY;
    }

    function globalTouchMove(event) {
        var x = event.targetTouches[0].pageX;
        var y = event.targetTouches[0].pageY;
        event.preventDefault();
        if ((Math.abs(x - touch_x) > touch_off) ||
             (Math.abs(y - touch_y) > touch_off)) {
            touchBlock = true;
        }
    }    

    function globalTouchEnd(event) {
        event.preventDefault();
        touch_x = false;
        touch_y = false;
    }

    function cellAnimClick(id, invert) {
        var s = 0.6;
        var e = 1;
        if (invert) {
            s = 0.15
            e = 0;
        }
        
        $('#' + id).fadeTo(50, s, function() {
            setTimeout(function () {$('#' + id).fadeTo(50, e);}, 100);
        });
    }

    function attachCellMouse(id, click) {
        if (isMobile)
            $('#' + id).attr('onTouchEnd', click);
        else
            $('#' + id).attr('onMouseDown', click);
    }

    var isMobile = @IS_MOBILE@;
    var rotate = @ROTATE@;
    var CHANGE_MAX_ID = @CHANGE_MAX_ID@
    var col_count = @COLS@;
    var row_count = @ROWS@;
    var control_meta = @CONTROL_META@;
    var touch_off = 20;

    function resize_controls() {
        var space = 1;
        var size_w = 10;
        var size_h = 10;
        var ww = $(window).width();
        var hh = $(window).height();
        var orientation = 1;
        var cc = col_count;
        var rc = row_count;
        if (rotate && ww > hh) {
            orientation = 0;
            cc = row_count;
            rc = col_count;
        }
        
        if (ww / hh < cc / rc) {            
            size_w = ww / cc;
            size_h = size_w;
        } else {
            size_h = hh / rc;
            size_w = size_h;
        }

        if (isMobile) {
            size_w = ww / cc;
            size_h = hh / rc;
        }        

        //if (!rotate)
        //    size -= 10;

        if (!isMobile) {
            size_w -= 10;
            size_h -= 10;
        }

        touch_off = Math.min(size_w, size_h) / 4;

        size_w = Math.round(size_w);
        size_h = Math.round(size_h);
                
        $('#main_container').width((size_w + space) * cc - space);
        $('#main_container').height((size_h + space) * rc - space);

        $('#main_container').css("left", (ww - $('#main_container').width()) / 2 + 'px');
        $('#main_container').css("top", (hh - $('#main_container').height()) / 2 + 'px');
        
        for (var i = 0; i < control_meta.length; i++) {
            var x = control_meta[i][0] * (size_w + space);
            var y = control_meta[i][1] * (size_h + space);
            var w = control_meta[i][2] * (size_w + space) - space;
            var h = control_meta[i][3] * (size_h + space) - space;
            var o = control_meta[i][5];

            var cell = $('#cell_' + (i + 1));
            if (rotate) {
                if (o == orientation)
                    cell.css('display', 'none');
                else
                    cell.css('display', 'block');
            }
            cell.css('left', x + 'px');
            cell.css('top', y + 'px');
            cell.width(w);
            cell.height(h);
        }

        window.dispatchEvent(new Event('resizeControls'));

        $('#main_container').css('opacity', 1);
    }
    
</script>

<style type="text/css">
    body {
        padding:0px;
        margin:0px;
        font-family:Arial;
        font-size:13px;
        overflow:hidden;
        background-color:#333333;
    }

    div.cell {
        position:absolute;
        background-color: #eeeeee;
        cursor:default;
        color:#ffffff;
        text-align:center;
        padding:0px;
        margin:0px;
        line-height:0.9;
    }
</style>

</HEAD>

<BODY>

<div id="main_container" style="position:absolute;overflow:hidden;text-align:left;">
@CONTENT@
</div>

</BODY>

<script type="text/javascript">
    function refresh_timer() {
        var q = $.ajax({url:'?FORM_QUERY=changes&key=' + CHANGE_MAX_ID});
        q.done(apply_changes);
        q.fail(function () {setTimeout(refresh_timer, 500)});
    };

    refresh_timer();

    function apply_changes(data) {
        if (data != '' && data.indexOf('@CHANGE_LOG@') > -1) {
            data = data.replace("@CHANGE_LOG@", "");
            var ls = data.split('#');
            for (var i = 0; i < ls.length; i++) {
                var row = ls[i].split(';');
                var nums = find_num_at_key(row[1]);
                for (var n = 0; n < nums.length; n++) {
                    var func = 'set_val_' + nums[n];
                    if (eval('typeof(' + func + ')') == 'function') {
                        eval(func + '(' + row[2] + ')');
                    }
                }
                if (row[0] != '')
                    CHANGE_MAX_ID = row[0];
            }

            setTimeout(refresh_timer, 500);
        } else {            
            location.href = location.href;
        }        
    }

    function find_num_at_key(key) {
        var res = [];
        for (var i = 0; i < control_meta.length; i++) {
            if (control_meta[i][4] == key)
                res.push(i + 1);
        }
        return res;
    }
</script>
