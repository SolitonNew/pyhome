const http = require('http');

function initHTTP() {
    http.createServer(function (request, response) {
        let fs = require('fs');
        fs.createReadStream(request.url).pipe(response);
    }).listen(8092);
    
    
    //document.getElementById('audioSpeech').src = 'http://127.0.0.1:8092/home/soliton/.config/Electron/audio/n.wav';
}
