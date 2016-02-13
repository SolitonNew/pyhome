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
    $('#popup_window_border').width(980);
    $('#popup_window_title').html("Менеджер OneWire");

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
        alert('CONFIRM: Удалить OneWire устройство?', 'yes,no', function (res) {
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

    var sysdialog_canclose = false;

    function load_terminal_log() {
        $.ajax({url:'system_dialog?FORM_QUERY=load_terminal'}).done(function (data) {
            if (data.indexOf("TERMINAL EXIT") > 0) {
                OW_MANAGER_GRID_refresh();
                sysdialog_canclose = true;
                setTimeout(function () {$('#terminal_bg').fadeOut(3000)}, 2000);
            } else {
                $('#terminal_log').html(data);
                setTimeout(load_terminal_log, 500);
            }
        });
    }

    function sysdialog_close() {
        if (sysdialog_canclose) {
            $('#terminal_bg').fadeOut(300)            
        }
    }    
</script>

<div style="position:relative;">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD colspan="2"></TD>
    </TR>    
    <TR>
        <TD colspan="2">
            <div style="position:relative;height:500px;width:100%;">
                @OW_MANAGER_GRID@
            </div>
        </TD>
    </TR>
    <TR>
        <TD valign="top">
            <button onClick="send_query('SCAN_OW', 'OW_STATUS')">Просканировать OW сети...</button>
            <button onClick="create_vars_for_free();">Создать переменные для свободных OW устройств</button>
        </TD>
        <TD align="right" valign="bottom" height="60">
            <button onClick="hide_window()">Закрыть</button>
        </TD>
    </TR>
    </table>

    <div id="terminal_bg" style="position:absolute;left:0px;top:0px;width:100%;height:100%;background-color:#fff;display:none;">
        <div style="position:absolute;width:100%;height:100%;background-color:#fff;opacity:0.4;">
        </div>
        <div id="terminal_log" style="position:absolute;width:100%;height:100%;background-color:#000;color:#fff;overflow:none;overflow-y:auto;text-align:left;" onClick="sysdialog_close();">
        </div>
    </div>
</div>
