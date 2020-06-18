<%-- emxProfileDeleteCheck.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
	System.out.println("START emxProfileDeleteCheck.jsp");
	
	String objectIds[] = emxGetParameterValues(request,"emxTableRowId");
	String parentOID = emxGetParameter(request,"parentOID");
	String timeStamp   		= emxGetParameter(request,"timeStamp");
	HashMap tableData 	= indentedTableBean.getTableData(timeStamp);
	TreeMap indexedList = (TreeMap)tableData.get("IndexedObjectList");		
	HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
	HashMap reqValuesMap    = UINavigatorUtil.getRequestParameterValuesMap(request);
	requestMap.put("RequestValuesMap", reqValuesMap); 
	requestMap.put("SelectedObjectId", objectIds);
	requestMap.put("parentOID", parentOID);
	requestMap.put("IndexedObjectList",indexedList);
	String objectId = (String)JPO.invoke(context, "emxProfileCheck", null, "deleteCheck", JPO.packArgs(requestMap), String.class);
	System.out.println("END emxProfileDeleteCheck.jsp");
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		getTopWindow().refreshTablePage();
	</script>
