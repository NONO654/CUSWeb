<%--  MCADLockUnlockFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@page import = "com.matrixone.apps.domain.util.*" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
		
	String integrationName = Request.getParameter(request,"integrationName");
	
	
	MCADGlobalConfigObject globalConfigObject   = integSessionData.getGlobalConfigObject(integrationName, integSessionData.getClonedContext(session));
	MCADLocalConfigObject localConfigObject 	= integSessionData.getLocalConfigObject();

	String checkoutDirectoryAttrName		= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-CheckOutDirectory");
	
	String isCheckoutDirectoryDisabled	= "";
	String checkoutDirectoryHiddenContent	= "";
	String workingDirectory		        = "";
	String inputTypeForWorkingDirText	= "hidden";
	String inputTypeForWorkingDirButton	= "hidden";
	String checkoutDirectoryString 		= "";

	workingDirectory = globalConfigObject.getPreferenceValue(checkoutDirectoryAttrName);

	String checkoutDirectoryPrefType	= globalConfigObject.getPreferenceType(checkoutDirectoryAttrName);
	if(checkoutDirectoryPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isCheckoutDirectoryDisabled = "disabled";
	}
	else if(checkoutDirectoryPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		checkoutDirectoryHiddenContent = "style=\"visibility: hidden\"";
	}
	else
	{
		workingDirectory = localConfigObject.getCheckoutDirectory(integrationName);
		//do not show default checkout directory value if the alias dir mode is "current"
		String userDirAliasMode = localConfigObject.getUserDirectoryAliasMode(integrationName);
		if(userDirAliasMode.equals(MCADAppletServletProtocol.ATTR_USERDIRALIAS_MODE_CURRENT))
		{
			workingDirectory = "";
		} 
	}
%>

<html>
  <head>
    <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
  </head>
  <body>

    <table width="100%" border="0" cellspacing="3" cellpadding="3">
      
<%	
	if(globalConfigObject.isRapidFileAccessEnabled())
	{    
		inputTypeForWorkingDirText	= "text";
	        inputTypeForWorkingDirButton	= "button";
		checkoutDirectoryString         = integSessionData.getStringResource("mcadIntegration.Server.FieldName.CheckoutDirectory");
	}
%>
            <!--XSSOK-->
      		<tr <%= checkoutDirectoryHiddenContent %>> <form name='directoryChooser'>
			
			<td nowrap align='left'><!--XSSOK-->
			<%= checkoutDirectoryString %>&nbsp
				<input type=<%= inputTypeForWorkingDirText %> name='workingDirectory' value="<xss:encodeForHTMLAttribute><%=workingDirectory%></xss:encodeForHTMLAttribute>" size=45 readonly>
				<input type=<%= inputTypeForWorkingDirButton %> name='SomeButton' value='<%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.Choose")%>' onClick='parent.showDirectoryChooser()'  <xss:encodeForHTMLAttribute><%=isCheckoutDirectoryDisabled%></xss:encodeForHTMLAttribute>>
			</td></form>
		</tr>

      <tr>
        
	
        <table width="100%" border="0" align="center" cellspacing="3" cellpadding="3">
          <tr>
		    <td nowrap align="left"><p align=left><img src="./images/utilSpace.gif" width=242 height=16 name=progress></p></td>
			<td nowrap align="right">
				<table border="0">
			<!--XSSOK-->
				<td nowrap><a href="javascript:parent.changeLockSelectionForAll(true)"><img src="./images/buttonMainMyTasks.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.LockAll")%>"></a>
				</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.changeLockSelectionForAll(true)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LockAll")%></a>	</td>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.changeLockSelectionForModified(true)"><img src="./images/buttonMainMyTasks.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.LockModified")%>"></a>
				</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.changeLockSelectionForModified(true)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LockModified")%></a>
				</td>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.changeLockSelectionForAll(false)"><img src="./images/buttonRemove.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.UnlockAll")%>"></a>
				</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.changeLockSelectionForAll(false)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.UnlockAll")%></a>
				</td>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.lockUnlockSelected()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%>"></a>&nbsp;
				</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.lockUnlockSelected()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%></a></td>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.lockUnlockCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;
				</td>
				<!--XSSOK-->
				<td nowrap><a href="javascript:parent.lockUnlockCancelled()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a>
				</td>
				<table>
			</td>
          </tr>
        </table>

      </tr>
    </table>
  </body>
</html>
