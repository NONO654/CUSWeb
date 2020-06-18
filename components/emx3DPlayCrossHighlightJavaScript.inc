
<%
	String selectHandler3dPlay     = (String)emxGetParameter(request, "selectHandler");
	String compare3D3dPlay = emxGetParameter(request, "3DCompare");
%>


var viewer;


function getIdPath(rowNode, matchresult) {
var children = rowNode.children;
var idPath1=[];

for(var j=0;j<children.length;j++) {
				var attr = children[j].getAttribute("a");
				if(attr!=null && typeof attr != 'undefined' && attr.contains("3dPlayKeyIdPath")){
					var tempids=attr.split(",");
					for(var k=0;k<tempids.length;k++){
					idPath1[k] = tempids[k].substring(0,attr.indexOf(":3dPlayKeyIdPath"));
					}
					if(matchresult === undefined || matchresult === "" || matchresult === "left"){
						break;	
					}				
		}
				
	}
return idPath1;
}


//To get the id path of the selected item in SB for 3D Live Examine selection
function  getIDPathFromXMLNode3DPlay(rowNode, matchresult){
	var parentRows = emxUICore.selectNodes(rowNode, "ancestor::r");
  
	var idPath = (parentRows.length != 0) ? "" : getIdPath(rowNode, matchresult);
	var finalidPath=[];
	for (var i = 0; i < parentRows.length; i++) {
  		idPath += getIdPath(parentRows[i], matchresult)+"/";
	}
  
	if(parentRows.length != 0){
	var childidPath = getIdPath(rowNode, matchresult);
	
	//added empty check for non-synched parts
		if(childidPath==""){
			idPath="";
			finalidPath[0]=idPath;
		 }else{
	
		 for(var k=0;k<childidPath.length;k++){
	
	 		finalidPath[k]=idPath+childidPath[k];
	}
  
  
		 }
	}else{
		idPath+="";
		finalidPath[0]=idPath;
	}
   	return finalidPath;
}

function subscribe(curViewer, status) {
	
	
	if (curViewer != undefined)	
		viewer = curViewer;
	if (viewer != undefined) {
		
		if(status)
			viewer.addSelectionCB(selectCB);
		else
			viewer.removeSelectionCB(selectCB);	
	}			

	window.parent.subsObj.selectCBAddToken = selectCB.onAddToken;
	window.parent.subsObj.selectCBRemoveToken = selectCB.onRemoveToken;
	
}





function checkParent(id,oXML){
	var ids = id.split("/");
	if(ids[ids.length-1]==""){
		ids.pop();
	}
	var path ="";
	var ids1 =[];
	
		
	var checkObject = null;
	for(var p =ids.length-1;p>0;p--){
		var relObId = ids[p-1]+"/"+ids[p];
		var checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r//c[contains(text(),'"+relObId+":3dPlayKeyIdPath')]/parent::r");
		
		if(checkObject!=null){
		break;
	}
	
		p=p-1;

	}
	
	return checkObject;
}



