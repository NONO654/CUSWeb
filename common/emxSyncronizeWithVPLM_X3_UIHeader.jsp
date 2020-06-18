
<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

<head>
<title></title>
<%@include file = "../emxStyleDefaultInclude.inc"%> 
<%@include file = "../emxStyleDialogInclude.inc"%> 
<script src="scripts/emxNavigatorHelp.js" type="text/javascript"></script>
</head>

<%
    String header 	= emxGetParameter(request, "header_var");
    String progressImage = "../common/images/utilProgressSummary.gif";
%>

<body>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td>&nbsp;</td>
</tr>
<tr>
<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt=""></td>
</tr>
</table>

<table border="0" width="100%" cellspacing="2" cellpadding="4">
<tr>
<td class="pageHeader" width="99%"><%=header%></td>
<td><div id="imgProgressDiv" style="visibility: hidden;">&nbsp;<img src="<%=progressImage%>" width="21" height="19" name="progress">&nbsp;</div></td>
</tr>
</table>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt=""></td>
</tr>
</table>

</body>
</html>
