<%--  emxComponentsLocationSearchDialogFS.jsp   - Display Frameset for Select Members
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsLocationSearchDialogFS.jsp.rca 1.4.6.6 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
    String Directory = appDirectory;

    //searchFramesetObject fs = new searchFramesetObject();
    framesetObject fs = new framesetObject();
    String initSource = emxGetParameter(request,"initSource");

    if (initSource == null)
    {
        initSource = "";
    }

    String jsTreeID   = emxGetParameter(request,"jsTreeID");
    String suiteKey   = emxGetParameter(request,"suiteKey");
    String projectId   = emxGetParameter(request,"objectId");

    String fieldName   = emxGetParameter(request,"fieldName");
    String fieldOId   = emxGetParameter(request,"fieldOId");
    String sformName   = emxGetParameter(request,"formName");

    String sSelection   = emxGetParameter(request,"selection");
    String sSubmitURL   = emxGetParameter(request,"SubmitURL");
    // MCC Bug fix 328078, need to show only Active Locations
    String sDefaultStates   = emxGetParameter(request,"defaultStates");
    String companyId   = emxGetParameter(request,"companyId");
    
    // Specify URL to come in middle of frameset
    String contentURL = "emxComponentsLocationSearchDialog.jsp";

    // add these parameters to each content URL, and any others the App needs
    contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&objectId="+projectId+ "&fieldOId="+fieldOId+"&fieldName="+fieldName+"&selection="+sSelection+"&SubmitURL="+sSubmitURL+"&formName="+sformName + "&defaultStates=" + sDefaultStates+ "&companyId=" + companyId;

    String PageHeading = "emxComponents.SelectLocation.SelectLocation";
	//Modified for #352072
    String HelpMarker = "emxhelpsearch";

    fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

    fs.setStringResourceFile("emxComponentsStringResource");
    fs.setDirectory(Directory);

    String rolesList = "role_GlobalUser";

    fs.createCommonLink("emxComponents.Button.Search",
                      "doSearch()",
                      rolesList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

    fs.createCommonLink("emxComponents.Button.Cancel",
                      "window.closeWindow()",
                      rolesList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

    fs.writePage(out);
%>
