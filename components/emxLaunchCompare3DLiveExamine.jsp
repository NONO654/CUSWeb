
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<html>
<head>
	<title>BOM Compare Report</title>
</head>
<%
	
	String objectId1 = emxGetParameter(request, "objectId1");
	String objectId2 = emxGetParameter(request, "objectId2");

	if(objectId1 != null && objectId2 != null) {
%>
<body>
<form method="post">
<div id="divPageBody">
<table width="100%" height="100%">
<tr>
	<td>
		<iframe width="100%" height="100%" frameborder="0" border="0" src="emxLaunch3DLiveExamine.jsp?3DCompare=true&crossHighlight=true&timeStamp=null&objectId=<%=XSSUtil.encodeForHTML(context, objectId1) %>" name="APPLaunch3DLiveChannel"></iframe>
	</td>
	<td>
		<iframe width="100%" height="100%" frameborder="0" border="0" src="emxLaunch3DLiveExamine.jsp?3DCompare=true&crossHighlight=true&timeStamp=null&objectId=<%=XSSUtil.encodeForHTML(context, objectId2) %>" name="APPLaunch3DLiveChannelCompare"></iframe>
	</td>	
</tr>	
</table>

</div>
<%
	} else {
		out.println("Please select parts to compare");
	}
%>
</form>

</body>
</html>
