	<%--  MCADFinalizationHeader.jsp

	   Copyright (c) 2016 Dassault Systemes. All rights reserved.
	   This program contains proprietary and trade secret information of
	   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
	   and does not evidence any actual or intended publication of such program

	--%>
	<%@include file ="MCADTopInclude.inc" %>
	<%@ page import = "com.matrixone.apps.common.*, com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*,com.matrixone.MCADIntegration.server.beans.*, java.util.*, com.matrixone.apps.domain.util.*" %>

	<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

	<%!
		public String getLateralViewSelectControlString(Hashtable lateralNavigationProgNameMapping, String preferenceType, MCADIntegrationSessionData integSessionData,String integrationName)
		{
			StringBuffer viewSelectControlBuffer = new StringBuffer(" <select name=\"lateralViewsComboControl\" onChange=\"parent.selectedChangeViewProgram(true)\"");
			if(preferenceType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
			{
				viewSelectControlBuffer.append(" disabled ");
			}

			viewSelectControlBuffer.append(">\n");
			
			viewSelectControlBuffer.append(" <option value=\"" + MCADAppletServletProtocol.VIEW_AS_BUILT + "\">" + integSessionData.getStringResource("mcadIntegration.Server.FieldName."+MCADAppletServletProtocol.VIEW_AS_BUILT) + "</option>\n");

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


			String isAsSavedViewSupported		= UINavigatorUtil.getI18nString("emxDesignerCentral.LateralViews.EnableAsSavedView","emxIEFDesignCenter", integSessionData.getLanguageName());			
				boolean bisAsSavedViewSupported = false;
				if(isAsSavedViewSupported.contains(integrationName))
				{
					bisAsSavedViewSupported =  true;
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
		MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
		Context context							    = integSessionData.getClonedContext(session);
		MCADMxUtil util								= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		String integrationName						= Request.getParameter(request,"integrationName");
		String objectIds						    = Request.getParameter(request,"objectIds");
		String isLateralNavigationAllowed			= Request.getParameter(request,"isLateralNavigationAllowed");
		if(isLateralNavigationAllowed == null)
			isLateralNavigationAllowed = "";

		MCADLocalConfigObject localConfigObject		= integSessionData.getLocalConfigObject();
		
		MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
		String finalizationViewRegistryName			= localConfigObject.getViewRegistryName(integrationName);
		String defaultExpandLevel					= localConfigObject.getDefaultExpandLevel(integrationName);
		
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

		Hashtable lateralViewProgNameMapping		= util.readLateralNavigationProgNameMapping(context,finalizationViewRegistryName);	
		Hashtable verticalViewProgNameMapping		= util.readVerticalNavigationProgNameMapping(context,finalizationViewRegistryName);
	%>
	<html>
	<head>
		<title>emxTableControls</title>
		<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
		<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
		
		<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>

	</head>
	<body>
	<form name="views" onsubmit="return false" method="post">

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


		<table border="0" cellspacing="2" cellpadding="0" width="100%">
			<tr>
				<td class="page-title"><img src="images/utilSpace.gif" width="1" height="1"></td>
			</tr>
			<tr>
				<td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
			</tr>
		</table>
		
		<table border="0" cellspacing="2" cellpadding="2" width="100%">
			<tr>
                                <!--XSSOK-->
				<td nowrap width="1%" class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.Promote")%></td>			
				<td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpace.gif" width="16" height="16" name="imgProgress"></td>
                                 <!--XSSOK-->
				 <td align="right" <%= defaultVerticalViewHiddenHTMLContent %>><b><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.RelatedVerticalViews")%></b><!--XSSOK-->
				 <%=getVerticalViewSelectControlString(verticalViewProgNameMapping, defaultVerticalViewPrefType, integSessionData)%></td>

				 <% 
					//if(isLateralNavigationAllowed.equalsIgnoreCase("TRUE")) 
					//{ 

				 %>
                                         <!--XSSOK-->
					 &nbsp;&nbsp;<td align="right" <%=defaultLateralViewHiddenHTMLContent %>><b><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.RelatedLateralViews")%></b><!--XSSOK-->
					 <%=getLateralViewSelectControlString(lateralViewProgNameMapping, defaultLateralViewPrefType,integSessionData,integrationName)%>
				 <%	
				//	}
				 %>
				  &nbsp;
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
					 <input type="text" name="showLevel"  size="2" value=<%=defaultExpandLevel%>>
				</td>
                                <!--XSSOK-->
				<td align="right" <%=refreshOptionsHiddenHTMLContent %>>
				<!--XSSOK-->
				<a href="javascript:parent.applyViewsSelected(true)"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RefreshSelected")%></a>&nbsp;&nbsp;&nbsp;
				<!--XSSOK-->
				<a href="javascript:parent.applyViewsSelected(false)"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RefreshAll")%></a>&nbsp;&nbsp;&nbsp;
				<!--XSSOK-->
				<a href="javascript:parent.resetToAsStored()"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.ResetToDefault")%></a>&nbsp;&nbsp;&nbsp;
				<a href='javascript:openIEFHelp("emxhelpdscpromote")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
				</td>
			</tr>
		</table>	
		
		</form>
	<script language="javascript">
		var viewsDetails		= parent.treeControlObject.getViewsDetails();
		var viewDetailsElements = viewsDetails.split('|');

	<%
		//if(isLateralNavigationAllowed.equalsIgnoreCase("TRUE"))
		//{
	%>
			document.forms['views'].lateralViewsComboControl.value = viewDetailsElements[0];
	<%	
		//}
	%>
		
		document.forms['views'].verticalViewsComboControl.value	= viewDetailsElements[1];
	</script>

	<script language="javascript">
	function onLevelChange(levelStr)
	{
	  if (levelStr == 'All')
	         //XSSOK
		 document.views.showLevel.value = "<%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%>";
	  else
                 //XSSOK
		 document.views.showLevel.value = '<%= defaultExpandLevel %>';
	}
	</script>

	<form name="UpdatePage" action="MCADUpdateWithMessage.jsp" target="_top" method="post">

<%
boolean csrfEnabled1 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled1)
{
  Map csrfTokenMap1 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName1 = (String)csrfTokenMap1 .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue1 = (String)csrfTokenMap1.get(csrfTokenName1);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName1%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName1%>" value="<%=csrfTokenValue1%>" />
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

