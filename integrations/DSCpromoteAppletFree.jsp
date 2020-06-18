<%--  DSCpromoteAppletFree.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@page import="com.matrixone.MCADIntegration.utils.MCADStringUtils"%>
<%@ include file = "MCADTopInclude.inc" %>
<%@ include file = "MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.apps.domain.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADLocalConfigObject" %>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADGlobalConfigObject" %>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADUtil" %>

<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js"></script>
<script language="JavaScript" src="../common/scripts/emxExtendedPageHeaderFreezePaneValidation.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<html>
<body>
<%
  	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	String sAction			=Request.getParameter(request,"action");
	String objectIds		= Request.getParameter(request,"objectIds");
	String currentObjectId	=Request.getParameter(request,"objectId");
	String integrationName	=Request.getParameter(request,"integrationName");
	String sRefreshFrame		=Request.getParameter(request,"refreshFrame");
	MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(),integSessionData.getResourceBundle(),integSessionData.getGlobalCache());
 
	if(MCADStringUtils.isNullOrEmpty(integrationName))
		integrationName = util.getIntegrationName(context, currentObjectId);

  	MCADServerGeneralUtil serverGeneralUtil	= new MCADServerGeneralUtil(context, integSessionData, integrationName);
   	MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
 	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
 	try{
		IEFPromoteDemoteHelper promoteDemoteHelper = new IEFPromoteDemoteHelper();
		Hashtable JPOResultData = new Hashtable();
		if(!MCADStringUtils.isNullOrEmpty(objectIds))
		{
			 JPOResultData = promoteDemoteHelper.executePromote(context, globalConfigObject, localConfigObject, serverGeneralUtil, util, integSessionData.getResourceBundle(), integrationName, currentObjectId, objectIds, integSessionData.getLogger());
		}
		else
		{
			JPOResultData = promoteDemoteHelper.executePromote(context, globalConfigObject, localConfigObject, serverGeneralUtil, util, integSessionData.getResourceBundle(), integrationName, currentObjectId, integSessionData.getLogger());
		}

		String jpoExecutionStatus =  (String) JPOResultData.get("jpoExecutionStatus");
	
		if("true".equalsIgnoreCase(jpoExecutionStatus))
		{
			Hashtable msgTable = new Hashtable(2);
			msgTable.put("NAME", integSessionData.getStringResource("mcadIntegration.Server.Title.Promote"));
			String operationSuccessful = integSessionData.getStringResource("mcadIntegration.Server.Message.OperationSuccessful", msgTable);
		%>
		<script language="JavaScript">
   		  alert("<%=operationSuccessful%>");
     	</script>
		<%
		}
        else{
        	String jpoStatusMessage = (String)JPOResultData.get("jpoStatusMessage");
        %>
    		<script language="JavaScript">
     			alert("<%=jpoStatusMessage%>");
        	</script>
		<%
        }
	}
	catch(Exception e)
	{
		String msg 				= e.getMessage();
		String messageHeader	= "mcadIntegration.Server.Message.PromoteOperationFailed";
		%>
		<script language="JavaScript">
			messageToShow = "<%=msg%>";
			window.top.document.getElementById('layerOverlay').style.display ='none';
			var messageDialogURL = "DSCErrorMessageDialogFS.jsp?messageHeader=<%=messageHeader%>&headerImage=images/iconError.gif&showExportIcon=true";
			showIEFModalDialog(messageDialogURL, 500, 400);
		</script>
	<%
	}
	%>
	<script language="javascript" >

var refreshFrame		= getFrameObject(top, '<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),sRefreshFrame)%>');
var integrationFrame	= getIntegrationFrame(this);
if(integrationFrame != null)
{
	if(refreshFrame == null)
	{
		//Set the refresh for Full Search
		refreshFrame = getFrameObject(top, "structure_browser");
	}
	var refreshFrameURL	= refreshFrame.location.href;
	if(refreshFrame.name == "content")
				{
					refreshFrame.location.href = refreshFrameURL; //using refreshFrame.reload() causes a bug on FireFox
				}
}
window.top.document.getElementById('layerOverlay').style.display ='none';
</script>
</body>
</html>
