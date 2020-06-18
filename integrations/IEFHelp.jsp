<%--  IEFHelp.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file="MCADTopInclude.inc" %>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context	= integSessionData.getClonedContext(session);
	
	String suiteDirectory			= Request.getParameter(request, "emxSuiteDirectory");
    String suiteKey				= Request.getParameter(request,"suiteKey");
	String helpMarkerMacro		= Request.getParameter(request,"helpMarker");
	String topic						= Request.getParameter(request,"topic");

    String lan						= request.getHeader("Accept-Language");
	String lanStr					= FrameworkUtil.i18nStringNow("emxFramework.HelpDirectory", lan);
    String lanOnlineStr			= FrameworkUtil.i18nStringNow("emxFramework.OnlineXML.HelpDirectory", lan);


	if(helpMarkerMacro==null || helpMarkerMacro.equals("null") || helpMarkerMacro.equals(""))
	{
		helpMarkerMacro = topic;
	}

	if(suiteKey==null || suiteKey.equals("null") || suiteKey.equals(""))
	{
		suiteKey = "DesignerCentral";
	}

	if(suiteDirectory==null || suiteDirectory.equals("null") || suiteDirectory.equals(""))
	{
		suiteDirectory = "iefdesigncenter";
	}
	try
	{
%>
		  <script language="JavaScript">
		    //XSSOK
			openHelp("<%=XSSUtil.encodeForJavaScript(context,helpMarkerMacro)%>","<%=XSSUtil.encodeForJavaScript(context,suiteDirectory)%>","<%=lanStr%>","<%=lanOnlineStr%>","<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>");
			window.close();
		 </script>
<%
	}
	catch(Exception ex)
	{
		ex.printStackTrace();
	}
%>
