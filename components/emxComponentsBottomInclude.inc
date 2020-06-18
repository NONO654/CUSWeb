<%--  emxComponentsBottomInclude.jsp   -  Bottom Include File for all jsp pages
                                          in AppsCommon.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsBottomInclude.inc.rca 1.5 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $
--%>

<%
  String MQLNoticeFlag = (String)request.getAttribute("MQLNoticeFlag");

  if ( (MQLNoticeFlag != null) && (MQLNoticeFlag.equals("true")) )
  {
%>
<%@include file = "emxMQLNotice.inc"%>
<%
  }

 // System.out.println("Time For" +request.getRequestURI()+ ":=" +(System.currentTimeMillis() - startTime));
%>
