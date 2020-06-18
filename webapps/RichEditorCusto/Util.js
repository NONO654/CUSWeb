//=================================================================
// JavaScript Util.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"

if(localStorage['debug.AMD']) {
	var _RichEditorUtil_js = _RichEditorUtil_js || 0;
	_RichEditorUtil_js++;
	console.info("AMD: RichEditorCusto/Util.js loading " + _RichEditorUtil_js + " times.");
}

define('DS/RichEditorCusto/Util', [], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: RichEditorCusto/Util.js dependency loaded.");
	}
	
	
	if(localStorage['debug.AMD']) {
		console.info("AMD: RichEditorCusto/Util.js finish. ");
	}
	return {};
});

function getFunctionName(fun) {
	if(!fun) {
		return "null";
	}
	
	if(fun.name) {
		return fun.name;
	}

	var ret = fun.toString();
	ret = ret.substr('function '.length);
	ret = ret.substr(0, ret.indexOf('('));
	return ret;
}

/**
 * Given a context object, function name, and callback functions, override the
 * function so that it calls callOnEntry before calling the original, and
 * callOnExit after exiting the original. The result to the caller depends.
 *
 * @param {Object}
 *            context of execution (e.g. window, emxEditableTable etc.)
 * @param {String}
 *            function Name to instrument
 * @param {Function}
 *            function to call before entering the original. Same arguments will
 *            be passed in as the original. if callOnEntry returns false, original
 *            function will not be invoked. if callOnEntry returns an array, first
 *            array element is returned without calling original function. In other
 *            cases, original function will be called and its result returned to the
 *            caller unless callOnExit is defined.
 *
 * @param {Function}
 *            function to call after exiting the original. Same arguments will
 *            be passed in as the original, as well as the result of the
 *            original function call. The result of callOnExit is returned to the
 *            caller.
 * @return true if successfully instrumented
 * 
**/

emxUICore.instrument = function(context, functionName, callOnEntry, callOnExit) {
    context = context || window;

    var original = context[functionName];

    while (!original && context.prototype) {
        original = context.prototype[functionName];
        context = context.prototype;
    }

    if (!original) {
        return false;
    }

    if(localStorage['debug.instrument']) {
    	console.log("Instrumentating " + functionName + " Pre: " + getFunctionName(callOnEntry) + ", Post: " + getFunctionName(callOnExit));
    }
    
    var isDeferred = false;
    if(original['_deferred']) {
    	var realOriginal = original['_deferred'];
    	isDeferred = true;
    }
    
    var instrumented = function() {

        if (callOnEntry) {
        	try{
            var newResult = callOnEntry.apply(this, arguments);
            if (newResult == false) return;
            if (newResult instanceof Array) return newResult[0];
        	} catch (ex) {
        		console.error(ex.stack);
        	}
        }
        if(isDeferred) {
            var result = realOriginal.apply(this, arguments);
        }
        else{
            var result = original.apply(this, arguments);
        }
        if (callOnExit) {
        	try{
            arguments[arguments.length] = result;
            arguments.length += 1;
            result = callOnExit.apply(this, arguments);
        	} catch (ex) {
        		console.error(ex.stack);
        	}
        }
        return result;
    };
    if(isDeferred) {
    	original['_deferred'] = instrumented;
    	original['_deferred']._original = realOriginal;
    }
    else{
        context[functionName] = instrumented;
        context[functionName]._original = original;
    }
    return true;
};

/**
 * Given a context object and function name of a function that has been
 * instrumented, revert the function to it's original (non-instrumented) state.
 *
 * @param {Object}
 *            context of execution (e.g. window, emxEditableTable etc.)
 * @param {String}
 *            function Name to de-instrument
 * @return true if successfully de-instrumented
 */
