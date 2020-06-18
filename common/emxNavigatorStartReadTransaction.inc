<%--  emxNavigatorStartReadTransaction.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxNavigatorStartReadTransaction.inc.rca 1.4 Wed Oct 22 15:48:32 2008 przemek Experimental przemek $
--%>

<%
  // By default the Transcation will be "OFF"
  String readTrxnFlag = "false"; 

  //get value from system properties
  readTrxnFlag = getSystemProperty(application, "emxNavigator.enableReadTransactions");

  // start the read tansaction if not disabled
  if ( (readTrxnFlag != null) && (!readTrxnFlag.equalsIgnoreCase("false")) ) {  
    context.connect();
    context.start(false);
  }
%>
