<%--
  PLCHierarchyDeletePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%--Common Include File --%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import = "com.matrixone.apps.productline.ProductLine"%>
<%@page import = "com.matrixone.apps.productline.Model"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  boolean bIsError       = false;
  boolean deletedModel   = false;
  boolean deletedProduct = false;
  StringList listPLObjectIds      = new StringList();
  StringList listModelObjectIds   = new StringList();
  StringList listProductObjectIds = new StringList();
  String strContextParentOID      = emxGetParameter(request,"parentOID");
  String strFrame = "content";
  if(ProductLineCommon.isNotNull(strContextParentOID)){
	   strFrame = "detailsDisplay";
  }
  String strProductIds  = "";
  String strModelIds    = "";
  try
  {
	  String strLanguage      = context.getSession().getLanguage();
	  String strAlertMessage  = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.CannotPerform", strLanguage);  
	  String strDeleteRootNode = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.CannotPerform", strLanguage); 
      String strTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
      String strObjectId      = "";
      String strParentOID     = "";
      Model modelBean           = new Model();
      Product productBean       = new Product();
      DomainObject domParentObj = null;
      String strRowIds          = "";
      String strObjectToRemove  = "";
      StringList lstPLChildTypes      = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCT_LINE);
      StringList lstModelChildTypes   = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_MODEL);
      StringList lstProductChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTS);
      
      for(int i = 0; i < strTableRowIds.length; i++)
      {
    	  StringList listOfTableRowIds = FrameworkUtil.split(strTableRowIds[i], "|");
    	  if(listOfTableRowIds.size() >= 4){
    	      strObjectId  = (String) listOfTableRowIds.get(1);
    	      strParentOID = (String) listOfTableRowIds.get(2);
    	      strRowIds   += (String) listOfTableRowIds.get(listOfTableRowIds.size() - 1) + "~";
    	  }
    	  else
    	  {
    		  strObjectId  = (String) listOfTableRowIds.get(0);
    		  strParentOID = (String) listOfTableRowIds.get(1);
    		  strRowIds   += (String) listOfTableRowIds.get(listOfTableRowIds.size() - 1) + "~";
    	  }
    	  strObjectToRemove += strObjectId +"~";
    	  
    	  DomainObject domObject = DomainObject.newInstance(context, strObjectId);
    	  String strObjectType   = domObject.getType(context);
    	  if(lstPLChildTypes.contains(strObjectType))
    	  {
    		  listPLObjectIds.add(strObjectId);
    	  }
    	  else if(lstModelChildTypes.contains(strObjectType))
    	  {
    		  listModelObjectIds.add(strObjectId);
    		  strModelIds += strObjectId + "~";
    	  }
    	  else if(lstProductChildTypes.contains(strObjectType))
    	  {
    		  listProductObjectIds.add(strObjectId);
    		  strProductIds += strObjectId + "~";
    	  }
      }
      
      if(ProductLineCommon.isNotNull(strContextParentOID) && listPLObjectIds.contains(strContextParentOID))
      {
%>
    	  <script language="javascript" type="text/javaScript">
    	  alert("<%=strDeleteRootNode%>");
    	  </script>
<%    	  
          return;
      }
        
      if(listProductObjectIds != null && listProductObjectIds.size() > 0)
      {
    	  deletedProduct = productBean.delete(context, (String[]) listProductObjectIds.toArray(new String[listProductObjectIds.size()]), new String());
      }
      
      if(listModelObjectIds != null && listModelObjectIds.size() > 0)
      {
    	  deletedModel = modelBean.delete(context, (String[]) listModelObjectIds.toArray(new String[listModelObjectIds.size()]), DomainConstants.EMPTY_STRING);
      }
      
      if(listPLObjectIds != null && listPLObjectIds.size() > 0)
      {
    	  ProductLine.delete(context, listPLObjectIds);
      }
      
      int PLObjectIdSize = listPLObjectIds.size();
