
<%@page import="java.util.HashMap"%>
<%@page import="com.dassault_systemes.catrgn.i18n.I18nUtil"%>
<%@page import="com.dassault_systemes.catrgn.i18n.I18nContext"%>
<%@page import="com.dassault_systemes.catrgn.pervasive.server.RequestNfo"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import = "com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil" %>
<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.interfaces.*" %>
<%@ page import = "com.dassault_systemes.catrgn.pervasive.parsing.tcl.TclArray"%>
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



<%
   //Implement TSK2223567
   //NLS

   String lang = request.getHeader("Accept-Language");
   CATRgnReportServices services = new CATRgnReportServices(context, request);
   I18nContext i18nCtx = new I18nServerContext(services.requestInfo);
   String autoNameLabel = i18nNow.getI18nString("emxComponents.Common.AutoName", "emxComponentsStringResource", lang);
   String requiredNoticeNLS = i18nNow.getI18nString("emxComponents.Common.RequiredNotice", "emxComponentsStringResource", lang);
   String nameLabel = I18nUtil.STR_NAME.get(i18nCtx);
   String titleLabel = I18nUtil.STR_TITLE.get(i18nCtx);
   String descrLabel = I18nUtil.STR_DESCRIPTION.get(i18nCtx);
   String outputFileLabel = I18nUtil.STR_OUTPUT_FORMAT_FILE.get(i18nCtx);
   String outputFormatPolicyLabel = I18nUtil.STR_POLICY.get(i18nCtx);
   String cancelNLS= I18nUtil.STR_CANCEL.get(i18nCtx);
   String enterNameAlert = I18nUtil.STR_ENTER_NAME.get(i18nCtx);
   String enterTitleAlert = I18nUtil.STR_ENTER_TITLE.get(i18nCtx);
   String newReportAlert = I18nUtil.STR_NEW_REPORT.get(i18nCtx);
   String invalidNameAlert = I18nUtil.STR_INVALID_NAME.get(i18nCtx);
   String invalidCharsAlert = I18nUtil.STR_INVALID_CHARS.get(i18nCtx);
	
   // END NLS
   // Get Input Parameters
   
   String targetLocation = emxGetParameter(request, "targetLocation");
   String mode = emxGetParameter(request, "mode");
   String objectId = emxGetParameter(request, "outputFormatId");
	
   // End Input Parameters

	//SQL Injection protection
