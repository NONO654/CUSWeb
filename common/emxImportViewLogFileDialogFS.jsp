<!--  emxImportviewLogFileDialogFS.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxImportViewLogFileDialogFS.jsp.rca 1.1.1.1.1.4 Wed Oct 22 15:48:34 2008 przemek Experimental przemek $
-->

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%
    // construct frameset object
    framesetObject fs = new framesetObject();
    // Getting the objectid
    String objectId     = emxGetParameter(request,"objectId");
    String jobId     = emxGetParameter(request,"oid");
    String suiteKey   = emxGetParameter(request,"suiteKey");
    // Specify the content URL
    StringBuffer contentURL =  new StringBuffer("emxImportViewLogFileDialog.jsp");
    contentURL.append("?suiteKey=");
    contentURL.append(suiteKey);
    contentURL.append("&objectId=");
    contentURL.append(objectId);
    contentURL.append("&oid=");
    contentURL.append(jobId);

    String pageHeading = "emxFramework.BackgroundProcess.Header.LogFileView/Download";
    String helpMarker = "emxhelpjoblogfile" ;
    fs.setDirectory(appDirectory);
    fs.setSubmitMethod(request.getMethod());
    fs.initFrameset(pageHeading,helpMarker, contentURL.toString(),false,true,false,false);

    fs.setStringResourceFile("emxFrameworkStringResource");
    fs.createCommonLink("emxFramework.FormComponent.Done",
                        "submit()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        false,
                        0);
    fs.createFooterLink("emxFramework.FormComponent.Cancel",
                                    "parent.window.closeWindow()",
                                    "role_GlobalUser",
                                    false,
                                    true,
                                    "common/images/buttonDialogCancel.gif",
                                    0);
	 fs.writePage(out);

%>
