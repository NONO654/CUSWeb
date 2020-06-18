<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
    This is an exact copy of emxTeamCreateFoldersWorkspaceDialogFS.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    The include file paths have been changed to point to team central.
    The emx prefix has been changed to sma where appropriate
    We are passing emxTableRowId
--%>

<%@ include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
  fs.useCache(false);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId   = emxGetParameter(request,"objectId");
  String objectName   = emxGetParameter(request,"txtName");
  String parentRowId = emxGetParameter(request, "emxTableRowId");

  // Specify URL to come in middle of frameset
  String contentURL = "smaTeamCreateFoldersWorkspaceDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+"&objectId="+objectId+"&txtName="+objectName;
  contentURL += "&emxTableRowId=" + parentRowId;

  String PageHeading = "emxTeamCentral.common.CreateNewFolder";
  String HelpMarker = "emxhelpcreatenewfolder";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitform()",
                      "role_Buyer,role_Supplier,role_ExchangeUser",
                      false,
                      true,
                      "emxUIButtonDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_Buyer,role_Supplier,role_ExchangeUser",
                      false,
                      true,
                      "emxUIButtonCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>
