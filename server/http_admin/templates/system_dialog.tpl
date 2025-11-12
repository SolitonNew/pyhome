<style type="text/css">
    div.group {
        position:relative;
        padding:5px;
        margin-left:-5px;
        width:100%;
        border: 1px solid #ccc;
    }

    div.group p {
        margin:0px;
        padding:5px 0;
        color:#777;
    }

    #terminal_log p {
        padding:2px 6px;
        margin:0px;
    }
    
</style>

<script type="text/javascript">
    $('#popup_window_border').width(500);
    $('#popup_window_title').html("System Utilities");

    var status_view_id = '';

    function send_query(query_data, view_id) {        
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
                var btn = '<button style="margin:20px;" onClick="$(\'#terminal_bg\').fadeOut(300);">Close Terminal</button>';
                $('#terminal_log').append(btn);
            } else {
                $('#terminal_log').html(data);
                setTimeout(load_terminal_log, 100);
            }
        });
    }

    function sysdialog_close() {
        $('#terminal_bg').fadeOut(300)
    }

    function send_command() {
        $.ajax({url:'system_dialog?FORM_QUERY=SEND_COMMAND&COMM_TEXT=' + $('#COMM_TEXT').val()}).done(function (data) {
            if (data == 'OK') {
                //$('#COMM_TEXT').val('');
            } else {
                alert(data);
            }
        });        
    }

    $(document).ready(function() {
        $("#command_form").ajaxForm(); 
    });
    
</script>

<div style="position:relative;background-color:#fff;border: 10px solid #fff;">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD></TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                Command Execute:
                <form id="command_form" action="system_dialog" method="GET">
                <table width="100%" cellpadding="5" cellspacing="0">
                <tr>
                    <td width="100%">
                        <input type="text" id="COMM_TEXT" name="COMM_TEXT" style="width:100%;"/>
                        <input type="hidden" name="FORM_QUERY" value="SEND_COMMAND">                        
                    </td>
                    <td><button type="submit">Execute</button></td>
                </tr>
                </table>
                </form>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                <div>
                    <button onClick="send_query('SYNC_TOGGLE', 'SYNC_STATUS')">Stop/Start synchronization</button>
                    &nbsp;&nbsp;&nbsp;&nbsp;Current Status: <B><span id="SYNC_STATUS">{{ widget('SYNC_STATUS') }}</span></B>
                </div>
                <p>
                    If a complete stop of data synchronization between the controllers and the server is performed, then the controllers, not having access to data from other devices, will operate in autonomous mode, servicing only the devices connected to them.
                </p>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                <div>
                    <button onClick="send_query('CONFIG_UPDATE', 'CONFIG_STATUS')">Upload Config File</button>
                </div>
                <p>
                    After the initial system setup, you need to load the configuration file. Otherwise, no changes will be applied.<br>
                    <b>Note:</b> Running variable synchronization without first transferring the configuration files may negatively affect the system’s behavior.
                </p>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                <div>
                    <button onClick="send_query('REBOOT_CONTROLLERS', 'REBOOT_STATUS')">Forced controller reboot</button>
                </div>
                <p>
                    After completing all the necessary configuration steps, a full system component reboot must be performed.
                </p>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            Estimated system consumption: <B>{{ widget('CURRENTLY') }}</B>
        </TD>
    </TR>
    <TR>
        <TD align="right" valign="bottom" height="60">
            <button onClick="hide_window()">Close</button>
        </TD>
    </TR>
    </table>

    <div id="terminal_bg" style="position:absolute;left:0px;top:0px;width:100%;height:100%;background-color:#fff;display:none;">
        <div style="position:absolute;width:100%;height:100%;background-color:#fff;opacity:0.4;">
        </div>
        <div id="terminal_log" style="position:relative;width:100%;height:100%;background-color:#000;color:#fff;overflow:none;overflow-y:auto;text-align:left;font-family:monospace;">
        </div>                    
    </div>
</div>
