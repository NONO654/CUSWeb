<%-- 
      GBOMNameLimitFilter.jsp
      Copyright (c) 1993-2018 Dassault Systemes.
      All Rights Reserved.
      This program contains proprietary and trade secret information of Dassault Systemes.
      Copyright notice is precautionary only and does not evidence any actual
      or intended publication of such program
--%>


<!-- Include file for error handling -->
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<!-- Include directives -->
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<!-- Page directives -->


<%
       // Get time stamp id for current table from request
       String jsTreeID = emxGetParameter(request,"jsTreeID");  
       String suiteKey = emxGetParameter(request,"suiteKey");    
       String initSource = emxGetParameter(request,"initSource");
       String strObjectId    = emxGetParameter(request, "objectId");
       String strParentId = emxGetParameter(request, "parentOID");

       String limitErr =  com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.checkPositiveInteger", context.getSession().getLanguage());

       // Get user inputs from HTML controls
       String sNameFilterValue = emxGetParameter(request, "FTRLogicalFeatureGBOMNameFilterCommand");
       String sLimitFilterValue = emxGetParameter(request, "FTRLogicalFeatureGBOMLimitFilterCommand");
%>
    <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript">
    var fUrl = "../common/emxIndentedTable.jsp?table=FTRViewGBOMTable&program=emxFTRPart:getActiveGBOMStructure&selection=multiple&header=emxProduct.GBOMStructureBrowser.ViewGBOMPartTableHeader&toolbar=FTRContextGBOMStructureToolbarActions,FTRGBOMCustomFilterToolbar&massUpdate=true&editLink=true&type=type_Part&HelpMarker=emxhelpgbom&type=type_Part&HelpMarker=emxhelpgbom&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureGBOMNameFilterCommand=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureGBOMLimitFilterCommand=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>";
    
    if((!isNaN("<%=XSSUtil.encodeForJavaScript(context,sLimitFilterValue)%>") && "<%=XSSUtil.encodeForJavaScript(context,sLimitFilterValue)%>" > 0 ) || "<%=XSSUtil.encodeForJavaScript(context,sLimitFilterValue)%>" == "*")
    {
    	window.parent.frames.location.href  = fUrl;
    }
    else
    {
         alert("<%=XSSUtil.encodeForJavaScript(context,limitErr)%>");
    }
    </script>

