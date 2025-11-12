<style type="text/css">
    a.ow_variable {
        text-decoration: none;
    }

    a.ow_variable:hover {
        text-decoration: underline;
    }

    #terminal_log p {
        padding:2px 6px;
        margin:0px;
    }    
    
</style>

<script type="text/javascript">
    $('#popup_window_border').width(820);
    $('#popup_window_title').html("1-Wire Manager");

    function create_vars_for_free() {
        $.ajax({url:'ow_manager?FORM_QUERY=create_vars_for_free'}).done(function (data) {
            if (data == 'OK') {
                OW_MANAGER_GRID_refresh();
            } else {
                alert(data);
            }
        });    
    }

    function del_ow(key) {
        if (key > 0) {
            alert('CONFIRM: Are You Sure?', 'yes,no', function (res) {
                if (res == 'yes') {
                    $.ajax({url:'ow_manager?FORM_QUERY=delete&key=' + key}).done(function (data) {
                        if (data == 'OK') {
                            OW_MANAGER_GRID_refresh();
                        } else {
                            alert(data);
                        }
                    });
                }
            });
        }
    }

    function send_query(query_data, view_id) {        
        sysdialog_canclose = false;
        status_view_id = view_id;
        $('#' + status_view_id).html('');
        $.ajax({url:'system_dialog?FORM_QUERY=' + query_data}).done(function (data) {
            if (data == 'START_TERMINAL') {
                $('#terminal_bg').fadeIn(300);
                load_terminal_log();
            } else {        
                $('#' + status_view_id).html(data);
            }            
        });
    }

    function load_terminal_log() {
        $.ajax({url:'system_dialog?FORM_QUERY=load_terminal'}).done(function (data) {
            if (data.indexOf("TERMINAL EXIT") > 0) {
                OW_MANAGER_GRID_refresh();
                var btn = '<button style="margin:20px;" onClick="$(\'#terminal_bg\').fadeOut(300);">Close Terminal</button>';
                $('#terminal_log').append(btn);
            } else {
                $('#terminal_log').html(data);
                setTimeout(load_terminal_log, 100);
            }
        });
    }
</script>

<div style="position:relative;">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>
    <TR>
        <TD colspan="2">
            <div class="toolbar">
                <table width="100%" cellpadding="0" cellspacing="0" style="padding-right:10px;">
                <tr>
                    <td><button onClick="send_query('SCAN_OW', 'OW_STATUS')" style="white-space: nowrap;">Scan 1-Wire Network...</button></td>
                    <td width="100%"><button onClick="create_vars_for_free();">Create variables for free OW devices</button></td>
                    <td><button onClick="del_ow(_OW_MANAGER_GRID_selected_key);">Delete</button></td>
                </tr>
                </table>
            </div>
        </TD>
    </TR>    
    <TR>
        <TD colspan="2">
            <div style="position:relative;height:500px;width:100%;">
                {{ widget('OW_MANAGER_GRID') }}
            </div>
        </TD>
    </TR>
    <TR>
        <TD colspan="2" align="right" valign="bottom" height="60">
            <button onClick="hide_window()">Close</button>
        </TD>
    </TR>
    </table>

    <div id="terminal_bg" style="position:absolute;left:0px;top:0px;width:100%;height:100%;background-color:#fff;display:none;">
        <div style="position:absolute;width:100%;height:100%;background-color:#fff;opacity:0.4;">
        </div>
        <div id="terminal_log" style="position:absolute;width:100%;height:100%;background-color:#000;color:#fff;overflow:none;overflow-y:auto;text-align:left;font-family:monospace;">
        </div>
    </div>
</div>
