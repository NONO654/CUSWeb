
<%
	String selectHandler     = (String)emxGetParameter(request, "selectHandler");
	String compare3D = emxGetParameter(request, "3DCompare");
%>

var channel3dLiveFrame 	= null;
var channel3dLiveFrame1 = null;

//To get the id path of the selected item in SB for 3D Live Examine selection
function getIDPathFromXMLNode(rowNode){
	var parentRows = emxUICore.selectNodes(rowNode, "ancestor::r");
  
	var idPath = (parentRows.length != 0) ? "" : rowNode.getAttribute("o");
	
	for (var i = 0; i < parentRows.length; i++) {
  		idPath += (i==0) ? parentRows[i].getAttribute("o") : "/" + parentRows[i].getAttribute("r");
	}
  
	idPath += (parentRows.length != 0) ? "/" + rowNode.getAttribute("r") : "";
  
	return idPath;
}

//To get the id path of the selected right side item in SB for 3D Live Examine selection in compare for common items
function getIDPathFromXMLNodeRight(rowNode){
	var parentRows = emxUICore.selectNodes(rowNode, "ancestor::r");
    
	var idPath = (parentRows.length != 0) ? "" : rowNode.getAttribute("o2");
	
    for (var i = 0; i < parentRows.length; i++) {
    	idPath += (i==0) ? parentRows[i].getAttribute("o2") : "/" + parentRows[i].getAttribute("r2");
    }
    
    idPath += (parentRows.length != 0) ? "/" + rowNode.getAttribute("r2") : "";
    
    return idPath;
}

//Default behavior of select/de-select if emxIndentedTable.jsp is passed with param selectHandler=crossHighlight and 
//OOTB channel is used for 3D Live Examine
function crossHighlight(rowIds, flag) {
	var chkAllFlag = false;
	var objForm = document.forms["emxTableForm"];
	if(objForm.chkList) {
		chkAllFlag = objForm.chkList.checked;
	}
	
	var strIDs = rowIds.split(":");
	if(chkAllFlag) {
		var tempVal = strIDs[0];
		strIDs = new Array();
		strIDs[0] = tempVal;
	}

	var aId = "";
	var rowId = "";
	var rowNode = null;
	var idPath = "";

	if(channel3dLiveFrame == null)
		channel3dLiveFrame 	= findFrame(getTopWindow(),"APPLaunch3DLiveChannel");
	
	if(typeof channel3dLiveFrame != 'undefined' && channel3dLiveFrame != null) {
 		channel3dLiveFrame.beginSelection("viewer");
		for (var j = 0; j < strIDs.length; j++) {
			aId = strIDs[j].split("|");
		    rowId = aId[3];
			rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
			
			idPath = getIDPathFromXMLNode(rowNode);
			toggleSelect(channel3dLiveFrame, flag, idPath);
		}
		channel3dLiveFrame. commitSelection("viewer");
	}
	
}

var finalResultsFrame = "";
//Function to Highlight 3D objects in BOM Compare
function highlight3DItem(strID, mode) {
	if(finalResultsFrame == "") {
		finalResultsFrame = getCompareResultsFrameName();
	}
	
	var aId = strID.split("|");
    var id = aId[3];
	var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
	
	if(channel3dLiveFrame1 == null || channel3dLiveFrame1.location == null) {
		channel3dLiveFrame 	= findFrame(getTopWindow(),"APPLaunch3DLiveChannel");
		channel3dLiveFrame1 	= findFrame(getTopWindow(),"APPLaunch3DLiveChannelCompare");
	}
	
	var idPath 			= getIDPathFromXMLNode(rowNode);

    var matchresult = rowNode.getAttribute("matchresult");
   	if(typeof matchresult != 'undefined' && matchresult != null) {
   		
   		if("AEFSCBOM2UniqueComponentsReport" == finalResultsFrame) {
   			matchresult = "right";
   		}
   		
   		if(matchresult == "left") {
	        toggleSelect(channel3dLiveFrame, mode, idPath);
   		} else if(matchresult == "right") {
	        toggleSelect(channel3dLiveFrame1, mode, idPath);
   		} else if(matchresult == "common") {
	        toggleSelect(channel3dLiveFrame, mode, idPath);
	        idPath = getIDPathFromXMLNodeRight(rowNode, "true");
	        toggleSelect(channel3dLiveFrame1, mode, idPath);
   		}
   	} else {
   		toggleSelect(channel3dLiveFrame, mode, idPath);
   	}
}

//Function to select/deselect based on flag
function toggleSelect(channel3dLiveFrame, flag, idPath) {
	 (flag) ? channel3dLiveFrame.select("viewer", idPath) : channel3dLiveFrame.unselect("viewer", idPath);
}

