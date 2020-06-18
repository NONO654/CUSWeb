 <%-- ECMCommonRefresh.jsp -  This is an common ECM jsp file for refreshing the pages.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>

<%

	String tableRowId       = emxGetParameter(request, "tableRowId");
    String commandName      = emxGetParameter(request, "commandName");
    String refreshStructure = emxGetParameter(request, "refreshStructure");
    String objectId	    = emxGetParameter(request, "objectId");
    String functionality    = emxGetParameter(request, "functionality");
    boolean sHas = false;
    
    if(!UIUtil.isNullOrEmpty(refreshStructure)) {
    	sHas = true;
    }
    
   
%>

<script language="Javascript">
    //XSSOK
	var sCommanName = "<%=XSSUtil.encodeForJavaScript(context, commandName)%>"; 
	//XSSOK
	var functionality = "<%=XSSUtil.encodeForJavaScript(context, functionality)%>";
	
	//XSSOK
	if (<%=sHas%>) {
		var frameObject = findFrame(getTopWindow(), sCommanName);
		if(frameObject != null) {
				frameObject.location.href = frameObject.location.href;
		} 
	}
	if(functionality == "editCOFromRMB" || functionality == "editCRFromRMB" || functionality == "editCAFromRMB") {
		var frameObject = findFrame(getTopWindow(), getTopWindow().commandName["targetFrameToRefresh"]);
		getTopWindow().commandName["targetFrameToRefresh"] = "";
		
		var varObjectId = "<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
		var rowsToRefresh = emxUICore.selectNodes(frameObject.oXML, "/mxRoot/rows//r[@o = '" + varObjectId + "']");
		
		for (var i = 0; i < rowsToRefresh.length; i++) {
			frameObject.emxEditableTable.refreshRowByRowId(rowsToRefresh[i].getAttribute("id"));
		}		
	}
	if (getTopWindow().location.href.indexOf("targetLocation=popup") == -1) {
		getTopWindow().closeSlideInDialog();
	}
		
	
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


