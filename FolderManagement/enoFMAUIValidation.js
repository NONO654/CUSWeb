
var objIdsString = "";

var channel3dplay = findFrame(getTopWindow(), "Workspace3DViewer");
var contentSBFrame = findFrame(getTopWindow(), "WorkspaceContent");

function loadFolderContent(id) {
	var treeWindow = emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders');
	var tree = treeWindow.jQuery('#genericFancyTree').fancytree("getTree");
	var ftNode = tree.getNodeByKey(id);
	ftNode.makeVisible();
	ftNode.setFocus();
	treeWindow.calledFromSearch = true;
	treeWindow.fancyTreeNodeClick(ftNode.data.objectId,ftNode.data.relId,ftNode.data.type);
	treeWindow.calledFromSearch = false;
}

function selectFolder(id) {
	var tree = null;
	try {
		tree = emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders').jQuery('#genericFancyTree').fancytree("getTree");
	} catch(ex) {
	}
	if (!tree) {
		setTimeout("selectFolder('" + id + "');", 1000);
	} else {
		console.log("Wait Successful");
		var row = emxUICore.selectSingleNode(oXML, "/mxRoot/rows/r[@o = '" + id + "']");
		var colValue = emxEditableTable.getCellValueByRowId(row.getAttribute("id"), 'Path').value.current.actual;
		var parser = new DOMParser();
		var xmlDoc = parser.parseFromString(colValue,"text/xml");
		var workspaceId = id;
		if (xmlDoc.documentElement.firstElementChild) {
		    var href = xmlDoc.documentElement.firstElementChild.getAttribute("href");
			workspaceId = href.substring(href.indexOf("'") + 1, href.length - 2);
		}
		var ftNode = tree.getNodeByKey(workspaceId);
		ftNode.setExpanded(true);
		setTimeout("loadFolderContent('" + id + "');", 3000);
	}
}

// On click of Name column of Folder search result
function displayFolderInFolderApp (colNum, oid) {
	getTopWindow().closeWindowShadeDialog(false, true);
	var tree = null;
	try {
		tree = emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders').jQuery('#genericFancyTree').fancytree("getTree");
	} catch(ex) {
		launchEnoviaApp("emxNavigator.jsp?appName=ENOFOL2_AP");
	}
	selectFolder(oid);
}

//this is the callback function to be registered with 3dplay
//arg - EventParameters is the instacePathId
//arg - EventCategory is boolean true or false
var cbFunction = function onSelection(EventParameters, EventCategory)
{
	if(!contentSBFrame) {
		return true;
	}
	var pathArray = EventParameters.split("/");
	var contextObject = null;
	if (pathArray.length == 1) {
		contextObject = emxUICore.selectSingleNode(contentSBFrame.oXML, "/mxRoot/rows//r[@o = '" + pathArray[pathArray.length-1] + "']");
	} else {
		contextObject = emxUICore.selectSingleNode(contentSBFrame.oXML, "/mxRoot/rows//r[@r = '" + pathArray[pathArray.length-1] + "']");
	}
	if (!contextObject) {
		return true
	}
	var contextId = contextObject.getAttribute("id");
	var contextIds = new Array();
	contextIds.push(contextId);
	if (EventCategory) {
		contentSBFrame.emxEditableTable.select(contextIds, false);
	} else {
		contentSBFrame.emxEditableTable.unselect(contextIds, false);
	}
	return true;
}


