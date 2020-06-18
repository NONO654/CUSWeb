<%--  IEFGlobalPreferencesContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.MCADIntegration.utils.xml.*" %>
<%@ page import="com.matrixone.MCADIntegration.utils.*" %>
<%@page import = "java.util.*" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%--
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	 Context	context                 = integSessionData.getClonedContext(session);
%>
--%>
<%!
	String GROUP_LABEL	= "Group_Label";
    String FIELD_LABEL	= "Field_Label";
	
	String sEnforceTo = "Enforce To";
	String sDefaultTo = "Default To";

	public String getLabelString(MCADIntegrationSessionData integSessionData, String labelType, String str)
	{
		String labelString = null;
		String key         = "";

		if(labelType.equals(GROUP_LABEL))
		{
			key = "mcadIntegration.Server.Heading." + str;
		}
		else if(labelType.equals(FIELD_LABEL))
		{
			key = "mcadIntegration.Server.FieldName." + str;
		}

		labelString = integSessionData.getStringResource(key);

		if(labelString == null || labelString.equals(""))
		{
			labelString = str;
		}

		return labelString;
	}

	private String getDDAttrType(String selDDAttrValWithType)
	{
		int idx					= selDDAttrValWithType.indexOf(")");
		String selDDAttrType	= selDDAttrValWithType.substring(1, idx);
		return selDDAttrType;
	}
	
	private String getDDValue(String selDDAttrValWithType) 
	{
		int idx				= selDDAttrValWithType.indexOf(")");
		String selDDValue	= selDDAttrValWithType.substring(idx + 1);
		return selDDValue;
	}

	private String getOtherTypeValue(String selDDAttrType)
	{
		String otherTypeValue = "";
		if(selDDAttrType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
			otherTypeValue = sDefaultTo;
		else
			otherTypeValue = sEnforceTo;

		return otherTypeValue;
	}

	private String getDDAttrTypeValue(String selDDAttrType)
	{
		String selDDAttrTypeValue = "";
		if(selDDAttrType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
			selDDAttrTypeValue	= sEnforceTo;
		else
			selDDAttrTypeValue	= sDefaultTo;

		return selDDAttrTypeValue;
	}

	private boolean getPreferenceTypeHidden(HashSet prefTypeSet)
	{
		boolean isHidden	= false;

		//if all the types the field have preference type as "HIDDEN", then entire field will not be shown on panel.
		if(prefTypeSet.contains(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE) && prefTypeSet.size()==1)
		{
			isHidden	= true;
		}
		return isHidden;
	}
	


%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	Context context                 = integSessionData.getClonedContext(session);
	MCADMxUtil util	                = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	
	MCADFolderUtil folderUtil					= new MCADFolderUtil(context, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	boolean isSolutionBased	        = MCADMxUtil.isSolutionBasedEnvironment(context);
	String gcoName         = emxGetParameter(request, "gcoName");
	String integrationName = emxGetParameter(request, "integrationName");
IEFConfigUIUtil iefConfigUIUtil = new IEFConfigUIUtil(context, integSessionData, integrationName);
	String deleteFileOnCheckinAttrName			= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-MCADInteg-DeleteLocalFileOnCheckin");
	String retainLockOnCheckinAttrName			= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-MCADInteg-LockObjectOnCheckin");
	String preferencesPageLayoutJPOAttrName		= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-PreferencesPageLayoutJPO");
	String viewRegistryNameAttrName				= MCADMxUtil.getActualNameForAEFData(context,"attribute_MCADInteg-ViewRegistryName");
	String userDirectoryAliasMode				= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-UserDirectoryAlias-Mode");
	String deleteFilesBehaviourOnCheckin		= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-DeleteFilesBehaviourOnCheckin");
	String selectFirstLevelChildrenOnCheckout	= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-MCADInteg-SelectFirstLevelChildren");
	String selectAllChildrenOnCheckout			= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-MCADInteg-SelectChildItems");
	String defaultVerticalView					= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-DefaultVerticalView");
	String defaultLateralView					= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-DefaultLateralView");
	String PrefViewRegistryNameAttrName			= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-MCADInteg-ViewRegistryName");
	String backGroundCheckinAttrName			= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-MCADInteg-BackgroundCheckin");
	String bulkloadAttrName						= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-IEF-UseBulkLoading");
	String enableProgressiveLoading				= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-EnableProgressiveLoading");
	
        String localCheckoutAttrName				= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-IEF-LocalCheckout");
	
	String sPreferenceName						= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.PreferenceName");
	String sPreferenceValue						= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.PreferenceValue");
	String sRuleToApply							= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.RuleToApply");
	String tableName							= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.WorkspaceTables");
	String webforms								= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Webforms");
	String webformName							= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.webformname");
	String adminTableName						= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.AdminTable");
	String sType								= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Type");
	String sDefaultDesignPolicy					= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.DefaultDesignPolicy");
	String sDefaultVersionPolicy				= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.DefaultVersionPolicy");

	String sCantDeleteFilesWhileRetainingLock = integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileRetainingLock");
	String sCantRetainLockWhileDeletingFiles = integSessionData.getStringResource("mcadIntegration.Server.Message.CantRetainLockWhileDeletingFiles");
	String sCantDeleteFilesWhileBackGroundCheckin	= integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileBackGroundCheckin");
	String sCantBackGroundCheckinWhileDeleteFiles	= integSessionData.getStringResource("mcadIntegration.Server.Message.CantBackGroundCheckinWhileDeleteFiles");
	String sCantDeleteFilesWhileRetainingLockAndBackGroundCheckin  = integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileRetainingLockAndBackGroundCheckin");
	String sCantRetainLockWhileBulkloading  = integSessionData.getStringResource("mcadIntegration.Server.Message.CantRetainLockWhileBulkloading");
	String sCantBulkloadWhileRetainLock  = integSessionData.getStringResource("mcadIntegration.Server.Message.CantBulkloadWhileRetainLock");
	String sCantEnforceLocalCheckoutToFalse  = integSessionData.getStringResource("mcadIntegration.Server.Message.CantEnforceLocalCheckoutToFalse");

	String localisedAdminPrefix   = integSessionData.getStringResource("mcadIntegration.Server.FieldName.AdminTablePrefix");
	String localisedUserPrefix    = integSessionData.getStringResource("mcadIntegration.Server.FieldName.WorkspaceTablePrefix");
%>

<html>

<head>
    <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

	<script language="javascript">

		function deleteFilesRetainLockValidation(deleteFilesRetainLockField)
		{
		        //XSSOK
			var isDeleteFiles		= document.forms["formGlobalPreferences"].elements["<%= deleteFileOnCheckinAttrName %>"].checked;
		        //XSSOK	
			var isRetainLock		= document.forms["formGlobalPreferences"].elements["<%= retainLockOnCheckinAttrName %>"].checked;
		        //XSSOK
			var isBackgroundCheckin	= document.forms["formGlobalPreferences"].elements["<%= backGroundCheckinAttrName %>"].checked;
	        	//XSSOK	
			var isBulkloading		= document.forms["formGlobalPreferences"].elements["<%= bulkloadAttrName %>"].checked;
                        //XSSOK
			if(deleteFilesRetainLockField.name == "<%= deleteFileOnCheckinAttrName %>" && isDeleteFiles )
			{
				if(isBackgroundCheckin && isRetainLock)
				{
					deleteFilesRetainLockField.checked = false;

					alert("<%= XSSUtil.encodeForJavaScript(context, sCantDeleteFilesWhileRetainingLockAndBackGroundCheckin) %>");
				}
				else if(isRetainLock )
				{
					deleteFilesRetainLockField.checked = false;
	
					alert("<%=XSSUtil.encodeForJavaScript(context, sCantDeleteFilesWhileRetainingLock)%>");
				}
				else if(isBackgroundCheckin )
				{
					deleteFilesRetainLockField.checked = false;
			
					alert("<%=XSSUtil.encodeForJavaScript(context, sCantDeleteFilesWhileBackGroundCheckin)  %>");
				}
			}
			//XSSOK
			else if(deleteFilesRetainLockField.name == "<%= retainLockOnCheckinAttrName %>" && isRetainLock)
			{
				if (isDeleteFiles)
				{
					deleteFilesRetainLockField.checked = false;
				
					alert("<%=XSSUtil.encodeForJavaScript(context, sCantRetainLockWhileDeletingFiles)%>");
				}
				else if(isBulkloading)
				{
					deleteFilesRetainLockField.checked = false;
		
					alert("<%=XSSUtil.encodeForJavaScript(context, sCantRetainLockWhileBulkloading)%>");
				}
			}
		}

		function validateBulkLoadingSelection(bulkLoadingCheckbox)
		{
		        //XSSOK
			var isRetainLock		= document.forms["formGlobalPreferences"].elements["<%= retainLockOnCheckinAttrName %>"].checked;
			//XSSOK
			var isBulkloading		= document.forms["formGlobalPreferences"].elements["<%= bulkloadAttrName %>"].checked;

			if(isRetainLock)
			{
				bulkLoadingCheckbox.checked = false;
	
				alert("<%=XSSUtil.encodeForJavaScript(context, sCantBulkloadWhileRetainLock)%>");
			}
		}

		function validateLocalCheckoutSelection(localCheckoutCheckbox)
		{
		        //XSSOK
			var isLocalCheckout	    = document.forms["formGlobalPreferences"].elements["<%= localCheckoutAttrName %>"].checked;
			//XSSOK
			var isLocalCheckoutType = document.forms["formGlobalPreferences"].elements["<%= localCheckoutAttrName %>" + "_Type"].value;
                        //XSSOK
			if(!isLocalCheckout && isLocalCheckoutType == "<%= sEnforceTo %>")
			{
				localCheckoutCheckbox.checked = true;
		
				alert("<%=XSSUtil.encodeForJavaScript(context, sCantEnforceLocalCheckoutToFalse)%>");
			}
		}

		function validateLocalCheckoutTypeSelection(localCheckoutType)
		{
		        //XSSOK
			var isLocalCheckout	    = document.forms["formGlobalPreferences"].elements["<%= localCheckoutAttrName %>"].checked;
			//XSSOK
			var isLocalCheckoutType = document.forms["formGlobalPreferences"].elements["<%= localCheckoutAttrName %>" + "_Type"].value;
                        //XSSOK
			if(!isLocalCheckout && isLocalCheckoutType == "<%= sEnforceTo %>")
			{
			        //XSSOK
				localCheckoutType.value = "<%= sDefaultTo %>";

				alert("<%=XSSUtil.encodeForJavaScript(context, sCantEnforceLocalCheckoutToFalse)%>");
			}
		}

		function selectChildrenValidation(selectChildrenField)
		{
		    //XSSOK
			var isSelectAllChildren			= document.forms['formGlobalPreferences'].elements["<%= selectAllChildrenOnCheckout %>"].checked;
			//XSSOK
			var isSelectFirstLevelChildren	= document.forms['formGlobalPreferences'].elements["<%= selectFirstLevelChildrenOnCheckout %>"].checked;
			//XSSOK
			if(selectChildrenField.name == "<%= selectFirstLevelChildrenOnCheckout %>" && isSelectAllChildren && isSelectFirstLevelChildren)
			{
				selectChildrenField.checked = false;
				//XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotSelectOnlyFirstLevelChildrenWithSelectAllChildrenEnabled")%>");
			}
			//XSSOK
			if(selectChildrenField.name == "<%= selectAllChildrenOnCheckout %>" && isSelectAllChildren && isSelectFirstLevelChildren)
			{
				selectChildrenField.checked = false;
				//XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotSelectAllChildrenWithSelectFirstLevelChildrenEnabled")%>");
			}
		}
		function backgroundCheckinValidation(backgroundCheckinFiled)
		{
		        //XSSOK
			var isDeleteFiles   = document.forms["formGlobalPreferences"].elements["<%= deleteFileOnCheckinAttrName %>"].checked;
			//XSSOK
			var isBackgroundCheckin	= document.forms["formGlobalPreferences"].elements["<%= backGroundCheckinAttrName %>"].checked;
                        //XSSOK
			if(backgroundCheckinFiled.name == "<%= backGroundCheckinAttrName %>" && isBackgroundCheckin && isDeleteFiles )
			{
				backgroundCheckinFiled.checked = false
				
				alert("<%= XSSUtil.encodeForJavaScript(context, sCantBackGroundCheckinWhileDeleteFiles) %>");
			}
			
		}
	</script>
</head>

<body>
	<form name="formGlobalPreferences" method="post" action="IEFGlobalPreferencesHiddenFrame.jsp" target="hiddenFrame">

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
//System.out.println("CSRFINJECTION::IEFGlobalPreferenceContent");
%>

		<input type="hidden" name="attrNameValList" value="">
		<input type="hidden" name="gcoName" value="<xss:encodeForHTMLAttribute><%=gcoName%></xss:encodeForHTMLAttribute>">
		<table border="0" cellspacing="2" cellpadding="3" width="100%">
			<tr>
				<td>
					<table border="0" cellspacing="2" cellpadding="3" width="100%">
						<tr>	
						
							<th width="45%" ><xss:encodeForHTML><%= sPreferenceName %></xss:encodeForHTML></th>
				
							<th width="20%" ><xss:encodeForHTML><%= sRuleToApply %></xss:encodeForHTML></th>
					
							<th width="35%" ><xss:encodeForHTML><%= sPreferenceValue %></xss:encodeForHTML></th>
						</tr>
					</table>
				</td>
			</tr>
<%
	String prefix		= "IEF-Pref-";
	int count			= 0;
	String globalConfigObjectID			= util.getGlobalConfigObjectID(context, "MCADInteg-GlobalConfig", gcoName);
	BusinessObject globalConfigObject	= new BusinessObject(globalConfigObjectID);

	globalConfigObject.open(context);

	String derivedOutputHeader	= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.DependentDocuments");

	Vector selDDAttrLabelList		= new Vector(3);
	selDDAttrLabelList.addElement(integSessionData.getStringResource("mcadIntegration.Server.FieldName.SelectedDerivedOutputs"));
	selDDAttrLabelList.addElement(integSessionData.getStringResource("mcadIntegration.Server.FieldName.SelectedManualDerivedOutputs"));
	selDDAttrLabelList.addElement(integSessionData.getStringResource("mcadIntegration.Server.FieldName.SelectedBackgroundDerivedOutputs"));

	String selectedDerivedOutputsAttrName		= util.getActualNameForAEFData(context,"attribute_MCADInteg-SelectedDerivedOutputs");
	Attribute selDDAttr							= globalConfigObject.getAttributeValues(context, prefix + selectedDerivedOutputsAttrName);
	
	String selectedManualDerivedOutputsAttrName	= util.getActualNameForAEFData(context,"attribute_IEF-SelectedManualDerivedOutputs");
	Attribute selDDManualAttr					= globalConfigObject.getAttributeValues(context, prefix + selectedManualDerivedOutputsAttrName);

	String selectedBackgroundDerivedOutputsAttrName	= util.getActualNameForAEFData(context,"attribute_IEF-SelectedBackgroundDerivedOutputs");
	Attribute selDDBackgroundAttr					= globalConfigObject.getAttributeValues(context, prefix + selectedBackgroundDerivedOutputsAttrName);	

	Vector selDDAttrNameList					= new Vector(3);
	selDDAttrNameList.addElement(selDDAttr.getName());
	selDDAttrNameList.addElement(selDDManualAttr.getName());
	selDDAttrNameList.addElement(selDDBackgroundAttr.getName());

	String selDDAttrValWithType	= selDDAttr.getValue();
	String selDDManualAttrValWithType	= selDDManualAttr.getValue();
	String selDDBackgroundAttrValWithType	= selDDBackgroundAttr.getValue();
	
	Vector selDDValueList						= new Vector(3);
	selDDValueList.addElement(getDDValue(selDDAttrValWithType));
	selDDValueList.addElement(getDDValue(selDDManualAttrValWithType));
	selDDValueList.addElement(getDDValue(selDDBackgroundAttrValWithType));

	String selDDAttrType			= getDDAttrType(selDDAttrValWithType);
	String selDDManualAttrType		= getDDAttrType(selDDManualAttrValWithType);
	String selDDBackgroundAttrType	= getDDAttrType(selDDBackgroundAttrValWithType);

	boolean isDerivedOutputHidden	= false;
	if((MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals(selDDAttrType) && (MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals(selDDManualAttrType) && (MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals(selDDBackgroundAttrType))
	{
		isDerivedOutputHidden	= true;
	}

	Vector actualPrefTypeList			= new Vector();
	actualPrefTypeList.addElement(selDDAttrType);
	actualPrefTypeList.addElement(selDDManualAttrType);
	actualPrefTypeList.addElement(selDDBackgroundAttrType);

	Vector otherTypeValueList				= new Vector();
	otherTypeValueList.addElement(getOtherTypeValue(selDDAttrType));//return "Enforced To" or "Default To"
	otherTypeValueList.addElement(getOtherTypeValue(selDDManualAttrType));
	otherTypeValueList.addElement(getOtherTypeValue(selDDBackgroundAttrType));

	Vector selDDAttrTypeList				= new Vector(3);
	selDDAttrTypeList.addElement(getDDAttrTypeValue(selDDAttrType));//return "Enforced To" or "Default To"
	selDDAttrTypeList.addElement(getDDAttrTypeValue(selDDManualAttrType));
	selDDAttrTypeList.addElement(getDDAttrTypeValue(selDDBackgroundAttrType));

	String createVersionAttrName	= util.getActualNameForAEFData(context,"attribute_IEF-CreateVersionObjects");
	Attribute createVersionObjects	= globalConfigObject.getAttributeValues(context, createVersionAttrName);
	String createVersionObjectsFlag = createVersionObjects.getValue();
	String sAttributeMapping	= integSessionData.getStringResource("mcadIntegration.Server.FieldName.AttributeMapping");
	String sENOVIAToCAD	= integSessionData.getStringResource("mcadIntegration.Server.FieldName.ENOVIAToCAD");
	String sCADToENOVIA	= integSessionData.getStringResource("mcadIntegration.Server.FieldName.CADToENOVIA");

	if(!isDerivedOutputHidden)
	{
%>
			<tr>
				<td>
					<table border="0" cellspacing="2" cellpadding="3" width="100%">
						<tr><th class="category" colspan="3"><xss:encodeForHTML><%= derivedOutputHeader %></xss:encodeForHTML></th></tr>
						
<%		
		for(int i=0 ;i<selDDAttrLabelList.size();i++)
		{
			if(!(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals((String)actualPrefTypeList.elementAt(i)))
			{
%>
						<tr>
						        <!--XSSOK-->
							<td width="45%" class="label"><%= (String)selDDAttrLabelList.elementAt(i) %></td>
							<td width="20%" class="inputField">
							        <!--XSSOK-->
								<select name="<%= (String)selDDAttrNameList.elementAt(i) %>_Type">
								        <!--XSSOK-->
									<option value="<%= (String)selDDAttrTypeList.elementAt(i) %>" selected><%= (String)selDDAttrTypeList.elementAt(i) %></option>
									<!--XSSOK-->
									<option value="<%= (String)otherTypeValueList.elementAt(i) %>"><%= (String)otherTypeValueList.elementAt(i) %></option>
								</select>&nbsp;&nbsp;
							</td>
							<td width="35%" class="inputField">
							        <!--XSSOK-->
								<input type="text" name="<%= (String)selDDAttrNameList.elementAt(i) %>" value="<%= (String)selDDValueList.elementAt(i) %>">
							</td>
						</tr>

<%
			}
		}
%>
     
					<tr><th class="category" colspan="3"><xss:encodeForHTML><%=sAttributeMapping%></xss:encodeForHTML></th></tr>
					<tr>
						<td width="45%" class="label"><xss:encodeForHTML><%=sENOVIAToCAD%></xss:encodeForHTML></td>
						<td width="20%" class="inputField"><a href="javascript:parent.showDialogAttrMapping('ENOVIAToCAD')"><xss:encodeForHTML><%=sENOVIAToCAD%></xss:encodeForHTML></a></td>
						<td width="35%" class="inputField"></td>
					</tr>
					<tr>
						<td width="45%" class="label"><xss:encodeForHTML><%=sCADToENOVIA%></xss:encodeForHTML></td>
						<td width="20%" class="inputField">
						<a href="javascript:parent.showDialogAttrMapping('CADToENOVIA')"><xss:encodeForHTML><%=sCADToENOVIA%></xss:encodeForHTML></a></td>
						<td width="35%" class="inputField"></td>
					</tr>
					</tr>
					</table>
				</td>
			</tr>
			<script language="javascript">
						<% if(!(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals((String)actualPrefTypeList.elementAt(0)))
			{ %>
			        //XSSOK
				parent.attributeNames["<%= count++ %>"] = "<%= (String)selDDAttrNameList.elementAt(0) %>";
					<%}
					if(!(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals((String)actualPrefTypeList.elementAt(1)))
			{ %>
			        //XSSOK
				parent.attributeNames["<%= count++ %>"] = "<%= (String)selDDAttrNameList.elementAt(1) %>";
					<%}
					if(!(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals((String)actualPrefTypeList.elementAt(2)))
			{ %>
			        //XSSOK
				parent.attributeNames["<%= count++ %>"] = "<%= (String)selDDAttrNameList.elementAt(2) %>";
					<%}%>
			</script>
<%
	}

	String defaultTypePolicySettingsHeader    = integSessionData.getStringResource("mcadIntegration.Server.ColumnName.DefaultTypePolicySettings");
	
	Attribute defaultTypePolicySettingsAttr   = globalConfigObject.getAttributeValues(context, prefix + util.getActualNameForAEFData(context,"attribute_MCADInteg-DefaultTypePolicySettings"));
	String defaultTypePolicySettingsAttrName  = defaultTypePolicySettingsAttr.getName();
	String defaultTypePolicySettingsAttrValue = defaultTypePolicySettingsAttr.getValue();
	
	Attribute defaultFolder   = globalConfigObject.getAttributeValues(context,prefix + util.getActualNameForAEFData(context,"attribute_IEF-DefaultFolder"));
	String defaultFolderValue = defaultFolder.getValue();
	StringTokenizer strTokens = new  StringTokenizer(defaultFolderValue,")");
	String defaultFolderTNR = "";
	String defaultFolderAttrType = "";
	String defaultFolderPath = "";
	String type			= "";
	String name			= "";
	String revision		= "";
			
		if(strTokens.countTokens() > 1 )
		{
			defaultFolderAttrType = (String)strTokens.nextToken();
			defaultFolderTNR = (String)strTokens.nextToken();
					
			StringTokenizer tnr = new  StringTokenizer(defaultFolderTNR,",");
			while(tnr.countTokens() > 1)
			{
			type = tnr.nextToken();
			name = tnr.nextToken();
			revision = tnr.nextToken();
			}
		    
            BusinessObject folderObj = new BusinessObject(type, name, revision, "");
            folderObj.open(context);
			String folderId = folderObj.getObjectId();
            folderObj.close(context);
			defaultFolderPath = folderUtil.getWorkspaceFolderPath(context, folderId); 
		
			            
          }		
		  else 
		  {
			 defaultFolderPath = "";
		  }	
	MCADConfigObjectLoader configObjectLoader = new MCADConfigObjectLoader(integSessionData, integSessionData.getLogger());

	String gcoRevision         = MCADMxUtil.getConfigObjectRevision(context);
	
	MCADGlobalConfigObject gco = configObjectLoader.createGlobalConfigObject("MCADInteg-GlobalConfig", gcoName, gcoRevision, context);
	gco.setPreferenceValue(defaultTypePolicySettingsAttrName, defaultTypePolicySettingsAttrValue);

	Hashtable defaultTypePolicySettingsMxTypesAttrTypesMap   = gco.getMxTypesPrefTypesMapFromDefaultTypePolicySettingsAttr();

	HashSet defaultTypePolicySettingsMxTypesAttrTypeCollection  = new HashSet();
	defaultTypePolicySettingsMxTypesAttrTypeCollection.addAll(defaultTypePolicySettingsMxTypesAttrTypesMap.values());

	boolean isHidden	= getPreferenceTypeHidden(defaultTypePolicySettingsMxTypesAttrTypeCollection);

	Hashtable defaultTypePolicySettingsMxTypesDefPoliciesMap = gco.getMxTypesDefPolsMapFromDefaultTypePolicySettingsAttr();
	Vector matrixTypes = gco.getMxTypesFromDefaultTypePolicySettingsAttr();

	if(!isHidden)
	{
%>
			<tr>
				<td>
					<table border="0" cellspacing="2" cellpadding="3" width="100%">
						<tr><th class="category" colspan="4"><xss:encodeForHTML><%= defaultTypePolicySettingsHeader %></xss:encodeForHTML></th></tr>
						<tr>
							<th class="category" width="30%" ><xss:encodeForHTML><%= sType %></xss:encodeForHTML></th>
							<th class="category" width="15%" ><xss:encodeForHTML><%= sRuleToApply %></xss:encodeForHTML></th>
							<th class="category" width="20%" ><xss:encodeForHTML><%= sDefaultDesignPolicy %></xss:encodeForHTML></th>

<!-- [NDM] : H68 -->
						</tr>
<%
	int cnt = 0;
	for(int i=0; i<matrixTypes.size(); i++)
	{
		String matrixType           = (String)matrixTypes.elementAt(i);
		Vector designPoliciesList   = gco.getPolicyListForType(matrixType);
		int designPoliciesListSize  = designPoliciesList.size();
	
//[NDM] : H68 3 lines removed
		Vector defaultPolicies  = (Vector)defaultTypePolicySettingsMxTypesDefPoliciesMap.get(matrixType);
		String defDesignPolicy  = (String)defaultPolicies.firstElement();
//[NDM] : H68		
		String defaultTypePolicySettingsAttrType      = (String)defaultTypePolicySettingsMxTypesAttrTypesMap.get(matrixType);
		String defaultTypePolicySettingsAttrOtherType = "";

		if(defaultTypePolicySettingsAttrType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
		{
			//If hidden then save this particular type to a var and fetch it while sending it for update.
%>
			<script language="javascript">
			                //XSSOK
					parent.matrixTypes["<%= cnt %>"] = "<%= matrixType %>";
					//XSSOK
					parent.hiddenDefaultTypes[<%= cnt %>] = "<%= matrixType %>";
//[NDM] : H68
                                        //XSSOK
					parent.hiddenDefaultTypesValues["<%= cnt++ %>"] = "(" + "<%= defaultTypePolicySettingsAttrType %>" + ")" + "<%= matrixType %>" + "|" + "<%= defDesignPolicy %>" + "\n" ;
			</script>
<%
			continue;
		}
		else if(defaultTypePolicySettingsAttrType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
		{
			defaultTypePolicySettingsAttrOtherType = sDefaultTo;
			defaultTypePolicySettingsAttrType      = sEnforceTo;
		}
		else
		{
			defaultTypePolicySettingsAttrOtherType = sEnforceTo;
			defaultTypePolicySettingsAttrType      = sDefaultTo;
		}
%>
						<tr>
                                                        <!--XSSOK-->
							<td class="label"><%= MCADMxUtil.getNLSName(context, "Type", matrixType, "", "", request.getHeader("Accept-Language"))%></td>
							<td class="inputField">
								<select name="<xss:encodeForHTMLAttribute><%= defaultTypePolicySettingsAttrName %></xss:encodeForHTMLAttribute>_Type[<%= cnt %>]" style="WIDTH: 110px">
						
									<option value="<xss:encodeForHTMLAttribute><%= defaultTypePolicySettingsAttrType %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTMLAttribute><%= defaultTypePolicySettingsAttrType %></xss:encodeForHTMLAttribute></option>
							
									<option value="<xss:encodeForHTMLAttribute><%= defaultTypePolicySettingsAttrOtherType %></xss:encodeForHTMLAttribute>"><xss:encodeForHTMLAttribute><%= defaultTypePolicySettingsAttrOtherType %></xss:encodeForHTMLAttribute></option>
								</select>&nbsp;&nbsp; 
							</td>
							<td class="inputField">
								<select name="<xss:encodeForHTMLAttribute><%= defaultTypePolicySettingsAttrName %></xss:encodeForHTMLAttribute>_DesPol[<%= cnt %>]" style="WIDTH: 150px">
<%									
		if(designPoliciesListSize > 0)
		{
			for(int j=0; j<designPoliciesListSize; j++)
			{
				String optionVal = (String)designPoliciesList.elementAt(j);
				if(optionVal.equals(defDesignPolicy))
				{
%>                                                                      <!--XSSOK-->
									<option value="<xss:encodeForHTMLAttribute><%= optionVal %></xss:encodeForHTMLAttribute>" selected><%= MCADMxUtil.getNLSName(context, "Policy", optionVal, "", "", request.getHeader("Accept-Language")) %></option>
<%
				}
				else
				{
%>                                                                      <!--XSSOK-->
									<option value="<xss:encodeForHTMLAttribute><%= optionVal %></xss:encodeForHTMLAttribute>"><%= MCADMxUtil.getNLSName(context, "Policy", optionVal, "", "", request.getHeader("Accept-Language")) %></option>
<%
				}
			}
		}
%>
								</select>
							</td>
						</tr>
						<script language="javascript">
						        //XSSOK
							parent.matrixTypes["<%= cnt++ %>"] = "<%= matrixType %>";
						</script>
<%
	}
%>
					</table>
				</td>
			</tr>
			<script language="javascript">
			        //XSSOK
				parent.attributeNames["<%= count++ %>"] = '<%= defaultTypePolicySettingsAttrName %>';
			</script>

<%	
	}
	Attribute defConfigTableSetsAttr		 = globalConfigObject.getAttributeValues(context, prefix + util.getActualNameForAEFData(context,"attribute_IEF-DefaultConfigTables"));
	String defConfigTableSetsAttrName	 = defConfigTableSetsAttr.getName();
	String defConfigTableSetsAttrValue  = defConfigTableSetsAttr.getValue();
	gco.setPreferenceValue(defConfigTableSetsAttrName, defConfigTableSetsAttrValue);

	String defaultTableValue		= integSessionData.getStringResource("mcadIntegration.Server.FieldName.DefaultTableName");

	Vector globalPrefContent	= gco.getLabelTableEnforceDefaultList(defaultTableValue);
	boolean isDefaultTableHidden	= false;
	HashSet defaultPrefTypeSet		= new HashSet();
	for(int i=0 ;i<globalPrefContent.size();i++)
	{
		Vector globalPrefContentValue	= (Vector)globalPrefContent.elementAt(i);
		
		String defaultPreferenceType	= (String)globalPrefContentValue.elementAt(1);
		defaultPrefTypeSet.add(defaultPreferenceType);
	
	}
	isDefaultTableHidden	= getPreferenceTypeHidden(defaultPrefTypeSet);
	Vector tableList					= iefConfigUIUtil.getAdminTableNamesWithPrefix(gco);
	tableList.insertElementAt(defaultTableValue, 0);

	int tableListSize	= tableList.size();
	int pageListSize	= globalPrefContent.size();

	if(!isDefaultTableHidden)
	{
%>			
		<table border="0" cellspacing="2" cellpadding="3" width="100%">
			<tr>
				<th class="category" colspan="4"><xss:encodeForHTML><%= sType %></xss:encodeForHTML><%= tableName %></th>
			</tr>
		
			 <tr>
				<th class="category" width ="30%" ><xss:encodeForHTML><%= sType %></xss:encodeForHTML></th>
				<th class="category" width ="15%"  ><xss:encodeForHTML><%= sRuleToApply %></xss:encodeForHTML></th>
				<th class="category" width ="55%" ><xss:encodeForHTML><%= adminTableName %></xss:encodeForHTML></th>
			 </tr>		
<%
	for( int i=0; i<pageListSize; i++)
	{
		Vector globalPrefContentValue	= (Vector)globalPrefContent.elementAt(i);			
		
		String pageKey							= (String)globalPrefContentValue.elementAt(0);
		String defaultEnforceValue			= (String)globalPrefContentValue.elementAt(1);
		String selectedTableValue			= (String)globalPrefContentValue.elementAt(2);
		String pageLabelKey					= (String)globalPrefContentValue.elementAt(3);
        String pageLabel						= integSessionData.getStringResource(pageLabelKey);
		
		if(pageLabel.equals(pageLabelKey))
			pageLabel = pageKey;

		String defaultSelected			= "";
		String enforceSelected		= "";

		if(defaultEnforceValue.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
		{
			//to store rest of attributes.
%>
			
			<script language="javascript">
			                //XSSOK
					parent.pageKeys['<%=i%>'] = "<%= pageKey %>";
					//XSSOK
					parent.hiddenDefaultConfigTypes['<%=i%>'] = "<%= pageKey %>";
					//XSSOK
					parent.hiddenDefaultConfigValues['<%=i%>']=  "(" + "<%= defaultEnforceValue %>" + ")" + "<%= pageKey %>" + "$" + "<%= selectedTableValue %>" + "@";
				</script>
			
<%
			continue;
		}
		else if(defaultEnforceValue.equals("DEFAULTVALUE"))
		{
			defaultSelected = "selected";
		}
		else
		{
			enforceSelected = "selected";
		}
%>		
				
			<tr>
			        <!--XSSOK-->
				<td name = "<%=defConfigTableSetsAttrName%>_pageName[<%=i%>]" class="label">
				        <!--XSSOK-->
					<%=pageLabel%>
				</td>

				<td class="inputField">
				<!--XSSOK-->
				<select name = "<%= defConfigTableSetsAttrName %>_tableListRule[<%= i %>]" style="WIDTH: 110px">				
		                	<!--XSSOK-->	
					<option value = "<%= sDefaultTo %>" <%= defaultSelected %> ><%= sDefaultTo %>
					<!--XSSOK-->
					<option value = "<%= sEnforceTo %>" <%= enforceSelected %> ><%= sEnforceTo %>
			    </td> 

				 <td class="inputField">
				 <!--XSSOK-->
				 <select name = "<%= defConfigTableSetsAttrName %>_tableList[<%= i %>]" style="WIDTH: 240px">
<%
		 String tempTableName = "";
		 for(int j = 0; j < tableListSize; j++)
		 {
			 String selectedTable	= "";			 

			 String tableListDisplayValue	= (String)tableList.elementAt(j);

			 String tableListActualValue = MCADUtil.replaceString(tableListDisplayValue, localisedAdminPrefix, IEFConfigUIUtil.ADMIN_PREFIX);
			 tableListActualValue        = MCADUtil.replaceString(tableListActualValue, localisedUserPrefix, IEFConfigUIUtil.USER_PREFIX);

			 if(tableListActualValue.equals(selectedTableValue))
			 {
				 selectedTable = "selected";
			 }
					
%>
                                                <!--XSSOK-->
						<option value="<%= tableListActualValue %>" <%= selectedTable %> ><%= tableListDisplayValue %>
<%				
		 }
%>
				 </td> 					
              </tr>
				<script language="javascript">
				        //XSSOK
					parent.pageKeys['<%=i%>'] = "<%= pageKey %>";
				</script>
<%					 
	}
%>
		  </table> 

		<script language="javascript">
		        //XSSOK
			parent.attributeNames["<%= count++ %>"] = "<%= defConfigTableSetsAttrName %>";
		</script>

			 <%
	}

	Attribute defWebformsSetsAttr     = globalConfigObject.getAttributeValues(context, prefix + util.getActualNameForAEFData(context,"attribute_IEF-DefaultWebforms"));

	String defWebformsSetsAttrName	 = defWebformsSetsAttr.getName();
	String defWebformsSetsAttrValue   = defWebformsSetsAttr.getValue();

	gco.setPreferenceValue(defWebformsSetsAttrName, defWebformsSetsAttrValue);

	Vector globalPrefWebformContent	= gco.getLabelWebformEnforceDefaultList();
	
	Vector webformList			= gco.getWebFormNames();

	boolean isWebFormTableHidden	= false;
	HashSet webFormPrefTypeSet		= new HashSet();
	for(int i=0 ;i<globalPrefWebformContent.size();i++)
	{
		Vector globalPrefContentValue = (Vector)globalPrefWebformContent.elementAt(i);
		
		String defaultPreferenceType	= (String)globalPrefContentValue.elementAt(1);
		webFormPrefTypeSet.add(defaultPreferenceType);
	
	}
	isWebFormTableHidden	= getPreferenceTypeHidden(webFormPrefTypeSet);

	int webformListtSize	= webformList.size();
	int webformPageListSize	= globalPrefWebformContent.size();

	if(!isWebFormTableHidden)
	{
%>
		<table border="0" cellspacing="2" cellpadding="3" width="100%">
			<tr>
				<th class="category" colspan="4"><xss:encodeForHTML><%= webforms %></xss:encodeForHTML></th>
			</tr>
		
			 <tr>
				<th class="category" width ="30%" ><xss:encodeForHTML><%= sType %></xss:encodeForHTML></th>
				<th class="category" width ="15%"  ><xss:encodeForHTML><%= sRuleToApply %></xss:encodeForHTML></th>
				<th class="category" width ="55%" ><xss:encodeForHTML><%= webformName %></xss:encodeForHTML></th>
			 </tr>	

			 <%

	for( int i=0; i<webformPageListSize; i++)
	{
		Vector globalPrefContentValue = (Vector)globalPrefWebformContent.elementAt(i);			

		String pageKey				= (String)globalPrefContentValue.elementAt(0);
		String defaultEnforceValue	= (String)globalPrefContentValue.elementAt(1);
		String selectedWebformValue	= (String)globalPrefContentValue.elementAt(2);
		String pageLabelKey			= (String)globalPrefContentValue.elementAt(3);
        String pageLabel			= integSessionData.getStringResource(pageLabelKey);
		
		if(pageLabel.equals(pageLabelKey))
			pageLabel = pageKey;

		String defaultSelected		= "";
		String enforceSelected		= "";

		if((MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE).equals(defaultEnforceValue))
		{
			//add here to store variables...
%>
			<script language="javascript">
			                //XSSOK
					parent.webformKeys['<%=i%>'] = "<%= pageKey %>";
					//XSSOK
					parent.hiddenDefaultWebFormTypes['<%=i%>'] = "<%= pageKey %>";
					//XSSOK
					parent.hiddenDefaultWebFormValues['<%=i%>'] = "(" + "<%= defaultEnforceValue %>" + ")" + "<%= pageKey %>" + "$" + "<%= selectedWebformValue %>" + "@";
			</script>
<%
			continue;
		}
		if(defaultEnforceValue.equals("DEFAULTVALUE"))
		{
			defaultSelected = "selected";
		}
		else
		{
			enforceSelected = "selected";
		}
%>		
				
			<tr>
			    <!--XSSOK-->
				<td name = "<%=defWebformsSetsAttrName%>_pageName[<%=i%>]" class="label">
				    <!--XSSOK-->
					<%=pageLabel%>
				</td>

				<td class="inputField">
				<!--XSSOK-->
				<select name = "<%= defWebformsSetsAttrName %>_webformListRule[<%= i %>]" style="WIDTH: 110px">				
                                	<!--XSSOK-->
					<option value = "<%= sDefaultTo %>" <%= defaultSelected %> ><%= sDefaultTo %>
					<!--XSSOK-->
					<option value = "<%= sEnforceTo %>" <%= enforceSelected %> ><%= sEnforceTo %>
			    </td> 

				 <td class="inputField">
				 <!--XSSOK-->
				 <select name = "<%= defWebformsSetsAttrName %>_webformList[<%= i %>]" style="WIDTH: 240px">
<%
		 for(int j = 0; j < webformListtSize; j++)
		 {
			 String  webformListValue	= (String)webformList.elementAt(j);
			 String selectedTable	= "";
			 if(webformListValue.equals(selectedWebformValue))
			 {
				 selectedTable = "selected";
			 }
					
%>
                        <!--XSSOK-->
						<option value="<%= webformListValue %>" <%= selectedTable %> ><%= webformListValue %>
<%				
		 }
%>
				 </td> 					
              </tr>
				<script language="javascript">
				    //XSSOK
					parent.webformKeys['<%=i%>'] = "<%= pageKey %>";
				</script>
<%					 
	}
%>
	</table>
	<script language="javascript">
			parent.attributeNames["<%= count++ %>"] = "<%= XSSUtil.encodeForJavaScript(context,defWebformsSetsAttrName) %>";
		</script>
<%
	}
	//read the attribute on gco which stores preference page layout
	Attribute preferencePageLayoutJPOAttr  = globalConfigObject.getAttributeValues(context, preferencesPageLayoutJPOAttrName);
	String preferencePageLayoutJPO = preferencePageLayoutJPOAttr.getValue();

	String[] args = new String[2];
	args[0]     = integSessionData.getLanguageName();
	args[1]		= createVersionObjectsFlag;

	String preferencePageLayout = util.executeJPO(context, preferencePageLayoutJPO, "getPreferencesPageLayout", args);
	IEFXmlNode rootNode          = MCADXMLUtils.parse(preferencePageLayout, integSessionData.getCharset());
	
	Enumeration categoryList = rootNode.elements();

	while(categoryList.hasMoreElements())
	{
		IEFXmlNode categoryNode = (IEFXmlNode)categoryList.nextElement();

		String categoryName     = categoryNode.getAttribute("name");
		String categoryLabel    = getLabelString(integSessionData, GROUP_LABEL, categoryName);
		
		Enumeration prefsList1 = categoryNode.elements();
		HashSet	hiddenPreferenceList	= new HashSet();
		boolean isCatagoryHidden	= false;

		while(prefsList1.hasMoreElements())
		{
			IEFXmlNode prefNode = (IEFXmlNode)prefsList1.nextElement();
			String prefName	=  prefNode.getAttribute("name");
			
			if(prefName.equalsIgnoreCase("blank"))
				continue;
			Attribute gcoAttribute				= globalConfigObject.getAttributeValues(context, prefix + prefName);
			String attributeValueWithType	= gcoAttribute.getValue();
			
			int index					= attributeValueWithType.indexOf(")");
			String attributeType	= attributeValueWithType.substring(1, index);
			hiddenPreferenceList.add(attributeType);
		}
		isCatagoryHidden	= getPreferenceTypeHidden(hiddenPreferenceList);

		if(!isCatagoryHidden)
		{
%>
			<tr>
				<td>
					<table border="0" cellspacing="2" cellpadding="3" width="100%">

						<tr><th class="category" colspan="3"><xss:encodeForHTML><%= categoryLabel %></xss:encodeForHTML></th></tr>
<%
		Enumeration prefsList = categoryNode.elements();
		while(prefsList.hasMoreElements())
		{
			IEFXmlNode prefNode = (IEFXmlNode)prefsList.nextElement();

			String prefName	=  prefNode.getAttribute("name");
			
			if(prefName.equalsIgnoreCase("blank"))
				continue;

			String label			= (prefNode.getChildByName("label")).getFirstChild().getContent();
			String labelString	= getLabelString(integSessionData, FIELD_LABEL, label);
			String uiType		= (prefNode.getChildByName("uitype")).getFirstChild().getContent();

			Attribute gcoAttribute				= globalConfigObject.getAttributeValues(context, prefix + prefName);
			String attributeValueWithType	= gcoAttribute.getValue();
			String attributeName					= gcoAttribute.getName();

			int index					= attributeValueWithType.indexOf(")");
			String attributeType	= attributeValueWithType.substring(1, index);
			String attributeValue	= attributeValueWithType.substring(index + 1);

			if(isSolutionBased && attributeType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE) &&  (prefName.equals(userDirectoryAliasMode) || prefName.equals(enableProgressiveLoading)))
			{
				attributeType	= "ENFORCED";
			}

			String otherType = "";
			String isHiddenValue	= "";
			String isHiddenType		= attributeType;

			if(attributeType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
			{ 
					isHiddenValue	= " style=\"display: none\" ";
			}
			else if(attributeType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
			{
				otherType = sDefaultTo;
				attributeType = sEnforceTo;
			}
			else if(attributeType.equals("UNSUPPORTED"))
			{
				continue;
			}
			else
			{
				otherType = sEnforceTo;
				attributeType = sDefaultTo;
			}
%>
                <!--XSSOK-->
				<tr <%= isHiddenValue %> >
				
					<td width="45%" class="label"><xss:encodeForHTML><%= labelString %></xss:encodeForHTML></td>
					<td width="20%" class="inputField">

<%
					if(attributeName.equals(localCheckoutAttrName))
					{
%>
						<select name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>_Type" onChange="javascript:validateLocalCheckoutTypeSelection(this)">
<%
					}
					else
					{
%>
							<select name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>_Type">
<%
					}
%>	              
							<option value="<xss:encodeForHTMLAttribute><%= attributeType %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTMLAttribute><%= attributeType %></xss:encodeForHTMLAttribute></option>

							<option value="<xss:encodeForHTMLAttribute><%= otherType %></xss:encodeForHTMLAttribute>"><xss:encodeForHTMLAttribute><%= otherType %></xss:encodeForHTMLAttribute></option>
						</select>&nbsp;&nbsp;
					</td>
					<td width="35%" class="inputField">
<%
			if(uiType.equalsIgnoreCase("PopupList"))
			{
%>
								<input type="text" name="<xss:encodeForHTML><%=attributeName%></xss:encodeForHTML>" value="<xss:encodeForHTMLAttribute><%= attributeValue %></xss:encodeForHTMLAttribute>" readonly>&nbsp;&nbsp;
								<input type="button" name="directoryChooser" value="..." alt="..." size="200" onClick="javascript:parent.showDirectoryChooser('<%=XSSUtil.encodeForJavaScript(context,attributeName)%>')">

<%
			}
			else if(uiType.equalsIgnoreCase("SearchBox"))
			{
%>           
			    <input type="text" name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>_text" value="<xss:encodeForHTMLAttribute><%=defaultFolderPath%></xss:encodeForHTMLAttribute>"
				readonly>&nbsp;&nbsp;					
				<input type="hidden" name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=attributeValue%></xss:encodeForHTMLAttribute>" readonly>
				<input type="button" name="FolderChooser" value="..." title="..." size="200" onClick="javascript:parent.showFolderChooser('<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>_text','<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>')"/>&nbsp;
				<!--XSSOK-->
				<input type="button" name="Clear" value="<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ClearSelectedFolder")%>" title="<%=integSessionData.getStringResource("mcadIntegration.Server.AltText.Clear ")%>" size="200" onclick="javascript:parent.clearSelectedFolder('<%= attributeName %>_text','<%= attributeName %>')"/>
<%
			}
			else if(uiType.equalsIgnoreCase("CheckBox"))
			{	
				String eventHandler = "";
				if(attributeName.equals(deleteFileOnCheckinAttrName) || attributeName.equals(retainLockOnCheckinAttrName))
				{
					eventHandler = "onClick=\"javascript:deleteFilesRetainLockValidation(this)\"";
				}
				else if(attributeName.equals(selectFirstLevelChildrenOnCheckout) || attributeName.equals(selectAllChildrenOnCheckout))
				{
					eventHandler = "onClick=\"javascript:selectChildrenValidation(this)\"";
				}
				else if(attributeName.equals(backGroundCheckinAttrName))
				{
					eventHandler = "onClick=\"javascript:backgroundCheckinValidation(this)\"";
				}
				else if(attributeName.equals(bulkloadAttrName))
				{
					eventHandler = "onClick=\"javascript:validateBulkLoadingSelection(this)\"";
				}
				else if(attributeName.equals(localCheckoutAttrName))
				{
					eventHandler = "onClick=\"javascript:validateLocalCheckoutSelection(this)\"";
				}

				if(attributeValue.equalsIgnoreCase("TRUE"))
				{
%>
                                <!--XSSOK-->
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>" checked <%= eventHandler %>>
<%
				}
				else
				{
%>
                                <!--XSSOK-->
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>" <%= eventHandler %>>
<%
				}
			}
			else if(uiType.equalsIgnoreCase("ComboBox"))
			{
				if(prefName.equalsIgnoreCase(viewRegistryNameAttrName))
				{
					String viewRegistryTypeName = util.getActualNameForAEFData(context,"type_MCADInteg-CheckoutViewProgramRegistry").trim();
					Vector registryNames        = util.getAllObjectNames(context, viewRegistryTypeName, "*", "*");
					
					if(registryNames != null && registryNames.size() > 0)
					{
%>
								<select name="<xss:encodeForHTML><%= attributeName %></xss:encodeForHTML>">
<%
						for(int i=0; i<registryNames.size(); i++)
						{
							String registryName = (String)registryNames.elementAt(i);
							if(registryName.equals(attributeValue))
							{
%>
									<option value="<xss:encodeForHTMLAttribute><%= registryName %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%= registryName %></xss:encodeForHTML>
<%
							}
							else
							{
%>
									<option value="<xss:encodeForHTMLAttribute><%= registryName %></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%= registryName %></xss:encodeForHTML>
<%
							}
						}
%>
								</select>
<%
					}
					
				}
				else if(prefName.equalsIgnoreCase(deleteFilesBehaviourOnCheckin))
				{
					String optionsString = (prefNode.getChildByName("options")).getFirstChild().getContent();
					Vector optionsValues = MCADUtil.getVectorFromString(optionsString, "|");

					if(optionsValues != null && optionsValues.size() > 0)
					{
%>

						<select name="<xss:encodeForHTML><%= attributeName %></xss:encodeForHTML>">
<%
						for(int i=0; i<optionsValues.size(); i++)
						{
							String optionKey				= (String)optionsValues.elementAt(i);
							String key						= "mcadIntegration.Server.FieldValue." + optionKey;
							String optionsValueStr		= integSessionData.getStringResource(key);
							String optionsValueValStr	= "";

							if(optionKey.equalsIgnoreCase("DeleteOnlySelectedFiles"))
								optionsValueValStr	= "Delete Selected Local Files";
							else if(optionKey.equalsIgnoreCase("DeleteAllLocalFiles"))
								optionsValueValStr	= "Delete All Local Files";
							
							if(optionsValueValStr.equals(attributeValue))
							{
%>             
								<option value="<xss:encodeForHTMLAttribute><%= optionsValueValStr %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%= optionsValueStr %></xss:encodeForHTML>
<%
							}
							else
							{
%>           
								<option value="<xss:encodeForHTMLAttribute><%= optionsValueValStr %></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%= optionsValueStr %></xss:encodeForHTML>
<%
							}
						}
%>
						</select>
<%
					}
				}
				else if(prefName.equalsIgnoreCase(userDirectoryAliasMode))
				{
					String optionsString = (prefNode.getChildByName("options")).getFirstChild().getContent();
					Vector optionsValues = MCADUtil.getVectorFromString(optionsString, "|");

					if(optionsValues != null && optionsValues.size() > 0)
					{
%>
						<select name="<xss:encodeForHTML><%= attributeName %></xss:encodeForHTML>">
<%
						for(int i=0; i<optionsValues.size(); i++)
						{
							String optionKey				= (String)optionsValues.elementAt(i);
							String key						= "mcadIntegration.Server.FieldValue." + optionKey;
							String optionsValueStr		= integSessionData.getStringResource(key);
							String optionsValueValStr	= "";

							if(optionKey.equalsIgnoreCase("Current"))
								optionsValueValStr	= "current";
							else if(optionKey.equalsIgnoreCase("Allowed"))
								optionsValueValStr	= "allowed";
							else if(optionKey.equalsIgnoreCase("NotAllowed"))
								optionsValueValStr	= "not allowed";
							
							if(optionsValueValStr.equals(attributeValue))
							{
%>                                                              <!--XSSOK-->
								<option value="<xss:encodeForHTMLAttribute><%= optionsValueValStr %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%= optionsValueStr %></xss:encodeForHTML>
<%
							}
							else
							{
%>                                                              <!--XSSOK-->
								<option value="<xss:encodeForHTMLAttribute><%= optionsValueValStr %></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%= optionsValueStr %></xss:encodeForHTML>
<%
							}
						}
%>
						</select>
<%
					}
				}
				
				else if(prefName.equalsIgnoreCase(defaultLateralView))
				{
					boolean isSelected = false;
					String checkoutViewRegistryName			= gco.getPreferenceValue(PrefViewRegistryNameAttrName);
					Hashtable lateralViewProgNameMapping    = util.readLateralNavigationProgNameMapping(context,checkoutViewRegistryName);
					
					if(lateralViewProgNameMapping != null)
					{
					
%>
						<select name="<xss:encodeForHTML><%= attributeName %></xss:encodeForHTML>">
<%
				
						Enumeration availableViews = lateralViewProgNameMapping.keys();
						do
						{

								String option = (String)availableViews.nextElement();
								String optionDisplay=  getLabelString(integSessionData, FIELD_LABEL, option);
								if(option.equals(attributeValue))
								{
									isSelected = true;
%>        
									<option value="<xss:encodeForHTMLAttribute><%= option %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%= optionDisplay %></xss:encodeForHTML>
<%
								}
								else
								{
%>

									<option value="<xss:encodeForHTMLAttribute><%= option %></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%= optionDisplay %></xss:encodeForHTML>
<%
								}
						}while(availableViews.hasMoreElements());
						String viewAsBuilt = MCADAppletServletProtocol.VIEW_AS_BUILT;
						if(isSelected)
								{
%>                                                                      <!--XSSOK-->
									<option value="<%= viewAsBuilt %>" > <%= getLabelString(integSessionData, FIELD_LABEL, viewAsBuilt) %>
<%
								}
								else
								{
%>                                                                      <!--XSSOK-->
									<option value="<%= viewAsBuilt %>" selected> <%= getLabelString(integSessionData, FIELD_LABEL, viewAsBuilt) %>
<%
								}

%>
						</select>
<%
					}			
										
				}

				else if(prefName.equalsIgnoreCase(defaultVerticalView))
				{
					boolean isSelected = false;
					String checkoutViewRegistryName			= gco.getPreferenceValue(PrefViewRegistryNameAttrName);
					Hashtable verticalViewProgNameMapping    = util.readVerticalNavigationProgNameMapping(context,checkoutViewRegistryName);
					if(verticalViewProgNameMapping != null)
					{
					
%>
						<select name="<xss:encodeForHTML><%= attributeName %></xss:encodeForHTML>">
<%
						
						Enumeration availableViews = verticalViewProgNameMapping.keys();
						do
						{

								String option = (String)availableViews.nextElement();
								String optionDisplay=  getLabelString(integSessionData, FIELD_LABEL, option);
								if(option.equals(attributeValue))
								{
									isSelected = true;
%>
									<option value="<xss:encodeForHTMLAttribute><%= option %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%= optionDisplay %></xss:encodeForHTML>
<%
								}
								else
								{
%>
									<option value="<xss:encodeForHTMLAttribute><%= option %></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%= optionDisplay %></xss:encodeForHTML>
<%
								}
						}while(availableViews.hasMoreElements());

						if(isSelected)
								{
%>                                                                      <!--XSSOK-->
									<option value="None" > <%= getLabelString(integSessionData, FIELD_LABEL, "None") %>
<%
								}
								else
								{
%>                                                                      <!--XSSOK-->
									<option value="None" selected> <%= getLabelString(integSessionData, FIELD_LABEL, "None") %>
<%
								}
%>
						</select>
<%
					}			
										
				}
				else
				{
					String optionsString = (prefNode.getChildByName("options")).getFirstChild().getContent();
					Vector optionsValues = MCADUtil.getVectorFromString(optionsString, "|");

					if(optionsValues != null && optionsValues.size() > 0)
					{
%>
						<select name="<xss:encodeForHTML><%= attributeName %></xss:encodeForHTML>">
<%
						for(int i=0; i<optionsValues.size(); i++)
						{
							String optionKey			= (String)optionsValues.elementAt(i);
							String key					= "mcadIntegration.Server.FieldValue." + optionKey;

							String optionsValueStr		= "";
							String optionsValueValStr	= "";
							optionsValueStr				= integSessionData.getStringResource(key);
							optionsValueValStr			= integSessionData.getStringResource(key);
							
							if(optionsValueValStr.equals("") || optionsValueValStr.equals(key))
							{
								optionsValueStr			= optionKey;
								optionsValueValStr		= optionKey;
							}

							if(optionsValueValStr.equals(attributeValue))
							{
%>  
								<option value="<xss:encodeForHTMLAttribute><%= optionsValueValStr %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%= optionsValueStr %></xss:encodeForHTML>
<%
							}
							else
							{
%>     
								<option value="<xss:encodeForHTMLAttribute><%= optionsValueValStr %></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%= optionsValueStr %></xss:encodeForHTML>
<%
							}
						}
%>
						</select>
<%
					}
				}
			}
			else
			{
%>
								<input type="text" name="<xss:encodeForHTMLAttribute><%= attributeName %></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%= attributeValue %></xss:encodeForHTMLAttribute>">
<%
			}

%>
							</td>	
						</tr>
						<%
						if(!isHiddenType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
						{
						%>
						<script language="javascript">
							parent.attributeNames["<%= count++ %>"] = '<%= XSSUtil.encodeForJavaScript(context, attributeName) %>';	
						</script>
						<%} %>
<%
		}
%>
					</table>
				<td>
			</tr>
<%
		}
		
	}	
	
	globalConfigObject.close(context);
%>					
		</table>
	</form>
</body>

</html>

