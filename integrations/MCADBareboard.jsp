<%--  MCADBareboard.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	Context context		= integSessionData.getClonedContext(session);
	MCADMxUtil _util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String sObjId			= emxGetParameter(request, "busId"); 
	String sIntegrationName = emxGetParameter(request, "integrationName"); 
	String sRefreshBasePage = emxGetParameter(request, "refresh"); 
%>

<html>
<head>
<!--XSSOK-->
<title> <%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.BareboardName")%> </title>

<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">

<script language="JavaScript">
function doneMethod()
{
	var sBareboardName = document.bareboard.bareboardName.value;
	sBareboardName = sBareboardName.replace( /^\s*/, "" );
	sBareboardName = sBareboardName.replace( /\s*$/, "" );

	document.bareboard.action = "MCADBareboardUpdate.jsp";
	document.bareboard.bareboardName.value = sBareboardName;
	document.bareboard.submit();
}
</script>
</head>

<body>

<form name="bareboard" action="javascript:parent.frames['contentPage'].doneMethod()" method="post" target="_top">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

<!--XSSOK-->
<input type="hidden" name="busId" value="<%= sObjId %>">
<!--XSSOK-->
<input type="hidden" name="integrationName" value="<%= sIntegrationName %>">
<!--XSSOK-->
<input type="hidden" name="refresh" value="<%= sRefreshBasePage %>">
<input type="hidden" name="sBareboardNameChecked" value="true">

<table border="0" width="100%">
  <tr>
  <!--XSSOK-->
  <th width="100%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.EnterBareBoardName")%></th>
 </tr>
  <tr><td>&nbsp;</td></tr>
</table>

<table border="0" width="100%">
  <tr>
    <!--XSSOK-->
	<td width="20%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.BareboardName")%></b></td>
	<td width="80%"><input type="text" name="bareboardName"></td>
  </tr>
</table>

</form>
</body>
</html>

