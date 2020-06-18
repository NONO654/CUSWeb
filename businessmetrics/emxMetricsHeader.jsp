<%--  emxMetricsHeader.jsp

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsHeader.jsp.rca 1.11 Tue Oct 28 18:59:28 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%

    String toolbar = emxGetParameter(request, "toolbar");
    String objectId = null;
    String relId = null;
    String strHelpMarker = emxGetParameter(request, "HelpMarker");

    if (toolbar == null || toolbar.trim().length() == 0)
    {
        toolbar = PropertyUtil.getSchemaProperty(context,"menu_MetricsCommonReportsToolbar");
    }
    String languageStr = request.getHeader("Accept-Language");
%>

<html>
    <head>
        <script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIPopups.js"></script>
        <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
        <script language="JavaScript" src="emxMetrics.js"></script>
        <script type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
            addStyleSheet("emxUIForm");
            addStyleSheet("emxUISearch");
        </script>
    </head>
<body>
<form method="post">
    <table border="0" cellspacing="0" cellpadding="0" width="100%">
       <tr>
          <td width="99%">
            <table border="0" width="100%" cellspacing="0" cellpadding="0">
              <tr>
                <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
              </tr>
            </table>
            <table border="0" cellspacing="0" cellpadding="0" width="100%">
              <tr>
                <td width="1%" nowrap><span class="pageHeader" id="pageHeader"></span></td>
                  <%
                      String progressImage = "../common/images/utilProgressBlue.gif";
                      String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
                   %>
                   <!-- //XSSOK -->
                <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>
                <td><img src="../common/images/utilSpacer.gif" alt="" width="4" height="33" />
                </td>
              </tr>
            </table>
			<!-- //XSSOK -->
            <jsp:include page = "../common/emxToolbar.jsp" flush="true"><jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/><jsp:param name="objectId" value="<%=objectId%>"/><jsp:param name="relId" value="<%=relId%>"/><jsp:param name="export" value="false"/><jsp:param name="PrinterFriendly" value="false"/><jsp:param name="portalMode" value="false"/><jsp:param name="HelpMarker" value="<%=XSSUtil.encodeForURL(context, strHelpMarker)%>"/></jsp:include>
          </td>
            <td><img src="../common/images/utilSpacer.gif" alt="" width="4" />
            </td>
       </tr>
    </table>
</form>
<script language="JavaScript">
     //set window Title
     getTopWindow().pageControl.setWindowTitle();

     //set window Title
     getTopWindow().pageControl.setPageHeaderText();
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
