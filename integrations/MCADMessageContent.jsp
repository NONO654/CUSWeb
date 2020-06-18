<%--  MCADMessageContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%   
	String isContentHtml  = emxGetParameter(request, "isContentHtml");
	String message        = (String)session.getAttribute("mcadintegration.message");
		
		if(message != null)
			message		= MCADUrlUtil.hexDecode(message);

	session.removeAttribute("mcadintegration.message");

	//Get all the HTML problem creating characters encoded properly.
	if(isContentHtml != null && isContentHtml != "" && ("true".equals(isContentHtml) || "TRUE".equals(isContentHtml)))
	{
		//do nothing.
	}
	else
	{		
		if(message != null)
		message = getHtmlSafeString(message);
	}
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">
</head>
<body>
<form method=POST>
	<script language="javascript">
	        //XSSOK
		var message = "<%=message%>";

		if(!message || message == 'null')
		{
			message = top.opener.top.messageToShow;	
			if(!message)
			{
				message = top.opener.messageToShow;
			}
		}

		document.write("<table border='0' cellspacing='0' cellpadding='5' width='100%'>");
		document.write("<tr>");
		document.write("<td width='100%' class='MCADMsgBody'>" + unescape(message) + "</td>");
		document.write("</tr>");
		document.write("</table>");
	</script>
	</form>
	</body>
<html>
