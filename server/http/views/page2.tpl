<script type="text/javascript">

    function calcSelTabKey() {
        var url = SCRIPT_VIEW_TABS_selected_url;
        if (url) {
            var i = url.indexOf('=');
            var key = url.substr(i + 1, url.length);
            return key;
        } else {
            return false;
        }
    }

    $(document).ready(function () {
        use_splitters();
        window.addEventListener('SCRIPT_LIST_selected', function (event) {
            var key = _SCRIPT_LIST_selected_key;
            if (key) {
                var label = SCRIPT_LIST_get_label(key);
                SCRIPT_VIEW_TABS_append(label, 'scripteditor?key=' + key);
            }
        });        

        window.addEventListener('SCRIPT_VIEW_TABS_selected', function (event) {
            var url = SCRIPT_VIEW_TABS_selected_url;
            SCRIPT_LIST_selected(calcSelTabKey());
        });

        window.addEventListener('VARIABLE_HELP_LIST_selected', function (event) {
            var tabKey = calcSelTabKey();
            if (tabKey) {
                var val = VARIABLE_HELP_LIST_get_label(_VARIABLE_HELP_LIST_selected_key);
                eval("script_insert_" + tabKey + "('" + val + "')");
                document.getElementById('script_text_' + tabKey).focus();
            }
        });
    });

    function create_script() {
        $.ajax({url:'page2?FORM_QUERY=create_script'}).done(function (data) {
            a = data.split(';');
            SCRIPT_VIEW_TABS_append(a[0], 'scripteditor?key=' + a[1]);
            SCRIPT_LIST_refresh();                
        });
    }
    
</script>

<style type="text/css">
    #VARIABLE_HELP_LIST_data {
        background-color:#eeeeee;
    }
</style>

<table style="position:relative;width:100%;height:100%;border:none;" cellpadding="0" cellspacing="0">
<tr style="position:relative;">
    <td colspan="3" style="position:relative;">
        <div class="toolbar">
            <button onClick="create_script();">Создать новый скрипт...</button>
        </div>
    </td>
</tr>
<tr style="position:relative;">
    <td style="position:relative;height:100%;">
        <div class="splitter_left" style="width:300px;">
            @SCRIPT_LIST@
        </div>
    </td>
    <td style="position:relative;width:100%;height:100%;">
        @SCRIPT_VIEW_TABS@
    </td>
    <td>
        <div class="splitter_right" style="width:250px;">
            @VARIABLE_HELP_LIST@
        </div>
    </td>
</tr>
</table>
