<%--  CPVIndentedTableValidation.jsp   - page to include the freezepane validation functions.

   (c) Dassault Systemes, 1993-2015.  All rights reserved.

--%>

<%-- 
 ** history:
 *  @fullreview  fl3 gh4 2016/09/19: Creation (3DEXP R2017x)
 *  @quickreview gh4 qwm 2017/03/13: IR-508050: CrossHighlight KO in random cases, for GroupRow & for 2nd level ManItems
 *  @quickreview gh4 qwm 2017/03/13: IR-508050: No code changes, just renaming & refactoring
 *  @quickreview jmm1 gh4 2017/05/25: IR-511564 : Fixed performance issue for crosshighlight toggle button
 *	@quickreview jmm1 gh4 2017/07/04: IR-533290: PPV_FUN070920_VNLS issues with PPV app
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
 *  @quickreview msl5 gh4 2017/10/10: IR-555086 : Cross-highlight, unhighlight and IE compatibility issue
 *  @quickreview jmm1 qwm 2019/03/06: IR-641550 : For MBOM Customized table view, passing only relID instead of rowID for PROCESS.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import = "com.dassault_systemes.vplm.DELJConstants"%>

<script language="Javascript">

<% 
out.clear();
String languageStr      = request.getHeader("Accept-Language");
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding()); 

String strExpandMode     = DELJConstants.EXPAND_MODE;
String strInstanceView   = DELJConstants.EXP_MODE_INSTANCE;
String strQuantityView   = DELJConstants.EXP_MODE_QUANTITY;
String strInstGroupView  = DELJConstants.EXP_MODE_INSTANCE_GROUP;
Locale locale = new Locale((String)request.getHeader("Accept-Language"));

String strInstanceViewHeader = EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", locale,"emxVPLMProcessEditor.CommandLabel.InstanceView");
String strQuantityViewHeader = EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", locale,"emxVPLMProcessEditor.CommandLabel.QuantityView");
String strInstanceGroupViewHeader = EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", locale,"emxVPLMProcessEditor.CommandLabel.InstanceGroupView");
%>


// Table View variables
var sExpandMode    = "<%=XSSUtil.encodeForJavaScript(context,strExpandMode)%>";
var sInstanceView  = "<%=XSSUtil.encodeForJavaScript(context,strInstanceView)%>";
var sQuantityView  = "<%=XSSUtil.encodeForJavaScript(context,strQuantityView)%>";
var sInstGroupView = "<%=XSSUtil.encodeForJavaScript(context,strInstGroupView)%>";

var sViewLabelSubHeader  = "";
var sInstanceViewHeader  = "<%=XSSUtil.encodeForJavaScript(context,strInstanceViewHeader)%>";
var sQuantityViewHeader  = "<%=XSSUtil.encodeForJavaScript(context,strQuantityViewHeader)%>";
var sInstGroupViewHeader = "<%=XSSUtil.encodeForJavaScript(context,strInstanceGroupViewHeader)%>";

// Frame Variables
var currentFrameName  = getURLParameterValue("portalCmdName");
var CPVCurrentFrame   = top.findFrame(top,currentFrameName); 

var CPVPortal         = top.findFrame(top,"CPVMBOMPortal");
var CPV3DViewerFrame  = top.findFrame(top,"CPV3DPlayerCmd");
var CPVExpandPSFrame  = top.findFrame(top,"CPVExpandPSCmd");
var CPVExpandMBOMFrame= top.findFrame(top,"CPVExpandMBOMCmd");

// 3D View Variables
var bIsActiveView     = false;
var iconShow          = "../planningreview/images/iconShowSelection.png";
var iconHide          = "../planningreview/images/iconHideSelection.png";
var iconPartial       = "../planningreview/images/iconCrosshighlightActive.png";
var iconNotApplicable = "../planningreview/images/iconHideSelection.png";

// Separator Variables
var INPUT_SEPARATOR   = ":";
var ROW_INFO_SEPARATOR= "|";
var ROW_ID_SEPARATOR  = "_";
var PATH_SEPARATOR    = "/";
var GROUP_SEPARATOR   = "-";

// CrossHighlight Variables
var bIsCrossHighlightActive    = false;
var cmdToggleCrossHighlightName= "CPVToggleCrossHighlight";
var iconCrossHighlightActive   = "../planningreview/images/iconCrosshighlightActive.png";
var iconCrossHighlightInactive = "../planningreview/images/iconCrosshighlightInactive.png";

