<%--  ECMCollaborateFS.jsp   -   FS page for opening synchronization report in a slidein page
   
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
	initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String targetLocation = emxGetParameter(request,"targetLocation");
  String[] strArrObjectId = emxGetParameterValues(request,"objectId");
  String strObjectId = strArrObjectId[0];
  String titleKey = emxGetParameter(request,"titleKey");

  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below

  // Specify URL to come in middle of frameset
String contentURL="ECMCollaborate.jsp?objectId="+strObjectId+"&targetLocation="+targetLocation+"&suiteKey="+suiteKey;

  // Page Heading - Internationalized
String PageHeading = titleKey;
 
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "";

  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxEnterpriseChangeMgtStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";

                      
  fs.createFooterLink("EnterpriseChangeMgt.Command.Done",
                      "top.closeSlideInDialog()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