emxUICore.deinstrument = function(context, functionName) {
    context = context || window;
    var original = context[functionName];

    while (!original && context.prototype) {
        original = context.prototype[functionName];
        context = context.prototype;
    }

    if (!original) {
        return false;
    }

    if (context[functionName].constructor === Function &&
        typeof context[functionName]._original.constructor == "function") {
        context[functionName] = context[functionName]._original;
        return true;
    }
};

/**
 * Load a script with a cache handler
 * @param url - the url's script
 * @param options - the options (see jQuery doc)
 */
jQuery.cachedScript = function(url, options) {

    // Allow user to set any option except for dataType, cache, and url
    options = $.extend(options || {}, {
        dataType: "script",
        cache: true,
        url: url
    });

    // Use $.ajax() since it is more flexible than $.getScript
    // Return the jqXHR object so we can chain callbacks
    return jQuery.ajax(options);
};


/*\
|*|
|*|  Base64 / binary data / UTF-8 strings utilities
|*|
|*|  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Base64_encoding_and_decoding
|*|
\*/


//Args - 
/* Base64 string to array encoding */
function uint6ToB64(nUint6) {


    return nUint6 < 26 ?
        nUint6 + 65 : nUint6 < 52 ?
        nUint6 + 71 : nUint6 < 62 ?
        nUint6 - 4 : nUint6 === 62 ?
        43 : nUint6 === 63 ?
        47 :
        65;

}

//Args - 
function base64EncArr(aBytes) {

    var nMod3 = 2,
        sB64Enc = "";

    for (var nLen = aBytes.length, nUint24 = 0, nIdx = 0; nIdx < nLen; nIdx++) {
        nMod3 = nIdx % 3;
        if (nIdx > 0 && (nIdx * 4 / 3) % 76 === 0) {
            sB64Enc += "\r\n";
        }
        nUint24 |= aBytes[nIdx] << (16 >>> nMod3 & 24);
        if (nMod3 === 2 || aBytes.length - nIdx === 1) {
            sB64Enc += String.fromCharCode(uint6ToB64(nUint24 >>> 18 & 63), uint6ToB64(nUint24 >>> 12 &
                63), uint6ToB64(nUint24 >>> 6 & 63), uint6ToB64(nUint24 & 63));
            nUint24 = 0;
        }
    }

    return sB64Enc.substr(0, sB64Enc.length - 2 + nMod3) + (nMod3 === 2 ? '' : nMod3 === 1 ? '=' : '==');

}
//Args - sDOMStr CK editor content.
function strToUTF8Arr(sDOMStr) {
	if (sDOMStr == undefined)
		return '';
	
    var aBytes, nChr, nStrLen = sDOMStr.length,
        nArrLen = 0;

    /* mapping... */

    for (var nMapIdx = 0; nMapIdx < nStrLen; nMapIdx++) {
        nChr = sDOMStr.charCodeAt(nMapIdx);
        nArrLen += nChr < 0x80 ? 1 : nChr < 0x800 ? 2 : nChr < 0x10000 ? 3 : nChr < 0x200000 ? 4 : nChr <
            0x4000000 ? 5 : 6;
    }

    aBytes = new Uint8Array(nArrLen);

    /* transcription... */

    for (var nIdx = 0, nChrIdx = 0; nIdx < nArrLen; nChrIdx++) {
        nChr = sDOMStr.charCodeAt(nChrIdx);
        if (nChr < 128) {
            /* one byte */
            aBytes[nIdx++] = nChr;
        } else if (nChr < 0x800) {
            /* two bytes */
            aBytes[nIdx++] = 192 + (nChr >>> 6);
            aBytes[nIdx++] = 128 + (nChr & 63);
        } else if (nChr < 0x10000) {
            /* three bytes */
            aBytes[nIdx++] = 224 + (nChr >>> 12);
            aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
            aBytes[nIdx++] = 128 + (nChr & 63);
        } else if (nChr < 0x200000) {
            /* four bytes */
            aBytes[nIdx++] = 240 + (nChr >>> 18);
            aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
            aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
            aBytes[nIdx++] = 128 + (nChr & 63);
        } else if (nChr < 0x4000000) {
            /* five bytes */
            aBytes[nIdx++] = 248 + (nChr >>> 24);
            aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
            aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
            aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
            aBytes[nIdx++] = 128 + (nChr & 63);
        } else /* if (nChr <= 0x7fffffff) */ {
            /* six bytes */
            aBytes[nIdx++] = 252 + /* (nChr >>> 32) is not possible in ECMAScript! So...: */ (nChr /
                1073741824);
            aBytes[nIdx++] = 128 + (nChr >>> 24 & 63);
            aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
            aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
            aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
            aBytes[nIdx++] = 128 + (nChr & 63);
        }
    }

    return aBytes;
}

