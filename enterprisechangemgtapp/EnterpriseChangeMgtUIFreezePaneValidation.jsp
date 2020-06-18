<%--  EnterpriseChangeMgtUIFreezePaneValidation.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../components/emx3DLiveCrossHighlightJavaScript.inc" %>

<emxUtil:localize id="i18nId" bundle="emxEnterpriseChangeMgtStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />


function createNewRowBelow(){
        FreezePaneregister('|||0,0');
        createNewChildRowBelow();
        FreezePaneunregister('|||0,0');
        emxEditableTable.refreshRowByRowId('0,0');
}

var sbAffectedItemFrame = null;
var channelAffectedItem3dLiveFrame = null;
var nSelRow = null;

function highlight3DCAAffectedItem(strID, flag) {
        var aId = strID.split("|");
    var id = aId[3];
    
    if(channelAffectedItem3dLiveFrame == null)
                channelAffectedItem3dLiveFrame  = findFrame(getTopWindow(),"ECM3DliveLaunchCA");
        
        if(sbAffectedItemFrame == null) {
                sbAffectedItemFrame = findFrame(getTopWindow(), "ECM3DAffectedItemsCA");
        }
        
        if(typeof channelAffectedItem3dLiveFrame != 'undefined' && channelAffectedItem3dLiveFrame != null) {    
                var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
                var selPartId = rowNode.getAttribute("o");
                var objId=sbAffectedItemFrame.objectId;
                        
		var idPath = emxUICore.getData("../enterprisechangemgtapp/ECMGetAffectedItemPath.jsp?contextECOId="+objId+"&selPartId="+selPartId);
                idPath = idPath.substring(0, idPath.indexOf("@"));
                if("NOTEXIST" == idPath && flag == true) {
                        //do nothing
                        //alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.3DLiveExamine.3DRepDoesntExist</emxUtil:i18nScript>");
                } else {
                        toggleSelect(channelAffectedItem3dLiveFrame, flag, idPath);
                }
        }
}
function highlight3DCandidateItem(strID, flag) {
        var aId = strID.split("|");
    var id = aId[3];
    
    if(channelAffectedItem3dLiveFrame == null)
                channelAffectedItem3dLiveFrame  = findFrame(getTopWindow(),"ECM3DliveLaunchCOCR");
        
        if(sbAffectedItemFrame == null) {
                sbAffectedItemFrame = findFrame(getTopWindow(), "ECMCandidateItems");
        }
        
        if(typeof channelAffectedItem3dLiveFrame != 'undefined' && channelAffectedItem3dLiveFrame != null) {    
                var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
                var selPartId = rowNode.getAttribute("o");
                var objId=sbAffectedItemFrame.objectId;
                        
		var idPath = emxUICore.getData("../enterprisechangemgtapp/ECMGetAffectedItemPath.jsp?contextECOId="+objId+"&selPartId="+selPartId);
                idPath = idPath.substring(0, idPath.indexOf("@"));
                if("NOTEXIST" == idPath && flag == true) {
                        //do nothing
                        //alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.3DLiveExamine.3DRepDoesntExist</emxUtil:i18nScript>");
                } else {
                        toggleSelect(channelAffectedItem3dLiveFrame, flag, idPath);
                }
        }
}
function highlight3DAffectedItem(strID, flag) {
        var aId = strID.split("|");
    var id = aId[3];
    
    if(channelAffectedItem3dLiveFrame == null)
                channelAffectedItem3dLiveFrame  = findFrame(getTopWindow(),"ECM3DliveLaunchCOCR");
        
        if(sbAffectedItemFrame == null) {
		sbAffectedItemFrame = findFrame(getTopWindow(), "ECMCRCOAffectedItems");
                if(sbAffectedItemFrame == null) {
                        sbAffectedItemFrame = findFrame(getTopWindow(), "ECMCRAffectedItems");
                }
        }
        
	if(typeof channelAffectedItem3dLiveFrame != 'undefined' && channelAffectedItem3dLiveFrame != null && !channelAffectedItem3dLiveFrame.location.href.match("emxBlank.jsp")) {    
                var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
                var selPartId = rowNode.getAttribute("o");
                var objId=sbAffectedItemFrame.objectId;
                        
		var idPath = emxUICore.getData("../enterprisechangemgtapp/ECMGetAffectedItemPath.jsp?contextECOId="+objId+"&selPartId="+selPartId);
                idPath = idPath.substring(0, idPath.indexOf("@"));
                if("NOTEXIST" == idPath && flag == true) {
                        //do nothing
                        //alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.3DLiveExamine.3DRepDoesntExist</emxUtil:i18nScript>");
                } else {
                        toggleSelect(channelAffectedItem3dLiveFrame, flag, idPath);
                }
        }
}
        
