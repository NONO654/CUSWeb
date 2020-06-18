<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
    This is an exact copy of emxTeamCreateWorkspaceDialogFS.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    The include file paths have been changed to point to team central.
    The emx prefix has been changed to sma where appropriate
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
  String jsTreeID       = emxGetParameter(request,"jsTreeID");
  String suiteKey       = emxGetParameter(request,"suiteKey");
  String sourcePageName = emxGetParameter(request,"sourcePageName");
  String workspaceName  = emxGetParameter(request,"workspaceName");
  String workspaceDesc  = emxGetParameter(request,"workspaceDesc");
  String templateId     = emxGetParameter(request,"templateId");
  String template       = emxGetParameter(request,"template");
  String sBuyerDesk     = emxGetParameter(request,"txtBuyerDesk");
  String sBuyerDeskId   = emxGetParameter(request,"txtBuyerDeskId");

  // Specify URL to come in middle of frameset
  String contentURL = "../simulationcentral/smaTeamCreateWorkspaceDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&workspaceName=" + workspaceName + "&workspaceDesc=" + workspaceDesc+ "&sourcePageName=" + sourcePageName+"&templateId=" + templateId+"&template=" + template;
  contentURL +="&txtBuyerDesk=" + sBuyerDesk+"&txtBuyerDeskId=" + sBuyerDeskId;

  String PageHeading = "emxTeamCentral.Workspace.CreateNewWorkspace";

  String HelpMarker  = "emxhelpcreatenewworkspace";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitform()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "emxUIButtonDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "emxUIButtonCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>

