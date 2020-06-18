<%@ page import = "java.io.PrintWriter" %>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
begin1
<%

	framesetObject fs = new framesetObject();

	fs.setDirectory(appDirectory);
	fs.setSubmitMethod(request.getMethod());

	// Add Parameters Below
	String targetLocation = emxGetParameter(request, "targetLocation");
	String reportId= emxGetParameter(request, "reportId");
	String documentId = emxGetParameter(request, "documentId");
	String reportName = emxGetParameter(request, "reportName");
	String withChanges = emxGetParameter(request, "withChanges");


	// Specify URL to come in middle of frameset
	StringBuffer contentURLBuf = new StringBuffer(80);
	contentURLBuf.append("emxCATRgnReportPostEdition.jsp?PrinterFriendly=true&reportId=");
	contentURLBuf.append(reportId);
	contentURLBuf.append("&documentId=");
	contentURLBuf.append(documentId);
	contentURLBuf.append("&reportName=");
	contentURLBuf.append(reportName);
	contentURLBuf.append("&withChanges=");
	contentURLBuf.append(withChanges);
	String contentURL = contentURLBuf.toString();


	// Page Heading - Internationalized
	String PageHeading = "emxRGN.Title.ReportGeneration";

	// Marker to pass into Help Pages
	// icon launches new window with help frameset inside
	String HelpMarker = "emxhelpreportgenerate";


	fs.initFrameset(PageHeading,
						HelpMarker,
						contentURL,
						false,
						true,
						false,
						false);

	String roleList = "role_RGNDesigner";

	fs.setTopFrameCommonPage("../common/emxAppTopPageInclude.jsp");
	fs.setBottomFrameCommonPage("../common/emxAppBottomPageInclude.jsp");
	fs.setStringResourceFile("emxRGNStringResource");

	fs.createFooterLink("emxRGN.Label.Done",
						"submitForm()",
						roleList,
						false,
						true,
						"common/images/buttonDialogDone.gif",
						0);

	fs.writePage(out);
	  
%>

end2
