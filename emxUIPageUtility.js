//   emxUIPageUtility.js
//
//   Placeholder for common page tasks.
//
//   Copyright (c) 1992-2018 Dassault Systemes.
//   All Rights Reserved.
//   This program contains proprietary and trade secret information of MatrixOne,
//   Inc.  Copyright notice is precautionary only
//   and does not evidence any actual or intended publication of such program
//
//   static const char RCSID[] = $Id: emxUIPageUtility.js.rca 1.68 Tue Oct 28 18:59:10 2008 przemek Experimental przemek $
//   ================================================================


// Try to consolidate all the browser checks. Use emxUICore for browser detection
var Browser = (function () {
	/*
	 * User Agent String for all the supported browser 
	 * 
	 * 
	 * */
	var browsers = {
				"IE" : false,
				"FIREFOX" : false,
				"CHROME" : false,
				"MOZILLA_FAMILY": false,
				"SAFARI" : false,
				"MOBILE" : false
 			};
	
	
	detectBrowser = function(ua){
		var ie = /(msie|trident)/i.test(ua)
      , chrome = /chrome|crios/i.test(ua)
      , safari = /safari/i.test(ua) && !chrome
      , firefox = /firefox/i.test(ua)
      , mobile = /(Mobile)/i.test(ua) || /(Touch|Tablet PC*)/.test(ua);
		if(ie){
			browsers.IE=true;
		}else if (chrome){
			browsers.CHROME=true;
		}else if(safari){
			browsers.SAFARI=true;
		}else if(firefox){
			browsers.FIREFOX=true;
		}
		if(mobile){
			browsers.MOBILE = true;
		}
		if(chrome || safari || firefox){
			browsers.MOZILLA_FAMILY=true;
		}
	};
	detectBrowser(navigator.userAgent);
	return browsers;
}());

var winDialog = null;
//cheap browser detect
var isIE = Browser.IE;
var isMoz_P = Browser.MOZILLA_FAMILY;

var pgfooterurl = ''; 
var pgheaderurl = '';
function loadfooterFrame(footerurl, headerurl) {
  pgfooterurl = footerurl;
  pgheaderurl = headerurl;
  var newdiv = document.createElement("form");
  newdiv.id = "bottomCommonForm";
  newdiv.name = "bottomCommonForm";
  newdiv.method = "post";
  newdiv.innerHTML = emxUICore.getData(footerurl);
  var dpf = document.getElementById("divPageFoot");
  dpf.innerHTML = "";
  dpf.appendChild(newdiv);

  pages = emxUICore.getData(headerurl + "&req=pages");
  if(pages && !isIE){
  pages = pages.trim();
  }
  turnOffProgress();
}
function loadFrames(headerurl, footerurl, contenturl){
  var dph = document.getElementById("ph");
  var ht = emxUICore.getData(headerurl + "&req=header");
  dph.innerHTML = ht;
  
  dph = document.getElementById("sph");
  if(dph){
  dph.innerHTML = emxUICore.getData(headerurl + "&req=subheader");
  }

  var filterselect = document.getElementById("filter_passed_param");
  if(filterselect) {
    eval(emxUICore.getData(headerurl + "&req=filt"));
  }
  
  dph = document.getElementById("imgProgressDiv");
  dph.innerHTML = emxUICore.getData(headerurl + "&req=pt");
  var phd = document.getElementById("pageHeadDiv");
  var dpb = document.getElementById("divPageBody");
  var height = phd.clientHeight;
  if(height <= 0){
	  height = phd.offsetHeight;
  }
  dpb.style.top = height + "px";
  loadfooterFrame(footerurl, headerurl);
}

function loadGenericSearchHeader(headerpage, footerpage){
  var dph = document.getElementById("ph");
  var ht = emxUICore.getData(headerpage + "&req=header");
  dph.innerHTML = ht;
  

  var dpf = document.getElementById("divPageFoot");
  dpf.innerHTML = emxUICore.getData(footerpage);
  turnOffProgress();
}
//this function opens a new window
function openExternalWindowSmall(url) {
  var strFeatures = "width=300,height=400,resizable=yes";
  openExternalWindow(url,strFeatures);
  return;
}

//this function opens a new window
function openExternalWindowMedium(url) {
  var strFeatures = "width=400,height=550,resizable=yes";
  openExternalWindow(url,strFeatures);
  return;
}

//this function opens a new window
function openExternalWindowLarge(url) {
  var strFeatures = "width=600,height=650,resizable=yes";
  openExternalWindow(url,strFeatures);
  return;
}


