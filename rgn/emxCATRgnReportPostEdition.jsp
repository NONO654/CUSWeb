
<%@page import="com.dassault_systemes.catrgn.i18n.I18nUtil"%>
<%@page import="com.dassault_systemes.catrgn.i18n.I18nContext"%>
<%@page import="com.dassault_systemes.catrgn.pervasive.server.RequestNfo"%>
<%@page import="com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.FileReader"%>

<%@ include file = "../common/emxNavigatorInclude.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@ page import = "com.dassault_systemes.catrgn.pervasive.util.*" %>
<%@ page import = "com.dassault_systemes.catrgn.services.util.nls.*" %>
<%@ page import = "com.dassault_systemes.catrgn.engine.report.generation.util.*" %>
<%@ page import = "com.matrixone.apps.domain.util.ENOCsrfGuard" %>
<%

	String lang = request.getHeader("Accept-Language");
	RequestNfo reqInfo = RGNUtil.createRequestFromContext(context, lang);
	I18nContext i18nCtx = new I18nServerContext(reqInfo);
	String postEditionLabel = I18nUtil.STR_POST_EDITION_TITLE.get(i18nCtx);

	String actionURL="../common/emxIndentedTable.jsp?program=CATRgnReport:getReports&programLabel=All&table=RGNReportNavSummary&header=emxRGN.Command.ReportGenerations&HelpMarker=emxhelpreportgenerationcreate&showRMB=true&topActionbar=RGNReportTopActionBar&bottomActionbar=RGNReportBottomActionBar&selection=multiple&sortColumnName=Name&sortDirection=descending&suiteKey=RGN&StringResourceFileId=emxRGNStringResource&SuiteDirectory=.";   

	String reportId= emxGetParameter(request, "reportId");
	String documentId = emxGetParameter(request, "documentId");
	String reportName = emxGetParameter(request, "reportName");
	String withChanges = emxGetParameter(request, "withChanges");
	StringBuffer paramsBuf = new StringBuffer(80);
	paramsBuf.append("&reportId=");
	paramsBuf.append(reportId);
	paramsBuf.append("&documentId=");
	paramsBuf.append(documentId);
	paramsBuf.append("&reportName=");
	paramsBuf.append(reportName);
	paramsBuf.append("&withChanges=");
	paramsBuf.append(withChanges);

	
    if(ENOCsrfGuard.isCSRFEnabled(context)){
         Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
         String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
         String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
		 String csrfAdditionalParams = "&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "= " + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue;
		 actionURL += csrfAdditionalParams;
		 paramsBuf.append(csrfAdditionalParams);  
    }


	String params = paramsBuf.toString();

	File tempFile = File.createTempFile("rgn", ".temp");
	File htmlFile = RGNUtil.checkoutFile(context, documentId, reportName, DomainConstants.FORMAT_GENERIC, tempFile.getParent());
	try {
		StringBuilder sb = new StringBuilder();
		FileReader fr = new FileReader(htmlFile);
		StreamUtil.appendAllFromReader(fr, sb);
		PrintWriter pw = new PrintWriter(out);
		pw.print(sb.toString().replaceFirst("\\$PostEdition", postEditionLabel));
		pw.flush();
	} finally {
        if (tempFile.exists()) tempFile.delete();
        if (htmlFile.exists()) htmlFile.delete();
    }

%>	

<!-- For Transient Message needs the following inclusion -->
<script src="../webapps/AmdLoader/AmdLoader.js"></script>
<script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
<script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
<script>
	require(['DS/WebappsUtils/WebappsUtils'], function (WebappsUtils){WebappsUtils._setWebappsBaseUrl('../webapps/');});
</script>
<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script> 
<link rel="stylesheet" type="text/css" href="../webapps/UIKIT/UIKIT.css">

<script src="scripts/emxRGNScript.js"></script> 
<script language="Javascript">
	function submitForm() {
		var document = findFrame(getTopWindow(), 'pagecontent').document;
		var spans = document.querySelectorAll('span[contenteditable=true]');
		var contentFrame = findFrame(getTopWindow(), 'content');
		var footerButtons = contentFrame.document.getElementById('divPageFoot').getElementsByTagName('button');
		var postData = '';
		var ids = '';
		for(var i = -1, c = spans.length; ++i < c; ) {
			var dataId = spans[i].id;
			// childNodes[*].textContent
			var text = (spans[i].innerText || spans[i].textContent);
			postData += (postData == '' ? '' : '&') + dataId + '=' + encodeURIComponent(text);
			ids += (ids == '' ? '' : ' ') + dataId;
		};
		if (postData.length > 0) {
			postData += '&editableIds=' + ids + '<%=XSSUtil.encodeForJavaScript(context, params)%>';
		};
		for (var j = 0; j < footerButtons.length; j++) {
			footerButtons[j].setAttribute('disabled', 'true');
		};
		doPostRequest('emxCATRgnReportPostEditionFinalize.jsp', postData, function(text, error) {
			if (error != null && error.search('PostEditionOK') < 0) {
				showTransientMessage(error, 'error');
			};
			if (text != null && text.search('PostEditionOK') < 0) {
				showTransientMessage(text.match(/RGN.+/m), 'error');
			}
			contentFrame.document.location.href = "<%=XSSUtil.encodeForJavaScript(context, actionURL)%>";
		}, 'application/x-www-form-urlencoded;charset=UTF-8');
	}

</script>


<%@include file="../emxUICommonEndOfPageInclude.inc"%>
