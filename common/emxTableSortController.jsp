<%--  emxTableSortController.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

String timeStamp = Request.getParameter(request, "timeStamp");
String transactionType = emxGetParameter(request, "TransactionType");
boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));

try {

    ContextUtil.startTransaction(context, updateTransaction);
    String strSortColumnName =Request.getParameter(request, "sortColumnName");
    String strSortDirection = Request.getParameter(request, "sortDirection");
    HashMap hmpTableData = tableBean.getTableData(timeStamp);
	HashMap hmpRequest = tableBean.getRequestMap(hmpTableData);
	String strUIType = (String)hmpRequest.get("uiType");
	String strTableName ="";
	if(strUIType!=null && "table".equals(strUIType))
	{
		strTableName = (String)hmpRequest.get("table");
	}
	boolean isUserTable = com.matrixone.apps.framework.ui.UITableCustom.isUserTable(context,strTableName);
	if(isUserTable)
	{
	   	  hmpRequest.put("customSortColumns",strSortColumnName);
	   	  hmpRequest.put("customSortDirections",strSortDirection);
	   	   
	}
	
    HashMap tableControlMap = tableBean.getControlMap(timeStamp);

    if (strSortDirection == null || strSortDirection.length() == 0)
        strSortDirection = "ascending";

    if (strSortColumnName != null && strSortColumnName.trim().length() > 0 && (!(strSortColumnName.equals("null"))))
    {
        strSortColumnName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(strSortColumnName);

        tableBean.setControlMapStringElement(tableControlMap, "SortColumnName", strSortColumnName);
        tableBean.setControlMapStringElement(tableControlMap, "SortDirection", strSortDirection);

        tableBean.sortObjects(context, timeStamp);
    }

    Integer iPagination = tableBean.getPagination(tableControlMap);
    int currentIndex = tableBean.getCurrentIndex(tableControlMap);
    int lastPageIndex = tableBean.getPageEndIndex(tableControlMap);

    tableBean.setPagination(tableControlMap, iPagination);
    tableBean.setCurrentIndex(tableControlMap, new Integer(currentIndex));
    tableBean.setPageEndIndex(tableControlMap, new Integer(lastPageIndex));


%>
    <script language="JavaScript">
        if (parent.listDisplay)
        {
            parent.listDisplay.location.reload();
            //parent.listFoot.location.reload();
        } else if (parent.formViewDisplay) {
            parent.formViewDisplay.location.reload();
        }
    </script>
<%

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    ex.printStackTrace();
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}

%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
