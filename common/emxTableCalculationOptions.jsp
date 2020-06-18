<%--  emxTableCalculationOptions.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableCalculationOptions.jsp.rca 1.5 Wed Oct 22 15:49:00 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%
    String timeStamp = emxGetParameter(request, "timeStamp");
    String HelpMarker = "emxtablecalculationoptions";

    String stringResFileId="emxFrameworkStringResource";
    String strLanguage = Request.getLanguage(request);
    String header = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.OptionsHeader", stringResFileId, strLanguage);
    String displayURL = "emxTableCalculationOptionsDisplay.jsp?timeStamp=" + XSSUtil.encodeForURL(context, timeStamp);
    String helpDone=UINavigatorUtil.getI18nString("emxFramework.FormComponent.Done", stringResFileId, strLanguage);
    String helpCancel=UINavigatorUtil.getI18nString("emxFramework.FormComponent.Cancel", stringResFileId, strLanguage);
%>

<head>
	<title>Table Calculation Options</title>
	<%@include file = "../emxStyleDefaultInclude.inc"%>
	<%@include file = "../emxStyleDialogInclude.inc"%>

	<script type="text/javascript">
			addStyleSheet("emxUIToolbar");
			addStyleSheet("emxUIMenu");
			addStyleSheet("emxUIDOMLayout");
	</script>

	<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
	<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
	<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
	<script language="javascript" src="scripts/emxNavigatorHelp.js"></script>
	<script language="javascript" src="scripts/emxUIModal.js"></script>
	<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</head>
<body onload="turnOffProgress();">
<div id="pageHeadDiv">
<form name="tableHeaderForm">
   <table>
     <tr>
    <td class="page-title">
      <h2><%=header%></h2>
    </td>
<%
	String processingText = UINavigatorUtil.getProcessingText(context, strLanguage);
%>
        <td class="functions">
        <table>
              <tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
        </tr></table>
        </td>
        </tr>
        </table>
<!-- //XSSOK -->
<jsp:include page = "emxToolbar.jsp" flush="true">  <jsp:param name="toolbar" value=""/>  <jsp:param name="objectId" value=""/>  <jsp:param name="relId" value=""/>  <jsp:param name="parentOID" value=""/>  <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>  <jsp:param name="editLink" value="false"/>  <jsp:param name="header" value="<%=header%>"/>  <jsp:param name="PrinterFriendly" value="false"/>  <jsp:param name="export" value="false"/>  <jsp:param name="helpMarker" value="<%=HelpMarker%>"/>
</jsp:include>
</form>
</div><!-- /#pageHeadDiv -->
        <div id="divPageBody">
          		<!-- //XSSOK -->
          		<iframe name="optionsDisplay" src="<%=displayURL%>" width="100%" height="100%"  frameborder="0" border="0"></iframe>
            	<iframe class="hidden-frame" name="optionsHidden" HEIGHT="0" WIDTH="0"></iframe>
		</div>
<div id="divPageFoot">
<form name="editFooter" method="post">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
    <td class="pagination"></td>
	<td class="buttons">
    <table>
	    <tr>
			<!-- //XSSOK -->
			<td><a class="footericon" href="#" onClick="optionsDisplay.submitOptions()"><img src="images/buttonDialogDone.gif" alt="<%=helpDone%>"></a></td>
			<!-- //XSSOK -->
			<td><a href="#" onClick="optionsDisplay.submitOptions()"><button class="btn-primary" type="button"><%=helpDone%></button></a></td>
			<!-- //XSSOK -->
			<td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img src="images/buttonDialogCancel.gif" alt="<%=helpCancel%>"></a></td>
			<!-- //XSSOK -->
			<td><a onClick="javascript:getTopWindow().closeWindow()"><button class="btn-default" type="button"><%=helpCancel%></button></a></td>
		</tr>
	</table>
	</td>
</tr>
</table>
</form>

</div>
</body>
</html>