//this is the callback function to be registered with 3dplay
//arg - EventParameters is the instacePathId
var centerGraphFun = function onCenterTree(EventParameters)
{
		//alert('callback isselect-->'+EventCategory);
		//alert('param-->'+EventParameters);
		//toggleProgress("visible");
		var sbFrame;
		var oXML;
		var checkObject;
		var tempAddRowIds = new Array();
		var tempDelRowIds = new Array();
		var addCounter = 0;
		var deleteCounter = 0;
		//var psSBFrame 	= findFrame(getTopWindow(), "PRSDObjectNavigate");

		if(!contentSBFrame) {
			return true;
		} else {
			oXML 	= contentSBFrame.oXML;
		}
		//alert(oXML);

		var currentElem = EventParameters;

		var selItem = null;
		var idPath = "";
		var tempArr;
		var strRel = "";
		var flag = false;
		var tempIdArr;

		selItem = currentElem;

		tempArr = selItem.split("/");
		strRel 	= tempArr[0];
		var selLength = tempArr.length;
		var onlyRootSelected = false;
		if(selLength == '1'){
			onlyRootSelected = true;
		}
		//alert('--onlyRootSelected--'+onlyRootSelected);

		if(onlyRootSelected){
			//alert("strRel-->"+strRel);
			checkObject  = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='"+tempArr[0]+"']");
			//alert(checkObject);
			if(!checkObject) {
				checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o2='"+tempArr[0]+"']");
			}
			//alert(tempArr.length);
			var nSelRow = checkObject;
			if(typeof nSelRow!='undefined' && nSelRow!=null) {
				var nSelRowId = nSelRow.getAttribute("id");
				tempAddRowIds[addCounter++] = nSelRowId;

			}
		} else {
			//Check the node and expand nodes
			var vImmediateParentRelId;
			for(var i=0; i < tempArr.length-1; i++)
			{
				var xPath = "/mxRoot/rows//r[@r = '";

				if(i==0)
					xPath = "/mxRoot/rows//r[@o = '";

				var node = emxUICore.selectSingleNode(oXML, xPath + tempArr[i] + "']");

				if(node != null)
				{
					var isExpanded = node.getAttribute("expand");

					vImmediateParentRelId = node.getAttribute("id");

					if(typeof isExpanded == 'undefined' || isExpanded == null)
					{
						var nodeIdArr = new Array();
						nodeIdArr[0] = vImmediateParentRelId;
						if (i == tempArr.length-2) {
							contentSBFrame.emxEditableTable.expand(nodeIdArr, "1", true);
						} else {
							contentSBFrame.emxEditableTable.expand(nodeIdArr, "1", false);
						}
					}
					else if(isExpanded == 'true')
						node.setAttribute("display", "block");
				}
			}

			strRel = tempArr[tempArr.length - 1];
							//if(tempArr.length != 1) {
			//nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@r = '" + strRel + "']");
								//alert("--in loop--"+strRel);

			nSelRow   = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '"+ vImmediateParentRelId +"']/r[@r = '"+ strRel +"']");

			if(!nSelRow) {
				//nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@r2 = '" + strRel + "']");
				nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '"+ vImmediateParentRelId +"']/r[@r2 = '"+ strRel +"']");
			}
			if(typeof nSelRow!='undefined' && nSelRow!=null) {
				var nSelRowId = nSelRow.getAttribute("id");
				tempAddRowIds[addCounter++] = nSelRowId;
			}
		}
			//alert('tempAddRowIds.length=='+tempAddRowIds.length);

		if(tempAddRowIds.length > 0) {

			contentSBFrame.emxEditableTable.select(tempAddRowIds, true);
			for (var j = 0; j < tempAddRowIds.length; j++) {
				var idEachRow = tempAddRowIds[j];
				RefreshSelections(idEachRow,true);
			}
		}
		//toggleProgress("hidden");
	return true;
}

//Sample function for Show hide column - Logic not completed
//This function loads the structure first and then registers the callback function for 3dplay
//NOTE  - it is important that callback registration is done in this method
//Needs to be moved in code to be added by HUO
function run3dviewer(objectId)
{
	//alert("From valid----new apprach --");
	//var myFrame = findFrame(getTopWindow(), "Workspace3DViewer");
	//alert(myFrame.frameElement);
	channel3dplay.frameElement.ENOV3DLoadStructure(objectId);
	//register the callback function with 3dPlayer using below line..This should be done on Show/Hide column logic
	//Temporarily added here for testing
	var vIsCBRegistered = channel3dplay.frameElement.ENOV3DIsCenterTreeCBRegistered();
	if(!vIsCBRegistered){
		channel3dplay.frameElement.ENOV3DAddCenterTreeCB(centerGraphFun);
	}
	var vIsCB2Registered = channel3dplay.frameElement.ENOV3DIsSelectCBRegistered();
	if(!vIsCB2Registered){
		channel3dplay.frameElement.ENOV3DAddSelectCB(cbFunction);
	}
}


