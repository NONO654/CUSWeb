
<%@ page import="java.io.PrintWriter"%>
<%@ page import = "java.util.List" %>

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

<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import = "matrix.db.*" %>
<%@ page import = "com.matrixone.apps.domain.*" %>
<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import = "com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil" %>
<%@ page import = "com.dassault_systemes.catrgn.services.util.nls.*"%>
<%@ page import = "com.dassault_systemes.catrgn.i18n.*"%>

<%
	String lang = request.getHeader("Accept-Language");

	//NLS
    String requiredNoticeNLS = i18nNow.getI18nString("emxComponents.Common.RequiredNotice", "emxComponentsStringResource", lang);
	String noConfigutarionRequiredMessage =  i18nNow.getI18nString("emxRGN.Label.NoConfigurationsRequired", "emxRGNStringResource", lang);
	//End NLS

	//SQL Injection protection
	for (String arg : Arrays.asList("contentPageIsDialog", "usepg", "warn", "portalMode", "launched")) {
		if (!emxGetParameter(request, arg).matches("(?i)(true|false)"))
			throw new RuntimeException("invalid parameter: " + arg);
	}
	if (!"emxRGNStringResource".equalsIgnoreCase(emxGetParameter(request, "strfile")))
		throw new RuntimeException("invalid parameter: stfile");
	//End SQL Injection
	
	HashMap<String,String> hiddenFields = new HashMap<String,String>();
	hiddenFields.put("action","none");
	String targetLocation = emxGetParameter(request, "targetLocation");
	if (targetLocation != null && !targetLocation.matches("(?i)(slidein|dialog)"))
		throw new RuntimeException("invalid parameter: targetLocation");
	hiddenFields.put("targetLocation", targetLocation);
	
	String mode = emxGetParameter(request, "mode");
	if (mode != null && !mode.equals("edit"))
		throw new RuntimeException("invalid parameter: mode");
	hiddenFields.put("mode", mode);

	boolean isSlideIn = "slidein".equalsIgnoreCase(targetLocation); 
	String openNewRow = isSlideIn ? "</TR><TR>" : "";
	boolean isEditMode = "edit".equalsIgnoreCase(mode); 

	String objectId = emxGetParameter(request, RGNUtil.REPORT_ID);
	if (objectId != null && !objectId.matches("^[\\w\\.]+$"))
		throw new RuntimeException("invalid parameter: objectId");
	hiddenFields.put(RGNUtil.REPORT_ID, objectId);

	String reportGenerationName = emxGetParameter(request, RGNUtil.REPORT_NAME);
	hiddenFields.put(RGNUtil.REPORT_NAME, reportGenerationName);

	String reportGenerationTitle = emxGetParameter(request, RGNUtil.REPORT_TITLE);
	if(reportGenerationTitle == null) reportGenerationTitle = "";
	hiddenFields.put(RGNUtil.REPORT_TITLE, reportGenerationTitle);

	String reportGenerationDescription = emxGetParameter(request, RGNUtil.REPORT_DESCR);
	if(reportGenerationDescription == null) reportGenerationDescription = "";
	hiddenFields.put(RGNUtil.REPORT_DESCR, reportGenerationDescription);

	String reportModelId = emxGetParameter(request,RGNUtil.REPORT_MODEL_ID);
	hiddenFields.put(RGNUtil.REPORT_MODEL_ID, reportModelId);

	String reportTemplateId = emxGetParameter(request,RGNUtil.REPORT_TEMPLATE_ID);
	hiddenFields.put(RGNUtil.REPORT_TEMPLATE_ID, reportTemplateId);

	String targetDocumentId = emxGetParameter(request,RGNUtil.TARGET_DOCUMENT_ID);
	hiddenFields.put(RGNUtil.TARGET_DOCUMENT_ID, targetDocumentId);
	
	String nbInputsStr = emxGetParameter(request,RGNUtil.REPORT_NB_INPUTS);
	Integer nbInputs = 0;	
	if(nbInputsStr != null) nbInputs = Integer.valueOf(nbInputsStr);

	HashSet<String> inputOIDSet = new HashSet<String>();
	for(int i = 0; i < nbInputs; i++) {
		String oid = emxGetParameter(request,RGNUtil.InputId(i));
		String value = emxGetParameter(request,RGNUtil.InputValue(i));
		if (oid != null && !oid.isEmpty()) inputOIDSet.addAll(Arrays.asList(oid.split("\\|")));
		hiddenFields.put(RGNUtil.InputId(i), oid);
		hiddenFields.put(RGNUtil.InputValue(i), value);
		hiddenFields.put(RGNUtil.InputType(i), emxGetParameter(request, RGNUtil.InputType(i)));
		hiddenFields.put(RGNUtil.InputName(i), emxGetParameter(request,RGNUtil.InputName(i)));
	}
	
	String[] inputOIDs = new String[inputOIDSet.size()];
	inputOIDSet.toArray(inputOIDs);
	String configInitValue = null;
	Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	String role = (String) context.getRole();
	List<String> configurations = null;
	if (role != null && (!role.equals("null") || !role.equals("")|| !role.equals(" "))) {
		configurations = CATRgnReportServices.getConfigurationsOfInput(context, inputOIDs);
	};
	
	hiddenFields.put(RGNUtil.REPORT_NB_INPUTS, String.valueOf(nbInputs));
	String configId = emxGetParameter(request,RGNUtil.REPORT_CONFIG_ID);
    hiddenFields.put(RGNUtil.REPORT_CONFIG_ID, configId);


%>

<script language="Javascript">
	function cancelForm() {
	    if(<%=XSSUtil.encodeForJavaScript(context, String.valueOf(isSlideIn))%>)
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
		findFrame(getTopWindow(),"slideInFrame").document.getElementById("divPageFoot").getElementsByClassName("btn-primary")[0].setAttribute("disabled", "true");
		document.editForm.action.value = "terminate";
		document.editForm.submit();
	}

</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>


<BODY class="slide-in-panel">
	<form name="editForm" method="post"
		onsubmit="submitForm(); return false"
		action="emxCATRgnReportCreate.jsp">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<% for (String key : hiddenFields.keySet()) { %>
			<input type="hidden" name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>" value="<%=XSSUtil.encodeForHTMLAttribute(context, hiddenFields.get(key))%>"/>
		<% } %>
		<table class="form">
			<tbody>
			<tr><td class="createRequiredNotice"><%=XSSUtil.encodeForHTML(context, requiredNoticeNLS)%></td></tr>
			<% if ( configurations == null) { %>
				<tr><td><%=XSSUtil.encodeForHTML(context, noConfigutarionRequiredMessage)%></td></tr>
			<% } else { %>
				<tr>
					<td class="label">
						<label for="configId"><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxRGN.Label.ConfigurationFilters", "emxRGNStringResource",lang))%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<select id="configId" name="configId">
							<option value="none"
								<% if(null==configId) { %>
									selected
								<% } %>
							><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxRGN.Label.NoConfigurationFilter", "emxRGNStringResource",lang))%></option>
	<%			            for(String aConfigID : configurations) { %>
								<option	value="<%=XSSUtil.encodeForHTMLAttribute(context, aConfigID)%>"
									<% if (aConfigID.equalsIgnoreCase(configId)) { %>
										selected
									<% } %>
									><%=XSSUtil.encodeForHTML(context, RGNUtil.mqlGetBusDisplayName(context, aConfigID))%></option>
	<%			            } %>
						</select>
					</td>
				</tr>
			<%
			}; 
			%>
			</tbody>
		</table>
	</form>
</Body>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>
