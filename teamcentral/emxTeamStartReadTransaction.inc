<%--  emxTeamStartReadTransaction.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxTeamStartReadTransaction.inc.rca 1.16 Wed Oct 22 16:06:13 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%
  // start the read if not disabled
  String read = JSPUtil.getApplicationProperty(context,application,"emxTeamCentral.enableReadTransactions");
  if (!"false".equals(read) && read != null) {
    try {
      // Start the read transaction
      ContextUtil.startTransaction(context, false);
    } catch (Exception e) {
      throw new Exception(e.getMessage());
    }
  }
%>
