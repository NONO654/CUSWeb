//=================================================================
// JavaScript emxUIFormValidation.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================
// emxUIFormValidation.js
// This file is used to add any validation routines to be used by the UIForm component
//-----------------------------------------------------------------

function reloadAccessColumn() {
    emxEditableTable.reloadCell("Access");
}

// functions for "Drop files here or click to select", the selected files will be stored in getTopWindow().files_to_checkin
function filesDragOver(div) {
    div.className = "dropAreaHover";
    document.getElementById("dropAreaIcon").src = "images/iconActionAddHover.png";
}

function filesDragLeave(div) {
    div.className = "dropArea";
    document.getElementById("dropAreaIcon").src = "images/iconActionAdd.png";
}

function filesDrop(div, e) {
    filesDragLeave(div);
    var files = e.dataTransfer.files;
    filesSelected(div, files);
}

function fileInputChanged(div, e) {
    filesSelected(div.parentElement, div.files);
}

function mouseoutDropArea(div) {
    div.className = 'dropArea';
}

function mouseoverDropArea(div) {
    div.className = 'dropAreaMouseOver';
}

function isFileAlreadySelected(file, selectedFiles) {
    var n = selectedFiles.length;
    for (var i = 0; i < n; i++) {
        var selectedFile = selectedFiles[i];
        if (file.name.toUpperCase() === selectedFile.name.toUpperCase()) { // check file name
            return true;
        }
    }
    return false;
}

function filterOutAlreadySelectedFiles(newSelectFiles, selectedFiles) { // return filtered files
    var filteredFiles = [];
    for (var i = 0; i < newSelectFiles.length; i++) {
        var file = newSelectFiles[i];
        if (isFileAlreadySelected(file, selectedFiles) === false) {
            filteredFiles.push(file);
        }
    }
    return filteredFiles;
}

function removeFile(removeButton) {
    var divDropArea = removeButton.divDropArea;
    var divFileInfo = removeButton.divFileInfo;
    var n = divDropArea.files_to_checkin.length;
    for (var i = 0; i < n; i++) {
        var file = divDropArea.files_to_checkin[i];
        if (file === divFileInfo.file) {
            divDropArea.files_to_checkin.splice(i, 1);
            break;
        }
    }
    onFileSelectionChange(divDropArea.files_to_checkin);
    divFileInfo.parentElement.removeChild(divFileInfo);
}

function onFileSelectionChange(selectedFiles) {
    if (selectedFiles == null || selectedFiles.length == 0) {
        return;
    }

    getTopWindow().files_to_checkin = selectedFiles;
    var titleDiv = document.getElementById('Title');
    if(titleDiv){
	    var currentTitle = titleDiv.value;
	    var autoTitle = titleDiv.autoTitle;
	    if (autoTitle === undefined) {
	        autoTitle = "";
	    }
	    if (autoTitle === currentTitle) {
	        titleDiv.value = selectedFiles[0].name;
	        titleDiv.autoTitle = titleDiv.value;
	    }
    }
}

function filesSelected(div, files) {
    if (files == null || files.length == 0) {
        return;
    }
    if (div.files_to_checkin === undefined || div.files_to_checkin === null) {
        div.files_to_checkin = [];
    }
    files = filterOutAlreadySelectedFiles(files, div.files_to_checkin);
    for (var i = 0; i < files.length; i++) {
        div.files_to_checkin.push(files[i]);
    }
    onFileSelectionChange(div.files_to_checkin);

    for (var i = 0; i < files.length; i++) {
        var file = files[i];
        var divFileInfo = document.createElement('div');
        var parent = div.parentElement.parentElement;
        if (parent.childNodes.length > 1) {
            parent.insertBefore(divFileInfo, parent.childNodes[1])
        }
        else {
            parent.appendChild(divFileInfo);
        }
        divFileInfo.file = file;

        var divFileName = document.createElement('div');
        divFileName.className = 'fileName';
        divFileName.textContent = file.name;
        var removeButton = document.createElement('img');
        removeButton.src = 'images/iconActionClosePanel.png';
        removeButton.className = 'removeButton';
        removeButton.onmouseover = function () { this.className = 'removeButtonMouseOver'; }
        removeButton.onmouseout = function () { this.className = 'removeButton'; }
        removeButton.divDropArea = div;
        removeButton.divFileInfo = divFileInfo;
        removeButton.onclick = function () { removeFile(this); }
        divFileName.appendChild(removeButton);
        divFileInfo.appendChild(divFileName);

        var commentTextArea = document.createElement('textarea');
        divFileInfo.file.comment = "";
        commentTextArea.onchange = function () {
            this.parentElement.file.comment = this.value;
        }
        commentTextArea.onfocus = function () {
            if (this.className == 'fileCommentInit') {
                this.className = 'fileCommentEdit';
                this.value = '';
            }
        }
        commentTextArea.rows = "1";
        commentTextArea.className = "fileCommentInit";
        commentTextArea.textContent = MSG_ADD_COMMENT; // "Click to add comment" - emxComponents.CommonDocument.UploadFiles.AddComment
        divFileInfo.appendChild(commentTextArea);
    }
}
// ~ end of functions for "Drop files here or click to select"

function emxCreateRemoveExtraRowAboveType() { // Remove extra row above Type on emxCreate.jsp table
    var extraRowInnerHtml = '<td align="center">&nbsp;</td>';
    var table = document.getElementsByClassName('form')[0];
    for (var i = 0; i < table.rows.length; i++) {
        if (table.rows.item(i).innerHTML === extraRowInnerHtml) {
            table.deleteRow(i); break;
        }
    }
}

function checkRangeValue(fieldObj){
	if(!fieldObj){
		fieldObj = this;
	}
	var attributeName = fieldObj.name;
	attributeName = attributeName.substring(attributeName.indexOf('|')+1);
	var attributeValue = fieldObj.value;
	if(attributeValue != ''){
		
		attributeValue = attributeValue.replace(/\[/g, '');
		attributeValue = attributeValue.replace(/\]/g, '');

		if(/::/g.test(attributeValue)){
			var rangeValues = attributeValue.split(/::/g);
			var minVal = rangeValues[0];
			var maxVal = rangeValues[1];
			if(isNaN(minVal) || isNaN(maxVal) || (attributeValue.match(/::/g)).length>1){
				var stralert = emxUIConstants.INVALID_RANGE_FORMAT;
				stralert = stralert.replace(/\{0}/, attributeName);
				alert(stralert);
				return false;
			} else if(Number(minVal) >= Number(maxVal)){
				var stralert = emxUIConstants.MINIMUM_NOT_LESS_THAN_MAXIMUM;
				stralert = stralert.replace(/\{0}/, attributeName);
				alert(stralert);
				return false;
			}
		} else if(isNaN(attributeValue) || Number(attributeValue) <= 0){
			var stralert = emxUIConstants.INVALID_RANGE_VALUE;
			stralert = stralert.replace(/\{0}/, attributeName);
			alert(stralert);
			return false;
		}
	}
	return true;
}
