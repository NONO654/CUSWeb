<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%--  emxDocumentCentralSubscribeOptionsFS.jsp

    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of  MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description: Frameset Page for Subscription

    Author     : Neaz Faiyaz
    Date       : 04/02/2003
    History    :

    static const char RCSID[] = "$Id: emxDocumentCentralSubscribeOptionsFS.jsp.rca 1.17 Wed Oct 22 16:02:10 2008 przemek Experimental przemek $";
--%>

<%@include file="../emxUIFramesetUtil.inc" %>
<%@include file = "emxLibraryCentralUtils.inc" %>

<%

    String objectId         = emxGetParameter(request,"objectId");
    String targetLocation   = emxGetParameter(request,"targetLocation");

    //--this is case when add subsription is called not from tree
    //but emxtable to handle multiple object subscription
    String emxTableRowIds[] = (String[]) emxGetParameterValues(request, "emxTableRowId");
    String objectIdString   = getTableRowIDsString(emxTableRowIds);

    if(emxTableRowIds == null)
    {
    	objectIdString = objectId;
    } else {
    	objectId   = (String)(getTableRowIDs(emxTableRowIds).get(0));
    }


    framesetObject fs = new framesetObject();
    fs.useCache(false);
    fs.setDirectory(appDirectory);
    fs.setObjectId(objectId);

    String pageHeading = "emxDocumentCentral.Subscribe.Options";;

    // Specify URL to come in middle of frameset

    StringBuffer contentURL = new StringBuffer();

    contentURL.append("emxDocumentCentralSubscribeOptionsDialog.jsp");
    contentURL.append("?objectIdString=" + objectIdString);
    contentURL.append("&targetLocation=" + targetLocation);

    String HelpMarker = "emxhelpsubscribeobject";
   
    fs.initFrameset(pageHeading,HelpMarker,contentURL.toString(),
        false,true,false,false);

    fs.setStringResourceFile("emxDocumentCentralStringResource");
    fs.removeDialogWarning();

    fs.createCommonLink("emxDocumentCentral.Button.Done",
                        "submitForm()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        false,
                        5);

    fs.createCommonLink("emxDocumentCentral.Button.Cancel",
                        "closeWindow()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogCancel.gif",
                        false,
                        5);

    fs.writePage(out);

%>
