 <%--  DMCPlanningValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.

   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
 --%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
//Added for IR-030712V6R2011
function toolTip(visibilityFlag, id)
{
    var layerDiv = document.getElementById(id);
    if(visibilityFlag)
        {
            layerDiv.style.visibility = "visible";
        }
    else
    {
       layerDiv.style.visibility = "hidden";
    }
       
 }
 
 
function updatedPreferredValueApply()
{
	var totalRows = getTopWindow().window.aDisplayRows.length;
	var allIds = [];
	var requiredIDs = [];
	var c = 0;
	
	for(var a = 0; a < totalRows; a++)
		{
				allIds[a] = getTopWindow().window.aDisplayRows[a].getAttribute("id");
		}
	
	for(var b = 0; b < allIds.length; b++)
		{
			var id1 = allIds[b];
			var split = id1.split(",");
			if(split.length == 2)
			{
				requiredIDs[c] = allIds[b];
				c++;
			}
		}
	var temp = 0;
	var id = [];
	var values = [];

	for(var d = 0; d < requiredIDs.length; d++)
		{
			id = getTopWindow().window.emxEditableTable.getChildrenRowIds(requiredIDs[d]);
			if(id == null)
			{
				break;
			}
	
	for( var i = 0; i < id.length; i++)
		{
			values[i] = getTopWindow().window.emxEditableTable.getCellValueByRowId(id[i],8).value.current.actual;
			if("Yes"==values[i])
			{
				temp++;
			}
		}
	
	if(temp==0)
	{
		var msg = "<%=i18nStringNowUtil("DMCPlanning.Alert.PreferedValue","dmcplanningStringResource",context.getSession().getLanguage())%>";
		return msg;
	}
	temp = 0;
	}

	return "";
 
} 


function updatedPreferredValue(){
 	var columnVals = getActualPreferedOptionValue();
 	var length = columnVals.length;
  	if(currentCell.target){
  	var rmbrow = currentCell.target.getAttribute("rmbrow");
    var strText1= [];
	strText1 = rmbrow.split(",");
	var l1 = strText1[2];
    columnVals[l1]=trim(arguments[0]);
  	var flag = false;
  	var temp1=0;
  	for(var i = 0; i< columnVals.length ; i++){
    	if("Yes"==columnVals[i]){
      		temp1++;
      		if(temp1>=2){
       			flag=true;
       			break;
      		}
    	}
   }
   if (flag) {
       alert("<%=i18nStringNowUtil("DMCPlanning.Alert.PreferedValueConfirm","dmcplanningStringResource",context.getSession().getLanguage())%>");
       return false;
      } 
 	}
  
  return true;
}
 
 
 function updateXMLByRowId(rowId,xmlCellData,columnId){
    var oldColumn = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id = '" + rowId + "']/c["+columnId+"]");
    var row = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id = '" + rowId + "']");
    var objDOM = emxUICore.createXMLDOM();
    objDOM.loadXML(xmlCellData);
    row.replaceChild(objDOM.documentElement,oldColumn);
}


function updatePostXMLByRowId (newColumn,columnNo,colVal)
{  
  var uid = currentRow.getAttribute("id");  
  var row = emxUICore.selectSingleNode (oXML.documentElement, "/mxRoot/rows//r[@id = '" + uid + "']");  
  updateXMLByRowId(uid,newColumn,columnNo);
  updatePostXML (row,colVal,columnNo);
}


/**
 * Send an array of values for the current nodes
 * sibling nodes
 */
function getActualPreferedOptionValue(){
    var level = currentRow.getAttribute("level");
    var xpath = "r";
    var aRowsAtLevel = null;
    if (level == "0") {
        aRowsAtLevel = emxUICore.selectNodes(oXML, "/mxRoot/rows/r");
    } else {
        aRowsAtLevel = emxUICore.selectNodes(currentRow.parentNode, "r");
    }

    fillupColumns(aRowsAtLevel, 0, aRowsAtLevel.length);

    var colIndex = currentColumnPosition;
    //if(isIE){colIndex--};

    var returnArray = new Array();
    for(var i=0;i < aRowsAtLevel.length; i++){
        if(emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("edited")=="true") 
        returnArray[i] = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("newA");
        else
        returnArray[i] = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("a");
    }
    return returnArray;
}

