<%--  emxEngCommonRefresh.jsp -  This is an common ENG jsp file for refreshing the pages.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
    String tableRowId       = emxGetParameter(request, "tableRowId");
    String frameNumber      = emxGetParameter(request, "frameNumber");    
    String commandName      = emxGetParameter(request, "commandName");
    String refreshStructure = emxGetParameter(request, "refreshStructure");
    String strObjectId      = emxGetParameter(request, "objectId");
    String viewAndEditMode  = emxGetParameter(request, "viewAndEditMode");
    String strFrameNumberPassed = "true";
    String action = request.getParameter("action")==null? "":request.getParameter("action");
    String openMode = emxGetParameter(request, "openMode");
    try {
    	Integer.parseInt(frameNumber);
    } catch (Exception e) {
    	frameNumber = "0";
    	strFrameNumberPassed = "false";
    }
%>

<script language="Javascript">
	//XSSOK
	var sURL = "";
	if("RMBProperties" == "<%=openMode%>" ){
		sURL="../common/emxTree.jsp?objectId="+"<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>";
		top.getTopWindow().closeSlideInDialog();
		this.document.location.href = sURL;
	}
	if ("true" == "<%=XSSUtil.encodeForJavaScript(context, viewAndEditMode)%>") {
		
		if (getTopWindow().commandName) { // true if coming from RMB else from full search. 
			var frameObject = findFrame(getTopWindow(), getTopWindow().commandName["refreshRowCommandName"]);
			getTopWindow().commandName["refreshRowCommandName"] = "";
			
			var varObjectId = "<%=XSSUtil.encodeForJavaScript(context, strObjectId)%>";
			var rowsToRefresh = emxUICore.selectNodes(frameObject.oXML, "/mxRoot/rows//r[@o = '" + varObjectId + "']");
			
			for (var i = 0; i < rowsToRefresh.length; i++) {
				frameObject.emxEditableTable.refreshRowByRowId(rowsToRefresh[i].getAttribute("id"));
			}
			
			getTopWindow().closeSlideInDialog();
		} else { // from full search
			var contentFrame = getFormContentFrame();
		
			if (contentFrame) {
				var formUrl = contentFrame.location.href;
			    contentFrame.location.href = changeURLToViewMode(formUrl);
			}else if(getTopWindow()!= null){
				if((getTopWindow().location.href).indexOf("AEFStructureComparePortal")){ //On click of part hiperlink,BOM Compare Report
				getTopWindow().closeSlideInDialog();
			}else {
				getTopWindow().closeWindow();
			}
			}
		}		
	} 
	else if("refreshParent" == "<%=XSSUtil.encodeForJavaScript(context, action)%>"){
		//Added to fix bug # 419381 start		
		if(getTopWindow()){			
				var contentFrame   = findFrame(getTopWindow().getWindowOpener(),"detailsDisplay");				
				if(!contentFrame){
					contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");	
				}
				
				if(contentFrame){					
					contentFrame.location.href = contentFrame.location.href;
				}
				else{					
					getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
				}

			if (isMoz) {
				getTopWindow().close();
			}
			else{
				getTopWindow().closeWindow();
			}
			
		}
		//Added to fix bug # 419381 end
	}
	else {
	
		if ("true" == "<%=XSSUtil.encodeForJavaScript(context,refreshStructure)%>") {
			//XSSOK
			var frameObject = findFrame(getTopWindow(), "<%=XSSUtil.encodeForJavaScript(context,commandName)%>");
			
			if(frameObject) {
				if (frameObject.emxEditableTable == null || frameObject.emxEditableTable == "undefined") {
					frameObject.location.href = frameObject.location.href;
				} else {		
					//XSSOK
					var currRowID = "<%=XSSUtil.encodeForJavaScript(context,tableRowId)%>";
					if (currRowID != null || currRowID != "null" || currRowID != "") {
					    frameObject.emxEditableTable.refreshRowByRowId(currRowID);
					} else {
						frameObject.emxEditableTable.refreshStructureWithOutSort();
					}
				}
			} else {		
				frameObject = findFrame(getTopWindow(), "portalDisplay")
				if(frameObject) {
					frameObject.location.href = frameObject.location.href;
				}
			}
			
		} else {
			//XSSOK
		    var frameObject = findFrame(getTopWindow(), "portalDisplay") == null ? findFrame(getTopWindow(), "content") : findFrame(getTopWindow(), "portalDisplay").frames[parseInt(<%=XSSUtil.encodeForJavaScript(context,frameNumber)%>)];
		    
		    if (frameObject != null) {
		    	if ("<%=strFrameNumberPassed%>" == "true" && getTopWindow().refreshTablePage) {
                    getTopWindow().refreshTablePage();
                 } else {		    		
		        	frameObject.location.href = frameObject.location.href;
		    	}
		    }
		}
		
		if (getTopWindow().location.href.indexOf("targetLocation=popup") == -1) {
			getTopWindow().closeSlideInDialog();
		}
	}
	
</script>

