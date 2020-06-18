<%--
  emxProgramPageHeader.inc

  Defines header tag for the Program Central Suite.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramPageHeader.inc.rca 1.8 Wed Oct 22 15:49:38 2008 przemek Experimental przemek $"
--%>

<%
  long emxProgramTimerHtmlStartTime = System.currentTimeMillis();
%>

<head>

  <title>
    <framework:i18n localize="i18nId">
      emxProgramCentral.Common.ProgramCentral
    </framework:i18n>
  </title>

  <%-- kds - link to style sheet in future --%>
  <%@ include file="emxProgramStyle.inc" %>

  <%@ include file="emxMQLNotice.inc" %>

  <%@ include file="emxProgramScripts.inc" %>


</head>