//	if (targetLocation != null && !targetLocation.matches("(?i)(slidein|dialog)"))
//		throw new RuntimeException("invalid parameter: targetLocation");
//	if (mode != null && !mode.equals("edit"))
//		throw new RuntimeException("invalid parameter: mode");
//	if (objectId != null && !objectId.matches("^[\\w\\.]+$"))
//		throw new RuntimeException("invalid parameter: objectId");
	
	for (String arg : Arrays.asList("contentPageIsDialog", "usepg", "warn", "portalMode", "launched")) {
		String val = emxGetParameter(request, arg);
		if (val != null && !val.matches("(?i)(true|false)"))
			throw new RuntimeException("invalid parameter: " + arg);
	}
	//End SQL Injection
   
   String checkAutoName = "";
   boolean isSlideIn = "slidein".equalsIgnoreCase(targetLocation); 
   String openNewRow = isSlideIn ? "</TR><TR>" : "";
   boolean isEditMode = "edit".equalsIgnoreCase(mode);
   String outputFormatName = emxGetParameter(request, "outputFormatNameField");
   String outputFormatTemplate = emxGetParameter(request, "outputFormatTitleField");
   String outputFormatDescription = emxGetParameter(request, "outputFormatDescriptionField");
   Map requestMap = UINavigatorUtil.getRequestParameterMap(request);
   String toolbarName = (String)requestMap.get("toolbar");
   String[] outputFormats = services.getLibraryOutputFormats();
   String[] outputFormatPolicies = RGNUtil.MqlPrintTypeSelects(context, "Report Template", "policy");
   String[] outputFormatPoliciesHidden = RGNUtil.MqlPrintTypeSelects(context, "Report Template", "policy.hidden");
   Map<String, String> policiesNLS = new HashMap<String, String>();
   for (int i = 0; i < outputFormatPolicies.length; i++) {
	   if ("false".equalsIgnoreCase(outputFormatPoliciesHidden[i]))
		   policiesNLS.put(outputFormatPolicies[i] ,I18nUtil.getFrameworkPolicyNLS(outputFormatPolicies[i]).get(i18nCtx));
   }
   
   String currentOFFileName = emxGetParameter(request, "outputFormatFileName");
   String currentOFPolicy = emxGetParameter(request, "outputFormatPolicy");
   Boolean terminate = "terminate".equalsIgnoreCase(emxGetParameter(request, "action"));
   String reportError = "";
   if (terminate) { %>
   		<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
   <%		try {
			if (isEditMode) {
				services.updateOutputFormat(objectId,
   									emxGetParameter(request, "outputFormatNameField"),
   									emxGetParameter(request, "outputFormatTitleField"),
   									emxGetParameter(request, "outputFormatDescriptionField"),
   									emxGetParameter(request, "outputFormatPolicy"));
			} else {
				objectId = services.createOutputFormat(emxGetParameter(request, "outputFormatNameField"),
   									emxGetParameter(request, "outputFormatTitleField"),
   									emxGetParameter(request, "outputFormatDescriptionField"),
   									emxGetParameter(request, "outputFormatFileName"),
   									emxGetParameter(request, "outputFormatPolicy"));
			}
   		} catch (MatrixException e) {
			terminate = false;
			reportError = e.toString();
   		} catch (Exception e) {
			terminate = false;
			reportError = e.getMessage();
		}
   } else {
   		if(isEditMode && objectId != null) {
   			if (objectId.startsWith("|")) objectId = objectId.substring(1, objectId.indexOf("|", 1));
   			String role = (String) context.getRole();
   			if (role != null && (!role.equals("null") || !role.equals("")|| !role.equals(" "))) {
				try {
					TclArray values = RGNUtil.tclPrintSelect(context, "bus", objectId, "name", "attribute[Title]", "description", "policy", "from[Active Version].to.attribute[Title]");
					outputFormatName = values.getString(0);
					outputFormatTemplate = values.getString(1);
					outputFormatDescription = values.getString(2);
					currentOFPolicy = values.getString(3);
					currentOFFileName = values.getString(4);
				} catch (MatrixException e) {
   					e.printStackTrace();
					reportError = e.getMessage();
				} catch (Exception e) {
   					e.printStackTrace();
					reportError = e.getMessage();
				}
			}
		}
   }
   
%>
	
