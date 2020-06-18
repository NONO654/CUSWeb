
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<html>
<head>
	<title>BOM Compare Report</title>
</head>
<%
	
	String objectId1 = emxGetParameter(request, "objectId1");
	String objectId2 = emxGetParameter(request, "objectId2");
	String currentCompareTableName = emxGetParameter(request, "currentCompareTableName");

	if(objectId1 != null && objectId2 != null) {
%>
<body>
<form method="post">
<div id="divPageBody">
<table width="100%" height="100%">
<tr>
	<td>
	<!-- XSSOK -->
		<iframe width="100%" height="100%" id="firstframe" frameborder="0" border="0" src="emxLaunch3DPlay.jsp?3DCompare=true&firstLoad=true&crossHighlight=true&timeStamp=null&objectId=<%=XSSUtil.encodeForHTML(context, objectId1) %>&objectId2=<%=XSSUtil.encodeForHTML(context, objectId2) %>&currentCompareTableName=<%=XSSUtil.encodeForHTML(context, currentCompareTableName) %>" name="ENGLaunch3DPlayChannel"></iframe>
	</td>
	<td>
		<iframe width="100%" height="100%" id="secondframe" frameborder="0" border="0" name="ENGLaunch3DPlayCompareSecondFrame" ></iframe>
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
