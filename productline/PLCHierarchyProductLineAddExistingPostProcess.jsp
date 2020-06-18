<%--
  PLCHierarchyProductLineAddExistingPostProcess.jsp
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
<%@page import="com.matrixone.apps.productline.ProductLine"%>
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
	String strLanguage      = context.getSession().getLanguage();
	String strAlertMessage  = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.PleaseSelectAnItem", strLanguage);
    String strProductLineId = emxGetParameter(request, "objectId");
    String strTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
    String relType          = ProductLineConstants.RELATIONSHIP_SUB_PRODUCT_LINES;
    Map programMap          = new HashMap();
    Map paramMap            = new HashMap();
    Map requestMap          = new HashMap();
    Map paramMapForXML      = new HashMap();
    String strContextParentOID = emxGetParameter(request, "ContextParentOID");
    if(strTableRowIds != null && strTableRowIds.length > 0)
    {
        for(int i = 0; i < strTableRowIds.length; i++)
        {
			StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[i],"|");
			String strSubProductLineId   = strTokenizer.nextToken();
			
			paramMap.put("newObjectId", strSubProductLineId);
			programMap.put("paramMap", paramMap);
			
			requestMap.put("objectId", strProductLineId);
			
			programMap.put("requestMap", requestMap);
			
			String[] arrJPOArgs = (String[])JPO.packArgs(programMap);     
		    JPO.invoke(context,"emxProductLine",null,"connectSubProductLine",arrJPOArgs,MapList.class);
		    
		    paramMapForXML.put("objectId", strProductLineId);
		    paramMapForXML.put("newObjectId", strSubProductLineId);
			   
			String xml = ProductLine.getXMLForSBCreate(context, paramMapForXML, relType);
			xml = xml.replace("pending", "committed");
%>			
			<script language="javascript" type="text/javaScript">
			
			var contentFrameObj     = getTopWindow().getWindowOpener().parent;
	        var oXML                = contentFrameObj.oXML;
	        var varSubProductLineId = "<%=XSSUtil.encodeForJavaScript(context,strSubProductLineId)%>";
	        var selectedRow         = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + varSubProductLineId + "']");
	        if(selectedRow.length > 0){
		        var oId = selectedRow[0].attributes.getNamedItem("o").nodeValue;
	            var rId = selectedRow[0].attributes.getNamedItem("r").nodeValue;
	            var pId = selectedRow[0].attributes.getNamedItem("p").nodeValue;
	            var lId = selectedRow[0].attributes.getNamedItem("id").nodeValue;
	            var rowIds = rId+"|"+oId+"|"+pId+"|"+lId;
		        var selctedRowIds = new Array(1);
		        selctedRowIds[0] = rowIds;
		        if(lId.split(",").length == 2){
		        contentFrameObj.emxEditableTable.removeRowsSelected(selctedRowIds); 
		        }
	        }
	        var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";  
	        getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected(strXml);
	        
	        // To Refresh Structure Tree on Add Existing Of Product Lines in Product Line >> Product Lines
	        var varContextParentOID = "<%=XSSUtil.encodeForJavaScript(context,strContextParentOID)%>";
	        if(varContextParentOID != "null" && varContextParentOID != ""){
			var parentId = "<%=XSSUtil.encodeForJavaScript(context,strProductLineId)%>";
			var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().parent.parent.parent, "content");
			contentFrame.addMultipleStructureNodes(varSubProductLineId, parentId, '', '', false);
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
        alert("<%=strAlertMessage%>");
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
