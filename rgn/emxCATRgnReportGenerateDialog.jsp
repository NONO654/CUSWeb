
<%@page import="com.dassault_systemes.catrgn.i18n.I18nContext"%>
<%@page import="com.dassault_systemes.catrgn.i18n.I18nUtil"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.lang.Exception" %>
<%@ page import="javax.servlet.*" %>	
<%@ page import="javax.servlet.http.*" %>

<%@ page import="com.google.gwt.user.server.rpc.*" %>
<%@ page import="com.dassault_systemes.catrgn.pervasive.server.*" %>
<%@ page import="com.dassault_systemes.catrgn.pervasive.util.*" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.util.*" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.*" %>
<%@ page import="com.dassault_systemes.catrgn.connector.configuration.interfaces.ConnectorConfigurationItf" %>
<%@ page import="com.dassault_systemes.catrgn.connector.configuration.interfaces.ConnectorConfigurationFactory" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.*" %>
<%@ page import="com.dassault_systemes.catrgn.connector.interfaces.*" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.otscript.OtsI18nFactory" %>
<%@ page import="com.dassault_systemes.catrgn.literals.*" %>
<%@ page import="com.dassault_systemes.catrgn.constants.SystemReportGenerationConstants" %>
<%@ page import="com.dassault_systemes.catrgn.services.util.nls.*" %>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@include file="../emxJSValidation.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIFormUtil.js"></script>
<script type="text/javascript" src="../common/emxFormConstantsJavascriptInclude.jsp"></script>
<script type="text/javascript" src="../common/emxJSValidation.jsp"></script>
<script type="text/javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>
<script type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIPopups.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICreate.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIFormUtil.js"></script>
<script type="text/javascript" src="../common/scripts/emxTypeAhead.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIJson.js"></script>
<script type="text/javascript" src="../common/scripts/emxQuery.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIFormHandler.js"></script>