function refreshParentwindowInManufacturingPlan()
{
      var listFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),'CFPProductManufacturingPlanComposition');
      if(listFrame==null)
       listFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),'detailsDisplay');
      listFrame.editableTable.loadData();
      listFrame.rebuildView();
      getTopWindow().location.href = getTopWindow().location.href;
}
//this function is used to update Cellvalue in the DesignEffectivitymatrix
function refreshParentCellValue(objid,colid,cellvalue)
{
	 var strCelValue = cellvalue;
     var parentFrametoUpdate = findFrame(getTopWindow().getWindowOpener().getTopWindow(),'content');
     var tRow;
     if(isEdge){
          var xmlDoc = parentFrametoUpdate.oXML.xml;
          var parser=new DOMParser();
          var xmlObj=parser.parseFromString(xmlDoc,"text/xml");
          tRow =emxUICore.selectSingleNode(xmlObj,"/mxRoot/rows//r[@o='"+objid+"']");
     }else{
          tRow =emxUICore.selectSingleNode(parentFrametoUpdate.oXML,"/mxRoot/rows//r[@o='"+objid+"']");
     }
 	 var objColumn = parentFrametoUpdate.colMap.getColumnByName(colid); 
	 var rowId = tRow.getAttribute("id");
	 var celValue = '<c>'+strCelValue+'</c>';
//alert("getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId" + getTopWindow().getWindowOpener().editableTable.updateXMLByRowId);
	 parentFrametoUpdate.editableTable.updateXMLByRowId(rowId,celValue,objColumn.index);

}

function checkValuesAndApply()
{
	var ta = 0;
	var index = 0;
	var colIndex = currentColumnPosition;
	var values = [];
    var idvalues = [];
    var rld = 0;
    
    var length = getTopWindow().window.content.aDisplayRows.length;    
         
    for(t = 0; t < length; t++)
    {  
    	rld = getTopWindow().window.content.aDisplayRows[index].getAttribute("id");
    	values[ta] = getTopWindow().window.content.emxEditableTable.getCellValueByRowId(rld,colIndex-1).value.current.actual;
    	idvalues[ta] = getTopWindow().window.content.emxEditableTable.getCellValueByRowId(rld,0).objectid;
    	
    	if(values[ta] == null || idvalues[ta] == null)
    		{
    			continue;
    		}
    	ta++;
    	index++;
    }
    values.shift();
    idvalues.shift();
    
    var selectids = [];
    var deselectids = [];
    var deind = 0;
    var seind = 0;
    
    for(var y = 0; y < values.length; y++)
    {
    	if(values[y] == "" ||values[y] == "Del")
    		{
    			deselectids[deind] = idvalues[y];
    			deind++;
    		}
    	if(values[y] != "" && values[y]!="Del")
    		{
    			selectids[seind] = idvalues[y] + "|" + values[y];
    			seind++;
    		}
    }
    
    var sl = selectids;
    var dl = deselectids;
    var confirmValue = false;
    var confirmmsg = "<%=i18nStringNowUtil("DMCPlanning.Alert.EditManufacturingPlanBreakdownNotInSync","dmcplanningStringResource",context.getSession().getLanguage())%> ";
    var strAction1="edit";
	var setProductId = "SetPID";
	var productId = getTopWindow().window.content.colMap.getColumnByIndex(colIndex-1).name;
	var rmbid = getTopWindow().window.content.emxEditableTable.getCellValueByRowId(0,0).objectid; // Model ID
	
	
	var urlParam = "mode=checkDesignChangeConfirm"+
            "&effectivityselections="+sl+
            "&effectivitydeselections="+dl+
            "&PRCFSParam2="+strAction1+"&ProductId="+productId+"&setProductID="+setProductId;
            var vRes = emxUICore.getDataPost("../dmcplanning/DesignEffectivityUtil.jsp", urlParam);
            //alert(vRes);
    		var iIndex = vRes.indexOf("bdesignChange=");
    		var iLastIndex = vRes.indexOf("#");
    		var bdesignChange = vRes.substring(iIndex+"bdesignChange=".length , iLastIndex );
    		if(trim(bdesignChange)== "true")
            {
					if(confirm(confirmmsg))
					{
						emxUICore.getDataPost("../dmcplanning/DesignEffectivityUtil.jsp?mode=create&PRCFSParam2="+strAction1+"&effectivityselections="+sl+
            "&effectivitydeselections="+dl+"&fromdesignmatrix=True&masterId="+rmbid);
					}
					else
					{
						//top.window.content.refreshSBTable();
						getTopWindow().window.content.resetEdits();
 	 				}
     		}
     		else
     		{
     			emxUICore.getDataPost("../dmcplanning/DesignEffectivityUtil.jsp?mode=create&PRCFSParam2="+strAction1+"&effectivityselections="+sl+
            "&effectivitydeselections="+dl+"&fromdesignmatrix=True&masterId="+rmbid);
     		}
     		
     	return "";
   }

function validateEditDesignEffectivityMAtrix()
{
	  var currentCellValue    = trim(arguments[0]);		
	  var oid = currentRow.getAttribute("o");
	  var isstateObsolete = trim(emxUICore.getData("../dmcplanning/DMCPlanningValidationProcess.jsp?objectID="+oid)); 
	
	  if(isstateObsolete=="true" && currentCellValue !="Del"){
	    alert("<%=i18nStringNowUtil("DMCPlanning.Alert.EditAndAddNotAllowedinObsolete","dmcplanningStringResource",context.getSession().getLanguage())%>");        
             return false;
	  }
 return true;
}
