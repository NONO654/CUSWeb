<%--
  emxTeamNoCache.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTeamNoCache.inc.rca 1.6 Wed Oct 22 16:06:20 2008 przemek Experimental przemek $";
--%>
<%
response.setDateHeader("Expires", 0); 
response.setHeader("pragma", "no-cache"); 
if(request.getProtocol().equals("HTTP/1.1")) 
{ 
response.setHeader("Cache-Control","no-cache"); 
}

response.setDateHeader("max-age", 0); 

%>
