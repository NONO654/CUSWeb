<!DOCTYPE html>


<%@ include file = "MCADTopInclude.inc" %>
<%@ include file = "MCADTopErrorInclude.inc" %>
<%@ page import="java.util.*" %>
<html>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context	= integSessionData.getClonedContext(session);
	boolean isDebugEnabled			= integSessionData.getLocalConfigObject().isTurnDebugOn();

	String progressBarLabel			= integSessionData.getStringResource("mcadIntegration.Server.Title.ProgressBar");
	
	String processString = UINavigatorUtil.getI18nString("emxFramework.Common.Processing","emxFrameworkStringResource", request.getHeader("Accept-Language"));
%>
<head>
<TITLE><%= progressBarLabel %></TITLE>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="javascript" >
//This part of code is added to disable clicks on the main page will operation is ongoing and to show the progess bar in right corner
	window.top.document.getElementById('layerOverlay').style.display ='block';
	if(parent.frames[0].document.getElementById('txtProgressDivChannel') !=null && parent.frames[0].document.getElementById('imgProgressDivChannel') != null)
	{// If for activing progress bar is command is executed from Obejct summary page
		parent.frames[0].document.getElementById('txtProgressDivChannel').innerHTML = '<%=processString%>';
		parent.frames[0].document.getElementById('imgProgressDivChannel').style.visibility ='visible';
	}
	else if(parent.parent.document.getElementById('txtProgressDivChannel') !=null && parent.parent.document.getElementById('imgProgressDivChannel') != null)
	{// else part for activating progess bar if command is executed from Navigate page.
		parent.parent.document.getElementById('txtProgressDivChannel').innerHTML = '<%=processString%>';
		parent.parent.document.getElementById('imgProgressDivChannel').style.visibility ='visible';
	}
	else if(parent.document.getElementById('imgLoadingProgressDiv')!=null)
	{// for navigate page from category tree
		parent.document.getElementById('imgLoadingProgressDiv').innerHTML  = '<%=processString%>';
		parent.document.getElementById('imgLoadingProgressDiv').style.visibility ='visible';
	}
	
</script>
</head>

<%

	String objectId		= Request.getParameter(request,"objectId");
	String integrationName	=Request.getParameter(request,"integrationName");
	String sRefreshFrame		=Request.getParameter(request,"refreshFrame");
	String action		=Request.getParameter(request,"action");
	String objectIds		= Request.getParameter(request,"objectIds");
	String busDetails		=Request.getParameter(request,"busDetails");
	String url		=Request.getParameter(request,"url");
	
	String site ="";
	
	if(action.equalsIgnoreCase("AppletFreePromote"))
	 site = url+"?refreshFrame=content&objectId="+objectId+"&integrationName=" + integrationName +"&objectIds=" + objectIds;
	else if(action.equalsIgnoreCase("AppletFreeDemote"))
	site = url+"&refreshFrame=content&integrationName=" + integrationName;
	else if(action.equalsIgnoreCase("EBOMSynchronize"))
		site = url+"?objectId="+objectId+"&integrationName=" + integrationName;
	
%>

<frameset rows="100%,*" >
    <frame  name="tableDisplay" src="<%=site%>">
</frameset>
</html>

