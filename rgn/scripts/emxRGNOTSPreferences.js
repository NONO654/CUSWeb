'use strict';
	
addStyleSheet('emxUIDefault');
addStyleSheet('emxUIForm');
addStyleSheet('emxRGNStyle');

function checkUnload() {
    return !(document.getElementById('saveLibrary').getAttribute('disabled'));
};

function checkRole(isAdmin) {
    document.getElementById('nonAppropriateContext').setAttribute('style', 'display: ' + (isAdmin ? 'none' : 'inline'));
    document.getElementById('otsForm').setAttribute('style', 'display: ' + (isAdmin ? 'inline' : 'none'));
}

function saveLibraries() {
    var requestData = {},
        processingMessage = document.getElementById('checkingOTScript').innerText;
    fillMessageZone(processingMessage);
    requestData.action = "save";
    requestData.otscript =  getOTScriptData();
    doPostRequest('ots', JSON.stringify(requestData), answerAnalysis)
}

function checkLibraries() {
     var requestData = {},
        processingMessage = document.getElementById('checkingOTScript').innerText;
    requestData.otscript =  getOTScriptData();
    fillMessageZone(processingMessage);
    doPostRequest('ots', JSON.stringify(requestData), answerAnalysis);
}

function fillMessageZone(processingMessage) {
    var messageZone = document.getElementById('errorDisplay'),
        listItems = document.getElementById('fileList').querySelectorAll('li'),
        msgClassList = messageZone.classList,
        i = 0;
    if (processingMessage) {
        document.getElementById('waitingLoop').classList.toggle('ots-hidden');
        messageZone.innerHTML = processingMessage;
    } else
        messageZone.innerHTML = '';
    for (i; i < listItems.length; i++)
        delete(listItems[i].error);
    msgClassList.remove('ots-ok');
    msgClassList.remove('ots-nok');
}

function answerAnalysis(answer, error) {
    var messageZone = document.getElementById('errorDisplay'),
        fileList = document.getElementById('fileList'),
        currentSelection = fileList.querySelector('.selected');
    document.getElementById('waitingLoop').classList.toggle('ots-hidden');
    if (answer) {
        try {
        	var ansData = JSON.parse(answer);
            if ('0' === ansData.code) {
                messageZone.classList.add('ots-ok');
                messageZone.innerHTML = ansData.message;
                if (ansData.saveOK) {
                	var listItems = fileList.querySelectorAll('li'),
                    	i = 0;
                    disableElement(document.getElementById('saveLibrary'));
                    updateApplyDoneButtons(true);
                    for (i; i < listItems.length; i++) {
                    	var item = listItems[i];
                    	if (item.classList.contains('deleted'))
                    		fileList.removeChild(item);
                    	else
                    		item.classList.remove('edited');
                    }
                }
            } else {
                messageZone.innerHTML = '';
                for (var i = 0; i < ansData.errors.length; i++) {
                    var errorObj = ansData.errors[i],
                        div = document.createElement('div');
                    document.getElementById(errorObj.library).parentNode.error = errorObj;
                    div.library = errorObj.library;
                    div.innerText = errorObj.library + ': ' + errorObj.error;
                    div.classList.add('ots-nok');
                    div.onclick = displayError;
                    messageZone.appendChild(div);
                }
            }
        } catch (e) {
        	 messageZone.classList.add('ots-nok');
             messageZone.innerHTML = e;
        }

    } else if (error) {
        messageZone.classList.add('ots-nok');
        messageZone.innerHTML = error;
    }
    if (currentSelection)
        basicDisplayOtsLibrary(currentSelection)
}

function updateApplyDoneButtons(enable) {
    var applyBtn = getTopWindow().document.getElementById('divPageFoot').querySelectorAll("a[onclick*='submitAndUpdate']")[0].childNodes[0],
        doneBtn = getTopWindow().document.getElementById('divPageFoot').querySelectorAll("a[onclick*='submitAndClose']")[0].childNodes[0];
    enable ? enableElement(applyBtn) : disableElement(applyBtn);
    enable ? enableElement(doneBtn) : disableElement(doneBtn);
}

function displayError(event) {
    var error = event.target,
        item = document.getElementById(error.library);
    basicDisplayOtsLibrary(item.parentNode);
}

