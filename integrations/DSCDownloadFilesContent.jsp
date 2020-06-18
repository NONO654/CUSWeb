<%--  DSCDownloadFilesContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc" %>
<html>
<body>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");	
	String objectList = emxGetParameter(request, "objectlist"); 
	StringTokenizer tokens = new StringTokenizer(objectList, "|");		
%>
	<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
	<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
	
	<table border="0" cellpadding="3" cellspacing="2" width="100%" height="15">
		
	<tr>
		<th class=sorted>
			<table border="0" cellspacing="0" cellpadding="0">	
			        <!--XSSOK-->
				<tr ><th><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name")%></th></tr>
			</table>
		</th>
	</tr>
<%
   String fileName = "";
   int i = 0;
   while(tokens.hasMoreTokens())
   {	
	   String evenOrOdd   = (i%2 == 0 ? "even" : "odd");
	   fileName = tokens.nextToken();
	   i++;
%>
       <!--XSSOK-->
	   <tr class="<%= evenOrOdd %>">		  
		<td align="left">&nbsp;<xss:encodeForHTML><%=fileName%></xss:encodeForHTML></td>
	   </tr>
<%
	}

%>
</table>
</body>
</html>
	
