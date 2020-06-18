<%--  emxEngrCommitTransaction.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%

  /*if(context.isTransactionActive())
  {
    context.commit();
    context.disconnect();
  }  */
  ContextUtil.commitTransaction(context);
    
%>

