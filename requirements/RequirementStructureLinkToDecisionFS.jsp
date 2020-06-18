	<%--  RequirementStructureLinkToDecisionFS.jsp   -   FS page for Link To Decision page.
	Copyright (c) 2008-2018 Dassault Systemes.
	All Rights Reserved.
	This program contains proprietary and trade secret information of MatrixOne,
	Inc.  Copyright notice is precautionary only
	and does not evidence any actual or intended publication of such program

	static const char RCSID[] = $Id: RequirementStructureLinkToDecisionFS.jsp
	--%>

<%--
    	@quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
    --%>
    <!-- Include directives -->
	<%@include file="../emxUIFramesetUtil.inc"%>
	<%@include file="emxProductVariables.inc"%>

	<!-- Page directives -->
	<%@page import = "com.matrixone.apps.domain.util.PropertyUtil"%>
	<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	<%
	framesetObject fs = new framesetObject();
	fs.setDirectory(appDirectory);

	String initSource = emxGetParameter(request,"initSource");
	if (initSource == null)
		{
			initSource = "";
		}
	
	String jsTreeID         = emxGetParameter(request, "jsTreeID");
	String suiteKey         = emxGetParameter(request, "suiteKey");
	String formName         = emxGetParameter(request, "formName");
	String fieldSelected    = emxGetParameter(request, "fieldSelected");
	String fieldNameActual  = emxGetParameter(request, "fieldNameActual");
	String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	String fieldRadioSelected = emxGetParameter(request, "fieldRadioSelected");
	
	// Specify URL to come in middle of frameset
	String contentURL       = "RequirementStructureLinkToDecision.jsp";
	
	// add these parameters to each content URL
	contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&formName=" + formName + "&fieldSelected=" + fieldSelected + "&fieldNameDisplay=" + fieldNameDisplay + "&fieldNameActual=" + fieldNameActual + "&fieldRadioSelected=" + fieldRadioSelected;
	
	// Marker to pass into Help Pages
	// icon launches new window with help frameset inside
	String HelpMarker  = "";
	String Header      = "emxRequirements.Heading.LinkToDecisionStep1";

	fs.initFrameset(Header,
				  HelpMarker,
				  contentURL,
				  false,
				  true,
				  false,
				  false);

	fs.setStringResourceFile("emxRequirementsStringResource");

	fs.createFooterLink("emxRequirements.Button.Next",
					  "submitForm()",
					  "role_GlobalUser",
					  false,
					  true,
					  "common/images/buttonDialogNext.gif",
					  0);
 //KIE1 ZUD TSK447636 
	fs.createFooterLink("emxRequirements.Button.Cancel",
					  "parent.closeWindow();",
					  "role_GlobalUser",
					  false,
					  true,
					  "common/images/buttonDialogCancel.gif",
					  0);
	// ----------------- Do Not Edit Below ------------------------------

	fs.writePage(out);

	%>





