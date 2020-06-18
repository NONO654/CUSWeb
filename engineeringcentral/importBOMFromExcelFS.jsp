<%--  importBOMFromExcelFS.jsp   -   FS page for importing Bom from excel
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
  if (initSource == null)
  {
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");
  String parentId = emxGetParameter(request,"parentId");
  
  String commandName = emxGetParameter(request, "commandName");
  
  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
  
  String selPartRelId = "";
  String selPartObjectId = "";
  String selPartParentOId = "";
  String selPartRowId     = "";
	
  if(tableRowIdList != null) {
		//String tableRowId = XSSUtil.encodeForJavaScript(context,tableRowIdList[0]);
	    StringList slList = FrameworkUtil.split(" "+tableRowIdList[0], "|");
	    try {
	        selPartRelId     = ((String)slList.get(0)).trim();
	        //selPartRelId = XSSUtil.encodeForJavaScript(context,selPartRelId); 
	        selPartObjectId  = ((String)slList.get(1)).trim();
	        //selPartObjectId = XSSUtil.encodeForJavaScript(context,selPartObjectId); 
	        selPartParentOId = ((String)slList.get(2)).trim();
	        //selPartParentOId = XSSUtil.encodeForJavaScript(context,selPartParentOId); 
	        selPartRowId     = ((String)slList.get(3)).trim();
	        //selPartRowId = XSSUtil.encodeForJavaScript(context,selPartRowId); 
	    } catch(Exception e) {
	        selPartParentOId="";
	    }
  } 

   // Specify URL to come in middle of frameset
   StringBuffer contentURL = new StringBuffer("importBOMFromExcelFile.jsp");

   // add these parameters to each content URL, and any others the App needs
   contentURL.append("?suiteKey=");
   contentURL.append(suiteKey);
   contentURL.append("&initSource=");
   contentURL.append(initSource);
   contentURL.append("&jsTreeID=");
   contentURL.append(jsTreeID);
   contentURL.append("&objectId=");
   contentURL.append(objectId);
   contentURL.append("&selPartRelId=");
   contentURL.append(selPartRelId);
   contentURL.append("&selPartObjectId=");
   contentURL.append(selPartObjectId);
   contentURL.append("&selPartParentOId=");
   contentURL.append(selPartParentOId);
   contentURL.append("&selPartRowId=");
   contentURL.append(selPartRowId);
   contentURL.append("&commandName=");
   contentURL.append(commandName);
   contentURL.append("&targetLocation=slidein");

   String finalURL=contentURL.toString();

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  //String HelpMarker = "emxhelpspeccreaterevision";
  String HelpMarker = "emxhelpaboutbomimport";
  
  String pageHeading = "emxEngineeringCentral.Header.EBOMImport";
  
  fs.initFrameset(pageHeading,
                  HelpMarker,
                  finalURL,
                  false,
                  true,
                  false,
                  false);            
                  
  fs.setStringResourceFile("emxEngineeringCentralStringResource"); 
  fs.setSuiteKey(suiteKey);
                
  fs.createFooterLink("emxFramework.Command.Done",
                      "submit()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);
                      
  fs.createFooterLink("emxFramework.Command.Cancel",
		  			  //"top.closeSlideInDialog()",
		  			  "getTopWindow().closeSlideInDialog()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
