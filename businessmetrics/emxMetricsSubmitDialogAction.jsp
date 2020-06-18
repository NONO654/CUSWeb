<%@ page buffer="100kb" autoFlush="false" %>
<%-- emxMetricsSubmitDialogAction.jsp - This JSP will be invoked wthen the user
                                        clicks on the "Done" link in report dialog page
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsSubmitDialogAction.jsp.rca 1.11 Wed Oct 22 16:11:58 2008 przemek Experimental $
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<html>
<%
  String strURL = emxGetParameter(request,"url");
%>
<head><title>MatrixOne</title>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="javascript" src="emxMetrics.js"></script>

<script language="javascript">
var strURL="<%=XSSUtil.encodeURLwithParsing(context, strURL)%>";
function submitSpecialForm(){
    var objContentWindow = findFrame(getTopWindow(), "metricsReportContent");
    var targetname;
    var fromPortalMode = false;
    if(!objContentWindow){
        objContentWindow = findFrame(getWindowOpener(), "metricsReportContent");        
        this.name = "ReportResultsNonModalWindow" + (new Date()).getTime();
        targetname = this.name;
    } else {
        parent.getWindowOpener().name = parent.getWindowOpener().strSavedReportName;
        targetname = parent.getWindowOpener().strSavedReportName;
    }
    // For closing the MODAL View Defn window from portal mode
    if(strURL.indexOf("portalMode")!=-1)
    {
       var tempURL = strURL.substring(strURL.indexOf("portalMode=") + 11,strURL.length);
       tempURL = tempURL.substring(0,tempURL.indexOf("&"));   
       if(tempURL=="true")
       {
           fromPortalMode = true;
       }
    }
    
    WINDOW_REF = objContentWindow.getTopWindow();
    var WINDOW_REF_OPENER = WINDOW_REF.getWindowOpener().getTopWindow();
    setPageControlValuesFromDialog(WINDOW_REF,WINDOW_REF_OPENER,fromPortalMode);
    var objForm = objContentWindow.document.forms[0];
    objForm.target = targetname;
    strURL = strURL.replace("showRefresh=true", "showRefresh=false");
    strURL = strURL + "&isSharedAndNotOwned=" + pageControl.isSharedAndNotOwned();
    objForm.action = strURL;
    objForm.method = "post";
    objForm.submit();
}
</script>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</head>
<body topmargin="0" marginheight="0" leftmargin="0" marginwidth="0" onload="submitSpecialForm()">
</body>
</html>
