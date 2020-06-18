//=================================================================
// JavaScript tooltip.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
//							MM:DD:YY
//quickreview QYG           05:03:16    javascript refactoring, split from RichTextEditorStructure.js


if(localStorage['debug.AMD']) {
	var _RMTTooltip_js = _RMTTooltip_js || 0;
	_RMTTooltip_js++;
	console.info("AMD: ENORMTCustoSB/tooltip.js loading " + _RMTTooltip_js + " times.");
}

define('DS/ENORMTCustoSB/tooltip', ['DS/RichEditorCusto/Util'], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/tooltip.js dependency loaded.");
	}
	
	// TOOLTIP FOR SB
	emxUICore.instrument(editableTable, 'attachOrDetachEventHandlers', null,
	  attachRMTEventHandlersTooltip);

	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/tooltip.js finish.");
	}
	
	return {};
});


function getObjectIndex(xmlObject, objectId) {
    for (var i = 0; i < xmlObject.length; i++) {
        var object = xmlObject[i].getAttribute("o");
        if (objectId == object)
            return i;
    }
    return -1;

}

function getRelIds(xmlObject, index, level) {
    var relIds = "";
    for (var i = index; i >= 0; i--) {
        var domLevel = xmlObject[i].getAttribute("level");
        var intLevel = parseInt(level);
        var intDomLevel = parseInt(domLevel);
        if (intDomLevel < intLevel) {
            if (intDomLevel > 0) {
                relIds = xmlObject[i].getAttribute("r") + "," + relIds;
                relIds = getRelIds(xmlObject, i - 1, domLevel) + relIds;
            }
            return relIds;
        }
    }
    return relIds;
}

function findObjectId(div) {
    var object;
    if (div == null)
        return null;
    if (div.localName != "tr")
        object = findObjectId(div.parentElement);
    else
        object = div.getAttribute("o");
    return object;
}

function findObjectRel(div) {
    var object;
    if (div == null)
        return null;
    if (div.localName != "tr")
        object = findObjectRel(div.parentElement);
    else
        object = div.getAttribute("r");
    return object;
}

function findObjectRowId(div) {
    var object;
    if (div == null)
        return null;
    if (div.localName != "tr")
        object = findObjectRowId(div.parentElement);
    else
        object = div.getAttribute("id");
    return object;
}

function findObjectParent(div) {
    var object;
    if (div == null)
        return null;
    if (div.localName != "tr")
        object = findObjectId(div.parentElement);
    else
        object = div.getAttribute("r");
    return object;
}

function createObjectToolTip(currentImage, objectId, relId) {

    var index = '';
    var level = '';
    var urlToLoad = '';
    var xmlObjects = '';

    if (!emxEditableTable.isRichTextEditor) { // SB
        xmlObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]");
        index = getObjectIndex(xmlObjects, objectId);
        level = xmlObjects[index].getAttribute("level");

        if (level != "0") {
            var relIds = xmlObjects[index].getAttribute("r");
            relIds = getRelIds(xmlObjects, index - 1, level) + relIds;
            urlToLoad = "../requirements/emxRMTGetData.jsp?";
            urlToLoad += "SeqOrderRelsList=" + relIds;
            urlToLoad += "&TypeOfObject=" + objectId;
        } else {
            urlToLoad = "../requirements/emxRMTGetData.jsp?";
            urlToLoad += "&TypeOfObject=" + objectId;
        }
    } else { // SCE
        index = 1;
        level = 1;

        if (level != "0") {
            var relIds = relId;
            urlToLoad = "../requirements/emxRMTGetData.jsp?";
            urlToLoad += "SeqOrderRelsList=" + relIds;
            urlToLoad += "&TypeOfObject=" + objectId;
        } else {
            urlToLoad = "../requirements/emxRMTGetData.jsp?";
            urlToLoad += "&TypeOfObject=" + objectId;
        }
    }

    urlToLoad += "&timeStamp=" + timeStamp;
    $.ajax({
        type: "GET",
        url: urlToLoad,
        dataType: "text",
        success: function(txt) {
            var newGetDataXML = emxUICore.createXMLDOM();
            newGetDataXML.loadXML(txt);
            emxUICore.checkDOMError(newGetDataXML);
            refreshTooltipObject(newGetDataXML, objectId, currentImage);
        }
    });
}

