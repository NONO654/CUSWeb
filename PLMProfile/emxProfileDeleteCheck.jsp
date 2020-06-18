<%-- emxProfileDeleteCheck.jsp --%>

<%@ include file = "../emxUICommonAppInclude.inc"%>

<%
	String objectId = emxGetParameter(request,"objectId");
	String parentOID = emxGetParameter(request,"parentOID");
	
	HashMap mapArgs = new HashMap();
	mapArgs.put("objectId", objectId);
	mapArgs.put("parentOID", parentOID);
	
	String args[] = JPO.packArgs(mapArgs);
	JPO.invoke(context, "emxProfileBase", null, "deleteCheck", args);

	
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
		getTopWindow().close();
	</script>
