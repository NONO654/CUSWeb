<%--
  emxProgramMethods.inc

  Defines methods for the Program Central Suite.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramMethods.inc.rca 1.23 Wed Oct 22 15:49:58 2008 przemek Experimental przemek $"
--%>

<%@page import="com.matrixone.apps.program.ProgramCentralUtil" %>

<%!
  // Call this method to internationalize variables in java.
  static public String i18nStringNow(String text, String languageStr) {
    i18nNow loc = new i18nNow();
    return (String)loc.GetString("emxProgramCentralStringResource", languageStr, text);
  }
%>
