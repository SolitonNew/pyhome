let variableGroups = new Array();  // (4) ["1", "Дом", "None", "0"]
let variables = new Array();       // ["156", "AQUA_PUMP", "Аквариум фильтр", "3", "0.0", "23"]

function buildVariables() {
    let page1 = document.getElementById('page1');
    let page2 = document.getElementById('page2');
    let page3 = document.getElementById('page3');
        
    //1: ok := (o.typ in [1, 3]); 
    //4: ok := (o.typ in [4, 5, 10]); 
    //7: ok := (o.typ in [7, 11, 13]);

    // ["1", "Дом", "None", "0"]    
    // ["156", "AQUA_PUMP", "Аквариум фильтр", "3", "0.0", "23"]
    
    // Сортируем группы по row[3]
    
    let loop = true;
    while (loop) {
        loop = false;
        for (let i = 0; i < variableGroups.length - 1; i++) {
            if (variableGroups[i][3] > variableGroups[i + 1][3]) {
                let row = variableGroups[i];
                variableGroups[i] = variableGroups[i + 1];
                variableGroups[i + 1] = row;
                loop = true;
            }
        }
    }
    
    
    let items = new Array();
    
    for (let g = 0; g < variableGroups.length; g++) {
        if (variableGroups[g][2] == 'None' || variableGroups[g][2] == '1')  {
            let g_row = {
                isGroup: true,
                name: variableGroups[g][1],
            }
            items.push(g_row);
           
            // Определяем вложения по дереву
            
            let ids = new Array();
            function getChilds(id) {
                ids.push(id);
                for (let i = 0; i < variableGroups.length; i++) {
                    if (variableGroups[i][2] == id) {
                        ids.push(variableGroups[i][0]);
                        getChilds(variableGroups[i][0]);
                    }
                }    
            }
            
            if (variableGroups[g][2] == '1') {
                getChilds(variableGroups[g][0]);
            } else {
                ids.push(variableGroups[g][0]);
            }
            
            // Формируем список подчиненных переменных
            
            for (let v = 0; v < variables.length; v++) {
                if (ids.indexOf(variables[v][5]) > -1) {
                    let v_row = {
                        id: variables[v][0],
                        isGroup: false,
                        name: variables[v][2],
                        typ: variables[v][3],
                        value: variables[v][4],
                    }
                    items.push(v_row);
                }
            }
        }
    }
    
    // Хелперы
    
    function addGroup(page_a, name) {
        page_a.push(
            '<div class="list-item-group">' +
                '<div style="position: absolute;width:100%;border-bottom: 1px solid #cccccc;"></div>' +
                '<div class="item-label">' + name + '</div>' +
            '</div>'
        );        
    }
    
    function addSwitch(page_a, id, name, value) {
        let v = '';
        if (value == '1.0') {
            v = 'checked';
        }
        page_a.push(
            '<div id="recID_' + id + '" class="list-item">' +
                '<img class="item-before-icon" src="./images/10_4.png">' +
                '<div class="item-label">' + name + '</div>' +
                '<div class="custom-control custom-switch">' +
                    '<input type="checkbox" class="custom-control-input" id="variable_' + id + '" oninput="switchClick(' + id + ')" ' + v + '>' +
                    '<label class="custom-control-label" for="variable_' + id + '"></label>' +
                '</div>' +
            '</div>'
        );        
    }
    
    function addTemperature(page_a, id, name, value) {       
        // Проверяем есть ли термостаты с таким же именем
        
        let terIndex = -1;
        for (let i = 0; i < variables.length; i++) {
            if ((variables[i][3] == '5') && (variables[i][2] == name)) {
                terIndex = i;
                break;
            }
        }
        
        if (terIndex == -1) {
            if (value == 'None') {
                page_a.push(
                    '<div id="recID_' + id + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                    '</div>'
                );
            } else {
                page_a.push(
                    '<div id="recID_' + id + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                        '<div class="variable-text-value"><span id="variable_' + id + '" class="variable-short-value">' + value + '</span>°C</div>' +
                    '</div>'
                );
            }        
        } else {
            let varTer = variables[terIndex];
            
            if (value == 'None') {
                page_a.push(
                    '<div id="recID_' + varTer[0] + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                        '<div class="variable-term-value">' +
                            '<span class="arrow-no-sel">&#9668;</span>' + 
                            '<span id="variable_' + varTer[0] + '">' + Math.round(parseFloat(varTer[4])) + '</span>' +
                            '<span class="arrow-no-sel">&#9658;</span>' +
                        '</div>' +
                        '<div class="variable-text-value"></div>' +
                    '</div>'
                );
            } else {
                page_a.push(
                    '<div id="recID_' + varTer[0] + '" class="list-item">' +
                        '<div class="item-label">' + name + '</div>' +
                        '<div class="variable-term-value">' +
                            '<span class="arrow-no-sel">&#9668;</span>' +
                            '<span id="variable_' + varTer[0] + '">' + Math.round(parseFloat(varTer[4])) + '</span>' +
                            '<span class="arrow-no-sel">&#9658;</span>' +
                        '</div>' +
                        '<div class="variable-text-value"><span id="variable_' + id + '" class="variable-short-value">' + value + '</span>°C</div>' +
                    '</div>'
                );            
            }
        }
    }
    
    function addFan(page_a, id, name, value) {
        let v = parseFloat(value) * 10;
        page_a.push(
            '<div id="recID_' + id + '" class="list-item">' +
                '<div class="item-label">' + name + '</div>' +
                '<input type="range" class="custom-range" style="width:70px;" id="variable_' + id + '" value="' + v + '">' +
            '</div>'
        );
    }
    
    function addShortValue(page_a, id, name, value, deg, style) {
        let v = value;
        let style_h = '';
        if (style) {
            style_h = 'style="' + style + '"';
        }
        if (value == 'None') {
            page_a.push(
                '<div id="recID_' + id + '" class="list-item">' +
                    '<div class="item-label" ' + style_h + '>' + name + '</div>' +
                '</div>'
            );  
        } else {
            page_a.push(
                '<div id="recID_' + id + '" class="list-item">' +
                    '<div class="item-label" ' + style_h + '>' + name + '</div>' +
                    '<div class="variable-text-value"><span id="variable_' + id + '" class="variable-short-value">' + v + '</span>' + deg + '</div>' +
                '</div>'
            );      
        }  
    }
    
    // Распределяем переменные по страницам    
    
    let page1_a = new Array();
    let page2_a = new Array();
    let page3_a = new Array();
    
    for (let i = 0; i < items.length; i++) {
        // PAGE 1  --------------------
        if (items[i].isGroup) {
            if ((page1_a.length > 0) && (page1_a[page1_a.length - 1].indexOf('list-item-group') > -1)) {
                page1_a.pop();
            }
            addGroup(page1_a, items[i].name);
        } else {
            switch (items[i].typ) {
                case '1':  // Свет
                case '3':  // Розетка
                    addSwitch(page1_a, items[i].id, items[i].name, items[i].value);
                    break;
            }
        }
    
        // PAGE 2  --------------------
        if (items[i].isGroup) {
            if ((page2_a.length > 0) && (page2_a[page2_a.length - 1].indexOf('list-item-group') > -1)) {
                page2_a.pop();
            }
            addGroup(page2_a, items[i].name);
        } else {
            switch (items[i].typ) {
                case '4':  // Термометр
                    addTemperature(page2_a, items[i].id, items[i].name, items[i].value);
                    break;
                case '10': // Гигрометр
                    addShortValue(page2_a, items[i].id, items[i].name, items[i].value, '%', 'font-style: italic;');
                    break;
                case '5':  // Термостат
                    break;
            }            
        }
        
        // PAGE 3  --------------------
        if (items[i].isGroup) {
            if ((page3_a.length > 0) && (page3_a[page3_a.length - 1].indexOf('list-item-group') > -1)) {
                page3_a.pop();
            }
            addGroup(page3_a, items[i].name);
        } else {
            switch (items[i].typ) {
                case '7':  // Вентилятор
                    addFan(page3_a, items[i].id, items[i].name, items[i].value);
                    break;
                case '11': // Датчик газа
                    addShortValue(page3_a, items[i].id, items[i].name, items[i].value, 'ppm', 'font-style: italic;');
                    break;
                case '13': // Датчик атмосферного давления
                    addShortValue(page3_a, items[i].id, items[i].name, items[i].value, 'mm', 'font-style: italic;');
                    break;
            }
        }
    }
    
    if ((page1_a.length > 0) && (page1_a[page1_a.length - 1].indexOf('list-item-group') > -1)) {
        page1_a.pop();
    }
    
    if ((page2_a.length > 0) && (page2_a[page2_a.length - 1].indexOf('list-item-group') > -1)) {
        page2_a.pop();
    }
    
    if ((page3_a.length > 0) && (page3_a[page3_a.length - 1].indexOf('list-item-group') > -1)) {
        page3_a.pop();
    }
    
    page1.innerHTML = page1_a.join('');
    page2.innerHTML = page2_a.join('');
    page3.innerHTML = page3_a.join('');
    
    $('#page1 div.list-item').on('click', (event) => {
        $('#page1 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
    
    $('#page2 .list-item').on('click', (event) => {
        $('#page2 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
    
    $('#page3 .list-item').on('click', (event) => {
        $('#page3 .selected').removeClass('selected');
        $(event.currentTarget).addClass('selected');
    });
    
    $('#page3 .custom-range').on('change', (event) => {
        let r = $(event.target);
        let id = r.attr('id').substring(9);
        setVarValue(id, Math.round(r.prop('value')) / 10);
    });
    
    let vvv = getVariableAtId(123);
    if (vvv) {
        setSilentInfo(vvv[4] == '1.0');
    }
}

function updateVariables(data) {

/* Array(5)
    0: "10108327"
    1: "95"
    2: "21.4"
    3: "4"
    4: "11" */
    
    //["156", "AQUA_PUMP", "Аквариум фильтр", "3", "0.0", "23"]
    
    for (let r = 0; r < data.length; r++) {
        for (let i = 0; i < variables.length; i++) {
            let id = variables[i][0];
            if (id == data[r][1]) {
                variables[i][4] = data[r][2];
                let v;
                
                switch (variables[i][3]) {
                    case '1':  // Свет
                    case '3':  // Розетки
                        if (variables[i][4] == '1.0') {
                            $('#variable_' + id).prop('checked', true);
                        } else {
                            $('#variable_' + id).prop('checked', false);
                        }
                        break;
                
                    case '4':  // Термометр
                    case '10':  // Гигрометр
                        $('#variable_' + id).text(variables[i][4]);
                        break;
                    case '5': // Термостат
                        $('#variable_' + id).text(Math.round(parseFloat(variables[i][4])));
                        break;
                        
                    case '7':  // Вентилятор
                        v = parseFloat(variables[i][4]) * 10;
                        $('#variable_' + id).prop('value', v);
                        break;
                    case '11': // Датчик газа
                    case '13': // Датчик атмосферного давления
                        $('#variable_' + id).text(variables[i][4]);
                        break;
                }
            }
        }
        
        if (data[r][1] == '123') {
            setSilentInfo(data[r][2] == '1.0');
        }
    }
}

function getVariableAtId(id) {
    for (let i = 0; i < variables.length; i++) {
        if (variables[i][0] == id) {
            return variables[i];
        }
    }
    return null;
}




