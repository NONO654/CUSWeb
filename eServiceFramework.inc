<%--  eServiceFramework.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: eServiceFramework.inc.rca 1.31 Wed Oct 22 16:09:51 2008 przemek Experimental przemek $
--%>

<%@include file = "emxRequestWrapperMethods.inc"%>
<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, java.util.*" errorPage="eServiceError.jsp"%>
<%
  String pageName = request.getRequestURI();
  if (request.getQueryString() != null) {
    pageName += "?" + request.getQueryString();
  }
  Framework.setTargetPage(session, pageName);
  if (!Framework.isLoggedIn(request)) {
    %>
    <jsp:forward page ="eServiceLogin.jsp"/>
    <%
    return;
  }
matrix.db.Context context = null;//Framework.getContext(session);
try
{
  context = Framework.getFrameContext(session);
}
catch (Exception ex)
{
}

%>
