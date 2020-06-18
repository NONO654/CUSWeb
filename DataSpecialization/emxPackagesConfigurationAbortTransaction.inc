<%--  emxPackagesConfigurationAbortTransaction.jsp   -

   Copyright (c) 1992-2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxPackagesConfigurationAbortTransaction.inc.rca 1.10 Wed Oct 22 16:06:30 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%
  // Abort the transaction
  ContextUtil.abortTransaction(context);
%>
