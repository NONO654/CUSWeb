<%--  emxVPMImportProcessing.jsp   -   Call Project Team to manage Export
   Copyright (c) 1992-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
       
   RCI - Wk15 2010 - Creation
--%>

<%@page import = "com.matrixone.vplmintegration.util.*"%>

<%@ page import = "com.dassault_systemes.VPLMJSRMExchange.VPLMJExchangeAccess"%>


<%--@include file ="./emxInfoUtils.inc"--%>
<%--<%@include file = "../emxUICommonAppInclude.inc"%>--%>

<html>
     <%@include file = "emxNavigatorInclude.inc"%>
    <%@include file = "emxNavigatorTopErrorInclude.inc"%>
    <emxUtil:localize id="i18nId" bundle="emxVPLMProductEditorStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
   <%


    String msgString = null;
    try {
        VPLMJExchangeAccess accessServices = VPLMJExchangeAccess.getInstance();
        accessServices.ImportImpl();
        }
    catch (Exception e) {
        session.putValue("error.message", e.getMessage());
        e.printStackTrace();
        msgString = e.getMessage();
        emxNavErrorObject.addMessage(msgString);
        throw e;
        }
 
/////////////////// gérer les messages ....

    %>
        <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>