//this function opens a new window
function openExternalWindow(url,strFeatures) {
  var win = window.open(url, "NewWindow", strFeatures);
  return;
}

function emxShowModalDialog(strURL, iWidth, iHeight, bScrollbars) {
  showModalDialog(strURL, iWidth, iHeight);
  //showNonModalDialog(strURL, iWidth, iHeight);
}

//
//method refreshed underlying page
//params:
//refreshType: inner or parent
//url (optional): href to target inner or parent frame
//
function refreshOpener(refreshType,url){

  parentFrameObj = window.getWindowOpener().parent;
  var randomnumber=Math.floor(Math.random()*123456789101112);

  if (refreshType == "inner"){
    if ((url != null) && (url.length > 5) && (url != 'undefined')){
      if (url.indexOf('?') > -1){
        url += "&rnd=" + randomnumber;
      }else{
        url += "?rnd=" + randomnumber;
      }
      parentFrameObj.frames[1].location = url;
    }else{
      var tempHref = parentFrameObj.frames[1].location.href;
      if (tempHref.indexOf('?') > -1){
        tempHref += "&rnd=" + randomnumber;
      }else{
        tempHref += "?rnd=" + randomnumber;
      }
      parentFrameObj.frames[1].location = tempHref;
    }
  }else{
    if ((url != null) && (url.length > 5)){
      if (url.indexOf('?') > -1){
        url += "&rnd=" + randomnumber;
      }else{
        url += "?rnd=" + randomnumber;
      }
      parentFrameObj.location = url;
    }else{
      var tempHref = parentFrameObj.location.href;
      if (tempHref.indexOf('?') > -1){
        tempHref += "&rnd=" + randomnumber;
      }else{
        tempHref += "?rnd=" + randomnumber;
      }
      parentFrameObj.location = tempHref;
    }
  }
}


//-----------------------------------------------------------------
// Method doDone(strSelectItem)
// This function assigns the seleted name and id of the object to the caller window.
//
// Parameters:
//  strSelectItem, InterNationalized string for Warnig message if nothing is selected.
// Returns:
//  nothing.
//-----------------------------------------------------------------

function doDone(strSelectItem){
  var winObj = parent.window.getWindowOpener();
  var selnode = localSelectableTree.nodes[localSelectableTree.selectedID];
  if(selnode == null)
  {
     if((strSelectItem == null) || (strSelectItem == ""))
     {
        if(parent.tree.alertMessage)
        {
          strSelectItem = parent.tree.alertMessage;
        }
        else
        {
          strSelectItem = emxUIConstants.SELECT_ONE_ITEM;
        }
     }
     
     alert(strSelectItem);    
     return;
  }

  var selName = selnode.name;
  var newSelName = "";

  for (var n = 1 ; n <= selName.length ; n++)
  {
    if (selName.substring(n-1,n) == "'")
    {
      newSelName+="\\'";
    }
    else
    {
      newSelName+=selName.substring(n-1,n);
    }
  }

  eval("winObj.document.forms[0]." + fieldName + ".value='" + newSelName + "'");
  eval("winObj.document.forms[0]." + fieldId + ".value='" + selnode.id + "'");

  if(fieldName.indexOf('Display') > -1) {
    var fieldAct = fieldName.substring(0,fieldName.length-7);
    eval("winObj.document.forms[0]." + fieldAct + ".value='" + newSelName + "'");
  }
  parent.window.closeWindow();
}


function doDoneWizard(){
  var selnode = localSelectableTree.nodes[localSelectableTree.selectedID];
  parent.window.document.location.href="changeTemplate.jsp" + selnode.id;
}


//////////////////Begin: ADAPTED FROM /common/script/emxNavigatorHelp.js
//Any modifications to this method needs to be replicated in emxNavigatorHelp.js also.
//------------------------------------------------------------------------------------
// Method openHelp()
// This function opens a window and requests context sensitive help.
//
// Parameters:
//   pageTopic - The Helpmarker to index into page with
//   directory - Directory Pages are under
//   langStr - The language To Use
// Returns:
//  nothing.
//-----------------------------------------------------------------

//open Help in separate Window
var childWindow=null;

