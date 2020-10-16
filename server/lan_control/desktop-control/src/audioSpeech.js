let audioSpeechQueue = new Array();
let audioSpeechPlayer;
let audioSpeechPlayerMuted = false;
let audioSpeechNotifyPlayed = false;

function audioSpeechPlayFirst() {
    if (audioSpeechQueue.length == 0) {
        audioSpeechNotifyPlayed = false;
        return ;
    }
    
    if (audioSpeechPlayer) {
        return ;
    }
    
    let file = audioSpeechQueue[0];
    const fs = require('fs');
    if (!fs.existsSync(file)) {
        setTimeout(() => {
            audioSpeechPlayFirst();
        }, 50);
        return ;
    }
    
    if (getVariableValueAtId(123) == '1.0') {
        audioSpeechQueue = new Array();
        return ;
    }
    
    if (file.indexOf('/alarm.wav') > -1) {
        audioSpeechNotifyPlayed = false;
    } else
    if (file.indexOf('/notify.wav') > -1) {
        if (audioSpeechNotifyPlayed) {
            audioSpeechQueue.shift(0, 1);
            if (audioSpeechQueue.length == 0) {
                return ;
            }
            file = audioSpeechQueue[0];
        } else {
            audioSpeechNotifyPlayed = true;
        }
    }
    
    audioSpeechPlayer = new Audio('http://127.0.0.1:8092' + file);
    audioSpeechSetVolume();
    $(audioSpeechPlayer).on('ended', (event) => {
        audioSpeechQueue.shift(0, 1);
        audioSpeechPlayer = null;
        audioSpeechPlayFirst();
    });
    
    audioSpeechPlayer.play().catch((error) => {
        audioSpeechQueue.shift(0, 1);
        audioSpeechPlayer = null;
        audioSpeechPlayFirst();
    });
}

function audioSpeechSetVolume() {
    if (audioSpeechPlayer) {
        audioSpeechPlayer.volume = $('#audioVolume').val() / 100;
        if (audioSpeechPlayerMuted) {
            audioSpeechPlayer.muted = true;
        } else {
            audioSpeechPlayer.muted = false;
        }
    }
}

function audioSpeechFileNameAtId(id) {
    let fs = require('fs');
    const path = app.getPath('userData') + '/audio';
    
    if (!fs.existsSync(path)) {
        fs.mkdirSync(path);
    }
    
    let file = path + '/' + id;
    if (file.length > 4 && file.substring(file.length - 4).toUpperCase() == '.MP3') {
        // It is MP3
    } else {
        file = file + '.wav';
    }
    
    return file;
}

function storeAudioSpeech(id, data) {
    let file = audioSpeechFileNameAtId(id);
    let fs = require('fs');
    
    function decodeHex(s) {
        const a = ['0', '1', '2', '3', 
                   '4', '5', '6', '7', 
                   '8', '9', 'a', 'b', 
                   'c', 'd', 'e', 'f'];
        return a.indexOf(s);
    }
        
    let f_data = new Uint8Array(data.length / 2);
    let k = 0;
    for (let i = 0; i < data.length / 2; i++) {
        let n1 = decodeHex(data[k]);
        k++;
        let n2 = decodeHex(data[k]);
        k++;        
        f_data[i] = (n1 << 4) + n2;
    }
    
    fs.writeFileSync(file, Buffer.from(f_data));
}

function audioSpeechAppendToQueue(fileID) {
    let file = audioSpeechFileNameAtId(fileID);
    audioSpeechQueue.push(file);
    
    let fs = require('fs');
    if (!fs.existsSync(file)) {
        metaQuery('audio data', fileID);
    }
}
