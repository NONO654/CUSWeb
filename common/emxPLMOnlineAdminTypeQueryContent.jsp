

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<!--include required for showModalDialog() function-->
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIModal.js"></script>

<html>

<head>

	<title></title>
	
	<link href="../common/styles/emxUIDefault.css" rel="stylesheet" type="text/css" />

	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<link href="styles/emxPLMOnlineAdminStyle.css" rel="stylesheet" type="text/css" />

	<script language="javascript">
			
			//submit query
			function submitQuery(){

				//get all values in textbox if "All" is checked
				var typePattern = getAllCheckboxValues("typeQueryForm", "typeCheckbox", "typeTextboxId");

				//submit form
				document.typeQueryForm.action = "emxPLMOnlineAdminTypeQueryResult.jsp";
				document.typeQueryForm.submit();
				//startProgressBar();
			}
			
	</script>

</head>
<body onload="init();">
	<%
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_byName    = getNLS("Access.Type.Query.byName");
        String i18_Name      = getNLS("Access.Type.Query.Name");
	%>

<form name="typeQueryForm" target="_parent">
	
	<table border="1" cellspacing="0" cellpadding="0" width="100%" >
		<tr>
			<td width="5%" class="barTDInQuery" align="center"><img src="../common/images/iconSmallRule.gif" /></td>
			<td width="85%" class="barTDInQuery"><b><%=i18_byName%></b></td>
			<td width="7%" class="barTDInQuery" ><img src="../common/images/buttonChannelCollapse.gif" id="typeImgId" onclick="switchMenu('divByPolicy', this, 'expandCollapse');"/></td>
		</tr>
	
	</table>
	<div id="divByPolicy">
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr>
				<td width="40%" class="label"><%=i18_Name%></td>
				<td class="inputField"> <input type="text" name="typePattern" id="typeTextboxId"  style="width:220px" value="*">
				</td>
			</tr>
			
		</table>
	</div>
	
</form>
                                    
</body>
</html>
