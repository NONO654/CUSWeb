<%--  emxContentSearchProcess.jsp  --  Comnnecting Contents to Route

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id : Exp $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
//simple route
String routeMemberString=emxGetParameter(request,"routeMemberString");
String routeInstructions =emxGetParameter(request,"routeInstructions");
String routeInitiateManner=emxGetParameter(request,"routeInitiateManner");
String allowDelegation=emxGetParameter(request,"allowDelegation");
String routeAction=emxGetParameter(request,"routeAction");
String routeDueDate=emxGetParameter(request,"routeDueDate");
String keyValue                 =    emxGetParameter(request,"keyValue");
String strLanguage      = emxGetParameter(request,"strLanguage");
String invokePurpose       =    emxGetParameter(request,"invokePurpose");
String routeDueDateMSValue = emxGetParameter(request,"routeDueDateMSValue");

//Route wizard
String routeName = emxGetParameter(request,"routeName");
String checkPreserveOwner = emxGetParameter(request,"checkPreserveOwner");
String routeAutoName = emxGetParameter(request,"routeAutoName");
String routeDescription = emxGetParameter(request,"routeDescription");
String selscope = emxGetParameter(request,"selscope");
String routeBasePurpose = emxGetParameter(request,"routeBasePurpose");
String routeStart = emxGetParameter(request,"routeStart");
String routeCompletionAction = emxGetParameter(request,"routeCompletionAction");
String templateId = (String)emxGetParameter(request,"templateId");
String template =(String) emxGetParameter(request,"template");
String routeAutoStop = emxGetParameter(request,"routeAutoStop");
String scopeId = emxGetParameter(request,"scopeId");
String workspaceFolder = emxGetParameter(request,"workspaceFolder");
String statesWithIds = (String) emxGetParameter(request, "statesWithIds");
if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(statesWithIds)) {
	statesWithIds = "";
}

String [] ContentID    = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
String strAccessError   = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale() , "emxComponents.Issue.CheckAccess");
StringBuffer documentID = new StringBuffer();
StringBuffer connectObjects = new StringBuffer();
com.matrixone.apps.domain.DomainObject docObj      = com.matrixone.apps.domain.DomainObject.newInstance(context);
Access docAccess		= null;
String accessGrantor 	= null;
String docName 			= "";
String contextUser 		= context.getUser();
String COMMON_ACCESS_GRANTOR = "Common Access Grantor";
for(int i=0; i < ContentID.length; i++){
    
    docObj.setId(ContentID[i]);
    docName = docObj.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
    StringList grantorList = com.matrixone.apps.common.Route.getGranteeGrantor(context, ContentID[i]);
    if(grantorList.contains(COMMON_ACCESS_GRANTOR))
    {
        docAccess = docObj.getAccessForGranteeGrantor(context, contextUser, COMMON_ACCESS_GRANTOR);
    } else if(grantorList.contains(AccessUtil.ROUTE_ACCESS_GRANTOR)){
        docAccess = docObj.getAccessForGranteeGrantor(context, contextUser, AccessUtil.ROUTE_ACCESS_GRANTOR);
    } else {
        docAccess = docObj.getAccessMask(context);
    }
    if(AccessUtil.hasReadAccess(docAccess)) {
  documentID.append(ContentID[i]);
  documentID.append("~");
    } else {
        connectObjects.append(docName);
        connectObjects.append(",");
    }
}

strAccessError = strAccessError + connectObjects.toString();
String topHREF=("QuickRouteContent").equals(invokePurpose)?"getTopWindow().getWindowOpener().getTopWindow().document.location.href=\"emxRouteCreateSimpleDialogFS.jsp?ContentID="+XSSUtil.encodeForURL(context, documentID.toString())+"&statesWithIds="+XSSUtil.encodeForURL(context, statesWithIds)+"&keyValue="+XSSUtil.encodeForURL(context, keyValue)+"&routeInstructions="+XSSUtil.encodeForURL(context,routeInstructions)+"&routeInitiateManner="+XSSUtil.encodeForURL(context,routeInitiateManner)+"&routeAction="+XSSUtil.encodeForURL(context,routeAction)+"&routeDueDate="+XSSUtil.encodeForURL(context,routeDueDate)+"&allowDelegation="+XSSUtil.encodeForURL(context,allowDelegation)+"&routeMemberString="+XSSUtil.encodeForURL(context,routeMemberString)+"&routeDueDateMSValue="+XSSUtil.encodeForURL(context,routeDueDateMSValue)+"&addContent=true\";":"getTopWindow().getWindowOpener().getTopWindow().document.location.href=\"emxRouteWizardCreateDialogFS.jsp?ContentID="+XSSUtil.encodeForURL(context, documentID.toString())+"&statesWithIds="+XSSUtil.encodeForURL(context, statesWithIds)+"&keyValue="+ XSSUtil.encodeForURL(context, keyValue)+"&init1=false"+"&routeName="+XSSUtil.encodeForURL(context,routeName)+"&routeDescription="+XSSUtil.encodeForURL(context,routeDescription)+"&selscope="+XSSUtil.encodeForURL(context,selscope)+"&routeStart="+XSSUtil.encodeForURL(context,routeStart)+"&routeCompletionAction="+XSSUtil.encodeForURL(context,routeCompletionAction)+"&routeBasePurpose="+XSSUtil.encodeForURL(context,routeBasePurpose)+"&routeAutoStop="+XSSUtil.encodeForURL(context,routeAutoStop)+"&templateId="+XSSUtil.encodeForURL(context,templateId)+"&template="+XSSUtil.encodeForURL(context,template)+"&workspaceFolderId="+XSSUtil.encodeForURL(context,scopeId)+"&workspaceFolder="+XSSUtil.encodeForURL(context,workspaceFolder)+"&routeAutoName="+XSSUtil.encodeForURL(context,routeAutoName)+"&checkPreserveOwner="+XSSUtil.encodeForURL(context,checkPreserveOwner)+"&addContent=true\";";

%>
<script language="javascript">
var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
//getTopWindow().getWindowOpener().getTopWindow().document.location.href="emxRouteWizardCreateDialogFS.jsp?ContentID=<%=documentID.toString()%>&keyValue=<%=keyValue%>&addContent=true";
//getTopWindow().getWindowOpener().getTopWindow().document.location.href="emxRouteCreateSimpleDialogFS.jsp?ContentID=<%=documentID.toString()%>&keyValue=<%=keyValue%>&addContent=true";
<%
	if(connectObjects.length() > 0)
	{
	%>
	alert("<%=XSSUtil.encodeForJavaScript(context, strAccessError)%>");
	
	<%
	} else { %>
	//XSSOK
<%=topHREF%>
	<% } %>
	getTopWindow().closeWindow();
</script>

