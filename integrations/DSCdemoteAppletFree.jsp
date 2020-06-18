<%--  DSCdemoteAppletFree.jsp

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
	String busDetails		= emxGetParameter(request, "busDetails");
  
	StringTokenizer busDetailsTokens = new StringTokenizer(busDetails, "|");
	String integrationName	= busDetailsTokens.nextToken();
	String refreshBasePage	= busDetailsTokens.nextToken();
	String currentObjectId			= busDetailsTokens.nextToken();
     
  	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	 String sRefreshFrame		=Request.getParameter(request,"refreshFrame");
   	MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
 	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(context.getSession().getLanguage());
 	 
 	try{
		String [] args = null;
		Hashtable JPOArgsTable = new Hashtable();;
		
		JPOArgsTable.put(MCADServerSettings.GCO_OBJECT, globalConfigObject);
		JPOArgsTable.put(MCADServerSettings.LANGUAGE_NAME, serverResourceBundle.getLanguageName());
		JPOArgsTable.put(MCADServerSettings.OBJECT_ID, currentObjectId);
		JPOArgsTable.put(MCADServerSettings.OPERATION_UID, MCADUtil.getUUID());
		String [] packedArgumentsTable = JPO.packArgs(JPOArgsTable);
		args = packedArgumentsTable;
		
		IEFPromoteDemoteHelper promoteDemoteHelper = new IEFPromoteDemoteHelper();
		
		Hashtable JPOResultData = promoteDemoteHelper.executeDemote(context, args, globalConfigObject);
		
		String jpoExecutionStatus =  (String) JPOResultData.get("jpoExecutionStatus");
		if("true".equalsIgnoreCase(jpoExecutionStatus))
		{
			Hashtable msgTable = new Hashtable(2);
			msgTable.put("NAME", integSessionData.getStringResource("mcadIntegration.Server.Title.Demote"));
			String operationSuccessful = integSessionData.getStringResource("mcadIntegration.Server.Message.OperationSuccessful", msgTable);
		%>
		<script language="JavaScript">
   		  alert("<%=operationSuccessful%>");
		  window.top.document.getElementById('layerOverlay').style.display ='none';
     	</script>
    	<%
		}
        else{
        	String jpoStatusMessage = (String)JPOResultData.get("jpoStatusMessage");
        %>
    		<script language="JavaScript">
     			alert("<%=jpoStatusMessage%>");
				 window.top.document.getElementById('layerOverlay').style.display ='none';
        	</script>
		<%
        }
		}
		catch(Exception e)
		{
			String msg = e.getMessage();
			Hashtable msgTable = new Hashtable(2);
			msgTable.put("NAME", integSessionData.getStringResource("mcadIntegration.Server.Title.Demote"));
			String messageHeader = integSessionData.getStringResource("mcadIntegration.Server.Message.OperationFailed", msgTable);
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
</script>
</body>
</html>
