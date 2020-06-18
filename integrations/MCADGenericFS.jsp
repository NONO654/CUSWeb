<%--  MCADGenericFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%
	 framesetObject fs = new framesetObject();
	//Page Details
	String suiteDirectory			= Request.getParameter(request,"emxSuiteDirectory");
	String stringResourceFile	        = Request.getParameter(request,"StringResourceFileId");
	String suiteKey				= Request.getParameter(request,"suiteKey");
	String pageDetails			= Request.getParameter(request,"pageDetails");
	String sHelpMarker			= Request.getParameter(request,"help");
 String sRefreshFrame		=Request.getParameter(request,"refreshFrame");
	StringTokenizer pageDetailsTokens = new StringTokenizer(pageDetails, "|");
	
	String pageTitle		= pageDetailsTokens.nextToken();	
	String pageHeading		= "mcadIntegration.Server.Title." + pageTitle;
	String contentPage		= pageDetailsTokens.nextToken();
	String integrationName	= pageDetailsTokens.nextToken();
	String refreshBasePage	= pageDetailsTokens.nextToken();
	String objectID			= pageDetailsTokens.nextToken();

	if(stringResourceFile==null || stringResourceFile.equals("null") || stringResourceFile.equals(""))
	{
		stringResourceFile = "iefStringResource";
	}

	if(suiteKey==null || suiteKey.equals("null") || suiteKey.equals(""))
	{
		suiteKey = "DesignerCentral";
	}

	if(suiteDirectory==null || suiteDirectory.equals("null") || suiteDirectory.equals(""))
	{
		suiteDirectory = "iefdesigncenter";
	}

	String instanceName = "";
	if(pageDetailsTokens.hasMoreTokens())
		instanceName = pageDetailsTokens.nextToken();
	
	contentPage += "?busId=" + objectID + "&instanceName=" + instanceName + "&emxSuiteDirectory=" + suiteDirectory + "&integrationName=" + integrationName + "&refresh=" + refreshBasePage+"&refreshFrame=" + sRefreshFrame;

    //Get the roles from property file
    MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    String mcadRoleList = MCADIntegrationSessionData.getPropertyValue("mcadIntegration.MCADRoles");

	String operationTitle	= integSessionData.getStringResource(pageHeading);

	 framesetObject.setBottomFrameCommonPage("../common/emxAppBottomPageInclude.jsp");
         framesetObject.setTopFrameCommonPage("../common/emxAppTopPageInclude.jsp");
	 fs.initFrameset(pageHeading,sHelpMarker,contentPage,false,true,false,false);

         fs.setStringResourceFile(stringResourceFile);
         fs.setPageTitle(operationTitle);
	 fs.setDirectory(suiteDirectory);
	 fs.setSuiteKey(suiteKey);

String roleList = "role_GlobalUser";

fs.createFooterLink("mcadIntegration.Server.ButtonName.Done",
                      "doneMethod()",
                      roleList,
                      false,
                      true,
                      "integrations/images/emxUIButtonDone.gif",
                      0);

fs.createFooterLink("mcadIntegration.Server.ButtonName.Cancel",
                      "parent.window.close()",
                      roleList,
                      false,
                      true,
                      "integrations/images/emxUIButtonCancel.gif",
                      0);

    fs.writePage(out);
%>

