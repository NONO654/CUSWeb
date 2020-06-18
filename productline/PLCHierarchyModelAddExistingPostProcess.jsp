<%--
  PLCHierarchyModelAddExistingPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.Model"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

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
	String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProdutLine.RowSelect.Single", strLanguage);
    String strObjId           = emxGetParameter(request, "objectId");
    String strTableRowIds[]   = emxGetParameterValues(request, "emxTableRowId");
    String relType            = ProductLineConstants.RELATIONSHIP_PRODUCTLINE_MODELS;
    String strContextParentOID = emxGetParameter(request, "ContextParentOID");
    
    if(strTableRowIds != null && strTableRowIds.length > 0)
    {
        for(int i = 0; i < strTableRowIds.length; i++)
        {
			StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[i],"|");
			String          strModelID   = strTokenizer.nextToken();
			String      strProductLineID = strTokenizer.nextToken();
			String[]   strProductLineIds = new String[1];
			strProductLineIds[0] = strProductLineID;
			Map  programMap = new HashMap();
			
			Map paramMap = new HashMap();
			paramMap.put("objectId", strModelID);
			programMap.put("paramMap", paramMap);
			
			Map requestMap = new HashMap();
			requestMap.put("objectId", strProductLineIds);
			
			programMap.put("requestMap", requestMap);
			
			String[] arrJPOArgs = (String[])JPO.packArgs(programMap);     
		    JPO.invoke(context,"emxModel",null,"connectToProdutLine",arrJPOArgs,MapList.class);
		    
		    Map paramMapForXML = new HashMap();
		    paramMapForXML.put("objectId", strProductLineID);
		    paramMapForXML.put("newObjectId", strModelID);
		    
		    String xml = Model.getXMLForSBModel(context, paramMapForXML, relType);
%>			
			<script language="javascript" type="text/javaScript">
	        var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";  
	        getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected(strXml);
	        
	        // To Refresh Structure Tree on Add Existing Of Models in Product Line >> Product Lines
	        var varContextParentOID = "<%=XSSUtil.encodeForJavaScript(context,strContextParentOID)%>";
	        if(varContextParentOID != "null" && varContextParentOID != ""){
	        var objectId = "<%=XSSUtil.encodeForJavaScript(context,strModelID)%>";	
			var parentId = "<%=XSSUtil.encodeForJavaScript(context,strProductLineID)%>";
			var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().parent.parent.parent, "content");
			contentFrame.addMultipleStructureNodes(objectId, parentId, '', '', false);
	        }
	        </script>
<%
        }
%>
        <script language="javascript" type="text/javaScript">
        getTopWindow().closeWindow();
        </script>
<%
    }	
    else
    {
%>
        <script language="javascript" type="text/javaScript">
        alert("<%=strRowSelectSingle%>");
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
