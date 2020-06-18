<%@ page import = "java.io.PrintWriter" %>
<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import = "com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil" %>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
begin1
<%

	framesetObject fs = new framesetObject();

	fs.setDirectory(appDirectory);
	fs.setSubmitMethod(request.getMethod());

	// Add Parameters Below
	String targetLocation = emxGetParameter(request, "targetLocation");
	String mode = emxGetParameter(request, "mode");
	String objectId = request.getParameter(RGNUtil.REPORT_ID);
	if(objectId == null || objectId.contentEquals("null") || objectId.isEmpty()) objectId = request.getParameter("emxTableRowId");
	if (objectId != null && objectId.startsWith("|")) objectId = objectId.substring(1, objectId.indexOf("|", 1));
	 

	// Specify URL to come in middle of frameset
	StringBuffer contentURLBuf = new StringBuffer(80);
	contentURLBuf.append("emxCATRgnReportCreateDialog.jsp");
	contentURLBuf.append(targetLocation == null ? "?targetLocation=slidein" : "?targetLocation=" + targetLocation);
	contentURLBuf.append(mode == null ? "" : "&mode=" + mode);
	contentURLBuf.append(objectId == null ? "" : "&" + RGNUtil.REPORT_ID + "=" + objectId);
	String contentURL = contentURLBuf.toString();


	// Page Heading - Internationalized
	String PageHeading = "emxRGN.Title.CreateReportStep1";

	// Marker to pass into Help Pages
	// icon launches new window with help frameset inside
	String HelpMarker = (mode != null && "edit".equalsIgnoreCase(mode)) ? "emxhelpreporteditdetails" : "emxhelpreportcreate";
	String roleList = "role_RGNDesigner";
	fs.setSuiteKey("RGN");
	fs.setTopFrameCommonPage("../common/emxAppTopPageInclude.jsp");
	fs.setBottomFrameCommonPage("../common/emxAppBottomPageInclude.jsp");
	fs.setStringResourceFile("emxRGNStringResource");
	
	fs.initFrameset(PageHeading,
			HelpMarker,
			contentURL,
			false,
			false,
			false,
			false);

	fs.createFooterLink("emxRGN.Label.Next",
						"submitForm()",
						roleList,
						false,
						true,
						"common/images/buttonDialogNext.gif",
						0);

 
	fs.createFooterLink("emxRGN.Label.Cancel",
						"cancelForm()",
						roleList,
						false,
						true,
						"common/images/buttonDialogCancel.gif",
						0);

	fs.writePage(out);
	  
%>

end2
