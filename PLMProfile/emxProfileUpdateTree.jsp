<%-- emxProfileUpdateTree.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
	String profileId = emxGetParameter(request,"profileId");
	if(profileId == null) {
		profileId = emxGetParameter(request,"objectId");
	}
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
	getTopWindow().location.href = "emxTree.jsp?objectId=<%=profileId%>";
</script>
