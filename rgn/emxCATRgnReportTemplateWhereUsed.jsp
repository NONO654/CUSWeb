
<%@page import="com.dassault_systemes.catrgn.i18n.I18nUtil"%>
<%@page import="com.dassault_systemes.catrgn.i18n.I18nContext"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.lang.Exception" %>
<%@ page import="javax.servlet.*" %>	
<%@ page import="javax.servlet.http.*" %>

<%@ page import="com.google.gwt.user.server.rpc.*" %>
<%@ page import="com.dassault_systemes.catrgn.pervasive.server.*" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.*" %>
<%@ page import="com.dassault_systemes.catrgn.literals.*" %>
<%@ page import="com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil" %>
<%@ page import = "com.dassault_systemes.catrgn.services.util.nls.*" %>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@include file="../emxJSValidation.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIFormUtil.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUITableUtil.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/jquery-latest.js"></script>


<%
	
	//Start NLS
	

	String lang = request.getHeader("Accept-Language");
	RequestNfo reqInfo = RGNUtil.createRequestFromContext(context, lang);
	I18nContext i18nCtx = new I18nServerContext(reqInfo);
	String reportsUsingNLS = I18nUtil.STR_REPORT_USING_TEMPLATES.get(i18nCtx);
	String usedTemplatesNLS = I18nUtil.STR_USED_TEMPLATES.get(i18nCtx);
	String usingTemplatesNLS = I18nUtil.STR_USING_TEMPLATES.get(i18nCtx);

	// End NLS
	
	String templateId = emxGetParameter(request, "objectId");
	reqInfo.setProperty(HttpServletRequest.class, request);
	Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	CATRgnReportServices services = new CATRgnReportServices(context, lang);
	templateId = services.getPhysicalId(context, templateId);
	MapList reports = services.getVisibleReportsUsing(templateId);
	PrintWriter pw = new PrintWriter(out);
	String wsDir = null;
	

	pw.println("<table>");
	pw.print("<tr><td class=\"label\">");
	pw.print(reportsUsingNLS);
	pw.println("</td></tr>");
	pw.println("</table>");
	pw.flush();
	pw.println("<table>");	
	for (int i = 0; i < reports.size(); i++) {
		Map<String, String> report = (Map<String, String>)reports.get(i);
		pw.println("<tr>");
		String reportId = (String)report.get("id");
		String reportName = (String)report.get("reportName");
		pw.println(String.format("<td class=\"field\" rmb rmbid=\"%s\" rmbrelid width=\"20\">", reportId));
		pw.print("<a href=\"JavaScript:emxTableColumnLinkClick('..%2Fcommon%2FemxTree.jsp%3FemxSuiteDirectory%3D.%26relId%3Dnull%26parentOID%3Dnull%26jsTreeID%3Dnull%26suiteKey%3DRGN&objectId=");
		pw.print(reportId);
		pw.print("',%20'',%20'',%20'false',%20'content',%20'',%20'");
		pw.print(reportName);
		pw.print("',%20'false',%20'')\" class=\"object\">");
		pw.print("<img border=\"0\" src=\"images/I_RGNReport.png\" width=\"22px\">");
		pw.print("</a>");
		pw.println(String.format("<td class=\"field\" rmb rmbid=\"%s\" rmbrelid>", reportId));
		pw.print("<a href=\"JavaScript:emxTableColumnLinkClick('..%2Fcommon%2FemxTree.jsp%3FemxSuiteDirectory%3D.%26relId%3Dnull%26parentOID%3Dnull%26jsTreeID%3Dnull%26suiteKey%3DRGN&objectId=");
		pw.print(reportId);
		pw.print("',%20'',%20'',%20'false',%20'content',%20'',%20'");
		pw.print(reportName);
		pw.print("',%20'false',%20'')\" class=\"object\">");
		pw.print(reportName);
		pw.print("</a>");
		pw.println("</td>");
		pw.println("</tr>");
		pw.flush();
	}
	pw.println("</table>");
	pw.flush();
	pw.println("<table>");
	pw.print("<tr><td class=\"label\">");
	pw.print(usingTemplatesNLS);
	pw.println("</td></tr>");
	pw.println("</table>");
	pw.flush();
	MapList usingTemplates = services.getUsingTemplates(context, templateId);
	pw.println("<table>");	
	for (int i = 0; i < usingTemplates.size(); i++) {
		Map<String, String> usingTemplate = (Map<String, String>)usingTemplates.get(i);
		pw.println("<tr>");
		String usingTemplateId = (String)usingTemplate.get("id");
		String usingTemplateName = (String)usingTemplate.get("name");
		pw.println(String.format("<td class=\"field\" rmb rmbid=\"%s\" rmbrelid width=\"20\">", usingTemplateId));
		pw.print("<a href=\"JavaScript:emxTableColumnLinkClick('..%2Fcommon%2FemxTree.jsp%3FemxSuiteDirectory%3D.%26relId%3Dnull%26parentOID%3Dnull%26jsTreeID%3Dnull%26suiteKey%3DRGN&objectId=");
		pw.print(usingTemplateId);
		pw.print("',%20'',%20'',%20'false',%20'content',%20'',%20'");
		pw.print(usingTemplateName);
		pw.print("',%20'false',%20'')\" class=\"object\">");
		pw.print("<img border=\"0\" src=\"images/I_RGNReportTemplate.png\" width=\"22px\">");
		pw.print("</a>");
		pw.println(String.format("<td class=\"field\" rmb rmbid=\"%s\" rmbrelid>", usingTemplateId));
		pw.print("<a href=\"JavaScript:emxTableColumnLinkClick('..%2Fcommon%2FemxTree.jsp%3FemxSuiteDirectory%3D.%26relId%3Dnull%26parentOID%3Dnull%26jsTreeID%3Dnull%26suiteKey%3DRGN&objectId=");
		pw.print(usingTemplateId);
		pw.print("',%20'',%20'',%20'false',%20'content',%20'',%20'");
		pw.print(usingTemplateName);
		pw.print("',%20'false',%20'')\" class=\"object\">");
		pw.print(usingTemplateName);
		pw.print("</a>");
		pw.println("</td>");
		pw.println("</tr>");
		pw.flush();
	}
	pw.println("</table>");
	pw.flush();
	pw.println("<table>");
	pw.print("<tr><td class=\"label\">");
	pw.print(usedTemplatesNLS);
	pw.println("</td></tr>");
	pw.println("</table>");
	pw.flush();
	MapList usedTemplates = services.getUsedTemplates(context, templateId);
	pw.println("<table>");	
	for (int i = 0; i < usedTemplates.size(); i++) {
		Map<String, String> usedTemplate = (Map<String, String>)usedTemplates.get(i);
		pw.println("<tr>");
		String usedTemplateId = (String)usedTemplate.get("id");
		String usedTemplateName = (String)usedTemplate.get("name");
		pw.println(String.format("<td class=\"field\" rmb rmbid=\"%s\" rmbrelid width=\"20\">", usedTemplateId));
		pw.print("<a href=\"JavaScript:emxTableColumnLinkClick('..%2Fcommon%2FemxTree.jsp%3FemxSuiteDirectory%3D.%26relId%3Dnull%26parentOID%3Dnull%26jsTreeID%3Dnull%26suiteKey%3DRGN&objectId=");
		pw.print(usedTemplateId);
		pw.print("',%20'',%20'',%20'false',%20'content',%20'',%20'");
		pw.print(usedTemplateName);
		pw.print("',%20'false',%20'')\" class=\"object\">");
		pw.print("<img border=\"0\" src=\"images/I_RGNReportTemplate.png\" width=\"22px\">");
		pw.print("</a>");
		pw.println(String.format("<td class=\"field\" rmb rmbid=\"%s\" rmbrelid>", usedTemplateId));
		pw.print("<a href=\"JavaScript:emxTableColumnLinkClick('..%2Fcommon%2FemxTree.jsp%3FemxSuiteDirectory%3D.%26relId%3Dnull%26parentOID%3Dnull%26jsTreeID%3Dnull%26suiteKey%3DRGN&objectId=");
		pw.print(usedTemplateId);
		pw.print("',%20'',%20'',%20'false',%20'content',%20'',%20'");
		pw.print(usedTemplateName);
		pw.print("',%20'false',%20'')\" class=\"object\">");
		pw.print(usedTemplateName);
		pw.print("</a>");
		pw.println("</td>");
		pw.println("</tr>");
		pw.flush();
	}
	pw.println("</table>");
	pw.flush();


%>

