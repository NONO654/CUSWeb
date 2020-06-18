<%--  emxQualificationAddExtensionProcess.jsp - Add Extension with the Qualification Command 
  Copyright (c) 2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  by YI3 2012/10/01
--%>
<%@ page import="java.io.*" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil,				
				java.util.ArrayList"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>

<%        

String objectId = emxGetParameter(request, "objectId");
String extensionName = emxGetParameter(request, "extension");
Map argsHash = new HashMap();
String retVal = null;
try{
		if ((null != extensionName) && !extensionName.isEmpty() && (null != objectId) && !objectId.isEmpty())
		{
			argsHash.put("objectId", objectId);
			argsHash.put("extension", extensionName);
	
			// Pack arguments into string array.
			String[] args = JPO.packArgs(argsHash);
			retVal =(String) JPO.invoke(context, "emxQualificationProgram", null, "addExtensionToObject", args, String.class);

			}
	}catch (Exception e)
	{
		System.out.println("YI3 - AddExtensionProcess - Exception : " + e.getMessage());
		emxNavErrorObject.addMessage("Adding extension KO : " + e.getMessage());	
	}

	

%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%-- Reload the page --%>
<script language="javascript" type="text/javaScript">

//***********************************
var sbWindow = findFrame(top, "PLMAddExtensionCmd");
if (sbWindow){
	if(sbWindow.editableTable){
		sbWindow.rebuildView();
		sbWindow.editableTable.loadData();
		sbWindow.RefreshTableHeaders();
		sbWindow.sbToolbarResize();
		sbWindow.location.href = sbWindow.location.href;

	}
}
top.closeSlideInDialog();
//***********************************

</script>
