<%--
  emxProgramNoCache.inc

  Top Level Include File for Program Central Suite

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramNoCache.inc.rca 1.5 Wed Oct 22 15:49:27 2008 przemek Experimental przemek $"
--%>

<%
  // Prevent caching for HTTP 1.1
  response.setHeader("Cache-Control", "no-store");

  // Prevent caching for HTTP 1.0
  response.setHeader("Pragma", "no-cache");

  // Prevent caching at the proxy server.
  response.setDateHeader("Expires", 0);
%>

