<%--  EBOMFloat.jsp -  This JSP used for all the util functionalities related to BOM Float functionality.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@page import="com.matrixone.json.JSONObject"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>


<jsp:useBean id="floatOnEBOM" class="com.matrixone.apps.engineering.EBOMFloat" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%!

private String updateGlobalObjectListCache(Context context,Map tableData,Map relObjMap,String[] tableRowId) 
{	         
     TreeMap indexedObjectList = (TreeMap)tableData.get("IndexedObjectList");
     StringList tempList 	   = new StringList();
     
	 int iRowSize  = tableRowId.length; String relId,objectId,rowId;
	 String rowObjectIdsInfo = "";
	 for (int i = 0; i < iRowSize; i++) 
	 {
	     	tempList = FrameworkUtil.split(tableRowId[i], "|");
	     	
	     	relId	 = (String) tempList.get(0);
	     	objectId = (String) tempList.get(1);
	     	rowId    = (String) tempList.get(3);
			
	     	if(relObjMap.containsKey(relId)) {
	     		 objectId 	  = (String)relObjMap.get(relId);//To place floated rev id into cache
	             Map objInfo  = (Map)indexedObjectList.get(rowId);
	             if(objInfo != null) {
	                 //objInfo.put("id[connection]", relId); Not required
	                 objInfo.put("id", objectId);
	                 objInfo.put("OBJECTID_REPLACED", "TRUE");
	                 rowObjectIdsInfo = (rowObjectIdsInfo.length() > 0 ) ? rowObjectIdsInfo+"~"+rowId+"|"+objectId : rowId+"|"+objectId;
	             }
	        }
	 }
	 return rowObjectIdsInfo;
}
     

%>

<html>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script>

function isValidFrame(frameEle) {
        return (frameEle == null || frameEle == undefined || frameEle.location.href.indexOf("about:blank")>-1) ? false : true;
 }
 
function getValidFrame(frameToSearchWithIn,frameName) {         
        var reference   = findFrame(frameToSearchWithIn,frameName);

        if(!isValidFrame(reference)) {
                var portalFrame = findFrame(frameToSearchWithIn,"detailsDisplay")?findFrame(frameToSearchWithIn,"detailsDisplay"):findFrame(frameToSearchWithIn,"content") ;
                reference       = portalFrame;
        }
        return reference;
}

function processRMBRowAndCallReplaceAPIs(functionality,frameName,rowId,rmbRowData) {
	var isRevMgmt            =  "<%=floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT%>";
	var frameToSearchWithIn  = (isRevMgmt == functionality) ? getTopWindow().getWindowOpener() : getTopWindow();                    
	var frameToRefresh       = getValidFrame(frameToSearchWithIn,frameName);
	var rmbRow 				 = emxUICore.selectSingleNode(frameToRefresh.oXML,"/mxRoot/rows//r[@id='"+rowId+ "']");
	var alreadyChecked       = rmbRow.getAttribute("checked");
	if(!alreadyChecked) {
		rmbRow.setAttribute("checked", "checked");
		frameToRefresh.postDataStore(rmbRowData,"add");// In order to add emxTableRowId as hidden parameter		
	}
	
	switch (functionality) {
	    case "replaceWithLatestRevision":
	    	frameToRefresh.replaceWithLatestRevision();
	        break;
	    case "replaceWithLatestReleased":
	    	frameToRefresh.replaceWithLatestReleased();
	        break;
	    case "replaceWithSpecificRevision":
	    	frameToRefresh.replaceWithSpecificRevision();
	        break;
	   }
	if(!alreadyChecked) {
			rmbRow.setAttribute("checked", "");
			frameToRefresh.postDataStore(rmbRowData,"remove");
		}
	}
   

</script>
</head>
</html>

