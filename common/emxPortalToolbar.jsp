<%--  emxPortalToolbar.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPortalToolbar.jsp.rca 1.17 Wed Oct 22 15:48:20 2008 przemek Experimental przemek $
--%>
<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
	String toolbar = emxGetParameter(request, "toolbar");
	String objectId = emxGetParameter(request, "objectId");
	String relId = emxGetParameter(request, "relId");
	String languageStr = request.getHeader("Accept-Language");
	String editLink = emxGetParameter(request, "editLink");
	String suiteKey = emxGetParameter(request, "suiteKey");

	String sHelpMarker = emxGetParameter(request, "HelpMarker");
    String tipPage = emxGetParameter(request, "TipPage");
    String printerFriendly = emxGetParameter(request, "PrinterFriendly");
    String export = emxGetParameter(request, "Export");


	String header = emxGetParameter(request, "header");
	if(header != null && !"".equals(header)) {
		header = UINavigatorUtil.parseHeader(context, pageContext, header, objectId, suiteKey, languageStr);
	} else {
		header = "emxFramework.HomePortal.Header";
		if ( objectId != null && objectId.trim().length() > 0 ) {
			header = "emxFramework.ObjectPortal.Header";
		}
		header = UINavigatorUtil.parseHeader(context, pageContext, header, objectId, "Framework", languageStr);
	}

    String subHeader = emxGetParameter(request, "subHeader");
	if ( (subHeader != null) && (subHeader.trim().length() > 0) ) {
		subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, languageStr);
	}
%>
<head>
	<title><xss:encodeForHTML><%=header%></xss:encodeForHTML></title>

	<%@include file = "emxUIConstantsInclude.inc"%>
	<%@include file = "../emxStyleDefaultInclude.inc"%>
   	<%@include file = "../emxStyleListInclude.inc"%>

	<script type="text/javascript">
		addStyleSheet("emxUIToolbar");
		addStyleSheet("emxUIMenu");
	</script>

	<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
	<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
    <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
    <script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
    <script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
</head>

<body>
<form method="post">
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td width="99%">
				<table border="0" cellspacing="0" cellpadding="0" width="100%">
					<tr>
						<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt=""/></td>
					</tr>
				</table>

				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<td width="1%" nowrap>
						<span class="pageHeader">&nbsp;<xss:encodeForHTML><%=header%></xss:encodeForHTML></span>
<%
						if (subHeader != null && subHeader.length() > 0 )
						{
%>
							<br><span class="pageSubTitle">&nbsp;<xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></span>
<%
						}
%>
						</td>
                        <%
                            String progressImage = "../common/images/utilProgressBlue.gif";
                            String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
                        %>
                        <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align=absmiddle/>&nbsp;<i><%=processingText%></i></div></td>
                        <td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" border="0" alt="" vspace="6"/></td>
						<td align="right" class="filter">&nbsp;</td>
					</tr>
				</table>
			</td>

			<td><img src="images/utilSpacer.gif" alt="" width="4"/></td>
		</tr>
	</table>
<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
    <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
    <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="editLink" value="<%=XSSUtil.encodeForURL(context, editLink)%>"/>
    <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/>
    <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, sHelpMarker)%>"/>
    <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/>
</jsp:include>

</form>
</body>
</html>
