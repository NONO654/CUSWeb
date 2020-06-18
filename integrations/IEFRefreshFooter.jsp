<%--  IEFRefreshFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
%>

<html>
  <head>
    <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
  </head>
  <body>

    <table width="100%" border="0" cellspacing="3" cellpadding="3">
      <tr>
        <td nowrap align="left"><p align=left><img src="./images/utilSpace.gif" width=242 height=16 name=progress></p></td><td nowrap align="right">
        <table border="0">
          <tr>
            <td nowrap>
			<!--XSSOK-->
			<a href="javascript:parent.refreshSelected()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%>"></a></td>
            <td nowrap>
			<!--XSSOK-->
			<a href="javascript:parent.refreshSelected()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Update")%></a></td>
			<td nowrap>&nbsp;</td>
			<td nowrap>
			<!--XSSOK-->
			<a href="javascript:parent.refreshCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a></td>
            <td nowrap>
			<!--XSSOK-->
			<a href="javascript:parent.refreshCancelled()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a>
            </td>
          </tr>
        </table>
        </td>
      </tr>
    </table>
  </body>
</html>