%>      
      <script language="javascript" type="text/javaScript">
      
      var varFrame            = "<%=strFrame%>";
      var varPLObjectIdSize   = <%=PLObjectIdSize%>;
      var varContextParentOID = "<xss:encodeForJavaScript><%=strContextParentOID%></xss:encodeForJavaScript>";
      
      if(varPLObjectIdSize <= 0 || (varContextParentOID != "null" && varContextParentOID != ""))
      {
	      var contentFrameObj     = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
	      var oXML                = contentFrameObj.oXML;
	      var varObjectToRemove   = "<%=XSSUtil.encodeForJavaScript(context, strObjectToRemove)%>";
	      var arrObjectToRemove   = new Array();
	      arrObjectToRemove       = varObjectToRemove.split("~");
	      var selctedRowIds       = new Array(arrObjectToRemove.length-1);
	      var parentObjIds        = new Array(arrObjectToRemove.length-1);
	      for(var i = 0; i < arrObjectToRemove.length-1; i++)
	      {	  
		      var selectedRow  = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + arrObjectToRemove[i] + "']");
		      
		      var oId = selectedRow[0].attributes.getNamedItem("o").nodeValue;
		      var rId = selectedRow[0].attributes.getNamedItem("r").nodeValue;
		      var pId = selectedRow[0].attributes.getNamedItem("p").nodeValue;
		      var lId = selectedRow[0].attributes.getNamedItem("id").nodeValue;
		      var rowIds = rId+"|"+oId+"|"+pId+"|"+lId;
		      parentObjIds[i]  = pId;
		      selctedRowIds[i] = rowIds;
	      }
	      contentFrameObj.emxEditableTable.removeRowsSelected(selctedRowIds);
	      
	      for(var j = 0; j < parentObjIds.length; j++)
	      {
	    	  var selParentRow    = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + parentObjIds[j] + "']");
	    	  var rowID           = selParentRow[0].getAttribute("id");
	   	      var lastObjectChild = selParentRow[0].lastChild.id;
	   	      contentFrameObj.emxEditableTable.refreshRowByRowId(lastObjectChild);
	      }
	      
	      // To Refresh Structure Tree on Delete Of Product Lines/Models/Products from Product Line >> Product Lines.
	      if(varContextParentOID != "null" && varContextParentOID != ""){
	          for(var j = 0; j < arrObjectToRemove.length-1; j++)
	          {
	        	  var objectId = arrObjectToRemove[j];
	      		  var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
	      		  contentFrame.deleteObjectFromTrees(objectId, false); 
	          }
	      }
      }
      else
      {
    	  var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
          contentFrameObj.editableTable.loadData();
          contentFrameObj.rebuildView();
      }
      </script> 
<%
  }
  catch(Exception e)
  {
	  if(deletedProduct || deletedModel)
	  {
%>
          <script language="javascript" type="text/javaScript">
          var varFrame            = "<%=strFrame%>";
          var contentFrameObj     = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
	      var oXML                = contentFrameObj.oXML;
	      var vardeletedProduct   = "<%=deletedProduct%>";
	      var arrObjectToRemove   = new Array();
	      if(vardeletedProduct == "true"){
	    	  var varProductIds = "<%=XSSUtil.encodeForJavaScript(context,strProductIds)%>";
	    	  arrObjectToRemove = varProductIds.split("~");
	      }else{
	    	  var varModelIds   = "<%=XSSUtil.encodeForJavaScript(context,strModelIds)%>";
	    	  arrObjectToRemove = varModelIds.split("~");
	      }
	      
	      var selctedRowIds       = new Array(arrObjectToRemove.length - 1);
	      var parentObjIds        = new Array(arrObjectToRemove.length - 1);
	      for(var i = 0; i < arrObjectToRemove.length - 1; i++)
	      {	  
		      var selectedRow  = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + arrObjectToRemove[i] + "']");
		      
		      var oId = selectedRow[0].attributes.getNamedItem("o").nodeValue;
		      var rId = selectedRow[0].attributes.getNamedItem("r").nodeValue;
		      var pId = selectedRow[0].attributes.getNamedItem("p").nodeValue;
		      var lId = selectedRow[0].attributes.getNamedItem("id").nodeValue;
		      var rowIds = rId+"|"+oId+"|"+pId+"|"+lId;
		      parentObjIds[i]  = pId;
		      selctedRowIds[i] = rowIds;
	      }
	      contentFrameObj.emxEditableTable.removeRowsSelected(selctedRowIds);
	      
	      for(var j = 0; j < parentObjIds.length; j++)
	      {
	    	  var selParentRow    = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + parentObjIds[j] + "']");
	    	  var rowID           = selParentRow[0].getAttribute("id");
	   	      var lastObjectChild = selParentRow[0].lastChild.id;
	   	      contentFrameObj.emxEditableTable.refreshRowByRowId(lastObjectChild);
	      }
	      </script> 
<%		  
	  }
	 
	  bIsError=true;
	  if (e.toString()!=null && e.toString().indexOf("Check trigger blocked event")< 0) {
	  session.putValue("error.message", e.getMessage());	  
	  }  
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
