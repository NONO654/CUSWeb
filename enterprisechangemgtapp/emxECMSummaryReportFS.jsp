<%--  emxEngrECOSummaryReportFS.jsp   -  This page displays the ECO Summary Report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file="../emxUIFramesetUtil.inc"%>

<%

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String suiteKey = emxGetParameter(request,"suiteKey");


  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxECMSummaryReport.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId;

  // Page Heading - Internationalized
  String PageHeading = "CO/CA Summary Report";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpecsummaryreport";

%>
<html>
<head>
<script language="javascript" src="../emxUIPageUtility.js"></script>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript">
function openWin()
{
 var iWidth = "700px";
 var iHeight = "600px";

 var strFeatures = "dialogWidth:" + iWidth  + ",dialogHeight:" +  iHeight + ",resizable:yes";
 var bScrollbars = true;
 var winleft = parseInt((screen.width - iWidth) / 2);
 var wintop = parseInt((screen.height - iHeight) / 2);
 if (isIE)
 {
     strFeatures += ",left=" + winleft + ",top=" + wintop;
 }
 else
 {
     strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;
 }

  strFeatures +=  ",toolbar=yes,location=no,modal=yes";
       //are there scrollbars?
      if (bScrollbars) {strFeatures += ",scrollbars=yes"};

var printDialog=null;
//XSSOK
printDialog = window.showListDialog("<%=XSSUtil.encodeForJavaScript(context,contentURL)%>");
}
</script>
</head>
<body onLoad="openWin()">
<form name="reportForm">
</form>
</body>
</html>
