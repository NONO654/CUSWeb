<%--
  TreeDisplaySettingsProcessing.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%--
		@quickreview HAT1 ZUD 14:12:22	 :  HL Requirement Specification Dependency.
		@quickreview KIE1 ZUD  16:07:19  : IR-448762-3DEXPERIENCER2017x: Tree preferences not applicable on Structure browser
		@quickreview KIE1 ZUD  16:12:13  :	IR-484700-3DEXPERIENCER2018x: R419-FUN055951: In Envoia Preferences user is unable to unselect options in Tree Display section once they are selected by user.
--%>


<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
    // check if change has been submitted or just refresh mode
    // Get language

    /* Specification Folders */
	String TreeDisplaySpecFoldersName      = emxGetParameter(request, "TreeDisplaySpecFoldersName");
	String TreeDisplaySpecFoldersTitle     = emxGetParameter(request, "TreeDisplaySpecFoldersTitle");
	String TreeDisplaySpecFoldersRevision  = emxGetParameter(request, "TreeDisplaySpecFoldersRevision");
	String TreeDisplaySpecFoldersSeperator = emxGetParameter(request, "TreeDisplaySpecFoldersSeperator");
		
	if(TreeDisplaySpecFoldersName == null)
	{
		TreeDisplaySpecFoldersName="false";
	}
	if(TreeDisplaySpecFoldersTitle == null)
	{
		TreeDisplaySpecFoldersTitle="false";
	}
	if(TreeDisplaySpecFoldersRevision == null)
	{
		TreeDisplaySpecFoldersRevision="false";
	}
	if(TreeDisplaySpecFoldersSeperator == null)
	{
		TreeDisplaySpecFoldersSeperator="false";
	}
	
	/* Requirement Spefications */
	String TreeDisplayReqSpecName          = emxGetParameter(request, "TreeDisplayReqSpecName");
	String TreeDisplayReqSpecTitle         = emxGetParameter(request, "TreeDisplayReqSpecTitle");
	String TreeDisplayReqSpecRevision      = emxGetParameter(request, "TreeDisplayReqSpecRevision");    
	String TreeDisplayReqSpecSeperator     = emxGetParameter(request, "TreeDisplayReqSpecSeperator");
	
	if(TreeDisplayReqSpecName == null)
	{
		TreeDisplayReqSpecName="false";
	}
	if(TreeDisplayReqSpecTitle == null)
	{
		TreeDisplayReqSpecTitle="false";
	}
	if(TreeDisplayReqSpecRevision == null)
	{
		TreeDisplayReqSpecRevision="false";
	}
	if(TreeDisplayReqSpecSeperator == null)
	{
		TreeDisplayReqSpecSeperator="false";
	}
	
	
	/* Chapters */
	String TreeDisplayChaptersName         = emxGetParameter(request, "TreeDisplayChaptersName");
	String TreeDisplayChaptersTitle        = emxGetParameter(request, "TreeDisplayChaptersTitle");
	String TreeDisplayChaptersRevision     = emxGetParameter(request, "TreeDisplayChaptersRevision");
	String TreeDisplayChaptersSeperator    = emxGetParameter(request, "TreeDisplayChaptersSeperator");
	
	if(TreeDisplayChaptersName == null)
	{
		TreeDisplayChaptersName="false";
	}
	if(TreeDisplayChaptersTitle == null)
	{
		TreeDisplayChaptersTitle="false";
	}
	if(TreeDisplayChaptersRevision == null)
	{
		TreeDisplayChaptersRevision="false";
	}
	if(TreeDisplayChaptersSeperator == null)
	{
		TreeDisplayChaptersSeperator="false";
	}
	
	
	/* Requirements */
	String TreeDisplayRequirementsName      = emxGetParameter(request, "TreeDisplayRequirementsName");
	String TreeDisplayRequirementsTitle     = emxGetParameter(request, "TreeDisplayRequirementsTitle");
	String TreeDisplayRequirementsRevision  = emxGetParameter(request, "TreeDisplayRequirementsRevision");
	String TreeDisplayRequirementsSeperator = emxGetParameter(request, "TreeDisplayRequirementsSeperator");
	
	if(TreeDisplayRequirementsName == null)
	{
		TreeDisplayRequirementsName="false";
	}
	if(TreeDisplayRequirementsTitle == null)
	{
		TreeDisplayRequirementsTitle="false";
	}
	if(TreeDisplayRequirementsRevision == null)
	{
		TreeDisplayRequirementsRevision="false";
	}
	if(TreeDisplayRequirementsSeperator == null)
	{
		TreeDisplayRequirementsSeperator="false";
	}
	
	
	/* Comments */
	String TreeDisplayCommentsName          = emxGetParameter(request, "TreeDisplayCommentsName");
	String TreeDisplayCommentsTitle         = emxGetParameter(request, "TreeDisplayCommentsTitle");
	String TreeDisplayCommentsRevision      = emxGetParameter(request, "TreeDisplayCommentsRevision");
	String TreeDisplayCommentsSeperator     = emxGetParameter(request, "TreeDisplayCommentsSeperator");

	if(TreeDisplayCommentsName == null)
	{
		TreeDisplayCommentsName="false";
	}
	if(TreeDisplayCommentsTitle == null)
	{
		TreeDisplayCommentsTitle="false";
	}
	if(TreeDisplayCommentsRevision == null)
	{
		TreeDisplayCommentsRevision="false";
	}
	if(TreeDisplayCommentsSeperator == null)
	{
		TreeDisplayCommentsSeperator="false";
	}
	
	// ++ KIE1 IR-448762-3DEXPERIENCER2017x: for adding Test Case and Parameters
	/* Test Cases */
	String TreeDisplayTestCasesName          = emxGetParameter(request, "TreeDisplayTestCasesName");
	String TreeDisplayTestCasesTitle         = emxGetParameter(request, "TreeDisplayTestCasesTitle");
	String TreeDisplayTestCasesRevision      = emxGetParameter(request, "TreeDisplayTestCasesRevision");
	String TreeDisplayTestCasesSeperator     = emxGetParameter(request, "TreeDisplayTestCasesSeperator");

	if(TreeDisplayTestCasesName == null)
	{
		TreeDisplayTestCasesName="false";
	}
	if(TreeDisplayTestCasesTitle == null)
	{
		TreeDisplayTestCasesTitle="false";
	}
	if(TreeDisplayTestCasesRevision == null)
	{
		TreeDisplayTestCasesRevision="false";
	}
	if(TreeDisplayTestCasesSeperator == null)
	{
		TreeDisplayTestCasesSeperator="false";
	}
	
	/* Parameters */
	String TreeDisplayParametersName          = emxGetParameter(request, "TreeDisplayParametersName");
	String TreeDisplayParametersTitle         = emxGetParameter(request, "TreeDisplayParametersTitle");
	String TreeDisplayParametersRevision      = emxGetParameter(request, "TreeDisplayParametersRevision");
	String TreeDisplayParametersSeperator     = emxGetParameter(request, "TreeDisplayParametersSeperator");

	if(TreeDisplayParametersName == null)
	{
		TreeDisplayParametersName="false";
	}
	if(TreeDisplayParametersTitle == null)
	{
		TreeDisplayParametersTitle="false";
	}
	if(TreeDisplayParametersRevision == null)
	{
		TreeDisplayParametersRevision="false";
	}
	if(TreeDisplayParametersSeperator == null)
	{
		TreeDisplayParametersSeperator="false";
	}
	// -- KIE1 IR-448762-3DEXPERIENCER2017x: for adding Test Case and Parameters
	
	
	// ++KIE1 ZUD added for Structure Browser and Dyna Tree
	String columnDisplayName      = emxGetParameter(request, "ColumnDisplayName");
	String columnDisplayTitle     = emxGetParameter(request, "ColumnDisplayTitle");
	if(columnDisplayName == null)
	{
		columnDisplayName="false";
	}
	if(columnDisplayTitle == null)
	{
		columnDisplayTitle="false";
	}
	// --KIE1 ZUD added for Structure Browser and Dyna Tree
	

	try{
		
		ContextUtil.startTransaction(context, true);
		
	    /* Specification Folders */
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersName", TreeDisplaySpecFoldersName.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersTitle", TreeDisplaySpecFoldersTitle.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersShowRevision", TreeDisplaySpecFoldersRevision.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplaySpecFoldersSeparator", TreeDisplaySpecFoldersSeperator.trim());
		
		/* Requirement Specification */
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecName", TreeDisplayReqSpecName.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecTitle", TreeDisplayReqSpecTitle.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecShowRevision", TreeDisplayReqSpecRevision.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayReqSpecSeperator", TreeDisplayReqSpecSeperator.trim());
		
    	/* Chapters */
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersName", TreeDisplayChaptersName.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersTitle", TreeDisplayChaptersTitle.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersShowRevision", TreeDisplayChaptersRevision.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayChaptersSeperator", TreeDisplayChaptersSeperator.trim());
		
		/* Requirements */
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsName", TreeDisplayRequirementsName.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsTitle", TreeDisplayRequirementsTitle.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsShowRevision", TreeDisplayRequirementsRevision.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayRequirementsSeperator", TreeDisplayRequirementsSeperator.trim());
		
		/* Comments */
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsName", TreeDisplayCommentsName.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsTitle", TreeDisplayCommentsTitle.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsShowRevision", TreeDisplayCommentsRevision.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayCommentsSeperator", TreeDisplayCommentsSeperator.trim());

		// ++ KIE1 IR-448762-3DEXPERIENCER2017x: for adding Test Case and Parameters 
		/* Test Cases */
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesName", TreeDisplayTestCasesName.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesTitle", TreeDisplayTestCasesTitle.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesShowRevision", TreeDisplayTestCasesRevision.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayTestCasesSeperator", TreeDisplayTestCasesSeperator.trim());
		
		/* Parameters */
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersName", TreeDisplayParametersName.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersTitle", TreeDisplayParametersTitle.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersShowRevision", TreeDisplayParametersRevision.trim());
		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTreeDisplayParametersSeperator", TreeDisplayParametersSeperator.trim());
		// -- KIE1 IR-448762-3DEXPERIENCER2017x: for adding Test Case and Parameters
		
		// ++KIE1 ZUD added for Structure Browser and Dyna Tree
        if(columnDisplayName !=null)
        {
       		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedColumnDisplayName", columnDisplayName.trim());
        }
        if(columnDisplayTitle !=null)
        {
    		PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedColumnDisplayTitle", columnDisplayTitle.trim());
        }
        // --KIE1 ZUD added for Structure Browser and Dyna Tree

	}
	catch (Exception ex) {
	    ContextUtil.abortTransaction(context);
	
	    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
	    {
	        emxNavErrorObject.addMessage("prefStructureDisplay:" + ex.toString().trim());
	    }
	}
	finally
	{
	    ContextUtil.commitTransaction(context);
	}

%>    
<script>   
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
