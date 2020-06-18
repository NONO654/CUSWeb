<%--
  emxProgramCentralResourceLoadingFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  this program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralResourceLoadingFS.jsp.rca 1.11 Wed Oct 22 15:49:34 2008 przemek Experimental przemek $";

--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

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
  String sStartDtHidden =      emxGetParameter(request,"start_msvalue");
  String sEndDtHidden   =      emxGetParameter(request,"end_msvalue");
  String InitialSelection =    emxGetParameter(request,"initial");

  if(sStartDtHidden==null)
  sStartDtHidden="";
  if(sEndDtHidden==null)
  sEndDtHidden="";

  double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
  start = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,start, clientTZOffset,request.getLocale());
  end = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,end, clientTZOffset,request.getLocale());
  String range_data="";


  if(start!=null && end != null && start.trim().length() > 0 && end.trim().length() > 0 )
  {
     range_data = start + "|"+ end;
  }

  //String[] emxTableRowId =      emxGetParameterValues(request,"emxTableRowId");
  String objectName =    emxGetParameter(request,"objectName");
  String filterValue =   emxGetParameter(request,"mx.page.filter");
  if(filterValue==null){
	  filterValue=selected;
  }
  String fromDashboard  = emxGetParameter(request,"fromDashboard");

  String Directory =     appDirectory;
  //Modified for Bug#312083  - Begin
  /*String hiddenParams = "";
     for(int k=0;k<emxTableRowId.length;k++){
            String itemId = emxTableRowId[k];
             if(k==emxTableRowId.length-1)
              hiddenParams += itemId;
            else
              hiddenParams += itemId + ",";
     }*/
  //Modified for Bug#312083  - End

  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");
  fs.enableSpreadSheetPage();

  String m = "emxProgramCentral.Common.ResourceLoading.Monthly";
  String w = "emxProgramCentral.Common.ResourceLoading.Weekly";
  String q = "emxProgramCentral.Common.ResourceLoading.Quarterly";

  if (initSource == null){
    initSource = "";
  }

//Modified for Bug#312083  - Begin
  String contentURL = "emxProgramCentralResourceLoadingSummary.jsp?suiteKey=" + suiteKey +
                      "&initSource=" + initSource + "&jsTreeID=" + jsTreeID +
                      "&objectId=" + objectId +"&date_range=" + range_data+ "&start_msvalue="+sStartDtHidden+"&end_msvalue="+sEndDtHidden+"&initial="+InitialSelection+"&start="+start+"&end="+end;
//Modified for Bug#312083  - End


  if(selected != null && !"".equals(selected)) {
    	
    	contentURL += "&mx.page.filter="+filterValue;
    	fs.setFilterValue(filterValue);
    	
    	  if(selected.equals("Quarterly")){
		      fs.addFilterOption(q,"Quarterly");
    }
		  if (selected.equals("Quarterly") || selected.equals("Monthly")){
      fs.addFilterOption(m,"Monthly");
    }
		  if(selected.equals("Quarterly") || selected.equals("Monthly") ||selected.equals("Weekly")){
      fs.addFilterOption(w,"Weekly");
  }
}
  String PageHeading = "";
  PageHeading = "emxProgramCentral.Common.ResourceLoading";
  String HelpMarker  = "emxhelpresourceloadingreport";

  String new_Report        = "emxProgramCentral.Common.ResourceLoading.NewReport";
  fs.createHeaderLink(new_Report, "newReport()", "role_GlobalUser",
                     false, true, "default", 3);


  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,false,false);

  //fs.addFilterOption(m,"Monthly");
  //fs.addFilterOption(w,"Weekly");
  //fs.addFilterOption(q,"Quarterly");

  String cancelStr = "emxProgramCentral.Button.Cancel";
  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);


  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

