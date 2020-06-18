<%--  emxFormViewCloseProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormViewCloseProcess.jsp.rca 1.6 Wed Oct 22 15:48:59 2008 przemek Experimental przemek $
--%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<%
    String timeStamp = com.matrixone.apps.domain.util.Request.getParameter(request, "timeStamp");
    tableBean.removeTableDataMaps(timeStamp);
    // System.out.println("Removed table Maps" );
%>
