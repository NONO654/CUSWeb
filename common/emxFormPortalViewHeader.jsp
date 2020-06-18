<%-- emxFormPortalViewHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormPortalViewHeader.jsp.rca 1.5 Wed Oct 22 15:48:33 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxFormConstantsInclude.inc"%>

<%
    String form = emxGetParameter(request, "form");
    String title_prefix = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.WindowTitle.Header", request.getLocale());
    String title = title_prefix + form;
%>

<head>

<title><xss:encodeForHTML><%=title%></xss:encodeForHTML></title>

<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStylePropertiesInclude.inc"%>

<script type="text/javascript">
        addStyleSheet("emxUIChannelDefault");
        addStyleSheet("emxUIToolbar");
        addStyleSheet("emxUIMenu");
</script>

<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
<script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>
</head>

<%
    String actionBar = emxGetParameter(request, "actionBarName");
    String toolbar = emxGetParameter(request, "toolbar");
    String editLink = emxGetParameter(request, "editLink");
    String objectId = emxGetParameter(request, "objectId");
    String relId = emxGetParameter(request, "relId");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String originalHeader =emxGetParameter(request, "originalHeader");
    String header = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, request.getHeader("Accept-Language"));

    String timeStamp = emxGetParameter(request, "timeStamp");

    String HelpMarker = emxGetParameter(request, "HelpMarker");
    String tipPage = emxGetParameter(request, "TipPage");
    String printerFriendly = emxGetParameter(request, "PrinterFriendly");
    String export = emxGetParameter(request, "Export");
%>

<body>
<form method="post">
        <div class="filter-row">
        </div>
        <jsp:include page = "emxToolbar.jsp" flush="true">
            <jsp:param name="portalMode" value="true"/>
            <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
            <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
            <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
            <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
            <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
            <jsp:param name="editLink" value="<%=XSSUtil.encodeForURL(context, editLink)%>"/>
            <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/>
            <jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, printerFriendly)%>"/>
            <jsp:param name="export" value="<%=XSSUtil.encodeForURL(context, export)%>"/>
            <jsp:param name="uiType" value="form"/>
            <jsp:param name="form" value="<%=XSSUtil.encodeForURL(context, form)%>"/>
            <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, HelpMarker)%>"/>
            <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/>
            <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>
            <jsp:param name="topActionbar" value="<%=XSSUtil.encodeForURL(context, actionBar)%>"/>
        </jsp:include>
</form>
</body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