<%

	//Start NLS


	String lang = request.getHeader("Accept-Language");
	RequestNfo reqInfo = RGNUtil.createRequestFromContext(context, lang);
	I18nContext i18nCtx = new I18nServerContext(reqInfo);
	String nameLabel = I18nUtil.STR_NAME.get(i18nCtx);
	String OKLabel = I18nUtil.STR_OK.get(i18nCtx);
	String NOKLabel = I18nUtil.STR_NOK.get(i18nCtx);
	String loadingConfLabel = I18nUtil.STR_LOADING_CONFIGURATION.get(i18nCtx);
	String loadingModelLabel = I18nUtil.STR_LOADING_MODEL.get(i18nCtx);
	String genStartedLabel = I18nUtil.STR_GENERATION_STARTED.get(i18nCtx);
	String genCompletedLabel = I18nUtil.STR_COMPLETED.get(i18nCtx);
	String cannotCreateGeneratedDocumentLabel = I18nUtil.STR_GEN_DOC_CREATION_FAILURE.get(i18nCtx);
	String backgroundGenerationLabel = I18nUtil.STR_BACKGROUND_GEN_LAUNCHED.get(i18nCtx);
	String backgroundGenerationPendingLabel = I18nUtil.STR_BACKGROUND_GEN_PENDING.get(i18nCtx);

	// End NLS


	boolean isSlideIn = "slidein".equalsIgnoreCase(emxGetParameter(request, "targetLocation")); 
	String openNewRow = isSlideIn ? "</TR><TR>" : "";
	boolean isEditMode = "edit".equalsIgnoreCase(emxGetParameter(request, "mode"));
	boolean withChanges = "true".equalsIgnoreCase(emxGetParameter(request, "withChanges"));
	String actionURL = null;
	boolean doPostEdition = false;
	String reportId = emxGetParameter(request, "objectId");
	if (reportId.startsWith("|")) reportId = reportId.substring(1, reportId.indexOf("|", 1));
	PrintWriter pw = new PrintWriter(out);
	ReportGenerationEnovia generation = null;
	try {
		Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
		CATRgnReportServices services = new CATRgnReportServices(context, lang);
		CATRgnIReport rgnInfo = services.getReportWithInputs(reportId);
        doPostEdition = rgnInfo.needPostEdition();
		if (!doPostEdition && JobUtil.isBackgroundGenerationEnabled()) {
			String reportDataId = rgnInfo.getReportDataId();
			String jobCurrent = JobUtil.getJobCurrentStatus(context, reportId, reportDataId);
			if (jobCurrent == null || !jobCurrent.matches("(?:" + JobUtil.CREATED_STATUS + "|" + JobUtil.SUBMITTED_STATUS + "|" + JobUtil.RUNNING_STATUS + ")")) {
				pw.println("<table><tr><td class=\"label\" align=\"center\">");
				pw.println(backgroundGenerationLabel);
				pw.println("</td></tr><tr>");
				pw.println("<td class=\"label\" align=\"center\">");
				pw.println("<a href='javascript:showNonModalDialog(\"../common/emxTable.jsp?table=AEFBackgroundJobList&program=emxJob:getMyCurrentBackgroundJobs&programLabel=emxFramework.Filter.Current&toolbar=AEFJobRequestToolbar&header=emxFramework.Label.MyBackgroundProcess&HelpMarker=emxhelpbackgroundjobs&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&targetLocation=slideins\")'>Monitoring</a>");
				pw.println("</td></tr>");
				try {
					JobUtil.runBackgroundGeneration(context, reportId);
				} catch (FrameworkException e) {
					pw.println("<tr><td class=\"label\" align=\"center\">");
					e.getMessage();
					if (SystemReportGenerationConstants.IS_DEBUG)
						e.printStackTrace();
					pw.println("</td></tr>");
				}
				pw.println("</table>");
			} else {
				pw.println("<table><tr><td class=\"label\" align=\"center\">");
				pw.println(backgroundGenerationPendingLabel);
				pw.println("</td></tr></table>");
			}
			pw.flush();
		} else {
			pw.println("<table><tr><td class=\"label\" align=\"center\">");
			pw.println(loadingConfLabel);
			pw.println("</td>");
			pw.flush();
			reqInfo.setProperty(HttpServletRequest.class, request);
			pw.println("<td class=\"label\" align=\"center\">");
			pw.println("<font color=\"green\">");
			pw.println(OKLabel);
			pw.println("</font></td></tr>");
			pw.flush();

			pw.println("<tr><td class=\"label\" align=\"center\">");
			pw.println(loadingModelLabel);
			pw.println("</td>");
			pw.flush();
			ConnectorConfigurationItf conConfig = new ConnectorConfigurationFactory().getRGNConfig(reqInfo);
			generation = new ReportGenerationEnovia(reqInfo, conConfig);
			generation.withChanges = withChanges;
			String messages = conConfig.getMessages();
			if (rgnInfo.getGeneratedDocumentId() != null) generation.loadReportEditableTexts(rgnInfo);
			if(messages.isEmpty()) {
				pw.println("<td class=\"label\" align=\"center\">");
				pw.println("<font color=\"green\">");
				pw.println(OKLabel);
				pw.println("</font></td></tr>");
				pw.flush();
			} else {
				pw.println("<td class=\"labelRequired\" align=\"center\">");
				pw.println(NOKLabel);
				pw.println("</td></tr></table>");
				pw.println("<table><tr><td class=\"label\" align=\"center\">");
				pw.println("<td class=\"labelRequired\" align=\"center\">");
				pw.println("Warning:");
				pw.println(messages);
				pw.println("</td></tr>");
				pw.flush();
			}
			try{
				pw.println("<tr><td class=\"label\" align=\"center\">");
				pw.println(genStartedLabel);
				pw.println("</td>");
				pw.flush();
				if (doPostEdition) generation.executeWithPostEdition(rgnInfo);
				else generation.execute(rgnInfo);
				services.createReportGeneratedDocument(rgnInfo);
				pw.println("<td class=\"label\" align=\"center\">");
				pw.println("<font color=\"green\">");
				pw.println(genCompletedLabel);
				pw.println("</font></td></tr></table>");
				pw.flush();
			} catch (Exception e) {
				e.printStackTrace(System.out);
				pw.println("<td class=\"labelRequired\" align=\"center\">");
				pw.println(NOKLabel);
				pw.println("</td></tr></table>");
				pw.println("<table><tr><td class=\"label\" align=\"center\">");
				pw.println("<td class=\"labelRequired\" align=\"center\">");
				pw.println(cannotCreateGeneratedDocumentLabel);
				pw.println("<br/>");
				pw.println(e.getMessage());
				pw.println("</td></tr></table>");
				pw.flush();
			}
			if (doPostEdition) {
				StringBuffer actionUrlBuff = new StringBuffer();
				actionUrlBuff.append("emxCATRgnReportPostEditionFS.jsp?reportId=");
				actionUrlBuff.append(reportId);
				actionUrlBuff.append("&documentId=");
				actionUrlBuff.append(rgnInfo.getGeneratedDocumentId());
				actionUrlBuff.append("&reportName=");
				actionUrlBuff.append(rgnInfo.getFileName());
				actionUrlBuff.append(".html&withChanges=");
				actionUrlBuff.append(emxGetParameter(request, "withChanges"));
				actionURL = actionUrlBuff.toString();
			}
		}
	} catch (MatrixException e) {
		doPostEdition = false;
		e.printStackTrace(System.out);
		pw.println("<td class=\"labelRequired\" align=\"center\">");
		pw.println(NOKLabel);
		pw.println("</td></tr></table>");
		pw.println("<table><tr>");
		pw.println("<td class=\"labelRequired\" align=\"center\">");
		pw.println(e.toString());
		pw.println("</td></tr></table>");
		pw.flush();		
	} catch (Exception e) {
		doPostEdition = false;
		e.printStackTrace(System.out);
		pw.println("<td class=\"labelRequired\" align=\"center\">");
		pw.println(NOKLabel);
		pw.println("</td></tr></table>");
		pw.println("<table><tr>");
		pw.println("<td class=\"labelRequired\" align=\"center\">");
		pw.println(e.getMessage());
		pw.println("</td></tr></table>");
		pw.flush();		
	} finally {
		if (generation != null) generation.clear();
	}
%>

<script language="Javascript">
	function submitForm() {
	    if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(isSlideIn))%>) {
	    	getTopWindow().closeSlideInDialog();
			var contentFrame = findFrame(getTopWindow(), "content");
			if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(doPostEdition))%>) {
				contentFrame.document.location.href = "<%=XSSUtil.encodeForJavaScript(context, actionURL)%>"
			} else {
				contentFrame.document.location.href = contentFrame.document.location.href;
			}
		} else {
	    	parent.window.opener.document.location = parent.window.opener.document.location;
			parent.window.close();
		} 
	}

</script>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>
