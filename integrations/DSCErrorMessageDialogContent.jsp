<%--  DSCErrorMessageDialogContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    Context context = integSessionData.getClonedContext(session);

%>

<html>
<head>
<link rel="stylesheet" href="../integrations/styles/emxIEFCommonUI.css" type="text/css">
</head>
<body>
<script language="JavaScript" src="./scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">

		var message = top.opener.top.messageToShow;	
		if(!message)
		{
			message = top.opener.messageToShow;
		}
		
        message = unescape(message);
				
		function csvExport()
		{			
			var result			= getIntegrationFrame(this).getAppletObject().callTreeTableUIObject("updateCSVData", message);
			if(result.indexOf("ERROR") == -1)
			{
				var tableURL="IEFTableExport.jsp?timeStamp=" + result;
				frames.location.href = tableURL;
			}
		}

		document.write("<table border='0' cellspacing='0' cellpadding='5' width='100%'>");
		document.write("<tr>");
		document.write("<td width='100%' class='node'>" + message + "</td>");
		document.write("</tr>");
		document.write("</table>");

<%   
    	String callBackFunction = Request.getParameter(request,"callBackFunction");
		
		if(callBackFunction == null)
			callBackFunction = "";

		if( callBackFunction != null && !callBackFunction.equals(""))
		{
%>
			window.onload=function()
			{
					var callbackFunction = eval(top.opener.top.<%=XSSUtil.encodeForJavaScript(context,callBackFunction)%>);	
					
					if(!callbackFunction)
					{
						callbackFunction = eval(top.opener.<%=XSSUtil.encodeForJavaScript(context,callBackFunction)%>);	
					}

					if(callbackFunction)
						callbackFunction();
			}
<%
		}
%>

	</script>
</body>
<html>
