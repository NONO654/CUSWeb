<%--  MCADUndoFinalization.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
	MCADIntegrationSessionData integSessionData		= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	MCADServerResourceBundle serverResourceBundle	= integSessionData.getResourceBundle();
	Context _context		= integSessionData.getClonedContext(session);
	MCADMxUtil _util		= new MCADMxUtil(_context, serverResourceBundle, integSessionData.getGlobalCache());
	boolean isAEFInstalled	= _util.isAEFInstalled(_context);

	String busDetails		= emxGetParameter(request, "busDetails");
	String breakPartSpec	= emxGetParameter(request, "breakPartSpec");
	
	if(breakPartSpec!=null){
		ENOCsrfGuard.validateRequest(_context, session, request, response);
	}
	if(isAEFInstalled && (breakPartSpec == null || "".equals(breakPartSpec)))
	{
		String pageDetails		 = "Demote|IEFUndoFinalizeOptions.jsp|"+busDetails;
		String	help			= "emxhelpdscdemote";
		String emxSuiteDirectory= "iefStringResource";

		request.setAttribute("pageDetails", pageDetails);
		request.setAttribute("help", help);
		request.setAttribute("emxSuiteDirectory", emxSuiteDirectory);

		String forwardPage	 = "MCADGenericFS.jsp";
%>
	<jsp:forward page="<%=XSSUtil.encodeForHTML(_context,forwardPage)%>" />
<%
		return;
	}

	StringTokenizer busDetailsTokens = new StringTokenizer(busDetails, "|");
	String integrationName	= busDetailsTokens.nextToken();
	String refreshBasePage	= busDetailsTokens.nextToken();
	String objectID			= busDetailsTokens.nextToken();

	String instanceName	= "";
	if(busDetailsTokens.hasMoreTokens())
	{
		instanceName = busDetailsTokens.nextToken();
		instanceName = MCADUrlUtil.hexDecode(instanceName);
	}
%>

<html>
<head>
</head>
<body>
<!--XSSOK-->
<h4><%= integSessionData.getStringResource("mcadIntegration.Server.Message.WorkInProgress")%></h4>

<form name="UpdatePage" action="MCADUpdateWithMessage.jsp" method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(_context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(_context, session);
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


	<input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="instanceName" value="<xss:encodeForHTMLAttribute><%= instanceName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="refresh" value="<xss:encodeForHTMLAttribute><%= refreshBasePage %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="instanceRefresh" value="true">
	<input type="hidden" name="details" value="">
</form>

<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
	var busId			= "<%=XSSUtil.encodeForJavaScript(_context,objectID) %>";
	var instanceName	= "<%=XSSUtil.encodeForJavaScript(_context,instanceName)  %>";
         //XSSOK
	var unitSeparator	= "<%=MCADAppletServletProtocol.UNIT_SEPERATOR%>";
	//XSSOK
	var recordSeparator = "<%=MCADAppletServletProtocol.RECORD_SEPERATOR%>";

	var parametersArray = new Array;
	parametersArray["busId"]			= busId;
	parametersArray["instanceName"]		= instanceName;
	parametersArray["Command"]			= "executeBrowserCommand";
        //XSSOK
	parametersArray["Action"]			= "<%=MCADGlobalConfigObject.FEATURE_UNDOFINALIZE%>";
	parametersArray["IntegrationName"]	= "<%=XSSUtil.encodeForJavaScript(_context,integrationName) %>";
	parametersArray["BreakPartSpec"]	= "<%=XSSUtil.encodeForJavaScript(_context,breakPartSpec) %>";

	var queryString = getQueryString(parametersArray, unitSeparator, recordSeparator);

	var integrationFrame = getIntegrationFrame(this);

	//cannot go ahead if unable to locate integration frame.
	if( integrationFrame != null )
	{
		var response = integrationFrame.getAppletObject().callCommandHandlerSynchronously("<%= XSSUtil.encodeForJavaScript(_context,integrationName) %>", "sendRequestToServerForBrowserCommands", queryString);
		var encodedString	= hexEncode("<%= XSSUtil.encodeForJavaScript(_context,integrationName) %>",response);
		document.UpdatePage.details.value=encodedString;
		document.UpdatePage.submit();
	}
	else
	{
                //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.IntegrationFrameNotFound")%>");
	}
</script>

</body>
</html>
