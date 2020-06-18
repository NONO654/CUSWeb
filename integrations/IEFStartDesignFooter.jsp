<%--  IEFStartDesignFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String isConfigUIRelated =Request.getParameter(request,"isConfigUIRelated");
	
	//Check for the role assigned to the user

	Context context = integSessionData.getClonedContext(session);
	
	MCADMxUtil util					= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	boolean isAssigned		= false;

	HashMap JPOArgsTable	= new HashMap();

	JPOArgsTable.put(MCADServerSettings.LANGUAGE_NAME, integSessionData.getLanguageName());
	String [] packedArgumentsTable = JPO.packArgs(JPOArgsTable);

	Boolean hasAdminRole	= (Boolean)JPO.invoke(context, "DSCTEAMAccessUtil", new String[0], "checkAccessForTEAMLeader", packedArgumentsTable, Boolean.class);
	isAssigned				= hasAdminRole.booleanValue();

	String integrationName =Request.getParameter(request,"integrationName");
	MCADGlobalConfigObject  globalConfigObject  = integSessionData.getGlobalConfigObject(integrationName, context);	
	String loadFilesOnCheckoutAttrName				= MCADMxUtil.getActualNameForAEFData(context, "attribute_IEF-Pref-MCADInteg-LoadObjectsInCADTool");
	boolean isUnsupported = false;
	if(globalConfigObject != null) 
	{
					 if(loadFilesOnCheckoutAttrName.length() > 0)
						isUnsupported = globalConfigObject.getPreferenceType(loadFilesOnCheckoutAttrName).equals("UNSUPPORTED");
	}

	//Get the String values from properties file.
	String sCreateDesignTemplateObject = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.CreateDesignTemplateObject");

	String sSubmit	= integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit");
	String sCancel	= integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>

<body>
<form name="bottomCommonForm">

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

<table border="0" cellspacing="0" cellpadding="0" align=right>
	<tr><td>&nbsp</td></tr>
	<tr>
<%
	if((isConfigUIRelated == null || isConfigUIRelated.equals("")) && isAssigned)
	{
%>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.createDesignTemplateObject()"><img src="../integrations/images/emxUIButtonDone.gif" border="0" alt="<%=sCreateDesignTemplateObject%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.createDesignTemplateObject()"><%=sCreateDesignTemplateObject%></a>&nbsp&nbsp;</td>
<%
	}
	
%>

                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.cancel()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=sCancel%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.cancel()"><%=sCancel%></a>&nbsp&nbsp;</td>
	</tr>
 </table>

</form>
</body>
</html>