// Function called when any row is selected or deselected in Navigate Structure Browser
// This function creates JSON array & calls setStructure() method
function openFromWeb(rowIds, selectedFlag) {

	if(rowIds != null && rowIds != "") {

		// Create string of selected object Ids
		var pathArray = rowIds.split(":");
		for(var i=0; i < pathArray.length; i++) {
			var idArray = pathArray[i].split("|");
			if(selectedFlag) {
				if(objIdsString.indexOf(idArray[1]) == -1)
					objIdsString+= idArray[1] + ",";
			}
			else
				objIdsString = objIdsString.replace(idArray[1] + ",", "");
		}

		var jsonArray = [];

		// Create JSON Array from objIdsString
		if(objIdsString != null && objIdsString != "") {

			if(objIdsString.indexOf(objectId) == -1)
				jsonArray.push({ "busid":objectId, "isroot":true,  "isselected":false });
			else
				jsonArray.push({ "busid":objectId, "isroot":true,  "isselected":true });

			var objArray = objIdsString.split(",");
			if(objArray.length > 1) {
				for(var i=0; i < (objArray.length - 1); i++) {
					if(objArray[i] != objectId)
						jsonArray.push({ "busid":objArray[i], "isroot":false,  "isselected":true });
				}
			}
		}

		// Call Set Structure method & pass JSONString
		jsonString = JSON.stringify(jsonArray);

		require(['UWA/Utils/InterCom'], function(InterCom) {
			var myStructureEventSocket = new InterCom.Socket('myStructureEventSocket');
			myStructureEventSocket.subscribeServer('com.ds.compass',  getTopWindow());
			myStructureEventSocket.dispatchEvent('onSetStructure', {structure: jsonString},'myStructureEventSocket'
			);
		});
	}
}

if(channel3dplay){
	var vIsCBRegistered = channel3dplay.frameElement.ENOV3DIsCenterTreeCBRegistered();
	if(!vIsCBRegistered){
		channel3dplay.frameElement.ENOV3DAddCenterTreeCB(centerGraphFun);
	}
	var vIsCB2Registered = channel3dplay.frameElement.ENOV3DIsSelectCBRegistered();
	if(!vIsCB2Registered){
		channel3dplay.frameElement.ENOV3DAddSelectCB(cbFunction);
	}
}

//var cbRegistered = false;
//sample function to reference 3dplay frame and invoke methods on it
function test3dviewer(objectId)
{
	//alert("to hide --");
	//var myFrame = findFrame(getTopWindow(), "Workspace3DViewer");
	//alert(myFrame.frameElement);
	//myFrame.frameElement.ENOV3DHideInViewer(objectId);
	channel3dplay.frameElement.ENOV3DSelectInViewer(objectId);
}

//function called when any row is selected or deselected in Navigate structure browser
//this function invokes select or deselect method of 3dplay for corresponding action
function crossHL3dplay(rowIds, flag)
{
	//alert('cross hl');
	//alert(vInCBExecution);

	var chkAllFlag = false;
	var objForm = document.forms["emxTableForm"];
	if(objForm.chkList) {
		chkAllFlag = objForm.chkList.checked;
	}

	// Open from Web in CATIA
	//openFromWeb(rowIds, flag);

	var strIDs = rowIds.split(":");
	if(chkAllFlag) {
		var tempVal = strIDs[0];
		strIDs = new Array();
		strIDs[0] = tempVal;
	}
//		for (var j = 0; j < strIDs.length; j++) {
//			aId = strIDs[j].split("|");
//		    var rowId = aId[1];
//	alert(rowId);
//	hide3dviewer(rowId);
//		}

	var aId = "";
	var rowId = "";
	var rowNode = null;
	var idPath = "";

	if(channel3dplay == null)
		channel3dplay 	= findFrame(getTopWindow(), "Workspace3DViewer");

	if(typeof channel3dplay != 'undefined' && channel3dplay != null) {

		for (var j = 0; j < strIDs.length; j++) {
			aId = strIDs[j].split("|");
		    rowId = aId[3];
			rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
			idPath = getIDPathFromXMLNode(rowNode);
			//alert(idPath);
			toggleSelect(channel3dplay, flag, idPath);

			//onSelection(idPath, true);
			//onSelection(idPath, false);

			//onSelection("SELECT", idPath);
			//onSelection("DESELECT", idPath);
		}
	}
}

//function to get the path of the given row from root node in structure browser
//this function builds the path for a given row as required by 3dplay js methods
function getIDPathFromXMLNode(rowNode){
	var parentRows = emxUICore.selectNodes(rowNode, "ancestor-or-self::r");

	var idPath = "";

	var firstTime = true;
	for (var i = 0; i < parentRows.length; i++) {
		var id = parentRows[i].getAttribute("id");
		var hideShowValue = emxEditableTable.getBooleanColumn(id, "HideShow");
		if (hideShowValue && hideShowValue == "none") {
			continue;
		}
		if (firstTime) {
			idPath += parentRows[i].getAttribute("o");
			firstTime = false;
		} else {
			idPath += "/" + parentRows[i].getAttribute("r");
		}
	}

	return idPath;
}

//Function to select/deselect based on flag
function toggleSelect(channel3dplay, flag, idPath) {
	 (flag) ? channel3dplay.frameElement.ENOV3DSelectInViewer(idPath) : channel3dplay.frameElement.ENOV3DDeselectInViewer(idPath);
}