// Row Variables
var AttInfo_Is_3DShow     = "is3DShow";      // Info to know if the current element is showed or hidden in the 3D - ONLY FOR LEAF NODES. Possible values: true / false
var AttInfo_3DIcon_Sataus = "icon3DStatus";  // Info to know if the current element is showed, query in db but not showed yet, partially showed, hidden or empty in the 3D - ICON STATUS. Possible values: show / query / hide / partial / intermediate / empty
var AttInfo_3DPath        = "path3D";        // Product path PIDs (prdRefPID1 / prdInstPID2 / prdRefPID3 etc.) corresponding to the current mfg item instance implement for 3D. Possible values: [prdRefPID1/prdInstPID2/prdRefPID3] / intermediate
var AttInfo_Scope_PID     = "scopePID";      // Ref PID of the scoped product of the current mfg item. Possible values: [PID] / intermediate
var AttInfo_ImplementPath_PID = "implementPathPID";	// Implement path PIDs (prdInstPID1 / prdInstPID2 etc.) of the current mfg item instance. Possible values: [prdInstPID1/prdInstPID2] / intermediate

var AttValue_Show    = "show";
var AttValue_Hide    = "hide";
var AttValue_True    = "true";
var AttValue_False   = "false";
var AttValue_Intermediate = "intermediate";
var AttValue_Partial = "partial";
var AttValue_Empty   = "empty";
var AttValue_Query   = "query";

// HTML Elements Variables
var expandMode      = getURLParameterValue(sExpandMode);
var bIsQuantityView = false;
if (expandMode == sQuantityView) {
	bIsQuantityView = true;
}

/////////////////////////////////////////////////////////   Toggle View Related Funs: Starts   //////////////////////////////////////////////////////
//Change View - Instance, Instance Group or Quantity
function setInstanceView()
{
	if(CPVExpandPSFrame != null){
		toggleView(CPVExpandPSFrame,  sInstanceView);
	}
	toggleView(CPVExpandMBOMFrame,sInstanceView);
}

function setInstanceGroupView()
{
	if(CPVExpandPSFrame != null){
		toggleView(CPVExpandPSFrame,  sInstGroupView);
	}
	toggleView(CPVExpandMBOMFrame,sInstGroupView);
}

function setQuantityView()
{
	if(CPVExpandPSFrame != null){
		toggleView(CPVExpandPSFrame,  sQuantityView);
	}
	toggleView(CPVExpandMBOMFrame,sQuantityView);
}

function toggleView(selectedFrame, mode)
{	
	var sURL = selectedFrame.location.href;
	
	if (mode == sQuantityView) {
		bIsQuantityView = true;
		sViewLabelSubHeader = sQuantityViewHeader;
	} else if (mode == sInstanceView) {
		sViewLabelSubHeader = sInstanceViewHeader;
	}  else {
		sViewLabelSubHeader = sInstGroupViewHeader;
	}
	
	if (sURL.indexOf("expandMode=") > 0) {
		sURL = sURL.replace(/expandMode=[^&]*/, "expandMode=" + mode);
		sURL = sURL.replace(/subHeader=[^&]*/, "subHeader=" + sViewLabelSubHeader);
	}
	else {
		sURL += "&expandMode=" + mode;
		sURL += "&subHeader=" + sViewLabelSubHeader;
	}
	
	selectedFrame.location.href = sURL;
}
/////////////////////////////////////////////////////////    Toggle View Related Funs: Ends    //////////////////////////////////////////////////////

///////////////////////////////////////////////////////   CrossHighlight Related Funs: Starts  //////////////////////////////////////////////////////
// Objects Info Management
// IR-508050: dataInfo was maintained sepearately for each of the Product & MBOM frames, which resulted in CrossHighlight KO randomly
// Instead it should be common for both the frames & thus moved it under the top window.
top.dataInfo = new Object();

function getDataInfo(rowNode, infoName)
{
	var infoValue = null;
	var occurence = rowNode.getAttribute("r");
	var objectElement = top.dataInfo[occurence];
	if (objectElement)
		infoValue = objectElement[infoName];
	
	 return infoValue;
}

function setDataInfo(rowNode, infoName, infoValue)
{
	var occurence = rowNode.getAttribute("r");
	var objectElement = top.dataInfo[occurence];
	if (objectElement) {
		objectElement[infoName] = infoValue;
	}
	else {
		var newObjectElement = new Object();
		newObjectElement[infoName] = infoValue;
		top.dataInfo[occurence] = newObjectElement;
	}
}

