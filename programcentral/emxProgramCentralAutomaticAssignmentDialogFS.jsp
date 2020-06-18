<%--  emxProgramCentralAutomaticAssignmentDialogFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/2/2002
--%>
  
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxProgramCentralCommonUtilAppInclude.inc"%>

<jsp:useBean id="object" scope="page" class="com.matrixone.apps.domain.DomainObject"/>
<jsp:useBean id="emxProgramCentralAutomaticAssignmentDialogFS" scope="session" class="com.matrixone.apps.framework.ui.UITable"/>
<jsp:useBean id="domainObject" scope="page" class="com.matrixone.apps.domain.DomainObject"/>

<%
  String jsTreeID      = emxGetParameter(request,"jsTreeID");
  String suiteKey      = emxGetParameter(request,"suiteKey");
  String initSource    = emxGetParameter(request,"initSource");
  String objectId      = emxGetParameter(request,"objectId");
  String taskIds       = emxGetParameter(request,"selectedIds");
  //String taskIds       = "";
  String tableBeanName = "emxProgramCentralAutomaticAssignmentDialogFS";
  String Directory     = appDirectory;
/*
  String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
  
  if(tableRowIdList != null )
  {
     for(int i=0;i<tableRowIdList.length;i++){
        String sObjId = "";
        StringTokenizer st = new StringTokenizer(tableRowIdList[i], "|");
        int numTokens = st.countTokens();
        if (numTokens == 2)
        {
           sObjId = st.nextToken();
        }
        else
        {
           sObjId = st.nextToken();
           sObjId = st.nextToken();
        }
        
        if ("".equals(taskIds))
        {
           taskIds += sObjId;
        }
        else
        {
           taskIds += "~" + sObjId;
        }
     }
  }
*/
  framesetObject fs = new framesetObject();
  fs.useCache(false);
  fs.setBeanName(tableBeanName);
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

    // Specify URL to come in middle of frameset
    String contentURL = "emxProgramCentralAutomaticAssignmentDialog.jsp";
    // add these parameters to each content URL, and any others the App needs
    contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
    contentURL += "&jsTreeID=" + jsTreeID + "&taskIds="+ taskIds + "&objectId=" + objectId + "&beanName=" + tableBeanName;
    //Added below HelpMarker for Bug341592
	String HelpMarker = "emxhelpassignbyprojectrole";
    fs.initFrameset("emxProgramCentral.Header.AutomaticAssignment", HelpMarker ,contentURL,true,false,true,false);

    fs.createFooterLink("emxProgramCentral.Common.Apply", "applyChanges()", "role_GlobalUser",
                      false, true, "common/images/buttonDialogDone.gif", 0);

    fs.createFooterLink("emxProgramCentral.Common.Cancel", "submitClose()", "role_GlobalUser",
                      false, true, "common/images/buttonDialogCancel.gif", 0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>
