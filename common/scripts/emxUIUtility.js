//=================================================================
// JavaScript emxUtility.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================

//-----------------------------------------------------------------
// Function refreshContentPage()
//-----------------------------------------------------------------
// DESCRIPTION
//  This function refreshes the content frame
//
//-----------------------------------------------------------------
function refreshContentPage()
{
  return  refreshSpecificPage("content");
}

//-----------------------------------------------------------------
// Function refreshTreeDetailsPage()
//-----------------------------------------------------------------
// DESCRIPTION
//  This function refreshes the "detailsDisplay" frame
//
//-----------------------------------------------------------------
function refreshTreeDetailsPage()
{
  return  refreshSpecificPage("detailsDisplay");
}

function refreshSpecificPage(frame)
{
    var treeDetailsFrame = findFrame (getTopWindow(), frame);

    if (treeDetailsFrame){
        if(treeDetailsFrame.editableTable){
        	treeDetailsFrame.editableTable.loadData();
        	treeDetailsFrame.RefreshTableHeaders();
        	treeDetailsFrame.rebuildView();
        }else{
        	treeDetailsFrame.location.href = treeDetailsFrame.location.href;
        }
      }else{
          return false;
      }
     return true;
}


//-----------------------------------------------------------------
// Function refreshTablePage()
//-----------------------------------------------------------------
// DESCRIPTION
//  This function refreshes the "table display page - content or tree details page" frame
//
//-----------------------------------------------------------------
function refreshTablePage()
{
    if( refreshTreeDetailsPage() == false)
    {
        if( refreshContentPage() == false)
            return false;
    }
    return true;
}
function refreshStructureTree(){
    var objTreeBarFrame = getTopWindow().findFrame(getTopWindow(), "emxUITreeBar");
    if(objTreeBarFrame != null && objTreeBarFrame.document != null){
    var strUrl = objTreeBarFrame.document.location.href;
	if(strUrl.indexOf("structureLoaded=")>-1){
	    	var structLoadParam = strUrl.substring(strUrl.indexOf("structureLoaded="),strUrl.length);
	    	structLoadParam = structLoadParam.substring(0,structLoadParam.indexOf("&")+1);
	    	strUrl = strUrl.replace(structLoadParam,"");
    	}
    objTreeBarFrame.document.location.href = strUrl;
    }
}

function checkURL(url){
	//If help documentation provided is customised to an URL then there is no need to verify the correctness
	//of URL through ajax call, because there might be cross domain access issue. Hence the below check is added.
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

var childWindow=null;

function openHelpPage(){
	var pageUrl;
	var detailsWindow = emxUICore.findFrame(getTopWindow(),"detailsDisplay");
	if(detailsWindow){
    	pageUrl = detailsWindow.location.href;
	}
	else{
		pageUrl = getPageURL();
	}
	var urlParams = pageUrl.substring(pageUrl.indexOf("?")+1);
	var pageTopic,directory, langStr, langOnlineStr, topLevel, suiteKey;

	var vars = urlParams.split("&");
	  for (var i=0;i<vars.length;i++) {
	    var pair = vars[i].split("=");
	    if(pair[0] == "HelpMarker" || pair[0] == "helpMarker"){
	    	pageTopic =  pair[1];
	    }else if(pair[0] == "SuiteDirectory"){
	    	directory =  pair[1];
	    }else if(pair[0] == "suiteKey"){
	    	suiteKey =  pair[1];
	    }
	  }

	if(!pageTopic && pageUrl.indexOf("emxHistory.jsp?") > -1){
		pageTopic = "emxhelphistory";
	}

	if(!directory){
		directory = "common";
	}

	langStr = emxUIConstants.BROWSER_LANGUAGE;
	langOnlineStr = emxUIConstants.STR_HELP_ONLINE_LANGUAGE;
	topLevel ="";

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
			  url = emxUIConstants.HELP_URL + "?P=11&V=2019x" + "&L=" +  langOnlineStr + "&F=" +htmlHelpfile + "&contextscope=" + contextscope;
			  defaultUrl = emxUIConstants.HELP_URL + "?P=11&V=2019x" + "&L=" +  langOnlineStr + "&F=" +"FrontmatterMap/DSDocHome.htm" + "&contextscope=" + contextscope; 
				  
		  }else{		  
		url = emxUIConstants.HELP_URL + "/" +  langOnlineStr + "/DSDoc.htm?show=" + htmlHelpfile;
			  defaultUrl = emxUIConstants.HELP_URL + "/DShomepage_"+langOnlineStr+".htm";
		  }
		  
		try {
		  fileUrl = emxUIConstants.HELP_URL + "/" +  langOnlineStr +"/"+ htmlHelpfile;
		  if(!checkURL(fileUrl) || htmlHelpfile == "true"){
			  url = defaultUrl;			  
			if(!checkURL(url)){
				errorMessageURL = altUrl+"?pageTopic="+pageTopic;
			}
		  }
		} catch( err) {
			//do nothing
		}
	  }
	if(errorMessageURL){
		var errorMessage = emxUICore.getData(errorMessageURL);
		alert(errorMessage);
		return;
	  }
	if ((childWindow == null) || (childWindow.closed)){
		if(!topLevel){
			altUrl = "../" + altUrl;
		}
		if(!checkURL(url)){
			url = altUrl;
		}
		childWindow = window.open(url,"helpwin","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
		childWindow.focus();
	} else {
		if(!topLevel){
			altUrl = "../" + altUrl;
		}
		if(!checkURL(url)){
			url = altUrl;
		}
		childWindow.location.replace(url);
		childWindow.focus();
	}
   return;
}