function getOTScriptData() {
    var items = document.getElementById('fileList').querySelectorAll('li:not(.deleted)'),
        otscriptDataList = [],
        i;
    for (i = 0; i < items.length; i++) {
        var  otscriptData = {};
        otscriptData.name = items[i].querySelector('span').innerText;
        otscriptData.code = items[i].getAttribute('value');
        otscriptDataList[i] = otscriptData;
    }
    return otscriptDataList;
}

function initFileList(fileMap, doSave) {
    var name,
        code,
        map = JSON.parse(fileMap.replace(/[\n\r]/g, '')),
        fileList = document.getElementById('fileList');
    for (name in map) {
        if (map.hasOwnProperty(name)) {
            code = map[name];
            newOtsLibrary(name, code);
        }
    }
    if (doSave)
        saveLibraries();
}


function newOtsLibrary(name, code) {
    var fileList = document.getElementById('fileList'),
        li = document.createElement('li'),
        span = document.createElement('span'),
        input = document.createElement('input'),
        edit = document.createElement('img'),
        del = document.createElement('img'),
        undel = document.createElement('img'),
        indice = fileList.getElementsByTagName('li').length;
    enableElement(document.getElementById('checkLibrary'));
    enableElement(document.getElementById('methodPattern'));
    setOtsLibraryName(span, name ? name : ('OTScript' + (indice + 1)));
    input.setAttribute('type', 'text');
    input.setAttribute('class', 'ots-hidden');
    input.onblur = updateOtsLibraryName;
    input.onkeydown = validateInput;
    edit.setAttribute('class', 'ots-ctx-img');
    edit.setAttribute('src', '../common/images/iconActionEdit.png');
    edit.onclick = editOtsLibraryName;
    del.setAttribute('class', 'ots-ctx-img');
    del.setAttribute('src', '../common/images/iconActionDelete.png');
    del.onclick = deleteOtsLibrary;
    undel.setAttribute('class', 'ots-ctx-img ots-hidden');
    undel.setAttribute('src', '../common/images/iconActionUndo.png');
    undel.onclick = undeleteOtsLibrary;
    li.setAttribute('value', code ? code : '');
    li.onclick = displayOtsLibrary;
    li.ondblclick = editOtsLibraryName;
    li.appendChild(span);
    li.appendChild(input);
    li.appendChild(del);
    li.appendChild(undel);
    li.appendChild(edit);
    fileList.appendChild(li);
    if (indice === 0 || !name)
        basicDisplayOtsLibrary(li);
    if (!name)
        editLibrary(li);
    sortFileList();
}

function enableElement(elt) {
    elt.removeAttribute('disabled');
}

function disableElement(elt) {
    elt.setAttribute('disabled', 'true');
}

function validateInput(event) {
    if (event instanceof KeyboardEvent) {
        if (event.keyCode === 13)
            event.target.blur();
    }
}

function displayOtsLibrary(event) {
    var target = event.target,
        li = target.tagName === 'LI' ? target : target.parentNode;
    if (!target.classList.contains('ots-ctx-img') && li && li.parentNode)
        basicDisplayOtsLibrary(li);
}

function basicDisplayOtsLibrary(listItem) {
    var currentSelection = listItem.parentNode.querySelector('.selected'),
        codeLayout = document.getElementById('codeLayout'),
        codeArea = document.createElement('textArea'),
        code = listItem.getAttribute('value'),
        errorObj = listItem.error;
    codeLayout.innerHTML = '';
    codeArea.setAttribute('class', 'ots-hidden');
    codeArea.innerHTML = code;
    codeLayout.appendChild(codeArea);
    if (currentSelection)
        toggleSelection(currentSelection);
    toggleSelection(listItem);
    var editor = CodeMirror.fromTextArea(codeArea, {
                            lineNumbers: true,
                            indentUnit: 4,
                            readOnly: true,
                            autofocus: false,
                            mode: 'otscript',
                            gutters: ['CodeMirror-gutter-elt', 'error']
                        });
    editor.options.readOnly = false;
    editor.on('change', onCodeChange);
    editor.setOption('extraKeys', {
        'Ctrl-S': function(cm) {
                saveLibraries();
        }
    });
    editor.clearGutter('error');
    if (listItem.querySelector('.ots-hidden').tagName === 'INPUT')
        editor.focus();
    if (errorObj && errorObj.startLine) {
        var startLine = parseInt(errorObj.startLine)-1,
            endLine = errorObj.endLine ? (parseInt(errorObj.endLine)-1) : startLine,
            startCh = parseInt(errorObj.startCol ? errorObj.startCol : 1)-1,
            endCh = errorObj.endCol ? (parseInt(errorObj.endCol)-1) : (startCh + 1);
        editor.setGutterMarker(startLine, 'error', makeErrorMarker());
        editor.getDoc().markText({line: startLine, ch: startCh}, {line: endLine, ch: endCh}, {className: 'ots-highlight-error'});
    } 
}

