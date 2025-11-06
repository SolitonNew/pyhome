<style>
    textarea.script_log {
        position:relative;
        width:100%;
        height:100%;
        background-color:#000000;
        color:#00ff00;
    }
</style>

<script type="text/JavaScript">
    calc_nums_{{ widget('ID') }}();
    $('#script_save_{{ widget('ID') }}').prop('disabled', true);

    function calc_nums_{{ widget('ID') }}() {
        $('#script_save_{{ widget('ID') }}').prop('disabled', false);

        var v = $('#script_text_{{ widget('ID') }}').val();        
        var c = 1;        
        for (var i = 0; i < v.length; i++)
            if (v.charAt(i) == '\n') c++;        
        var s = '';
        for (i = 1; i <= c; i++) {
            s += i + '<br>';
        }
        $('#script_num_{{ widget('ID') }}').html(s);
    }

    function script_keydown_{{ widget('ID') }}(event) {
        switch (event.keyCode) {
            case 9: // Tab
                event.stopPropagation();
                event.preventDefault();
                script_insert_{{ widget('ID') }}('    ');
                break;
            case 13: // Enter
                var line_tabs = script_calc_line_tab_{{ widget('ID') }}();
                event.stopPropagation();
                event.preventDefault();
                if (script_get_char_{{ widget('ID') }}() == ':')
                    script_insert_{{ widget('ID') }}('\n    ' + line_tabs);
                else
                    script_insert_{{ widget('ID') }}('\n' + line_tabs);
                break;
            case 83:
                if (event.ctrlKey) {
                    event.stopPropagation();
                    event.preventDefault();
                    script_save_to_db_{{ widget('ID') }}();
                }
                break;
            case 8: // Backspace
                var doc = document.getElementById('script_text_{{ widget('ID') }}');
                if (doc.selectionEnd - doc.selectionStart == 0) {
                    var text = $(doc).val();
                    text = text.substr(0, doc.selectionStart);
                    if (text.charAt(text.length - 1) != ' ') {
                        //script_clear_{{ widget('ID') }}(1);
                    } else {
                        event.stopPropagation();
                        event.preventDefault();                        
                        var i = text.lastIndexOf('\n');                    
                        text = text.substr(i - 1, text.length);                    
                        for (var k = 0; k < text.length; k++) {
                            if (text.charAt(k) != ' ') {
                                script_clear_{{ widget('ID') }}(1);
                                break;
                            }
                        }
                        var c = Math.trunc(text.length / 4) * 4;
                        script_clear_{{ widget('ID') }}(text.length - c + 1);
                    }
                }
                break;
            //default:
            //   alert(event.keyCode + '');
        }
    }

    function script_insert_{{ widget('ID') }}(text) {
        var doc = document.getElementById('script_text_{{ widget('ID') }}');
        var i = doc.selectionStart;
        var s = $(doc).val();        
        s = s.substr(0, i) + text + s.substr(i);
        $(doc).val(s);
        doc.selectionStart = i + text.length;
        doc.selectionEnd = doc.selectionStart;
        calc_nums_{{ widget('ID') }}();
    }

    function script_clear_{{ widget('ID') }}(chars) {
        var doc = document.getElementById('script_text_{{ widget('ID') }}');
        var i = doc.selectionStart;
        var s = $(doc).val();        
        s = s.substr(0, i - chars) + s.substr(i);
        $(doc).val(s);
        doc.selectionStart = i - chars;
        doc.selectionEnd = doc.selectionStart;
        calc_nums_{{ widget('ID') }}();
    }

    function script_calc_line_tab_{{ widget('ID') }}() {
        var doc = document.getElementById('script_text_{{ widget('ID') }}');
        var text = $(doc).val();
        text = text.substr(0, doc.selectionStart);
        var i = text.lastIndexOf('\n');
        if (text.charAt(i + 1) == ' ') {
            var t = i;
            for (var k = i + 1; k < text.length; k++) {
                if (text.charAt(k) == ' ')
                    t++;
                else
                    break;
            }            
            var n = Math.round((t - i) / 4);
            var res = '';
            for (var k = 0; k < n; k++)
                res += '    ';
            return res;
        } else {
            return '';
        }
    }

    function script_get_char_{{ widget('ID') }}() {
        var doc = document.getElementById('script_text_{{ widget('ID') }}');
        var text = $(doc).val();
        text = text.substr(0, doc.selectionStart);
        return text.charAt(text.length - 1);
    }

    function script_save_to_db_{{ widget('ID') }}() {
        $('#script_FORM_QUERY_{{ widget('ID') }}').val('save');
        $('#script_form_{{ widget('ID') }}').submit();
        SCRIPT_LIST_refresh();
        SCRIPT_VIEW_TABS_rename($('#script_NAME_{{ widget('ID') }}').val(), 'scripteditor?key={{ widget('ID') }}');
    }

    function script_execute_{{ widget('ID') }}() {
        $('#script_result_{{ widget('ID') }}').val('');
        $('#script_FORM_QUERY_{{ widget('ID') }}').val('execute');
        $('#script_form_{{ widget('ID') }}').submit();
    }

    function script_delete_{{ widget('ID') }}() {
        var s = $('#script_NAME_{{ widget('ID') }}').val();
        alert('Delete script "' + s + '"?', ',yes,no,', function (res) {
            if (res == 'yes') {
                $('#script_FORM_QUERY_{{ widget('ID') }}').val('delete');
                $('#script_form_{{ widget('ID') }}').submit();
            }
        });
    }

    $(document).ready(function() {
        use_splitters();
        
        $("#script_form_{{ widget('ID') }}").ajaxForm(function(data) {
            if ($('#script_FORM_QUERY_{{ widget('ID') }}').val() == 'save') {
                if (data == "OK") {
                    $('#script_save_{{ widget('ID') }}').prop('disabled', true);
                } else {
                    alert(data);
                }
            } else
            if ($('#script_FORM_QUERY_{{ widget('ID') }}').val() == 'execute') {
                $('#script_result_{{ widget('ID') }}').val(data);
            } else
            if ($('#script_FORM_QUERY_{{ widget('ID') }}').val() == 'delete') {
                if (data == "OK") {
                    SCRIPT_VIEW_TABS_close(SCRIPT_VIEW_TABS_num('scripteditor?key={{ widget('ID') }}'));
                    SCRIPT_LIST_refresh();
                } else {
                    alert(data);
                }
            }
        });
    });


