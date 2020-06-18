<%-- emxFreezePaneAutoFilterHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneAutoFilterHeader.jsp.rca 1.5.3.2 Wed Oct 22 15:48:45 2008 przemek Experimental przemek $
--%>

<html>
<%@include file = "emxNavigatorInclude.inc"%>


<head>
<title>
</title>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>
        <script type="text/javascript">
            addStyleSheet("emxUIToolbar");
        </script>

<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIModal.js"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js"></script>
<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
<script language="javascript" src="scripts/emxNavigatorHelp.js"></script>

</head>

<%
String sHelpMarker = "emxhelpfiltercolumns";
//modified for bug :345114
String strHelp = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.Tooltip.Help", request.getLocale());
String commonDir = EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.CommonDirectory");
String helpHTML = "<a href=\"javascript:openHelp('" + sHelpMarker + "', '" + commonDir + "', '" + langStr + "')\"><img src=\"images/buttonContextHelp.gif\" title=\""+strHelp+"\" alt=\""+strHelp+"\" border=\"0\" /></a>";
%>
<body>
<form method="post">
<div id="pageHeadDiv">
   <table>
<tr>
    <td class="page-title">
      <h2><emxUtil:i18nScript localize="i18nId">emxFramework.TableComponent.AutoFilterHeader</emxUtil:i18nScript></h2>
    </td>
<%
       String processingText = UINavigatorUtil.getProcessingText(context, langStr);
%>
        <td class="functions">
            <table>
<tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
</tr>
</table>
        </td>
</tr>
</table>
<!-- //XSSOK -->
<jsp:include page = "emxToolbar.jsp" flush="true"> <jsp:param name="helpMarker" value="<%=sHelpMarker%>"/> <jsp:param name="PrinterFriendly" value="false"/> <jsp:param name="export" value="false"/>
</jsp:include>
</div><!-- /#pageHeadDiv -->
</form>

<script language="javascript">
  var cc = new jsActionBar;
  cc.top = 44;
  cc.left = 40;
  cc.visibleLinks = 4;

  cc.addLink("<emxUtil:i18nScript localize="i18nId">emxFramework.IconMail.Button.Reset</emxUtil:i18nScript>", "javascript:resetFilters()", null);
  cc.draw();
</script>


</body>
</html>