// Post Expand JS for Product Structure
function postExpandPS(rowID)
{
	// 1. Rebuilt 3D icons for the complete table
}

// Post Expand JS for Mfg Item Structure
function postExpandMBOM(rowID)
{
	// 1. Rebuilt 3D icons for the complete table
	// 2. If crosshighlight active in PS or MBOM frame, rebuilt implement links for children in current frame
	
	// IR-508050: As dataInfo is common to both the frames, CrossHighlight-check also should be common to both of them
	//if (CPVExpandPSFrame.bIsCrossHighlightActive || CPVExpandMBOMFrame.bIsCrossHighlightActive) {
	if (bIsCrossHighlightActive) {
		var rowNode = emxUICore.selectSingleNode(CPVExpandMBOMFrame.oXML, "/mxRoot/rows//r[@id = '" + rowID + "']");
		rebuildImplementLinks(rowNode);
	}
}


// Activate or Unactivate Crosshighlight => Implement Links are retrieved from the DB when needed
function toggleCrossHighlight() 
{
	// 1. Change the icon
	// 2. Rebuilt implement links for MBOM table
	
	if (!bIsQuantityView) 
	{
		bIsCrossHighlightActive = !bIsCrossHighlightActive;
		if (bIsCrossHighlightActive) 
		{
			toggleProgress ('visible');
			
			// Rebuilt Implement Links for MBOM Frame
			var rowNode = emxUICore.selectSingleNode(CPVExpandMBOMFrame.oXML, "/mxRoot/rows//r[@id = '0']");
			rebuildImplementLinks(rowNode);
		}
		else 
		{
			CPVCurrentFrame.$("#"+cmdToggleCrossHighlightName)[0].children[0].setAttribute("src", iconCrossHighlightInactive);
		}
	}
}

function rebuildImplementLinks(rowNode)
{
	// 0. Called from Post Expand, call rebuildImplementLinks with expanded rowNode
	// 0. Called from Toggle Crosshighlight (active), call rebuildImplementLinks with Root Node
	
	// 1. call checkImplementLinks to get the list of objectsToGetImplements
	// 2. query info from jsp for elements in the list objectsToGetImplements
	// 3. set info on elements in the list objectsToGetImplements
	
	var objectsToGetImplements = new Object();
	checkImplementLinks(rowNode, objectsToGetImplements);
	
	var objData = new Object();
	objData.program = "DELJManufItemUtil";
	objData.method = "getImplementPaths";
	objData.data = objectsToGetImplements;
	objData.context = new Object();
	
	var inputs = JSON.stringify(objData);
	
	$.ajax({
		url: '../planningreview/CPVCallJPOProcess.jsp',
		type: 'POST',
		dataType: 'json',
		data: inputs,
		contentType: 'application/json',
		mimeType: 'application/json',

		success: function (implIDs) 
		{
			//IR-511564: Getting First level of childs and set Implemented Product PID 
			var rows = emxUICore.selectSingleNode(CPVExpandMBOMFrame.oXML, "/mxRoot/rows");			
			setImplIDForRows(rows, implIDs.data);  // Loop through each sub childs and set Implemented Product PID 
			
			toggleProgress('hidden');
			CPVCurrentFrame.$("#"+cmdToggleCrossHighlightName)[0].children[0].setAttribute("src", iconCrossHighlightActive);
		},
		error: function(data,status,er) 
		{
			runAlert("error", er);
		}
	});
}


//Recurssive method to iterate each child rows and set Implemented Product PID
function setImplIDForRows(rows, jsonImplIDList)
{
	//IR-555086 Changed row.chlidren to selectNodes
	var childerRows = emxUICore.selectNodes(rows, "r");	
	
	if(childerRows != null && childerRows != undefined){
		
		for(var i=0; i < childerRows.length; i++){
			//IR-555086 removed if condition
			var childRow = childerRows[i];	
			var childRowId = childRow.getAttribute("id");
				var implPrdPID = jsonImplIDList[childRowId];
				// Set Data for each row node
			//IR-555086 Added condition for cross-highlight issue.
			var sImplPathPID = getDataInfo(childRow, AttInfo_ImplementPath_PID);
			if(sImplPathPID == null || sImplPathPID == "" || sImplPathPID == 'undefined') 
			{
				setDataInfo(childRow, AttInfo_ImplementPath_PID, implPrdPID);
			}	
				setImplIDForRows(childRow, jsonImplIDList);
			}
		}
	}

