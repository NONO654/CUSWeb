/*!================================================================
 *  
 *  emxUIMetrics.js
 *
 *  This file contains the code to show the report dialog frame
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIMetrics.js.rca 1.6 Wed Oct 22 15:48:21 2008 przemek Experimental przemek $
 *=================================================================
 */

//This method determines where the Metrics Framework dialog will open.
function findReportFrame(){

    //arguments[0] is the url of the Report Specific Dialog page
    //arguments[1] is the targetFrame name
    //arguments[2] is the page title
    //arguments[3] is the commandName
    //arguments[4] is the helpMarker parameter
    //arguments[5] is the registered suiteKey parameter
    //arguments[6] is the helpMarker suiteDir parameter    
    //arguments[7] is the parameter which will indicate whether portal mode is true or false                
    
    if(arguments.length){
        //determine if the report window is already open
        var targetFrame = findFrame(getTopWindow(),arguments[1]);
        //if open target frame
        if(targetFrame){
            targetFame.getTopWindow().findReportFrame(arguments[0],arguments[1],arguments[2],arguments[3],arguments[4],arguments[5],arguments[6],arguments[7]);
        //else call showNonModal
        }else{
            showNonModalReport("../businessmetrics/emxMetrics.jsp?defaultReport=" + arguments[3] + "&suiteKey=" + arguments[5] + "&suiteDirectory=" + arguments[6]+ "&fromPortalMode=" + arguments[7]);
        }
    } 
}

//This function opens a reusable window
function showNonModalReport(strURL){
        var intWidth = 700;
        var intHeight = 500;
        var strFeatures = "width=" + intWidth + ",height=" + intHeight;
        var intLeft = parseInt((screen.width - intWidth) / 2);
        var intTop = parseInt((screen.height - intHeight) / 2);
        strFeatures += ",left=" + intLeft + ",top=" + intTop;
        strFeatures += ",resizable=yes";
        var objWindow = window.open(strURL, "NonModalReportWindow", strFeatures);
        registerChildWindows(objWindow, getTopWindow());
        objWindow.focus();
}