</script>

<form id="script_form_{{ widget('ID') }}" action="scripteditor" method="GET" style="position:relative;width:100%;height:100%;">
    <input name="key" type="hidden" value="{{ widget('ID') }}">
    <input id="script_FORM_QUERY_{{ widget('ID') }}" name="FORM_QUERY" type="hidden" value="">
    <table style="position:relative;width:100%;height:100%;" cellpadding="0" cellspacing="0">
    <tr>
        <td style="position:relative;">
            <div class="toolbar">
                <table style="position:relative;width:100%;" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="10"></td>
                    <td>
                        <input id="script_NAME_{{ widget('ID') }}" type="text" name="NAME" style="width:120px;"
                               value="{{ widget('NAME') }}" onInput="calc_nums_{{ widget('ID') }}();">
                        <button id="script_save_{{ widget('ID') }}" type="button" onClick="script_save_to_db_{{ widget('ID') }}();">Save</button>
                        <button id="script_test_{{ widget('ID') }}" type="button" onClick="script_execute_{{ widget('ID') }}();">Test</button>
                        <button id="script_events_{{ widget('ID') }}" type="button" onClick="show_window('attach_event_dialog?key={{ widget('ID') }}');">Attach as Event...</button>
                    </td>
                    <td align="right">
                        <button type="button" onClick="script_delete_{{ widget('ID') }}();">Delete</button>
                    </td>
                    <td width="10"></td>
                </tr>
                </table>
            </div>
        </td>
    </tr>
    <tr style="position:relative;">
        <td style="position:relative;width:100%;height:100%;">
            <table style="position:relative;width:100%;height:100%;" cellpadding="0" cellspacing="0">
            <tr>
                <td style="position:relative;" align="left" valign="top">
                    <div style="position:relative;width:33px;height:100%;overflow:hidden;background-color:#f0f0f0;border-right:1px solid #aaaaaa;">
                        <div id="script_num_{{ widget('ID') }}" style="position:absolute;width:100%;height:100%;margin-left:5px;margin-top:-1px;color:#555555;"></div>
                    </div>
                </td>
                <td style="position:relative;">
                    <div style="position:relative;width:5px;"></div>
                </td>
                <td style="position:relative;width:100%;height:100%;">
                    <textarea id="script_text_{{ widget('ID') }}" name="text" wrap="off"
                              style="width:100%;height:100%;border:none;outline:none;background:none;"
                              onInput="calc_nums_{{ widget('ID') }}();"
                              onScroll="$('#script_num_{{ widget('ID') }}').css('top', -$(this).scrollTop() + 'px');"
                              onKeydown="script_keydown_{{ widget('ID') }}(event)">{{ widget('TEXT') }}</textarea>
                </td>
            </tr>
            <tr>
                <td colspan="3" style="position:relative;">
                    <div class="splitter_bottom" style="height:200px;">
                        <textarea id="script_result_{{ widget('ID') }}"
                                  class="script_log"
                                  onKeydown="return false;"
                                  readonly></textarea>
                    </div>
                </td>
            </tr>
            </table>
        </td>
    </tr>
    </table>
</form>
