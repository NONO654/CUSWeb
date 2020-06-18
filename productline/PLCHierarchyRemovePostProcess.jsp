<%--
  PLCHierarchyRemovePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%--Common Include File --%>

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.productline.ProductLine"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  boolean bIsError=false;
  try
  {
	  String strLanguage        = context.getSession().getLanguage();
	  String strAlertMessage    = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.CannotPerform", strLanguage);  
	  String strRemoveProduct   = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.RemoveOperationFailure", strLanguage);
      String strTableRowIds[]   = emxGetParameterValues(request, "emxTableRowId");
      String strObjectId        = "";
      String strParentOID       = "";
      StringList relIdList      = new StringList();
      DomainObject domParentObj = null;
      DomainObject domObject    = null;
      String strObjectToRemove  = "";
      StringList lstPLIds = new StringList();
      StringList lstPLChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCT_LINE);
      StringList lstProductChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTS);
      String strContextParentOID      = emxGetParameter(request,"parentOID");
      String strFrame = "content";
      if(ProductLineCommon.isNotNull(strContextParentOID)){
   	   strFrame = "detailsDisplay";
      }
      for(int i = 0; i < strTableRowIds.length; i++)
      {
    	  StringList listOfTableRowIds = FrameworkUtil.split(strTableRowIds[i], "|");
    	  if(listOfTableRowIds.size() >= 4){
    	      strObjectId  = (String) listOfTableRowIds.get(1);
    	      strParentOID = (String) listOfTableRowIds.get(2);
    	  }
    	  else
    	  {
    		  strObjectId  = (String) listOfTableRowIds.get(0);
    		  strParentOID = (String) listOfTableRowIds.get(1);
    	  }
    	  strObjectToRemove += strObjectId +"|"+ strParentOID + "~";
    	  
    	  domObject = new DomainObject(strObjectId);
    	  StringList lstSelect = new StringList();
    	  lstSelect.add(DomainConstants.SELECT_TYPE);
    	  Map objectMap = domObject.getInfo(context, lstSelect);
    	  String strObjectType = (String) objectMap.get(DomainConstants.SELECT_TYPE);
    	  
    	  if(lstPLChildTypes.contains(strObjectType))
    	  {
    		  lstPLIds.add(strObjectId);
    	  }
          if(DomainConstants.EMPTY_STRING.equals(strParentOID) || (!ProductLineCommon.isNotNull(strParentOID))){
%>
              <script language="javascript" type="text/javaScript">
              alert("<%=strAlertMessage%>");
              </script>
<%
              return;
          }
        
          if(lstProductChildTypes.contains(strObjectType)){
%>
        	  <script language="javascript" type="text/javaScript">
        	  alert("<%=strRemoveProduct%>");
        	  </script>
<%
        	  return;
          }
          
    	  domParentObj       = DomainObject.newInstance(context, strParentOID); 
    	  String objectWhere = DomainObject.SELECT_ID +"=="+ strObjectId;
    	  MapList mapRelIds  = domParentObj.getRelatedObjects(context, DomainConstants.QUERY_WILDCARD, DomainConstants.QUERY_WILDCARD, new StringList(), new StringList(DomainRelationship.SELECT_ID), false, true, (short) 1, objectWhere, new String(), 0);
		  Map     map        = (Map) mapRelIds.get(0);
		  String strRelId    = (String) map.get(DomainRelationship.SELECT_ID);
		  relIdList.add(strRelId);
      }
       
      if(relIdList != null && relIdList.size() > 0)
      {
    	  DomainRelationship.disconnect(context, (String[]) relIdList.toArray(new String[relIdList.size()]));
      }    
      
      Map connectedPLMap = null;
      if(lstPLIds.size() > 0){
      StringList lstSelect = new StringList();
      lstSelect.add("to["+ ProductLineConstants.RELATIONSHIP_SUB_PRODUCT_LINES +"].from.id");
      MapList mapList = DomainObject.getInfo(context, (String[])lstPLIds.toArray(new String[lstPLIds.size()]), lstSelect);
      connectedPLMap  = (Map)mapList.get(0);
      }
      if(connectedPLMap != null && connectedPLMap.size() == 0 && !ProductLineCommon.isNotNull(strContextParentOID)){
%>
          <script language="javascript" type="text/javaScript">
          var varFrame        = "<%=strFrame%>";
          var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
          contentFrameObj.editableTable.loadData();
          contentFrameObj.rebuildView();
          </script>
<%        	  

     }
     else{
%>      
         <script language="javascript" type="text/javaScript">
         var varFrame            = "<%=strFrame%>";
         var contentFrameObj     = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
         var oXML                = contentFrameObj.oXML;
         var varObjectToRemove   = "<%=XSSUtil.encodeForJavaScript(context,strObjectToRemove)%>";	
         var arrObjectToRemove   = new Array();
         arrObjectToRemove       = varObjectToRemove.split("~");
         var selectedRowIds       = new Array(arrObjectToRemove.length-1);
         
         for(var i = 0; i < arrObjectToRemove.length-1; i++)
         {	  
          var varSelRows   = new Array();
          varSelRows       = arrObjectToRemove[i].split("|");
   	      var selectedRow  = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + varSelRows[0] + "' and @p = '" + varSelRows[1] + "']");
   	      
   	      var oId = selectedRow[0].attributes.getNamedItem("o").nodeValue;
   	      var rId = selectedRow[0].attributes.getNamedItem("r").nodeValue;
   	      var pId = selectedRow[0].attributes.getNamedItem("p").nodeValue;
   	      var lId = selectedRow[0].attributes.getNamedItem("id").nodeValue;
   	      var rowIds = rId+"|"+oId+"|"+pId+"|"+lId;
   	      
   	      selectedRowIds[i] = rowIds;
         }
         contentFrameObj.emxEditableTable.removeRowsSelected(selectedRowIds);
         
         // To Refresh Structure Tree on Remove Of Product Lines/Models/Products from Product Line >> Product Lines
         var varContextParentOID = "<%=XSSUtil.encodeForJavaScript(context,strContextParentOID)%>";
         if(varContextParentOID != "null" && varContextParentOID != ""){
           for(var j = 0; j < arrObjectToRemove.length-1; j++)
           {
        	  var varSelRowsToRemove = new Array();
        	  varSelRowsToRemove     = arrObjectToRemove[j].split("|");
        	  var objectId = varSelRowsToRemove[0];
      		  var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
      		  contentFrame.deleteObjectFromTrees(objectId, false); 
           }
         }
         </script>
<%	 
     }
  }
  catch(Exception e)
  {
	  bIsError=true;
	  session.putValue("error.message", e.getMessage());	  
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
