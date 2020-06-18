
//=================================================================
// JavaScript emxCreateUtil.js - 
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================

function getTopAccessFrame() {
    if (getTopAccessFrame.cache) {
        return getTopAccessFrame.cache;
    }
    var oTop = this;
    while(oTop && oTop.parent != oTop && oTop.name != "mxPortletContent" ){
        try{
            var doc = oTop.parent.test = "temp";
        }catch(e){
            break;
        }
        oTop = oTop.parent;
    }
    getTopAccessFrame.cache = oTop;
    return getTopAccessFrame.cache;
}

function getOpenerTopAccessFrame() {
    if (getOpenerTopAccessFrame.cache) {
        return getOpenerTopAccessFrame.cache;
    }
    var oTop = getTopAccessFrame();

    try{
        while(oTop.name != "mxPortletContent" && oTop.getWindowOpener() && oTop.getWindowOpener().getTopWindow()){
            var docOpenerTop = oTop.getWindowOpener().getTopWindow().test = "temp";
            oTop = oTop.getWindowOpener().getTopWindow()
        }
    }catch(e){
    }
    getOpenerTopAccessFrame.cache = oTop;
    return getOpenerTopAccessFrame.cache;
}

var topAccessFrame = getTopAccessFrame();
if(typeof topAccessFrame.emxUIConstants == "object"){
	var emxUIConstants = topAccessFrame.emxUIConstants;
}else{ 
	if(typeof getOpenerTopAccessFrame().emxUIConstants == "object"){
		topAccessFrame = getOpenerTopAccessFrame();
		var emxUIConstants = topAccessFrame.emxUIConstants;
	} else {
    document.write("<scri" + "pt language=\"JavaScript\" type=\"text/javascript\" src=\"../common/emxUIConstantsJavaScriptInclude.jsp\"></scr" + "ipt>");
	}
}
//End: Overridden functions

