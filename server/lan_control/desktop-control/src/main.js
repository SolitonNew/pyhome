const {BrowserWindow} = require('electron').remote;
import settings from 'electron-settings';

let fs = require('fs');

function startLoad() {
    //let ls = document.getElementById('page1');

    //let data = fs.readFileSync('src/page1.txt', 'utf-8');

    //ls.innerHTML = data;
    
    buildPage1();
}

function closeWindow() {
    window.close();
}

let settingsWindow;

function showSettings() {
    if (settingsWindow) {
        settingsWindow.focus();
        return ;
    }

    settingsWindow = new BrowserWindow({
        width: 500,
        height: 500,
        autoHideMenuBar: true,
        show: true,
        frame: false,
    });
  
    settingsWindow.loadURL(`file://${__dirname}/settingsWindow.html`);
  
    settingsWindow.on('closed', () => {
        settingsWindow = null;
    });
}

let videoWindow;

function showVideo() {
    if (videoWindow) {
        videoWindow.focus();
        return ;
    }

    videoWindow = new BrowserWindow({
        width: 800,
        height: 600,
        autoHideMenuBar: true,
        show: true,
        frame: false,
    });
  
    videoWindow.loadURL(`file://${__dirname}/video.html`);
  
    videoWindow.on('closed', () => {
        videoWindow = null;
    });
}

function showPage(num) {
    let tabs = document.getElementById('pageTabs').children;
    
    for (let i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove('active');
    }
    
    let tab = document.getElementById('tab' + num);
    tab.classList.add('active');    
    
    tab.blur();

    let pages = document.getElementById('pageContent').children;

    for (let i = 0; i < pages.length; i++) {
        pages[i].classList.remove('active');
        pages[i].classList.remove('show');
    }

    let page = document.getElementById('page' + num);
    page.classList.add('show');
    page.classList.add('active');
}

function buildPage1() {
    var a = new Array();

    for (let i = 0; i < 10; i++) {
        let s = '<div class="list-item">' +
                '<div class="item-label">VARIABLE_' + i + '</div>' +
                '<div class="custom-control custom-switch">' +
                '<input type="checkbox" class="custom-control-input" id="customSwitch' + i + '">' +
                '<label class="custom-control-label" for="customSwitch' + i + '"></label>' +
                '</div>' +
                '</div>';
        a.push(s);
    }

    let page = document.getElementById('page1');
    page.innerHTML = a.join('');
}

