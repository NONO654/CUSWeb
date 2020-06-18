<%--  emxengchgMetricsReportDialogFS.jsp   -   FS page for Metrics Report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

%>

<%
  // Specify URL to come in middle of frameset
  String contentURL = "emxengchgMetricsReportProcess.jsp";

  boolean first = true;
  String param;

  // Loop through parameters and pass on to summary page
  for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
  {
      String name = (String) names.nextElement();
      String value = emxGetParameter(request, name);

      if (first) {
        param = "?" + name + "=" + value;
        first = false;
      }
      else {
        param = "&" + name + "=" + value;
      }

      contentURL += param;
  }

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.DesignTOP.MetricsReport";

  // Marker to pass into Help Pages, icon launches new window with help frameset inside
  String HelpMarker = "emxhelpmetricsreport";

  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL,
                  true,
                  true,
                  false,
                  false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  // Role based access
  /*String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator";*/
   String roleList ="role_GlobalUser";

   fs.createFooterLink("emxFramework.Command.Previous",
           "window.parent.location.href='emxengchgMetricsReportDialogFS.jsp'",
           roleList,
           false,
           true,
           "common/images/buttonDialogPrevious.gif",
           0);
  
  fs.createFooterLink("emxFramework.Command.Done",
                      "parent.closeWindow()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  

  fs.writePage(out);

%>





