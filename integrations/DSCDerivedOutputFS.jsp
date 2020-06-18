<%--  DSCDerivedOutputFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>

<%
	
	 MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String queryString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);

	String contentURL	= "./DSCDerivedOutput.jsp?" + queryString;
%>

<html>
<head>
<!-- IR-471177 :  Source link added for jquery.min.js and emxUICore.js-->
<script src="../plugins/libs/jquery/2.0.0/jquery.min.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</head>

<frameset id="framesetEditForm" rows="90,10" framespacing="0" border="0" frameborder="no" scrolling="no">
	<frame name="contentFrame" src="<xss:encodeForHTML><%=contentURL%></xss:encodeForHTML>" noresize="noresize" marginheight="0" border="0" scrolling="no" />
	<frame name="footerFrame" src="./MCADGenericFooterPage.jsp?buttonName=Close" noresize="noresize" marginheight="0" border="0" scrolling="no" />
</frameset>

</html>
