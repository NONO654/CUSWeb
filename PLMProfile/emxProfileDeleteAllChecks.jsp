<%-- emxProfileDeleteChecks.jsp --%>

<%@ include file = "../emxUICommonAppInclude.inc"%>

<%
	String objectId = emxGetParameter(request,"objectId");
	
	HashMap mapArgs = new HashMap();
	mapArgs.put("objectId", objectId);
	
	String args[] = JPO.packArgs(mapArgs);
	JPO.invoke(context, "emxProfileCheck", null, "deleteAllChecks", args);

	
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		getTopWindow().refreshTablePage();
	</script>
