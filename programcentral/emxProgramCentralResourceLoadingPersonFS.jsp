<%-- emxProgramCentralResourceLoadingPersonFS.jsp

  Displays a window for creating a Calendar event.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralResourceLoadingPersonFS.jsp.rca 1.11 Wed Oct 22 15:49:43 2008 przemek Experimental przemek $";

--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<jsp:useBean id="emxProgramCentralRiskSummaryFS" scope="session" class="com.matrixone.apps.framework.ui.UITable"/>

<%

  DomainObject domainObject = null;
  String jsTreeID =      emxGetParameter(request,"jsTreeID");
  String suiteKey =      emxGetParameter(request,"suiteKey");
  String initSource =    emxGetParameter(request,"initSource");
  String objectId =      emxGetParameter(request,"objectId");
  String selected =      emxGetParameter(request,"selected");
  String start =      emxGetParameter(request,"start");
  String end =      emxGetParameter(request,"end");
  String sStartDtHidden = emxGetParameter(request,"start_msvalue");
  String sEndDtHidden = emxGetParameter(request,"end_msvalue");
  String range_data="";
  String sDate =        emxGetParameter(request,"sDate");
  String eDate =        emxGetParameter(request,"eDate");

  if(start!=null && end != null && start.trim().length() > 0 && end.trim().length() > 0 )
  {
     range_data = start + "|"+ end;
  }


  String[] emxTableRowId =      emxGetParameterValues(request,"emxTableRowId");
  String objectName =    emxGetParameter(request,"objectName");
  String filterValue =   emxGetParameter(request,"mx.page.filter");

  if(selected==null && filterValue!=null)
    selected=filterValue;

  String Directory =     appDirectory;
  String hiddenParams = "";
  String itemId="";
  if(emxTableRowId != null)
  {
    for(int k=0;k<emxTableRowId.length;k++){
      itemId = emxTableRowId[k];
      if(k==emxTableRowId.length-1){
        hiddenParams += itemId;
      }
      else{
        hiddenParams += itemId + ",";
     }
  }
  }


  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");
  fs.enableSpreadSheetPage();



  if (initSource == null){
    initSource = "";
  }


  String m = "emxProgramCentral.Common.ResourceLoading.Monthly";
  String w = "emxProgramCentral.Common.ResourceLoading.Weekly";
  String q = "emxProgramCentral.Common.ResourceLoading.Quarterly";

  String contentURL = "emxProgramCentralResourceLoadingPersonSummary.jsp?suiteKey=" + suiteKey +
                      "&initSource=" + initSource + "&jsTreeID=" + jsTreeID +
                      "&objectId=" + objectId +"&emxTableRowId=" + hiddenParams+"&date_range=" + range_data+"&start_msvalue="+sStartDtHidden+"&end_msvalue="+sEndDtHidden+"&start="+start+"&end="+end+"&sDate="+sDate+"&eDate="+eDate;


  if(selected != null && !"".equals(selected))
  {
    if(selected.equals("Weekly"))
    {
      contentURL += "&mx.page.filter=" + selected;
      fs.setFilterValue(selected);
      fs.addFilterOption(w,"Weekly");
    }
    else if(selected.equals("Quarterly"))
    {
      contentURL += "&mx.page.filter=" + selected;
      fs.setFilterValue(selected);
      fs.addFilterOption(q,"Quarterly");
      fs.addFilterOption(m,"Monthly");
      fs.addFilterOption(w,"Weekly");
    }
    else
    {
      contentURL += "&mx.page.filter=Monthly";
      fs.setFilterValue(selected);
      fs.addFilterOption(m,"Monthly");
      fs.addFilterOption(w,"Weekly");

    }
  } else {
      contentURL += "&mx.page.filter=Monthly";
      fs.setFilterValue("Monthly");

      fs.addFilterOption(m,"Monthly");
      fs.addFilterOption(w,"Weekly");
      fs.addFilterOption(q,"Quarterly");

  }

  String PageHeading = "";
  PageHeading = "emxProgramCentral.Common.ResourceLoading";
  String new_Report        = "emxProgramCentral.Common.ResourceLoading.NewReport";
  fs.createHeaderLink(new_Report, "newReport()", "role_GlobalUser",
                     false, true, "default", 3);
  String HelpMarker  = "emxhelpresourceloadingperson";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,false,false);

  String cancelStr = "emxProgramCentral.Button.Cancel";
  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);



  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

