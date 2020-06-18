
<%--  emxDesignBottomInclude.inc

  Bottom Include File for all jsp pages is Product Central Suite

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/emxDesignBottomInclude.inc 1.3.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$;

--%>

<%
  String MQLNoticeFlag = (String)request.getAttribute("MQLNoticeFlag");

  if ( (MQLNoticeFlag != null) && (MQLNoticeFlag.equals("true")) )
  {
%>

<%@include file = "../components/emxMQLNotice.inc"%>

<%
  }
%>
