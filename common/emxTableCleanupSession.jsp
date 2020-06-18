<%--  emxTableCleanupSession.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableCleanupSession.jsp.rca 1.8 Wed Oct 22 15:48:38 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
    String timeStamp = com.matrixone.apps.domain.util.Request.getParameter(request, "timeStamp");
    tableBean.removeTableData(timeStamp);
%>
