<!DOCTYPE html>
<HTML>
<HEAD>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="shortcut icon" href="{{ url_for('static', filename='favicon.ico') }}">
    <script type="text/javascript" src="{{ url_for('static', filename='jquery-2.1.4.js') }}"></script>
    <script type="text/javascript" src="{{ url_for('static', filename='jquery.json.js') }}"></script>
    <script type="text/javascript" src="{{ url_for('static', filename='jquery.form.js') }}"></script>    
    <script type="text/javascript" src="{{ url_for('static', filename='app.js') }}"></script>

    <script type="text/javascript">
        function log_out() {
            $.ajax({url:'index_login?FORM_QUERY=logout'}).done(function (data) {
                $(document).html(data);
            });
        }

        var last_id = -1;
    
        function load_event_list() {
            var q = $.ajax({url:'eventlist?FORM_QUERY=last_id'});
            q.done(function(data) {
                if (data > last_id) {
                    last_id = data;
                    var q_list = $.ajax({url:'eventlist?FORM_QUERY=list'});
                    q_list.done(function (data) {
                        $('#event_list').html(data);
                        setTimeout(load_event_list, 1000);
                        VARIABLE_LIST_refresh();
                    });
                    q_list.fail(function () {setTimeout(load_event_list, 500)});
                } else {
                    setTimeout(load_event_list, 1000);
                }
            });
            q.fail(function () {setTimeout(load_event_list, 500)});
        }
        load_event_list();

        function check_sync() {
            var q = $.ajax({url:'system_dialog?FORM_QUERY=SYNC_CHECK&rnd=' + Math.random()});
            q.done(function (data) {
                if (data != 'OK') {
                    $('#sync_check').css('display', 'inline-block');
                } else {
                    $('#sync_check').css('display', 'none');
                }
                setTimeout(check_sync, 5000);
            });
            q.fail(function () {setTimeout(check_sync, 5000)});
        }
        check_sync();
        
    </script>
    
    <style type="text/css">
        body {
            padding:0px;
            margin:0px;
            font-family:Arial;
            font-size:13px;
            overflow:hidden;
        }

        table {
            position:relative;
            border:none;
            padding:0px;
            margin:0px;
        }

        select {
            position:relative;
            padding:0px;
            margin:0px;
            border:1px solid #cccccc;
        }

        textarea {
            position:relative;
            padding:0px;
            margin:0px;
            border:1px solid #cccccc;
        }

        div.splitter_left {
            position:relative;
            border-right: 8px solid #ccc;
            height:100%;
            cursor:w-resize;
        }        

        div.splitter_top {
            position:relative;
            border-bottom: 8px solid #ccc;
            width:100%;
            cursor:n-resize;
        }

        div.splitter_right {
            position:relative;
            border-left: 8px solid #ccc;
            height:100%;
            cursor:e-resize;
        }

        div.splitter_bottom {
            position:relative;
            border-top: 8px solid #ccc;
            width:100%;
            cursor:s-resize;
        }

        table.tab_control {
            position:relative;
            width:100%;
            height:100%;
        }

        table.tab_control tr {
            position:relative;
        }        

        table.tab_control tr td {
            position:relative;
        }

        div.page_tab_top, div.page_tab_bottom {
            position:relative;
            display:inline-block;
            padding:7px 14px;
            margin: 0px;
            margin-left:5px;
            margin-top:5px;
            border: 1px solid #cccccc;
            border-bottom:none;
            cursor: default;
            background-color: #eeeeee;
        }

        div.page_tab_bottom {
            margin-top:0;
            margin-bottom:5px;
            border: 1px solid #cccccc;
            border-top:none;
        }

        div.page_tab:hover {
            opacity:0.7;
        }

        div.page_tab_sel {
            background-color: #ffffff;
        }

        div.page_tab_top button, div.page_tab_bottom button {
            width:16px;
            height:16px;
            margin:-10px;
            margin-left:15px;
            margin-right:-5px;
            font-size:10px;
            padding:0px;
        }

        div.page_data {
            position:relative;
            top:0px;
            left:0px;
            width:100%;
            height:100%;
            display:none;
            background-color: #ffffff;
            border-top:1px solid #cccccc;
            border-bottom:1px solid #cccccc;
            cursor: default;
        }

        div.toolbar {
            position:relative;
            width:100%;
            padding:0px;
            background-color:#dddddd;
        }

        div.toolbar button {
            margin:10px 7px;
            margin-right:0px;
        }


        div.list_control {
            position:absolute;
            background-color: #ffffff;
            #border:1px solid #eeeeee;
            width:100%;
            height:100%;
            overflow: hidden;
            overflow-y: auto;
            cursor:default;
        }

        div.list_control table {
            position:relative;
            width:100%;
        }

        div.list_control td {
            position:relative;
            padding:3px;
            padding-right:5px;            
            width:100%;
        }

        div.list_control td div {
            position:relative;
            padding:5px;
            width:100%;
        }        

        div.list_control td:hover {
            background-color:#f3f3f3;
        }

        tr.list_control_selected {
            background-color:#f3f3f3;
        }        
        

        table.grid_control {
            position:relative;
            background-color: #ffffff;
            border:1px solid #eeeeee;
            width:100%;
            height:100%;
            cursor: default;
        }
        
        table.grid_header {
            position:relative;
            background-color: #eeeeee;
        }

        table.grid_header td {
            text-align:center;
            background-color: #eeeeee;
            border-right:1px solid #dddddd;
            border-bottom:1px solid #dddddd;
        }        

        table.grid_header td div {
            padding:5px;
        }

        table.grid_data {
            position:relative;
            background-color: #ffffff;
        }

        table.grid_data tr:hover {
            background-color:#f3f3f3;
        }

        tr.grid_data_selected {
            background-color:#f3f3f3;
        }                

        table.grid_data td {
            text-align:center;
            border-right:1px solid #dddddd;
            border-bottom:1px solid #dddddd;
        }

        table.grid_data td div {
            padding:5px;
        }

        div.grid_data_content {
            position:absolute;
            width:100%;
            height:100%;
            overflow:auto;
        }

        div.chart_control {
            position:relative;
            background-color:#ffffff;
            width:100%;
            height:100%;
        }

        div.chart_control div {
            position: absolute;
            width:3px;
            height:3px;
            background-color:#ff0000;
        }
        
    </style>    
