<%--
  GBOMDisconnectPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<html>
<head>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
</head>
<%
String strMode = emxGetParameter(request,"mode");
if(strMode!=null  && strMode.equalsIgnoreCase("CustomGBOMDisconnect")){
	String strRelId = emxGetParameter(request, "relId");
	String parentOID = emxGetParameter(request, "parentOID");
	
	LogicalFeature logicalFTR= new LogicalFeature(parentOID);
	StringList slRemoveRelIds= new StringList(strRelId);	
	logicalFTR.removeGBOM(context,slRemoveRelIds);
}
else{
  try
  {
     //this will be logical feature
     String strObjId = emxGetParameter(request, "objectId");
     //get the selected Objects from the Full Search Results page
     String[] strContextObjectId    = emxGetParameterValues(request, "emxTableRowId");
     //If the selection is empty given an alert to user
     boolean bFlag = false;
     if(strContextObjectId==null){   
     %>    

       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%
     }
     //If the selection are made in Search results page then     
     else{
              LogicalFeature logicalFTR= new LogicalFeature(strObjId);
              String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
              String arrRelIds[] = null;
              String arrObjectIds[] = null;
              String selectedGBOMID = "";
              Map mapFromTree = (Map)ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
              arrRelIds = (String[])mapFromTree.get("RelId");
              arrObjectIds = (String[])mapFromTree.get("ObjId");
              StringList slRemoveRelIds= new StringList();
              /* StringList relationshipSelect = new StringList("id");
                  relationshipSelect.addElement(ConfigurationConstants.SELECT_ID);   */
              for(int i=0;i<arrRelIds.length;i++){
                  StringTokenizer st = new StringTokenizer(arrRelIds[i],"|");
                  String selectedGBOMRelID = st.nextToken();
                  //slRelIds.add(selectedGBOMRelID);
                  /* StringTokenizer st1 = new StringTokenizer(arrRelIds[i],"|");
                  selectedGBOMID = st1.nextToken();                  
                  ProductLineCommon PL = new ProductLineCommon();
                  MapList mLRERelId = PL.queryConnection(context,
                                  ConfigurationConstants.RELATIONSHIP_PRECISE_BOM,
                                  relationshipSelect,
                                  "torel.id=="+selectedGBOMRelID);   */
                  
                  MapList mLRERelId            = new MapList();
                  DomainRelationship domainRel = new DomainRelationship();
                  StringList strRelSelect      = new StringList();
                  strRelSelect.add("tomid["+ ConfigurationConstants.RELATIONSHIP_PRECISE_BOM +"].id");
                  DomainRelationship.MULTI_VALUE_LIST.add("tomid["+ ConfigurationConstants.RELATIONSHIP_PRECISE_BOM +"].id");
                  
                  String[] BOMRelId               = new String[1];
                  BOMRelId[0]                     = selectedGBOMRelID;
                  MapList mapListOfPreciseBOMRels = domainRel.getInfo(context, BOMRelId, strRelSelect);
                  DomainRelationship.MULTI_VALUE_LIST.remove("tomid["+ ConfigurationConstants.RELATIONSHIP_PRECISE_BOM +"].id");
                  Map mapOfPreciseBOMRel          = (Map) mapListOfPreciseBOMRels.get(0);
                  Object objectOfPreciseBOMRel    = mapOfPreciseBOMRel.get("tomid["+ ConfigurationConstants.RELATIONSHIP_PRECISE_BOM +"].id");
                  StringList listOfPreciseBOMRel  = new StringList();
                  if(objectOfPreciseBOMRel instanceof List){
                  listOfPreciseBOMRel = (StringList) objectOfPreciseBOMRel;	  
                  }else if(objectOfPreciseBOMRel instanceof String){
                  listOfPreciseBOMRel.add(objectOfPreciseBOMRel.toString());
                  }
                  
                  for(int j = 0; j < listOfPreciseBOMRel.size(); j++)
                  {
                	  Map mapOfObject = new HashMap();
                	  mapOfObject.put("RelInfo", ConfigurationConstants.RELATIONSHIP_PRECISE_BOM);
                	  mapOfObject.put("id", listOfPreciseBOMRel.get(j));
                	  
                	  mLRERelId.add(mapOfObject);
                  }  
                  
                  if(mLRERelId.size()>0)
                  {
                	  bFlag = logicalFTR.inactiveGBOM(context,selectedGBOMRelID);
                      
                      
                  }else
                  {
                      slRemoveRelIds.addElement(selectedGBOMRelID);
                  }
              }
              if(slRemoveRelIds.size()>0){
            	  if("GBOMDisconnectFromDuplicate".equals(strMode)){
            		  try{
            			  ContextUtil.startTransaction(context, true);
            		  	  bFlag = logicalFTR.removeGBOMForDuplicate(context,slRemoveRelIds);
            		  	  logicalFTR.deltaUpdateDuplicatePartXML(context,slRemoveRelIds,strObjId);
            		      ContextUtil.commitTransaction(context);
            		  }
            		  catch(Exception e){
            			  ContextUtil.abortTransaction(context);
            			  throw new FrameworkException(e.getMessage());
            		  }
            	  }else{
               bFlag = logicalFTR.removeGBOM(context,slRemoveRelIds);
              }
              }
              if (bFlag)
              { 
              %> 
                  <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
                  <script language="javascript" type="text/javaScript">
                  <%
                  if("FTRGBOMViewDuplicatePartsTable".equals(emxGetParameter(request,"table")))
                  {  
                	  
                      %>                      
                      	//parent.getTopWindow().getWindowOpener().getTopWindow().location.href = parent.getTopWindow().getWindowOpener().getTopWindow().location.href;                      	                 	
                      	var strObjId = '<%=XSSUtil.encodeForJavaScript(context,selectedGBOMID)%>';
                        var contentFrameObj = openerFindFrame(getTopWindow(), "FTRProductContextGBOMPartTable");
                        if(contentFrameObj==null)
                            contentFrameObj =findFrame(getTopWindow(), "FTRContextGBOMPartTable");
                        if(contentFrameObj==null)
                            contentFrameObj =parent;                       
                        var temp = "/mxRoot/rows//r[@o ='" + strObjId + "']";
                        var derivedToRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,temp);        
                        var oId = derivedToRow.attributes.getNamedItem("o").nodeValue;
                        var rId = derivedToRow.attributes.getNamedItem("r").nodeValue;
                        var pId = derivedToRow.attributes.getNamedItem("p").nodeValue;
                        var lId = derivedToRow.attributes.getNamedItem("id").nodeValue;
                        var parentRowIDs = rId+"|"+oId+"|"+pId+"|"+lId;
                        var prentRowIds = new Array(1);
                        prentRowIds[0] = parentRowIDs;                        
                        contentFrameObj.emxEditableTable.removeRowsSelected(prentRowIds);                        
                        if(null != getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().emxEditableTable){
                     		getTopWindow().getWindowOpener().emxEditableTable.removeRowsSelected(prentRowIds);                     	
                        	getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort();
                        }
                      	parent.location.href = parent.location.href;
                      <%  
                	  
                  }else
                  {
                	  for(int i=0;i<arrRelIds.length;i++){
                          StringTokenizer st1 = new StringTokenizer(arrRelIds[i],"|");
                          selectedGBOMID = st1.nextToken();
                  %>
                       var strObjId = '<%=XSSUtil.encodeForJavaScript(context,selectedGBOMID)%>';
                       var contentFrameObj =findFrame(getTopWindow(), "FTRProductContextGBOMPartTable");
                       if(contentFrameObj==null)
                           contentFrameObj =findFrame(getTopWindow(), "FTRContextGBOMPartTable");
                       if(contentFrameObj==null)
                           contentFrameObj =parent;                       
                       var temp = "/mxRoot/rows//r[@r ='" + strObjId + "']";
                       var derivedToRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,temp);        
                       var oId = derivedToRow.attributes.getNamedItem("o").nodeValue;
                       var rId = derivedToRow.attributes.getNamedItem("r").nodeValue;
                       var pId = derivedToRow.attributes.getNamedItem("p").nodeValue;
                       var lId = derivedToRow.attributes.getNamedItem("id").nodeValue;
                       var parentRowIDs = rId+"|"+oId+"|"+pId+"|"+lId;
                       var prentRowIds = new Array(1);
                       prentRowIds[0] = parentRowIDs;
                       contentFrameObj.emxEditableTable.removeRowsSelected(prentRowIds);   
					   // it was usecase with duplicate part-no more valid
                       //if(null != getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().emxEditableTable)
                    	//	getTopWindow().getWindowOpener().emxEditableTable.removeRowsSelected(prentRowIds);
                       var cntFrame = findFrame(getTopWindow(), "content");
                       if(cntFrame !== null && cntFrame !== undefined){
                       if(typeof cntFrame.deleteObjectFromTrees !== 'undefined' && 
                       		typeof cntFrame.deleteObjectFromTrees === 'function')
                       	{
                       		cntFrame.deleteObjectFromTrees(oId, false);
                       	}
                       }
                  <%
                	  }
                  }
                  %>        
                  </script>
              <%
              }
      }
  }catch(Exception e){
      %>
      <script language="javascript" type="text/javaScript">
       alert("<%=XSSUtil.encodeForJavaScript(context,e.getMessage())%>");                 
      </script>
      <%    
}
  
}

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

