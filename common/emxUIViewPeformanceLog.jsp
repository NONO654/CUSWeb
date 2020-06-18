<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
String timeStamp = request.getParameter("timeStamp");
HashMap tableData = indentedTableBean.getTableData(timeStamp);
StringBuilder logBuilder = new StringBuilder();
logBuilder.append("<section style='font-weight:bold;white-space: pre-wrap;font-family: Arial, Helvetica, sans-serif;font-size:12px'>");
logBuilder.append("Total number of objects&nbsp;&nbsp;&nbsp;:   " + tableData.get("logTotNoOfObj"));
logBuilder.append("<br />");
logBuilder.append("Total number of columns : " + tableData.get("logNoOfCols"));
logBuilder.append("</section><br />");
logBuilder.append("<table style='white-space: pre-wrap;width:100%' border='0px'><tr><td style='bgcolor:#d1d4d4;font-weight:bold;font-family: Arial, Helvetica, sans-serif;font-size:14px'>");
logBuilder.append("<u>Server Log</u>");
logBuilder.append("</td></tr><tr><td style='font-family: Arial, Helvetica, sans-serif;font-size:12px'>");
logBuilder.append("<b>Total time taken on the server side : " + ((Long)tableData.get("totalServerTime")).toString() + "</b>");
if(tableData!=null) {
	logBuilder.append((StringBuilder)tableData.get("logBuffer"));
}
logBuilder.append(System.getProperty("line.separator"));
logBuilder.append("</td></tr>");
out.println(logBuilder.toString() + ",totalServerTime=" + ((Long)tableData.get("totalServerTime")).toString()); 
%>

