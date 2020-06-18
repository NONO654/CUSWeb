/**
 *   This is used in structure browser to find string
 */

function emxFindInCntrl(strID) {
	// draw find in control in the toolbar specified.
	var divToolbar = document.getElementById(strID);
	var divFindInWrapper = document.createElement("div");
	divFindInWrapper.classList.add("find-in-wrapper");
	divToolbar.appendChild(divFindInWrapper);

	var divFindInBttn = document.createElement("div");
	divFindInBttn.classList.add("toolbar");
	divFindInBttn.classList.add("find-in-button");
	divFindInBttn.innerHTML = "<table>"
			+ "<tbody>"
			+ "<tr>"
			+ "<td title='" + emxUIConstants.GSB_FIND_TXT + "' class='icon-button'><img src='images/iconActionFindInStructure.png'></td>"
			+ "</tr>" + "</tbody>" + "</table>";
	var divFindInCntrl = document.createElement("div");
	divFindInCntrl.classList.add("toolbar");
	divFindInCntrl.classList.add("find-in-controls");
	divFindInCntrl.innerHTML = "<div class='find-in-string'>"
			+ "<input type='text' id='findInStr' class='form-control' placeholder='" + emxUIConstants.GSB_FIND_TXT + "'>"
			+ "</div>"
			+ "<div id='findInRslt' class='find-in-results'></div>"
			+ "<div class='find-in-cancel'>"
			+ "<button type='button' class='cancel'></button>"
			+ "</div>"
			+ "<div class='btn-grp'>"
			+ "<button type='button' id='findInPrev' class='btn btn-default find-in-previous'></button>"
			+ "<button type='button' id='findInNext' class='btn btn-default find-in-next'></button>"
			+ "</div>";
	divFindInWrapper.appendChild(divFindInCntrl);
	divFindInWrapper.appendChild(divFindInBttn);

	// initialize HTML elements
	this.HTMLTextbox = document.getElementById("findInStr");
	this.HTMLResult = document.getElementById("findInRslt");
	this.initialize(true);

	// As this objects in the event functions below points to HTML element.
	var thisObj = this;

	// open close find in control
	divFindInBttn.onclick = function() {
		if (divFindInCntrl.classList.contains("open")) {
			divFindInCntrl.classList.remove("open");
			thisObj.initialize(true);
		} else {
			divFindInCntrl.classList.add("open");
		}
	};

	// search on enter in the textbox
	this.HTMLTextbox.onkeyup = function(e) {
		if (e.keyCode == 13) {
			thisObj.search();
		}	
	};
	// search on enter in the textbox
	this.HTMLTextbox.oninput = function(e) {
			thisObj.findStrChanged = true;
	};

	// clear the search
	jQuery("button.cancel")[0].onclick = function() {
		thisObj.initialize(true);
	};

	// start search on first time or navigate to prev search item.
	jQuery("#findInPrev")[0].onclick = function() {
		thisObj.move(false);
	};

	// start search on first time or navigate to next search item.
	jQuery("#findInNext")[0].onclick = function() {
		thisObj.move(true);
	};
}

// initialize and reset all parameters
emxFindInCntrl.prototype.initialize = function(initializeHTML) {
	this.textChanged = false;
	this.total = 0;
	this.currentIndex = 0;
	this.data = new Array();
	this.rowIndex = null;
	if (initializeHTML) {
		this.HTMLTextbox.value = "";
		this.HTMLResult.innerHTML = "";
		this.text = "";
	}
	var spans = jQuery(".find-in-result").parent();
	for (var i = 0; spans && i < spans.length; i++) {
		parentHTML = spans[i].innerHTML;
		parentHTML = parentHTML.replace(new RegExp(" current", "g"), "");
		parentHTML = parentHTML.replace(new RegExp("<span class=\"find-in-result\" id=\"findInSpan\\d+\">", "g"), "");
		parentHTML = parentHTML.replace(new RegExp("</span>", "g"), "");
		spans[i].innerHTML = parentHTML;
	}
};

// get matched data by rowid
emxFindInCntrl.prototype.getDataForRow = function (rowId) {
	var dataIndexes = this.rowIndex[rowId];
	var returnData = null;
	if (dataIndexes) {
		var returnData = new Array();
		for(var i = 0; i < dataIndexes.length; i++) {
			returnData.push(this.data[dataIndexes[i]]);
		}
	}
	return returnData;
};

