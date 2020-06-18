<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>

<html>
<head>
    <link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
</head>
<%
    initNLSCatalog("myMenu",request);
	String NonAppropriateContextAdmin = getNLS("NonAppropriateContextAdmin");
%>
<body>
	<div class="transparencyTotal" id="loading"   style="z-index:1;position:absolute" >
		<table width="100%" style="height : 100%" >
			<tr valign="middle" align="middle">
				<td style="color:#990000 ; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt">
				<%=NonAppropriateContextAdmin%></td>
			</tr>
		</table>
	</div>
</body>
</html>
