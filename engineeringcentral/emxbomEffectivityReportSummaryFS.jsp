<%--emxbomEffectivityReportSummaryFS.jsp   
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


  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below
  String objectId = emxGetParameter(request,"objectId");
  String effectivityDate = emxGetParameter(request,"effectivityDate");
  String effectivityTime = emxGetParameter(request,"effectivityTime");

  // Specify URL to come in middle of frameset
  String contentURL = "emxbomEffectivityReportSummary.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId + "&effectivityDate="+effectivityDate+"&effectivityTime=" + effectivityTime;

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.EBOM.EffectivityDateSummaryPageHeading";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpparteffectivityreport";
  String dest="";
    int len=contentURL.length();
    int index=0;
    String code=null;
    for(int i=0;i<len; i++){
    char ch=contentURL.charAt(i);
    if(ch==' '){
      code="%20";
      }
    if(code!=null){
    dest+=contentURL.substring(index,i)+code;
    index=i+1;
    code=null;
      }
     }
    if(index<len){
    dest+=contentURL.substring(index,len);
    
     }
  contentURL=dest;

  fs.setObjectId(objectId);
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,false,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");
  fs.setSuiteKey("EngineeringCentral");
  fs.removeDialogWarning();

  if (acc.has(Access.cRead)) {
 String roleList ="role_GlobalUser";

  fs.createCommonLink("emxEngineeringCentral.Common.Close",
                      "parent.closeWindow()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);


  }
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