function refreshTooltipObject(relxml, oClientData, oHTTP) {
    var seqOrder = emxUICore.selectNodes(relxml, "/mxRoot/seqOrder");
    var objectType = emxUICore.selectNodes(relxml, "/mxRoot/objectType");

    var arrowPath =
        " <img src=\"images/iconSmallRelationshipDirect.gif\" width=\"8px\" height=\"8px\" /> ";
    var oriPath = "";
    for (var j = 0; /* NOP */ ; j++) {
        try {
            var valuePath = "/mxRoot/objectName_" + j + "/text()";
            oriPath += emxUICore.selectSingleNode(relxml, valuePath).nodeValue;
            oriPath += arrowPath;
        } catch (err) {
            oriPath = oriPath.substring(0, oriPath.length - arrowPath.length);
            break;
        }
    }

    if (objectType.length == 0)
        return;

    var contentTextType = '';
    var contentTextSeq = '';
    if (isIE) {
        contentTextType = objectType[0].text;
        if (seqOrder.length > 0)
            contentTextSeq = seqOrder[0].text;
    } else {
        contentTextType = objectType[0].textContent;
        if (seqOrder.length > 0)
            contentTextSeq = seqOrder[0].textContent;
    }

    var title = contentTextType;
    if (seqOrder.length > 0) {
        title += " (" + contentTextSeq + ")";
    }

    var currentHover = dw_Tooltip.content_vars[oClientData.replace(/\./g, '') + '_toolTipInfo'];
    currentHover['content'] = '<table><tbody><tr class=""><td>' + title + '</td></tr><tr>';
    if (oriPath != "") {
        currentHover['content'] += '<td>' + oriPath + '</td></tr></tbody></table>';
    } else {
        // NOP
    }

    // If the tooltip no longer exists
    try {
        oHTTP.outerHTML = currentHover['content'];
    } catch (exT) {
        // NOP
    }
}

function attachRMTEventHandlersTooltip() {
	var table = "table=RMTFullTraceabilityTable";
	var strHref = location.href;
	var index = strHref.split("&").find(table);
	
	if(index==-1){
		var listOfObject = $('.object');
	    for (var i = 0; i < listOfObject.length; i++) {

	        var currentDiv = listOfObject[i];
	        if (currentDiv.className.indexOf('showTip') > 0)
	            return;

	        // We remove the old title
	        currentDiv.parentElement.removeAttribute('title');

	        var objectId = '';
	        if (!emxEditableTable.isRichTextEditor) // SB
	            objectId = findObjectId(currentDiv);
	        else // SCE
	            objectId = $(e.target).parent().parent().parent().parent().parent()[0].getAttribute('o');

	        // Safe guard
	        if (objectId == null)
	            return;

	        var objectIdDiv = objectId.replace(/\./g, '');

	        var currentHover = dw_Tooltip.content_vars[objectIdDiv + '_toolTipInfo'] = {};
	        currentHover['sticky'] = false;
	        currentHover['showDelay'] = 1000;

	        currentHover['on_activate'] = function() {
	            // NOP
	        };

	        currentHover['content'] = "<img style='display: block; margin-left: auto; margin-right: auto;' " +
	            "src='images/loading.gif' onload='createObjectToolTip(this, \"" + objectId + "\", \"\");' />";
	        currentHover['contentTitle'] = '';

	        currentDiv.className = 'object showTip ' + objectIdDiv + '_toolTipInfo';
	    }
	}
    
}

if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/tooltip.js global finish.");
}
