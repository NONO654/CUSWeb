<%--  emxProjectCentralFinancialDetailsFS.jsp

  A FrameSet Page for displaying the  properties of a finacial Item and Header links.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/15/2002

  static const char RCSID[] = $Id: emxProgramCentralFinancialItemDetailsFS.jsp.rca 1.14 Wed Oct 22 15:49:35 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
    String jsTreeID   = emxGetParameter(request,"jsTreeID");
    String suiteKey   = emxGetParameter(request,"suiteKey");
    String initSource = emxGetParameter(request,"initSource");
    String objectId   = emxGetParameter(request,"objectId");
    String Directory  = appDirectory;

    framesetObject fs = new framesetObject();
    fs.useCache(false);
    fs.setDirectory(Directory);
    fs.setObjectId(objectId);
    fs.setStringResourceFile("emxProgramCentralStringResource");

    if (initSource == null)
    {
        initSource = "";
    }

    // ----------------- Do Not Edit Above ------------------------------

    // Specify URL to come in middle of frameset
    String contentURL = "emxProgramCentralFinancialItemDetails.jsp";
    // add these parameters to each content URL, and any others the App needs
    contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
    contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

    // Page Heading & Help Page
    String PageHeading = "emxProgramCentral.Common.Basics";
    String HelpMarker = "emxhelpfinancialitemdetails";

    fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);

    // determine if user can edit
    DomainObject domainObject = DomainObject.newInstance(context, objectId);
    boolean editFlag = domainObject.checkAccess(context, (short) AccessConstants.cModify);

    if (editFlag)
    {
      String edit = "emxProgramCentral.Button.Edit";
      String editActionURL = "emxProgramCentralFinancialItemEditDetailsDialogFS.jsp?objectId=" + objectId;
    fs.createHeaderLink(edit, editActionURL, "role_GlobalUser", true, false, "default", 3);
    }

    // ----------------- Do Not Edit Below ------------------------------

    fs.writePage(out);
%>
