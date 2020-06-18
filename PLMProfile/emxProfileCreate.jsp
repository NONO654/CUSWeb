<%-- emxProfileCreate.jsp --%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		doCancel('slidein', 'null', 'null');
		getTopWindow().location.href = '../common/emxIndentedTable.jsp?table=PROProfileTable&toolbar=PROBrowserToolbar&program=emxProfileBase:getProfilesList&selection=multiple';
	</script>
