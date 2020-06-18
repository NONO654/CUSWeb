<%--  MCADEBOMSynchFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.*" %>


<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	 Context context = integSessionData.getClonedContext(session);
	String isGrayOutMsgRequired = Request.getParameter(request,"isGrayOutMsgRequired");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>
<body>

<table border="0" align="center">
	<tr colspan="5"> 
		<td nowrap>&nbsp;</td>
	</tr> 
   <tr colspan="5"> 
   	<% if(isGrayOutMsgRequired != null && "true".equals(isGrayOutMsgRequired))
	{
	%>
		<td nowrap>
			<font size="2" color="red">
			<!--XSSOK-->
			<b><%=integSessionData.getStringResource("mcadIntegration.Server.Message.GrayedOutNodeAreExcludedFromBOM")%></b>
			</font>
		</td>
	<%
	} 
	%>
    </tr>
    <tr colspan="5"> 
		<td nowrap>&nbsp;</td>
	</tr> 
</table>            	

<table width="35%" border="0" cellspacing="3" cellpadding="3" align="right">
    <tr>
        <td nowrap align="right">
            <table border="0">
                <tr>
		    <!--XSSOK-->
                    <td nowrap><a href="javascript:parent.ebomSynchSelected()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%>"></a>&nbsp;</td>
                    <!--XSSOK-->
                    <td nowrap><a href="javascript:parent.ebomSynchSelected()"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Submit")%></a></td>
                    <td nowrap>&nbsp;</td>
		    <!--XSSOK-->
		    		<td nowrap><a href="javascript:parent.ebomSynchCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;</td>
                    <!--XSSOK-->
                    <td nowrap><a href="javascript:parent.ebomSynchCancelled()"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
                </tr>
            </table>
        </td>
    </tr>
</table>

	<form name="UpdatePage" action="MCADUpdateWithMessage.jsp" target="_top" method="post">

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

		<input type="hidden" name="busId" value="">
		<input type="hidden" name="instanceName" value="">
		<input type="hidden" name="refresh" value="true">
		<input type="hidden" name="instanceRefresh" value="true">
		<input type="hidden" name="details" value="">
	</form>

</body>
</html>
