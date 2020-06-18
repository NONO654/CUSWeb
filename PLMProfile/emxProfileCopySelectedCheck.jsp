<%-- emxProfileCopySelectedCheck.jsp --%>

<%@ include file = "../emxUICommonAppInclude.inc"%>

<%
	System.out.println("START emxProfileCopySelectedCheck.jsp");
	
	String objectIds[] = emxGetParameterValues(request,"emxTableRowId");
	String parentOID = emxGetParameter(request,"parentOID");
	
	HashMap mapArgs = new HashMap();
	mapArgs.put("objectId", objectIds);
	mapArgs.put("parentOID", parentOID);
	
	String args[] = JPO.packArgs(mapArgs);
	JPO.invoke(context, "emxProfileBase", null, "cloneCheck", args);

	System.out.println("END emxProfileDeleteCheck.jsp");
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		getTopWindow().refreshTablePage();
	</script>
