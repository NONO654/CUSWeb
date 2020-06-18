<%--  IEFNotificationDialogFooter.jsp

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

    <table border="0" width="95%">
      <tr>
        <td nowrap align="left"><p align=left><img src="./images/utilSpace.gif" width=242 height=16 name=progress></p></td><td nowrap align="right">
        <table border="0">
          <tr>
            <td nowrap><a href="javascript:parent.submitForm()"><img src="../integrations/images/emxUIButtonNext.gif" border="0"></a></td>
			<!--XSSOK-->
            <td nowrap><a href="javascript:parent.submitForm()"><%= integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Continue")%></a></td>
            </td>
          </tr>
        </table>
        </td>
      </tr>
    </table>
  </body>
</html>
