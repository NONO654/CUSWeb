<%--  emxRequestWrapperMethods.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRequestWrapperMethods.inc.rca 1.25 Wed Oct 22 16:09:52 2008 przemek Experimental przemek $
--%>

<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, java.util.*,
                         java.io.*,com.matrixone.apps.domain.util.*" %>
<%!
  //
  // check for request Attribute if request.getParameter returns null
  // Also check if the value is "null" string and if so return null
  //
  static public String emxGetParameter(HttpServletRequest request, String parameter)
  {
         return com.matrixone.apps.domain.util.Request.getParameter(request, parameter);
  }

  //
  // check for request Attribute if request.getParameter returns null
  // Also check if the value is "null" string and if so return null
  //
  static public String emxGetParameter(HttpServletRequest request, String parameter, String encoding) throws Exception 
  {
          return com.matrixone.apps.domain.util.Request.getParameter(request, parameter, encoding);
  }

  //
  // if same parameter is sent multiple times in a request
  //
  static public String[] emxGetParameterValues(HttpServletRequest request, String parameter)
  {
	return com.matrixone.apps.domain.util.Request.getParameterValues(request, parameter);
   }

  //
  // return the list of parameter names
  //
  static Enumeration emxGetParameterNames(HttpServletRequest req)
  {
	return req.getParameterNames();
  }

  //
  // return the Querystring of request
  //
  static public String emxGetQueryString(HttpServletRequest request)
  {
	return request.getQueryString();
  }
%>