//to add "\" for special characters
function addEscapeForSpeacialChar(originalText){
	var specialChars = "^.+(){}";
   
    for(i = 0; i < specialChars.length;i++){
        if(originalText.indexOf(specialChars[i]) > -1){
          originalText=originalText.replace(new RegExp("\\"+specialChars[i],"g"), "\\"+specialChars[i]);  
        }
    }
	return originalText;
};

//to remove the added "\" in front of special characters
function removeEscapeForSpeacialChar(originalText){
	var specialChars = "^.+(){}";
   
    for(i = 0; i < specialChars.length;i++){
        if(originalText.indexOf(specialChars[i]) > -1){
        	originalText=originalText.replace(new RegExp("[\\\\]\\"+specialChars[i],"g"),specialChars[i]);  
        }
    }
	return originalText;
};

// highlight content of the table cell with matched item
emxFindInCntrl.prototype.highlightContent = function(element, searchText, matchInfo) {
	if(element.getElementsByClassName('cke_contents').length > 0)
	{
		element = element.getElementsByClassName('cke_contents')[0];
	}
	var allChildren = element.getElementsByTagName("*");
	allChildren = Array.prototype.slice.call(allChildren);
	allChildren.push(element);
	var bFound = false;
	for (var i = 0; i < allChildren.length; i++) {
		for (var j = 0; j < allChildren[i].childNodes.length; j++) {
			if(allChildren[i].childNodes[j].nodeType === 3) {
				var childNode = allChildren[i].childNodes[j];
				var matchedStrings = childNode.nodeValue.match(new RegExp(searchText, "gi"));
				if (!matchedStrings) {
					continue;
				}
				bFound = true;
				matchedStrings.sort();
				var prevEntry = null;
				for (var k = 0; k < matchedStrings.length; k++) {
					matchedStrings[k]=addEscapeForSpeacialChar(matchedStrings[k]);
					if (prevEntry == null || prevEntry != matchedStrings[k]) {
            			childNode.nodeValue = childNode.nodeValue.replace(new RegExp(matchedStrings[k], "g"), "%%" + matchedStrings[k] + "%%");
						prevEntry = matchedStrings[k];
					}
				}
			}
		}
	}
	if (!bFound) {
		return;
	}
	var innerHTML = element.innerHTML;
	searchText=addEscapeForSpeacialChar(searchText);
	searchText=addEscapeForSpeacialChar(searchText);
	innerHTML=innerHTML.replace(/&amp;/g,"&");
	var matchedStrings = innerHTML.match(new RegExp("%%" + searchText + "%%", "gi"));
	if (!matchedStrings) {
		return;
	}
	for (var k = 0; k < matchedStrings.length; k++) {
		actMatchedString = matchedStrings[k].slice(2, matchedStrings[k].length - 2);
		actMatchedString=removeEscapeForSpeacialChar(actMatchedString);
		var replaceStr = "<span class='find-in-result' id='findInSpan" + Number(matchInfo.spanIdCounter + k) + "'>" + actMatchedString + "</span>";
		matchedStrings[k]=addEscapeForSpeacialChar(matchedStrings[k]);
		matchedStrings[k]=addEscapeForSpeacialChar(matchedStrings[k]);
		innerHTML = innerHTML.replace(new RegExp(matchedStrings[k]), replaceStr);
	}
	element.innerHTML = innerHTML;
};

// highlight all the table rows with matched item
emxFindInCntrl.prototype.highlightResults = function (isScroll) {
	allTRs = jQuery("#bodyTable tr");
	for (var i = 0; i < allTRs.length; i++) {
		var rowId = allTRs[i].getAttribute("id");
		if (!rowId) {
			continue;
		}
		var matches = this.getDataForRow(rowId);
		var prevColumnIndex = null;
		for (var j = 0; matches && j < matches.length; j++) {
			if (prevColumnIndex == matches[j].columnIndex) {
				continue;
			}
			var td = null;
			if (matches[j].columnIndex < split) {
				td = jQuery("#treeBodyTable #" + rowId.replace(new RegExp("," , "g"), "\\,")+ " td[position = '" + (Number(matches[j].columnIndex) + 1) + "']");
			} else {
				td = jQuery("#bodyTable #" + rowId.replace(new RegExp("," , "g"), "\\,") + " td[position = '" + (Number(matches[j].columnIndex) + 1) + "']");
			}
			if (td && td.length > 0) {
				this.highlightContent(td[0], this.text, matches[j]);
			}
			prevColumnIndex = matches[j].columnIndex;
		}
	}
	var matchItem = this.data[this.currentIndex];
	var spanCurrent = document.getElementById("findInSpan" + this.currentIndex);
	if (spanCurrent) {
		spanCurrent.classList.add("current");
		if (!isScroll) {
			var currOffset = jQuery(spanCurrent).offset().top;
			var treeOffset = jQuery(document.getElementById("mx_divTreeBody")).offset().top;
			if(currOffset < treeOffset)
			{
				var scrollTop = document.getElementById("mx_divTableBody").scrollTop;
				document.getElementById("mx_divTableBody").scrollTop = scrollTop - (treeOffset - currOffset) - 34;
			}
			else if(currOffset > (treeOffset + document.getElementById("mx_divTableBody").offsetHeight))
			{
				var scrollTop = document.getElementById("mx_divTableBody").scrollTop;
				document.getElementById("mx_divTableBody").scrollTop = scrollTop + (currOffset - treeOffset) + 34;
			}
		}	
	}
};


