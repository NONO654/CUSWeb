<%@page import="com.dassault_systemes.catrgn.engine.report.generation.otscript.OTScriptDataModel"%>
<%@page import="com.dassault_systemes.catrgn.connector.interfaces.*,
		com.dassault_systemes.catrgn.connector.configuration.interfaces.*,
		com.dassault_systemes.catrgn.report.datamodel.*,
		com.dassault_systemes.catrgn.pervasive.server.*,
		com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil,
        com.dassault_systemes.catrgn.services.util.preferences.PreferenceUtil,
		com.dassault_systemes.catrgn.otscript.i18nSupport.impl.GwtI18nSupport"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc" %>

<%
	String lang = request.getHeader("Accept-Language");
	RequestNfo reqInfo = RGNUtil.createRequestFromContext(context, lang);
	reqInfo.setProperty(HttpServletRequest.class, request);
	ConnectorConfigurationItf cfg = new ConnectorConfigurationFactory().getRGNConfig(reqInfo);
	PreferenceUtil prefUtil = new PreferenceUtil(context);
	ArrayList<PublicProperty> publicProperties = (ArrayList)cfg.getPublicProperties(reqInfo);
	String propertiesToJSON = prefUtil.isAdminRole ? prefUtil.getPropertiesAsJSON(publicProperties) : prefUtil.getInvalidRoleAsJSON();
	if (prefUtil.isAdminRole && "true".equalsIgnoreCase(emxGetParameter(request, "process"))) {
%>
		<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
		for (PublicProperty property : publicProperties) {
			String propertyName = property.getName();
			String propValue = emxGetParameter(request, propertyName);
			if (property instanceof BooleanPublicProperty) {
				prefUtil.savePublicProperty(propertyName, Boolean.toString(propValue != null && !propValue.isEmpty()));
			} else {
				prefUtil.savePublicProperty(propertyName, propValue);
			}
		}
		cfg.clearCaches(reqInfo);
		OTScriptDataModel.resetOTScript(reqInfo);
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
        <style type="text/css">
            textarea {
                white-space: pre;
            }
        </style>
    </head>
	<body onload="buildForm('<%=XSSUtil.encodeForJavaScript(context, propertiesToJSON)%>');turnOffProgress()">
		<form method="post" action="emxCATRgnPropertiesPreferences.jsp?process=true">
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
