<%
	
	String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
	String objectId = ids[0];
%>

<script>
	window.location.href = "../common/emxPortal.jsp?objectId=<%=objectId%>&portal=CSSC3DLiveViewPortal";
</script>