//function added by Priyanka for show hide
function getChildrenFromXMLNode(rowNode, isParShow, dontAskViewer){
	//var psSBFrame  = findFrame(getTopWindow(), "WorkspaceContent");

 /* if(channel3dplay == null)
    channel3dplay 	= findFrame(getTopWindow(), "Workspace3DViewer");
 */
  var isPartShow = isParShow;

  var rElems = rowNode.getElementsByTagName("r");

  var rowsToRefresh = [];
  for(var t = 0;t <rElems.length;t++)
  {
    var temp = rElems[t];
    var displayRowAttribute = temp.getAttribute("displayRow");
    if(displayRowAttribute != 'false')
    {
      var TempObjectIdLev = temp.getAttribute("id");
      var columnName = "HideShow";
      var temprowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + TempObjectIdLev + "']");


      if (dontAskViewer == null || dontAskViewer == false)
      {
        var idPath = getIDPathFromXMLNode(temprowNode);
        var isloaded = channel3dplay.frameElement.ENOV3DIsObjectLoaded(idPath);
        isPartShow = isloaded;
      }

      contentSBFrame.emxEditableTable.setBooleanColumn(temprowNode.getAttribute("id"), columnName, isPartShow ,false);
      rowsToRefresh.push(temprowNode.getAttribute("id"));
    }
  }
  if (rowsToRefresh.length > 0)
    contentSBFrame.emxEditableTable.refreshRowByRowId(rowsToRefresh,true);
}

 function showhide(idLevel)
 {
        var rowNode = null;
	var oXML = null;
	//var contentSBFrame  = findFrame(getTopWindow(), "WorkspaceContent");

	if(!contentSBFrame)
	{
					return true;
	}
	else
	{
					oXML    = contentSBFrame.oXML;
	}
	//var myFrame = findFrame(getTopWindow(), "Workspace3DViewer");
	//add below line to register callback with 3dplay
	//New method added by Ronan to check if cb is already registered or not
	var vIsCBRegistered = channel3dplay.frameElement.ENOV3DIsCenterTreeCBRegistered();
//	alert(vIsCBRegistered);
	if(!vIsCBRegistered){
		//alert('to register');
		//channel3dplay.frameElement.ENOV3DAddSelectCB(cbFunction);
		channel3dplay.frameElement.ENOV3DAddCenterTreeCB(centerGraphFun);
	}

	var vIsCB2Registered = channel3dplay.frameElement.ENOV3DIsSelectCBRegistered();
//	alert(vIsCB2Registered);
	if(!vIsCB2Registered){
		//alert('to register');
		channel3dplay.frameElement.ENOV3DAddSelectCB(cbFunction);
//		channel3dplay.frameElement.ENOV3DAddSelectCB(centerGraphFun);
	}


	rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + idLevel + "']");
	var idPath = getIDPathFromXMLNode(rowNode);

	var isloaded = channel3dplay.frameElement.ENOV3DIsObjectLoaded(idPath);
	var columnName = "HideShow";
	if(isloaded)
	{
		channel3dplay.frameElement.ENOV3DUnloadStructure(idPath);
	    contentSBFrame.emxEditableTable.setBooleanColumn(rowNode.getAttribute("id"), columnName, false);
	  getChildrenFromXMLNode(rowNode, false,true);
	}
	else
        {
		channel3dplay.frameElement.ENOV3DLoadStructure(idPath);
	    contentSBFrame.emxEditableTable.setBooleanColumn(rowNode.getAttribute("id"), columnName, true);
	  getChildrenFromXMLNode(rowNode, true,true);
	}
 }

