<%-- emxTableCalculationOptionsHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableCalculationOptionsHeader.jsp.rca 1.5 Wed Oct 22 15:47:49 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
try
{
    String timeStamp = emxGetParameter(request, "timeStamp");
    String HelpMarker = "emxtablecalculationoptions";

    String stringResFileId="emxFrameworkStringResource";
    String strLanguage = Request.getLanguage(request);
    String header = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.OptionsHeader", stringResFileId, strLanguage);
%>


<head>
	<title></title>
	<%@include file = "../emxStyleDefaultInclude.inc"%>
	<%@include file = "../emxStyleDialogInclude.inc"%>

	<script type="text/javascript">
			addStyleSheet("emxUIToolbar");
			addStyleSheet("emxUIMenu");
	</script>

	<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
	<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
	<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
	<script language="javascript" src="scripts/emxNavigatorHelp.js"></script>
</head>

<body>
<table border="0" cellspacing="2" cellpadding="2" width="100%">
<tr>
<td width="99%">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
	</tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
	<td width="1%" nowrap><span class="pageHeader" nowrap>&nbsp;<%=header%></span>
	</td>
	<td width="1%"><img src="images/utilSpacer.gif" width="1" height="25" alt="" vspace="6" /></td>
</tr>
</table>


<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value=""/>
    <jsp:param name="objectId" value=""/>
    <jsp:param name="relId" value=""/>
    <jsp:param name="parentOID" value=""/>
    <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
    <jsp:param name="editLink" value="false"/>
    <jsp:param name="header" value="<%=header%>"/>
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="helpMarker" value="<%=HelpMarker%>"/>
</jsp:include>

</td></tr></table>
</body>
<%
} catch (Exception ex) {
	if(ex.toString()!=null && (ex.toString().trim()).length()>0)
		emxNavErrorObject.addMessage("emxTableCalculationOptionsHeader.jsp:" + ex.toString().trim());
}
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
