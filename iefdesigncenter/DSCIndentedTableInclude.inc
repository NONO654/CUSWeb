<%--  DSCIndentedTableInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   This inc file is used to get the basic information requied to refresh the indented table page.
   it will redirect the refresh request to the DSCIndentedTableRefresh.jsp
--%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%

		String sortColumnName	= "";
		String sortDirection	= "";

		String timeStamp	= emxGetParameter(request, "timeStamp");
		if(timeStamp != null && !"".equals(timeStamp) && indentedTableBean != null)
		{
			HashMap tableData	= indentedTableBean.getTableData(timeStamp);
			if(tableData != null)
			{
				HashMap controlMap	= (HashMap)tableData.get("ControlMap");
				
				sortColumnName	= (String)controlMap.get("SortColumnName");
				sortDirection	= (String)controlMap.get("SortDirection");

				if(sortColumnName == null || "null".equals(sortColumnName))
				{
					sortColumnName = "";
				}

				if(sortDirection == null || "null".equals(sortDirection))
				{
					sortDirection = "";
				}
			}
		}

%>

<form name="DSCIndentedTableRefreshForm" action="../iefdesigncenter/DSCIndentedTableRefresh.jsp">
	<input type="hidden" name="sortColumnName" value="<xss:encodeForHTMLAttribute><%=sortColumnName%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="sortDirection" value="<xss:encodeForHTMLAttribute><%=sortDirection%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="refreshFrame" value="">
</form>

<script language="JavaScript">

function refreshIndentedTable(refreshFrameName)
{
	document.DSCIndentedTableRefreshForm.refreshFrame.value = refreshFrameName;
	document.DSCIndentedTableRefreshForm.submit();
}

</script>