function openHelp(pageTopic, directory, langStr, langOnlineStr, topLevel, suiteKey) {
    directory = directory.toLowerCase();
    var url;
    var altUrl;
    var errorUrl;
    var strFinalURL = "../common/emxXMLHelpLookup.jsp?suiteDir="+directory+"&language="+langStr+"&pageTopic="+pageTopic+"&suiteKey="+suiteKey;
    var isHtmlHelpfile = emxUICore.getData(strFinalURL);
    var htmlHelpfile = emxUICore.trim(isHtmlHelpfile);
    var url = null;
    var errorMessageURL = null;
    altUrl = "../common/emxXMLError.jsp";
    if(htmlHelpfile=="false"){
        url = "../doc/" +  directory + "/" + langStr + "/wwhelp/wwhimpl/js/html/wwhelp.htm?context=" + directory + "&topic=" + pageTopic;
        if(!checkURL(url)){
          url = "../doc/" +  directory + "/" + langStr + "/ENOHelp.htm?context=" + directory + "&topic=" + pageTopic;
          if(!checkURL(url)){
              errorMessageURL = altUrl;
            }
        }
      } else{
    	  var defaultUrl;
		  if(emxUIConstants.HELP_URL.indexOf('http') == 0 && emxUIConstants.HELP_URL.indexOf("HelpDS.aspx") > -1){
			  // We have to find a solution for not hardcoding V here
			  var contextscope ="";			  
			  if(emxUIConstants.STR_IS_CLOUD == "true"){
				  contextscope = "cloud";
			  }else{
				  contextscope = "onpremise";
			  }
			  url = emxUIConstants.HELP_URL + "?P=11&V=2019x" + "&L=" + langOnlineStr + "&F=" +htmlHelpfile +  "&contextscope=" + contextscope;
			  defaultUrl = emxUIConstants.HELP_URL + "?P=11&V=2019x" + "&L=" +  langOnlineStr + "&F=" +"FrontmatterMap/DSDocHome.htm" + "&contextscope=" + contextscope;
		  }else{
        url = emxUIConstants.HELP_URL + "/" +  langOnlineStr + "/DSDoc.htm?show=" + htmlHelpfile;
			  defaultUrl = emxUIConstants.HELP_URL + "/DShomepage_"+langOnlineStr+".htm";
		  }
        try {
          if(!checkURL(url) || htmlHelpfile == "true"){
        	url = emxUIConstants.HELP_URL + "/DShomepage_"+langOnlineStr+".htm";
        	if(!checkURL(url)){
    	        errorMessageURL = altUrl+"?pageTopic="+pageTopic;
    	    }
          }
        } catch (err) {
        	// do nothing
        }
      }
    if(errorMessageURL){
        var errorMessage = emxUICore.getData(errorMessageURL);
        alert(errorMessage);
        return;
      }
   
  
    if ((childWindow == null) || (childWindow.closed)){
        //adjust URLs for top level
        if(!topLevel){
            //url = "../" + url;
            altUrl = "../" + altUrl;
        }
        
        //Page exists in the system with given URL?
        if(!checkURL(url)){
            url = altUrl;
        }
        
        //open help
        childWindow = window.open(url,"helpwin","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
        childWindow.focus();
    } else {
    
      //Bug 359757
        if(!topLevel){
            url = "../" + url;
            altUrl = "../" + altUrl;
        }
        
        //Page exists in the system with given URL?
        if(!checkURL(url)){
            url = altUrl;
        }

        //open help in the existing help window which is already open
        childWindow.location.replace(url);
        childWindow.focus();
    }

   return;
}


function checkURL(url){
	if(url.indexOf('http') == 0){
		return true;
	}
    var xmlhttp = createHttpRequest();
    xmlhttp.open("HEAD", url, false);
    xmlhttp.send(null);
    return xmlhttp.status==200;
}

function createHttpRequest() {
        if (isIE) {
                return new ActiveXObject("Microsoft.XMLHTTP");
        } else {
                return new XMLHttpRequest;
        }
}
//////////////////End: ADAPTED FROM /common/script/emxNavigatorHelp.js

//function take a string and replaces all spaces with %20 and return the string
    function fnEncode(str){
    var dest="";
    var len=str.length;
    var index=0;
    var code=null;
    for(var i=0;i<len; i++){
    var ch=str.charAt(i);
    if(ch==" "){
      code="%20";
      }
    if(code!=null){
    dest+=str.substring(index,i)+code;
    index=i+1;
    code=null;
      }
     }
    if(index<len){
    dest+=str.substring(index,len);
    return dest;
     }
    }

      function doCheck()
      {
      var objForm="";
      var test=parent.pagecontent;
      if(test != null){
         objForm = parent.pagecontent.document.markupForm;
        }else{
            objForm = parent.frames[1].pagecontent.document.markupForm;
        }
      var chkList = objForm.chkList;
      var chkboxObj;
      var selectedRows = "";
      if(objForm && objForm.objCount)
      {
        //go over every row and keep track a list of selected rows
        for(var i=0; i < objForm.objCount.value; i++){
            chkboxObj = document.getElementById("chkbox" + i);
            chkboxObj.checked = chkList.checked;
            
            if(selectedRows.length < 1){
                selectedRows = i;
            } else {
                selectedRows += "," + i;
            }            
        }
        
        //clear if no row is selected
        if(!chkList.checked){
            if(objForm.selectedRows){
                objForm.selectedRows.value = "";
            }
        } else {
            objForm.selectedRows.value = selectedRows;
        }
        
      } else if(objForm) { //original AEF code - should not into this code
        for (var i=0; i < objForm.elements.length; i++){
            if (objForm.elements[i].name.indexOf('partName') > -1){
          objForm.elements[i].checked = chkList.checked;
            }
         }      
      }      
    }


    function updateCheck()
    {
      var objForm = document.forms[0];
      var chkList = objForm.chkList;
      chkList.checked = false;
    }


  //
  // Use this method to determine if client is using Netscape with JP O/S
  // IF so pop up page alternatively with isJapOS code block
  //
  function showCheckinDialog(url,directory,FCSFileSite){
    // convert all characters to lowercase to simplify testing
    var agt=navigator.userAgent.toLowerCase();

    // *** BROWSER VERSION ***
    // Note: On IE5, these return 4, so use is_ie5up to detect IE5.
    var is_major = parseInt(navigator.appVersion);
    var is_minor = parseFloat(navigator.appVersion);

    var is_nav  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
                && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
                && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1));

    var isJapOS = (agt.indexOf('ja')!=-1);

    var returnTo = escape(parent.location.href);

    if (url.indexOf('?') > -1)
      url += "&returnTo=" + returnTo;
    else
      url += "?returnTo=" + returnTo;

    if( is_nav) 
    {
      if (!isJapOS ){

        //make cancelPageURL last param
        if (url.indexOf('?') > -1)
          url += "&charset=iso-8859-1&cancelPageURL=" + escape(returnTo);
        else
          url += "?charset=iso-8859-1&cancelPageURL=" + escape(returnTo);

        //Netscape Non Japanese OS
        emxShowModalDialog(url,670,570,true);
      } else {

        // Netscape Japanese OS
        if (url.indexOf('?') > -1)
          url += "&charset=MS932";
        else
          url += "?charset=MS932";

        //make cancelPageURL last param
        url += "&cancelPageURL=" + escape(returnTo);

        parent.frames[3].launchCheckin(url,directory);
      }
    } else {
      //make cancelPageURL last param
      if (url.indexOf('?') > -1)
        url += "&cancelPageURL=" + escape(returnTo);
      else
       url += "?cancelPageURL=" + escape(returnTo);

      //IE, or Netscape with English OS
      emxShowModalDialog(url,670,570,true);
    }
  }

  //
  // Use this method to determine if client is using Netscape with JP O/S
  // IF so pop up page alternatively with isJapOS code block
  //
  function showMultipleFileCheckinDialog(url,directory,FCSFileSite){
    // convert all characters to lowercase to simplify testing
    var agt=navigator.userAgent.toLowerCase();

    // *** BROWSER VERSION ***
    // Note: On IE5, these return 4, so use is_ie5up to detect IE5.
    var is_major = parseInt(navigator.appVersion);
    var is_minor = parseFloat(navigator.appVersion);

    var is_nav  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
                && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
                && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1));

    var isJapOS = (agt.indexOf('ja')!=-1);

    var returnTo = escape(parent.location.href);

    if (url.indexOf('?') > -1)
      url += "&returnTo=" + returnTo;
    else
      url += "?returnTo=" + returnTo;

    if( is_nav) 
    {
      if (!isJapOS ){

        //make cancelPageURL last param
        if (url.indexOf('?') > -1)
          url += "&charset=iso-8859-1&cancelPageURL=" + escape(returnTo);
        else
          url += "?charset=iso-8859-1&cancelPageURL=" + escape(returnTo);

        //Netscape Non Japanese OS
        emxShowModalDialog(url,670,570,true);
      } else {

        // Netscape Japanese OS
        if (url.indexOf('?') > -1)
          url += "&charset=MS932";
        else
          url += "?charset=MS932";

        //make cancelPageURL last param
        url += "&cancelPageURL=" + escape(returnTo);

        parent.frames[3].launchCheckin(url,directory);
      }
    } else {
      //make cancelPageURL last param
      if (url.indexOf('?') > -1)
        url += "&cancelPageURL=" + escape(returnTo);
      else
       url += "?cancelPageURL=" + escape(returnTo);

      //IE, or Netscape with English OS
      emxShowModalDialog(url,670,570,true);
    }
  }


   function startProgressBar(isDialog){
     turnOnProgress(isDialog);
   }

   function startSearchProgressBar(){
      if (parent.document.progress){
          parent.document.progress.src = "common/images/utilProgressBlue.gif";
      }
   }

  //
  // Use this method to determine if client is using Netscape with JP O/S
  // IF so pop up page alternatively with isJapOS code block
  //
  function emxShowCheckoutDialog(url,width,height){
    // convert all characters to lowercase to simplify testing
    var agt=navigator.userAgent.toLowerCase();

    // *** BROWSER VERSION ***
    // Note: On IE5, these return 4, so use is_ie5up to detect IE5.
    var is_major = parseInt(navigator.appVersion);
    var is_minor = parseFloat(navigator.appVersion);

    var is_nav  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
                && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
                && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1));

    var isJapOS = (is_nav && agt.indexOf('ja')!=-1);

    var returnTo = escape(parent.location.href);


    if (url.indexOf('?') > -1)
      url += "&returnTo=" + returnTo;
    else
      url += "?returnTo=" + returnTo;


    if (!isJapOS){
      //make cancelPageURL last param
      if (url.indexOf('?') > -1)
        url += "&cancelPageURL=" + escape(returnTo);
      else
        url += "?cancelPageURL=" + escape(returnTo);

      emxShowModalDialog(url,570,320);

    } else{
      if (url.indexOf('?') > -1)
        url += "&charset=MS932";
      else
        url += "?charset=MS932";

      //make cancelPageURL last param
      if (url.indexOf('?') > -1)
        url += "&cancelPageURL=" + escape(returnTo);
      else
        url += "?cancelPageURL=" + escape(returnTo);

      parent.frames[3].launchCheckout(url,570,320);
    }

  }

  var bottomLoaded = false;

  function loadBottomFrameIE(url){
    if (!bottomLoaded){
      bottomLoaded = true;
      frames[2].location.href= url;
    }
  }

  function loadBottomFrameNN(url){
    if (!bottomLoaded){
      bottomLoaded = true;
      frames[2].location.href= url;
    }
  }


  //
  // variable used to detect if a form have been submitted
  //
  var clicked = false;

  //
  // function jsDblClick() - sets var clicked to true.
  // Used to prevent double click from resubmitting a
  // form in IE
  //
  function jsDblClick() {
    if (!clicked) {
      clicked = true;
      return true;
    }
    else {
      return false;
    }
  }

  //
  // function jsIsClicked() - returns value of the clicked variable.
  //
  function jsIsClicked() {
    return clicked;
  }

  //
  // function jsClickOnPage() - returns true if clicked is not set.
  // Used by the document.onclick js method to prevent mouse clicks
  // after a form have been submitted to abort the requested page
  // for IE. This function have to be used when the form action is
  // another page than the current running.
  //
  function jsClickOnPage(e){
    if(jsIsClicked()) {
      return false;
    } else {
      return true;
    }
  }


   function selectAll(){
  var objForm = document.ActionSelect;
  var chkList = objForm.chkList;

  for (var i=0; i < objForm.elements.length; i++){

    if (objForm.elements[i].name.indexOf('checkBox') > -1){
      objForm.elements[i].checked = chkList.checked;
      }
    }
  }


  function SendSelectedActions(msg){
  var objForm = document.ActionSelect;
  var chkList = objForm.chkList;
  var atleastOneSelect=false;
  var selectedActions="";
  var cntNotSelected=0;
  for (var i=1; i < objForm.elements.length; i++){
    if (objForm.elements[i].checked){
      selectedActions+=objForm.elements[i].value+",";
      atleastOneSelect=true;
    }else{
      cntNotSelected++;
    }
   }
      var strLast=selectedActions.charAt(selectedActions.length-1);
      if(strLast==",")
        selectedActions=selectedActions.substring(0,selectedActions.length-1);

    if(!atleastOneSelect){
        alert(msg);
        return;
    }else{

        if(cntNotSelected==0)
          parent.getWindowOpener().parent.frames[0].document.objectHistoryHeader.actionFilter.value="*";
        else
          parent.getWindowOpener().parent.frames[0].document.objectHistoryHeader.actionFilter.value=selectedActions;

        parent.window.closeWindow();
    }
  }


  function launchSpreadsheetPage(iWidth,iHeight){
      if (parent){
        //use the altpage  var if defined in center page else use the center location
        var sspage = parent.frames[1].location.href;
        var altpage = parent.frames[1].altSpreadsheetPage;
        if (altpage != "" && altpage != "undefined" && altpage)
          sspage = altpage;


        if (sspage.indexOf('?') > -1){
          sspage += "&outputAsSpreadsheet=true";
        }else{
          sspage += "?outputAsSpreadsheet=true";
        }

        //showDetailsPopup(sspage);    //causes js error in netscape

        var strFeatures = "width=" + iWidth + ",height=" + iHeight + ",menubar=yes,scrollbars=yes,toolbar=yes,location=yes";

        var winleft = parseInt((screen.width - iWidth) / 2);
        var wintop = parseInt((screen.height - iHeight) / 2);

        // resizable 'fix' for Netscape
        if (isIE)
          strFeatures += ",left=" + winleft + ",top=" + wintop + ",resizable=yes";
        else
          strFeatures += ",screenX=" + winleft + ",screenY=" + wintop + ",resizable=no";

if (sspage.indexOf('emxObject') > -1)
         {
            parent.pagehidden.location.href=sspage;  
         }
        else
        {
           var winNonModalDialog = window.open(sspage, "NonModalWindow" + (new Date()).getTime(), strFeatures);
           //set focus to the dialog
           winNonModalDialog.focus();
        }

      }


  }

  function exportData() {
      launchSpreadsheetPage();  
  }
  
  function shiftFocus(strForm, objInput) {

    var objForm = document.forms[strForm];

    for (var i=0; i < objForm.elements.length; i++) {
      if (objInput == objForm.elements[i]) {
        if (objForm.elements[i+1]) {
          objForm.elements[i+1].focus();
          return;
        } //End: if (objForm.elements[i+1])
      } //End: if (objInput == objForm.elements[i])
    } //End: for (var i=0; i < objForm.elements.length; i++)

} //End: function shiftFocus(strForm, objInput)



