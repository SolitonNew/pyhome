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
    $('#popup_window_title').html("Системные утилиты");

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
                var btn = '<button style="margin:20px;" onClick="$(\'#terminal_bg\').fadeOut(300);">Закрыть терминал</button>';
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
                $('#COMM_TEXT').val('');
            } else {
                alert(data);
            }
        });        
    }
</script>

<div style="position:relative;background-color:#fff;border: 10px solid #fff;">
    <table cellpadding="0" cellspacing="10" width="100%">
    <TR>
        <TD></TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                Выполнить команду:
                <table width="100%" cellpadding="5" cellspacing="0">
                <tr>
                    <td width="100%"><input type="text" id="COMM_TEXT" style="width:100%;"/></td>
                    <td><button onClick="send_command();">Выполнить</button></td>
                </tr>
                </table>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                <div>
                    <button onClick="send_query('SYNC_TOGGLE', 'SYNC_STATUS')">Остановить/Запустить синхронизацию</button>
                    &nbsp;&nbsp;&nbsp;&nbsp;Текущий статус: <B><span id="SYNC_STATUS">@SYNC_STATUS@</span></B>
                </div>
                <p>
                Если выполнена полная остановка синхронизации данных между
                контроллерами и сервером, то контроллеры, не имея доступа к
                данным других устройств будут работать в автономном режиме
                обслуживая только подключенные к ним устройства.
                </p>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                <div>
                    <button onClick="send_query('CONFIG_UPDATE', 'CONFIG_STATUS')">Загрузить файл конфигурации</button>
                </div>
                <p>
                После предварительной настройки системы необходимо выполнить
                загрузку конфигурационного файла. Иначе никакие изменения не
                будут применены.<BR>
                <b>Примечание:</b> Запущеная синхронизация переменных без
                предварительной передачи конфигурационных файлов может
                негативно сказаться на поведении системы.
                </p>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            <div class="group">
                <div>
                    <button onClick="send_query('REBOOT_CONTROLLERS', 'REBOOT_STATUS')">Принудительная перезагрузка контроллеров</button>
                </div>
                <p>
                После выполнения всех необходимых настроечных действий
                необходимо выполнить полную перезагрузку компонентов системы.
                </p>
            </div>
        </TD>
    </TR>
    <TR>
        <TD>
            Расчетное потребление системы: <B>@CURRENTLY@</B>
        </TD>
    </TR>
    <TR>
        <TD align="right" valign="bottom" height="60">
            <button onClick="hide_window()">Закрыть</button>
        </TD>
    </TR>
    </table>

    <div id="terminal_bg" style="position:absolute;left:0px;top:0px;width:100%;height:100%;background-color:#fff;display:none;">
        <div style="position:absolute;width:100%;height:100%;background-color:#fff;opacity:0.4;">
        </div>
        <div id="terminal_log" style="position:relative;width:100%;height:100%;background-color:#000;color:#fff;overflow:none;overflow-y:auto;text-align:left;">
        </div>                    
    </div>
</div>