var compareResultsFrms = new Array();
compareResultsFrms[0] = "AEFSCCompleteSummaryResults";
compareResultsFrms[1] = "AEFSCDifferenceOnlyReport";
compareResultsFrms[2] = "AEFSCCompareCommonComponents";
compareResultsFrms[3] = "AEFSCBOM1UniqueComponentsReport";
compareResultsFrms[4] = "AEFSCBOM2UniqueComponentsReport";

function getCompareResultsFrameName() {
	for(var counter=0; counter < compareResultsFrms.length; counter++) {
		if(findFrame(getTopWindow(), compareResultsFrms[counter]).frameElement.parentElement.style.display == "") {
			return compareResultsFrms[counter];
		}
	}
}

function getFinalSBFrame() {
<%
	if(compare3D != null && !"".equals(compare3D)) {
%>
		if(finalResultsFrame == "" || findFrame(getTopWindow(), finalResultsFrame).frameElement.parentElement.style.display != "") {
			finalResultsFrame = getCompareResultsFrameName();
		}
		return findFrame(getTopWindow(), finalResultsFrame);				
<%					
	} else {
%>
		var visibleFrame = findFrame(getTopWindow(),"detailsDisplay");
		return findFrame(visibleFrame,"listHidden").parent;
<%
	}
%>
}

function onSelection(ViewerId, EventCategory, EventName, EventSender, EventParameters)
{
	var sbFrame;
	var oXML;
	var checkObject;
	var tempAddRowIds = new Array();
	var tempDelRowIds = new Array();
	var addCounter = 0;
	var deleteCounter = 0;
	
	if(!findFrame(getTopWindow(), "listHidden")) {
		return true;
	} else {
		sbFrame = getFinalSBFrame();
		if(!sbFrame) {
			return true;
		}
		oXML 	= sbFrame.oXML;
	}
	
	if (EventCategory == "Selection")
	{
		var currentElem = EventParameters;
		var selCount 	= currentElem.Count;
		var selItem = null;
		var idPath = "";
		var tempArr;
		var strRel = "";
		var flag = false;
		var tempIdArr;
		
		if (selCount > 0)
		{
			for(var j = 1; j <= selCount; j++)
			{			
				selItem = currentElem.Item(j);
				idPath 	= getIdFromObject(ViewerId, selItem);
				
<%
				if(selectHandler != null && !"".equals(selectHandler)) {
%>
					eval("sbFrame." + "<%=XSSUtil.encodeForJavaScript(context, selectHandler) %>('"+idPath+"', "+("Add" == EventName)+")");
<%					
				} else {
%>				
					tempArr = idPath.split("/");
					strRel 	= tempArr[tempArr.length-1];
					
					tempIdArr = strRel.split(".");
					if(tempIdArr.length == 5) {
						strRel = strRel.substring(0, strRel.lastIndexOf("."));
					}
					
					checkObject  = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='"+tempArr[0]+"']"); 
					if(!checkObject) {
						checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o2='"+tempArr[0]+"']"); 
					}
					
					var nSelRow = checkObject;
					
					//Check the node and expand nodes
					if(sbFrame.isStructureCompare != "TRUE") { 
						for(var i=1; i < tempArr.length-1; i++) {
							
							var expandRow = emxUICore.selectSingleNode(checkObject, "r[@r = '" + tempArr[i] + "']");
							if(expandRow != null) {
								var expandC = expandRow.getAttribute("expand");
								if(expandC == null || (typeof expandC == 'undefined')){
									var parentLevel = expandRow.getAttribute("level");
									var parentRowIdArr = new Array();
									parentRowIdArr[0] = expandRow.getAttribute("id");
									sbFrame.emxEditableTable.expand(parentRowIdArr, parentLevel);
								} else if(expandC == 'true') {
									expandRow.setAttribute("display","block");
								}
		
								checkObject = expandRow;
							}
		
						}
					}
					
					if(tempArr.length != 1) {
						nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@r = '" + strRel + "']");
						if(!nSelRow) {
							nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@r2 = '" + strRel + "']");
						}
					}
					
	
					if(typeof nSelRow!='undefined' && nSelRow!=null) {
						var nSelRowId = nSelRow.getAttribute("id");
						if (EventName == "Add") {
							tempAddRowIds[addCounter++] = nSelRowId;
						} else if (EventName == "Remove") {
							tempDelRowIds[deleteCounter++] = nSelRowId;
						}
					}
						
					if(tempDelRowIds.length > 0) {
						sbFrame.emxEditableTable.unselect(tempDelRowIds);
					}
					
					if(tempAddRowIds.length > 0) {
						sbFrame.emxEditableTable.select(tempAddRowIds, true);
					}
				 
<%					
				}
%>				
			}
			
		}
	}
	return true;
}
  	