function makeErrorMarker() {
    var marker = document.createElement("div");
    marker.style.color = "#822";
    marker.innerHTML = "●";
    return marker;
}

function toggleSelection(listItem) {
    listItem.classList.toggle('selected');
}

function onCodeChange(cmInstance, changedObject) {
    var origin = changedObject.origin,
        currentSelection = document.getElementById('fileList').querySelector('.selected');
    if (origin !== 'setValue') {
        editLibrary(currentSelection, cmInstance.getDoc().getValue());
    }
}

function editLibrary(selection, code) {
    enableElement(document.getElementById('saveLibrary'));
    updateApplyDoneButtons(false);
    if (selection) {
        selection.classList.add('edited');
        if (code || code === '')
            selection.setAttribute('value', code);
    }
}

function editOtsLibraryName(event) {
    var li = event.target.tagName === 'LI' ? event.target : event.target.parentNode,
        span = li.querySelector('span'),
        input = li.querySelector('input');
    toggleOtsLibraryNameDisplay(li);
    input.value = span.innerText;
    input.focus();
}

function updateOtsLibraryName(event) {
    var target = event.target,
        li = target.parentNode,
        span = li.querySelector('span'),
        input = li.querySelector('input');
    toggleOtsLibraryNameDisplay(li);
    if (span.innerText !== input.value) {
        setOtsLibraryName(span, input.value);
        sortFileList();
        editLibrary(li);
    }
}

function setOtsLibraryName(span, name) {
    var fileList = document.getElementById('fileList'),
        dup = fileList.querySelector('span[id="' + name + '"]'),
        i = 1,
        newName = name;
    while (dup) {
        newName = name + i++;
        dup = fileList.querySelector('span[id="' + newName + '"]');
    }
    span.innerText = newName;
    span.setAttribute('id', newName);

}

function sortFileList() {
    var fileList = document.getElementById('fileList'),
    	names = [],
    	elts = fileList.querySelectorAll('span'),
    	i;
    for (i = 0; i< elts.length; i++)
        names[i] = elts[i].innerText;
    names.sort().forEach(function(elt, index) {
        fileList.insertBefore(document.getElementById(elt).parentNode, fileList.childNodes[index]);
    });
}

function toggleOtsLibraryNameDisplay(li) {
    var span = li.querySelector('span'),
        input = li.querySelector('input');
    span.classList.toggle('ots-hidden');
    input.classList.toggle('ots-hidden');
    toggleLibraryButtonsVisibility(li);
}

function toggleLibraryButtonsVisibility(li) {
	var imgs = li.querySelectorAll('img');
	for (var i = 0; i < imgs.length; i++)
        imgs[i].classList.toggle('ots-hidden');
}

function deleteOtsLibrary(event) {
    var list = document.getElementById('fileList'),
        sel = event.target.parentNode,
        newSel;
    sel.classList.toggle('deleted');
    toggleLibraryButtonsVisibility(sel);
    editLibrary();
    newSel = list.querySelector('li');
    if (newSel)
        basicDisplayOtsLibrary(newSel);
    else {
        fillMessageZone();
        document.getElementById('codeLayout').innerHTML = '';
        disableElement(document.getElementById('checkLibrary'));
        disableElement(document.getElementById('methodPattern'));
    }
}

function undeleteOtsLibrary(event) {
    var list = document.getElementById('fileList'),
        sel = event.target.parentNode,
        newSel;
    sel.classList.toggle('deleted');
    toggleLibraryButtonsVisibility(sel);
    editLibrary();
    basicDisplayOtsLibrary(sel);
}

function insertPattern(patternName) {
    switch (patternName) {
        case 'method':
            appendCode('\nMETHOD <Type>.<Name>() -doc : {\n'
                    + '\t//Code\n'
                    + '} CATEGORY "<methodCategory>"\n'
                    + 'LABEL "<methodDisplay>"\n'
                    + 'HELPTEXT "<Tooltip information>";\n');
            break;
    
        default:
            break;
    }
}

function appendCode(code) {
    var listItem = document.getElementById('fileList').querySelector('.selected');
    editLibrary(listItem, listItem.getAttribute('value') + code);
    basicDisplayOtsLibrary(listItem);
}
