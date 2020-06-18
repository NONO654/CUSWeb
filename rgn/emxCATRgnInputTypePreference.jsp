<%@page import="com.dassault_systemes.catrgn.connector.interfaces.*,
		com.dassault_systemes.catrgn.connector.configuration.interfaces.*,
		com.dassault_systemes.catrgn.report.datamodel.*,
		com.dassault_systemes.catrgn.pervasive.server.*,
		com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil,
		com.dassault_systemes.catrgn.services.util.preferences.PreferenceUtil,
		com.dassault_systemes.catrgn.reportNav.services.interfaces.PreferenceManager.PreferenceException,
		com.dassault_systemes.catrgn.engine.connector.configuration.properties.UserInputTypesProperty,
		com.dassault_systemes.catrgn.otscript.i18nSupport.impl.GwtI18nSupport"%>
<%@ page import = "com.dassault_systemes.catrgn.services.util.nls.*" %>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc" %>
<%
	String lang = request.getHeader("Accept-Language");
	RequestNfo reqInfo = RGNUtil.createRequestFromContext(context, lang);
	reqInfo.setProperty(HttpServletRequest.class, request);
	ConnectorConfigurationItf cfg = new 	ConnectorConfigurationFactory().getRGNConfig(reqInfo);
	PublicProperty inputTypesProp = new UserInputTypesProperty(reqInfo);
	PreferenceUtil prefUtil = new PreferenceUtil(context);
	String propertiesToJSON = prefUtil.getPropertyAsJSON(inputTypesProp);
	if ("true".equalsIgnoreCase(emxGetParameter(request, "process"))) {
%>
		<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
		String propertyName = inputTypesProp.getName();
		String propValue = emxGetParameter(request, propertyName);
		try {
			prefUtil.setUserPreferenceProperty(ConnectorConfigurationItf.INPUT_TYPES_PREFERENCE, propValue);
		} catch (PreferenceException ex) {
			emxNavErrorObject.addMessage("prefStructureDisplay:" + ex.getMessage().trim());
		}
	}

%>
<html>
	<head>
		<meta http-equiv="pragma" content="no-cache" />
		<script language="javaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
		<script type="text/javascript">
			<% out.print(GwtI18nSupport.makeJsI18nDictionary(lang, "emxRGNStringResource")); %>
			addStyleSheet("emxUIDefault");
			addStyleSheet("emxUIForm");
		</script>
	</head>
	<body onload="buildForm('<%=XSSUtil.encodeForJavaScript(context, propertiesToJSON)%>');turnOffProgress()">
		<form method="post" action="emxCATRgnInputTypePreference.jsp?process=true">
			<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
			<div id="pageHeadDiv" class="pageHead">
				<table>
					<tbody id="propertiesTable">
					</tbody>
				</table>
			</div>
		</form>
	</body>
	<script type="text/javascript" src="./scripts/emxRGNScript.js"></script>
</html>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
