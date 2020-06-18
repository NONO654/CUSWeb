<%-- emxMetricsResultsFooter.jsp  - The footer section of the Results page

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsResultsFooter.jsp.rca 1.8 Wed Oct 22 16:11:55 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ include file="emxMetricsConstantsInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%
    String pagination = "";
    String paginationRange = "";
    String wrapColSize = "";
    String upperWrapColSize = "";

    try{
        wrapColSize = "100";//FrameworkProperties.getProperty(context, "emxMetrics.label.WrapSize");
        if( (wrapColSize == null) || (wrapColSize.equals("null")) || (wrapColSize.equals(""))) {
            wrapColSize="100";
        }

    }catch (Exception ex){
        if(ex.toString() != null && (ex.toString().trim()).length()>0){
                emxNavErrorObject.addMessage("emxMetricsResultsFooter.jsp:" + ex.toString().trim());
        }
    }
%>
<html>
    <head>
        <title>Search Footer</title>
        <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
        <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
        <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIPopups.js"></script>
        <script type="text/javascript" language="JavaScript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIList");
            addStyleSheet("emxUISearch");

            function doDone() {
                turnOnProgress("utilProgressBlue.gif");
                setTimeout("getTopWindow().closeWindow()", 500);
            }


            function trimWhitespace(strString) {
                strString = strString.replace(/^[\s\u3000]*/g, "");
                return strString.replace(/[\s\u3000]+$/g, "");
            }
        </script>
        <script language="JavaScript" src="emxMetricsUtils.js" type="text/javascript"></script>
    </head>
    <body onload="setFormfields();">
    <form name="frmFooter" method="post">
      <table width="100%" border="0" align="center" cellspacing="0" cellpadding="0">
        <tr>
          <td>
            <table border="0">
              <tr>
                <td></td>
                <td></td>
                <td></td>
                <td>&nbsp;&nbsp;</td>
              </tr>
            </table>
          </td>
          <td align="right">
            <table border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td>&nbsp;&nbsp;</td>
                <td></td>
                <td nowrap></td>
                <td>&nbsp;&nbsp;</td>
                <td><a href="javascript:getTopWindow().closeWindow()"><img border="0" alt="Cancel" src="../common/images/buttonSearchCancel.gif" /></a></td>
                <td nowrap>&nbsp;<a class="button" onClick="javascript:getTopWindow().closeWindow()"><%=STR_METRICS_CLOSE%></a></td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      <input type="image" height="1" width="1" border="0" name="inputImage" value=""/>
    </form>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>
