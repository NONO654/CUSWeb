<%--  emxCommonDocumentCreateDialogFS.jsp   -   Create Frameset for Route Wizard
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentConversionDialogFS.jsp.rca 1.3.1.1.2.5 Wed Oct 22 16:18:39 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>

<%
  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");

  if(emxCommonDocumentCheckinData == null)
  {
    emxCommonDocumentCheckinData = new HashMap();
  }

    String objectAction =  (String)emxCommonDocumentCheckinData.get("objectAction");

    framesetObject fs    = new framesetObject();
    // Specify URL to come in middle of frameset
    StringBuffer contentURL = new StringBuffer();
    contentURL.append("emxCommonDocumentConversionDialog.jsp?");

    fs.setStringResourceFile("emxComponentsStringResource");

  String fromAction = emxGetParameter(request,"fromAction");
    emxCommonDocumentCheckinData.put("fromAction",fromAction);



  String heading = (String) emxCommonDocumentCheckinData.get("stepOneHeader");
  // Page Heading - Internationalized
  String PageHeading = "emxComponents.DocumentCreateDialog.SpecifyDetails";
  if ( heading != null && !"".equals(heading) && !"null".equals(heading) )
  {
      PageHeading = heading;
  }
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpdsfaconvert" ;

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);
  if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
     objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC))
  {
      fs.createFooterLink("emxComponents.Button.Done",
                          "submitForm()",
                          "role_GlobalUser",
                          false,
                          true,
                          "common/images/buttonWizardDone.gif",
                          3);
  }
  else if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER))
  {
      fs.createFooterLink("emxComponents.Button.Next",
                          "submitForm()",
                          "role_GlobalUser",
                          false,
                          true,
                          "common/images/buttonDialogNext.gif",
                          3);
  }
  fs.createFooterLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);
  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);

%>