// search for a text string
emxFindInCntrl.prototype.search = function () {
	this.text = this.HTMLTextbox.value;
	if (this.findStrChanged && this.text && this.text.trim().length > 0) {
		this.initialize(false);
		this.text=addEscapeForSpeacialChar(this.text);
		for(var i = 0; i < aDisplayRows.length; i++) {
			var rowId = aDisplayRows[i].getAttribute("id");
			var aColumns = emxUICore.selectNodes(aDisplayRows[i], "c");
			for(var j = 0; j < aColumns.length; j++) {
				var contentToSearch = aColumns[j];
				if(contentToSearch.getAttribute('a') != null && contentToSearch.getAttribute('a').toUpperCase() ===  'RICHTEXT')
				{
					if(contentToSearch.getElementsByClassName('cke_contents').length > 0)
					{
						contentToSearch = contentToSearch.getElementsByClassName('cke_contents')[0];
					}
				}
				var matchedItems = emxUICore.getText(contentToSearch).match(new RegExp(this.text, "ig"));
				if(matchedItems) {
					this.total += matchedItems.length;
					for(var k = 0; k < matchedItems.length; k++) {
						var matchedItem = new Object();
						matchedItem.rowId = rowId;
						matchedItem.columnIndex = j;
						matchedItem.match = matchedItems[k];
						matchedItem.spanIdCounter = this.data.length;
						this.data.push(matchedItem);
						if(!this.rowIndex) {
							this.rowIndex = new Object();
						}
						if(!this.rowIndex[rowId]) {
							this.rowIndex[rowId] = new Array();
						}
						this.rowIndex[rowId].push(this.data.length - 1);
					}
				}
			}
		}
		if (this.total > 0) {
			var matchItem = this.data[this.currentIndex];
			emxEditableTable.scrollColumnToView(matchItem.rowId, matchItem.columnIndex);
			emxEditableTable.scrollRowToView(matchItem.rowId);
			this.highlightResults();
		}
		if(this.total==0){
			this.HTMLResult.innerHTML = this.currentIndex + " of " + this.total;
		}else{
			this.HTMLResult.innerHTML = this.currentIndex + 1 + " of " + this.total;
		}
		
		this.findStrChanged = false;
	}
}

// called to find if control is actively searching
emxFindInCntrl.prototype.isActive = function (isNext) {
	return (this.data.length > 0);
}

// called to move current find cursor to next or prev matched item
emxFindInCntrl.prototype.move = function (isNext) {
	if (this.findStrChanged) {
		this.search();
	} else {
		if (!this.isActive()) {
			return;
		}
		var matchItem = this.data[this.currentIndex];
		emxEditableTable.scrollColumnToView(matchItem.rowId, matchItem.columnIndex);
		emxEditableTable.scrollRowToView(matchItem.rowId);
		var spanPrev = document.getElementById("findInSpan" + this.currentIndex);
		if (spanPrev) {
			spanPrev.classList.remove("current");
		}
		if (isNext) {
			this.currentIndex++;
			if (this.currentIndex >= this.total) {
				this.currentIndex = 0;
			}
		} else {
			this.currentIndex--;
			if (this.currentIndex < 0) {
				this.currentIndex = this.total - 1;
			}
		}

		matchItem = this.data[this.currentIndex];
		emxEditableTable.scrollColumnToView(matchItem.rowId, matchItem.columnIndex);
		emxEditableTable.scrollRowToView(matchItem.rowId);
		var spanNext = document.getElementById("findInSpan" + this.currentIndex);
		if (spanNext) {
			spanNext.classList.add("current");
		}
		this.HTMLResult.innerHTML = this.currentIndex + 1 + " of " + this.total;
	}
};

