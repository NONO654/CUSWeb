 <%-- emxProgramCentralMemberTransferDialogFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>
<%! 
//This sets session object "emxProgramCentralMemberTransferDialogFSParams" for back button functionality
//Bug No. 357558
private static String emxGetParameter(HttpServletRequest request, HttpSession session, String requestString)
{
    String requestValue = (String)emxGetParameter(request, requestString);
    
    HashMap trasferAssignmentParamsMap = (HashMap)session.getAttribute("emxProgramCentralMemberTransferDialogFSParams");
    if(trasferAssignmentParamsMap == null)
    {
        trasferAssignmentParamsMap = new HashMap();
        session.setAttribute("emxProgramCentralMemberTransferDialogFSParams", trasferAssignmentParamsMap);
    }

    if (requestValue == null)
	{
        requestValue = (String)trasferAssignmentParamsMap.get(requestString);
	}
	else
	{
	    trasferAssignmentParamsMap.put(requestString, requestValue);
	}
    
	return requestValue;
}
%>

<%
  String jsTreeID   = emxGetParameter(request, session, "jsTreeID");
  String suiteKey   = emxGetParameter(request, session, "suiteKey");
  String initSource = emxGetParameter(request, session, "initSource");
  String objectId   = emxGetParameter(request, session, "objectId");
  String personId   = emxGetParameter(request, session, "personId");
  String userType   = emxGetParameter(request, session, "userType");
  String emxTableRowId = emxGetParameter(request, session, "emxTableRowId");
  Map TableRowIdMap = ProgramCentralUtil.parseTableRowId(context,emxTableRowId);
  emxTableRowId = (String)TableRowIdMap.get("objectId");
  if(emxTableRowId.contains(":")){
  	StringList valueList = StringUtil.split(emxTableRowId, ":");
  	String personName = (String)valueList.get(2);
  	if(personName.contains("_PRJ")){
  		personName = personName.substring(0,personName.indexOf("_PRJ"));
  		emxTableRowId = PersonUtil.getPersonObjectID(context, personName);
  	}else{
  		String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			  "emxProgramCentral.MemberTransfer.selectPerson", sLanguage);
  	%>
  	 <script language="JavaScript" type="text/javascript">
      alert("<%=errMsg%>");
      window.closeWindow();
      
     </script>
                               
  	<%
  	return;
  	}
  	
  }
  
  String Directory  = appDirectory;

  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralMemberTransferDialog.jsp?busId="+ objectId;

  // add these parameters to each content URL, and any others the App needs
  contentURL += "&suiteKey=" + suiteKey + "&initSource=" + initSource + "&emxTableRowId=" + emxTableRowId;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&personId=" + personId + "&userType=" + userType;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.Header.TransferAssignment1";
  // Below Helpmarker code modified for Bug 341592
  String HelpMarker = "emxhelptransferdetails";
  
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  String submitStr = "emxProgramCentral.Button.Next";
  String cancelStr = "emxProgramCentral.Button.Cancel";

  fs.createFooterLink(submitStr, "moveNext()", "role_GlobalUser",
                      false, true, "emxUIButtonNext.gif", 0);

  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>
