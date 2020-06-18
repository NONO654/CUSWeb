<%--
  emxPopupSelectUtil.inc

  Methods used for popup selection, for use with win9x clients
  Workaround for limitation of the number of SELECT statements on a browser
  in win9x platform, see Microsoft Knowledge Base Article - 265489

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPopupSelectUtil.inc.rca 1.4 Wed Oct 22 15:49:35 2008 przemek Experimental przemek $
--%>
<%
  final String userAgent = request.getHeader("User-Agent"); 
  final boolean isWin9x = userAgent.toLowerCase().indexOf("windows 9") >= 0;
%>
