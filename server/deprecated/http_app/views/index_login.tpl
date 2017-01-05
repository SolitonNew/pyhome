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
        window.addEventListener("resize", resize_controls);

        $('td').mousedown(mouseDown);
    });

    function mouseDown(event) {
        if ($(event.target).attr('id') == 'indicator') return false;
        button_down($(event.target).html());
        return false;
    }

    var isMobile = @IS_MOBILE@;
    var col_count = 3;
    var row_count = 5;

    function resize_controls() {
        var space = 1;
        var size_w = 10;
        var size_h = 10;
        var ww = $(window).width();
        var hh = $(window).height();

        if (ww / hh < col_count / row_count) {
            size_w = ww / col_count;
            size_h = size_w;
        } else {
            size_h = hh / row_count;
            size_w = size_h;
        }

        if (isMobile) {
            size_w = ww / col_count;
            size_h = hh / row_count;
        } else {
            if (size_w > 100)
                size_w = 100;
            if (size_h > 100)
                size_h = 100;
        }
        
        $('#main_container').width((size_w + space) * col_count - space);
        $('#main_container').height((size_h + space) * row_count - space);

        $('td').width(size_w);
        $('td').height(size_h);
        $('td').css('font-size', size_h / 2);

        $('#main_container').css("left", (ww - $('#main_container').width()) / 2 + 'px');
        $('#main_container').css("top", (hh - $('#main_container').height()) / 2 + 'px');

        if ($('#main_container').css('opacity') == '0') {
            $('#main_container').css('opacity', '1')
            $('#main_container').hide();
            $('#main_container').fadeIn(700);
        }
    }

    var pincode = '';

    function button_down(key) {
        switch (key) {
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case '0':
                pincode += key;
                break;
            case 'C':
                pincode = '';
                break;
            case 'E':
                $.ajax({url:'?FORM_QUERY=' + pincode}).done(function(data) {
                    if (data == 'OK') {
                        location.href = location.href;
                    } else {
                        button_down('C');
                    }
                });
                break;
        }

        var s = '';
        for (var i = 0; i < pincode.length; i++)
             s += '*';
        $('#indicator').html(s);
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

    td {
        background-color:#eeeeee;
        text-align:center;
        cursor:default;
    }

    td:active {
        opacity:0.6;
    }
</style>

</HEAD>

<BODY>

<div id="main_container" style="position:absolute;opacity:0;">
    <table width="100%" height="100%" cellpadding="0" cellspacing="1">
    <tr>
        <td colspan="3" id="indicator"></td>
    </tr>
    <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
    </tr>
    <tr>
        <td>4</td>
        <td>5</td>
        <td>6</td>
    </tr>
    <tr>
        <td>7</td>
        <td>8</td>
        <td>9</td>
    </tr>
    <tr>
        <td>C</td>
        <td>0</td>
        <td>E</td>
    </tr>
    </table>
</div>

</BODY>
