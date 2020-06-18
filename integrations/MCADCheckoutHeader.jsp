<%--  MCADCheckoutHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.*" %>

<%! 

	public String getLateralViewSelectControlStringBaseline(Hashtable lateralNavigationProgNameMapping, String preferenceType, MCADIntegrationSessionData integSessionData, String baselineId)
    {
        StringBuffer viewSelectControlBuffer = new StringBuffer(" <select name=\"lateralViewsComboControl\" onChange=\"parent.selectedChangeViewProgram(true)\"");
		if(preferenceType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
		{
			viewSelectControlBuffer.append(" disabled ");
		}
		String sViewBaselineValue = MCADAppletServletProtocol.VIEW_BASELINE;//read from properties; 
		String sViewBaselineDisplay = integSessionData.getStringResource("mcadIntegration.Server.FieldName.Baseline");


		viewSelectControlBuffer.append(">\n");
		viewSelectControlBuffer.append(" <option value=\"" + sViewBaselineValue + "\">" + sViewBaselineDisplay + "</option>\n");

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

	public String getLateralViewSelectControlString(Hashtable lateralNavigationProgNameMapping, String preferenceType, MCADIntegrationSessionData integSessionData,String integrationName)
    {
        StringBuffer viewSelectControlBuffer = new StringBuffer(" <select name=\"lateralViewsComboControl\" onChange=\"parent.selectedChangeViewProgram(true)\"");
		if(preferenceType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
		{
			viewSelectControlBuffer.append(" disabled ");
		}
		        String isAsSavedViewSupported		= UINavigatorUtil.getI18nString("emxDesignerCentral.LateralViews.EnableAsSavedView","emxIEFDesignCenter", integSessionData.getLanguageName());			
				boolean bisAsSavedViewSupported = false;
				if(isAsSavedViewSupported.contains(integrationName)){
				bisAsSavedViewSupported =  true;
			}

if(!bisAsSavedViewSupported)
        {
		viewSelectControlBuffer.append(">\n");
		viewSelectControlBuffer.append(" <option value=\"" + MCADAppletServletProtocol.VIEW_AS_BUILT + "\">" + integSessionData.getStringResource("mcadIntegration.Server.FieldName.As-Built") + "</option>\n");

		}
else if(lateralNavigationProgNameMapping != null ){
		viewSelectControlBuffer.append(">\n");
		viewSelectControlBuffer.append(" <option value=\"" + MCADAppletServletProtocol.VIEW_AS_BUILT + "\">" + integSessionData.getStringResource("mcadIntegration.Server.FieldName.As-Built") + "</option>\n");

}
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
			if(bisAsSavedViewSupported)
			{
				viewSelectControlBuffer.append(">\n");		
				viewSelectControlBuffer.append(" <option value=\"" + MCADAppletServletProtocol.VIEW_AsSaved + "\">" + integSessionData.getStringResource("mcadIntegration.Server.FieldName.As-Saved") + "</option>\n");
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
	String downloadStructure						= Request.getParameter(request,"downloadStructure");
	String isVersionedObject 					= Request.getParameter(request,"isVersionedObject"); 


	String fromBaselineOpen 					= Request.getParameter(request,"fromBaselineOpen"); 





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
	String defaultExpandLevel				= localConfigObject.getDefaultExpandLevel(integrationName);

	String expandLevel = defaultExpandLevel;
	String showLevel   = Request.getParameter(request,"showLevel");
	if(showLevel != null && !showLevel.equals(""))
	{
		expandLevel = showLevel;
	}
	if(defaultExpandLevel != null && defaultExpandLevel.equalsIgnoreCase("All"))
	{
		expandLevel = integSessionData.getStringResource("mcadIntegration.Server.FieldName.All");
	}
    
	Hashtable lateralViewProgNameMapping    = null;
	
	// [NDM] QWJ : if isVersionedObject = true then don't compute lateral view information
	if(null == isVersionedObject || "".equals(isVersionedObject) || !isVersionedObject.equalsIgnoreCase("true"))
		lateralViewProgNameMapping = util.readLateralNavigationProgNameMapping(integSessionData.getClonedContext(session),checkoutViewRegistryName);	
		
    Hashtable verticalViewProgNameMapping   = util.readVerticalNavigationProgNameMapping(integSessionData.getClonedContext(session),checkoutViewRegistryName);


String sLateralViewHtmlContent = getLateralViewSelectControlString(lateralViewProgNameMapping, defaultLateralViewPrefType, integSessionData, integrationName);




String sTitleDownload = integSessionData.getStringResource("mcadIntegration.Server.Title.DownloadStructure");
String sPageHeader = sTitleDownload;
	if(null != fromBaselineOpen && !"".equals(fromBaselineOpen) && fromBaselineOpen.equalsIgnoreCase("true"))
	{
	String baselineId 					= Request.getParameter(request,"baselineId"); 

DomainObject doTmp = DomainObject.newInstance(context,baselineId);
String sNameBaseline = doTmp.getName(context);


		verticalViewProgNameMapping = null;
		sLateralViewHtmlContent = getLateralViewSelectControlStringBaseline(lateralViewProgNameMapping, defaultLateralViewPrefType, integSessionData, baselineId);
		
		String sTitleBaseline = integSessionData.getStringResource("mcadIntegration.Server.Title.Baseline");
		sPageHeader = sTitleBaseline + " : " + sNameBaseline;
	}

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
	<input type="hidden" name="integrationName" value="<%=XSSUtil.encodeForHTML(context, integrationName)%>">
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
		<%
			if(MCADUtil.getBoolean(downloadStructure))
			{
				if(MCADUtil.getBoolean(fromBaselineOpen))
				{
		%>
               <!--XSSOK-->
               <td nowrap width="1%" class="pageHeader"><%=sPageHeader%></td>
		<%
				} else {
		%>
               <!--XSSOK-->
               <td nowrap width="1%" class="pageHeader"><%=sPageHeader%></td>
		<%
				}
			}
			else
			{
		%>
               <!--XSSOK-->
               <td nowrap width="1%" class="pageHeader"><%=integSessionData.getStringResource("mcadIntegration.Server.Title.Checkout")%></td>
		<%
			}
		%>
			   <td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpace.gif" width="16" height="16" name="imgProgress"></td>
			   <!--XSSOK-->
			   <td align="right" <%=defaultVerticalViewHiddenHTMLContent %>><b><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.RelatedVerticalViews")%></b><!--XSSOK-->
        <%=getVerticalViewSelectControlString(verticalViewProgNameMapping, defaultVerticalViewPrefType, integSessionData)%></td>
               &nbsp;&nbsp; 
	                   <!--XSSOK-->
			   <td align="right" <%=defaultLateralViewHiddenHTMLContent %>><b><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.RelatedLateralViews")%></b><!--XSSOK-->
        <%=sLateralViewHtmlContent%>
               </td>
        </tr>
        </table>
        <table border="0" cellspacing="2" cellpadding="0" width="100%">
        <tr>
		    <td class="filter">
			 <!--XSSOK-->
			 <%= integSessionData.getStringResource("mcadIntegration.Server.Heading.ExpandLevels")%>
			 <select name="filterLevel" id="filterLevel" onChange="javascript:onLevelChange(filterLevel.options[filterLevel.selectedIndex].value);return true;">
				<%
				if(defaultExpandLevel.equalsIgnoreCase("All"))
				{
				%>
                                        <!--XSSOK-->
					<option selected value="All"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%></option>
					<!--XSSOK-->
					<option value="UpTo"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.Upto")%></option>
				<%	
				}
				else
				{
				%>
				        <!--XSSOK-->
					<option value="All"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%></option>
					<!--XSSOK-->
					<option selected value="UpTo"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.Upto")%></option>
				<%
				}
				%>

			 </select>
			 <!--XSSOK-->
			 <input type="text" name="showLevel"  size="2" value=<%=XSSUtil.encodeForHTMLAttribute(context,expandLevel)%>>
			</td>
			<!--XSSOK-->
			<td align="right" <%=refreshOptionsHiddenHTMLContent %>>
			<!--XSSOK-->
			<a href="javascript:parent.applyViewsSelected(true)"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RefreshSelected")%></a>&nbsp;&nbsp;&nbsp;
			<!--XSSOK-->
			<a href="javascript:parent.applyViewsSelected(false)"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RefreshAll")%></a>&nbsp;&nbsp;&nbsp;
			
			<% if(null == isVersionedObject || "".equals(isVersionedObject) || !isVersionedObject.equalsIgnoreCase("true"))
			{  
			%>
			<!--XSSOK-->
			<a href="javascript:parent.resetToAsStored()"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.ResetToDefault")%></a>&nbsp;&nbsp;&nbsp;
			
			<%
			}
			%>
			
			<a href='javascript:openIEFHelp("emxhelpdsccheckout")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			</td>
        </tr>
    </table>

	</form>

	<script language="javascript">

		function onLevelChange(levelStr)
		{
                  //XSSOK
		  var expLevel= "<%= defaultExpandLevel %>";
		  if (levelStr == "All" || expLevel.toUpperCase() == "ALL")
		  {
                         //XSSOK
			 document.views.showLevel.value = "<%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%>";
		  }
		  else
		  {
                         //XSSOK
			 document.views.showLevel.value = "<%= defaultExpandLevel %>";	
		  }
		}
		
		var viewsDetails = parent.treeControlObject.getViewsDetails();
		var viewDetailsElements = viewsDetails.split('|');

		document.forms['views'].verticalViewsComboControl.value	= viewDetailsElements[0];
		document.forms['views'].lateralViewsComboControl.value	= viewDetailsElements[1];
	</script>
</body>
</html>
