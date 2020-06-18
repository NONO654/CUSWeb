<%--  emxNavigatorAbortTransaction.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxNavigatorAbortTransaction.inc.rca 1.4 Wed Oct 22 15:48:15 2008 przemek Experimental przemek $
--%>

<%
  // abort any active transactions
  if ( context.isTransactionActive() ) 
  {
    context.abort();
    context.disconnect();
  }
%>
