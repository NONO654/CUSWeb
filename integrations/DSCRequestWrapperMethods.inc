<%--  DSCRequestWrapperMethods.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--  

   static const char RCSID[] = $Id: /ENODesignerCentral/CNext/webroot/integrations/DSCRequestWrapperMethods.inc 1.3 Sat Apr 26 10:22:24 2008 GMT ds-mbalakrishnan Experimental$
--%>

<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, java.util.*, java.io.*,java.lang.*,com.matrixone.apps.domain.util.*" %>

<%!
  //
  // check for request Attribute if request.getParameter returns null
  // Also check if the value is "null" string and if so return null
  //
  static public String emxGetParameter(HttpServletRequest request, String parameter)
  {

      try
      {
          return com.matrixone.apps.domain.util.Request.getParameter(request, parameter);
      } catch(Exception ex) {
          System.out.println("EXCEPTION IN emxGetParameter()");
          return null;
      }

  }
%>

<%!
  //
  // check for request Attribute if request.getParameter returns null
  // Also check if the value is "null" string and if so return null
  //
  static public String emxGetParameter(HttpServletRequest request, String parameter, String encoding)
  {

      try
      {
          return com.matrixone.apps.domain.util.Request.getParameter(request, parameter, encoding);
      } catch(Exception ex) {
          System.out.println("EXCEPTION IN emxGetParameter()");
          return null;
      }

  }
%>

<%!
  //
  // if same parameter is sent multiple times in a request
  //
  static public String[] emxGetParameterValues(HttpServletRequest request, String parameter)
  {
   String parameterValues[] = request.getParameterValues(parameter);
   return parameterValues;
   }
%>

<%!
  //
  // return the list of parameter names
  //
  static Enumeration emxGetParameterNames(HttpServletRequest req)
  {
    Enumeration paramEnum = req.getParameterNames();
    return (paramEnum);
  }
%>

<%!
  //
  // return the Querystring of request
  //
  static public String emxGetQueryString(HttpServletRequest request)
  {
    String queryString = request.getQueryString();
    return queryString;
  }
%>