function emailPageURL(){
	var daReferrer = document.referrer;
	var email = "";
	var subject = "Notification";
	var body_message = getPageURL();
	if(body_message.indexOf("?") > 0){
	body_message += "&fromExt=true";
	} else {
		body_message += "?fromExt=true";
	}
	if (getTopWindow().document.location.href.indexOf("emxNavigatorDialog.jsp")== -1) {
	if(curTenant && curTenant != ""){
		body_message += "&tenant=" + curTenant;
	}
	}

	var treeLabel = getParamValuesByName(body_message, "treeLabel");
	if(treeLabel && treeLabel != ""){
		treeLabel = encodeURIComponent(treeLabel);
		body_message = updateURLParameter(body_message, "treeLabel", treeLabel);
	}
	var defaultCategory = "";
	if(getTopWindow().bclist){
		var currBC = getTopWindow().bclist.getCurrentBC();
		defaultCategory = (currBC.categoryDynamicName != undefined || "") ? currBC.categoryDynamicName : "";
		(typeof defaultCategory !== 'undefined' && body_message.indexOf("DefaultCategory") > 0)?(body_message=resetParameter(body_message,"DefaultCategory", defaultCategory)):(body_message+=("&DefaultCategory="+ defaultCategory));
	}
	body_message=body_message.replace(/&/g, "%26");
	var mailto_link = 'mailto:'+email+'?subject='+subject+'&body='+body_message;
	if(isIE){
		if(getTopWindow().hiddenFrame){
			getTopWindow().hiddenFrame.location.href = mailto_link;
		}else{
		 window.location.href=mailto_link;
		}
	 }else{
	win = window.open(mailto_link,'emailWindow');
	if (win && win.open &&!win.closed){ 
		if(isChrome){
			setTimeout(function(){win.close(),500});
			}
		else{
			win.close();
		}
	}
	}
}

function copyURL(){

	var daReferrer = document.referrer;
	var email = "";
	var subject = "Notification";
	var body_message = getPageURL();
	if(body_message.indexOf("?") > 0){
	body_message += "&fromExt=true";
	} else {
		body_message += "?fromExt=true";
	}
	if(curTenant && curTenant != ""){
		body_message += "&tenant=" + curTenant;
	}
 if(!document.getElementById('pageURLDiv')){
    var divDisplay = document.createElement('div');
    var divHeader = document.createElement('div');
    var divContent = document.createElement('div');
	divDisplay.appendChild(divHeader);
    divDisplay.appendChild(divContent)
	if (document.body.firstChild) {
      document.body.insertBefore(divDisplay, document.body.firstChild);
    }
    else {
      document.body.appendChild(divDisplay);
    }
	// affect id to component elements
    divHeader.id = "PageUrlUserHelpBlock";
    divContent.id = "PageLinkBlockInput";
    divDisplay.id = "PageLinkBlock";
	divHeader.innerHTML = emxUIConstants.STR_COPY_PASTE;
	divContent.innerHTML = "<input type=\"text\" size=\"50\" id=\"PageLink\" onblur=\"setTimeout('hideUrl()',100)\" readonly=\"true\"/>";
	linkInput = document.getElementById('PageLink');
}	
 
  linkInput.value = body_message;
  linkInput.focus();
  linkInput.select();
}
 
 hideUrl = function() {
  var linkBlock = document.getElementById('PageLinkBlock');
  if (linkBlock) {
    linkBlock.parentNode.removeChild(linkBlock);
  }
}
function getPageURL(){
    var contextWindow = emxUICore.findFrame(getTopWindow(),"content");//window.parent.parent;
    var contentFrameURL = "";
    if(contextWindow){
    	// this fix is done for chrome as contextWindow.location.href returns the emxNavigator.jsp
    	contentFrameURL = contextWindow.cntFrameURL ? contextWindow.cntFrameURL : "";
    	contextWindow = contextWindow.document;
    } else {
    	contextWindow = document;
    }
    return (contentFrameURL != "") ? contentFrameURL : contextWindow.location.href;
}


function rerunsearch(value1, searchPageURL){
		var wsf = findFrame(getTopWindow(), 'windowShadeFrame');
		wsf.FullSearch.rerunsearch(value1, searchPageURL);
}

/**
 * reset a parameter in url
 * @param parm The querystring parameter
 * @param val The parameter value
 */
function resetParameter(url, parm, val){
     if(url.indexOf("amp;") >= 0){
            while(url.indexOf("amp;") >= 0){
                url = url.replace("amp;", "");
            }
        }

    var arrURLparms = url.split("&");
    var len = arrURLparms.length;
    var count = 0;
    for(var i = 0; i < len; i++){
        arrURLparms[i] = arrURLparms[i].split("=");
        //only change the first matching parm
        if(arrURLparms[i][0] == parm && count == 0){
            count++;
            //set new value
            arrURLparms[i][1] = val;
        }
        arrURLparms[i] = arrURLparms[i].join("=");
    }
    url = arrURLparms.join("&");
    //if the count is still zero add param to end
    if(count == 0){
        url += ("&" + parm + "=" + val);
    }
    return url;
}
