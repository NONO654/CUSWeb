<%-- emxTimelineFilterFS.jsp

        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.
        This program contains proprietary and trade secret information of MatrixOne,
        Inc.
        Copyright notice is precautionary only and does not evidence any actual or
        intended publication of such program.

        static const char RCSID[] = $Id: emxTimelineFilterFS.jsp.rca 1.6 Wed Oct 22 15:48:56 2008 przemek Experimental przemek $
 --%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%
  framesetObject fs = new framesetObject();

  String attributeFilter = emxGetParameter(request, UITimeline.SETTING_ATTRIBUTE_FILTER_LIST);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String suiteKey     = emxGetParameter(request,"suiteKey");

  fs.setDirectory(UINavigatorUtil.getRegisteredDirectory(context,suiteKey));

  String timeStamp = emxGetParameter(request, "timestamp");

  // Specify URL to come in middle of frameset
  String contentURL = "emxTimelineFilterDisplay.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&timestamp="+timeStamp + "&attributeFilterList=" + attributeFilter;


  fs.setStringResourceFile("emxFrameworkStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Roadmap.Filter.Header";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelptimelinefilter";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.createFooterLink("emxFramework.Preferences.Apply",
                        "applyFilter()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogApply.gif",
                        3);

  fs.createFooterLink("emxFramework.Common.Done",
                      "doneFilter()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      3);

  fs.createFooterLink("emxFramework.Button.Cancel",
                      "doCancel()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
