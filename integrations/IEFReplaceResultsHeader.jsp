<%--  IEFReplaceResultsHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import= "com.matrixone.MCADIntegration.server.beans.*,com.matrixone.MCADIntegration.utils.*,				 com.matrixone.MCADIntegration.server.*,matrix.db.* " %>
<!-- IR-469644 : charset encoding added -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />
<title>
</title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

    <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
</head>
<%
MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context = integSessionData.getClonedContext(session);
MCADServerResourceBundle serverResourceBundle = integSessionData.getResourceBundle();
String replaceResultsTitle  = serverResourceBundle.getString("mcadIntegration.Server.Title.ReplaceResultsTitle");
%>
<body topmargin="10" marginheight="10" >
<form name="mx_filterselect_hidden_form">
<input type="hidden" name="pheader" value="Replace"/>
        <table border="0" cellspacing="2" cellpadding="0" width="100%">
          <tr>
            <td width="99%">
              <table border="0" cellspacing="0" cellpadding="0" width="100%">
                <tr>
                  <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" alt=""></td>
                </tr>
              </table>
              <table border="0" width="100%" cellspacing="0" cellpadding="0">
                <tr>
				  <!--XSSOK-->
                  <td width="1%" nowrap><span class="pageHeader">&nbsp;<%=replaceResultsTitle%></span>
                  </td>
                  <td width="1%"><img src="../common/images/utilSpacer.gif" width="1" height="28" border="0" alt="" vspace="6"></td>
                  <td align="right" class="filter">
                    &nbsp
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
            <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1"></td>
          </tr>
        </table>
        <table border="0" cellpadding="0" cellspacing="0"  align="right" width="1%">
                <tr><td><img src="../common/images/utilSpacer.gif" width="1" height="10" ></td></tr>
                <tr><td></td>
     </tr>
  </table>

</form>
</body>
</html>


