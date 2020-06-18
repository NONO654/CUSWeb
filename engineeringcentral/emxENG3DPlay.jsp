<%--  emxENG3DPlay.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
 <%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

<!DOCTYPE html>
<html style="height: 100%; overflow: hidden;">
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>


<%
	 String objectId     = (String)emxGetParameter(request, "objectId");
// Modified for IR-458314 -My Engineering view 3D Play -start
	 if(UIUtil.isNullOrEmpty(objectId)){
	 	String rowID = (String)emxGetParameter(request, "emxTableRowId");	 	
	 	 StringTokenizer sToken = new StringTokenizer(rowID,"|");
			if(sToken.hasMoreTokens())
				objectId = sToken.nextToken();	     
	 }
	// Modified for IR-458314 -My Engineering view 3D Play -end
	 String timeStamp = (String)emxGetParameter(request,"timeStamp");
	 StringBuffer contentURL = new StringBuffer("emxLaunch3DPlay.jsp?");
	 contentURL.append("timeStamp=");
     contentURL.append(XSSUtil.encodeForURL(context, timeStamp));
     contentURL.append("&"); 
     contentURL.append("objectId=");
     contentURL.append(XSSUtil.encodeForURL(context, objectId));
     contentURL.append("&");
     contentURL.append(XSSUtil.encodeURLwithParsing(context, request.getQueryString()));
%>			
</head>

<body class=" slide-in-panel" style="height: 100%; margin: 0px;">
		
		<div id="divPageBody" name="divPageBody" style="top: 0px;bottom: 200px;width:100%;height:100%;">
		<script language="javascript">
		//XSSOK
			this.location.href = "<%= contentURL.toString()%>";
	  	</script>
</div>
</body>
</html>
