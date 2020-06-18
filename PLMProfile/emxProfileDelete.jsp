<%-- emxProfileDelete.jsp --%>

<%@ include file = "../emxUICommonAppInclude.inc"%>

<%
	String objectIds[] = emxGetParameterValues(request,"emxTableRowId");
	
	HashMap mapArgs = new HashMap();
	mapArgs.put("emxTableRowId", objectIds);
	
	String args[] = JPO.packArgs(mapArgs);
	String errormsg  = (String) JPO.invoke(context, "emxProfileBase", null, "deleteProfile", args, Object.class);
	System.out.println(errormsg);
	if(errormsg.equalsIgnoreCase("")){
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		getTopWindow().refreshTablePage();
	</script>
<%
	} else {
%>
	<script language="javascript">
		alert("<%=errormsg%>");
	</script>
	<%
	}
%>
	
