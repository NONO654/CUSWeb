
<%@page import="com.dassault_systemes.catrgn.pervasive.server.RequestNfo"%>
<%@page import="com.dassault_systemes.catrgn.i18n.I18nContext"%>
<%@page import="com.dassault_systemes.catrgn.i18n.I18nUtil"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import = "com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil" %>
<%@ page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.*" %>
<%@ page import = "com.dassault_systemes.catrgn.services.util.nls.*" %>

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
<script type="text/javascript" src="./scripts/emxRGNScript.js"></script>


<%
	
	//Start NLS
	

	String lang = request.getHeader("Accept-Language");
	RequestNfo reqInfo = RGNUtil.createRequestFromContext(context, lang);
	I18nContext i18nCtx = new I18nServerContext(reqInfo);
 	String autoNameLabel = i18nNow.getI18nString("emxComponents.Common.AutoName", "emxComponentsStringResource", lang);
    String requiredNoticeNLS = i18nNow.getI18nString("emxComponents.Common.RequiredNotice", "emxComponentsStringResource", lang);
	String nameLabel = I18nUtil.STR_NAME.get(i18nCtx);
	String titleLabel = I18nUtil.STR_TITLE.get(i18nCtx);
	String descrLabel = I18nUtil.STR_DESCRIPTION.get(i18nCtx);
	String reportModelLabel = I18nUtil.STR_REPORT_MODEL.get(i18nCtx);
	String reportTemplateLabel = I18nUtil.STR_REPORT_TEMPLATE.get(i18nCtx);
	String targetDocumentLabel = I18nUtil.STR_TARGET_DOCUMENT.get(i18nCtx);
	String enterReportNameAlert = I18nUtil.STR_ENTER_REPORT_NAME.get(i18nCtx);
	String fillReportModelAlert = I18nUtil.STR_FILL_REPORT_MODEL.get(i18nCtx);
	String fillReportTemplateAlert = I18nUtil.STR_FILL_REPORT_TEMPLATE.get(i18nCtx);
	String newReportAlert = I18nUtil.STR_NEW_REPORT.get(i18nCtx);
	String invalidNameAlert = I18nUtil.STR_INVALID_NAME.get(i18nCtx);
	String clearNLS = I18nUtil.STR_CLEAR.get(i18nCtx);
	String cancelNLS= I18nUtil.STR_CANCEL.get(i18nCtx);
	String searchI18n = I18nUtil.STR_SEARCH.get(i18nCtx);
	String invalidCharacters = I18nUtil.STR_INVALID_SEARCH.get(i18nCtx);
	// End NLS
	
	// Get Input Parameters	
	String targetLocation = emxGetParameter(request, "targetLocation");
	String mode = emxGetParameter(request, "mode");
	String objectId = emxGetParameter(request, RGNUtil.REPORT_ID);
	// End Input Parameters

	//SQL Injection protection
	if (targetLocation != null && !targetLocation.matches("(?i)(slidein|dialog)"))
		throw new RuntimeException("invalid parameter: targetLocation");
	if (mode != null && !mode.equals("edit"))
		throw new RuntimeException("invalid parameter: mode");
	if (objectId != null && !objectId.matches("^[\\w\\.]+$"))
		throw new RuntimeException("invalid parameter: objectId");
	for (String arg : Arrays.asList("contentPageIsDialog", "usepg", "warn", "portalMode", "launched")) {
		if (!emxGetParameter(request, arg).matches("(?i)(true|false)"))
			throw new RuntimeException("invalid parameter: " + arg);
	}
	if (!"emxRGNStringResource".equalsIgnoreCase(emxGetParameter(request, "strfile")))
		throw new RuntimeException("invalid parameter: stfile");
	//End SQL Injection

	String checkAutoName = "";
	boolean isSlideIn = "slidein".equalsIgnoreCase(targetLocation); 
	String openNewRow = isSlideIn ? "</TR><TR>" : "";
	boolean isEditMode = "edit".equalsIgnoreCase(mode);
	CATRgnIReport reportWithInputs = null;
	String reportGenerationName = null;
	String reportGenerationTitle = null;
	String reportGenerationDescription = null;
	String reportError = null;
	Map<String, Object> reportMap = Collections.emptyMap();		
	String reportModelID = null;
	String reportModelName = null;
	String reportModelDisplay = null;
	String reportTemplateID = null;
	String reportTemplateName = null;
	String reportTemplateDisplay = null;
	String configId = null;
	String targetDocumentID = null;
	String targetDocumentName = null;

	if (isEditMode && objectId != null) {
		//Fix IR-324070-3DEXPERIENCER2015x
		if (objectId.startsWith("|")) objectId = objectId.substring(1, objectId.indexOf("|", 1));
        Map<Object, Object> requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
		String role = (String) context.getRole();
		if (role != null && (!role.equals("null") || !role.equals("")|| !role.equals(" "))) {
			try{
				CATRgnReportServices services = new CATRgnReportServices(context, lang);
				reportWithInputs = services.getReportWithInputs(objectId);
				reportMap = services.getMapInfo(reportWithInputs);
				reportGenerationName = reportWithInputs.getName();
				reportGenerationTitle = reportWithInputs.getTitle();
				reportGenerationDescription = reportWithInputs.getDescription();
				reportModelID = reportWithInputs.getModelId();
				reportModelName = reportWithInputs.getModelName();
				reportModelDisplay = reportWithInputs.getModelTitle();
				if (reportModelDisplay == null) reportModelDisplay = reportModelName;
				reportTemplateID = reportWithInputs.getTemplateId();
				reportTemplateName = reportWithInputs.getTemplateName();
				reportTemplateDisplay = reportWithInputs.getTemplateTitle();
				if (reportTemplateDisplay == null) reportTemplateDisplay = reportTemplateName;
				configId = reportWithInputs.getConfigurationId();
				targetDocumentID = reportWithInputs.getGeneratedDocumentId();
				targetDocumentName = reportWithInputs.getGeneratedDocumentName();
			} catch (RuntimeException e) {
				reportError = e.getMessage();
			}

		}
	} 
	
	java.util.Set<String> inputNames = reportMap.keySet();