//Function to select SB  row from 3DLive Examine window in affected items page
function highlightSBAffectedItem(strPath, flag) {
	var oXMLCandidateItems = null;
        var tempArr = strPath.split("/");
	var ECMCandidateFrame =  findFrame(getTopWindow(), "ECMCandidateItems");
	if(ECMCandidateFrame != null && !ECMCandidateFrame.location.href.match("emxBlank.jsp"))
		oXMLCandidateItems = ECMCandidateFrame.oXML;
	var SBFrame = findFrame(getTopWindow(), "ECMCRCOAffectedItems");
        if(tempArr.length == 1) {
                nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o = '" + tempArr[0] + "']");
		if(nSelRow == null){
			nSelRow = emxUICore.selectSingleNode(oXMLCandidateItems, "/mxRoot/rows//r[@o = '" + tempArr[0] + "']");
			SBFrame = findFrame(getTopWindow(), "ECMCandidateItems");
}
        } else {
                var strRel      = tempArr[tempArr.length-1];
                
                var tempIdArr = strRel.split(".");
                if(tempIdArr.length == 5) {
                        strRel = strRel.substring(0, strRel.lastIndexOf("."));
                }
                
		var idPath = emxUICore.getData("../enterprisechangemgtapp/ECMGetAffectedItemPath.jsp?strRel="+strRel+"&fromAffectedItems=true");
                idPath = idPath.substring(0, idPath.indexOf("@"));
		nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o = '" + idPath + "']");
        if(nSelRow == null){
                nSelRow = emxUICore.selectSingleNode(oXMLCandidateItems, "/mxRoot/rows//r[@o = '" + idPath + "']");
                SBFrame = findFrame(getTopWindow(), "ECMCandidateItems");
        }
	}
	
                
        if(typeof nSelRow != 'undefined' && nSelRow != null) {
                sbAffectedItemFrame = SBFrame;
                if(sbAffectedItemFrame == null) {
                        sbAffectedItemFrame = findFrame(getTopWindow(), "ECMCRAffectedItems");
                }
		if(sbAffectedItemFrame == null) {
			sbAffectedItemFrame = findFrame(getTopWindow(), "ECM3DAffectedItemsCA");
		}
                if(flag) {
                        sbAffectedItemFrame.emxEditableTable.select([nSelRow.getAttribute("id")]);
                } else {
                        sbAffectedItemFrame.emxEditableTable.unselect([nSelRow.getAttribute("id")]);
                }
        }
}
  //CO Affected Items    
    
  attachEventHandler(window, "load", closeRowGroupingToolbar);
  function closeRowGroupingToolbar(){
        //Once Affected items page is loaded, close row grouping toolbar which was loaded by default
        if(this && this.frameElement && this.frameElement.name == "ECMCRCOAffectedItems") {
                setTimeout('processRowGroupingToolbarCommand("open/close")',100); 
        }              
    }



   function switchToDefaultView(){
        this.document.location.href = this.document.location.href;
 }
 
 /*****************************************************************************************************************************/
/* function validateEstimatedCompletionDate() - Validates Estimated Completion date which should be greater than today's date
/*                                                                            
/*****************************************************************************************************************************/
function validateEstimatedCompletionDate() {
	var strCompletionDate = trim(arguments[0]);;
    var currentDate = new Date();
    currentDate.setHours(0,0,0,0);
    var eDate = new Date();
    eDate.setTime(strCompletionDate);
    eDate.setHours(0,0,0,0);
    if(strCompletionDate != "" && strCompletionDate != undefined) {
	    if((parseInt(eDate.getTime()))<=(parseInt(currentDate.getTime()))) {
	    	var errormessage="<emxUtil:i18nScript localize="i18nId">EnterpriseChangeMgt.Alert.DueDateGreaterThanCurrent</emxUtil:i18nScript>";
	        alert(errormessage);
	        return false;
	    }
    }
    
    return true;
}

/******************************************************************************/
/* function checkForDecimal() - Check for decimal values                        
/*                                                                            
/******************************************************************************/
 function checkForDecimal(num)
 {
 	return num%1 ? false : true;
 }

/******************************************************************************/
/* function validateEffortDays() - validating Effort days as integer                        
/*                                                                            
/******************************************************************************/
function validateEffortDays(){
	var alertMessage = "<%=EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),"EnterpriseChangeMgt.Alert.IntegerValueAlertForSB")%>"; 
	var ScheduleImpact = trim(arguments[0]);
	if(!isNaN(ScheduleImpact)&&checkForDecimal(ScheduleImpact)){
		return true;
	}
	alert(alertMessage);
	return false;
}

