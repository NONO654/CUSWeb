<%--  MCADUpdateWithMessage.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>


<%
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	 Context context = integSessionData.getClonedContext(session);

	String objectID			= emxGetParameter(request, "busId");
	String instanceName		= emxGetParameter(request, "instanceName");
	String messageEnDetails	= emxGetParameter(request, "details");
	String refreshBasePage	= emxGetParameter(request, "refresh");

	String messageStatus	= "";
	String messageHeader	= "";
	String messageContent	= "";

	String messageDetails = MCADUrlUtil.hexDecode(messageEnDetails);

	StringTokenizer detailTokens = new StringTokenizer(messageDetails, MCADAppletServletProtocol.HEXA_DELIT);

	if(detailTokens.hasMoreTokens())
		messageStatus = detailTokens.nextToken();
	if(detailTokens.hasMoreTokens())
		messageHeader = detailTokens.nextToken();
	if(detailTokens.hasMoreTokens())
		messageContent = detailTokens.nextToken();

		messageHeader	= MCADUrlUtil.hexEncode(messageHeader);
		messageContent	= MCADUrlUtil.hexEncode(messageContent);

	request.setAttribute("instanceName", instanceName);
    request.setAttribute("messageHeader", messageHeader);
	request.setAttribute("message", messageContent);

	String forwardPage = "MCADMessageFS.jsp";
	if(messageStatus.equalsIgnoreCase(MCADAppletServletProtocol.TRUE))
	{
		if("true".equalsIgnoreCase(refreshBasePage))
			forwardPage += "?refresh=true&objectID="+XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),objectID);
	}
	else
	{
		forwardPage += "?refresh=false";
	}

%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
        <!--XSSOK-->
	<jsp:forward page = "<%= forwardPage %>" />
