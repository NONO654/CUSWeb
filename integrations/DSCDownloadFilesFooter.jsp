<%--  DSCDownloadFilesFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	String integrationName	= Request.getParameter(request,"integrationName");
	

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);
	MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
	MCADLocalConfigObject localConfig			= integSessionData.getLocalConfigObject();

	String checkoutDirectoryAttrName				= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-CheckOutDirectory");
	String workingDirectory							= "";
	String isCheckoutDirectoryDisabled				= "";
	String checkoutDirectoryHiddenHTMLContent			= "";

	String checkoutDirectoryPrefType	= globalConfigObject.getPreferenceType(checkoutDirectoryAttrName);
	if(checkoutDirectoryPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isCheckoutDirectoryDisabled = "disabled";
		workingDirectory = globalConfigObject.getPreferenceValue(checkoutDirectoryAttrName);
	}
	else if(checkoutDirectoryPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		checkoutDirectoryHiddenHTMLContent = "style=\"visibility: hidden\"";
		workingDirectory = globalConfigObject.getPreferenceValue(checkoutDirectoryAttrName);
	}
	else
	{
		workingDirectory = localConfig.getCheckoutDirectory(integrationName);
		//do not show default checkout directory value if the alias dir mode is "current"
        String userDirAliasMode = localConfig.getUserDirectoryAliasMode(integrationName);
		if(userDirAliasMode.equals(MCADAppletServletProtocol.ATTR_USERDIRALIAS_MODE_CURRENT))
        {
			workingDirectory = "";
        }
	}	
%>

<html>
  <head>
    <!--style type=text/css > 
	  body { background-color: #DDDECB; } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; } 
    </style-->
	<link rel="stylesheet" href="../integrations/styles/emxIEFCommonUI.css" type="text/css">
  </head>
  <body>

    <!--XSSOK-->
    <table border='0' width='95%' <%= checkoutDirectoryHiddenHTMLContent %>>
    <tr>
		<form name='directoryChooser'>
		<!--XSSOK-->
		<td nowrap align='left'><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.CheckoutDirectory")%>&nbsp
		    <!--XSSOK-->
			<input type='text' name='workingDirectory' value="<%= workingDirectory %>" size=45 readonly>
			<!--XSSOK-->
			<input type='button' name='SomeButton' value="<%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.Choose")%>" onClick='parent.showDirectoryChooser()' <%= isCheckoutDirectoryDisabled %>>
		</td>
		</form>
		<td nowrap align='left'><p align=left><img src="images/utilSpace.gif" width=242 height=16 name=progress></p></td>
    </tr>

    <table border="0" width="95%">
      <tr>
        <td nowrap align="left"><p align=left><img src="./images/utilSpace.gif" width=242 height=16 name=progress></p></td><td nowrap align="right">
        <table border="0">
          <tr>
		    <!--XSSOK-->
            <td nowrap><a href="javascript:parent.downloadSelected()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%>"></a></td>
			<!--XSSOK-->
            <td nowrap><a href="javascript:parent.downloadSelected()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Download")%></a></td>
			<td nowrap>&nbsp;</td>
			<td nowrap>&nbsp;</td>
			<td nowrap>&nbsp;</td>
			<!--XSSOK-->
            <td nowrap><a href="javascript:parent.downloadCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a></td>
			<!--XSSOK-->
            <td nowrap><a href="javascript:parent.downloadCancelled()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a>
            </td>
          </tr>
        </table>
        </td>
      </tr>
    </table>
  </body>
</html>