//To get the id path of the selected right side item in SB for 3D Live Examine selection in compare for common items
function getIDPathFromXMLNodeRight(rowNode){
	var parentRows = emxUICore.selectNodes(rowNode, "ancestor::r");
    
	var idPath = (parentRows.length != 0) ? "" : getIdPath(rowNode);
	
    for (var i = 0; i < parentRows.length; i++) {
  		idPath += getIdPath(parentRows[i])+"/";
    }
    
	idPath += (parentRows.length != 0) ? getIdPath(rowNode) : "";
    
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


	
function toggleSelect3DPlay(viewer, flag, idPath) {
	
	if(flag) {
		viewer.selectNode(idPath);		
	
	}else {
		viewer.unselectNode(idPath[0]);		
	}
	
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

function getFinalSBFrame3DPlay() {

	if(window.parent.compare3D1) {

		if(finalResultsFrame == "" || findFrame(getTopWindow(), finalResultsFrame).frameElement.parentElement.style.display != "") {
			finalResultsFrame = getCompareResultsFrameName();
		}
		return findFrame(getTopWindow(), finalResultsFrame);				
				
	} else {

		var visibleFrame = findFrame(getTopWindow(),"detailsDisplay");
		return findFrame(visibleFrame,"listHidden").parent;

	}


}


function selectCB(CSOaction, idPathTable) {
	
	
	selectInSB(idPathTable,CSOaction);
	
}

function getPosition(str, m, i) {
   return str.split(m, i).join(m).length;
}

var viewerSelect =false;
function selectInSB(idPath1, EventName)
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
		sbFrame = getFinalSBFrame3DPlay();
		if(!sbFrame) {
			return true;
		}
		oXML 	= sbFrame.oXML;
	}
	
	for(var k = 0; k<idPath1.length;k++){
	
	idPath 	= idPath1[k];
	tempArr = idPath.split("/");
	strRel 	= tempArr[tempArr.length-1];
	
	var id="";
	var ids= []
					
	if(EventName == "REMOVE"){
	if(sbSelected.length>0) {
		
		
		var found = $.inArray(idPath1[k], sbSelected) > -1;
		
		if(found) {
			for(var i=0;i<tempArr.length;i++) {
					id+=tempArr[i]+"/";
					ids.push(tempArr[i]);
			}
			var index = sbSelected.indexOf(idPath1[k]);
				if (index > -1) {
    				sbSelected.splice(index, 1);
				}
		}else {
		for(var i=0;i<tempArr.length-2;i++) {
			id+=tempArr[i]+"/";
				ids.push(tempArr[i]);
		}
		}
		
	}
	else {
		
		for(var i=0;i<tempArr.length-2;i++) {
			id+=tempArr[i]+"/";
				ids.push(tempArr[i]);
		}
	}
	}else {
	
	
	for(var i=0;i<tempArr.length-2;i++) {
			id+=tempArr[i]+"/";
			ids.push(tempArr[i]);
		}
		
		
		
	
	}
					
	id = id.substring(0,id.lastIndexOf("/"));
	var ids3 = id.split("/");
	var relObId ="";
	if(ids3.length==1){
		checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r//c[text()='"+ids3+":3dPlayKeyIdPath']/parent::r");
	}else {
	var n = id.split("/").length-1;			
	relObId  = id.substring(getPosition(id,"/",n-1)+1,id.length); 
	checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r//c[contains(text(),'"+relObId+":3dPlayKeyIdPath')]/parent::r");
	}
					
	
	var parent;
	var nSelRow = checkObject;
	if(sbFrame.isStructureCompare != "TRUE") { 
		var flag=true;
		var varId = id;
		while(flag){
			if(checkObject == null || typeof checkObject =='undefined') {
			
				parent = checkParent(id,oXML);
					if(parent == null || (typeof parent == 'undefined')){
					flag = false;
					}
				
				var expandRow = parent;
				if(expandRow != null) {
					var expandC = expandRow.getAttribute("expand");
					if(expandC == null || (typeof expandC == 'undefined')){
						var parentLevel = expandRow.getAttribute("level");
						var parentRowIdArr = new Array();
						parentRowIdArr[0] = expandRow.getAttribute("id");
						sbFrame.emxEditableTable.expand(parentRowIdArr, parentLevel);
					} else if(expandC == 'true') {
								expandRow.setAttribute("display","block");
								flag=false;
					}
	
					checkObject =emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r//c[contains(text(),'"+relObId+":3dPlayKeyIdPath')]/parent::r");
				}
			} else {
							
				flag=false;
			}
	
		}
	}
	
		if(checkObject != null && checkObject != "" && typeof checkObject != 'undefined'){
		var nSelRowId = checkObject.getAttribute("id");
		}else{
			require(['DS/UIKIT/Alert'], function (Alert) {
									var myAlert = new Alert({
										closable: true,
										visible: true,
										autoHide: true
									}).inject(getTopWindow().document.body, 'top');
									myAlert.add({ className: "error", message: "EBOM not synched!" });
								});
								return;
		}
		if (EventName == "ADD") {
			tempAddRowIds[addCounter++] = nSelRowId;
		} else if (EventName == "REMOVE") {
			tempDelRowIds[deleteCounter++] = nSelRowId;
		}
		if(tempDelRowIds.length > 0) {
			
			sbFrame.emxEditableTable.unselect(tempDelRowIds, false);
			viewerSelect=true;
		}
		if(tempAddRowIds.length > 0) {
			sbFrame.emxEditableTable.select(tempAddRowIds, false);
			viewerSelect=true;
		}
	}
	return true;
}
  	
