<%--  MCADGenericHeaderPage.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>


<% 
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context	= integSessionData.getClonedContext(session);

	String sMsgHeader	= Request.getParameter(request,"messageHeader");
	
	if(sMsgHeader == null || sMsgHeader.equals(""))
	{
		sMsgHeader	= (String)session.getAttribute("mcadintegration.messageHeader");
		session.removeAttribute("mcadintegration.messageHeader");
	}

	String HelpMarker		= Request.getParameter(request,"helpMarker");
	String language			= request.getHeader("Accept-Language");
	String strHelp			= UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Help",
                                               "emxFrameworkStringResource", language);

	String headerImage		= Request.getParameter(request,"headerImage");
	String showExportIcon	= Request.getParameter(request,"showExportIcon");
	
%>

<!-- Content starts here -->

<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<html>
<head>
<style>
  /* Background Appearance */
  body { background-color: #FEFEFE; }
  body, th, td, p, select, option { font-family: Verdana, Arial, Helvetica, Sans-Serif; font-size: 11px; }

  /* Message Header Appearance */
  td.MCADMsgHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 14px; font-weight: bold; color: #082C52; }

  /* Message Body Appearance */
  td.MCADMsgBody {  font-family: Arial, Helvetica, Sans-Serif; font-size: 10pt; font-weight: bold; color: #082C52;  text-align: center; }

  /* Page Header Border Appearance */
  td.pageBorder {  background-color: #003366; }
</style>
</head>

<body >

<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
	<td class="pageBorder"><img src="spacer.gif" width="1" height="1"></td>
	
  </tr>
</table>

<!-- page header and pagination -->
<script language="javascript">
	
	function csvExport()
	{
		top.frames['contentFrame'].csvExport();
	}
	
	document.write("<table border='0' width='100%' cellpadding='2'>");
	document.write("<tr>");
	document.write("<td class='MCADMsgHeader'>");
	<%
	if(headerImage != null && !headerImage.equals("null") && !headerImage.equals("")){
	%>
		document.write("<img src='<%=XSSUtil.encodeForURL(context,headerImage)%>' width='24' height='24' border='0'>&nbsp&nbsp;");
	<% 
	} 
	%>
	document.write(unescape("<%= sMsgHeader %>") + "</td>");
	<%
	if(showExportIcon != null && showExportIcon.equalsIgnoreCase("true"))
	{
	%>
		document.write("<td>&nbsp;&nbsp;<a href='javascript:csvExport();'><img src='../common/images/iconActionExcelExport.gif' border='0' width='15' height='15'></a></td>");
	<% 
	} 
	%>
	document.write("</tr>");
	document.write("</table>");
</script>
<script language="javascript" src="./scripts/IEFHelpInclude.js">
</script>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
    <td class="pageBorder"><img src="spacer.gif" width="1" height="1"></td>
  </tr>
</table>
  <%
  if(HelpMarker != null && !HelpMarker.equals("null")){
  %>
<br>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
	<td align="right" ><a href='javascript:openIEFHelp("<%=XSSUtil.encodeForJavaScript(context,HelpMarker)%>")'><img src="images/buttonContextHelp.gif" width="16" height="16" border="0" alt="<%=strHelp%>"></a></td>
  </tr>
</table>
  <% } %>


</body>
</html>
