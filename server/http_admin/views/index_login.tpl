<!DOCTYPE html>
<html>
<head>
    <title></title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <script type="text/javascript" src="jquery-2.1.4.js"></script>
    <script type="text/javascript" src="javalib.js"></script>
    <link rel="stylesheet" type="text/css" href="default.css">

    <style type="text/css">
        body {
            padding:0px;
            margin:0px;
            font-family:Arial;
            font-size:13px;
            overflow:hidden;
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function() {
        }); 
    });
    </script>
</head>

<body>
    <table style="position:absolute;" width="100%" height="80%" cellpadding="0" cellspacing="0">
    <tr>
        <td align="center" valign="middle">
            <div style="width:300px; border:5px solid #f7f7f7; background-color: #f7f7f7;">
            <form method="GET">
                <input type="hidden" name="FORM_QUERY" value="login">
                <table width="100%" height="100%" cellpadding="0" cellspacing="0">
	        <tr>
	            <td bgcolor="#999999">
                        <div style="padding:5px;color:#ffffff;">
                            Вход в систему
                        </div>
	            </td>
                </tr>
	      	<tr>
                    <td>
                        <table width="100%" height="100%" cellpadding="0" cellspacing="10">
                        <tr>
                            <td colspan="2" height="1"></td>
                        </tr>
                        <tr>
                            <td>Логин:</td>
                            <td><input name="wh_login" type="text" style="width:140px;" autofocus></td>
                        </tr>
                        <tr>
                            <td>Пароль:</td>
                            <td><input name="wh_pass" type="password" style="width:140px;"></td>
                        </tr>
                        <tr>
                            <td colspan="2" height="40" valign="bottom" align="right"><button type="submit">Готово</button></td>
                        </tr>
                        </table>
	   	    </td>
	        </tr>
	        </table>
	    </form>
            </div>
        </td>
    </tr>
    </table>
</body>

</html>
