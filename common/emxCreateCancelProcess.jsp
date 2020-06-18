<%--  emxCreateCancelProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCreateCancelProcess.jsp.rca 1.1.5.4 Wed Oct 22 15:48:06 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>

<%
    String timeStamp = emxGetParameter(request, "timeStamp");
try {
    ContextUtil.startTransaction(context, false);
    // Clean the session HashMap for this entry with timestamp
    createBean.removeFormData(timeStamp);

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
} finally {
    ContextUtil.commitTransaction(context);
}
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
