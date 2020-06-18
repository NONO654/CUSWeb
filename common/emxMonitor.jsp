<%--  emxMonitor.jsp   -  This page is used to monitor the ematrix server.

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxMonitor.jsp.rca 1.8 Wed Oct 22 15:47:51 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
<%@include file = "emxUIConstantsInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>

<script language="JavaScript">
   var printDialog = null;
   // Call printer friendly page
   function openPrinterFriendlyPage(){
    strURL = "";
    var strFilterit="";
    var filteringValue="";
    currentURL =document.location.href;
    
   
    if (currentURL.indexOf("?") == -1){
      strURL = currentURL + "?PrinterFriendly=true";
    }else{
      strURL = currentURL + "&PrinterFriendly=true";
    }
    iWidth = "700";
    iHeight = "600";
    bScrollbars = true;
      //make sure that there isn't a window already open 
    if (!printDialog || printDialog.closed) { 

      //build up features string 
      var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=yes";

      //calculate center of the screen 
      var winleft = parseInt((screen.width - iWidth) / 2);
      var wintop = parseInt((screen.height - iHeight) / 2);

      if (isIE)
        strFeatures += ",left=" + winleft + ",top=" + wintop;
      else
        strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;

      strFeatures +=  ",toolbar=yes";         

      //are there scrollbars? 
      if (bScrollbars) strFeatures += ",scrollbars=yes";

      //open the window 
      printDialog = window.open(strURL, "printDialog" + (new Date()).getTime(), strFeatures);

      //set focus to the dialog 
      printDialog.focus();

    } else {
      if (printDialog) printDialog.focus();
    }
  }
<%
String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

   boolean isPrinterFriendly = false;
   String printerFriendly = emxGetParameter(request, "PrinterFriendly");

if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
 isPrinterFriendly = "true".equals(printerFriendly);
%>
	addStyleSheet("emxUIDefaultPF");
	addStyleSheet("emxUIPropertiesPF");
	addStyleSheet("emxUIPF");
<%
} else {
%>
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIToolbar");
	addStyleSheet("emxUIDOMLayout");
	addStyleSheet("emxUIMenu");
	addStyleSheet("emxUIForm");
	addStyleSheet("emxUIProperties");
<%
}
%>
</script>
<%
   try {

   String mqlString = "monitor context terse";
   // THe monitor command can only be run by a system admin,
   // so run as systemadmin
   String result = MqlUtil.mqlCommand(context,mqlString,true);

   Vector names = new Vector();
   Vector values = new Vector();

   StringTokenizer lines = new StringTokenizer(result, "\n");
   while (lines.hasMoreTokens()) {
     String line = lines.nextToken();
     int pos = line.indexOf(": ");
     if (pos >= 0) {
       names.add(line.substring(0, pos));
       values.add(line.substring(pos+2));
     }
   }

      String sHelpMarker ="emxhelpadminmonitor";
      String suiteDir="common";
%>
<body onload="turnOffProgress();" class="no-footer">
<%
if (!isPrinterFriendly) {
%>
<div id="pageHeadDiv" >
<%
}
String progressImage = "images/utilProgressBlue.gif";
String languageStr = request.getHeader("Accept-Language");
String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
%>
      <table>
       <tr>
      <td class="page-title">
        <h2><emxUtil:i18n localize="i18nId">emxFramework.AdminTool.MonitorPage</emxUtil:i18n></h2>
      </td>
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
<%
if (!isPrinterFriendly) {
%>
<!-- //XSSOK -->
<jsp:include page = "emxToolbar.jsp" flush="true"> <jsp:param name="export" value="false"/> <jsp:param name="helpMarker" value="<%=sHelpMarker%>"/>    
</jsp:include>
</div>
<div id="divPageBody">
<%
}
%>



<table class="form monitor" width="100%">
<%


   for (int i=0; i<names.size(); i++) {
     String namefromdb = (String)names.elementAt(i);
     String name = UINavigatorUtil.getAdminI18NString("AdminTool",namefromdb, request.getHeader("Accept-Language"));
     String value = (String)values.elementAt(i);
%>
<tr>
<td class="label"><xss:encodeForHTML><%=name%></xss:encodeForHTML></td>
<td nowrap="nowrap" class="field"><xss:encodeForHTML><%=value%></xss:encodeForHTML></td>
</tr>

<%
  }
%>
</table>
<%
       if (!isPrinterFriendly) {
%>
</div>
<%
   }
  } catch (Exception e) {
   throw e;
  }
%>
</body>
</html>
