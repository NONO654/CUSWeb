<%--  MCADCheckoutFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.MCADIntegration.utils.*" %>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%  
    String integrationName						=Request.getParameter(request,"integrationName");	
	boolean isDownloadStructure					= false;
	String downloadStructure					= Request.getParameter(request,"downloadStructure");
	if(MCADUtil.getBoolean(downloadStructure))
		isDownloadStructure = true;
		
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	matrix.db.Context context					= integSessionData.getClonedContext(session);
    MCADServerLogger logger						= integSessionData.getLogger();
    MCADLocalConfigObject localConfig			= integSessionData.getLocalConfigObject();

    MCADGlobalConfigObject globalConfigObject		= integSessionData.getGlobalConfigObject(integrationName,context);
	MCADMxUtil util								= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String checkoutDirectoryAttrName				= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-CheckOutDirectory");
	String loadFilesOnCheckoutAttrName				= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-LoadObjectsInCADTool");
	String selectAllChildrenOnCheckoutAttrName		= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-SelectChildItems");
	String selectFirstChildrenOnCheckoutAttrName	= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-SelectFirstLevelChildren");
	String applyViewToChildrenOnlyAttrName			= globalConfigObject.getAttrActualName("attribute_IEF-Pref-IEF-ApplyViewToChildrenOnly");
        
	String workingDirectory					= "";
	boolean loadFilesOnCheckout				= false;
	boolean selectAllChildrenOnCheckout		= false;
	boolean selectFirstLevelChildren		= false;
	boolean applyViewToChildrenOnly			= false;
	
	boolean isUnSupported					= false;
	
	String isCheckoutDirectoryDisabled				= "";
	String checkoutDirectoryHiddenContent				= "";
	String isLoadFilesOnCheckoutDisabled			= "";
	String loadFilesOnCheckoutHiddenContent				= "";
	String isSelectAllChildrenOnCheckoutDisabled	= "";
	String selectAllChildrenOnCheckoutHiddenContent		= "";
	String isSelectFirstLevelChildrenDisabled		= "";
	String selectFirstLevelChildrenHiddenContent		= "";
	String isApplyViewToChildrenOnlyDisabled 		= "";
	String applyViewToChildrenOnlyHiddenContent 		= "";

	String checkoutDirectory						= integSessionData.getStringResource("mcadIntegration.Server.FieldName.CheckoutDirectory");

	String checkoutDirectoryPrefType	= globalConfigObject.getPreferenceType(checkoutDirectoryAttrName);
	if(checkoutDirectoryPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isCheckoutDirectoryDisabled = "disabled";
		workingDirectory = globalConfigObject.getPreferenceValue(checkoutDirectoryAttrName);
	}
	else if(checkoutDirectoryPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		checkoutDirectoryHiddenContent = "style=\"visibility: hidden\"";
		workingDirectory = globalConfigObject.getPreferenceValue(checkoutDirectoryAttrName);
	}
	else
	{
		workingDirectory = localConfig.getCheckoutDirectory(integrationName);
		//do not show default checkout directory value if the alias dir mode is "current"
        /*String userDirAliasMode = localConfig.getUserDirectoryAliasMode(integrationName);
		if(userDirAliasMode.equals(MCADAppletServletProtocol.ATTR_USERDIRALIAS_MODE_CURRENT))
        {
			workingDirectory = "";
        }*/
	}

	String loadFilesOnCheckoutPrefType	= globalConfigObject.getPreferenceType(loadFilesOnCheckoutAttrName);
	if(loadFilesOnCheckoutPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isLoadFilesOnCheckoutDisabled = "disabled";
		loadFilesOnCheckout = globalConfigObject.getPreferenceValue(loadFilesOnCheckoutAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(loadFilesOnCheckoutPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		loadFilesOnCheckoutHiddenContent = "style=\"visibility: hidden\"";
		loadFilesOnCheckout = globalConfigObject.getPreferenceValue(loadFilesOnCheckoutAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(loadFilesOnCheckoutPrefType.equals("UNSUPPORTED"))
	{
		isUnSupported = true;
		loadFilesOnCheckout = false;
	}
	else
	{
		loadFilesOnCheckout = localConfig.isLoadonCheckoutEnabled(integrationName);
	}

	if(isDownloadStructure)
	{
		loadFilesOnCheckout = false;		
		checkoutDirectory	= integSessionData.getStringResource("mcadIntegration.Server.FieldName.DownloadDirectory");
	}
		
	String selectAllChildrenOnCheckoutPrefType	= globalConfigObject.getPreferenceType(selectAllChildrenOnCheckoutAttrName);
	if(selectAllChildrenOnCheckoutPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isSelectAllChildrenOnCheckoutDisabled = "disabled";
		selectAllChildrenOnCheckout = globalConfigObject.getPreferenceValue(selectAllChildrenOnCheckoutAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(selectAllChildrenOnCheckoutPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		selectAllChildrenOnCheckoutHiddenContent = "style=\"visibility: hidden\"";
		selectAllChildrenOnCheckout = globalConfigObject.getPreferenceValue(selectAllChildrenOnCheckoutAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		selectAllChildrenOnCheckout = localConfig.isSelectAllChildrenFlagOn(integrationName);
	}
	
	String applyViewToChildrenOnlyPrefType	= globalConfigObject.getPreferenceType(applyViewToChildrenOnlyAttrName);
	if(applyViewToChildrenOnlyPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isApplyViewToChildrenOnlyDisabled	= "disabled";
		applyViewToChildrenOnly				= globalConfigObject.getPreferenceValue(applyViewToChildrenOnlyAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(applyViewToChildrenOnlyPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		applyViewToChildrenOnlyHiddenContent		= "style=\"visibility: hidden\"";
		applyViewToChildrenOnly				= globalConfigObject.getPreferenceValue(applyViewToChildrenOnlyAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		applyViewToChildrenOnly	= localConfig.isApplyViewToChildrenOnlyFlagOn(integrationName);
	}
	
	String  selectFirstChildrenOnCheckoutPrefType	= globalConfigObject.getPreferenceType(selectFirstChildrenOnCheckoutAttrName);
	if(selectFirstChildrenOnCheckoutPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isSelectFirstLevelChildrenDisabled = "disabled";
		selectFirstLevelChildren			= globalConfigObject.getPreferenceValue(selectFirstChildrenOnCheckoutAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(selectFirstChildrenOnCheckoutPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		selectFirstLevelChildrenHiddenContent	= "style=\"visibility: hidden\"";
		selectFirstLevelChildren			= globalConfigObject.getPreferenceValue(selectFirstChildrenOnCheckoutAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		selectFirstLevelChildren = localConfig.isSelectFirstChildrenFlagOn(integrationName);
	}
	String appName = application.getInitParameter("ematrix.page.path");
	if(appName == null ) appName = "";
	String previewServletPath = appName + "/servlet/MCADBrowserServlet";
%>

<html>
<head>
    <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>
<body>

    <table width="100%" border="0" cellspacing="3" cellpadding="3">
    <!--XSSOK-->
    <tr  <%= checkoutDirectoryHiddenContent %>>
		<form name='directoryChooser'>
          	<!--XSSOK-->
		<td nowrap align='left'><%=checkoutDirectory%>&nbsp
		    <!--XSSOK-->
			<input type='text' name='workingDirectory' value="<%= workingDirectory %>" size=45 readonly>
			<!--XSSOK-->
			<input type='button' name='SomeButton' value="<%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.Choose")%>" onClick='parent.showDirectoryChooser()' <%= isCheckoutDirectoryDisabled %>>
		</td>
		<td nowrap align='left'><p align=left><img src=images/utilSpace.gif width=240 height=16 name=progress></p></td>
		</form>
    </tr>
    </table>
    <table width="100%" border="0" cellspacing="3" cellpadding="3">
    <tr>
		<form name='configOptions'>
<%
	if(!isDownloadStructure && !isUnSupported)
	{
%>		
        	<!--XSSOK-->
		<td nowrap align='left' <%= loadFilesOnCheckoutHiddenContent %> ><input type='checkBox' name='loadFilesOnCheckout' <%= loadFilesOnCheckout?"checked":"" %> <%= isLoadFilesOnCheckoutDisabled %> ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.LoadFiles")%></td>
<%
	}
%>	
            	<!--XSSOK-->
		<td nowrap align='left' <%= applyViewToChildrenOnlyHiddenContent %>><input type='checkBox' name='applyViewToChildrenOnly'  <%= applyViewToChildrenOnly?"checked":"" %> <%= isApplyViewToChildrenOnlyDisabled %> ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ApplyViewToChildrenOnly")%></td>
		<td nowrap align='left'><p align=left><img src=images/utilSpace.gif width=120 height=16></p></td>
		<!--XSSOK-->
		<td nowrap align='right'  <%= selectFirstLevelChildrenHiddenContent%>><input type='checkBox' name='selectFirstLevelChildrenOnCheckout' <%= selectFirstLevelChildren?"checked":"" %> onClick="parent.selectChildrenValidation(this)" <%= isSelectFirstLevelChildrenDisabled%>  ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.SelectFirstLevelChildren")%></td>
		<!--XSSOK-->
		<td nowrap align='right' <%= selectAllChildrenOnCheckoutHiddenContent %>><input type='checkBox' name='selectAllChildrenOnCheckout' <%= selectAllChildrenOnCheckout?"checked":"" %> onClick="parent.selectChildrenValidation(this)" <%= isSelectAllChildrenOnCheckoutDisabled %>  ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.SelectAllChildren")%></td>
		</form>
	</tr>
	<tr></tr>
	</table>
	
	<table width="100%" border="0" cellspacing="3" cellpadding="3">
	<tr>
		<td nowrap align='right'>
			<table border='0'>
			<tr>
			<%
	if(!isDownloadStructure)
	{
%>	
                                <!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLockSelectionForAll(true)'><img src='images/buttonMainMyTasks.gif' border='0' alt="<%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LockAll")%>"></a>&nbsp;</td> 
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLockSelectionForAll(true)'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LockAll")%></a></td>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLockSelectionForAll(false)'><img src='images/buttonRemove.gif' border='0' alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.LockNone")%>"></a>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLockSelectionForAll(false)'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LockNone")%></a></td>
<% 
}
	if(globalConfigObject.isRapidFileAccessEnabled() && !isDownloadStructure)
	{
%>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLocalCheckoutSelectionForAll(true)'><img src='images/buttonMainMyTasks.gif' border='0' alt="<%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LocalCheckoutAll")%>"></a>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLocalCheckoutSelectionForAll(true)'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LocalCheckoutAll")%></a></td>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLocalCheckoutSelectionForAll(false)'><img src='images/buttonRemove.gif' border='0' alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.LocalCheckoutNone")%>"></a>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeLocalCheckoutSelectionForAll(false)'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.LocalCheckoutNone")%></a></td>
<% 
	}
%>				
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeSelectionForMust(true)'><img src='./images/buttonMainMyTasks.gif' border='0' alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.SelectRequired")%>"></a>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.changeSelectionForMust(true)'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.SelectRequired")%></a></td>
				<td nowrap>&nbsp;</td>
<%
	if(isDownloadStructure)
	{
%>
                                <!--XSSOK-->
				<td nowrap><a href='javascript:parent.checkoutSelected()'><img src='../integrations/images/emxUIButtonNext.gif' border='0' alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.DownloadStructure")%>"></a>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.checkoutSelected()'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.DownloadStructure")%></a></td>
<% 
	}
	else
	{
%>
                                <!--XSSOK-->
				<td nowrap><a href='javascript:parent.checkoutSelected()'><img src='../integrations/images/emxUIButtonNext.gif' border='0' alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Checkout")%>"></a>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.checkoutSelected()'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Checkout")%></a></td>
				
<% 
	}
%>
				<td nowrap>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.checkoutCancelled()'><img src='../integrations/images/emxUIButtonCancel.gif' border='0' alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;</td>
				<!--XSSOK-->
				<td nowrap><a href='javascript:parent.checkoutCancelled()'><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
			</tr>
			</table>
		</td>
    </tr>
    </table>
    <!--XSSOK-->
    <form name="previewForm" action="<%=previewServletPath%>" method="post">
        <input type="hidden" name="FileName" value="">
        <input type="hidden" name="FormatName" value="">
        <input type="hidden" name="BusObjectId" value="">
        <input type="hidden" name="Command" value="GetPreviewFile">
    </form>

	<script language="JavaScript">
		var optionArr = new Array();
		var integrationFrame	= getIntegrationFrame(this);
		optionArr = integrationFrame.getFooterOptions();
		if (optionArr != null && optionArr != "")
		{
			if(optionArr[0] != "")
			{
				document.forms["directoryChooser"].workingDirectory.value =  optionArr[0];
			}else 
				document.forms["directoryChooser"].workingDirectory.value = "";
			
			if(null != document.forms["configOptions"].loadFilesOnCheckout && "undefined" != typeof (document.forms["configOptions"].loadFilesOnCheckout))
			{
			if(optionArr[1] == "true")
			{		
				document.forms["configOptions"].loadFilesOnCheckout.checked = true;

			}else
			{
				document.forms["configOptions"].loadFilesOnCheckout.checked = false;
			}
			}

			if(optionArr[2] == "true")
			{		
				document.forms["configOptions"].selectAllChildrenOnCheckout.checked = true;

			}else
			{
				document.forms["configOptions"].selectAllChildrenOnCheckout.checked = false;
			}

			if(optionArr[3] == "true")
			{		
				document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked = true;

			}else
			{
				document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked = false;
			}
			

			if(optionArr[4] == "true")
			{		
				document.forms["configOptions"].applyViewToChildrenOnly.checked = true;

			}else
			{
				document.forms["configOptions"].applyViewToChildrenOnly.checked = false;
			}
				
		}
	
	</script>
	
	<script language="JavaScript">
		var option  = new Array();
		option[0]=document.forms["directoryChooser"].workingDirectory.value;
		//option[2]=document.forms["configOptions"].loadFilesOnCheckout.checked;
		if(null != document.forms["configOptions"].loadFilesOnCheckout && "undefined" != typeof (document.forms["configOptions"].loadFilesOnCheckout))
		{
		option[2]=document.forms["configOptions"].loadFilesOnCheckout.checked;
		}
		else
		{
			option[2]="false";
		}
		option[3]=document.forms["configOptions"].selectAllChildrenOnCheckout.checked;
		option[4]=document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked;
		option[5]=document.forms["configOptions"].applyViewToChildrenOnly.checked;

		var integrationFrame	= getIntegrationFrame(this);
		integrationFrame.setFooterOptions(option);
	</script>
</body>
</html>
