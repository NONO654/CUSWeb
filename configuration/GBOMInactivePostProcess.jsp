
<%--  GBOMInactivePostProcess.jsp-- Will redirect to GBOMReplaceDialog with proper params
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>

<html>
<head>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
</head>

<%  
	String strMode = emxGetParameter(request,"mode");
	StringList slGBOMRelID= new StringList();
	String strObjId = "";
	String selectedGBOMRelID ="";
	String selectedGBOMID = "";
	if(strMode!=null  && strMode.equalsIgnoreCase("CustomGBOMInactive")){
		try{
		strObjId = emxGetParameter(request, "objectId");
		String parentOID = emxGetParameter(request, "parentOID");
	    String strRelId = emxGetParameter(request, "relId");
	    slGBOMRelID.add(strRelId);
	    LogicalFeature logicalFTR= new LogicalFeature(parentOID);
	   
	    boolean bFlag = logicalFTR.inactiveGBOM(context,slGBOMRelID);
	    out.write("responseMsg="+bFlag+"#");
        }
		catch(Exception e){       
			out.write("responseMsg=\""+e+"\"");
	    }
	    out.println();
	    out.flush();
	}
	else{
		try{
	String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
	strObjId = emxGetParameter(request, "objectId");
	String arrObjectIds[] = null;
	String arrRelIds[] = null;
	Map mapFromTree = (Map)ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
	arrRelIds = (String[])mapFromTree.get("RelId");
	arrObjectIds = (String[])mapFromTree.get("ObjId");
	
	for(int i=0;i<arrRelIds.length;i++){
	    StringTokenizer st = new StringTokenizer(arrRelIds[i],"|");
	    selectedGBOMRelID = st.nextToken();
	    slGBOMRelID.add(selectedGBOMRelID);
	}
	
	LogicalFeature logicalFTR= new LogicalFeature(strObjId);
	boolean bFlag = logicalFTR.inactiveGBOM(context,slGBOMRelID);
	if (bFlag)
	{
		for(int i=0;i<arrObjectIds.length;i++){
            StringTokenizer st1 = new StringTokenizer(arrRelIds[i],"|");
            selectedGBOMID = st1.nextToken(); 
		%>
		<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="javascript" type="text/javaScript">
		    var strObjId = '<%=XSSUtil.encodeForJavaScript(context,selectedGBOMID)%>';
		    var contentFrameObj =findFrame(getTopWindow(), "FTRProductContextGBOMPartTable");
	        if(contentFrameObj==null)
	            contentFrameObj =findFrame(getTopWindow(), "FTRContextGBOMPartTable");  
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
            var cntFrame = findFrame(getTopWindow(), "content");
            if(cntFrame !== null && cntFrame !== undefined){
            if(typeof cntFrame.deleteObjectFromTrees !== 'undefined' && 
            		typeof cntFrame.deleteObjectFromTrees === 'function')
            	{
            		cntFrame.deleteObjectFromTrees(oId, false);
            	}
            }
		    </script>
		<%
	 }
	}
	}
catch(Exception e){
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