<%
    	String functionality     = emxGetParameter(request, "functionality");
        String objectId          = emxGetParameter(request, "objectId");
        String suiteKey          = emxGetParameter(request, "suiteKey");
        String type              = emxGetParameter(request, "type");
        String isFromRMB         = emxGetParameter(request, "isFromRMB");
        String isBOMPowerview    = emxGetParameter(request, "BOMMode");
        String isWhereUsed       = emxGetParameter(request, "partWhereUsed");   
        String isFromConfigBOM   = emxGetParameter(request, "fromConfigBOM");
        String BOMViewMode   = emxGetParameter(request, "BOMViewMode");
        BOMViewMode = UIUtil.isNotNullAndNotEmpty(BOMViewMode)?BOMViewMode:"";
        String frameName         = emxGetParameter(request, "frameName");
        String timeStamp 		 = emxGetParameter(request,"timeStamp");
        if(UIUtil.isNullOrEmpty(timeStamp)){ timeStamp = emxGetParameter(request,"fpTimeStamp");}
        
        if(UIUtil.isNullOrEmpty(frameName)) {   
                frameName  = ("true".equalsIgnoreCase(isFromConfigBOM)) ? "PUEUEBOM" : ("true".equalsIgnoreCase(isWhereUsed))? "ENCWhereUsed" : "ENCBOM";       
        }
        HashMap tableData         		   = indentedTableBean.getTableData(timeStamp);
        String emxTableRowIds[]   		   = emxGetParameterValues(request, "emxTableRowId");     
        String replaceSelectedConfirmation = EnoviaResourceBundle.getProperty(context,floatOnEBOM.PROPERTY_SUITE,locale,"FloatOnEBOMManagement.Confirmation.ReplaceSelected");
        String replaceAllConfirmation      = EnoviaResourceBundle.getProperty(context,floatOnEBOM.PROPERTY_SUITE,locale,"FloatOnEBOMManagement.Confirmation.ReplaceAll");
        String selectionMandatory          = EnoviaResourceBundle.getProperty(context,floatOnEBOM.PROPERTY_SUITE,locale,"FloatOnEBOMManagement.ReplaceByRevision.selectionMandatory");
        
        String confirmation   = "";     
        String errorMessage   = "";
        MapList data = new MapList();
        Map validatedMap = new HashMap();
        Map returnMap = new HashMap();
        
        //BOM retrieval criteria
        short recurseToLevel = 1;
        boolean getFrom      = true;
        boolean getTo        = false;
        boolean latestFilterRequired = true;
        
        String refreshWholeView = "true";
        String rowObjectIdsData = "";

        //Where used criteria for getting Float data
        if(floatOnEBOM.TRUE.equalsIgnoreCase(isWhereUsed)) {

                getFrom      = false;
                getTo        = true;
                latestFilterRequired = false;
        }                                       
        
     	if ("TRUE".equalsIgnoreCase(isFromRMB)) {
         	StringList tempList  = FrameworkUtil.split( " "+emxTableRowIds[0], "|");
         	String RMBrowId      = (String) tempList.get(3);

%>
     	<script>
	//XSSOK
     		processRMBRowAndCallReplaceAPIs("<%=functionality%>","<%=frameName%>","<%=RMBrowId%>","<%=emxTableRowIds[0]%>");
     	</script>     	
<%
     	}
     	else if(floatOnEBOM.REPLACE_WITH_LATEST_REVISION.equalsIgnoreCase(functionality) || floatOnEBOM.REPLACE_WITH_LATEST_RELEASED.equalsIgnoreCase(functionality)
                                                                                                                           || floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT.equalsIgnoreCase(functionality) ) {

                                if(floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT.equalsIgnoreCase(functionality)) {
	                    	  Map tableRowDataMap =  floatOnEBOM.getTableRowDataInStringList(emxTableRowIds); 
	                          StringList srelIDs = (StringList)tableRowDataMap.get("RelId");
	                          if("Rollup".equalsIgnoreCase(BOMViewMode)){
	                        	  data =  floatOnEBOM.getTableRowMapListforRollUpData(context,emxTableRowIds);
	                          }
	                          else {
                                	data =  floatOnEBOM.getTableRowMapList(context,emxTableRowIds); // gives rowId/Obj/Rel in each map
                          	}
                        }
                        else {
                                if (emxTableRowIds == null) {//If no rows were selected hit the db, get all the data

                                        //In case of where used, criteria will differ
                                        data = floatOnEBOM.getBOMFloatData(context,objectId,recurseToLevel, getFrom, getTo,latestFilterRequired);
                                }
                                else {
                                        Map tableRowDataMap =  floatOnEBOM.getTableRowDataInStringList(emxTableRowIds); // Gives rowId/Obj/Rel in Stringlist format
                                        StringList srelIDs = (StringList)tableRowDataMap.get("RelId");
                                        if("Rollup".equalsIgnoreCase(BOMViewMode)){
                                        	data = floatOnEBOM.getRelFloatData(context,floatOnEBOM.getRolledUpConectionIDList(context, srelIDs));
                                        }else{
                                        	data = floatOnEBOM.getRelFloatData(context,(StringList)tableRowDataMap.get("RelId"));
                                        }
                                }                               
                        }
                        
                        validatedMap = floatOnEBOM.validateData(context,data,functionality);
                        errorMessage = (String)validatedMap.get(floatOnEBOM.ERROR_MESSAGE);
                        //If no errors, then proceed for update
                        if(UIUtil.isNullOrEmpty(errorMessage)) {
                        	returnMap = floatOnEBOM.updateBOM(context,data);
                        	
                        	//Need this below one as if loop instead else loop for replace with selected revision refresh cases
                        	if(UIUtil.isNotNullAndNotEmpty((String)returnMap.get(floatOnEBOM.ERROR_MESSAGE)))  {
                        		refreshWholeView = "doNothing";//Error case dont refresh whole view instead just provide error notice
                        		errorMessage = (String)returnMap.get(floatOnEBOM.ERROR_MESSAGE);
%>
								<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%                        		
                        	}                        	
                        	else if(UIUtil.isNullOrEmpty((String)returnMap.get(floatOnEBOM.ERROR_MESSAGE)) && (emxTableRowIds != null && !floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT.equalsIgnoreCase(functionality)) && ("ENG".equalsIgnoreCase(isBOMPowerview) || "true".equalsIgnoreCase(isFromConfigBOM))) {
                        		refreshWholeView = "false";                        		
                        		rowObjectIdsData = updateGlobalObjectListCache(context,(Map)tableData,(Map)returnMap.get("FLOATED_DATA"),emxTableRowIds);                        		
                        	}                        	
                        }
%>      
                        <script>        
                        var message         = "<xss:encodeForJavaScript><%=errorMessage%></xss:encodeForJavaScript>";
                        //XSSOK
                        var functionality   = "<%=functionality%>";
			//XSSOK
                        var frameName       = "<%=frameName%>";                        
                        
                        var isRevMgmt            =  "<%=floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT%>";
                        var frameToSearchWithIn  = (isRevMgmt == functionality) ? getTopWindow().getWindowOpener() : getTopWindow();                    
                        var frameToRefresh               = getValidFrame(frameToSearchWithIn,frameName);
                        if(message != null && message != "null" && message != "") {
                                alert(message);
                        }
                        else {
                                //frameToRefresh.emxEditableTable.refreshStructureWithOutSort();
                                if("<%=refreshWholeView%>" === "true") {                                	
                                	frameToRefresh.document.location.href = frameToRefresh.document.location.href;	
                                }
                                //else {
                                if("<%=refreshWholeView%>" === "false") {	
				//XSSOK	
                                    var rowObjectIdsData = "<%=rowObjectIdsData%>";
                                    if(rowObjectIdsData != "" && (typeof rowObjectIdsData != 'undefined')) {
                                		var rowIdObjectIDsArr = rowObjectIdsData.split("~");
                                	    var objectId,sourceIdx,rowId,rowIdObjectID,tRow;
                                	    var rowIdArr = new Array();
                                		for(var i = 0; i < rowIdObjectIDsArr.length; i++) {
                                		  rowIdObjectID = rowIdObjectIDsArr[i];
                                		  sourceIdx     = rowIdObjectID.indexOf("|");
                                		  rowId         = rowIdObjectID.substring(0,sourceIdx);
                                		  objectId      = rowIdObjectID.substring(sourceIdx+1,rowIdObjectID.length);
                                		  tRow 			= frameToRefresh.emxUICore.selectSingleNode(frameToRefresh.oXML,"/mxRoot/rows//r[@id='"+rowId+"']");
                                		  tRow.setAttribute("o", objectId);
                                		  rowIdArr[i]= tRow.getAttribute("id");
                                	    }
                                	}	                            		                                	
                                	frameToRefresh.emxEditableTable.refreshStructureWithOutSort();
                                    if(tRow.getAttribute("expand"))
                                		frameToRefresh.emxEditableTable.expand(rowIdArr);
                                }                                 
                                if(isRevMgmt == functionality) {
                                        getTopWindow().closeWindow(); 
                                }
                        }
                        frameToRefresh.toggleProgress("hidden");
                        </script>
<%              
   }    
    else if(floatOnEBOM.REPLACE_WITH_SPECIFIC_REVISION.equalsIgnoreCase(functionality) || floatOnEBOM.REPLACE_WITH_SPECIFIC_REVISION_FOR_ALL.equalsIgnoreCase(functionality)) {         
        
                if (emxTableRowIds == null) {
                //If no rows were selected hit the db, get all the data                         
                        data = floatOnEBOM.getBOMFloatData(context,objectId,(short)0, getFrom, getTo,latestFilterRequired); // replaceWithSpecificRevisionForAll not available for where used
                }
                else {
                        Map tableRowDataMap =  floatOnEBOM.getTableRowDataInStringList(emxTableRowIds); // Gives rowId/Obj/Rel in Stringlist format
						data = floatOnEBOM.getRelFloatData(context,(StringList)tableRowDataMap.get("RelId"),(StringList)tableRowDataMap.get("RowId"),true);
                }                               
        
        String jsonRevData    = floatOnEBOM.getJSONData(context,data);
        String sortColumnName = XSSUtil.encodeForURL(context,PropertyUtil.getSchemaProperty(context,"attribute_FindNumber"));           
                        
        String urlToOpen   = "../common/emxIndentedTable.jsp?program=enoFloatOnEBOM:getRevisionSummary&BOMViewMode="+BOMViewMode+"&frameName="+frameName+"&selectHandler=toggleSelectionInRevMgmt&sortColumnName="+sortColumnName+",Revision&suiteKey=EngineeringCentral&cancelLabel=emxEngineeringCentral.Button.Cancel&submitLabel=emxEngineeringCentral.Button.Submit&callbackFunction=submitFromRevisionManagement&portalMode=false&HelpMarker=emxhelpselectanyrevision&launched=false&table=ENCRevisionManagement&header=FloatOnEBOMManagement.Header.RevisionManagement&selection=multiple&massPromoteDemote=false&editRootNode=false&customize=true&displayView=details&revisionData="+ XSSUtil.encodeForURL(context, jsonRevData);
%>

                <script>                                                                                
                getTopWindow().showModalDialog("<%=XSSUtil.encodeForJavaScript(context, urlToOpen)%>", "570","570","true");                
                </script>
<%              
        
    }
%>      


                        
                
                



