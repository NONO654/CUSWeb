<%--  emxMetricsSaveDialog.jsp - This JSP will be invoked when the user clicks on "Save"
                                 command in Report Dialog page's Action menu       
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsSaveDialog.jsp.rca 1.20 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UINavigatorUtil" %>

<%
    String strMode     = emxGetParameter(request, "mode");
    String languageStr = request.getHeader("Accept-Language");
    String strOwner = context.getUser();    
%>
<html>
<head>
  <title>
    <%=STR_METRICS_SAVE_REPORT_TITLE%>
  </title>
<%@include file = "../emxJSValidation.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="emxMetrics.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

    <script type="text/javascript" language="JavaScript">
        addStyleSheet("emxUIForm");
        addStyleSheet("emxUIMetricsDialog");

        function doDone(){
            var result = "";
            turnOnProgress("utilProgressBlue.gif");
            var reportName  = document.forms[0].elements[0].value;
            var reportTitle = document.forms[0].elements[1].value;
            var existingReportName = getTopWindow().getWindowOpener().pageControl.getSavedReportName();
            reportName = trimString(reportName);
            reportTitle = trimString(reportTitle);

            
            <%
                if ((strMode!=null) && (strMode.equalsIgnoreCase("ResultsSave"))){
            %>
                    var timeStamp = getTopWindow().getWindowOpener().getTopWindow().pageControl.getTimeStamp();
                    if (reportName.length > 0){
                        if(!checkNameField(document.forms[0].elements[0])){
                           document.forms[0].elements[0].focus();
                           turnOffProgress("utilProgressBlue.gif");
                           return;
                        }
                        if(reportTitle.length >0){
                          if(!checkNameField(document.forms[0].elements[1])){
                           document.forms[0].elements[1].focus();
                           turnOffProgress("utilProgressBlue.gif");
                           return;
                           }
                        }
                        saveReportResults(reportName,reportTitle,"save","SaveResults",timeStamp);
                    }else{
                        alert(STR_METRICS_EMPTY_NAME);
                        turnOffProgress();
                    }
            <%
                } else {
            %>
                getTopWindow().getWindowOpener().pageControl.setResultsTitle(reportTitle);
                getTopWindow().getWindowOpener().pageControl.setOwner("<%=XSSUtil.encodeForJavaScript(context, strOwner) %>");

                if (reportName.length > 0){                    
                    //are there special characters?
                    if(!checkNameField(document.forms[0].elements[0])){
                        document.forms[0].elements[0].focus();
                        turnOffProgress("utilProgressBlue.gif");
                        return;
                    }
                    if(reportTitle.length >0){
                     if(!checkNameField(document.forms[0].elements[1])){
                         document.forms[0].elements[1].focus();
                         turnOffProgress("utilProgressBlue.gif");
                         return;
                     }
                    }
                    result = getTopWindow().getWindowOpener().getTopWindow().saveReport(reportName,reportTitle,"save","criteriaUpdate","");
                }else{
                    alert(STR_METRICS_EMPTY_NAME);
                    turnOffProgress();
                }               
                reportSaveHidden.document.write(result);
            <% 
                }
            %>
        }
        

        function turnOffProgress(){
            document.images['imgProgress'].src = "../common/images/utilSpacer.gif";
        }

    </script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUISearchUtils.js"></script>
</head>
<body onLoad="turnOffProgress(), focusFormElm()" class="save">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
    <td><img src="../common/images/utilSpacer.gif" width="1" height="1" alt="" /></td>
  </tr>
</table>
<div id="divPageHead">
    <table><tr><td>
   <span class="pageHeader">
  &nbsp;<%=STR_METRICS_SAVE_REPORT%>&nbsp;&nbsp;&nbsp;&nbsp;</span><img src="../common/images/utilProgressBlue.gif" width="34" height="28" name="imgProgress" />
  </td></tr>
  <tr><td>&nbsp;&nbsp;</td></tr></table>
</div>
<div id="divPageBody" style="top:54px;">
  <form method="post" onsubmit="doDone(); return false">
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <tr>
        <td><img src="../common/images/utilSpacer.gif" width="100" height="1" alt="" /></td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td  class="labelRequired"><%=STR_METRICS_LABEL_NAME%></td>
        <td class="inputField"><input type="text" size="35" name="txtName" id="txtName" value="" />
        &nbsp;</td>
      </tr>
      <tr>
        <td  class="label"><%=STR_METRICS_LABEL_TITLE%></td>
        <td class="inputField"><input type="text" size="35" name="txtTitle" id="txtTitle" value="" />
        &nbsp;</td>
      </tr>

    </table>
 </form>
</div>
<div id="divPageFoot">
  <div id="divDialogButtons">
    <table border="0" cellspacing="0" align="right">
      <tr>
        <td width="80%">&nbsp;&nbsp;</td>
        <td><a onclick="javascript:doDone()" class="button"><button class="btn-primary" type="button"><%=STR_METRICS_DONE%></button></a></td>
        <td></td>
        <td><a onclick="javascript:getTopWindow().closeWindow()" class="button"><button class="btn-default" type="button"><%=STR_METRICS_CANCEL%></button></a></td>
        <td>&nbsp;&nbsp;&nbsp;</td>
      </tr>
    </table>
  </div>
</div>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="JavaScript">
    var DisplayErrorMsg = "";
</script>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
<iframe src="../common/emxBlank.jsp" width="0" height="0" scrolling="no" frameborder="0" name="reportSaveHidden" id="reportSaveHidden"></iframe>
</html>
