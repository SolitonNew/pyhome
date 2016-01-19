<style>
    textarea.script_log {
        position:relative;
        width:100%;
        height:100%;
        background-color:#000000;
        color:#00ff00;
        editable=false;
    }
</style>

<script type="text/JavaScript">
    calc_nums_@ID@();
    $('#script_save_@ID@').prop('disabled', true);

    function calc_nums_@ID@() {
        $('#script_save_@ID@').prop('disabled', false);

        var v = $('#script_text_@ID@').val();        
        var c = 1;        
        for (var i = 0; i < v.length; i++)
            if (v.charAt(i) == '\n') c++;        
        var s = '';
        for (i = 1; i <= c; i++) {
            s += i + '<br>';
        }
        $('#script_num_@ID@').html(s);
    }

    function script_keydown_@ID@(event) {
        switch (event.keyCode) {
            case 9: // Tab
                event.stopPropagation();
                event.preventDefault();
                script_insert_@ID@('    ');
                break;
            case 13: // Enter
                var line_tabs = script_calc_line_tab_@ID@();
                event.stopPropagation();
                event.preventDefault();
                if (script_get_char_@ID@() == ':')
                    script_insert_@ID@('\n    ' + line_tabs);
                else
                    script_insert_@ID@('\n' + line_tabs);
                break;
            case 83:
                if (event.ctrlKey) {
                    event.stopPropagation();
                    event.preventDefault();
                    script_save_to_db_@ID@();
                }
                break;
            
            //default:
            //   alert(event.keyCode + '');
        }
    }

    function script_insert_@ID@(text) {
        var doc = document.getElementById('script_text_@ID@');
        var i = doc.selectionStart;
        var s = $(doc).val();        
        s = s.substr(0, i) + text + s.substr(i);
        $(doc).val(s);
        doc.selectionStart = i + text.length;
        doc.selectionEnd = doc.selectionStart;
        calc_nums_@ID@();
    }

    function script_calc_line_tab_@ID@() {
        var doc = document.getElementById('script_text_@ID@');
        var text = $(doc).val();
        text = text.substr(0, doc.selectionStart);
        var i = text.lastIndexOf('\n');
        if (text.charAt(i + 1) == ' ') {
            var t = text.lastIndexOf(' ');
            var n = Math.round((t - i) / 4);
            var res = '';
            for (var k = 0; k < n; k++)
                res += '    ';
            return res;
        } else {
            return '';
        }
    }

    function script_get_char_@ID@() {
        var doc = document.getElementById('script_text_@ID@');
        var text = $(doc).val();
        text = text.substr(0, doc.selectionStart);
        return text.charAt(text.length - 1);
    }

    function script_save_to_db_@ID@() {
        $('#script_FORM_QUERY_@ID@').val('save');
        $('#script_form_@ID@').submit();
    }

    function script_execute_@ID@() {
        $('#script_result_@ID@').val('');
        $('#script_FORM_QUERY_@ID@').val('execute');
        $('#script_form_@ID@').submit();
    }    

    $(document).ready(function() {
        use_scrollers();
        
        $("#script_form_@ID@").ajaxForm(function(data) {
            if ($('#script_FORM_QUERY_@ID@').val() == 'save') {
                if (data == "OK")
                    $('#script_save_@ID@').prop('disabled', true);
                else
                    alert(data);
            } else
            if ($('#script_FORM_QUERY_@ID@').val() == 'execute') {
                $('#script_result_@ID@').val(data);
            }
        });
    });


</script>

<form id="script_form_@ID@" action="scripteditor" method="GET" style="position:relative;width:100%;height:100%;">
    <input name="key" type="hidden" value="@ID@">
    <input id="script_FORM_QUERY_@ID@" name="FORM_QUERY" type="hidden" value="">
    <table style="position:relative;width:100%;height:100%;" cellpadding="0" cellspacing="0">
    <tr>
        <td style="position:relative;">
            <div class="toolbar">
                <button id="script_save_@ID@" type="button" onClick="script_save_to_db_@ID@();">Сохранить</button>
                <button id="script_test_@ID@" type="button" onClick="script_execute_@ID@();">Тест</button>
            </div>
        </td>
    </tr>
    <tr style="position:relative;">
        <td style="position:relative;width:100%;height:100%;">
            <table style="position:relative;width:100%;height:100%;" cellpadding="0" cellspacing="0">
            <tr>
                <td style="position:relative;" align="left" valign="top">
                    <div style="position:relative;width:33px;height:100%;overflow:hidden;background-color:#f0f0f0;border-right:1px solid #aaaaaa;">
                        <div id="script_num_@ID@" style="position:absolute;width:100%;height:100%;margin-left:5px;margin-top:-1px;color:#555555;"></div>
                    </div>
                </td>
                <td style="position:relative;">
                    <div style="position:relative;width:5px;"></div>
                </td>
                <td style="position:relative;width:100%;height:100%;">
                    <textarea id="script_text_@ID@" name="text" wrap="off"
                              style="width:100%;height:100%;border:none;outline:none;background:none;"
                              onInput="calc_nums_@ID@();"
                              onScroll="$('#script_num_@ID@').css('top', -$(this).scrollTop() + 'px');"
                              onKeydown="script_keydown_@ID@(event)">@TEXT@</textarea>
                </td>
            </tr>
            <tr>
                <td colspan="3" style="position:relative;">
                    <div class="splitter_bottom" style="height:200px;">
                        <textarea id="script_result_@ID@" class="script_log" onKeydown="return false;"></textarea>
                    </div>
                </td>
            </tr>
            </table>
        </td>
    </tr>
    </table>
</form>
