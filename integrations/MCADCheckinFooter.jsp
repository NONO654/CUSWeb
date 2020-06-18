<%--  MCADCheckinFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript">
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</script>
<%	
	String integrationName							=Request.getParameter(request,"integrationName");
	
	MCADIntegrationSessionData integSessionData		= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	MCADLocalConfigObject localConfig								= integSessionData.getLocalConfigObject();	
	MCADGlobalConfigObject globalConfigObject				= integSessionData.getGlobalConfigObject(integrationName, integSessionData.getClonedContext(session));

	String deleteFilesOnCheckinAttrName						= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-DeleteLocalFileOnCheckin");
	String deleteFilesBehaviourOnCheckinAttrName 	= globalConfigObject.getAttrActualName("attribute_IEF-Pref-IEF-DeleteFilesBehaviourOnCheckin");
	String createVersionOnCheckinAttrName					= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-CreateVersionOnCheckin");
	String retainLockOnCheckinAttrName						= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-LockObjectOnCheckin");
	String selectAllChildrenOnCheckinAttrName			= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-SelectChildItems");
	String selectBackgroungCheckinAttrName				= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-BackgroundCheckin");	

	boolean deleteFilesOnCheckin				= false;
	boolean createVersionOnCheckin			= false;
	boolean retainLockOnCheckin					= false;
	boolean selectAllChildrenOnCheckin		= false;
	boolean selectBackgroungCheckin		= false;
	
	String checkInComment										= "";
	
	String deleteFilesOptionValueToShow				= "";
	String deleteFilesOptionValue								= "";
	String isDeleteFilesOnCheckinDisabled			= "";
	String deleteFilesOnCheckinHiddenContent			= "";
	String isCreateVersionOnCheckinDisabled		= "";
	String createVersionOnCheckinHiddenContent	= "";
	String isRetainLockOnCheckinDisabled			= "";		
	String retainLockOnCheckinHiddenContent			= "";
	String isSelectAllChildrenOnCheckinDisabled	= "";
	String selectAllChildrenOnCheckinHiddenContent	= "";
	String isSelectBackgroungCheckinDisabled	= "";
	String selectBackgroungCheckinHiddenContent		= "";
	

	String deleteFilesOnCheckinString	 = integSessionData.getStringResource("mcadIntegration.Server.FieldName.DeleteLocalFilesOnCheckin");
	String deleteOnlySelectedFilesString = integSessionData.getStringResource("mcadIntegration.Server.FieldValue.DeleteOnlySelectedFiles");
	String deleteAllLocalFilesString     = integSessionData.getStringResource("mcadIntegration.Server.FieldValue.DeleteAllLocalFiles");


	String deleteFileBehaviourPrefType	= globalConfigObject.getPreferenceType(deleteFilesBehaviourOnCheckinAttrName);
		deleteFilesOptionValue = globalConfigObject.getPreferenceValue(deleteFilesBehaviourOnCheckinAttrName);
	if(deleteFileBehaviourPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE) || deleteFileBehaviourPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{

		if(deleteFilesOptionValue.equalsIgnoreCase(deleteOnlySelectedFilesString))
			deleteFilesOptionValueToShow = deleteOnlySelectedFilesString;
		else if(deleteFilesOptionValue.equalsIgnoreCase(deleteAllLocalFilesString))
			deleteFilesOptionValueToShow = deleteAllLocalFilesString;
		else
			deleteFilesOptionValueToShow = deleteFilesOnCheckinString;

	}
	else if(deleteFileBehaviourPrefType.equals("DEFAULTVALUE"))
	{
		deleteFilesOptionValue = localConfig.getPreferenceValueForIntegration(integrationName, localConfig.getAttrActualName("attribute_IEF-DeleteFilesBehaviourOnCheckin"));	
		if(deleteFilesOptionValue.equalsIgnoreCase(deleteOnlySelectedFilesString))
			deleteFilesOptionValueToShow = deleteOnlySelectedFilesString;
		else if(deleteFilesOptionValue.equalsIgnoreCase(deleteAllLocalFilesString))
			deleteFilesOptionValueToShow = deleteAllLocalFilesString;
		else
			deleteFilesOptionValueToShow = deleteFilesOnCheckinString;

	}

	String 	deleteFilesOnCheckinPrefType = globalConfigObject.getPreferenceType(deleteFilesOnCheckinAttrName);
	if(deleteFilesOnCheckinPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isDeleteFilesOnCheckinDisabled = "disabled";
		deleteFilesOnCheckin = globalConfigObject.getPreferenceValue(deleteFilesOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(deleteFilesOnCheckinPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		deleteFilesOnCheckinHiddenContent = "style=\"visibility: hidden\"";
		deleteFilesOnCheckin = globalConfigObject.getPreferenceValue(deleteFilesOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		deleteFilesOnCheckin = localConfig.isDeleteLocalFileOnCheckinEnabled(integrationName);
	}

	String createVersionOnCheckinPrefType	= globalConfigObject.getPreferenceType(createVersionOnCheckinAttrName);
	if(createVersionOnCheckinPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isCreateVersionOnCheckinDisabled = "disabled";
		createVersionOnCheckin = globalConfigObject.getPreferenceValue(createVersionOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(createVersionOnCheckinPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		createVersionOnCheckinHiddenContent = "style=\"visibility: hidden\"";
		createVersionOnCheckin = globalConfigObject.getPreferenceValue(createVersionOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		createVersionOnCheckin = localConfig.isCreateVersionOnCheckinFlagOn(integrationName);
	}

	String retainLockOnCheckinPrefType	=  globalConfigObject.getPreferenceType(retainLockOnCheckinAttrName);
	if(retainLockOnCheckinPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isRetainLockOnCheckinDisabled = "disabled";
		retainLockOnCheckin = globalConfigObject.getPreferenceValue(retainLockOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(retainLockOnCheckinPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		retainLockOnCheckinHiddenContent = "style=\"visibility: hidden\"";
		retainLockOnCheckin = globalConfigObject.getPreferenceValue(retainLockOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		retainLockOnCheckin = localConfig.isLockOnCheckinEnabled(integrationName);
	}

	String selectAllChildrenOnCheckinPrefType	= globalConfigObject.getPreferenceType(selectAllChildrenOnCheckinAttrName);
	if(selectAllChildrenOnCheckinPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isSelectAllChildrenOnCheckinDisabled = "disabled";
		selectAllChildrenOnCheckin = globalConfigObject.getPreferenceValue(selectAllChildrenOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(selectAllChildrenOnCheckinPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		selectAllChildrenOnCheckinHiddenContent = "style=\"visibility: hidden\"";
		selectAllChildrenOnCheckin = globalConfigObject.getPreferenceValue(selectAllChildrenOnCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		selectAllChildrenOnCheckin = localConfig.isSelectAllChildrenFlagOn(integrationName);	
	}

	String selectBackgroundCheckinPrefType	= globalConfigObject.getPreferenceType(selectBackgroungCheckinAttrName);
	if(selectBackgroundCheckinPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isSelectBackgroungCheckinDisabled = "disabled";
		selectBackgroungCheckin = globalConfigObject.getPreferenceValue(selectBackgroungCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(selectBackgroundCheckinPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		selectBackgroungCheckinHiddenContent = "style=\"visibility: hidden\"";
		selectBackgroungCheckin = globalConfigObject.getPreferenceValue(selectBackgroungCheckinAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		selectBackgroungCheckin = localConfig.isBackgroundCheckin(integrationName);
	}

%>

<html>
  <head>
  <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
  </head>

  <body>	

	<table width="100%" border="0" align="center" cellspacing="3" cellpadding="3">
		<tr>
			<form action="javascript:parent.validateCheckinComment(this)" name="checkinComment">
			    <!--XSSOK-->
				<td align="left" nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.CheckinComment")%>&nbsp<input type="text" name="checkinComment" size=60></td>
			</form>
		</tr>
	</table>
	
	<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
		<tr>
			<form name="configOptions">
				<%
				if(selectBackgroungCheckin && deleteFilesOnCheckin)

				{
				%>
				<!--XSSOK-->
				<td align="left" nowrap><input type="checkBox" name="deleteFilesOnCheckin" false onClick="parent.deleteFilesRetainLockValidation(this)" ><%=deleteFilesOptionValueToShow%></td>	
				<%
				}else if (selectBackgroungCheckin){				
				%>
				<!--XSSOK-->
				<td align="left" nowrap><input type="checkBox" name="deleteFilesOnCheckin" <%= deleteFilesOnCheckin?"checked":"" %> onClick="parent.deleteFilesRetainLockValidation(this)" disabled ><%=deleteFilesOptionValueToShow%></td>
				<%
				}else if(!selectBackgroungCheckin){
				%>
				<!--XSSOK-->
				<td align="left" nowrap <%= deleteFilesOnCheckinHiddenContent %> ><input type="checkBox" name="deleteFilesOnCheckin" <%= deleteFilesOnCheckin?"checked":"" %> onClick="parent.deleteFilesRetainLockValidation(this)"  <%= isDeleteFilesOnCheckinDisabled %>><%=deleteFilesOptionValueToShow%></td>
				<%
				}
				if(globalConfigObject.isCreateVersionObjectsEnabled())
				{
				%>
				<!--XSSOK-->
				<td align="left" nowrap <%= createVersionOnCheckinHiddenContent %> ><input type="checkBox" name="createVersionOnCheckin" <%= createVersionOnCheckin?"checked":"" %>  <%= isCreateVersionOnCheckinDisabled %>><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.CreateVersionOnCheckin")%></td>
				<%
				}
				else
				{
				%>
				<td align="left" nowrap><input type="hidden" name="createVersionOnCheckin" "disabled"> </td>
				<%
				}
				if(!localConfig.isUseBulkLoadingEnabled(integrationName))
				{
				%>
				<!--XSSOK-->
				<td align="left" nowrap <%= retainLockOnCheckinHiddenContent %> ><input type="checkBox" name="retainLockOnCheckin" <%= retainLockOnCheckin?"checked":"" %> onClick="parent.deleteFilesRetainLockValidation(this)" <%= isRetainLockOnCheckinDisabled %>><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.RetainLockOnCheckin")%></td>
				<%
				}
				else
				{
				%>
				<td align="left" nowrap><input type="hidden" name="retainLockOnCheckin" "disabled"></td>
				<%
				}
				%>
				<%
				if(deleteFilesOnCheckin && selectBackgroungCheckin)
				{				
				%>

				<!--XSSOK-->
				<td align="left" nowrap><input type="checkBox" name="selectBackgroungCheckin" false  onClick="parent.selectBackgroungCheckinValidation(this)" ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.BackgroundCheckin")%></td>
				<%
				}else if (deleteFilesOnCheckin){
				%>
				<!--XSSOK-->
				<td align="left" nowrap><input type="checkBox" name="selectBackgroungCheckin" <%= selectBackgroungCheckin?"checked":"" %>  onClick="parent.selectBackgroungCheckinValidation(this)" disabled ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.BackgroundCheckin")%></td>										
				<%
					}
				else if(!deleteFilesOnCheckin){
				%>
				<!--XSSOK-->
				<td align="left" nowrap <%= selectBackgroungCheckinHiddenContent %> ><input type="checkBox" name="selectBackgroungCheckin" <%= selectBackgroungCheckin?"checked":"" %> onClick="parent.backgroundCheckinValidation(this)" <%= isSelectBackgroungCheckinDisabled %>><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.BackgroundCheckin")%></td>
				<% 
				} 
				%>
				<!--XSSOK-->
				<td align="left" nowrap <%= selectAllChildrenOnCheckinHiddenContent %> ><input type="checkBox" name="selectAllChildrenOnCheckin" <%= selectAllChildrenOnCheckin?"checked":"" %> <%= isSelectAllChildrenOnCheckinDisabled %>><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.SelectAllChildren")%></td>
			</form>
		</tr>
	</table>
	<BR>
	<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
		<tr>
			<td align="left"><p align=left><img src="./images/utilSpace.gif" width=242 height=16 name=progress></p></td>
			<td align="right">
				<table border="0">
					<tr>
					    <!--XSSOK-->
						<td><a href="javascript:parent.globalFolderAssign()"><img src="./images/buttonFolder.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.AssignFolder")%>"></a>&nbsp;</td> 
						<!--XSSOK-->
						<td nowrap><a href="javascript:parent.globalFolderAssign()"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.AssignFolder")%></a></td>
						<td nowrap>&nbsp;</td>
						<!--XSSOK-->
						<td><a href="javascript:parent.changeSelectionForModified(true)"><img src="./images/buttonMainMyTasks.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.SelectModified")%>"></a>&nbsp;</td> 
						<!--XSSOK-->
						<td nowrap><a href="javascript:parent.changeSelectionForModified(true)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.SelectModified")%></a></td>
						<td nowrap>&nbsp;</td>
						<!--XSSOK-->
						<td nowrap><a href="javascript:parent.checkinSelected()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Checkin")%>"></a>&nbsp;</td>
						<!--XSSOK-->
						<td nowrap><a href="javascript:parent.checkinSelected()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Checkin")%></a></td>
						<td nowrap>&nbsp;</td>
						<!--XSSOK-->
						<td nowrap><a href="javascript:parent.checkinCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;</td>
						<!--XSSOK-->
						<td nowrap><a href="javascript:parent.checkinCancelled()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<script language="JavaScript">
		var optionArr = new Array();
		var integrationFrame	= getIntegrationFrame(this);
		optionArr = integrationFrame.getFooterOptions();
		if (optionArr != null && optionArr != "")
		{
				if(optionArr[0] != "")
				{
					document.forms["checkinComment"].checkinComment.value =  optionArr[0];
				}else 
					document.forms["checkinComment"].checkinComment.value = "";

				if(optionArr[1] == "true")
				{		
					document.forms["configOptions"].deleteFilesOnCheckin.checked = true;

				}else
				{
					document.forms["configOptions"].deleteFilesOnCheckin.checked = false;
				}

				if(optionArr[2] == "true")
				{		
					document.forms["configOptions"].createVersionOnCheckin.checked = true;

				}else
				{
					document.forms["configOptions"].createVersionOnCheckin.checked = false;
				}

				if(optionArr[3] == "true")
				{		
					document.forms["configOptions"].retainLockOnCheckin.checked = true;

				}else
				{
					document.forms["configOptions"].retainLockOnCheckin.checked = false;
				}
				

				if(optionArr[4] == "true")
				{		
					document.forms["configOptions"].selectBackgroungCheckin.checked = true;

				}else
				{
					document.forms["configOptions"].selectBackgroungCheckin.checked = false;
				}


				if(optionArr[5] == "true")
				{		
					document.forms["configOptions"].selectAllChildrenOnCheckin.checked = true;

				}else
				{
					document.forms["configOptions"].selectAllChildrenOnCheckin.checked = false;
				}
		}
	
	</script>
	
	<script language="JavaScript">
		var option  = new Array();
		option[0]=document.forms["checkinComment"].checkinComment.value;
		option[1]=document.forms["configOptions"].deleteFilesOnCheckin.checked;
		option[2]=document.forms["configOptions"].createVersionOnCheckin.checked;
		option[3]=document.forms["configOptions"].retainLockOnCheckin.checked;
		option[4]=document.forms["configOptions"].selectBackgroungCheckin.checked;
		option[5]=document.forms["configOptions"].selectAllChildrenOnCheckin.checked;

		var integrationFrame	= getIntegrationFrame(this);
		integrationFrame.setFooterOptions(option);
	</script>
  </body>
</html>

