<%--  emxPaginationInclude.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPaginationInclude.inc.rca 1.29 Wed Oct 22 16:09:13 2008 przemek Experimental przemek $
--%>
 
<%@ page import = "com.matrixone.apps.framework.ui.*" %>
  

<%
  // create a pagination object to be used
  emxPagination emxPage = new emxPagination(context, session, request);
%>
