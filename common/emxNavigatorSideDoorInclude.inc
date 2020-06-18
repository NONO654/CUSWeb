<%--  emxNavigatorSideDoorInclude.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorSideDoorInclude.inc.rca 1.7 Wed Oct 22 15:48:06 2008 przemek Experimental przemek $
--%>

<%
  String sPortalMode = emxGetParameter(request, "portal");
  String strRequestURL = request.getServletPath();
  String strQueryString = request.getQueryString();

  String strFullURL = "";
  if ( strQueryString != null && strQueryString.length() > 0 )
    strFullURL = strRequestURL + "?" + strQueryString;
  else
    strFullURL = strRequestURL;

  // System.out.println("strFullURL : " + strFullURL);
  session.setAttribute("ForwardURL", strFullURL);

// Side door implementation
if ( sPortalMode != null && sPortalMode.equalsIgnoreCase("true") )
  session.setAttribute("portal", sPortalMode);

%>