var IsEventOn3DPlay = false;
 function setIconHideShow(rowId)
 {

	if (!IsEventOn3DPlay) {
		require(["UWA/Utils/InterCom"], function(InterCom){
			var socket = new InterCom.Socket();
			socket.subscribeServer('enovia.bus.server', getTopWindow());
			socket.addListener('Load3DData', function (data) {
				var pathArray = data.path.split("/");
				var row = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o = '" + pathArray[0] + "']");
				emxEditableTable.setBooleanColumn(row.getAttribute("id"), columnName, true);
			});
			socket.addListener('Unload3DData', function (data) {
				var pathArray = data.path.split("/");
				var row = null;
				if (pathArray.length == 1) {
					row = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o = '" + pathArray[0] + "']");
				} else {
					row = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@r = '" + pathArray[pathArray.length - 1] + "']");
				}
				emxEditableTable.setBooleanColumn(row.getAttribute("id"), columnName, false);
			});
		});
		IsEventOn3DPlay = true;
	}

	var rowNode = null;
	var oXML = null;
	//var contentSBFrame  = findFrame(getTopWindow(), "WorkspaceContent");

	if(!contentSBFrame)
	{
					return true;
	}
	else
	{
					oXML    = contentSBFrame.oXML;
	}
	//var channel3dplay = findFrame(getTopWindow(), "Workspace3DViewer");

	var columnName = "HideShow";
	var colValue = contentSBFrame.emxEditableTable.getBooleanColumn(rowId, columnName);
	if (colValue == "none") {
		return true;
	}

	rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
	var idPath = getIDPathFromXMLNode(rowNode);
	var isloaded = channel3dplay.frameElement.ENOV3DIsObjectLoaded(idPath);
	if(isloaded)
	{
		contentSBFrame.emxEditableTable.setBooleanColumn(rowId, columnName, true, false);
		getChildrenFromXMLNode(rowNode, true);
	}
	else
	{
		contentSBFrame.emxEditableTable.setBooleanColumn(rowId, columnName, false, false);
		getChildrenFromXMLNode(rowNode, false);
	}

 }

function CheckBadNameCharsTMC()
  {

  var isBadNameChar=checkForNameBadCharsListTMC(this);
       if( isBadNameChar.length > 0 )
       {
         alert(BAD_NAME_CHARS + isBadNameChar);
         return false;
       }
        return true;
  }

 function checkForNameBadCharsListTMC(objField){
//variable listing bad chars for Name fiels - to be updated as per DEC GCO information
	var STR_FILE_NAME_BAD_CHARS = "\\\ \" # $ @ % * , ? \\\\ < > [ ] | :";
  	var ARR_NAME_BAD_CHARS_TMC = "";
  	if (STR_FILE_NAME_BAD_CHARS != "")
  	{
  		ARR_NAME_BAD_CHARS_TMC = STR_FILE_NAME_BAD_CHARS.split(" ");
  	}
        return checkFieldForCharsTMC(objField, ARR_NAME_BAD_CHARS_TMC, true);
}
 function checkFieldForCharsTMC(objField, arrBadChars, blnReturnAll){
        var strResult = checkStringForCharsTMC(objField.value, arrBadChars, blnReturnAll);
        if (strResult.length > 0) {
                objField.focus();
        }
        return strResult;
}
function checkStringForCharsTMC(strText, arrBadChars, blnReturnAll){
        var strBadChars = "";

        for (var i=0; i < arrBadChars.length; i++) {
                if (strText.indexOf(arrBadChars[i]) > -1) {
                        strBadChars += arrBadChars[i] + " ";
                }
        }

        if (strBadChars.length > 0) {
                if (blnReturnAll) {
                        return arrBadChars.join(" ");
                } else {
                        return strBadChars;
                }
        } else {
                return "";
        }
}

function nameRMB(oid){
	var forwardUrl = "../common/emxTree.jsp?treeRefreshMenu=refreshFalse&aloid=true&AppendParameters=true&mode=insert&objectId=" + oid;
	forwardUrl += "&treeMenu=FMAtype_Folder";
	var cntFrame = emxUICore.findFrame(getTopWindow(),'content');
	cntFrame.location.href = forwardUrl;
}

function nameLinkClick(colNum,oid,relId,parentId,linkName){
	var frameHandle = emxUICore.findFrame(getTopWindow(),'WorkspaceContent');
	var oXM = frameHandle.sbPage.oXML;
	var tRow = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '"+oid.trim()+"']");
	var objColumn = colMap.getColumnByName("Type");
	var col = emxUICore.selectSingleNode(tRow, "c[" + objColumn.index + "]");
	var colType = col.getAttribute("a");
	var forwardUrl = "../common/emxTree.jsp?treeRefreshMenu=refreshFalse&aloid=true&AppendParameters=true&mode=insert&objectId=";
	forwardUrl += oid;
	forwardUrl += "&rmbid=";
	forwardUrl += oid;
	var cntFrame = emxUICore.findFrame(getTopWindow(),'content');
	if (colType == 'Document')
	{
		forwardUrl += "&treeMenu=FMAtype_Document";
		cntFrame.location.href = forwardUrl;
	}
	else if (colType == 'Workspace Vault')
	{
		forwardUrl += "&treeMenu=FMAtype_Folder";
		//cntFrame.location.href = forwardUrl;
		emxUICore.findFrame(getTopWindow(),'WorkspacePublicFolders').loadDataWithProgress('',oid,true);
    }else{
    		cntFrame.location.href = forwardUrl;
    }

}


