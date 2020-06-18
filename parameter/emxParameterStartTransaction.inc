<%--  emxParameterStartTransaction.inc   -

   Copyright (c) 1992-2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.
--%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%
    try {
      // Start the update transaction
      ContextUtil.startTransaction(context, true);
    } catch (Exception e) {
      throw new Exception(e.getMessage());
    }
%>
