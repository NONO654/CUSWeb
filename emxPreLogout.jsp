<%--  emxPreLogout.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "emxTagLibInclude.inc"%>
<%@include file = "emxContentTypeInclude.inc"%>
<%@include file = "emxRequestWrapperMethods.inc"%>
<%
String logoutURL = "";
String tenantId = emxGetParameter(request, "tenant");
if(session.isNew())     
{         
	logoutURL = "emxLogin.jsp?tenant="+tenantId;
}     
else     
{         
	logoutURL = "emxLogout.jsp?tenant="+tenantId;
}
%>
<html>
<body onload=window.location='<%=logoutURL%>'>
</body>
</html>
