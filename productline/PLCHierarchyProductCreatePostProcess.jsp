<%--
  PLCHierarchyProductCreatePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>

<%-- Top error page in emxNavigator --%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.productline.Model"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<script language="javascript" src="emxUIMouseEvents.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITreeUtil.js"></script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<%
  boolean bIsError = false;
  try
  {
   String strObjectId     = emxGetParameter(request,"objectId");
   String strNewObjectId  = emxGetParameter(request,"newObjectId");
   String languageStr     = emxGetParameter(request,"languageStr");
   String strMode         = emxGetParameter(request,"mode");
   String strContextParentOID      = emxGetParameter(request,"ContextParentOID");
   StringList lstModelChildTypes   = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_MODEL);
   String strFrame = "content";
   if(ProductLineCommon.isNotNull(strContextParentOID)){
	   strFrame = "detailsDisplay";
   }
   
   if("CreateProduct".equals(strMode))
   {
	   matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
	   ContextUtil.commitTransaction(ctx);
	   
	   DomainObject productObj = new DomainObject(strNewObjectId);
	   StringList lstSelect    = new StringList();
	   lstSelect.add("to["+ ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT +"].from.id");
	   lstSelect.add("to["+ ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT +"].id");
	   Map modelMap =  productObj.getInfo(context, lstSelect);
	   String strModelId = (String)modelMap.get("to["+ ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT +"].from.id");
	   String strRelId = (String)modelMap.get("to["+ ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT +"].id");
	   
	   Map paramMap = new HashMap();
	   paramMap.put("objectId", strObjectId);
	   paramMap.put("newObjectId", strModelId);
	   paramMap.put("languageStr", languageStr);
	   String modelXML = Model.getXMLForSBModel(context, paramMap, ProductLineConstants.RELATIONSHIP_PRODUCTLINE_MODELS);
	   
%>
	   <script language="javascript" type="text/javaScript">
	   var varFrame        = "<%=strFrame%>";
	   var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
	   var varModelId      = "<%=XSSUtil.encodeForJavaScript(context,strModelId)%>";
	   var strXml          = "<%=XSSUtil.encodeForJavaScript(context,modelXML)%>";
	   contentFrameObj.emxEditableTable.addToSelected(strXml);
	   var oXML            = contentFrameObj.oXML;
	   var selectedRow     = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + varModelId + "']");
	   var rowId           = selectedRow[0].getAttribute("id");
       contentFrameObj.emxEditableTable.expand([rowId],null); 
       
       // To Refresh Structure Tree on Create Product in Product Line >> Product Lines.
	   var varContextParentOID = "<%=XSSUtil.encodeForJavaScript(context,strContextParentOID)%>";
	   if(varContextParentOID != "null" && varContextParentOID != "")
	   {
		   var varPLId = "<%=XSSUtil.encodeForJavaScript(context, strObjectId) %>";
		   var contentFrame = getTopWindow().findFrame(window.parent.getTopWindow().getTopWindow(), "content");
		   contentFrame.addMultipleStructureNodes(varModelId, varPLId, '', '', false);
	   }
	   </script>
