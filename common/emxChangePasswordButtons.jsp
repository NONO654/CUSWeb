<%-- emxChangePasswordButtons.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxChangePasswordButtons.jsp.rca 1.8 Wed Oct 22 15:48:35 2008 przemek Experimental przemek $   
--%>

<html>

<%@include file="emxNavigatorInclude.inc"%>

<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxUIConstantsInclude.inc"%>
<head>
<title></title>

<%@include file="../emxStyleDefaultInclude.inc"%>
<%@include file="../emxStyleDialogInclude.inc"%>

<script language="javascript">
	function doDone() {
		if (getTopWindow().displayFrame.document.frmChangePass == null)
			getTopWindow().closeWindow();
		else
			getTopWindow().displayFrame.document.frmChangePass.target = "pwdHiddenFrame";
		getTopWindow().displayFrame.document.frmChangePass.submit();
	}

	function doCancel() {
		getTopWindow().closeWindow();
	}
</script>
</head>
<body class="dialog foot">
<table>
	<tr>
		<td class="functions"></td>
		<td class="buttons">
		<table border="0" width="100%">
			<tr>
				<td align="right">
				<table border="0">
					<tr>
						<td><a href="javascript:doDone()"><img
							src="images/buttonDialogDone.gif" border="0"
							alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Submit</emxUtil:i18n>" /></a></td>
						<td><a href="javascript:doDone()"><emxUtil:i18n
							localize="i18nId">emxFramework.Button.Submit</emxUtil:i18n></a></td>
						<td>&nbsp;&nbsp;</td>
						<td><a href="javascript:doCancel()"><img
							src="images/buttonDialogCancel.gif" border="0"
							alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n>" /></a></td>
						<td><a href="javascript:doCancel()"><emxUtil:i18n
							localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></a></td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>

</body>
<%@include file="emxNavigatorBottomErrorInclude.inc"%>
</html>