</HEAD>

<BODY>
    <table style="position:absolute;width:100%;height:100%;" cellpadding="0" cellspacing="0">
    <tr style="position:relative;height:100%;">
        <td style="position:relative;width:100%;height:100%;">
            <table style="position:relative;width:100%;height:100%;" cellpadding="0" cellspacing="0">
            <tr>
                <td style="position:relative;background-color:#cccccc;">
                    <div style="margin:10px;font-size:25px;">
                        <b>WISE HOUSE v{{ widget('VERSION') }}</b>
                    </div>                    
                </td>
                <td style="position:relative;background-color:#cccccc;" align="right" valign="middle">
                    <div id="sync_check" style="display:none;padding:5px;width:170px;background-color:#00ff00;text-align:center;">
                        ЕСТЬ ИЗМЕНЕНИЯ В БД
                    </div>
                    <button onClick="show_window('ow_manager')">Менеджер OneWire...</button>
                    <button onClick="show_window('system_dialog')">Системные утилиты...</button>
                    <button onClick="log_out();" style="margin-right:5px;">Выход</button>
                </td>                
            </tr>
            <tr style="position:relative;height:100%;">
                <td colspan="2" style="position:relative;height:100%;">
                     {{ widget('TAB_CONTROL') }}
                </td>
            </tr>
            </table>            
        </td>
        <td style="position:relative;height:100%;">            
            <div class="splitter_right" style="width:350px;">
                <div id="event_list" style="position:absolute;cursor:default;width:100%;height:100%;overflow:hidden;color:#ffffff;background-color:#000000;" onMouseDown="return false;">
                </div>
            </div>
        </td>        
    </tr>
    </table>

    <div id="popup_window" style="position:absolute;left:0px;top:0px;width:100%;height:100%;display:none;">
        <div style="position:absolute;left:0px;top:0px;background-color:#000;width:100%;height:100%;opacity:0.2;color:#fff;"></div>
        <table width="100%" height="80%" style="position:relative;left:0px;top:0px;">
        <tr>
            <td align="center" valign="middle">
                <div id="popup_window_border" style="width:300px; border:5px solid #f7f7f7; background-color: #f7f7f7;">
                    <table width="100%" height="100%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td bgcolor="#999999">
                            <div id="popup_window_title" style="padding:5px;color:#ffffff;"></div>
                        </td>
                    </tr>
                    <tr>
                        <td id="popup_window_content"></td>
                    </tr>
                    </table>
                </div>
            </td>
        </tr>
	</table>
    </div>

    <div id="popup_alert" style="position:absolute;left:0px;top:0px;width:100%;height:100%;display:none;">
        <div style="position:absolute;left:0px;top:0px;background-color:#000;width:100%;height:100%;opacity:0.2;color:#fff;"></div>
        <table width="100%" height="80%" style="position:relative;left:0px;top:0px;">
        <tr>
            <td align="center" valign="middle">
                <div style="width:400px; border:5px solid #f7f7f7; background-color: #f7f7f7;">
                    <table width="100%" height="100%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td bgcolor="#999999">
                            <div id="popup_alert_title" style="padding:5px;color:#ffffff;"></div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%" height="100%" cellpadding="0" cellspacing="20">
			    <tr>
                                <td align="left" valign="top">
                                    <div id="popup_alert_content" style="padding:10px;"></div>
                                </td>
                            </tr>
                            <tr>
                                <td height="40" align="center" valign="bottom">
                                    <button id="alert_ok" type="button" onClick="alert_click('ok');">Ок</button>
                                    <button id="alert_yes" type="button" onClick="alert_click('yes');">Да</button>
                                    <button id="alert_no" type="button" onClick="alert_click('no');">Нет</button>
                                    <button id="alert_cancel" type="button" onClick="alert_click('cancel');">Отмена</button>
                                </td>
                            </tr>
                            </table>
                        </td>
                    </tr>
                    </table>
                </div>
            </td>
        </tr>
        </table>
    </div>

    <div id="tool_tip_container" style="position:absolute;background-color:#FFFFB9;border: 1px solid #aaaaaa;padding:5px 8px;display:none;">
    </div>

    <div id="splitter_bg" style="position:absolute;background-color:#000000;left:0px;top:0px;width:100%;height:100%;display:none;opacity:0;">
    </div>
</BODY>
