<%@page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.CATRgnIReportTemplate.TemplateParameter"%>
<%@page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.CATRgnIReportTemplate"%>
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
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

	// Specify URL to come in middle of frameset
	StringBuffer contentURLBuf = new StringBuffer();
	contentURLBuf.append("emxCATRgnReportCreateParamsDialog.jsp");
	
	contentURLBuf.append("?targetLocation=");  
	contentURLBuf.append(emxGetParameter(request, "targetLocation"));

	String mode = emxGetParameter(request, "mode");
	if(mode != null) {
		contentURLBuf.append("&mode=");
		contentURLBuf.append(mode);
	}
		
	String objectId = emxGetParameter(request, RGNUtil.REPORT_ID);
	if(objectId != null) {
		contentURLBuf.append("&");
		contentURLBuf.append(RGNUtil.REPORT_ID);
		contentURLBuf.append("=");
		contentURLBuf.append(objectId);
	}
	
	String reportGenerationName = emxGetParameter(request, RGNUtil.REPORT_NAME);
	if(reportGenerationName != null) {
		contentURLBuf.append("&");
		contentURLBuf.append(RGNUtil.REPORT_NAME);
		contentURLBuf.append("=");
		contentURLBuf.append(CATRgnReportServices.encodeUTF8(reportGenerationName));
	}
	
	String reportGenerationTitle = emxGetParameter(request, RGNUtil.REPORT_TITLE);
	if(reportGenerationTitle != null) {
		contentURLBuf.append("&");
		contentURLBuf.append(RGNUtil.REPORT_TITLE);
		contentURLBuf.append("=");
		contentURLBuf.append(CATRgnReportServices.encodeUTF8(reportGenerationTitle));
	}

	String reportGenerationDescription = emxGetParameter(request, RGNUtil.REPORT_DESCR);
	if(reportGenerationDescription != null) {
		contentURLBuf.append("&");
		contentURLBuf.append(RGNUtil.REPORT_DESCR);
		contentURLBuf.append("=");
		contentURLBuf.append(CATRgnReportServices.encodeUTF8(reportGenerationDescription));	
	}
	
	String reportModelId = emxGetParameter(request,RGNUtil.REPORT_MODEL_ID);
	if(reportModelId != null) {
		contentURLBuf.append("&");
		contentURLBuf.append(RGNUtil.REPORT_MODEL_ID);
		contentURLBuf.append("=");
		contentURLBuf.append(reportModelId);
	}
	
	String reportTemplateId = emxGetParameter(request,RGNUtil.REPORT_TEMPLATE_ID);
	if(reportTemplateId != null) {
		contentURLBuf.append("&");
		contentURLBuf.append(RGNUtil.REPORT_TEMPLATE_ID);
		contentURLBuf.append("=");
		contentURLBuf.append(reportTemplateId);
	}
	
	String targetDocumentId = emxGetParameter(request,RGNUtil.TARGET_DOCUMENT_ID);
	if(targetDocumentId != null) {
		contentURLBuf.append("&");
		contentURLBuf.append(RGNUtil.TARGET_DOCUMENT_ID);
		contentURLBuf.append("=");
		contentURLBuf.append(targetDocumentId);
	}

	CATRgnIReportTemplate templateRepresentation = CATRgnReportServices.getTemplateRepresentation(context, reportModelId);
	TemplateParameter[] params = templateRepresentation.getParameters();
	int nbInputs = params.length;
	if(nbInputs>0) {
		contentURLBuf.append("&"); 
		contentURLBuf.append(RGNUtil.REPORT_NB_INPUTS);
		contentURLBuf.append("=");
		contentURLBuf.append(nbInputs);
		for(int i = 0; i < nbInputs; i++) {
			TemplateParameter param = params[i];
			String fieldName = RGNUtil.InputId(i);
			contentURLBuf.append("&"); 
			contentURLBuf.append(fieldName);
			contentURLBuf.append("=");
			contentURLBuf.append(emxGetParameter(request, fieldName));
			fieldName = RGNUtil.InputValue(i);
			contentURLBuf.append("&"); 
			contentURLBuf.append(fieldName);
			contentURLBuf.append("=");
			contentURLBuf.append(emxGetParameter(request, fieldName));
			fieldName = RGNUtil.InputName(i);
			contentURLBuf.append("&"); 
			contentURLBuf.append(fieldName);
			contentURLBuf.append("=");
			contentURLBuf.append(param.getDisplay());
			fieldName = RGNUtil.InputType(i);
			contentURLBuf.append("&"); 
			contentURLBuf.append(fieldName);
			contentURLBuf.append("=");
			contentURLBuf.append(param.getTypeName());
		}
	}

	String configId = emxGetParameter(request,RGNUtil.REPORT_CONFIG_ID);
    if(configId != null) {
        contentURLBuf.append("&");
        contentURLBuf.append(RGNUtil.REPORT_CONFIG_ID);
        contentURLBuf.append("=");
        contentURLBuf.append(configId);
    }

	String contentURL = contentURLBuf.toString();
	


	// Page Heading - Internationalized
	String PageHeading = "emxRGN.Title.CreateReportStep2";

	// Marker to pass into Help Pages
	// icon launches new window with help frameset inside
	String HelpMarker = (mode != null && "edit".equalsIgnoreCase(mode)) ? "emxhelpreporteditparams" : "emxhelpreportcreateparams";
	fs.setSuiteKey("RGN");

	fs.initFrameset(PageHeading,
						HelpMarker,
						contentURL,
						false,
						false,
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

	fs.createFooterLink("emxRGN.Label.ConfigurationFilters",
			"submitNext()",
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
