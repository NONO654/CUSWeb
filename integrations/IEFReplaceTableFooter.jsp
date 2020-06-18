<%--  IEFReplaceTableFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import= "com.matrixone.MCADIntegration.server.beans.*,com.matrixone.MCADIntegration.utils.*,				 com.matrixone.MCADIntegration.server.*" %>

<%@ include file ="MCADTopInclude.inc" %>

<%
MCADIntegrationSessionData intSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
MCADServerResourceBundle srvResourceBundle	= intSessionData.getResourceBundle();
String cancel					= srvResourceBundle.getString("mcadIntegration.Server.ButtonName.Cancel");
String done					= srvResourceBundle.getString("mcadIntegration.Server.ButtonName.Done");

%>
<html>
<head>
<title></title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
<body>
<form name="bottomCommonForm" method="post">
  <table border=0 width=100% >
    <tr>
      <td  valign=top align=right >
      </td>
      <td width="1%" align=right valign=top >
    </td>
    <td align=right nowrap >
&nbsp;
<!--XSSOK--><a href="javascript:parent.frames['contentFrame'].submitData()"  ><img src="../integrations/images/emxUIButtonDone.gif" border=0 align=absmiddle></a>&nbsp;<a href="javascript:parent.frames['contentFrame'].submitData()"  ><%=done%></a>&nbsp;&nbsp;<a href="javascript:parent.frames['contentFrame'].cancelDialog()"  ><img src="../integrations/images/emxUIButtonCancel.gif" border=0 align=absmiddle></a>&nbsp;<!--XSSOK--><a href="javascript:parent.frames[1].cancelDialog()"  ><%=cancel%></a>&nbsp;
    </td>
  </tr>
  <tr>
    <td></td>
    <td></td>
  </tr>
</table>
</form>
</body>
</html>

