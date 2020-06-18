
<%--  emxGenericDeleteProcess.jsp
   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxGenericDeleteProcess.jsp.rca 1.7.3.3 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
--%>
<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.exception.PLMxModelerException" %>
				 
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
boolean isFromSearch = false;
try
{
	String lang = request.getHeader("Accept-Language");
	String memberIds[] = emxGetParameterValues(request,"emxTableRowId");
	Map requestMap = UINavigatorUtil.getRequestParameterMap(request);
	String toolbarName = (String)requestMap.get("toolbar");
	isFromSearch = toolbarName != null && toolbarName.contains("Search");
	for (int i = 0; i < memberIds.length; i++) {
		if (memberIds[i].startsWith("|")) memberIds[i] = memberIds[i].substring(1, memberIds[i].indexOf("|", 1));
	}
	CATRgnReportServices services = new CATRgnReportServices(context, lang);
	services.deleteReports(memberIds);
	
} catch (Exception ex) {   
   	emxNavErrorObject.addMessage(ex.getMessage().trim());			
}

%>

<html>
<head> 
<script language="JavaScript" src="scripts/emxUICore.js"></script> 

<script type="text/javascript" language="javascript">
	if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(isFromSearch))%>) {
		findFrame(getTopWindow(),"windowShadeFrame").document.getElementById("full_search_hidden").submit();
	} else {
		parent.location=parent.location;
	}
</script>

</head>
<body>
</body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
