<%--  emxChartDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxChartDisplay.jsp.rca 1.5 Wed Oct 22 15:48:58 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="chartBean" class="com.matrixone.apps.framework.ui.UIChart" scope="request"/>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
String timeStamp = emxGetParameter(request, "timeStamp");
HashMap tableData = tableBean.getTableData(timeStamp);
String timeZone = (String)session.getAttribute("timeZone");
try {
	chartBean.setChartData(context, tableData, timeZone, request.getLocale());
} catch (Exception ex) {
}
%>

<body>
	<jsp:include page = "emxChartInclude.jsp" flush="true"/>
</body>
</html>
