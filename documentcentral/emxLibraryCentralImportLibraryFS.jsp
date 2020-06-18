<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxLibraryCentralmportAG.jsp.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import="com.matrixone.servlet.Framework,com.matrixone.fcs.mcs.McsBase" %>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>
<%

	String PageHeading = "emxMultipleClassification.Command.ImportHeadingLibrary";
	String HelpMarker = "emxhelpimportlibrary";
	String contentURL = "emxLibraryCentralImportLibrary.jsp";
	String jsTreeID = emxGetParameter(request,"jsTreeID");
	String suiteKey = emxGetParameter(request,"suiteKey");
	String initSource = emxGetParameter(request,"initSource");
	String isAGImport=emxGetParameter(request,"AGImport");
	String isbkgProcess=emxGetParameter(request,"bkgprocess");
	String heading=emxGetParameter(request,"heading");
	String targetLocation=emxGetParameter(request,"targetLocation");
	// add these parameters to each content URL, and any others the App needs
	contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+"&isAGImport="+isAGImport+"&targetLocation="+targetLocation;
	if(!UIUtil.isNullOrEmpty(isbkgProcess))
		contentURL +="&bkgprocess="+isbkgProcess;
	if(!UIUtil.isNullOrEmpty(heading))
		PageHeading ="emxMultipleClassification.Command.ImportHeadingLibraryBkg";
	framesetObject fs = new framesetObject();
	fs.setDirectory(appDirectory);
	fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
	fs.useCache(false);
	fs.setStringResourceFile("emxLibraryCentralStringResource");
	fs.removeDialogWarning();
  

  // ----------------- Bottom Include ------------------------------

    fs.createCommonLink("emxMultipleClassification.Command.Import",
                    "formSubmit()",
                    "role_GlobalUser",
                    false,
                    true,
                    "common/images/buttonDialogAdd.gif",
                    false,
                    1);
  fs.createCommonLink("emxMultipleClassification.Command.Validate",
          "validateLibraryXML(true)",
          "role_GlobalUser",
          false,
          true,
          "common/images/buttonDialogDone.gif",
          false,
          2);  

  fs.createCommonLink("emxDocumentCentral.Button.Close",
                      "getTopWindow().closeSlideInDialog()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

	//----------------- Do Not Edit Below ------------------------------
	fs.writePage(out);

%>


<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
