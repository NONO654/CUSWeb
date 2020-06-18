<%--
  PLCHierarchyProductLineCreatePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.productline.ProductLine"%>

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
   String strProductLineId   = emxGetParameter(request,"objectId");
   String strSubProductLine  = emxGetParameter(request,"newObjectId");
   String languageStr        = emxGetParameter(request,"languageStr");
   String relType            = ProductLineConstants.RELATIONSHIP_SUB_PRODUCT_LINES;
   String strContextParentOID  = emxGetParameter(request, "parentOID");
   String strFrame  =  "content";
   if(ProductLineCommon.isNotNull(strContextParentOID)){
	   strFrame = "detailsDisplay";
   }
   
   if(ProductLineCommon.isNotNull(strProductLineId))
   { 
	   Map paramMap = new HashMap();
	   paramMap.put("objectId", strProductLineId);
	   paramMap.put("newObjectId", strSubProductLine);
	   paramMap.put("languageStr", languageStr);
	   
	   String xml = ProductLine.getXMLForSBCreate(context, paramMap, relType);
	   xml = xml.replace("pending", "committed");
%>
	   <script language="javascript" type="text/javaScript">
	   var varFrame   = "<%=strFrame%>";
	   var strXml     = "<%=XSSUtil.encodeForJavaScript(context,xml)%>";
	   var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
	   contentFrameObj.emxEditableTable.addToSelected(strXml);
	   
	   // To Refresh Structure Tree on Create Of Product Lines in Product Line >> Product Lines.
	   var varContextParentOID = "<xss:encodeForJavaScript><%=strContextParentOID%></xss:encodeForJavaScript>";
	   if(varContextParentOID != "null" && varContextParentOID != "")
	   {
		   var objectId = "<xss:encodeForJavaScript><%=strSubProductLine%></xss:encodeForJavaScript>";
		   var parentId = "<xss:encodeForJavaScript><%=strProductLineId%></xss:encodeForJavaScript>";
		   var contentFrame = getTopWindow().findFrame(window.parent.getTopWindow().getTopWindow(), "content");
		   contentFrame.addMultipleStructureNodes(objectId, parentId, '', '', false);
	   }
	   </script>
<%    	   
    }
    else
    {
%>
 	   <script language="javascript" type="text/javaScript">
 	   var varFrame   = "<%=strFrame%>";
 	   var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),varFrame);
 	   contentFrameObj.editableTable.loadData();
 	   contentFrameObj.rebuildView();
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
