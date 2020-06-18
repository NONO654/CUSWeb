<%--  emxChart.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxChart.jsp.rca 1.9 Wed Oct 22 15:48:17 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc" %>
<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="chartBean" class="com.matrixone.apps.framework.ui.UIChart" scope="request"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
String timeStamp = emxGetParameter(request, "timeStamp");
String header = "";
Vector userRoleList = PersonUtil.getAssignments(context);
boolean fromTable = true;
MapList relBusObjPageList = new MapList();

try {
    ContextUtil.startTransaction(context, false);
	if(timeStamp == null || "".equals(timeStamp) || "null".equalsIgnoreCase(timeStamp)) {
		timeStamp = tableBean.getTimeStamp();
		fromTable = false;
	    // Process the request object to obtain the table data and set it in Table bean
	    tableBean.setTableData(context, pageContext,request, timeStamp, userRoleList);
	}

    HashMap tableControlMap = tableBean.getControlMap(timeStamp);
    header = tableBean.getPageHeader(tableControlMap);
    HashMap tableData = tableBean.getTableData(timeStamp);
    HashMap requestMap = tableBean.getRequestMap(tableData);

    String tableRowIdList[] = (String[])requestMap.get("emxTableRowId");
    MapList relBusObjList = tableBean.getFilteredObjectList(tableData);
	if(!fromTable)
	{
		relBusObjPageList = relBusObjList;
		tableBean.setEditObjectList(context, timeStamp, relBusObjPageList, null);
	}
	else if (relBusObjList != null && relBusObjList.size() > 0)
	{
		if ( tableBean.isMultiPageMode(tableControlMap))
		{
			int currentIndex = tableBean.getCurrentIndex(tableControlMap);
			int lastPageIndex = tableBean.getPageEndIndex(tableControlMap);

			for (int i = currentIndex; i < lastPageIndex; i++)
			{
				if (i >= relBusObjList.size())
					break;
				relBusObjPageList.add(relBusObjList.get(i));
			}
		} else {
			relBusObjPageList = relBusObjList;
		}

		if(tableRowIdList == null || tableRowIdList.length <= 0) {
			tableBean.setEditObjectList(context, timeStamp, relBusObjPageList, null);
		} else {
			tableBean.setEditObjectList(context, timeStamp, relBusObjList, tableRowIdList);
		}

		relBusObjPageList = tableBean.getEditObjectList(context, timeStamp);
	}

    ContextUtil.commitTransaction(context);
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}
%>

	<head>
		<title><xss:encodeForHTML><%=header%></xss:encodeForHTML></title>
		<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
		<%@include file = "emxUIConstantsInclude.inc"%>
        <%@include file = "../emxStyleDefaultInclude.inc"%>
        <script type="text/javascript">
            addStyleSheet("emxUIChannelDefault");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
        </script>

        <script language="JavaScript" src="scripts/emxUICore.js"></script>
        <script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
	</head>

<%
	if(relBusObjPageList.size() > 0) {
		String portalMode = emxGetParameter(request, "portalMode");
		String framesetRows = "*";
		boolean isportal = false;
		if(portalMode != null && "true".equalsIgnoreCase(portalMode)) {
			framesetRows = "50,*";
			isportal = true;
		}

		if (isportal) {
%>
            <div id="pageHeadDiv">
			<form name="chartHeaderForm" method="post">
                <div class="filter-row"></div>

                    <jsp:include page = "emxToolbar.jsp" flush="true">
					    <jsp:param name="toolbar" value=""/>
					    <jsp:param name="helpMarker" value="false"/>
					    <jsp:param name="PrinterFriendly" value="false"/>
					    <jsp:param name="export" value="false"/>
					    <jsp:param name="portalMode" value="true"/>
				    </jsp:include>
            </form>
            </div>
<%
		}
		HashMap tableData = tableBean.getTableData(timeStamp);
		String timeZone = (String)session.getAttribute("timeZone");
		try {
		    chartBean.setChartData(context, tableData, timeZone, request.getLocale());
		} catch (Exception ex) {}
%>
			<div id="divPageBody">
			 <jsp:include page = "emxChartInclude.jsp" flush="true"/>
			</div>
<%
	} else {
    	String stringResFileId="emxFrameworkStringResource";
    	String strLanguage = request.getHeader("Accept-Language");
		String noObjectAlert = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), "emxFramework.ChartOptions.NoObjectAlert");
%>
		<body>
		<%=noObjectAlert%>
		</body>
<%
	}
%>
</html>
