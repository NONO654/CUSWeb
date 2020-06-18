/*!==========================================================================
 *  JavaScript Report Functions
 *
 *  emxMetrics.js
 *
 *  This file contains the code for Metrics Reports
 *
 *  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
 *
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxMetrics.js.rca 1.57 Tue Oct 28 23:00:55 2008 przemek Experimental $
 *============================================================================
 */

//GLOBAL VARIABLES
var pageControl = new pageController();
var NAME = 0;
var VALUE = 1;
var CHECKED = 2;
var DISABLED = 3;
//variable to hold the timestamp will be used in unload of metrics.jsp
var DialogTimeStamp = "";

/**
 * returns the business metrics document element (a DOM element)
 */
function $bmId(id, location){
	if(!location){
		return getTopWindow().document.getElementById(id);
	} else {
		return location.document.getElementById(id);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////   PageController Class    /////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

function pageController(){
        this.openedLast = false;
        this.showingAdvanced = false;
        this.title = "";
        this.mode = "";
        this.resultsTitle = "";
        this.type = "";
        this.metricsReportContentURL = "";
        this.savedReportName = "";
        this.showErrMsg = false;
        this.doReload = false;
        this.doSubmit = false;
        this.arrFormVals = new Array();
        this.helpMarker = null;
        this.helpMarkerSuiteDir = null;
        this.queryLimit = null;
        this.pagination = null;
        this.commandname = "";
        this.metricsReportResultsURL = "";
        this.wrapColSize = null;
        this.timeStamp = null;
        this.reportTimeStamp = null;
        this.sharedAndOwned = false;
        this.sharedAndNotOwned = false;
        this.webReportOwner = "";
        this.commaSeparatedFormElements = "";
        this.obj_top = null;
        //OPENEROK
        this.obj_opener = null;
        //OPENEROK
        this.obj_openers_opener_top = null;
        this.latestSavedReportName = "";
        this.changedDisplayFormat = "";
}

//top window reference
pageController.prototype.setTopWindow = function __setTopWindow(obj){
        this.obj_top = obj;
}
pageController.prototype.getTopWindow = function __getTopWindow(){
        return this.obj_top;
}

//top window getWindowOpener()'s reference
pageController.prototype.setOpenerWindow = function __setOpenerWindow(obj){
        //OPENEROK
        this.obj_opener = obj;
}
pageController.prototype.getOpenerWindow = function __getOpenerWindow(){
        //OPENEROK
        return this.obj_opener;
}

//top window getWindowOpener()'s getWindowOpener() reference
pageController.prototype.setOpenersOpenerWindow = function __setOpenersOpenerWindow(obj){
        //OPENEROK
        this.obj_openers_opener_top = obj;
}
pageController.prototype.getOpenersOpenerWindow = function __getOpenersOpenerWindow(){
        //OPENEROK
        return this.obj_openers_opener_top;
}

//Shared And Owned
pageController.prototype.setSharedAndOwned = function __setSharedAndOwned(bln){
        this.sharedAndOwned = bln;
}
pageController.prototype.isSharedAndOwned = function __isSharedAndOwned(){
        return this.sharedAndOwned;
}

//Shared And Not Owned
pageController.prototype.setSharedAndNotOwned = function __setSharedAndNotOwned(bln){
        this.sharedAndNotOwned = bln;
}
pageController.prototype.isSharedAndNotOwned = function __isSharedAndNotOwned(){
        return this.sharedAndNotOwned;
}

//owner of the WebReport
pageController.prototype.setOwner = function __setOwner(txt){
    this.webReportOwner = txt;
}

pageController.prototype.getOwner = function __getOwner(){
    return this.webReportOwner;
}

//opened Last
pageController.prototype.setOpenedLast = function __setOpenedLast(bln){
    this.openedLast = bln;
}

pageController.prototype.getOpenedLast = function __getOpenedLast(){
    return this.openedLast;
}

//showingAdvanced
pageController.prototype.setShowingAdvanced = function __setShowingAdvanced(bln){
    this.showingAdvanced = bln;
}

pageController.prototype.getShowingAdvanced = function __getShowingAdvanced(){
    return this.showingAdvanced;
}
pageController.prototype.setWrapColSize = function __setWrapColSize(txt){
    this.wrapColSize = txt;
}

//mode
pageController.prototype.setMode = function __setMode(txt){
    this.mode = txt;
}

pageController.prototype.getMode = function __getMode(){
    return this.mode;
}

//title
pageController.prototype.setTitle = function __setTitle(txt){
    this.title = txt;
}

pageController.prototype.getTitle = function __getTitle(){
    return this.title;
}

//results title
pageController.prototype.setResultsTitle = function __setResultsTitle(txt){
    this.resultsTitle = txt;
}


pageController.prototype.getResultsTitle = function __getResultsTitle(){
    return this.resultsTitle;
}

//Wrap Columns Size
pageController.prototype.getWrapColSize = function __getWrapColSize(){
    return this.wrapColSize;
}

//type
pageController.prototype.setType = function __setType(txt){
    this.type = txt;
}

pageController.prototype.getType = function __getType(){
    return this.type;
}

//metricsReportContentURL
pageController.prototype.setReportContentURL = function __setReportContentURL(txt){
    this.metricsReportContentURL = txt;
}

pageController.prototype.getReportContentURL = function __getReportContentURL(){
    return this.metricsReportContentURL;
}

//savedReportName
pageController.prototype.setSavedReportName = function __setSavedReportName(txt){
    this.savedReportName = txt;
}

pageController.prototype.getSavedReportName = function __getSavedReportName(){
    return this.savedReportName;
}

pageController.prototype.clearSavedReportName = function __clearSavedReportName(){
    this.savedReportName = "";
}

//showErrMsg
pageController.prototype.setShowErrMsg = function __setShowErrMsg(bln){
    this.showErrMsg = bln;
}

pageController.prototype.getShowErrMsg = function __getShowErrMsg(){
    return this.showErrMsg;
}

//doReload
pageController.prototype.setDoReload = function __setDoReload(bln){
    this.doReload = bln;
}

pageController.prototype.getDoReload = function __getDoReload(){
    return this.doReload;
}

//doSubmit
pageController.prototype.setDoSubmit = function __setDoSubmit(bln){
    this.doSubmit = bln;
}

pageController.prototype.getDoSubmit = function __getDoSubmit(){
    return this.doSubmit;
}

//arrFormVals
pageController.prototype.clearArrFormVals = function __clearArrFormVals(){
    this.arrFormVals.length = 0;
}

pageController.prototype.addToArrFormVals = function __addToArrFormVals(arrVal){
    this.arrFormVals[this.arrFormVals.length] = arrVal;
}

pageController.prototype.getArrFormValsLength = function __getArrFormValsLength(){
    return this.arrFormVals.length;
}

//This function sets the window title
pageController.prototype.setWindowTitle = function __setWindowTitle(){
    getTopWindow().document.title = this.title;
}

//This function sets the reportHeader pageHeader text
pageController.prototype.setPageHeaderText = function __setPageHeaderText(){
    var heading = $bmId('pageHeader');
    heading.innerHTML = this.title;
}

//This function sets the reportResultsHeader pageHeader text
pageController.prototype.setResultsPageHeaderText = function __setResultsPageHeaderText(){
    var heading = $bmId('divPageTitle');
    heading.innerHTML = this.title;
}

//This function sets the helpMarker
pageController.prototype.setHelpMarker = function __setHelpMarker(str){
    this.helpMarker = str;
}

//This function sets help marker suite directory
pageController.prototype.setHelpMarkerSuiteDir = function __setHelpMarkerSuiteDir(str){
    this.helpMarkerSuiteDir = str;
}

//This function opens help
pageController.prototype.openHelp = function __openHelp(){
    openHelp(this.helpMarker,this.helpMarkerSuiteDir,STR_SEARCH_LANG);
}

//This function sets the queryLimit
pageController.prototype.setQueryLimit = function __setQueryLimit(strNum){
    this.queryLimit = strNum;
}

//This function gets the queryLimit
pageController.prototype.getQueryLimit = function __getQueryLimit(){
    return this.queryLimit;
}

//This function sets the pagination
pageController.prototype.setPagination = function __setPagination(strNum){
    this.pagination = strNum;
}

//This function gets the pagination
pageController.prototype.getPagination = function __getPagination(){
    return this.pagination;
}

//This function sets the Command Name
pageController.prototype.setCommandName = function __setCommandName(strNum){
    this.commandname = strNum;
}

//This function gets the Command Name
pageController.prototype.getCommandName = function __getCommandName(){
    return this.commandname;
}

//metricsReportContentURL
pageController.prototype.setReportResultsURL = function __setReportResultsURL(txt){
    this.metricsReportResultsURL = txt;
}

pageController.prototype.getReportResultsURL = function __getReportResultsURL(){
    return this.metricsReportResultsURL;
}

//timeStamp
pageController.prototype.setTimeStamp = function __setTimeStamp(txt){
        this.timeStamp = txt;
}
pageController.prototype.getTimeStamp = function __getTimeStamp(){
        return this.timeStamp;
}

//Comma Separated Form Element Values for comparison
pageController.prototype.setConvertedFormElements = function __setConvertedFormElements(txt){
        this.commaSeparatedFormElements = txt;
}
pageController.prototype.getConvertedFormElements = function __getConvertedFormElements(){
        return this.commaSeparatedFormElements;
}
//displayformat
pageController.prototype.setDisplayFormat = function __setDisplayFormat(txt){
        this.displayFormat = txt;
}
pageController.prototype.getDisplayFormat = function __getDisplayFormat(){
        return this.displayFormat;
}
//displayformat
pageController.prototype.setBooleanDisplayFormat = function __setBooleanDisplayFormat(txt){
        this.booleanDisplayFormat = txt;
}
pageController.prototype.getBooleanDisplayFormat = function __getBooleanDisplayFormat(){
        return this.booleanDisplayFormat;
}
//changed displayformat
pageController.prototype.setChangedDisplayFormat = function __setChangedDisplayFormat(txt){
        this.changedDisplayFormat = txt;
}
pageController.prototype.getChangedDisplayFormat = function __getChangedDisplayFormat(){
        return this.changedDisplayFormat;
}
//Latest Saved Report Name
pageController.prototype.setLatestSavedReportName = function __setLatestSavedReportName(txt){
    this.latestSavedReportName = txt;
}

pageController.prototype.getLatestSavedReportName = function __getLatestSavedReportName(){
    return this.latestSavedReportName;
}
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////End PageController Class////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

//This function determines where the Metrics Framework Dialog will open.
function findReportFrame(){
    //arguments[0] is the url of the Report Specific Dialog page
    //arguments[1] is the targetFrame name
    //arguments[2] is the page title
    //arguments[3] is the commandName
    //arguments[4] is the helpMarker parameter
    //arguments[5] is the registered suiteKey parameter
    //arguments[6] is the helpMarker suiteDir parameter
    if(arguments.length){
    //debugger
        //determine if the report window is already open
        var targetFrame = findFrame(getTopWindow(),arguments[1]);

        //if open target frame
        if(targetFrame){
            targetFrame.location.href = arguments[0];
            pageControl = new pageController();
            //store content url
            pageControl.setReportContentURL(arguments[0]);




            //is there a title to set?
            if(arguments[2]){
                //store title
                pageControl.setTitle(arguments[2]);

                //set window Title
                pageControl.setWindowTitle();

                //set window Title
                pageControl.setPageHeaderText();
            }

            //is there a helpMarker to set?
            if(arguments[4]){
               //store the helpMarker
                pageControl.setHelpMarker(arguments[4]);
            }

            //is there a helpMarker suiteDir to set?
            if(arguments[5]){
               //store the helpMarker
                pageControl.setHelpMarkerSuiteDir(arguments[5]);
            }

            //is there a helpMarker suiteDir to set?
            if(arguments[8]){
               //store the helpMarker
                pageControl.setSavedReportName(arguments[8]);
            }

            //is there a timeStamp to set?
            if(arguments[9]){
               //store the timeStamp
                pageControl.setTimeStamp(arguments[9]);
            }

        //else call showNonModal
        }else{
            // added for View Def portal mode fix
            if(arguments[11]!="true")
            {
                try
                {
                   // arguments[7] is portalMode
                   if(arguments[7] == "true"){
                       showModalDialog("../businessmetrics/emxMetrics.jsp?defaultReport=" + arguments[3] + "&suiteKey=" + arguments[5] + "&suiteDirectory=" + arguments[6] + "&portalMode=" + arguments[7] + "&reportName="+arguments[8]+ "&viewdef="+arguments[10]+ "&reportOwner="+arguments[9],700,500,true);
                   }
                   else{
                       showNonModalReport("../businessmetrics/emxMetrics.jsp?defaultReport=" + arguments[3] + "&suiteKey=" + arguments[5] + "&suiteDirectory=" + arguments[6] + "&portalMode=" + arguments[7] + "&reportName="+arguments[8]+ "&viewdef="+arguments[10]+ "&reportOwner="+arguments[9]);
                   }

                }
                catch(e)
                {
                }
            }
            else
            {
                try
                {
                   if(arguments[7] == "true"){
                       var tempURL = "../businessmetrics/emxMetrics.jsp?defaultReport=" + arguments[3] + "&suiteKey=" + arguments[5] + "&suiteDirectory=" + arguments[6] + "&portalMode=" + arguments[7] + "&reportName="+decodeURI(arguments[8])+ "&viewdef="+arguments[11]+ "&reportOwner="+decodeURI(arguments[10])+ "&timeStamp="+ arguments[9] + "&mode=" + arguments[12] + "&launched=" + arguments[14];
                       showModalDialog(tempURL,700,500,true);
                   }
                   else{
                       showNonModalReport("../businessmetrics/emxMetrics.jsp?defaultReport=" + arguments[3] + "&suiteKey=" + arguments[5] + "&suiteDirectory=" + arguments[6] + "&portalMode=" + arguments[7] + "&reportName="+decodeURI(arguments[8])+ "&viewdef="+arguments[11]+ "&reportOwner="+decodeURI(arguments[10])+ "&timeStamp="+ arguments[9] + "&mode=" + arguments[12]+ "&launched=" + arguments[14]);
                   }
                }
                catch(e)
                {
                }
            }
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
    jQuery(objWindow).focus();
    registerChildWindows(objWindow, getTopWindow());
}

function enableFunctionality(functionality,bln){
    var headerFrame = $bmId('divPageHead');
    if(headerFrame == null){
    	headerFrame = document.getElementById("divPageHead");
    }
    if(headerFrame!=null && headerFrame.toolbars){
        if(headerFrame.toolbars[0]){
            if(!bln)
            {
            // Added by 354848 to validate if the Toolbar exists pivot limit
            if(headerFrame.toolbars[0].items[0].menu != null)
            {
              for(var i=0;i<headerFrame.toolbars[0].items[0].menu.items.length;i++)
              {
                  var actualText = headerFrame.toolbars[0].items[0].menu.items[i].text;
                  if(actualText.indexOf(".",0)!=-1)
                  {
                     actualText = actualText.substring(0,actualText.indexOf(".",0));
                  }
                  if(actualText == functionality){
                      if(!headerFrame.toolbars[0].items[0].menu.items[i].menu)
                      {
                          headerFrame.toolbars[0].items[0].menu.items[i].disable();
                      }
                  }
                  if((headerFrame.toolbars[0].items[0].menu.items[i].menu) && (actualText == functionality)){
                      for(var j=0;j<headerFrame.toolbars[0].items[0].menu.items[i].menu.items.length;j++){
                          headerFrame.toolbars[0].items[0].menu.items[i].menu.items[j].disable();
                      }
                  }
              }
             }
             // Added by 354848 if the toolbar items doesnt exists within the pivot limit
             else
             {
              for(var i=0;i<headerFrame.toolbars[0].items.length;i++)
              {
                  var actualText = headerFrame.toolbars[0].items[i].text;
                  if(actualText.indexOf(".",0)!=-1)
                  {
                     actualText = actualText.substring(0,actualText.indexOf(".",0));
                  }
                  if(actualText == functionality){
                      if(!headerFrame.toolbars[0].items[i].menu)
                      {
                          headerFrame.toolbars[0].items[i].disable();
                      }
                  }
                  if((headerFrame.toolbars[0].items[i].menu) && (actualText == functionality)){
                      for(var j=0;j<headerFrame.toolbars[0].items[i].menu.items.length;j++){
                          headerFrame.toolbars[0].items[i].menu.items[j].disable();
                      }
                  }
              }
             }
            }
            else
            {
            if(headerFrame.toolbars[0].items[0].menu != null)
            {
              for(var i=0;i<headerFrame.toolbars[0].items[0].menu.items.length;i++)
              {
                  var actualText = headerFrame.toolbars[0].items[0].menu.items[i].text;
              if(actualText.indexOf(".",0)!=-1)
              {
                  actualText = actualText.substring(0,actualText.indexOf(".",0));
                  }
                  if(actualText == functionality){
                      if(!headerFrame.toolbars[0].items[0].menu.items[i].menu)
                      {
                          headerFrame.toolbars[0].items[0].menu.items[i].enable();
                      }
                  }
                  if((headerFrame.toolbars[0].items[0].menu.items[i].menu) && (actualText == functionality)){
                      for(var j=0;j<headerFrame.toolbars[0].items[0].menu.items[i].menu.items.length;j++){
                          headerFrame.toolbars[0].items[0].menu.items[i].menu.items[j].enable();
                      }
                  }
              }
             }
             // Added by 354848 if the toolbar items doesnt exists within the pivot limit
             else
             {
              for(var i=0;i<headerFrame.toolbars[0].items.length;i++)
              {
                  var actualText = headerFrame.toolbars[0].items[i].text;
                  if(actualText.indexOf(".",0)!=-1)
                  {
                     actualText = actualText.substring(0,actualText.indexOf(".",0));
                  }
                  if(actualText == functionality){
                      if(!headerFrame.toolbars[0].items[i].menu)
                      {
                          headerFrame.toolbars[0].items[i].enable();
                      }
                  }
                  if((headerFrame.toolbars[0].items[i].menu) && (actualText == functionality)){
                      for(var j=0;j<headerFrame.toolbars[0].items[i].menu.items.length;j++){
                          headerFrame.toolbars[0].items[i].menu.items[j].enable();
                      }
                  }
              }
             }
            }
        }
    }
}

/////////////////// TEMPORARY FORM FIELD STORAGE FOR COMPARISON//////////////
function storeFormValsTemporarily()
{
    var myForm = arguments[0];
    var formElementValues = convertFormElements(myForm);
    pageControl.setConvertedFormElements(formElementValues);
}

function convertFormElements()
{
    var myForm = arguments[0];
    var formLen = myForm.elements.length;
    var formElementValues = "";

    for(var i = 0; i < formLen; i++)
    {
        var formField = myForm.elements[i];
        var formFieldValue = "";
        if(formField.type=="radio")
        {
            if(formField.checked)
            {
                formFieldValue = formField.value + ":Checked";
            }
            else
            {
                formFieldValue = formField.value + ":NotChecked";
            }
        }
        else
        {
            formFieldValue = formField.value;
        }
        if(i==0)
        {
            formElementValues = formFieldValue;
        }
        else
        {
           formElementValues = formElementValues + "," + formFieldValue;
        }
    }
    return formElementValues;
}

function compareFormElements()
{
    var myForm = arguments[0];
    var newFormElementValues = convertFormElements(myForm);
    var oldFormElementValues = pageControl.getConvertedFormElements();
    if(oldFormElementValues!=newFormElementValues)
    {
        return false;
    }
    else
    {
        return true;
    }
}
/////////////////// END OF FORM FIELD COMPARISON FUNCTIONS///////////////

/////////////////// FORM FIELD STORAGE //////////////////////////////////
//arrFormVals is an Array in the form of
//arrFormVals[i](String "field name", [Array (int,int)] or String "field value")
//where Array (int,int) is an array of selected indexes for select menus
//example
//arrFormVals[0] = new Array("field_1", new Array(1,2,4));

//also this array should maintain the same order of elements
//form[1] should equal arrFormVals[1]

function storeFormVals(){

    //reset array
    pageControl.clearArrFormVals();

    //loop through form and store values
    var myForm = arguments[0];
    var formLen = myForm.elements.length;
    for(var i = 0; i < formLen; i++){
        addFormValues(myForm[i]);
    }
}

function addFormValues(formfield){

    //select the appropriate data to save
    switch (formfield.type){

        //text fields
        //store value
        case "text" :
        case "textarea" :
        case "hidden" :
            pageControl.addToArrFormVals(new Array(formfield.name,formfield.value,null,formfield.disabled));
        break;

        //radio or checkbox
        //store checked boolean
        case "radio" :
        case "checkbox" :
            pageControl.addToArrFormVals(new Array(formfield.name, formfield.value, formfield.checked,formfield.disabled));
        break;

        //select menus
        //store array of selected indexes
        case "select-multiple" :
        case "select-one" :
            var arrSelectValues = new Array();

            for(var i = 0; i < formfield.options.length; i++){
                if(formfield.options[i].selected == true){
                    var selectval = formfield.options[i].value + ":true";
                    arrSelectValues[arrSelectValues.length] = new Array(i,selectval,formfield.options[i].text);
                }
                else
                {
                    var unSelectedValue = formfield.options[i].value + ":false";
                    arrSelectValues[arrSelectValues.length] = new Array(i,unSelectedValue,formfield.options[i].text);
                }
            }
            pageControl.addToArrFormVals(new Array(formfield.name,arrSelectValues));

        break;

        default :
            pageControl.addToArrFormVals(new Array(formfield.name,formfield.value));
        break;

    }


}

//rebuilds the form after the xml is tranformed
function rebuildForm(){
    var comboBoxCount = 0;
    var bodyFrame = null;
    var theForm = null;

    //if doSubmit use hidden content frame
    //find the form


    if(pageControl.getDoSubmit()){
        bodyFrame = findFrame(getTopWindow(),"metricsReportContent");
    }
    bodyFrame = findFrame(getTopWindow(),"metricsReportContent");
    if(bodyFrame)
    {
       theForm = bodyFrame.document.forms[0];
    }
    else
    {
       bodyFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"metricsReportContent");
       theForm = bodyFrame.document.forms[0];
    }

    //for each item in arrFormVals array, based on type check for formfield and set value
    var arrLen = pageControl.getArrFormValsLength();
    if(arrLen != theForm.elements.length){
        pageControl.setShowErrMsg(true);
    }

    for(var i = 0; i < arrLen; i++){
        var foundElement = false;

        try{
            //get the formfield
            var formElement = bodyFrame.document.getElementsByName(pageControl.arrFormVals[i][NAME]);

            var formElementCount = formElement.length;

            for(var j = 0; j < formElementCount; j++){

                switch (formElement[j].type){

                    //text
                    case "text" :
                    case "textarea" :
                    case "hidden" :
                        foundElement = setText(formElement[j], pageControl.arrFormVals[i]);
                    break;

                    //radio
                    case "radio" :
                        foundElement = setRadioChecked(formElement[j], pageControl.arrFormVals[i]);
                    break;

                    //checked
                    case "checkbox" :
                        foundElement = setChecked(formElement[j], pageControl.arrFormVals[i]);
                    break;

                    //select
                    case "select-multiple" :
                    case "select-one" :

                        foundElement = setSelect(formElement[j], pageControl.arrFormVals[i])
                    break;

                    default:
                        foundElement = true;
                    break;
                }

                //if we found a match break out of loop
                if(foundElement){
                    break;
                }

                //if this is the last element and we didn't find
                //a match set Alert
                if(!foundElement && j == formElementCount-1){
                    pageControl.setShowErrMsg(true);
                }
            }
        }catch(e){
                pageControl.setShowErrMsg(true);
        }
    }

    if(pageControl.getShowErrMsg()){
        pageControl.setShowErrMsg(false);
    }

    storeFormValsTemporarily(theForm);
}

function setText(formfield, val){
    if(formfield.name == val[NAME]){
        formfield.value = val[VALUE];
        formfield.disabled = val[DISABLED];
        return true;
    }
    return false;
}

function setRadioChecked(formfield, val){
    if((formfield.name == val[NAME]) && (formfield.value == val[VALUE] || formfield.value == unescape(val[VALUE])))
    {
        formfield.checked = val[CHECKED];
        formfield.value = val[VALUE];
        formfield.disabled = val[DISABLED];
        return true;
    }
    return false;
}

function setChecked(formfield, val){
    if(formfield.name == val[NAME])
    {
        formfield.checked = val[CHECKED];
        formfield.value = val[VALUE];
        return true;
    }
    return false;
}

function setSelect(formfield, arrOpts){
     if(formfield.name == arrOpts[NAME]){
            var populateAllData = false;
            if(formfield.name != "chartType")
            {
              populateAllData = true;
              //clear current selections
              var formfieldOptsLen = formfield.options.length;
              for(var i=formfieldOptsLen-1;i>-1;i--){
                  formfield.options[i] = null;
              }
            }
        //reset
        var arrOptsLen = arrOpts[VALUE].length;

        for(var j=0; j<arrOptsLen; j++)
        {
             var savedElement = decodeURI(arrOpts[VALUE][j][1]);
             var savedText = decodeURI(arrOpts[VALUE][j][2]);
             var element = savedElement.substring(0,savedElement.indexOf(":"));
             var xx = new Option(element,element);
             if(populateAllData)
             {
               formfield.options.add(xx);
             }

           if(savedElement.substring(savedElement.indexOf(":") + 1, savedElement.length)=="true"){
               formfield.options[j].selected = true;
           }
           if(populateAllData)
           {
             formfield.options[j].text = savedText;
           }
        }
        return true;
    }
    return false;
}

///////////////////////////////////////////////////////////////////
//resets all the pageControl settings after the xml is transformed and reloads the report
//specific dialog page

function reviseReport(vName,vView){
   try
   {
      //debugger
      //if doSubmit use hidden content frame
       var metricsReportViewFrame = null;

       if(pageControl.getDoSubmit()){
           metricsReportViewFrame = findFrame(getTopWindow(),"metricsReportContent");
       }else{
           metricsReportViewFrame = findFrame(getTopWindow(),"metricsReportView");
       }

       //querystring
       var querystring = escape(pageControl.getReportContentURL());

       // get metricsReportViewUrl
       var metricsReportViewUrl = "emxMetricsView.jsp?url=" + querystring;

       //if hidden submit use only the
       if(pageControl.getDoSubmit()){
           metricsReportViewUrl = pageControl.getReportContentURL();
           if(metricsReportViewUrl.lastIndexOf("#")==(metricsReportViewUrl.length - 1))
           {
               metricsReportViewUrl = metricsReportViewUrl.substring(0,metricsReportViewUrl.indexOf("#"));
           }
       }

       pageControl.setDoReload(true);
       if(("open .last"!=vName) && (vView!="true"))
       {
           pageControl.setSavedReportName(decodeURI(vName));
           metricsReportViewFrame.location.href = metricsReportViewUrl;
       }
       else if(("open .last"!=vName) && (vView=="true"))
       {
           getTopWindow().loadReportFormFields();
       }
       else
       {
           pageControl.setDoSubmit(true);
           getTopWindow().loadReportFormFields();
       }
           var footerFrame = $bmId('divPageFoot');
           footerFrame.children[0].WrapColSize.value = pageControl.getWrapColSize();
    }
    catch(e)
    {
    }
    //NOTE add footer values
}

function loadReportFormFields(){
    setTimeout("checkReloadFlag()",50);
}

function checkReloadFlag(){
    if(pageControl.getDoReload())
        eval(rebuildForm());
    if(pageControl.getDoSubmit()){
        //find the form
        var bodyFrame = findFrame(getTopWindow(),"metricsReportContent");
        //bodyFrame.doReport();
    }

    pageControl.setDoSubmit(false);
    pageControl.setDoReload(false);
}

///////////////////// Save Report Functions //////////////////////////////////
//opens save and save as dialogs

function processSaveReport(){
    var ContentFrame = findFrame(getTopWindow(),"metricsReportContent");
    if (ContentFrame.validateReport()){
        var footerFrame = $bmId('divPageFoot');
        pageControl.setWrapColSize(footerFrame.children[0].WrapColSize.value);
        if(pageControl.getSavedReportName() == "" || pageControl.getSavedReportName() == "open .last"){
            showModalDialog("emxMetricsSaveDialog.jsp", 400, 225,true);
        }
        else if(pageControl.getOpenedLast())
        {
            showModalDialog("emxMetricsSaveDialog.jsp", 400, 225,true);
        }else{
            if(confirm(STR_METRICS_SAVE_REPORT_MSG))
            {
                var result =  saveReport(pageControl.getSavedReportName(),pageControl.getResultsTitle(), "updateNotes","criteriaUpdate",pageControl.getSavedReportName());
                var hiddenFrame = findFrame(getTopWindow(),"metricsReportHidden");
                hiddenFrame.document.write(result);
            }
        }
    }
}

//results Save process
function processSaveReportResults(){
    try
    {
      if(pageControl.getSavedReportName() == "" || pageControl.getSavedReportName() == "open .last"){
           showModalDialog("emxMetricsSaveDialog.jsp?mode=ResultsSave", 400, 225,true);
      }
      else if(pageControl.getOpenedLast())
      {
           showModalDialog("emxMetricsSaveDialog.jsp?mode=ResultsSave", 400, 225,true);
      }
      else
      {
           var saveCondition = false;
           if(fromPortalMode && (fromPortalMode == "true") ){
              if(pageControl.isSharedAndNotOwned() == true && (pageControl.getChangedDisplayFormat() !=    pageControl.getDisplayFormat()) && pageControl.getChangedDisplayFormat() != ""){
                  alert(STR_METRICS_CHANGED_DISPLAY_FORMAT);
                  saveCondition = true;
              }
           }
           else{
              if((pageControl.isSharedAndNotOwned() == "true"  || pageControl.isSharedAndNotOwned() == true) && (pageControl.getChangedDisplayFormat() != pageControl.getDisplayFormat()) && pageControl.getChangedDisplayFormat() != ""){
                  alert(STR_METRICS_CHANGED_DISPLAY_FORMAT);
                  saveCondition = true;
              }
           }

           if(saveCondition == false){
               saveReportResults(pageControl.getSavedReportName(),pageControl.getTitle(), "update","SaveResults",pageControl.getTimeStamp());
           }
      }
    }
    catch(e)
    {

    }
}

//results save processing
function saveReportResults(strName,strTitle,strSaveType,mode,timeStamp)
{
    var displayFormat;
    var booleanDisplayFormat;
    var owner;
    var fromPortalMode = "false";
    var reportResultsFrame = null;
    var footerFrame = null;
    var headerFrame = null;

    if(findFrame(this,"metricsReportResultsContent")){
        reportResultsFrame = findFrame(this,"metricsReportResultsContent");
    }
    else{
        reportResultsFrame = parent.openerFindFrame(getTopWindow(),"metricsReportResultsContent");
    }

    fromPortalMode = reportResultsFrame.parent.STR_FROM_PORTAL_MODE;

    if(fromPortalMode && (fromPortalMode == "true")){
        // all these values are set in emxMetricsResults.jsp
        displayFormat = reportResultsFrame.parent.pageControl.getDisplayFormat();
        booleanDisplayFormat = reportResultsFrame.parent.pageControl.getBooleanDisplayFormat();
        owner = reportOwner;
    }
    else{
        displayFormat = reportResultsFrame.getTopWindow().pageControl.getDisplayFormat();
        booleanDisplayFormat = reportResultsFrame.getTopWindow().pageControl.getBooleanDisplayFormat();
        owner = reportResultsFrame.getTopWindow().pageControl.getOwner()
    }

    var url = "emxMetricsResultsSave.jsp";
       url += "?saveType=" + strSaveType;
       url += "&reportName=" + strName;
       url += "&reportTitle=" + strTitle;
       url += "&defaultReport=" + reportResultsFrame.parent.pageControl.getCommandName();
       url += "&mode=" + mode;
       url += "&displayFormat=" + displayFormat;
       url += "&booleanDisplayFormat=" + booleanDisplayFormat
       url += "&owner=" + owner;
       url += "&timeStamp=" + timeStamp;
       url += "&fromPortalMode=" + fromPortalMode;
	    if (parent.getWindowOpener()) {
			footerFrame = $bmId('divPageFoot', parent.getWindowOpener().getTopWindow());
			if (footerFrame == null) {
	
				footerFrame = $bmId('divPageFoot', parent.getWindowOpener());
			}
		} else if (footerFrame == null) {
			footerFrame = $bmId('divPageFoot', parent.getTopWindow());
		}
    var thisForm;

    if(footerFrame){
        thisForm = footerFrame.children[0];
    }
     else {
		if (parent.getWindowOpener() != null) {
			headerFrame = $bmId('divPageHead', parent.getWindowOpener().getTopWindow());
			if (headerFrame == null) {
				headerFrame = $bmId('divPageHead', parent.getWindowOpener());
			}
		} else if (headerFrame == null) {
			headerFrame = $bmId('divPageHead', this);
		}
        thisForm = headerFrame.children[0];
    }
    
    thisForm.action = url;
    thisForm.method = "post";
    if(fromPortalMode!=null && fromPortalMode == "true")
    {
       thisForm.target = "metricsReportResultsHidden";
    }
    else if(parent.openerFindFrame(parent,"reportSaveHidden"))
    {
       thisForm.target = "reportSaveHidden";
    }
    else
    {
       thisForm.target = "metricsReportResultsHidden";
    }
    if(isIE) {
    	jQuery(document.body).append(thisForm.outerHTML);
        var newChildForm= jQuery("form[name='frmFooter']");
        addSecureToken(newChildForm[0]);
        newChildForm[0].submit();
        removeSecureToken(newChildForm[0]);
    } else {
    addSecureToken(thisForm);
    thisForm.submit();
    removeSecureToken(thisForm);
}

}

//results Save As processing
function saveAsReportResults(strName,strTitle,strSaveType,mode,timeStamp,existingReportName)
{
    var displayFormat;
    var booleanDisplayFormat;
    var owner;
    var fromPortalMode = "false";
    var reportResultsFrame = null;
    var footerFrame = null;
    var headerFrame = null;

    if(findFrame(getWindowOpener(),"metricsReportResultsContent")){
        reportResultsFrame = findFrame(getWindowOpener(),"metricsReportResultsContent");
    }
    else{
        reportResultsFrame = parent.openerFindFrame(getTopWindow(),"metricsReportResultsContent");
    }

    fromPortalMode = reportResultsFrame.parent.STR_FROM_PORTAL_MODE;

    if(fromPortalMode && (fromPortalMode == "true")){
        // all these values are set in emxMetricsResults.jsp
        displayFormat = reportResultsFrame.parent.pageControl.getDisplayFormat();
        booleanDisplayFormat = reportResultsFrame.parent.pageControl.getBooleanDisplayFormat();
        owner = reportResultsFrame.parent.STR_REPORT_OWNER;
    }
    else{
        displayFormat = reportResultsFrame.parent.pageControl.getDisplayFormat();
        booleanDisplayFormat = reportResultsFrame.parent.pageControl.getBooleanDisplayFormat();
        owner = reportResultsFrame.parent.pageControl.getOwner();
    }

    if(strSaveType == "saveas")
    {
        strSaveType = "save";
    }

    var url = "emxMetricsResultsSaveAs.jsp";
       url += "?saveType=" + strSaveType;
       url += "&reportName=" + strName;
       url += "&reportTitle=" + strTitle;
       url += "&defaultReport=" + reportResultsFrame.parent.pageControl.getCommandName();
       url += "&mode=" + mode;
       url += "&timeStamp=" + timeStamp;
       url += "&existingReportName=" + existingReportName;
       url += "&owner=" + owner;
       url += "&chartType=" +displayFormat;
       url += "&fromDisplayFormat=" +booleanDisplayFormat;

   headerFrame = $bmId('divPageHead', parent.getWindowOpener().getTopWindow());
    if(headerFrame == null)
    {
    	headerFrame = $bmId('divPageHead', parent.getWindowOpener());
    }
    thisForm = headerFrame.children[0];

    thisForm.action = url;
    thisForm.method = "post";
    if(fromPortalMode!=null && fromPortalMode == "true")
    {
       thisForm.target = "metricsReportSaveAsHidden";
    }
    else if(parent.openerFindFrame(parent,"metricsReportSaveAsHidden"))
    {
       thisForm.target = "metricsReportSaveAsHidden";
    }
    else
    {
       thisForm.target = "metricsReportResultsHidden";
    }

    thisForm.submit();
}

//results ViewDefinition processing
function viewReportDefinition(){
    // fromPortalMode will be available in the emxMetricsResults.jsp
    // reportOwner will be available in the emxMetricsResults.jsp

    var reportName;
    var timeStamp;
    var mode;

    if(fromPortalMode != null && (fromPortalMode == "true") ){
        reportName = pageControl.getSavedReportName();
        timeStamp = pageControl.getTimeStamp();
        mode = pageControl.getMode();
    }
    else{
        reportName = pageControl.getSavedReportName();
        timeStamp = pageControl.getTimeStamp();
        mode = pageControl.getMode();
    }

    var url = "emxMetricsViewDefinition.jsp";
        url += "?defaultReport=" + strCommandName;
        url += "&reportName=" + reportName;
        url += "&fromPortalMode="+fromPortalMode;
        url += "&reportOwner="+reportOwner;
        url += "&timeStamp="+timeStamp;
        url += "&mode=" + mode;
        url += "&launched=" + isPageLaunched; // available in emxMetricsResults.jsp

    // added as portal mode View Def fix
    var headerFrame = $bmId('divPageHead');
    if(headerFrame == null){
    	headerFrame = document.getElementById('divPageHead');
    }
    var thisForm = headerFrame.children[0];

    thisForm.action = url;
    thisForm.method = "post";
    thisForm.target = "metricsReportResultsHidden";
    thisForm.submit();
}

function processOpenReports(){
    showModalDialog("../common/emxTable.jsp?suiteKey=BusinessMetrics&table=MetricsTableForOpenViewDelete&program=emxMetricsWebReports:getOwnedWebReports,emxMetricsWebReports:getSharedWebReports,emxMetricsWebReports:getAllWebReports&programLabel=emxMetrics.label.Owned,emxMetrics.label.Shared,emxMetrics.label.All&header=emxMetrics.label.OpenReports&CancelButton=true&SubmitURL=../businessmetrics/emxMetricsOpenViewDeleteReportProcess.jsp?mode=open&SubmitLabel=emxMetrics.label.Done&selection=none&objectBased=false&Export=false&pagination=0&PrinterFriendly=false&Style=dialog&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelpreportaccess&mode=open&reporttype="+pageControl.getCommandName(), 700, 500,true);
}

function processViewReports(){
    showModalDialog("../common/emxTable.jsp?suiteKey=BusinessMetrics&table=MetricsTableForOpenViewDelete&program=emxMetricsWebReports:getOwnedWebReports,emxMetricsWebReports:getSharedWebReports,emxMetricsWebReports:getAllWebReports&programLabel=emxMetrics.label.Owned,emxMetrics.label.Shared,emxMetrics.label.All&header=emxMetrics.label.ViewResults&CancelButton=true&SubmitURL=../businessmetrics/emxMetricsOpenViewDeleteReportProcess.jsp?mode=view&SubmitLabel=emxMetrics.label.Done&selection=none&objectBased=false&Export=false&pagination=0&PrinterFriendly=false&Style=dialog&mode=view&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelpreportviewresults&reporttype="+pageControl.getCommandName(), 700, 500,true);
}

function processDeleteReports(){
    if(confirm(getTopWindow().STR_METRICS_DELETE_REPORT_MSG))
    {
        var reportName = pageControl.getSavedReportName();
        if(reportName==null || reportName ==""){
            reportName = pageControl.getLatestSavedReportName();
        }
        var url = "emxMetricsOpenViewDeleteReportProcess.jsp";
            url += "?reportName=" + reportName;
            url += "&reporttype=" + pageControl.getCommandName();
            url += "&mode=delete";

        var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
        var thisForm = contentFrame.document.forms[0];
        thisForm.action = url;
        thisForm.method = "post";
        thisForm.target = "metricsReportHidden";
        addSecureToken(thisForm);
        thisForm.submit();
        removeSecureToken(thisForm);
    }
    else
    {
        return false;
    }
}

function processSaveAsReport(){
    try
    {

        var ContentFrame = findFrame(getTopWindow(),"metricsReportContent");
        // passing the current webreport name for restricting in "Save As" page
        var currentWebReportName = pageControl.getLatestSavedReportName();
        if (ContentFrame.validateReport()){
           showModalDialog("emxMetricsSaveAsReport.jsp?HelpMarker=emxhelpreportssaveas&reporttype="+pageControl.getCommandName()+"&fromPortalMode="+fromPortalMode + "&timestamp="+pageControl.getTimeStamp()+"&currentWebReportName="+encodeURI(currentWebReportName), 700, 500,true);
        }
    }
    catch(e)
    {
    }
}

function processSaveAsReportResults(){
    try
    {
       var commandName;
       var timestamp;
       // passing the current webreport name for restricting in "Save As" page
       var currentWebReportName;

       if((fromPortalMode!=null) && (fromPortalMode!="undefined")){
           currentWebReportName = this.pageControl.getSavedReportName();
           commandName = this.pageControl.getCommandName();
           timestamp = this.pageControl.getTimeStamp();
       }
       else{
           currentWebReportName = parent.pageControl.getSavedReportName();
           commandName = pageControl.getCommandName();
           timestamp = pageControl.getTimeStamp();
       }
       showModalDialog("emxMetricsSaveAsReport.jsp?HelpMarker=emxhelpreportssaveas&mode=ResultsSaveAs&reporttype="+commandName+"&fromPortalMode="+fromPortalMode + "&timestamp="+timestamp+"&currentWebReportName="+encodeURI(currentWebReportName), 700, 500,true);

    }
    catch(e)
    {
    }
}

//saves the webreport
function saveReport(strName,strTitle,strSaveType,mode,existingReportName,fromViewDef){

   var oXMLHTTP = null;

   try
   {
      //check that the url is the same in both the pageController and bodyFrame
      //if not then reset
      getTopWindow().validateURL();
      var timeStamp = (new Date()).getTime();
      var vOwner = pageControl.getOwner();
      pageControl.setTimeStamp(timeStamp);

      //build xml doc from formfields
      var xmlData = buildXMLfromForm();
      var url = "emxMetricsNotesSaveProcess.jsp";
          url += "?saveType=" + encodeURI(strSaveType);
          url += "&reportName=" + encodeURI(strName);
          url += "&reportTitle=" + encodeURI(strTitle);
          url += "&defaultReport=" + encodeURI(pageControl.getCommandName());
          url += "&mode=" + encodeURI(mode);
          url += "&timestamp=" + timeStamp;
          url += "&owner=" + encodeURI(vOwner);
          url += "&sharedAndNotOwned=" + pageControl.isSharedAndNotOwned();
          url += "&existingReportName=" + encodeURI(existingReportName);
          url += "&viewdef=" + fromViewDef;

      var oXMLHTTP = emxUICore.createHttpRequest();
      oXMLHTTP.open("post", url, false);
      addSecureTokenHeader(oXMLHTTP);
      oXMLHTTP.send(xmlData);
   }
   catch(e)
   {
   }
   //run tests then...
   return oXMLHTTP.responseText;
}

function deleteReport(strName, strSaveType){
    var xmlData = "<root/>"
    var url = "emxMetricsResults.jsp";
        url += "?saveType=" + strSaveType;
        url += "&saveName=" + strName;

    var oXMLHTTP = emxUICore.createHttpRequest();
    oXMLHTTP.open("post", url, false);
    oXMLHTTP.send(xmlData);
    return oXMLHTTP.responseText;
}

//builds the XML by reading the report-specific dialog page and the pageControl settings
function buildXMLfromForm(){
    var NAME = 0;
    var VALUE = 1;
    var CHECKED = 2;

    var contentFrame = findFrame(getTopWindow(), "metricsReportContent");

    var theForm = contentFrame.document.forms[0];
    /*if(pageControl.getSavedReportName()=="")
    {
       pageControl.setSavedReportName("last");
    }*/

    //save formData
    storeFormVals(theForm);

    var xmlData = emxUICore.createXMLDOM();
    xmlData.loadXML("<root/>");

    //root
    var root = xmlData.documentElement;

    //command
    var command = xmlData.createElement("command");
    root.appendChild(command);
    //jsp
    var jsp = xmlData.createElement("jsp");
    root.appendChild(jsp);
    //params
        //for each
    for (var e in pageControl){
        if(!(typeof pageControl[e] == "function" || typeof pageControl[e] == "object")){
            var param = xmlData.createElement("param");
            param.setAttribute("name", e);
            var tn = xmlData.createTextNode(""+pageControl[e]);
            param.appendChild(tn);
            root.appendChild(param);
        }
    }


    //formdata node
    var formData = xmlData.createElement("formData");
    root.appendChild(formData);

    //for each arrFormArray

    var arrLen = pageControl.getArrFormValsLength();
    for (var i = 0; i < arrLen; i++){
            var formfield = xmlData.createElement("formfield");
            formfield.setAttribute("name", pageControl.arrFormVals[i][NAME]);
            //boolean value?
            if(typeof pageControl.arrFormVals[i][CHECKED] == "boolean"){
                formfield.setAttribute("type", "boolean");
                formfield.setAttribute("checked", pageControl.arrFormVals[i][CHECKED]);
                formfield.setAttribute("disabled", (pageControl.arrFormVals[i][DISABLED])?"true":"false");
            }else if(typeof pageControl.arrFormVals[i][DISABLED] == "boolean"){
                formfield.setAttribute("type", "string");
                formfield.setAttribute("disabled", (pageControl.arrFormVals[i][DISABLED])?"true":"false");
            }else{
                formfield.setAttribute("type", (typeof pageControl.arrFormVals[i][VALUE]));
            }

            //string value
            if(typeof pageControl.arrFormVals[i][VALUE] == "string"){

                //boolean value (checkbox?)
                if(typeof pageControl.arrFormVals[i][CHECKED] == "boolean"){
                    var tn = xmlData.createTextNode(encodeURI(pageControl.arrFormVals[i][VALUE]));
                    formfield.appendChild(tn);
                }else{
                    var tn = xmlData.createTextNode(encodeURI(pageControl.arrFormVals[i][VALUE]));
                    formfield.appendChild(tn);
                }
            }

            //object (array) values
            if(typeof pageControl.arrFormVals[i][VALUE] == "object"){
                var objLen = pageControl.arrFormVals[i][VALUE].length;
                for(var j = 0; j < objLen; j++){
                    var valNode = xmlData.createElement("value");
                    var tmpStr = pageControl.arrFormVals[i][VALUE][j][0] + ",\"" + encodeURI(pageControl.arrFormVals[i][VALUE][j][1]) + "\",\"" + encodeURI(pageControl.arrFormVals[i][VALUE][j][2]) + "\"";
                    var tn = xmlData.createTextNode(tmpStr);
                    valNode.appendChild(tn);
                    formfield.appendChild(valNode);
                }

            }
            //add to formdata
            formData.appendChild(formfield);
    }
    return xmlData.xml;
}

//Retrieves the xml from the notes field and does the xml parsing
//Retrieves the xml from the notes field and does the xml parsing
function importSavedReportXML(vName,vView,reportOwner,timeStamp,mode,viewDef){
    try
    {

       //get reportName
       var strName = pageControl.getSavedReportName();//escape???

       if(strName!="" && strName!=vName && vName!="open .last")
       {
           strName = vName;
       }
       if(strName=="" || strName=="undefined")
       {
           if(vName!="open .last")
           {
               strName = vName;
           }
       }
       var owner = "";
       var isSharedAndNotOwned = pageControl.isSharedAndNotOwned();
       if(isSharedAndNotOwned){
          enableFunctionality(STR_METRICS_SAVE_COMMAND,false);
          enableFunctionality(STR_METRICS_DELETE_COMMAND,false);
       }else if(strName!=""){
          enableFunctionality(STR_METRICS_DELETE_COMMAND,true);
       }
       // when coming from portal mode, for shared webreport,
       // pass in the user name for loading the dialog page
       // in case of View Def
       if(fromPortalMode != 'null'){
           if(pageControl.getOwner().length == 0 ){
               if(reportOwner){
                   owner = reportOwner;
               }
           }
       }
       else{
           owner = pageControl.getOwner();
       }
       var result = "";
       if(timeStamp==null || timeStamp=="" || timeStamp=="null")
       {
          timeStamp = pageControl.getTimeStamp();
       }

       if(fromPortalMode == 'true' && mode != 'reportView' && mode != 'SavedWithNewDisplayFormat'){
           fromPortalMode = "false";
       }

      //get xml data
       var url = "emxMetricsGetSavedReport.jsp";
           url += "?saveName=" + strName;
           url += "&reporttype=" + pageControl.getCommandName();
           url += "&portalMode=" + fromPortalMode;
           url += "&owner=" + owner;
           url += "&timeStamp=" + timeStamp;
           url += "&mode=" + mode;

       //add a timestamp to prevent caching
       var timestamp = (new Date()).getTime();
           url += "&timestamp=" + timestamp;

       // load the xml file
       var myXMLHTTPRequest = emxUICore.createHttpRequest();
       myXMLHTTPRequest.open("GET", url, false);
       myXMLHTTPRequest.send(null);

       //load xml into DOM
       var xmlDoc = emxUICore.createXMLDOM();
       xmlDoc.loadXML(myXMLHTTPRequest.responseText);

       // Fix for bug #302627. An alert message will be shown when the shared user tries to
       // access the webreport definition which had been already deleted by the webreport
       // owner(like "Save" in dialog page)
       if((strName.length>0) && (myXMLHTTPRequest.responseText.length == 309 || myXMLHTTPRequest.responseText.length == 0)){
           alert(STR_METRICS_DEFINITION_CHANGED);
       }
       else{

           //test for valid xml???
           if (isIE) {
                if (xmlDoc.parseError != 0) {
                     // its not going into this !!
                     findFrame(getTopWindow(),"metricsReportHidden").document.write(myXMLHTTPRequest.responseText);
                     return;
                }
          } else {
                if (xmlDoc.documentElement.tagName == "parsererror") {
                        findFrame(getTopWindow(),"metricsReportHidden").document.write(myXMLHTTPRequest.responseText);
                        return;
                }
          }

          //store doSubmit
           var localDoSubmit = pageControl.getDoSubmit();

            //create new pageController
          pageControl = new pageController();

          //set openedLast true if it is last report
          //this should happen only for the first time
          //the dialog is opened
          if(vName=="open .last")
          {
              pageControl.setOpenedLast(true);
              enableFunctionality(getTopWindow().STR_METRICS_DELETE_COMMAND,false);
          }

          //reset doSubmit
          pageControl.setDoSubmit(localDoSubmit);
          //extract and set pageControl values
          evalTransform(myXMLHTTPRequest, xmlDoc, "emxMetricsReportSetParams.xsl");

          //extract and set arrFormVals
          evalTransform(myXMLHTTPRequest, xmlDoc, "emxMetricsReportSetFormArray.xsl");

          if((mode=="reportDisplay" && viewDef=="ViewDefinition") || (mode=="openReport" && vView=="true") || fromPortalMode != 'null'){
              if(fromPortalMode != 'null'){
                  pageControl.setLatestSavedReportName(decodeURI(strName));
              }else{
                  pageControl.setLatestSavedReportName(strName);
              }
          }

          //load the saved report
          reviseReport(vName,vView);
          if(timeStamp!=null || timeStamp!="undefined" || timeStamp!="null")
          {
              pageControl.setTimeStamp(timeStamp);
          }
          pageControl.setSharedAndNotOwned(isSharedAndNotOwned);
      }
   }
   catch(e)
   {
   }
}

function createXSLTProcessor() {
    if (!isIE)
    {
        return new XSLTProcessor();
    }
}

//Transforms the generated xml from notes field into the actual form field data
function evalTransform(oHTTPReq ,oXML, strXSLFile){

    //get the xslt file
    oHTTPReq.open("GET", strXSLFile, false);
    oHTTPReq.send(null);

    //create DOM
    var xslStylesheet = emxUICore.createXMLDOM();

    //load stylesheet
    xslStylesheet.loadXML(oHTTPReq.responseText);

    //create the xslt processor
    var xsltProcessor = createXSLTProcessor();

    //transform and evaluate
    if(isIE){
            result = oXML.transformNode(xslStylesheet);
            eval(result);
    }else{
            xsltProcessor.importStylesheet(xslStylesheet);
            result = xsltProcessor.transformToDocument(oXML);
            eval(result.documentElement.childNodes[0].nodeValue);
    }
}


function validateURL(){
    //check that the bodyFrame url is the same as the pageController url
    //if different set the pageController url to bodyFrame url
    var bodyFrame = findFrame(getTopWindow(),"metricsReportContent");
    var bodyFrameURL = bodyFrame.document.location.href;
    var pageControlURL = pageControl.getReportContentURL();

    if(!compareURLs(pageControlURL,bodyFrameURL)){
        var tmpURL = getRelativeURL(bodyFrameURL);
        if(tmpURL != pageControlURL){
            pageControl.setReportContentURL(tmpURL);
        }
    }
}


function compareURLs(a,b){
    //if there is no ../ in url just return true
    //we don't want to handle this case
    if(a.indexOf("../") == -1){
        return true;
    }
    var url_1 = a.substring(3);     //a holds a relative url "../appName/file.jsp?param=x"
    var iStart = b.indexOf(url_1)   //b holds a full url "http://host/app..."
    if(iStart > -1){
        return (b.substring(iStart) == url_1);
    }
    return false;
}


function getRelativeURL(strURL){
    var url = pageControl.getReportContentURL();
    var appDir = url.substring(3,url.indexOf("/",3))
    var iStart = strURL.indexOf(appDir);
    if(iStart > -1){
        return "../" + strURL.substring(iStart);
    }
    return url;
}



///////////////////////////////////////////////////////////////////////////////

// added for Object Count Report

function updateAttributes(){
  var dialogFormName = document.forms [0].name

  var emxType = arguments[0];

  //if emxType == null get emyType from form
  if((typeof emxType) == "undefined"){
       emxType = document.getElementById("txtTypeActual").value;
  }

  if (dialogFormName == "MetricsObjectCountReportForm"){
      // this is submitting in hidden frame....The frame "metricsReportHidden"
      // is present in the emxBPMReport.jsp

      document.forms [0].target = "metricsReportHidden";
      document.forms [0].action = "emxMetricsObjectCountReportGetValues.jsp?Type="+emxType;
      document.forms [0].submit ();
  }

  updateType();
}


function updateSubgroup(){

    var dialogFormName = document.forms [0].name
    var emxType = arguments[0];
    //if emxType == null get emyType from form
    if((typeof emxType) == "undefined"){
        emxType = document.getElementById("txtTypeActual").value;
    }

    var attrName = document.getElementById("lstGroupBy").value;
    document.forms [0].target = "metricsReportHidden";
    document.forms [0].action = "emxMetricsObjectCountReportSubGroupValues.jsp?Type="+emxType+"&AttributeName="+attrName;
    document.forms [0].submit ();

}

////////////////////Object Count Report Over Time///////////////////////////

function updateAttributesForOverTime(){
  var dialogFormName = document.forms [0].name

  var emxType = arguments[0];

  //if emxType == null get emyType from form
  if((typeof emxType) == "undefined"){
       emxType = document.getElementById("txtTypeActual").value;
  }

  if (dialogFormName == "MetricsObjectCountOverTimeReportForm"){
      // this is submitting in hidden frame....The frame "metricsReportHidden"
      // is present in the emxBPMReport.jsp

      document.forms [0].target = "metricsReportHidden";
      document.forms [0].action = "emxMetricsObjectCountOverTimeReportGetValues.jsp?Type="+emxType;
      document.forms [0].submit ();
  }

  updateType();
}


function updateSubgroupForOverTime(){

    var dialogFormName = document.forms [0].name
    var emxType = arguments[0];
    //if emxType == null get emyType from form
    if((typeof emxType) == "undefined"){
        emxType = document.getElementById("txtTypeActual").value;
    }

    var attrName = document.getElementById("lstGroupBy").value;
    document.forms [0].target = "metricsReportHidden";
    document.forms [0].action = "emxMetricsObjectCountOverTimeReportSubGroupValues.jsp?Type="+emxType+"&AttributeName="+attrName;
    document.forms [0].submit ();

}


////////////////////////////////////////////////////////////////////////////

function updateType(){
    var emxType = arguments[0];

    //if emxType == null get emyType from form
    if((typeof emxType) == "undefined"){
        emxType = document.getElementById("txtTypeActual").value;
    }

    if (pageControl && emxType != pageControl.getType()){
        typeChanged = true;
        document.getElementById("txtTypeActual").value = emxType;
        pageControl.setType(emxType);
        document.forms[0].txtTypeDisplay.title=emxType;
        if (pageControl.getShowingAdvanced() == false){
            return;
        }else{
            var objDiv = document.getElementById("divMore");
            if(getAdvancedSearch(typeChanged,objDiv)){
                typeChanged = false;
            }
        }
    }
}


//  check for valid numeric strings
function IsNumeric(field)
{
   var strValidChars = "0123456789";
   var strChar;
   var blnResult = true;
   var strString = field.value;

   if (strString.length == 0) return false;

   //  test strString consists of valid characters listed above
   for (i = 0; i < strString.length && blnResult == true; i++)
      {
      strChar = strString.charAt(i);
      if (strValidChars.indexOf(strChar) == -1)
         {
            blnResult = false;
         }
      }
   return blnResult;
}

function setSelectedPolicyOption()
{
   var txtType = document.getElementById("txtTypeActual").value
   showChooser('../businessmetrics/emxMetricsPolicyChooser.jsp?formName=frmLifecycleDurationReport&frameName=metricsReportContent&fieldNameDisplay=txtPolicyDisplay&fieldNameActual=txtPolicyActual&selectedType='+txtType);
}

function generateReport(){

    var ContentFrame = findFrame(getTopWindow(),"metricsReportContent");
    var contextUser = arguments[0];
    var fromViewDef = strViewDef;

    if(pageControl.getSavedReportName()=="")
    {
        pageControl.setOwner(contextUser);
    }

    if(!compareFormElements(ContentFrame.document.forms[0]) && pageControl.isSharedAndNotOwned())
    {
         alert(getTopWindow().STR_METRICS_SHARED_DEF_CHANGE_MSG);
    }
    else
    {
       var footerFrame = $bmId('divPageFoot');
       var result = "";
       pageControl.setWrapColSize(footerFrame.children[0].WrapColSize.value);
       if (ContentFrame.validateReport())
       {
           var savedReportName = pageControl.getSavedReportName();

           if(savedReportName != null && savedReportName != "")
           {
              result = getTopWindow().saveReport(savedReportName,pageControl.getResultsTitle(),"update","reportDisplay","",fromViewDef);
           }
           else
           {
              result = getTopWindow().saveReport("",pageControl.getResultsTitle(),"save","reportDisplay","",fromViewDef);
           }
           var hiddenFrame = findFrame(getTopWindow(),"metricsReportHidden");
           hiddenFrame.document.write(result);
       }
    }
}

function submitDialog(){
    var frm = findFrame(getTopWindow(),"metricsReportContent");
    var thisForm = frm.document.forms[0];
    thisForm.action = "emxMetricsSubmitDialogAction.jsp?mode=reportDisplay&defaultReport="+pageControl.getCommandName();
    thisForm.method = "post";
    thisForm.target = "metricsReportHidden";
    thisForm.submit();
}


function openResultsDialog(timeStamp){

    var viewdef = arguments[1]; // the second argument of the function
    var ContentFrame = findFrame(getTopWindow(),"metricsReportContent");
    var reportName="";
    var showPercentage = ContentFrame.document.getElementById("showPercentage").innerHTML;
    if(pageControl.getOpenedLast())
    {
        reportName = "";
    }else{
        reportName = pageControl.getSavedReportName();
    }

    // added for portal mode
    if(getTopWindow().fromPortalMode && (getTopWindow().fromPortalMode == 'true')){
        if(reportName.length == 0){
            reportName = parent.pageControl.getSavedReportName();
        }
    }

    var strURL = "emxMetricsResults.jsp?mode=reportDisplay&defaultReport="+pageControl.getCommandName()+"&resultsTitle=" + (pageControl.getResultsTitle()) +"&reportName="+ (reportName)+"&wrapColSize="+pageControl.getWrapColSize()+"&timestamp="+timeStamp+"&owner="+pageControl.getOwner()+"&viewdef="+viewdef+"&showPercentage="+showPercentage;
    // Change for Portal mode
    // Essentially, if the View Def (dialog page). is opened from Portal Mode, on click of "Done"
    // should refresh the portal.
    // If the dialog page is opened normally, click of "Done" should open the results in oppup

    //var headerFrame = findFrame(parent.getWindowOpener(),"metricsReportResultsHeader");
    var hiddenFrame = findFrame(this,"metricsReportHidden");

    // Obtain the reference of portal mode from the emxMetrics.jsp
    // call it as getTopWindow().isPortalMode because the openResultsDialog() will be called
    // on click of "Done" in the footer of the dialog page
    if(getTopWindow().fromPortalMode && (getTopWindow().fromPortalMode == 'true')){
         strURL += "&portalMode=true&showRefresh=true";
         if(hiddenFrame){
            hiddenFrame.location.href = "emxMetricsSubmitDialogAction.jsp?url=" + encodeHREF(strURL);
         }
    }
    else
    {
        try
        {
            showNonModalDialog("emxMetricsSubmitDialogAction.jsp?url="+encodeHREF(strURL), 700, 600,false);
        }
        catch(e)
        {
        }
    }
}

//This function opens a reusable window
function showNonModalReportResults(strURL){
        var objWindow = window.open(strURL, "NonModalReportWindow","width=900,height=600,resizable=yes");
        registerChildWindows(objWindow, getTopWindow());
        objWindow.focus();
}


function openReport(reportName,vView,reportOwner)
{
    //set doSubmit =true
    pageControl.setDoSubmit(true);

    //will be required from view definition
    if(reportName==null || reportName=="" || reportName=="null")
    {
       reportName = pageControl.getSavedReportName();
    }
    if(vView=="true")
    {
       reportName = decodeURI(reportName);
    }

    //get saved report
    eval(importSavedReportXML(encodeURI(reportName),vView,encodeURI(reportOwner),"","openReport",""));
}

function doRefresh(){

    var contentURL = strResultsPageURL;
    tempURL= contentURL.substring(contentURL.indexOf("?"),contentURL.length);
    finalURL = "emxMetricsResults.jsp"+tempURL+"&refreshMode=true";
    // change when "Refresh"ing from Portal Mode
    if(fromPortalMode){
        // While refreshing in portal mode, remove any instances of "launched=null"
        // from the finalURL. This finalURL will also be set as the href for the "Launch"
        // button while loading the "Launch" command in the toolbar by emxToolbarJavaScript.jsp,
        // which will anyhow append "launched=true" to the finalHref.

        if(finalURL.indexOf("launched=null") != -1){
            finalURL = finalURL.replace("launched=null&","");
        }
        this.location.href = finalURL;
    }
    else{
        getTopWindow().location.href = escape(finalURL);
    }
}

//invoked from save dailog to submit to the Results page
function submitFunction(strSaveType,strReportName,strOwner,strReportTitle,strDefaultReport,strMode,timeStamp){
    var url = "emxMetricsResults.jsp";
        url += "?saveType="+strSaveType;
        url += "&reportName="+strReportName;
        url += "&reportTitle="+strReportTitle;
        url += "&defaultReport="+strDefaultReport;
        url += "&mode="+strMode;
        url += "&timestamp="+timeStamp;
        url += "&owner="+strOwner;
    var contentFrame = getTopWindow().findFrame(getTopWindow(),"metricsReportContent");
    contentFrame.document.forms[0].action = url;
    contentFrame.document.forms[0].target = "metricsReportHidden";
    contentFrame.document.forms[0].submit();
 }

 function loadReport()
 {
    var savedName = pageControl.getSavedReportName();
    if(savedName != null && savedName != "" && savedName != "null" && savedName !="open .last")
    {
        if(strViewDef=='true'){

            // the value for 'reportOwner' is assigned in emxMetrics.jsp
            // timeStamp,mode,viewDef
            getTopWindow().importSavedReportXML(encodeURI(savedName),strViewDef,encodeURI(reportOwner),pageControl.getTimeStamp(),pageControl.getMode());
        }else{
            getTopWindow().loadReportFormFields();
        }
    }
    else
    {
        var timeStamp = pageControl.getTimeStamp();
        if(timeStamp!=null && timeStamp!="undefined" && timeStamp!="" && timeStamp!="null")
        {
            getTopWindow().loadReportFormFields();
        }
        else
        {
            getTopWindow().importSavedReportXML("open .last","");
            enableFunctionality(getTopWindow().STR_METRICS_DELETE_COMMAND, false);
        }
    }
 }

//emxMetricsOpenReports functions
function setSaveName(str){
    getTopWindow().getWindowOpener().pageControl.setSavedReportName(str);
}


// Cleanup the session level report bean
function cleanupSession (timeStamp,reportType)
{
  var objHiddenFrame = getTopWindow().openerFindFrame(parent, "metricsReportResultsHidden");

  if(objHiddenFrame){
    if(objHiddenFrame.document){
    	submitWithCSRF("emxMetricsReportCleanupSession.jsp?timeStamp="+timeStamp+"&reportType="+reportType , window);
    }
  }
}

function radioSelected()
{
    if((!parent.listDisplay.document.emxTableForm.emxTableRowId) && (!parent.listDisplay.document.emxTableForm.selectedWebReport.checked))
    {
       alert(parent.listFoot.document.forms[0].SubmitAlertMsg.value);
       return;
    }
}


//////////////////// For changing display format //////////////////////////

// argument "displayFormat" is the passed in display format from the command

function changeDisplayFormat(displayFormat){

    var resultsContentFrame = $bmId('divPageHead');
    if(resultsContentFrame == null){
    	resultsContentFrame = document.getElementById('divPageHead');
    }
    if(resultsContentFrame){
        var thisForm = resultsContentFrame.children[0];//document.forms[0];

        if(thisForm){
            // "strResultsPageURL" is in emxMetricsResults.jsp
            // The value of "chartType" in "strResultsPageURL" will be something else..
            // so remove it from the string and add the new value of "chartType" at the end

            // The split function divides the given string into two halves
            // based on the split parameter

            var reportName;
            var referenceDisplayFormat;
            var splitupString;
            var finalURL;

            if(fromPortalMode && (fromPortalMode == "true") ){
                reportName = pageControl.getSavedReportName();
                referenceDisplayFormat = pageControl.getDisplayFormat();
            }
            else{
                reportName = pageControl.getSavedReportName()
                referenceDisplayFormat = pageControl.getDisplayFormat();
            }
            if(reportName){
                var appendReportName = strResultsPageURL.split("reportName=");
                var urlSecondPart = appendReportName[1];
                strResultsPageURL = appendReportName[0]+"reportName="+encodeURI(reportName);
                if(urlSecondPart.indexOf("&") != -1){
                urlSecondPart = urlSecondPart.substring(urlSecondPart.indexOf("&"), urlSecondPart.length);
                strResultsPageURL = strResultsPageURL + urlSecondPart;
                }
            }
            if(strResultsPageURL.indexOf("?chartType=")>0){
                splitupString = strResultsPageURL.split("?chartType=");
            }
            else{
                splitupString = strResultsPageURL.split("&chartType=");
            }
            var firstPart = splitupString[0]
            var tempSecondPart = splitupString[1] // contains value for ChartType. we have to remove it
            var secondPart="";
            var oldDisplayFormat = "";
            if(tempSecondPart){
                var index = tempSecondPart.indexOf("&")
                if(index != -1 ){
                    secondPart = tempSecondPart.substring(index,tempSecondPart.length)
                    oldDisplayFormat = tempSecondPart.substring(0,index-1);
                }
                else{
                    secondPart = "";
                }
            }
            if(referenceDisplayFormat==undefined || referenceDisplayFormat==null || referenceDisplayFormat==""){
                if(fromPortalMode && (fromPortalMode == "true")){
                    pageControl.setDisplayFormat(displayFormat);
                }
                else{
                    pageControl.setDisplayFormat(displayFormat);
                    enableFunctionality(STR_METRICS_SAVE_COMMAND,true);
                }
            }
            else if(referenceDisplayFormat == displayFormat){
                if(fromPortalMode && (fromPortalMode == "false")){
                    enableFunctionality(STR_METRICS_SAVE_COMMAND,false);
                }
            }
            else{
                if(fromPortalMode && (fromPortalMode == "true")){
                    pageControl.setDisplayFormat(displayFormat)
                    enableFunctionality(STR_METRICS_SAVE_COMMAND,true);
                }
                else{
                    pageControl.setDisplayFormat(displayFormat);
                    enableFunctionality(STR_METRICS_SAVE_COMMAND,true);
                }
            }


            if(fromPortalMode && (fromPortalMode == "true")){
                pageControl.setBooleanDisplayFormat("true");
            }
            else{
                pageControl.setBooleanDisplayFormat("true");
            }
            if(fromReportView=="reportView"){
                oldDisplayFormat = tempSecondPart;
            }

            if(fromPortalMode && (fromPortalMode == "true")){
                pageControl.setChangedDisplayFormat(oldDisplayFormat);
            }
            else{
                pageControl.setChangedDisplayFormat(oldDisplayFormat);
            }

            pageControl.setMode("SavedWithNewDisplayFormat");

            if(strResultsPageURL.indexOf("?chartType=")>0){
                finalURL = firstPart+"?chartType="+displayFormat+secondPart+"&fromDisplayFormat=true";
            }
            else{
                finalURL = firstPart+secondPart+"&chartType="+displayFormat+"&fromDisplayFormat=true";
            }
            if(finalURL.indexOf("&refreshMode=true")>0){
                var splitup = finalURL.split("&refreshMode=true");
                var splitupFirst = splitup[0];
                var splitupSecond = splitup[1]
                finalURL = splitupFirst+splitupSecond;
            }else if(finalURL.indexOf("?refreshMode=true")>0){
                var splitup = finalURL.split("?refreshMode=true");
                var splitupFirst = splitup[0];
                var splitupSecond = splitup[1];
                splitupSecond = splitupSecond.substring(splitupSecond.indexOf("&")+1,splitupSecond.length);
                finalURL = splitupFirst+"?"+splitupSecond;
            }
            strResultsPageURL = finalURL;
            thisForm.action = finalURL
            thisForm.method = "post"
            thisForm.target = "metricsReportResultsContent";
			addSecureToken(thisForm);
            thisForm.submit();
			removeSecureToken(thisForm);
        }
    }
}


//////////////////////////////////Object Count Report/////////////////////////////////////////


function getAdvancedSearch(bln, objDiv){
    var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
    var formName = contentFrame.document.forms[0].name;
    //get type
    var emxType = pageControl.getType();
    if(emxType == null || emxType == ""){
        alert(STR_METRICS_SELECT_TYPE);
        return false;
    }

    if(!pageControl.getShowingAdvanced() || bln){
        var url = "../businessmetrics/emxMetricsGetAdvanced.jsp?type=" + emxType+"&frmName="+formName;
        var myXMLHTTPRequest = emxUICore.createHttpRequest();
        myXMLHTTPRequest.open("GET", url, false);
        myXMLHTTPRequest.send(null);

        //write back to div
        objDiv.innerHTML = myXMLHTTPRequest.responseText;
    }
    return true;
}


function toggleMore(){
    var objDiv = document.getElementById("divMore");
    if(getAdvancedSearch(true,objDiv)){
        var imgMore = document.getElementById("imgMore");
        var theForm = document.forms[0];

        objDiv.style.display = (objDiv.style.display == "none" ? "" : "none");
        imgMore.src = (objDiv.style.display == "none" ? "../common/images/utilSearchPlus.gif" : "../common/images/utilSearchMinus.gif");
        pageControl.setShowingAdvanced(objDiv.style.display == "none" ? false : true);
        //if div is closed clear it
        if(!pageControl.getShowingAdvanced()){
            removeFormElements();
            objDiv.innerHTML = "";
        }
    }
}


function removeFormElements(){
    var theForm = document.forms[0];
    var formLen = theForm.elements.length;

    for(var i = formLen-1; i >=0 ; i--){
        var objParent = theForm.elements[i].parentNode;
        isDivMore(theForm.elements[i]);
        if(isInDivMore){
            objParent.removeChild(objParent.childNodes[0]);
            isInDivMore = false;
        }
    }
   return theForm;
}

var isInDivMore = false;
function isDivMore(o){
   if(o.parentNode != null){
      if(o.parentNode && o.parentNode.id == "divMore"){
          isInDivMore = true;
          return;
      }
      isDivMore(o.parentNode);
   }
}

function doLoad(){
   var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
   if (contentFrame.document.forms[0].elements.length > 0) {
       var objElement = contentFrame.document.forms[0].elements[0];

       if (objElement.focus) objElement.focus();
       if (objElement.select) objElement.select();
   }

   var type = pageControl.getType();
   type = (!type)? contentFrame.document.getElementById("txtTypeActual").value : type;
   contentFrame.document.getElementById("txtTypeDisplay").title=type;
   pageControl.setType(type);
   if(pageControl.getShowingAdvanced()){
       typeChanged = true;
       toggleMore();
   }
   		//Attach event handler for image tag, when clicked on it shows the contained in info.
		var imgTag = document.getElementById("imgTag");
		if(imgTag!=null && imgTag!="undefined")
		{
			imgTag.addEventListener("click",getContainedInInfo,false);
		}
}


function disableFromAndToDate(){
   var name = arguments[0];
   var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
   for (var i=0;i<contentFrame.document.forms[0].elements.length;i++) {
       var objElement = contentFrame.document.forms[0].elements[i];
       if((objElement.name).indexOf("comboDescriptor_")>=0){
           if((objElement.options[objElement.options.selectedIndex].value).indexOf("InBetween") >= 0){
                contentFrame.document.forms[0].elements[i+1].disabled=false;
                contentFrame.document.forms[0].elements[i+3].disabled=false;
           }else if((objElement.options[objElement.options.selectedIndex].value).indexOf("IsOn") >= 0 || (objElement.options[objElement.options.selectedIndex].value).indexOf("IsOnOrBefore") >= 0 || (objElement.options[objElement.options.selectedIndex].value).indexOf("IsOnOrAfter") >= 0){
                contentFrame.document.forms[0].elements[i+3].disabled=true;
           }
       }
       if(objElement.name == ("comboDescriptor_"+name)){
           if(objElement.options[objElement.options.selectedIndex].value == "*"){
               contentFrame.document.forms[0].elements[i+1].value="";
               if(contentFrame.document.forms[0].elements[i+3]){
                   contentFrame.document.forms[0].elements[i+3].value="";
               }
           }
       }
   }
}

function checkEmpty(){
   var name = arguments[0];
   var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
   for (var i=0;i<contentFrame.document.forms[0].elements.length;i++) {
       var objElement = contentFrame.document.forms[0].elements[i];
       if(objElement.name == ("comboDescriptor_"+name)){
            if(objElement.options[objElement.options.selectedIndex].value == "*"){
                var objElem = contentFrame.document.forms[0].elements[i+1];
                if( objElem.type == "text"){
                    contentFrame.document.forms[0].elements[i+1].value = "*";
                    if(contentFrame.document.forms[0].elements[i+2]){
                        if(contentFrame.document.forms[0].elements[i+2].name == name){
                            if( contentFrame.document.forms[0].elements[i+2].type == "select-one"){
                                if((contentFrame.document.forms[0].elements[i+2].name).indexOf("comboDescriptor_")<0){
                                    contentFrame.document.forms[0].elements[i+2].value = "";
                                }
                            }
                        }
                    }
                }
                if( objElem.type == "select-one"){
                    contentFrame.document.forms[0].elements[i+1].value = "";
                }
            }
        }
    }
}
//////////////////////////////////End of Object Count Report/////////////////////////////////////////

function openPrinterFriendlyPage()
{

    var owner;

    if(fromPortalMode && (fromPortalMode == "true") ){
        owner = reportOwner;
    }
    else{
        owner = pageControl.getOwner();
    }

    var timeStamp = "";
    var reportName= "";
    var contentFrame = findFrame(this,"metricsReportResultsContent");
    var chartType = contentFrame.document.getElementById("chartType");
    var wrapColSize = contentFrame.document.getElementById("wrapColSize");
    var suiteKey = contentFrame.document.getElementById("suiteKey");
    var strYAxisTitle = contentFrame.document.getElementById("strYAxisTitle");
    var chartTypeVal = chartType.value;
    var wrapColSizeVal = wrapColSize.value;
    var suiteKeyVal = suiteKey.value;
    var strYAxisTitleVal = strYAxisTitle.value;
    if(pageControl.getOpenedLast())
    {
        reportName = "";
    }
    else
    {
        reportName = pageControl.getSavedReportName();
    }

    timeStamp = pageControl.getTimeStamp();

    var strURL = "emxMetricsReportPrinterFriendly.jsp?reportName=" + reportName;
    strURL = strURL + "&timeStamp=" + timeStamp;
    strURL = strURL + "&chartType=" + chartTypeVal;
    strURL = strURL + "&defaultReport=" + pageControl.getCommandName();
    strURL = strURL + "&wrapColSize=" + wrapColSizeVal;
    strURL = strURL + "&suiteKey=" + suiteKeyVal;
    strURL = strURL + "&owner=" + owner;
    strURL = strURL + "&strYAxisTitle=" + strYAxisTitleVal;

    showPrinterFriendlyPage(strURL);
}

function showViewResultsWindow(reportName)
{
   try
   {
       showModalDialog("emxMetricsResults.jsp?mode=reportView&defaultReport="+pageControl.getCommandName()+"&resultsTitle=" + pageControl.getResultsTitle()+"&reportName="+reportName+"&showRefresh=true", 700, 600,false);
   }
   catch(e)
   {
   }
}

//checking the bad chars
function checkNameField(field){
    var newBadChar = "% &";
    var arrayBadChar = newBadChar.split(" ");
    field.value = trimWhitespace(field.value);
    badCharacters = checkForNameBadCharsList(field);
    if(badCharacters.length != 0) {
      alert(STR_INVALID_INPUT_MSG + badCharacters +" "+ newBadChar);
      return false;
    }
    else
    {
        var fieldValue = field.value;
        for (var i=0; i < arrayBadChar.length; i++) {
        if (fieldValue.indexOf(arrayBadChar[i]) > -1) {
            badCharacters += arrayBadChar[i] + " ";
        }
        }
      if(badCharacters.length != 0) {
        alert(STR_INVALID_INPUT_MSG + STR_NAME_BAD_CHARS +" "+ newBadChar);
        return false;
      }
    }
    return true;
}

function setPageControlValuesFromDialog(objWindowDialog,objWindowResults,fromPortalMode)
{
     // fromPortalMode will be set in emxMetricsResults.jsp
     if(!fromPortalMode){
         var contentFrame = parent.openerFindFrame(parent,"metricsReportContent");
         if(contentFrame.pageControl)
         {
             pageControl.setSharedAndOwned(contentFrame.pageControl.isSharedAndOwned());
             pageControl.setSharedAndNotOwned(contentFrame.pageControl.isSharedAndNotOwned());
             pageControl.setOwner(contentFrame.pageControl.getOwner());
             pageControl.setWrapColSize(contentFrame.pageControl.getWrapColSize());
             pageControl.setResultsTitle(contentFrame.pageControl.getResultsTitle());
             pageControl.setReportContentURL(contentFrame.pageControl.getReportContentURL());
             pageControl.setSavedReportName(contentFrame.pageControl.getSavedReportName());
             pageControl.setCommandName(contentFrame.pageControl.getCommandName());
             pageControl.setTimeStamp(contentFrame.pageControl.getTimeStamp());
         }
    }
    else
    {
         if(objWindowResults!=null && objWindowResults.pageControl)
         {
             var resultsContentFrame = objWindowResults.findFrame(objWindowResults,"metricsReportResultsContent");
             if(objWindowDialog!=null && objWindowDialog.pageControl)
             {
                 resultsContentFrame.parent.pageControl.setSharedAndOwned(objWindowDialog.pageControl.isSharedAndOwned());
                 resultsContentFrame.parent.pageControl.setSharedAndNotOwned(objWindowDialog.pageControl.isSharedAndNotOwned());
                 resultsContentFrame.parent.pageControl.setOwner(objWindowDialog.pageControl.getOwner());
                 resultsContentFrame.parent.pageControl.setWrapColSize(objWindowDialog.pageControl.getWrapColSize());
                 resultsContentFrame.parent.pageControl.setResultsTitle(objWindowDialog.pageControl.getResultsTitle());
                 resultsContentFrame.parent.pageControl.setReportContentURL(objWindowDialog.pageControl.getReportContentURL());
                 resultsContentFrame.parent.pageControl.setSavedReportName(objWindowDialog.pageControl.getSavedReportName());
                 resultsContentFrame.parent.pageControl.setCommandName(objWindowDialog.pageControl.getCommandName());
                 resultsContentFrame.parent.pageControl.setTimeStamp(objWindowDialog.pageControl.getTimeStamp());
                 objWindowDialog.closeWindow();
             }
         }
    }
}
//an alternative to registerChildWindows, trying...
function registerResultsToDefinition(objResultWindow, objChild, objParent)
{
    try
    {
        if(objParent.childWindows)
        {
            objParent.childWindows[objParent.childWindows.length] = objChild;
        }
        else
        {
            objParent.childWindows[0] = objChild;
            if(!objChild.childWindows)
            {
                objChild.childWindows[0] = objResultWindow;
            }
        }
    }
    catch(e)
    {
    }
}

function showCellInfo(cellHref,hasObjects,refresh)
{
    var tempCellHrefFirstPart;
    var tempCellHrefSecondPart;

    try
    {
        if(hasObjects=="TRUE" || refresh=="true"){
            var index = cellHref.indexOf("reportName=");
            if(index!=-1)
            {
               tempCellHrefFirstPart = cellHref.substring(0,index+11);
               tempCellHrefSecondPart = cellHref.substring(index+11,cellHref.length);
               tempCellHrefSecondPart = tempCellHrefSecondPart.substring(tempCellHrefSecondPart.indexOf("&"),tempCellHrefSecondPart.length);
               cellHref = tempCellHrefFirstPart + parent.pageControl.getSavedReportName() + tempCellHrefSecondPart;
            }
            showModalDialog(cellHref,930,650,false);
        }
        else if(hasObjects=="FALSE"){
            alert(STR_METRICS_OBJECT_DETAILS_SAVED);
        }
    }
    catch(e)
    {
    }
}
	function getContainedInInfo()
	{
		closeDiv();
		var containedObjId = document.forms[0].txtActualContainedIn.value;
		var containedInType = document.forms[0].txtContainedInType.value;
		var containedInRev = document.forms[0].txtContainedInRev.value;
		var containedInName = document.forms[0].txtContainedIn.value;
		var objEvent = emxUICore.getEvent();
		if(containedObjId!='')
		{
			var sURL = "../common/emxSearchGetContainedInObjectInfo.jsp?objectId="+containedObjId+"&type="+containedInType+"&name="+containedInName+"&revision="+containedInRev;
			var oXMLHTTP = emxUICore.createHttpRequest();
			oXMLHTTP.open("GET", sURL, false);
			oXMLHTTP.send(null);
			floatingDiv = document.createElement("div");


			floatingDiv.name="floatingdiv";
			floatingDiv.id="floatingdiv";
			floatingDiv.style.position="absolute";
			floatingDiv.style.zIndex=100;
            hiddenIFrame = document.getElementById("hiddenFrm");

			document.forms[0].appendChild(floatingDiv);


			window.focus();
			floatingDiv.style.display = "block";
			floatingDiv.focus();


			var floatDivInnerHTML = floatingDiv.innerHTML;
			floatDivInnerHTML +=oXMLHTTP.responseText ;
			floatingDiv.innerHTML=floatDivInnerHTML;
			var floatingDivWidth = "";
			if(isIE)
			{
				floatingDivWidth = floatingDiv.firstChild.offsetWidth;
			}
			else
			{
				floatingDivWidth = floatingDiv.offsetWidth;
			}
			floatingDiv.setAttribute("width", floatingDivWidth);
            if(isIE)
            {
                setDivPosition(objEvent,hiddenIFrame,floatingDivWidth);
                hiddenIFrame.style.zIndex=10;
                hiddenIFrame.style.width=floatingDivWidth;
                hiddenIFrame.style.height=floatingDiv.firstChild.offsetHeight;
                hiddenIFrame.style.filter='progid:DXImageTransform.Microsoft.Alpha(style=0,opacity=0)';
                hiddenIFrame.style.display="block";
            }
			if(!isIE)
			{
				var divFormLayerBorder = document.getElementById("formLayerBorder");
				var tblHeader = document.getElementById("tblHeader");
				if(parseInt(divFormLayerBorder.offsetWidth) < parseInt(tblHeader.offsetWidth))
				{
					divFormLayerBorder.style.width = tblHeader.offsetWidth+50+"px";
				}
				floatingDivWidth = tblHeader.offsetWidth +20;
		    }

			setDivPosition(objEvent, floatingDiv,floatingDivWidth);
		}
		else
		{
			alert(emxUIConstants.STR_SEARCH_CONTAINEDIN_EMPTY);
		}
	}
	function closeDiv()
	{
            if(floatingDiv!=null)
		    {
				floatingDiv.innerHTML ="";
				floatingDiv.style.display="none";
				floatingDiv = null;
                hiddenIFrame.style.display="none";
			}

	}
	function adjustBody(){
		var phd = document.getElementById("divPageHead");
		var dpb = document.getElementById("divPageBody");

		var ht = phd.offsetHeight;
		if(ht <= 0){
			ht = phd.clientHeight;
		}
		dpb.style.top = ht + "px";
	}

	function resizeContentIFrame(iFrameId, divId)
    {
        if(isIE){
        	$bmId(iFrameId,this).height = $bmId(divId,this).offsetHeight;
        }
    }

	function setDivPosition(objEvent, floatingDiv,floatingDivWidth,floatingDivHeight)
	{
		intX = objEvent.clientX
		intY = objEvent.clientY

		//add offset to each coordinate
		intX += 15 + document.body.scrollLeft;
		intY += 15 + document.body.scrollTop;

		//make sure that all of the tooltip is visible
		if ((intX + floatingDivWidth) > (document.body.clientWidth + document.body.scrollLeft)) {

			//move it so that the right edge of the div lines up with the right edge of the window
			intX = (document.body.clientWidth + document.body.scrollLeft) - floatingDivWidth - 5;
		}

		var intWindowHeight = document.body.clientHeight || window.innerHeight;

		//make sure that all of the tooltip is visible
		if ((intY + 100) > (intWindowHeight + document.body.scrollTop)) {

			//move it so that the bottom edge of the div lines up with bottom edge of the window
			intY = (document.body.clientHeight + document.body.scrollTop) - 100;

		}
		intY = intY-40;
		floatingDiv.style.top = intY;
		floatingDiv.style.left=  intX;

};
