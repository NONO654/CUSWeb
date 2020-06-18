
<%@page import="java.util.stream.Collectors"%>
<%@page import="java.util.Arrays"%>
<%@page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.CATRgnIReportTemplate.TemplateParameter"%>
<%@ page import="java.io.PrintWriter"%>

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

<!--<script type="text/javascript" src="../common/scripts/emxUIJson.js"></script>-->

<script type="text/javascript" src="../common/scripts/emxQuery.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIFormHandler.js"></script>

<script type="text/javascript" src="./scripts/emxRGNScript.js"></script>
<script type="text/javascript" src="./scripts/emxRGNInputParams.js"></script>

<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import = "matrix.db.*" %>
<%@ page import = "com.matrixone.apps.domain.*" %>
<%@ page import = "com.dassault_systemes.catrgn.pervasive.server.RequestNfo"%>
<%@ page import = "com.dassault_systemes.catrgn.i18n.I18nContext"%>
<%@ page import = "com.dassault_systemes.catrgn.i18n.I18nUtil"%>
<%@ page import = "com.dassault_systemes.catrgn.report.datamodel.Type"%>
<%@ page import = "com.dassault_systemes.catrgn.connector.utils.DataModelServices" %>
<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import = "com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil" %>
<%@ page import = "com.dassault_systemes.catrgn.services.util.nls.*" %>
<%@ page import = "com.dassault_systemes.catrgn.otscript.i18nSupport.impl.GwtI18nSupport" %>
<%@ page import = "com.dassault_systemes.catrgn.constants.SystemReportGenerationConstants" %>

