<%-- emxProfileUpdateRefresh.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
	getTopWindow().refreshTablePage();
</script>
