const http = require('http');

function initHTTP() {
    http.createServer(function (request, response) {
        let fs = require('fs');
        let file = request.url;
        let id = -1;
        try {
            id = parseInt(file);
        } catch(e) {}
        
        if (id > 0) { // Секция для отдачи моих медиаданных
            
        } else { // Секйия для отдачи звуковых (и только) треков
            let ext = file.substring(file.length - 4).toUpperCase();
            let ext_ok = (['.MP3', '.WAV'].indexOf(ext) > -1);
            let appData = app.getPath('appData');
            let path_ok = (file.indexOf('./') == -1) && 
                          (file.indexOf('~/') == -1) && 
                          (file.substring(0, appData.length) == appData);
            if (ext_ok && path_ok) {
                fs.createReadStream(request.url).pipe(response);                
            } else {
                response.writeHead(404);
            }
        }
    }).listen(8092);
}