%>

<script language="Javascript">
	function cancelForm() {
	    if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(isSlideIn))%>)
		{
	    	getTopWindow().closeSlideInDialog();
			var contentFrame = findFrame(getTopWindow(), "content");
	    	contentFrame.document.location.href = contentFrame.document.location.href;
		}
	    else	
		{
			parent.window.opener.document.location = parent.window.opener.document.location;
			parent.window.close();
		}
	}

	function submitForm() {
		var autonameChecked = document.editForm.checkAutoName.checked;
		var nameValue = document.editForm.reportNameField.value;
		var reportModelOID = document.editForm.reportmodelOID.value;
		var reportTemplateOID = document.editForm.reporttemplateOID.value;
		//is nameValue empty?
		if (!autonameChecked && trimWhitespace(nameValue).length == 0) {
			alert("<%=XSSUtil.encodeForJavaScript(context,  enterReportNameAlert )%>");
			return;
		}

		var nameCheckValue = checkForNameBadChars(nameValue, false);
		var descCheckValue = checkForBadChars(document.editForm.reportDescriptionField);

		//validate that all required fields are entered
		if (!autonameChecked && (nameValue == null || nameValue == "")) {
			alert("<%=XSSUtil.encodeForJavaScript(context,  newReportAlert )%>");
			document.editForm.reportNameField.focus();
			return;
		} else if (charExists(nameValue, '"') || charExists(nameValue, '#')
				|| (nameCheckValue == false)) {
			alert("<%=XSSUtil.encodeForJavaScript(context,  invalidNameAlert )%>");
			document.editForm.reportNameField.focus();
			return;
		} else if (descCheckValue.length != 0) {
			alert("<%=XSSUtil.encodeForJavaScript(context,  invalidCharacters )%>"
					+ descCheckValue
					+ "<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
			document.editForm.reportDescriptionField.focus();
			return;
		} else if (reportModelOID == null || reportModelOID == "") {
			alert("<%=XSSUtil.encodeForJavaScript(context,  fillReportModelAlert )%>");
			return;
		} else if (reportTemplateOID == null || reportTemplateOID == "") {
			alert("<%=XSSUtil.encodeForJavaScript(context,  fillReportTemplateAlert )%>");
			return;
		} else {
			findFrame(getTopWindow(),"slideInFrame").document.getElementById("divPageFoot").getElementsByClassName("btn-primary")[0].setAttribute("disabled", "true");
			document.editForm.submit();
		}
	}
	
	function takeFocus() {
		var nameDisabled = document.editForm.reportNameField.disabled;
		if (nameDisabled) {
			document.editForm.reportDescriptionField.focus();
		} else {
			document.editForm.reportNameField.focus();
		}
	}
	
	function switchAutoName() {
		var autonameChecked = document.editForm.checkAutoName.checked;
		if (autonameChecked) {
			document.editForm.reportNameField.value = "";
			document.editForm.reportNameField.disabled = true;
		} else {
			document.editForm.reportNameField.disabled = false;
			document.editForm.reportNameField.focus();
		}
	}

</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>


<BODY OnLoad="takeFocus();rgnUpdateCreateForm();" class="slide-in-panel">
	<form name="editForm" method="post"
		onsubmit="submitForm(); return false"
		action="emxCATRgnReportCreate.jsp">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<input type="hidden" name="fromDialog" value="CreateDialog">
<% if (reportError ==null) { %>
	<% if (isSlideIn){ %>	
		<input name="targetLocation" value="<%=XSSUtil.encodeForHTMLAttribute(context, targetLocation)%>" type="hidden"/>
	<% } %>
	<% if (isEditMode){ %>	
		<input name="mode" value="<%=XSSUtil.encodeForHTMLAttribute(context, mode)%>" type="hidden"/>
	<% } %>	
	<% if (objectId != null){ %>	
		<input name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context, objectId)%>" type="hidden"/>
	<% } %>
	<% if (configId != null){ %>
		<input name="configId" value="<%=XSSUtil.encodeForHTMLAttribute(context, configId)%>" type="hidden"/>
	<% } %>
	<%
		for(String name : inputNames) {
			String value = (String)reportMap.get(name);
			if ( value != null )
	%>
		<input name="<%=XSSUtil.encodeForHTMLAttribute(context, name)%>" value="<%=XSSUtil.encodeForHTMLAttribute(context, value)%>" type="hidden"/>
	<% } %>	
		<table class="form">
			<tbody>
				<tr><td class="createRequiredNotice"><%=XSSUtil.encodeForHTML(context, requiredNoticeNLS)%></td></tr>
				<tr>
					<td class="createLabelRequired">
						<label for="reportNameField"><%=XSSUtil.encodeForHTML(context,  nameLabel )%></label>
					</td>
				</tr>
				<tr>
					<td class="inputField">
						<input type="text" id="reportNameField" name="reportNameField" value="<% if (reportGenerationName != null) { %><%=XSSUtil.encodeForHTMLAttribute(context, reportGenerationName)%><% }; %>"
							size="25" onFocus="this.select()"/>	
					<% if (checkAutoName.equals("on")) {%>
						<input <% if (isEditMode) { %>type="hidden"<% } else { %>type="checkbox"<%} %> name="checkAutoName" onClick="switchAutoName()" checked />
					<%} else {%>
						<input <% if (isEditMode) { %>type="hidden"<% } else { %>type="checkbox"<%} %> name="checkAutoName" onClick="switchAutoName()" />
					<%}%>
					<% if (!isEditMode) { %>
						<label><%=XSSUtil.encodeForHTML(context,  autoNameLabel )%></label>
					<% } %>		
					</td>
				</tr>
				<!--Title Field -->
				<tr>
					<td class="label">
						<label  for="reportTitleField"><%=XSSUtil.encodeForHTML(context,  titleLabel )%></label>
					</td>
				</tr>
				<tr>
					<td  class="field">
						<input type="text" id="reportTitleField" name="reportTitleField" size="20" value="<% if (reportGenerationTitle != null){ %><%=XSSUtil.encodeForHTMLAttribute(context, reportGenerationTitle)%><% }; %>"/>
					</td>
				</tr>
				<!--Description Field -->
				<tr>
					<td class="label">
						<label for="reportDescriptionField"><%=XSSUtil.encodeForHTML(context,  descrLabel )%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<textarea cols="25" rows="5" id="reportDescriptionField" name="reportDescriptionField" onFocus="this.select()"><% if (reportGenerationDescription != null){ %><%=XSSUtil.encodeForHTML(context, reportGenerationDescription)%><% }; %></textarea>
					</td>
				</tr>
				<tr>
					<td class="labelRequired">
						<label for="reportmodel"><%=XSSUtil.encodeForHTML(context, reportModelLabel)%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<input id="reportmodel" name="reportmodel" type="hidden" value="" />
						<input id="reportmodelDisplay" name="reportmodelDisplay" size="25" type="text"
							placeholder="<%=XSSUtil.encodeForHTMLAttribute(context, searchI18n)%>" 
							value="<%if (reportModelDisplay != null)%><%=XSSUtil.encodeForHTMLAttribute(context, reportModelDisplay)%>"/>
						<input id="reportmodelOID" name="reportmodelOID" type="hidden"
							value="<%if (reportModelID != null) %><%=XSSUtil.encodeForHTMLAttribute(context, reportModelID)%>"/>
						<input id="reportmodelBtn" name="reportmodelBtn" type="button"
							onclick="rgnFullSearch('RGNReportModelSearchList', 'type_ReportModel', '*', '<%=XSSUtil.encodeForJavaScript(context, cancelNLS)%>', 'reportmodel', '<%=XSSUtil.encodeForJavaScript(context, invalidCharacters)%>')"
							value="..."/>
						<a onclick="clearField('reportmodel')"><%=XSSUtil.encodeForHTML(context, clearNLS)%></a>
					</td>
				</tr>
				<tr>
					<td class="labelRequired">
						<label for="reporttemplate"><%=XSSUtil.encodeForHTML(context, reportTemplateLabel)%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<input id="reporttemplate" name="reporttemplate" type="hidden" value="" />
						<input id="reporttemplateDisplay" name="reporttemplateDisplay" size="25" type="text" placeholder="<%=XSSUtil.encodeForHTMLAttribute(context, searchI18n)%>" 
							value="<%if (reportTemplateDisplay != null) %><%=XSSUtil.encodeForHTMLAttribute(context, reportTemplateDisplay)%>"/>
						<input id="reporttemplateOID" name="reporttemplateOID" type="hidden"
							value="<%if (reportTemplateID != null) %><%=XSSUtil.encodeForHTMLAttribute(context, reportTemplateID)%>"/>
						<input id="reporttemplateBtn" name="reporttemplateBtn" type="button"
							onclick="rgnFullSearch('RGNReportTemplateSearchList', 'type_ReportTemplate', '*', '<%=XSSUtil.encodeForJavaScript(context, cancelNLS)%>', 'reporttemplate', '<%=XSSUtil.encodeForJavaScript(context, invalidCharacters)%>')"
							value="..."/>
						<a onclick="clearField('reporttemplate')"><%=XSSUtil.encodeForHTML(context, clearNLS)%></a>
					</td>
				</tr>
				<tr>
					<td class="label">
						<label for="targetDocument"><%=XSSUtil.encodeForHTML(context, targetDocumentLabel)%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<input id="targetDocument" name="targetDocument" type="hidden" value="" />
						<input id="targetDocumentDisplay" name="targetDocumentDisplay" size="25" type="text" placeholder="<%=XSSUtil.encodeForHTMLAttribute(context, searchI18n)%>" 
							value="<%if (targetDocumentName != null) %><%=XSSUtil.encodeForHTMLAttribute(context, targetDocumentName)%>"/>
						<input id="targetDocumentOID" name="targetDocumentOID" type="hidden"
							value="<%if (targetDocumentID != null) %><%=XSSUtil.encodeForHTMLAttribute(context, targetDocumentID)%>"/>
						<input id="targetDocumentBtn" name="targetDocumentBtn" type="button"
							onclick="rgnFullSearch('AEFGeneralSearchResults', 'type_DOCUMENTS', '*', '<%=XSSUtil.encodeForJavaScript(context, cancelNLS)%>', 'targetDocument', '<%=XSSUtil.encodeForJavaScript(context, invalidCharacters)%>')"
							value="..."/>
						<a onclick="clearField('targetDocument')"><%=XSSUtil.encodeForHTML(context, clearNLS)%></a>
					</td>
				</tr>
			</tbody>
		</table>
<% } else { %>
	<%=XSSUtil.encodeForHTML(context,  reportError )%>
<% } %>
	</form>
</Body>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>
