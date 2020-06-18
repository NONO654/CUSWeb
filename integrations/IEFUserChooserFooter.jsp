<%--  IEFUserChooserFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

    String isSolutionBased = emxGetParameter(request, "isSolutionBased");
	if(isSolutionBased == null)
		isSolutionBased = "false";
	
	String sDone		 = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done");

%>

<html>
  <head>
    <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
  </head>
  <body>

    <table border="0" width="95%">
      <tr>
        <td align="left"><p align=left><img src="./images/utilSpace.gif"></p></td>
		<td align="right">
			<table border="0">
			  <tr>	
			 <%if(isSolutionBased.equals("true")) { %> 
			        <!--XSSOK-->
				<td align="right"><a href="javascript:parent.done()"><img src="../integrations/images/emxUIButtonDone.gif" border="0" alt="<%= sDone %>"></a>&nbsp</td>
				<!--XSSOK-->
		        <td align="right"><a href="javascript:parent.done()"><%= sDone %></a>&nbsp&nbsp;</td>
			 <%} else { %>	
                                <!--XSSOK-->
				<td align="right" nowrap><a href="javascript:parent.gotoNextPage()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Next")%>"></a>&nbsp;</td>
			         <!--XSSOK-->
                         	<td align="right" nowrap><a href="javascript:parent.gotoNextPage()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Next")%></a></td>	
			  <%} %>	
			        <!--XSSOK-->
                        	<td align="right" nowrap>&nbsp;&nbsp;&nbsp;<a href="javascript:parent.closeWindow()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;</td>
				 <!--XSSOK-->
				<td align="right" nowrap><a href="javascript:parent.closeWindow()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
			  </tr>
			</table>
        </td>
      </tr>
    </table>
  </body>
</html>