/* Array of bytes to base64 string decoding */
function b64ToUint6(nChr) {

    return nChr > 64 && nChr < 91 ?
        nChr - 65 : nChr > 96 && nChr < 123 ?
        nChr - 71 : nChr > 47 && nChr < 58 ?
        nChr + 4 : nChr === 43 ?
        62 : nChr === 47 ?
        63 :
        0;

}

function base64DecToArr(sBase64, nBlocksSize) {
    var
        sB64Enc = sBase64.replace(/[^A-Za-z0-9\+\/]/g, ""),
        nInLen = sB64Enc.length,
        nOutLen = nBlocksSize ? Math.ceil((nInLen * 3 + 1 >> 2) / nBlocksSize) * nBlocksSize : nInLen * 3 +
        1 >> 2,
        taBytes = new Uint8Array(nOutLen);

    for (var nMod3, nMod4, nUint24 = 0, nOutIdx = 0, nInIdx = 0; nInIdx < nInLen; nInIdx++) {
        nMod4 = nInIdx & 3;
        nUint24 |= b64ToUint6(sB64Enc.charCodeAt(nInIdx)) << 18 - 6 * nMod4;
        if (nMod4 === 3 || nInLen - nInIdx === 1) {
            for (nMod3 = 0; nMod3 < 3 && nOutIdx < nOutLen; nMod3++, nOutIdx++) {
                taBytes[nOutIdx] = nUint24 >>> (16 >>> nMod3 & 24) & 255;
            }
            nUint24 = 0;

        }
    }

    return taBytes;
}

/* UTF-8 array to DOMString and vice versa */
function UTF8ArrToStr(aBytes) {
    var sView = "";

    for (var nPart, nLen = aBytes.length, nIdx = 0; nIdx < nLen; nIdx++) {
        nPart = aBytes[nIdx];
        sView += String.fromCharCode(
            nPart > 251 && nPart < 254 && nIdx + 5 < nLen ? /* six bytes */
            /* (nPart - 252 << 32) is not possible in ECMAScript! So...: */
            (nPart - 252) * 1073741824 + (aBytes[++nIdx] - 128 << 24) + (aBytes[++nIdx] - 128 << 18) +
            (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128 : nPart >
            247 && nPart < 252 && nIdx + 4 < nLen ? /* five bytes */
            (nPart - 248 << 24) + (aBytes[++nIdx] - 128 << 18) + (aBytes[++nIdx] - 128 << 12) + (
                aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128 : nPart > 239 && nPart < 248 &&
            nIdx + 3 < nLen ? /* four bytes */
            (nPart - 240 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++
                nIdx] - 128 : nPart > 223 && nPart < 240 && nIdx + 2 < nLen ? /* three bytes */
            (nPart - 224 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128 : nPart > 191 &&
            nPart < 224 && nIdx + 1 < nLen ? /* two bytes */
            (nPart - 192 << 6) + aBytes[++nIdx] - 128 : /* nPart < 127 ? */ /* one byte */
            nPart
        );
    }

    return sView;

}

if(localStorage['debug.AMD']) {
	console.info("AMD: RichEditorCusto/Util.js global finish ");
}

