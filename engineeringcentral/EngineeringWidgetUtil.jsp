<%--  EngineeringWidgetUtil.jsp - This util jsp for Engineering Part and BOM widgets
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<%
//For BOM CHARTS Widgets
String functionality = emxGetParameter(request, "functionality");
String widget = "";

if("bomCharts".equalsIgnoreCase(functionality)) {
	Map map = new HashMap();
	map.put("objIds",emxGetParameter(request, "objIds"));
	map.put("relIds",emxGetParameter(request, "relIds"));
	map.put("rootObjectId",emxGetParameter(request, "rootObjectId"));
	CacheUtil.setCacheMap(context, "bomChartData", map);
	widget = "ENG_Experience_BOM_ChartView";
}
else if("partCharts".equalsIgnoreCase(functionality)) {
	Map map = new HashMap();
	map.put("objIds",emxGetParameter(request, "objIds"));
	CacheUtil.setCacheMap(context, "partsChartData", map);
	widget = "ENG_Experience_Parts_ChartView";
}	
%>
<script> 

var widgetURL = "../webapps/Foundation/foundation-basic.html?e6w-widget=<%=widget%>";

showModalDialog(widgetURL, 1850, 1630,true,"Large");
</script>	