<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<BODY OnLoad="takeFocus();" class="slide-in-panel">
	<form name="outputFormatCreationForm" method="post" onsubmit="submitForm(); return false" action="emxCATRgnOutputFormatCreate.jsp?action=terminate">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<input type="hidden" name="action">
		<input type="hidden" name="mode">
		<input type="hidden" name="targetLocation">
		<input type="hidden" name="outputFormatId">
		<table class="form">
			<tbody>
				<tr><td class="createRequiredNotice"><%=XSSUtil.encodeForHTML(context, requiredNoticeNLS)%></td></tr>
				<tr>
					<td class="createLabelRequired" valing="middle" width="150">
						<label for="outputFormatNameField"><%=XSSUtil.encodeForHTML(context, nameLabel)%></label>
					</td>
				</tr>
				<tr>
					<td class="createInputField">
						<input type="text" id="outputFormatNameField" name="outputFormatNameField" value="<% if(outputFormatName != null) { %><%=XSSUtil.encodeForHTMLAttribute(context, outputFormatName)%><% }; %>"
							size="25" onFocus="this.select()"/>	
					<% if (checkAutoName.equals("on")) {%>
						<input <% if (isEditMode) { %>type="hidden"<% } else { %>type="checkbox"<%} %> name="checkAutoName" onClick="Javascript:switchAutoName()" checked />
					<%} else {%>
						<input <% if (isEditMode) { %>type="hidden"<% } else { %>type="checkbox"<%} %> name="checkAutoName" onClick="Javascript:switchAutoName()" />
					<%}%>
					<% if (!isEditMode) { %>
						<label><%=XSSUtil.encodeForHTML(context, autoNameLabel) %></label>
					<% } %>		
					</td>
				</tr>
				<!--Title Field -->
				<tr>
					<td class="createLabelRequired" width="150" align="left">
						<label for="outputFormatTitleField"><%=XSSUtil.encodeForHTML(context, titleLabel)%></label>
					</td>
				</tr>
				<tr>
					<td  class="field">
						<input type="text" id="outputFormatTitleField" name="outputFormatTitleField" size="20" value="<% if(outputFormatTemplate != null){ %><%=XSSUtil.encodeForHTMLAttribute(context, outputFormatTemplate)%><% }; %>"/>
					</td>
				</tr>
				<!--Description Field -->
				<tr>
					<td class="label">
						<label for="outputFormatDescriptionField"><%=XSSUtil.encodeForHTML(context, descrLabel)%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<textarea cols="25" rows="5" id="outputFormatDescriptionField" name="outputFormatDescriptionField" onFocus="this.select()"><% if(outputFormatDescription != null){ %><%=XSSUtil.encodeForHTML(context, outputFormatDescription)%><% }; %></textarea>
					</td>
				</tr>
				<!--Output Format select -->
				<% if(!isEditMode) { %>
				<tr>
					<td class="label">
						<label for="outputFormatFileName"><%=XSSUtil.encodeForHTML(context, outputFileLabel)%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<select id="outputFormatFileName" name="outputFormatFileName">
							<option value="none" <% if(null==currentOFFileName) { %>selected<% } %>>
								<%=XSSUtil.encodeForHTML(context, I18nUtil.STR_NO_OUTPUT_FORMAT.get(i18nCtx))%>
							</option>
						<% for(String ofFileName : outputFormats) { %>
							<option	value="<%=XSSUtil.encodeForHTMLAttribute(context, ofFileName)%>" <% if (ofFileName.equalsIgnoreCase(currentOFFileName)) { %>selected<% } %>>
								<%=XSSUtil.encodeForHTML(context, ofFileName)%>
							</option>
						<% } %>
						</select>
					</td>
				</tr>
				<% } %>
				<!-- Policy select -->
				<tr>
					<td class="label">
						<label for="outputFormatPolicy"><%=XSSUtil.encodeForHTML(context, outputFormatPolicyLabel)%></label>
					</td>
				</tr>
				<tr>
					<td class="field">
						<select id="outputFormatPolicy" name="outputFormatPolicy">
						<% 	int i = 0;
							for(String ofPolicy : policiesNLS.keySet()) { 
						%>
							<option	value="<%=XSSUtil.encodeForHTMLAttribute(context, ofPolicy)%>" <% if (ofPolicy.equalsIgnoreCase(currentOFPolicy)) { %>selected<% } %>>
								<%=XSSUtil.encodeForHTML(context, policiesNLS.get(ofPolicy))%>
							</option>
						<% 		
							} 
						%>
						</select>
					</td>
				</tr>
			</tbody>
		</table>
	</form>

	<script>
		if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(terminate))%>) {
			getTopWindow().closeSlideInDialog();
			var contentFrame = findFrame(getTopWindow(), "content"),
				deskpanel = getTopWindow().document.getElementById('mydeskpanel'),
				rgnMyDesk = getTopWindow().document.getElementById('RGNMyDesk'),
				rgnMyDeskHidden = rgnMyDesk.style.display === 'none',
				desks = deskpanel.querySelector(".menu-content").querySelectorAll('div[style]');
			if (rgnMyDeskHidden) {
				for (var i = 0; i < desks.length; i++) { // hide all desks
					desks[i].style.display = 'none';
				}
				rgnMyDesk.style.display = 'block'; // show RGN desk
			}
			rgnMyDesk.querySelectorAll('li > a')[1].click(); // select output format menu item
		} else if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(!reportError.isEmpty()))%>) {
			//Fix IR-580539-3DEXPERIENCER2018x
			alert('<%=XSSUtil.encodeForJavaScript(context, reportError)%>');
			findFrame(getTopWindow(), "slideInFrame").document.querySelector('button.btn-primary').removeAttribute('disabled');
		}
		
		function takeFocus() {
			var form = document.outputFormatCreationForm;
			var nameDisabled = form.outputFormatNameField.disabled;
			if (nameDisabled) {
				form.outputFormatTitleField.focus();
			} else {
				form.outputFormatNameField.focus();
			}
		}
		
		function switchAutoName() {
			var form = document.outputFormatCreationForm;
			var autonameChecked = form.checkAutoName.checked;
			if (autonameChecked) {
				form.outputFormatNameField.value = "";
				form.outputFormatNameField.disabled = true;
			} else {
				form.outputFormatNameField.disabled = false;
				form.outputFormatNameField.focus();
			}
		}
		
		function cancelForm() {
	    	if(<%=XSSUtil.encodeForJavaScript(context, String.valueOf(isSlideIn))%>) {
	    		getTopWindow().closeSlideInDialog();
				var contentFrame = findFrame(getTopWindow(), "content");
	    		contentFrame.document.location.href = contentFrame.document.location.href;
			} else {
				parent.window.opener.document.location = parent.window.opener.document.location;
				parent.window.close();
			}
		}

		function submitForm() {
			var form = document.outputFormatCreationForm;
			var autonameChecked = form.checkAutoName.checked;
			var nameValue = form.outputFormatNameField.value;
			//is nameValue empty?
			if (!autonameChecked && trimWhitespace(nameValue).length == 0) {
				alert("<%=XSSUtil.encodeForJavaScript(context,  enterNameAlert)%>");
				form.outputFormatNameField.focus();
				return;
			}

			//is titleValue empty?
			var titleValue = form.outputFormatTitleField.value;
			if (trimWhitespace(titleValue).length == 0) {
				alert("<%=XSSUtil.encodeForJavaScript(context,  enterTitleAlert)%>");
				form.outputFormatTitleField.focus();
				return;
			}

			var nameCheckValue = checkForNameBadChars(nameValue, false);
			var descCheckValue = checkForBadChars(form.outputFormatDescriptionField);

			//validate that all required fields are entered
			if (!autonameChecked && (nameValue == null || nameValue == "")) {
				alert("<%=XSSUtil.encodeForJavaScript(context,  newReportAlert)%>");
				form.outputFormatNameField.focus();
				return;
			} else if (charExists(nameValue, '"') || charExists(nameValue, '#')
					|| (nameCheckValue == false)) {
				alert("<%=XSSUtil.encodeForJavaScript(context,  invalidNameAlert)%>");
				form.outputFormatNameField.focus();
				return;
			} else if (descCheckValue.length != 0) {
				alert("<%=XSSUtil.encodeForJavaScript(context,  invalidCharsAlert)%>"
						+ descCheckValue
						+ "<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
				form.outputFormatDescriptionField.focus();
				return;
			} else {
				findFrame(getTopWindow(),"slideInFrame").document.getElementById("divPageFoot").getElementsByClassName("btn-primary")[0].setAttribute("disabled", "true");
				form.action.value = "terminate";
				form.mode.value = "<%=XSSUtil.encodeForJavaScript(context,  mode)%>"
				form.targetLocation.value= "<%=XSSUtil.encodeForJavaScript(context,  targetLocation)%>";
				form.outputFormatId.value = "<%=XSSUtil.encodeForJavaScript(context,  objectId)%>"
				form.submit();
			}
		}

	</script>
</BODY>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
