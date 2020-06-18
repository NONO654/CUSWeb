<%--  MCADDependentDocsFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	matrix.db.Context Context					= integSessionData.getClonedContext(session);
	String integrationName						= Request.getParameter(request,"integrationName");
    MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName, Context);
	MCADLocalConfigObject localConfig			= integSessionData.getLocalConfigObject();
	MCADMxUtil util								= new MCADMxUtil(Context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String applyToChildrenAttrName		= util.getActualNameForAEFData(Context, "attribute_IEF-Pref-MCADInteg-ApplyToChildren");
	String isApplyToChildrenDisabled	= "";
	String applyToChildrenHiddenContent	= "";
	boolean applyToChildrenOnCheckin	= false;

	String applyToChildrenPrefType	= globalConfigObject.getPreferenceType(applyToChildrenAttrName);
	if(applyToChildrenPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isApplyToChildrenDisabled = "disabled";
		applyToChildrenOnCheckin = globalConfigObject.getPreferenceValue(applyToChildrenAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(applyToChildrenPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		applyToChildrenHiddenContent	= "style=\"visibility: hidden\"";
	}
	else
	{
		applyToChildrenOnCheckin = localConfig.isApplyToChildrenFlagOn(integrationName);
	}

%>

<html>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIDialog.css" type="text/css">
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript">
	function doDone()
	{
      var framecontentFrame = findFrame(top,"contentFrame");
	  framecontentFrame.formSubmit();
	}

	function doCancel()
	{
		//this will call bodyunload event in content.jsp
		top.close();
	}

</script>
</head>

<body>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr><td>&nbsp</td></tr>
		<tr>
			<td align="right">
				<table border="0">
					<tr>
						<form name="dependentDocOptions">
						<td align="left" nowrap <%= applyToChildrenHiddenContent %> ><input type="checkBox" name="applyToChildrenOnCheckin" <%= isApplyToChildrenDisabled %> <%= applyToChildrenOnCheckin?"checked":"" %>><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ApplyToChildrenOnCheckin")%></td>
						</form>
						<td align="right"><a href="javascript:doDone()"><img src="../common/images/buttonDialogDone.gif" border="0"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%></a></td>
						<td align="right"><a href="javascript:doCancel()"><img src="../common/images/buttonDialogCancel.gif" border="0"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>
