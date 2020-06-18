<%--  emxBlank.jsp   - Component Frame for "Build ECO"

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxBlank.jsp.rca 1.7 Wed Oct 22 15:48:43 2008 przemek Experimental przemek $
--%>
<%
response.addHeader("Cache-Control", "max-age=604800"); 
long now = System.currentTimeMillis(); 
response.setDateHeader("Expires", now + 604800*1000);
%>
<html>
<title>blank Document</title>
<body>

</body>
</html>
