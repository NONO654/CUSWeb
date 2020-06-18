<html>
	<%@include file = "../common/emxNavigatorInclude.inc"%>
	<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

	<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>

	<%
		String tableID = Request.getParameter(request, "tableID");
	%>

	<head>
		<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
		<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
		<script language="javascript">
			function filterData()
			{
				var filterProcessURL="emxPLMOnlineAdminCustomFilterProcess.jsp";
				document.filterIncludeForm.action = filterProcessURL;
				document.filterIncludeForm.target = "listHidden";
				document.filterIncludeForm.submit();
			}
		</script>
	</head>

	<body>
		<form name="filterIncludeForm">
			<table border="0" cellspacing="2" cellpadding="0" width="100%">
				<tr>
				<td width="99%">
				<table border="0" cellspacing="0" cellpadding="0" width="100%">
					<tr>
					<td class="pageBorder"><img src="images/utilSpacer.gif"	width="1" height="1" alt=""></td>
					</tr>
				</table>
					</td></tr>
				</table>
				<table>
					<tr>
					<!--<td width="100"><label> </label></td>-->
					<td class="inputField" >
						<input type="text" name="searchName" value="*">
					</td>
					<td width="50"> &nbsp; </td>
					<td width="150"><input type="button" name="btnFilter" value="Filter..." onclick="javascript:filterData()"></td>
					</tr>
			</table>
			<input type="hidden" name="tableID" value="<%=tableID%>">
		</form>
	</body>
</html>
