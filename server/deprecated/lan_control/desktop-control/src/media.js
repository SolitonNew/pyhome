let mediaExts = new Array();     // "AVI;MP4;MKV;MP3;WAV;JPG;TIFF;PSD"
let mediaGroups = new Array();   // ["9", "1", "AFI"]
let mediaData = new Array();     // ["29167", "10", "MUSIKS - 02 - 01 - Real Gone.mp3", "D:\Media\MUSIKS\02\01 - Real Gone.mp3", "2"]


function buildMediaGroups() {
    //
}

function buildMedia() {
    let ls = new Array();
    
    for (let i = 0; i < mediaData.length; i++) {
        let o = mediaData[i];
        
        ls.push(
            '<div id="mediaID_' + o[0] + '" class="list-item">' +
                '<div class="media-name">' + o[2] + '</div>' +
                '<img src="">' +
            '</div>'
        );
    }

    let page = document.getElementById('page5');
    page.innerHTML = ls.join('');
    
    $('#page5 div.list-item').on('click', (event) => {
        $('#page5 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
}
