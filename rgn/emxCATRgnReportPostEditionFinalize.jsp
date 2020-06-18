<%@ page import="com.matrixone.apps.common.util.ComponentsUtil"%>
<%@ page import="matrix.util.MatrixException"%>
<%@ page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@ include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import="java.io.File" %>
<%@ page import="com.dassault_systemes.catrgn.services.util.misc.*" %>
<%@ page import="com.dassault_systemes.catrgn.pervasive.server.*" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.util.*" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.*" %>
<%@ page import="com.dassault_systemes.catrgn.connector.configuration.interfaces.ConnectorConfigurationItf" %>
<%@ page import="com.dassault_systemes.catrgn.connector.configuration.interfaces.ConnectorConfigurationFactory" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.*" %>
<%@ page import="com.dassault_systemes.catrgn.connector.interfaces.*" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.otscript.*" %>
<%@ page import="com.dassault_systemes.catrgn.literals.*" %>
<%@ page import="com.dassault_systemes.catrgn.constants.*" %>
<%
	String msg = "PostEditionOK";
	String actionURL="../common/emxIndentedTable.jsp?program=CATRgnReport:getReports&programLabel=All&table=RGNReportNavSummary&header=emxRGN.Command.ReportGenerations&HelpMarker=emxhelpreportgenerationcreate&showRMB=true&topActionbar=RGNReportTopActionBar&bottomActionbar=RGNReportBottomActionBar&selection=multiple&sortColumnName=Name&sortDirection=descending&suiteKey=RGN&StringResourceFileId=emxRGNStringResource&SuiteDirectory=.";
	ReportGenerationEnovia generation = null;
	CATRgnReportServices services = null;
	CATRgnIReport rgnInfo = null;
	try {
		String lang = request.getHeader("Accept-Language");
		String reportId= emxGetParameter(request, "reportId");
		String documentId = emxGetParameter(request, "documentId");
		RequestNfo reqInfo = RGNUtil.createRequestFromContext(context, lang);
		reqInfo.setProperty(HttpServletRequest.class, request);
		Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
		services = new CATRgnReportServices(context, lang);
		rgnInfo = services.getReportWithInputs(reportId); 
		Map<String, String> editableTexts = new HashMap<String, String>();
		String[] editableIds = ((String)requestMap.get("editableIds")).split(" ");
		for (int i = 0; i < editableIds.length; i++) {
			String editableId = editableIds[i];
			editableTexts.put(editableId, (String)requestMap.get(editableId));
		};		
		services.reportDataServices.saveReportEditableTexts(rgnInfo, editableTexts);
		services.generateReport(rgnInfo, true, false, "true".equalsIgnoreCase(emxGetParameter(request, "withChanges")));
	} catch (MatrixException e) {
		e.printStackTrace(System.out);
		msg = "RGN: " + e.toString();
		if (services != null && rgnInfo != null)
			services.reportDataServices.saveReportDataAttribute(rgnInfo.getReportDataId(), SystemReportGenerationConstants.GENERATION_MESSAGE, msg);
	} catch (Exception e) {
		e.printStackTrace(System.out);	
		msg = "RGN: " + e.getMessage();
		if (services != null && rgnInfo != null)
			services.reportDataServices.saveReportDataAttribute(rgnInfo.getReportDataId(), SystemReportGenerationConstants.GENERATION_MESSAGE, msg);
	} finally {
		if (generation != null) generation.clear();
	}
%>
<%=XSSUtil.encodeForHTML(context, msg)%>
