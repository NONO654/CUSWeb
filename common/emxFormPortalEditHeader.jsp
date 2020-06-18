<%-- emxTablePortalHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormPortalEditHeader.jsp.rca 1.6 Wed Oct 22 15:48:08 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
    String timeStamp = emxGetParameter(request, "timeStamp");
    String objectId = emxGetParameter(request, "objectId");
    String relId = emxGetParameter(request, "relId");
	String HelpMarker = emxGetParameter(request, "HelpMarker");
	String suiteKey = emxGetParameter(request, "suiteKey");

    String form = emxGetParameter(request, "form");
    String title_prefix = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", "emxFramework.WindowTitle.Header", request.getLocale());
    String title = title_prefix + form;
%>
<head>
<title><xss:encodeForHTML><%=title%></xss:encodeForHTML></title>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>

        <script type="text/javascript">
              addStyleSheet("emxUIChannelDefault");
              addStyleSheet("emxUIToolbar");
              addStyleSheet("emxUIMenu");
        </script>

        <script language="javascript" src="scripts/emxUICoreMenu.js"></script>
		<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="scripts/emxUIModal.js"></script>
        <script language="JavaScript" src="scripts/emxUIPopups.js"></script>
    	<script language="javascript" src="scripts/emxNavigatorHelp.js"></script>
</head>

<body>
<div class="filter-row"></div>
<jsp:include page = "emxToolbar.jsp" flush="true">
	<jsp:param name="portalMode" value="true"/>
    <jsp:param name="toolbar" value=""/>
    <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
    <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
    <jsp:param name="editLink" value="false"/>
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="uiType" value="form"/>
    <jsp:param name="form" value="<%=XSSUtil.encodeForURL(context, form)%>"/>
    <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, HelpMarker)%>"/>
    <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>
</jsp:include>
</body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