/*****************************************************************************************************************************/
/* function validateEstimatedCompletionDate() - Validates Estimated Completion date which should be greater than today's date
/*                                                                            
/*****************************************************************************************************************************/
function validateEstimatedCompletionDate() {
	var strCompletionDate_msvalue = trim(arguments[0]);
	
    var currentDate = new Date();
    currentDate.setHours(0,0,0,0);
    
    var eDate = new Date(new Date(parseInt(strCompletionDate_msvalue)).toLocaleDateString());
    eDate.setHours(0,0,0,0);
    
   if(strCompletionDate_msvalue != "" && strCompletionDate_msvalue != undefined) {
	    if(eDate<currentDate) {
	    	var errormessage="<%=EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),"EnterpriseChangeMgt.Alert.DueDateGreaterThanCurrent")%>"; 
	        alert(errormessage);
	        return false;
	    }
    }
    
    return true;
}


function validateRequestedChange(arguments) {
	var argArr = arguments.split("|");
	var newValue = argArr[0];
	var affectedItemId = currentRow.getAttribute("o");
	var changeId = currentRow.getAttribute("p");
	var url="../enterprisechangemgtapp/ECMUtil.jsp";
	var queryString = "";
	
	if(affectedItemId == "" || changeId == ""){
		var allNodesUnderCA = currentRow.childNodes;
		for(var i=0; i<currentRow.childNodes.length; i++){
			var node = allNodesUnderCA[i];
			if(node.nodeName == "r"){
				affectedItemId = node.getAttribute("o");
				changeId = node.getAttribute("p");
				
				queryString = "functionality=validateRequestedChange&requestedChangeValue=" +encodeURIComponent(newValue)+ "&affectedItemId=" + encodeURIComponent(affectedItemId) + "&changeId=" + changeId;
				
				if(argArr[1]){
			    	queryString = queryString + "&context=" + argArr[1];
			    }   
			    
			    var jsonString = emxUICore.getDataPost(url, queryString);
				var json = JSON.parse(jsonString);
				var alrtMsg = json.message;
			
				if(alrtMsg){
					alert(alrtMsg);
					return false;
				}				
			}
		}
		return true;
	}
	else{
		
	    queryString = "functionality=validateRequestedChange&requestedChangeValue=" +encodeURIComponent(newValue)+ "&affectedItemId=" + encodeURIComponent(affectedItemId) + "&changeId=" + changeId;
    
    if(argArr[1]){
    	queryString = queryString + "&context=" + argArr[1];
    }    
    
    var jsonString = emxUICore.getDataPost(url, queryString);
	var json = JSON.parse(jsonString);
	var alrtMsg = json.message;

	if(alrtMsg){
		alert(alrtMsg);
		return false;
	}
	else{
		return true;
	}	
}
}


function validateRequestedChangeCOContext(arguments) {
	var success = "";
	var arg = arguments + "|" + "COContext";
	success = validateRequestedChange(arg);
	return success;
}

function validateUserAccess(arguments){
	
	var argArr = arguments.split("|");
	var changeOrderId = currentRow.getAttribute("o");
	var changeRequestId = currentRow.getAttribute("p");
	var url="../enterprisechangemgtapp/ECMUtil.jsp";
    var queryString = "functionality=validateUserAccess&changeOrderId=" + encodeURIComponent(changeOrderId) + "&changeRequestId=" + encodeURIComponent(changeRequestId);
   
    
    if(argArr[1]){
    	queryString = queryString + "&context=" + argArr[1];
    } 
    var jsonString = emxUICore.getDataPost(url, queryString);
	var json = JSON.parse(jsonString);
	var alrtMsg = json.message;

	if(alrtMsg){
		alert(alrtMsg);
		return false;
	}
	else{
		return true;
		}	
}

function validateUserAccessForCC(arguments) {
	var success = "";
	var arg = arguments + "|" + "CCContext";
	success = validateUserAccess(arg);
	return success;
}
function loadDelegatedUIForCreateExternalChangeAction() {
	console.log("loadDelegatedUIForCreateExternalChangeAction");
	require(['DS/ENOChgOSLCConsumer/scripts/ENOECMOSLCConsumer'],function(ENOECMOSLCConsumer){
	var enoECMOSLCConsumer = new ENOECMOSLCConsumer();
	enoECMOSLCConsumer.setup();
	enoECMOSLCConsumer.loadDelegatedUIForCreateExternalChangeAction(enoECMOSLCConsumer.createChangeActionPostProcess);
	});
}
function loadDelegatedUIForAddExistExternalChangeAction() {
	console.log("loadDelegatedUIForAddExistExternalChangeAction");
	require(['DS/ENOChgOSLCConsumer/scripts/ENOECMOSLCConsumer'],function(ENOECMOSLCConsumer){
	var enoECMOSLCConsumer = new ENOECMOSLCConsumer();
	enoECMOSLCConsumer.setup();
	enoECMOSLCConsumer.loadDelegatedUIForAddExistExternalChangeAction(enoECMOSLCConsumer.createChangeActionPostProcess);
	
	});
}