<%
	String lang = request.getHeader("Accept-Language");
	
	//NLS
	RequestNfo reqInfo = CATRgnReportServices.getRequestInfo(context, request);
	I18nContext i18nCtx = new I18nServerContext(reqInfo);
	
    String requiredNoticeNLS = i18nNow.getI18nString("emxComponents.Common.RequiredNotice", "emxComponentsStringResource", lang);
	String unfilledParametersAlert = I18nUtil.STR_EMPTY_PARAMETERS.get(i18nCtx);
	String noParameterRequiredMessage= I18nUtil.STR_NO_PARAMETER_REQUIRED.get(i18nCtx);
	String cancelNLS= I18nUtil.STR_CANCEL.get(i18nCtx);
	String clearNLS = I18nUtil.STR_CLEAR.get(i18nCtx);
	
	//END NLS

	//SQL Injection protection
	for (String arg : Arrays.asList("contentPageIsDialog", "usepg", "warn", "portalMode", "launched")) {
		if (!emxGetParameter(request, arg).matches("(?i)(true|false)"))
			response.sendError(500, "invalid parameter: " + arg);
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
	TemplateParameter[] params = CATRgnReportServices.getTemplateRepresentation(context, reportModelId).getParameters();

	String reportTemplateId = emxGetParameter(request,RGNUtil.REPORT_TEMPLATE_ID);
	hiddenFields.put(RGNUtil.REPORT_TEMPLATE_ID, reportTemplateId);
	

	String targetDocumentId = emxGetParameter(request,RGNUtil.TARGET_DOCUMENT_ID);
	hiddenFields.put(RGNUtil.TARGET_DOCUMENT_ID, targetDocumentId);

	String configId = emxGetParameter(request,RGNUtil.REPORT_CONFIG_ID);
    hiddenFields.put(RGNUtil.REPORT_CONFIG_ID, configId);

	String nbInputsStr = emxGetParameter(request,RGNUtil.REPORT_NB_INPUTS);
	hiddenFields.put(RGNUtil.REPORT_NB_INPUTS, nbInputsStr);
	int nbInputs = nbInputsStr == null ? 0 : Integer.valueOf(nbInputsStr);
	HashMap<String, String> inputTypesInitValues = new HashMap<String, String>();
	for(int i = 0; i < nbInputs; i++) {
		String fieldName = RGNUtil.InputId(i);
		inputTypesInitValues.put(fieldName, emxGetParameter(request, fieldName));
		fieldName = RGNUtil.InputName(i);
		inputTypesInitValues.put(fieldName, emxGetParameter(request, fieldName));
		fieldName = RGNUtil.InputType(i);
		inputTypesInitValues.put(fieldName, emxGetParameter(request, fieldName));
		fieldName = RGNUtil.InputValue(i);
		inputTypesInitValues.put(fieldName, emxGetParameter(request, fieldName));
	}

%>

<head>
 	<script src="../webapps/AmdLoader/AmdLoader.js"></script>
 	<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>
	<link rel="stylesheet" href="../webapps/UIKIT/UIKIT.css"/>
	<script src="../webapps/UIKIT/UIKIT.js"></script>
	<link rel="stylesheet" href="./styles/emxRGNStyle.css"/>
</head>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<BODY class="slide-in-panel" onload="rgnUpdateCreateParamForm(<%=XSSUtil.encodeForJavaScript(context,  String.valueOf(nbInputs) )%>);">
	<form name="editForm" method="post"
		onsubmit="submitForm(); return false"
		action="emxCATRgnReportCreate.jsp">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<% for(String key : hiddenFields.keySet()) { %>
				<input type="hidden" name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>" value="<%=XSSUtil.encodeForHTMLAttribute(context, hiddenFields.get(key))%>"/>
		<% } %>
		<input type="hidden" name="fromDialog" value="ParamsDialog">
		<table class="form">
			<tbody>
				<tr><td class="createRequiredNotice"><%=XSSUtil.encodeForHTML(context, requiredNoticeNLS)%></td></tr>
				<% if( nbInputs == 0) { %>
				<tr><td><%=XSSUtil.encodeForHTML(context, noParameterRequiredMessage)%></td></tr>
				<% } else { 
					for(int i = 0; i< nbInputs; i++) {
						String key = RGNUtil.InputValue(i);
						String inputDisplayName = inputTypesInitValues.get(RGNUtil.InputName(i));
						//String inputLabel = inputTypeVars[1];
						//if (inputLabel != null && ! inputLabel.isEmpty()) inputDisplayName = inputLabel;
						String typeQName = inputTypesInitValues.get(RGNUtil.InputType(i));
						Type type = DataModelServices.getTypeNamed(reqInfo, typeQName);
						boolean isTerminalType = type.isTerminal();
						String[] inputTypeFullName = typeQName.split("\\.");
						String typeName = inputTypeFullName[inputTypeFullName.length-1];
						boolean isRelationshipType = typeName.startsWith("rel_");
						boolean isMQLSearchType = isRelationshipType 
													|| (SystemReportGenerationConstants.RGN_BUNDLE.containsKey(SystemReportGenerationConstants.MQL_SEARCH_TYPES)
															&& Arrays.asList(SystemReportGenerationConstants.RGN_BUNDLE.getString(SystemReportGenerationConstants.MQL_SEARCH_TYPES).split("\\s*,\\s*")).contains(typeName));
						String searchTable = "AEFGeneralSearchResults";
						String typeNameI18n;
						if (isRelationshipType) {
							typeName = typeName.substring(4);
							typeNameI18n = I18nUtil.FSTR_INPUT_PARAMETER_RELATIONSHIP(I18nUtil.getFrameworkRelationshipNLS(typeName)).get(i18nCtx);
						} else
							typeNameI18n = I18nUtil.getFrameworkTypeNLS(typeName).get(i18nCtx);
						String browseI18n = I18nUtil.STR_BROWSE.get(i18nCtx);
						String resetI18n = I18nUtil.STR_RESET.get(i18nCtx);
						String searchI18n = I18nUtil.STR_SEARCH.get(i18nCtx);
						String selectDataI18n = I18nUtil.STR_SELECT_DATA.get(i18nCtx);
						String invalidCharacters = I18nUtil.STR_INVALID_SEARCH.get(i18nCtx);
						String initParam = (String)inputTypesInitValues.get(RGNUtil.InputId(i));
						if (initParam == null) initParam = "";
						String initParamName = (String)inputTypesInitValues.get(RGNUtil.InputName(i));
						if (initParamName == null) initParamName = "";
						String initParamValue = (String)inputTypesInitValues.get(RGNUtil.InputValue(i));
						if (initParamValue == null) initParamValue = "";
						String initParamType = (String)inputTypesInitValues.get(RGNUtil.InputType(i));
						if (initParamType == null) initParamType = "";
						int cardinality = params[i].getCardinality();
				%>
				<tr>
				<%		if (cardinality == 0) { %>
					<td class="labelRequired">
				<% 		} else  { %>
					<td class="label">
				<% 		} %>
						<label for="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>"><%=XSSUtil.encodeForHTML(context, typeNameI18n)%>: <%=XSSUtil.encodeForHTML(context, inputDisplayName)%></label>
					</td>
                </tr>
				<tr>
                    <td class="field">
							<input 
								id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>"
								name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>" 
								type="hidden"
								value="<%=XSSUtil.encodeForHTMLAttribute(context, initParamValue)%>"/>
							<input 
								id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Name" 
								name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Name" 
								type="hidden"
								value="<%=XSSUtil.encodeForHTMLAttribute(context, initParamName)%>"/>
							<input 
								id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Type" 
								name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Type" 
								type="hidden"
								value="<%=XSSUtil.encodeForHTMLAttribute(context, typeQName)%>"/>
							<input 
								id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>OID" 
								name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>OID" 
								type="hidden"
								value="<%=XSSUtil.encodeForHTMLAttribute(context, initParam)%>"/>
							<% if (isMQLSearchType) { %>
                                <div 
									id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>ResultDiv" 
									title="<%=XSSUtil.encodeForHTMLAttribute(context, searchI18n)%>">
                                 	<input 
										id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Display"  
										name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Display"
										size="25" type="text"
										placeholder="<%=XSSUtil.encodeForHTMLAttribute(context, searchI18n)%>"
										value="<%=XSSUtil.encodeForHTMLAttribute(context, initParamValue)%>"
										title="<%=XSSUtil.encodeForHTMLAttribute(context, initParamValue)%>"
										onchange="clearOID('<%=XSSUtil.encodeForHTMLAttribute(context, key)%>')"/>
								    <a 
										onclick="javascript:queryInputs('<%=XSSUtil.encodeForJavaScript(context, key)%>', <%=XSSUtil.encodeForJavaScript(context, String.valueOf(cardinality))%>, addSelect, '<%=XSSUtil.encodeForJavaScript(context, selectDataI18n)%>')"
										type="button" 
										id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Btn" 
										name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Btn" >
                                        <img src="../rgn/images/iconActionNewSearch.png" width="20px"/>
                                    </a>
									<a 
										onclick="clearField('<%=XSSUtil.encodeForJavaScript(context, key)%>')">
										<%=XSSUtil.encodeForHTML(context, clearNLS)%>
									</a>
                                </div>
                            	<div
									id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>SelectDiv" 
									title="<%=XSSUtil.encodeForHTMLAttribute(context, resetI18n)%>" 
									hidden>
                                </div>
							<% } else { %>
                                <input id="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Display"
									name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Display"
									size="25" type="text" 
									placeholder="<%=XSSUtil.encodeForHTMLAttribute(context, searchI18n)%>" 
									value="<%=XSSUtil.encodeForHTMLAttribute(context, initParamValue)%>"
									<% if (isTerminalType) { %> 
										oninput="updateTerminalInputFields('<%=XSSUtil.encodeForJavaScript(context, key)%>')"
									<% } %>
									/>
								<% if (!isTerminalType) { %>
									<input name="<%=XSSUtil.encodeForHTMLAttribute(context, key)%>Btn" type="button"
										title="<%=XSSUtil.encodeForHTMLAttribute(context, browseI18n)%>"
										onclick="rgnFullSearch('<%=XSSUtil.encodeForJavaScript(context, searchTable)%>',
													'<%=XSSUtil.encodeForJavaScript(context, typeName)%>',
													'*',
													'<%=XSSUtil.encodeForJavaScript(context, cancelNLS)%>',
													'<%=XSSUtil.encodeForJavaScript(context, key)%>',
													'<%=XSSUtil.encodeForJavaScript(context, invalidCharacters)%>',
													'<%=XSSUtil.encodeForJavaScript(context, String.valueOf(cardinality))%>')"
										value="..."/>
									<a onclick="clearField('<%=XSSUtil.encodeForJavaScript(context, key)%>')"><%=XSSUtil.encodeForHTML(context, clearNLS)%></a>
								<% } %>
							<% } %>
						</td>
					</tr>
		<%
				};
		 }; %>
			</tbody>
		</table>
	</form>
	<script>
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

		function basicSubmitForm() {
			var paramsOK = <%=XSSUtil.encodeForJavaScript(context, String.valueOf(nbInputs) )%>;
		<%	for (int i = 0; i<nbInputs; i++) { %>	
				var paramOID = document.editForm.input<%=XSSUtil.encodeForJavaScript(context, String.valueOf(i))%>OID.value,
					paramValue = document.editForm.input<%=XSSUtil.encodeForJavaScript(context, String.valueOf(i))%>.value,
					labelClassName = document.editForm.querySelector('label[for="input<%=XSSUtil.encodeForJavaScript(context, String.valueOf(i))%>"]').parentNode.getAttribute("class");
				if (('label' === labelClassName) || (paramOID != null && paramOID != "") || (paramValue != null && paramValue != "")) paramsOK -= 1;
		<%	} %>
			if (paramsOK == 0) {
				document.editForm.submit();
			} else {
				findFrame(getTopWindow(),"slideInFrame").document.getElementById("divPageFoot").getElementsByClassName("btn-default")[0].removeAttribute("disabled");
				alert("<%=XSSUtil.encodeForJavaScript(context,  unfilledParametersAlert )%>")
			}
		}
	</script>
</Body>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>