function checkImplementLinks(rowNode, objectsToGetImplements)
{
	
	// 1. check if scope / implement already defined on rowNode
	// 2. if not => put in list objectsToGetImplements
	// 3. call again for rowNode children
	
	var rowID = rowNode.getAttribute("id");
	var sImplPathPID = getDataInfo(rowNode, AttInfo_ImplementPath_PID);
	
	if(typeof(sImplPathPID) == 'undefined' || sImplPathPID == null || sImplPathPID == "") 
	{
		var rowRID = rowNode.getAttribute("r");
		var instPID = getInstPIDFromRowRID(rowRID);
		objectsToGetImplements[rowID] = instPID;		
	}
	
	var lChildren = rowNode.childNodes;
	if (lChildren) 
	{
		for(var i=0; i < lChildren.length; i++) { 
			var curChildNode = lChildren[i];	
			if (curChildNode.tagName == 'r')
				checkImplementLinks(curChildNode, objectsToGetImplements);
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CrossHighlight Action Functions
function doProductCrossHighlight(inputStr, isSelection) 
{
	if (inputStr && bIsCrossHighlightActive) 
	{
		var slSelectedRows = inputStr.split(INPUT_SEPARATOR);
		for (var i = 0; i < slSelectedRows.length; i++) 
		{
			var sRowID = getRowIDfromRow(slSelectedRows[i]);
			var rowNode = emxUICore.selectSingleNode(CPVExpandPSFrame.oXML, "/mxRoot/rows//r[@id = '" + sRowID + "']");
			if(!isGroupNode(rowNode)) 
			{
				var sPathPID = getRowRIDfromRow(slSelectedRows[i]);
				var sInstPathPID = getInstPathFromRowRID(sPathPID);
				if(typeof(sInstPathPID) != 'undefined' && sInstPathPID != null && sInstPathPID != "") {
					var arrRowIds = getMfgItemOccFromPrdInstPath(sInstPathPID, isSelection);
					if(arrRowIds != null && arrRowIds.length>0)
						toggleInTable(isSelection, arrRowIds, CPVExpandMBOMFrame);
				}
			} // if: !isGroupNode
		} // for loop
		
	} // if: bIsCrossHighlightActive
}

function doMfgItemCrossHighlight(inputStr, isSelection) 
{
	if (inputStr && bIsCrossHighlightActive) 
	{
		var slSelectedRows = inputStr.split(INPUT_SEPARATOR);
		for (var i = 0; i < slSelectedRows.length; i++) 
		{
			var sRowID = getRowIDfromRow(slSelectedRows[i]);
			var rowNode = emxUICore.selectSingleNode(CPVExpandMBOMFrame.oXML, "/mxRoot/rows//r[@id = '" + sRowID + "']");
			if(!isGroupNode(rowNode)) 
			{
				var sCompleteImplPathPID = getMfgItemCompleteImplPath(sRowID);
				if(typeof(sCompleteImplPathPID) != 'undefined' && sCompleteImplPathPID != null && sCompleteImplPathPID != "") {
					var arrRowIds = getPrdOccFromMfgItemImplPath(sCompleteImplPathPID, isSelection);
					if(arrRowIds != null && arrRowIds.length>0)
						toggleInTable(isSelection, arrRowIds, CPVExpandPSFrame);
				}
			} // if: !isGroupNode
		} // for loop
	} // if: bIsCrossHighlightActive
}


// Toggle Functions
function toggleInTable(isSelection, arrRowIds, selectedFrame)
{	
	if(isSelection)
		selectedFrame.emxEditableTable.highlight(arrRowIds);
	else
		selectedFrame.emxEditableTable.unhighlight(arrRowIds);
}


// Navigation Functions
/*
function getPrdOccFromPathPID(sPathPID)
{
	var arrRowIds = new Array();
	var rowNodeList = emxUICore.selectNodes(CPVExpandPSFrame.oXML, "/mxRoot/rows//r");
	
	if(typeof(sPathPID) != 'undefined' && sPathPID != null && sPathPID != "") 
	{
		for (var i=0; i < rowNodeList.length; i++) 
		{
			var rowNode = rowNodeList[i];
			var sCurPathPID = rowNode.getAttribute("r");
			if(sCurPathPID == sPathPID && !isGroupNode(rowNode)) {
				var sRowID = rowNode.getAttribute("id");
				arrRowIds.push(sRowID);
			}
		} // for loop
	}
	
	return arrRowIds;
}
*/

function getPrdOccFromMfgItemImplPath(sImplPathPID, isSelection) 
{
	var arrRowIds = new Array();
	var rowNodeList = emxUICore.selectNodes(CPVExpandPSFrame.oXML, "/mxRoot/rows//r");
	
	if(typeof(sImplPathPID) != 'undefined' && sImplPathPID != null && sImplPathPID != "") 
	{
		for (var i=0; i < rowNodeList.length; i++) 
		{
			var rowNode = rowNodeList[i];
			var sRowRID = rowNode.getAttribute("r");
			var sPathInstPID = getInstPathFromRowRID(sRowRID);
			if(sPathInstPID == sImplPathPID && !isGroupNode(rowNode)) {
			//if(sPathInstPID.includes(sImplPathPID) && !isGroupNode(rowNode)) {
				var sRowID = rowNode.getAttribute("id");
				arrRowIds.push(sRowID);
			}
		} // for loop
	}
	return arrRowIds;
}

function getMfgItemOccFromPrdInstPath(sInstPathPID, isSelection) 
{
	var rowNodeList = emxUICore.selectNodes(CPVExpandMBOMFrame.oXML, "/mxRoot/rows//r");
	var arrRowIds = new Array();
	
	if(typeof(sInstPathPID) != 'undefined' && sInstPathPID != null && sInstPathPID != "") 
	{
		for (var i=0; i < rowNodeList.length; i++) 
		{
			var rowNode = rowNodeList[i];
			var sRowType = rowNode.getAttribute("type");
			var sRowRID = rowNode.getAttribute("r");
			var sImplPathPID = getDataInfo(rowNode, AttInfo_ImplementPath_PID);
			if(sInstPathPID.indexOf(sImplPathPID) != -1 && sImplPathPID != null && sImplPathPID != "" && !isGroupNode(rowNode) && sImplPathPID != AttValue_Intermediate) 
			{
				var sRowID = rowNode.getAttribute("id");
				if(sInstPathPID == sImplPathPID)
					arrRowIds.push(sRowID);
				else {
					var sCompleteImplPathPID = getMfgItemCompleteImplPath(sRowID);
					if(sInstPathPID == sCompleteImplPathPID)
						arrRowIds.push(sRowID);
				}
			}
		} // for loop
	}
	
	return arrRowIds;
}

function getMfgItemCompleteImplPath(nodeID)
{
	var rowNode = emxUICore.selectSingleNode(CPVExpandMBOMFrame.oXML, "/mxRoot/rows//r[@id = '" + nodeID + "']");	
	var sCompleteImplPathPID = "";
	if(!isGroupNode(rowNode)) 
	{
		var sImplPathPID = getDataInfo(rowNode, AttInfo_ImplementPath_PID);
		var isFirst = true;
		
		if(typeof(sImplPathPID) != 'undefined' && sImplPathPID != null && sImplPathPID != "" && sImplPathPID != AttValue_Intermediate) 
		{
			var slImplPathPIDs = getOccurenceInfo(rowNode, AttInfo_ImplementPath_PID);
			// IR-508050: To fix CrossHighlight KO for 2nd level ManItems. Root-node is already
			// ignored in getOccurenceInfo. So loop should start from 0 only, not from 1.
			for (var i = 0; i < slImplPathPIDs.length; i++)
			{
				var sTempImplPathPID = slImplPathPIDs[i];
				if(typeof(sTempImplPathPID) != 'undefined' && sTempImplPathPID != null && sTempImplPathPID != "" && sTempImplPathPID != AttValue_Intermediate) {
					if(isFirst) {
						sCompleteImplPathPID = sTempImplPathPID;
						isFirst=false;
					}
					else {
						sCompleteImplPathPID += PATH_SEPARATOR + sTempImplPathPID;
					}
				}
			} // for loop
			
			if(isFirst) {
				sCompleteImplPathPID = sImplPathPID;
			}
			else {
				sCompleteImplPathPID += PATH_SEPARATOR + sImplPathPID;
			}
			
		} // if: sImplPathPID
	} // if: !isGroupNode
	
	return sCompleteImplPathPID;
}

/* Return list of info of the rowNode and its parents (if exist).
 * Do not take into account InstanceGroup nodes
 */
function getOccurenceInfo(rowNode, InfoName)
{
	var InfoValueList = [];
	var parentRows = emxUICore.selectNodes(rowNode, "ancestor::r");
	for (var i = 1; i < parentRows.length; i++) 
	{
		var sParentInfoValue = getDataInfo(parentRows[i],InfoName);
		if(!isGroupNode(parentRows[i])) {
			InfoValueList.push(sParentInfoValue);
		}
	}
	return InfoValueList;
}

///////////////////////////////////////////////////////    CrossHighlight Related Funs: Ends   //////////////////////////////////////////////////////

//////////////////////////////////////////////////////////    RowInfo Related Funs: Starts     //////////////////////////////////////////////////////

/* Some notes on RowInfo
 * Typical Row Format:  <RelID>|<ObjID>|<ParID>|<RowID>
	- For RootRow, RelID won't exist
	- In PPV we modify RelID to hold complete OccPath, whose format would be
	     TopRefPID / prd1InstPID / prd1RefPID / prd2InstPID / prd2RefPID / ...
  * Separators used
	     var INPUT_SEPARATOR  = ":";
	     var ROW_INFO_SEPARATOR = "|";
	     var ROW_ID_SEPARATOR = "_";
	     var PATH_SEPARATOR   = "/";
	     var GROUP_SEPARATOR  = "-";
 */
 
// Functions to get info from rows
function getRowRIDfromRow(strRowInfo) 
{
	var sID = "";
	if (strRowInfo) 
	{
		var tempList = strRowInfo.split(ROW_INFO_SEPARATOR);
		if(tempList.length > 3)
			sID = tempList[0];
	}
	return  sID;
}

function getRowOIDfromRow(strRowInfo)
{
	var sID = "";
	if (strRowInfo) 
	{
		var tempList = strRowInfo.split(ROW_INFO_SEPARATOR);
		if(tempList.length == 3)
			sID = tempList[0];
		else
			sID = tempList[1];
	}
	return  sID;
}

function getRowIDfromRow(strRowInfo) 
{
	var sID = "";
	if (strRowInfo) 
	{
		var tempList = strRowInfo.split(ROW_INFO_SEPARATOR);
		if(tempList.length == 3)
			sID = tempList[2];
		else
			sID = tempList[3];
	}
	return  sID;
}


// Functions to get info from RowRID (ref and inst PIDs, path inst PIDs)
function getRefPIDFromRowRID(sRowRID) 
{
	var sID = "";
	var sPathPID = sRowRID;
	if (sPathPID)
	{
		var tempList = sPathPID.split(PATH_SEPARATOR);
		if(tempList.length > 0)
			sID = tempList[tempList.length - 1];
	}
	return  sID;
}

function getInstPIDFromRowRID(sRowRID) 
{
	var sID = "";
	var sPathPID = sRowRID;
	if (sPathPID) 
	{
		var tempList = sPathPID.split(PATH_SEPARATOR);
		if(tempList.length > 1){
			sID = tempList[tempList.length - 2];
		}
		else{ 
			sID = tempList[0];
		}
	}
	return  sID;
}	

function getInstPathFromRowRID(sRowRID) 
{
	var pathInstID = "";
	var sPathID = sRowRID;
	if (sPathID) 
	{
		var pathList = sPathID.split(PATH_SEPARATOR);
		if(pathList.length > 2) {
			for (var i=1; i < pathList.length; i++) {
				if(i==1)
					pathInstID = pathList[i];
				else
					pathInstID += PATH_SEPARATOR + pathList[i];
				i++;
			}
		}
	}
	return  pathInstID;
}

function getListFromPath(strPath) 
{
	var idTable = [];
	if (strPath) 
	{
		var pathList = strPath.split(PATH_SEPARATOR);
		if(pathList.length > 0) {
			for (var i=0; i < pathList.length; i++)
				idTable.push(pathList[i]);
		}
	}
	return  idTable;
}

///////////////////////////////////////////////////////////    RowInfo Related Funs: Ends    ////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////    Functions Utils: Starts    ///////////////////////////////////////////////////////////
function isGroupNode(rowNode) 
{
	// IR-641550 - Always GroupRow Node is false for Instance View
	if(expandMode === sInstanceView){
		return false;
	}
	
	// IR-508050: GroupRow check can't be based on Type as it would have actual objType value.
	// So check has to be based on the RelId, which will have GROUP_SEPARATOR in it (in case of GroupRow)
	var rowRelId = rowNode.getAttribute("r");
	
	//IR-555086 replaced includes method with indexOf since IE doesn't support includes
	var groupSep = rowRelId.indexOf(GROUP_SEPARATOR);
	
	if(groupSep === -1)
	{
		// IR-641550 GROUP_SEPARATOR is removed for MBOM GroupRow Node, check should be done 
		// if any one of the child RelId and GroupRow RelId should be equal 
		// since we are setting same RelId for Customize Table view
		
		var lChildren = rowNode.childNodes;
		if (lChildren) 
		{
			for(var i=0; i < lChildren.length; i++) { 
				var curChildNode = lChildren[i];	
				if (curChildNode.tagName === 'r'){
					var curChildRelId = curChildNode.getAttribute("r");
					if(curChildRelId == rowRelId){
						return true;
					}
				}
			}
		}
	}	
	else
	{
		// Product structure 
		return true;
	}

	
	return  false;
}

//get URL Parameters
function getURLParameterValue(paramName) 
{
	var searchStr = paramName + "=";
	var indexStart = document.location.href.indexOf(searchStr);
	
	if (indexStart >= 0) 
	{
		var indexEnd = document.location.href.indexOf("&", indexStart);
		
		if (indexEnd > indexStart)
			return document.location.href.substring(indexStart+searchStr.length, indexEnd);
		else
			return document.location.href.substring(indexStart+searchStr.length);
	}
	return "";
}

//jsp="CPVCallJPOProcess.jsp"
function runProcess(jsp, inputs) 
{
	$.ajax({
		url: jsp,
		type: 'POST',
		dataType: 'json',
		data: JSON.stringify(inputs),
		contentType: 'application/json',
		mimeType: 'application/json',

		success: function (outputs) 
		{
			var ctx = outputs.context;
			var data = outputs.data;
			var className = data.result;
			var message = data.message;
			runAlert(className, "Message : " + message);
		},
		error: function(data,status,er) 
		{
			alert("error: "+data+" status: "+status+" er:"+er);
		}
	});
}

function runAlert(sClassName, sMessage) 
{
	var context = getTopWindow().require ? getTopWindow(): window;
	context.require(['DS/UIKIT/Alert'], function (Alert)
	{
		var myAlert = new Alert({
			closable: true,
			visible: true,
			autoHide: true
		}).inject(getTopWindow().document.body);
		//className = success OR warning OR error
		myAlert.add({ className: sClassName, message: sMessage});
	})
}

///////////////////////////////////////////////////////////    Functions Utils: Ends    ///////////////////////////////////////////////////////////

///    ------------------- 3D -------------------

////////////////////////////////////////////////////////  CfgFilter Related Funs: Starts    /////////////////////////////////////////////////////////
function setCfgFitlerValues(topWindow, sCfgFilterName, bEnableDisable, 
							sDispValue, sActualValue, sOIDValue) 
{	
	// Set values of input control
	topWindow.document.getElementById(sCfgFilterName).value = sDispValue;  
	topWindow.document.getElementById(sCfgFilterName + "_actualValue").value = sActualValue;  
	topWindow.document.getElementById(sCfgFilterName + "_OID").value = sOIDValue;
	
	// Enable\disable input control
	topWindow.document.getElementById(sCfgFilterName).disabled = bEnableDisable;
	
	// Enable\disable chooser control
	var inputCtrlTitle = topWindow.document.getElementById(sCfgFilterName).title;
	var chooserBtns = top.document.getElementsByName("chooser");
	for (var i=0; i < chooserBtns.length; i++)
	{
		var chooserBtnTitle = chooserBtns[i].title;
		if (chooserBtnTitle === inputCtrlTitle) {
			chooserBtns[i].disabled = bEnableDisable;
			break;
		}
	}
}

function clearCfgFilters() 
{	
	// Clear PreDefined Filter
	setCfgFitlerValues(top, "gh4_CPVCfgFilterPredefInput",  false, "", "", "");
	
	// Clear Dynamic Filter
	setCfgFitlerValues(top, "gh4_CPVCfgFilterDynamicInput", false, "", "", "");
}

////////////////////////////////////////////////////////    CfgFilter Related Funs: Ends    /////////////////////////////////////////////////////////
