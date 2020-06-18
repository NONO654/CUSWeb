<%--  emxComponentsCommitTransaction.inc   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxComponentsCommitTransaction.inc.rca 1.5 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $
--%>

<%

  if(context.isTransactionActive())
  {
    context.commit();
    context.disconnect();
  }  
    
%>

