/**
Utility functions for Widgets
@since 1.0
@author tws
*/

/**
@module widget
*/


String.prototype.htmlEncode = function _String_htmlEncode() {
	var strTemp = this.toString();
	strTemp = strTemp.replace(/&/g, "&amp;");
	strTemp = strTemp.replace(/>/g, "&gt;");
	strTemp = strTemp.replace(/</g, "&lt;");
	strTemp = strTemp.replace(/"/g, "&quot;");
	strTemp = strTemp.replace(/'/g, "&#x27;");
	strTemp = strTemp.replace(/\//g, "&#x2F;");
	return strTemp;
};
String.prototype.htmlDecode = function _String_htmlDecode() {
	var decode = this.toString();
	decode = decode.replace(/&amp;/g, "&");
	decode = decode.replace(/&lt;/g, "<");
	decode = decode.replace(/&gt;/g, ">");
	decode = decode.replace(/&quot;/g, "\"");
	decode = decode.replace(/&#39;/g, "\'");
    return decode.hexDecode();
};
String.prototype.hexDecode = function _String_hexDecode () {
	var str = this.toString(), clean = str.split('&#x');
	while(clean.length) {
		var num = '0x' + clean.pop().split(';')[0], strReplace, re;
		if (!isNaN(parseFloat(num)) && isFinite(num)) {
			strReplace = String.fromCharCode(num);
			re = new RegExp("&#x" + num.substring(2) + ";","g");
			str = str.replace(re,strReplace);
		}
		
	}
	return str;
}
/**
Method to get top most window we have access to
Copied from emxUICore.js
@return {Object} Window
*/
function getTopWindow(includeOpeners) {
	if(getTopWindow.cache) {
		return getTopWindow.cache;
	}
	var oTop = this;
	while(oTop && oTop.parent != oTop && oTop.name != "mxPortletContent") {
		try {
			oTop.parent.test = "temp";
			if(oTop.parent.test == "temp") {
				oTop = oTop.parent;
			} else {
				break;
			}
		} catch(e) {
			break;
		}
	}
	if(includeOpeners) {
		try {
			while(oTop.name != "mxPortletContent" && oTop.getWindowOpener() && oTop.getWindowOpener().top) {
				oTop.getWindowOpener().top.test = "temp2"
				if(oTop.getWindowOpener().top.test == "temp2") {
					oTop = oTop.getWindowOpener().top;
				} else {
					break;
				}
			}
		} catch(e) {}
	}

	getTopWindow.cache = oTop;
	return getTopWindow.cache;
}

function touchHandler(event) {
	var touches = event.changedTouches,
		first = touches[0],
		type = "";
	switch(event.type) {
	case "touchstart":
		type = "mousedown";
		break;
	case "touchmove":
		type = "mousemove";
		event.preventDefault();
		break;
	case "touchend":
		type = "mouseup";
		break;
	default:
		return;
	}

	var simulatedEvent = document.createEvent("MouseEvent");
	simulatedEvent.initMouseEvent(type, true, true, window, 1, first.screenX, first.screenY, first.clientX, first.clientY, false, false, false, false, 0 /*left*/ , null);

	first.target.dispatchEvent(simulatedEvent);
}

function is_touch_device() {
	return('ontouchstart' in window) // works on most browsers 
	||
	window.navigator.msMaxTouchPoints; // works on ie10
};

function touchify(elem) {
	if (elem instanceof jQuery) {
		elem = elem[0];
	}
	// Detect touch support
	if(!is_touch_device()) {
		return;
	}
	elem.addEventListener("touchstart", touchHandler, true);
	elem.addEventListener("touchmove", touchHandler, true);
	elem.addEventListener("touchend", touchHandler, true);
	elem.addEventListener("touchcancel", touchHandler, true);
}

function allowDrop(ev) {
	ev.preventDefault();
}

function drag(ev) {
	var pid, url, data, title;
	pid = jQuery(ev.target).closest('[data-pid]').attr('data-pid');
	url = jQuery(ev.target).find('a').attr('href') || "";
	title = jQuery(ev.target).closest('[data-title]').attr('data-title');
	if(url.length == 0) {
		url = jQuery(ev.target).closest('a').attr('href') || "";
	}

	data = JSON.stringify({
		url: url,
		pid: pid,
		title: title
	});
	ev.dataTransfer.setData("text/ds-json", data);
}

function drop(ev) {
	ev.preventDefault();
	var data = ev.dataTransfer.getData("text/ds-json");
	data = JSON.parse(data);

	var $popup = jQuery('<div style="position:absolute; top: 10px; left: 10px; background-color: #3A6EBB; color: whitesmoke; font-weight: bold; height: 33px; line-height: 33px"></div>').html("URL of passed in object: " + data.url).appendTo(jQuery(ev.target).closest('.channel'));
	setTimeout(function() {
		$popup.fadeOut();
		setTimeout(function() {
			$popup.remove();
		}, 2000);
	}, 5000);
}

