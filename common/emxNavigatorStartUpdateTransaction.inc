<%--  emxNavigatorStartUpdateTransaction.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxNavigatorStartUpdateTransaction.inc.rca 1.4 Wed Oct 22 15:48:25 2008 przemek Experimental przemek $
--%>

<%
  // By default the Transcation will be "OFF"
  String updateTrxnFlag = "false"; 

  //get value from system properties
  updateTrxnFlag = getSystemProperty(application, "emxNavigator.enableUpdateTransactions");  

  // start the update tansaction if not disabled
  if ( (updateTrxnFlag != null) && (!updateTrxnFlag.equalsIgnoreCase("false")) ) {
    context.connect();
    context.start(true);
  }
%>
