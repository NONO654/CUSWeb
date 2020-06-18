<%--  MCADSaveAsHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.util.*" %>

<%!

    public String getLateralViewSelectControlString(Hashtable lateralNavigationProgNameMapping, String preferenceType, MCADIntegrationSessionData integSessionData)
    {
        StringBuffer viewSelectControlBuffer = new StringBuffer(" <select name=\"lateralViewsComboControl\" onChange=\"parent.selectedChangeViewProgram(true)\"");
		if(preferenceType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
		{
			viewSelectControlBuffer.append(" disabled ");
		}
	
		viewSelectControlBuffer.append(">\n");
		viewSelectControlBuffer.append(" <option value=\"" + MCADAppletServletProtocol.VIEW_AS_BUILT + "\">" + integSessionData.getStringResource("mcadIntegration.Server.FieldName.As-Built") + "</option>\n");

        if(lateralNavigationProgNameMapping != null)
        {
            Enumeration availableViews = lateralNavigationProgNameMapping.keys();
            while(availableViews.hasMoreElements())
            {
                String option = (String)availableViews.nextElement();

				String viewLabel = integSessionData.getStringResource("mcadIntegration.Server.FieldName." + option);

                viewSelectControlBuffer.append(" <option value=\"" + option + "\">" + viewLabel + "</option>\n");
            }
        }

        viewSelectControlBuffer.append(" </select>\n");
		return viewSelectControlBuffer.toString();
    }

	public String getVerticalViewSelectControlString(Hashtable verticalNavigationProgNameMapping, String preferenceType, MCADIntegrationSessionData integSessionData)
    {
        StringBuffer viewSelectControlBuffer = new StringBuffer(" <select name=\"verticalViewsComboControl\" onChange=\"parent.selectedChangeViewProgram(true)\"");

		if(preferenceType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
		{
			viewSelectControlBuffer.append(" disabled ");
		}
		viewSelectControlBuffer.append(">\n");

        viewSelectControlBuffer.append(" <option value=\"" + MCADAppletServletProtocol.VIEW_NONE + "\">" + integSessionData.getStringResource("mcadIntegration.Server.FieldName.None") + "</option>\n");

        if(verticalNavigationProgNameMapping != null)
        {
            Enumeration availableViews = verticalNavigationProgNameMapping.keys();
            while(availableViews.hasMoreElements())
            {
                String option = (String)availableViews.nextElement();

				String viewLabel = integSessionData.getStringResource("mcadIntegration.Server.FieldName." + option);

                viewSelectControlBuffer.append(" <option value=\"" + option + "\">" + viewLabel + "</option>\n");
            }
        }

        viewSelectControlBuffer.append(" </select>\n");

        return viewSelectControlBuffer.toString();
    }
%>

<%
	String integrationName						= Request.getParameter(request,"integrationName");
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	matrix.db.Context context					= integSessionData.getClonedContext(session);
	MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);

	String defaultVerticalView					= globalConfigObject.getAttrActualName("attribute_IEF-Pref-IEF-DefaultVerticalView");
	String defaultLateralView					= globalConfigObject.getAttrActualName("attribute_IEF-Pref-IEF-DefaultLateralView");


	String defaultVerticalViewHiddenHTMLContent			= "";
	String defaultLateralViewHiddenHTMLContent			= "";
	String refreshOptionsHiddenHTMLContent				= "";

	String defaultVerticalViewPrefType	= globalConfigObject.getPreferenceType(defaultVerticalView);
	String defaultLateralViewPrefType	= globalConfigObject.getPreferenceType(defaultLateralView);


    if(defaultVerticalViewPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		defaultVerticalViewHiddenHTMLContent	= " style=\"visibility: hidden\" ";
	}


	if(defaultLateralViewPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		defaultLateralViewHiddenHTMLContent = " style=\"visibility: hidden\" ";	
	}
	
	if(defaultLateralViewPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE) && defaultVerticalViewPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		refreshOptionsHiddenHTMLContent	=  " style=\"visibility: hidden\" ";	
	}

	MCADMxUtil util	= new MCADMxUtil(integSessionData.getClonedContext(session), integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
	String checkoutViewRegistryName			= localConfigObject.getViewRegistryName(integrationName);

	Hashtable verticalViewProgNameMapping   = util.readVerticalNavigationProgNameMapping(integSessionData.getClonedContext(session),checkoutViewRegistryName);
	Hashtable lateralViewProgNameMapping    = util.readLateralNavigationProgNameMapping(integSessionData.getClonedContext(session),checkoutViewRegistryName);
%>

<html>
<head>
	<title>emxTableControls</title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

	<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>
	<script language="javascript" type="text/javascript" src="./scripts/MCADUtilMethods.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

</head>
<body>
	<form name="views" onsubmit="return false">
	<input type="hidden" name="integrationName" value="<%=integrationName%>">
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
		<tr>
			<td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
	</table>
        <table border="0" cellspacing="2" cellpadding="2" width="100%">
		<tr>
			<td nowrap width="1%" class="pageHeader"><%=integSessionData.getStringResource("mcadIntegration.Server.Title.SaveAs")%></td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpace.gif" width="16" height="16" name="imgProgress"></td>
			<td align="right" <%= defaultVerticalViewHiddenHTMLContent %>><b><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.RelatedVerticalViews")%></b>
			<%=getVerticalViewSelectControlString(verticalViewProgNameMapping, defaultVerticalViewPrefType,  integSessionData)%>
			&nbsp;&nbsp;</td>
			<td align="right" <%= defaultLateralViewHiddenHTMLContent %>><b><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.RelatedLateralViews")%></b>
        <%=getLateralViewSelectControlString(lateralViewProgNameMapping, defaultLateralViewPrefType,  integSessionData)%>
			</td>
		</tr>
	</table>
	<table border="0" cellspacing="2" cellpadding="0" width="100%" <%= refreshOptionsHiddenHTMLContent %>>
        <tr>
			<td align="right">			
			<a href="javascript:parent.applyViewsSelected(true)"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RefreshSelected")%></a>&nbsp;&nbsp;&nbsp;
			<a href="javascript:parent.applyViewsSelected(false)"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RefreshAll")%></a>&nbsp;&nbsp;&nbsp;
			<a href="javascript:parent.resetToAsStored()"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.ResetToDefault")%></a>&nbsp;&nbsp;&nbsp;
			<a href='javascript:openIEFHelp("emxhelpdscsaveas")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			</td>
        </tr>
    </table>
	
	</form>

	<script language="javascript">
	
		var viewsDetail = parent.treeControlObject.getViewsDetails();
		var viewDetailsElements = viewsDetail.split('|');
		document.forms['views'].verticalViewsComboControl.value	= viewDetailsElements[0];
		document.forms['views'].lateralViewsComboControl.value	= viewDetailsElements[1];
	</script>

</body>
</html>
