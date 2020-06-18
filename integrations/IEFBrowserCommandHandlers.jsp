<%--  IEFBrowserCommandHandlers.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import="com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,matrix.db.*"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%
	String iefErrorMessage				= "";
	String iefIntegrationName			= "";
	String iefObjectId					= "";

	try
	{
		MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

        Context iefContext	= integSessionData.getClonedContext(session);

		if(integSessionData != null) 
		{
			MCADMxUtil util	= new MCADMxUtil(iefContext, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

			iefObjectId =Request.getParameter(request,"objectId");
			iefIntegrationName	= util.getIntegrationName(iefContext,iefObjectId);

			MCADGlobalConfigObject globalConfigObject	= (MCADGlobalConfigObject)integSessionData.getGlobalConfigObject(iefIntegrationName,iefContext);
			MCADServerGeneralUtil serverGeneralUtil		= new MCADServerGeneralUtil(iefContext,integSessionData, iefIntegrationName);

			BusinessObject busObj = new BusinessObject(iefObjectId);
			busObj.open(iefContext);
			String boType		= busObj.getTypeName();
			boolean isMCADType	= globalConfigObject.isMCADType(boType);

			String cadType			= util.getCADTypeForBO(iefContext,busObj);
			boolean isDepDocType	= globalConfigObject.isTypeOfClass(cadType, MCADAppletServletProtocol.TYPE_DERIVEDOUTPUT_LIKE);

			if(isMCADType && !isDepDocType)
			{
				
			}
			else
			{
				iefErrorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.NotIntegrationMenu");
			}
		}
	}
	catch(Throwable exception)
	{
		String iefAcceptLanguage = request.getHeader("Accept-Language");
		MCADServerResourceBundle iefServerResourceBundle = new MCADServerResourceBundle(iefAcceptLanguage);

		iefErrorMessage = iefServerResourceBundle.getString("mcadIntegration.Server.Message.NotIntegrationMenu");
	}
	
%>

<script language="javascript">
//XSSOK
var iefErrorMessage				= "<%= iefErrorMessage %>";
//XSSOK
var iefIntegrationName			= "<%= iefIntegrationName %>";
//XSSOK
var iefObjectID					= "<%= iefObjectId %>";

function showIEFCheckoutPage()
{
	if(iefErrorMessage != "")
	{
		alert(iefErrorMessage);
	}
	else
	{
		checkoutWithValidation1(iefIntegrationName, iefObjectID, '', '', '', 'interactive', 'false');
	}
}

function showIEFFinalizePage()
{	
	if(iefErrorMessage != "")
	{
		alert(iefErrorMessage);
	}
	else
	{
		var finalizationDetails = iefIntegrationName + "|" + iefObjectID;
		showFinalizationPage(iefIntegrationName, finalizationDetails)
	}
}

function showIEFUndoFinalizePage()
{
	if(iefErrorMessage != "")
	{
		alert(iefErrorMessage);
	}
	else
	{
		var undoFinalizedURL = "../integrations/MCADUndoFinalization.jsp?busDetails=" + iefIntegrationName + "|true|" + iefObjectID;

		window.parent.pageheader.showNonModalDialog(undoFinalizedURL, 400, 400);
	}
}

function showIEFSynchEBOMPage()
{
	if(iefErrorMessage != "")
	{
		alert(iefErrorMessage);
	}
	else
	{
		var synchEBOMURL = "../integrations/MCADEBOMSynchronization.jsp?busDetails=" + iefIntegrationName + "|false|" + iefObjectID;

		window.parent.pageheader.showNonModalDialog(synchEBOMURL, 400, 400);
	}
}

function showIEFPurgePage()
{
	if(iefErrorMessage != "")
	{
		alert(iefErrorMessage);
	}
	else
	{
		var purgeURL = "../integrations/IEFPurge.jsp?header=mcadIntegration.Server.Title.Purge&funcPageName=<%=MCADGlobalConfigObject.PAGE_PURGE%>&relName=VersionOf&end=to&objectId=" + iefObjectID + "&help=emxhelpdscpurge";

		window.parent.pageheader.showNonModalDialog(purgeURL, 600, 450);
	}
}

function showIEFRenamePage()
{
	if(iefErrorMessage != "")
	{
		alert(iefErrorMessage);
	}
	else
	{
		var renameURL = "../integrations/MCADGenericFS.jsp?pageDetails=Rename|MCADRename.jsp|" + iefIntegrationName + "|true|" + iefObjectID + "&help=emxhelpdscrename";

		window.parent.pageheader.showNonModalDialog(renameURL, 400, 400);
	}
}

function showIEFSaveAsPage()
{
	if(iefErrorMessage != "")
	{
		alert(iefErrorMessage);
	}
	else
	{
		var saveAsDetails		= iefIntegrationName + "|" + iefObjectID;
		showSaveAsPage(iefIntegrationName, saveAsDetails)
	}
}

</script>