//this function updates the Tree links to target content if theye are _parent
function updateLinks() {
        for (var i=0; i < document.links.length; i++) {
                if (document.links[i].href.indexOf("emxTree.jsp") > -1 && (document.links[i].target == "_parent" || document.links[i].target == "")) {
                        document.links[i].target = "content";
                }
        }
}


//! Public Function turnOffProgress()
//!     This function changes the progress clock so that it disappears.
function turnOffProgress() {

  if((document.getElementById('imgProgressDiv')) != null)
  {
        document.getElementById('imgProgressDiv').style.visibility = 'hidden';
  }
  else if (parent.frames[0] != null && (parent.frames[0].document.getElementById('imgProgressDiv')) != null)
      {
           parent.frames[0].document.getElementById('imgProgressDiv').style.visibility = 'hidden';
      }else if(parent.document.getElementById('imgProgressDiv')){
  	    parent.document.getElementById('imgProgressDiv').style.visibility = 'hidden';
      }else
      {
            setTimeout("turnOffProgress()", 500);
      }  
}  

//! Public Function turnOnProgress()
//!     This function changes the progress clock so that it reappears.
function turnOnProgress(isDialog) {

      if ((parent.frames[0].document.getElementById('imgProgressDiv')) != null)
      {
           parent.frames[0].document.getElementById('imgProgressDiv').style.visibility = 'visible';
      }
      else if((document.getElementById('imgProgressDiv')) != null)
      {
            document.getElementById('imgProgressDiv').style.visibility = 'visible';
      } else if(isDialog && parent.document.getElementById('imgProgressDiv')){
	      parent.document.getElementById('imgProgressDiv').style.visibility = 'visible';
      }
      else 
      {                                  
        setTimeout("turnOnProgress()", 500);
      }  

}

function cleanupFSSession (qsKey, beanName)
{
	emxUICore.getData('../emxFSTableCleanupSession.jsp?QSKey=' + qsKey + '&beanname=' + beanName);
}
function addSecureTokenInForm(e){
	if(emxUIConstants.isCSRFEnabled){
		for(var i=0 ; i < e.target.contentDocument.forms.length ; i++){
			addSecureToken(e.target.contentDocument.forms[i]);
		}
	}
}
