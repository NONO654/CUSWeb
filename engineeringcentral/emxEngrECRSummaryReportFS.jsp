<%--  emxEngrECRSummaryReportFS.jsp   -  This page displays the ECR Summary Report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<%

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String suiteKey = emxGetParameter(request,"suiteKey");


  // ----------------- Do Not Edit Above ------------------------------

  //String generateSummary = emxGetParameter(request,"generateSummary");
  // Specify URL to come in middle of frameset
  String contentURL = "emxEngrECRSummaryReport.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId ;

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.Common.SummaryReportHeader";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpecsummaryreport";

%>
<html>
<head>
<script language="javascript" src="../emxUIPageUtility.js"></script>

<script language="javascript">
function openWin()
{
 var iWidth = "700";
 var iHeight = "600";

 var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=yes";
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

  strFeatures +=  ",toolbar=yes,location=no";
       //are there scrollbars?
      if (bScrollbars) {strFeatures += ",scrollbars=yes"};

//XSSOK
showModalDialog("<%=XSSUtil.encodeForJavaScript(context,contentURL)%>", "700","600","true");
}
</script>
</head>
<body onLoad="openWin()">
<form name="reportForm">
</form>
</body>
</html>
