<%-- emxTeamCommitTransaction.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxTeamCommitTransaction.inc.rca 1.12 Wed Oct 22 16:06:04 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%
  try {
    // Commit the transaction
    ContextUtil.commitTransaction(context);
  } catch (Exception e) {
    throw new Exception(e.getMessage());
  }
%>