<%	 	         
   }
   else if("CreateDerivation".equals(strMode))
   {
	   String strProductId      = emxGetParameter(request,"objectID");
	   String strDerivationType = emxGetParameter(request,"DerivationType");
	   String strLevel          = emxGetParameter(request,"Level");
	   
	   matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
	   ContextUtil.commitTransaction(ctx);
	    
	   Map programMap = new HashMap();
	   programMap.put("objectId", strNewObjectId);
	   programMap.put("selId", strProductId);
	   programMap.put("DerivationType", strDerivationType);
	   programMap.put("Level", strLevel);
	   String[] methodargs = JPO.packArgs(programMap);
	    
	   String xml = (String)JPO.invoke(context, "emxProduct", null, "postCreateGetRowXML", methodargs, String.class);
	   xml = "<mxRoot><action>add</action><data status=\"committed\">" + xml + "</data></mxRoot>";
%>
	   <script language="javascript" type="text/javaScript">
	   var varFrame  = "<%=strFrame%>";
	   var strXml    = "<%=XSSUtil.encodeForJavaScript(context,xml)%>";
	   var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
	   contentFrameObj.emxEditableTable.addToSelected(strXml);
	   
	   // To Refresh Structure Tree on Create Product Derivation in Product Line >> Product Lines.
	   var varContextParentOID = "<%=XSSUtil.encodeForJavaScript(context, strContextParentOID) %>";
	   if(varContextParentOID != "null" && varContextParentOID != "")
	   {
		   var objectId = "<%=XSSUtil.encodeForJavaScript(context, strNewObjectId)%>";
		   var parentId = "<%=XSSUtil.encodeForJavaScript(context, strProductId)%>";
		   var contentFrame = getTopWindow().findFrame(window.parent.getTopWindow().getTopWindow(), "content");
		   contentFrame.addMultipleStructureNodes(objectId, parentId, '', '', false);
	   }
	   </script>
<%	   
   }
   else if("CreateRevision".equals(strMode))
   {
	   String strProductId      = emxGetParameter(request,"objectID");
	   String strDerivationType = emxGetParameter(request,"DerivationType");
	   String strLevel          = emxGetParameter(request,"Level");
	   String strParentOID      = emxGetParameter(request,"parentOID"); 
	   String strModelId        = emxGetParameter(request,"modelID"); 
	   
	   DomainObject domObject   = DomainObject.newInstance(context,strParentOID); 
	   String strObjectType     = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
	   boolean isModel          = lstModelChildTypes.contains(strObjectType);
	   
	   matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
	   ContextUtil.commitTransaction(ctx);
	    
	   Map programMap = new HashMap();
	   programMap.put("objectId", strNewObjectId);
	   programMap.put("selId", strProductId);
	   programMap.put("DerivationType", strDerivationType);
	   programMap.put("Level", strLevel);
	   String[] methodargs = JPO.packArgs(programMap);
	   
	   String xml = (String)JPO.invoke(context, "emxProduct", null, "postCreateGetRowXML", methodargs, String.class);
	   xml = "<mxRoot><action>add</action><data status=\"committed\" pasteBelowOrAbove=\"true\">" + xml + "</data></mxRoot>"; 
%>
	   <script language="javascript" type="text/javaScript">
	   var varTypeModel     = "<%=isModel%>";
	   var varFrame         = "<%=strFrame%>";
	   var strXml           = '<%=xml%>';
	   var contentFrameObj  = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
	   var oXML             = contentFrameObj.oXML;
	   var varModelId       = "<%=XSSUtil.encodeForJavaScript(context,strModelId)%>";
	   var selectedRow      = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + varModelId + "']");
	   var rowId            = selectedRow[0].getAttribute("id");
	   var lastModelChild   = selectedRow[0].lastChild.getAttribute("id");
	   var varLevel         = "<%=XSSUtil.encodeForJavaScript(context,strLevel)%>";
	   var varSelectedObjId = "<%=XSSUtil.encodeForJavaScript(context,strParentOID)%>";
	   if(lastModelChild != null && lastModelChild != undefined && lastModelChild != "" && lastModelChild != " ")
	   {
		    if(varTypeModel == "true")
		    {
		    	strXml = strXml.replace("pasteBelowToRow=\""+varLevel+"\"","pasteBelowToRow=\""+lastModelChild+"\"");
				contentFrameObj.emxEditableTable.addToSelected(strXml);
				contentFrameObj.emxEditableTable.refreshRowByRowId(lastModelChild);
		    }
		    else
		    {
		    	var selRow  = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + varSelectedObjId + "']");
		 	    var rowID   = selRow[0].getAttribute("id");
		    	contentFrameObj.emxEditableTable.addToSelected(strXml);
				contentFrameObj.emxEditableTable.refreshRowByRowId(rowID);
		    }
	   }
	   else
	   {
			contentFrameObj.emxEditableTable.expand([rowId],null);  
	   }
	   
	   // To Refresh Structure Tree on Create Product Revision in Product Line >> Product Lines.
	   var varContextParentOID = "<%=XSSUtil.encodeForJavaScript(context,strContextParentOID)%>";
	   if(varContextParentOID != "null" && varContextParentOID != "")
	   {
		   var objectId = "<%=XSSUtil.encodeForJavaScript(context,strNewObjectId)%>";
		   var contentFrame = getTopWindow().findFrame(window.parent.getTopWindow().getTopWindow(), "content");
		   contentFrame.addMultipleStructureNodes(objectId, varModelId, '', '', false);
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
