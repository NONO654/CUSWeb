<%-- emxClientSideInfoProcessing.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxClientSideInfoProcessing.jsp.rca 1.5 Wed Oct 22 15:49:02 2008 przemek Experimental przemek $
--%>


                
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%
try{

    UINavigatorUtil.processClientSideData(context, pageContext);
  
} catch (Exception ex) {
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
