
<%@page import="com.dassault_systemes.catrgn.reportNav.services.interfaces.CATRgnIReportTemplate.TemplateParameter"%>
<%@page import="com.dassault_systemes.catrgn.connector.interfaces.PLMInputData"%>
<%@page import="com.dassault_systemes.catrgn.reportNav.services.ReportInputInformation"%>
<%@page import="com.dassault_systemes.catrgn.pervasive.server.RequestNfo"%>
<%@page import="com.dassault_systemes.catrgn.pervasive.log.SystemReportGenerationLogger"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.lang.Exception" %>
<%@ page import = "javax.json.*" %>

<%@ page import = "matrix.db.*" %>

<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%@ page import = "com.dassault_systemes.catrgn.reportNav.services.CATRgnReportServices" %>
<%@ page import = "com.dassault_systemes.catrgn.engine.report.generation.util.RGNUtil" %>
<%@ page import = "com.dassault_systemes.catrgn.services.util.nls.*"%>
<%@ page import = "com.dassault_systemes.catrgn.i18n.*"%>
<%@ page import = "com.dassault_systemes.vplm.modeler.exception.PLMxModelerException" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
	String errStr = null;
	String actionURL = null;
	String lang = request.getHeader("Accept-Language");
	String mode = emxGetParameter(request, "mode");
	String action = emxGetParameter(request, "action");
	String objectId = emxGetParameter(request, RGNUtil.REPORT_ID);
	boolean isEditMode = "edit".equalsIgnoreCase(mode);
	boolean isTerminate = "terminate".equalsIgnoreCase(action);
	String targetLocation = emxGetParameter(request, "targetLocation");
	boolean isSlideIn = "slidein".equalsIgnoreCase(targetLocation);
	String fromDialog = emxGetParameter(request, "fromDialog");
	boolean fromCreateDialog = "CreateDialog".equalsIgnoreCase(fromDialog);
	boolean fromParamDialog = "ParamsDialog".equalsIgnoreCase(fromDialog);
	boolean fromConfigDialog = "ConfigDialog".equalsIgnoreCase(fromDialog);
	Map<Object, Object> requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	String nbInputsStr = emxGetParameter(request,RGNUtil.REPORT_NB_INPUTS);
	Integer nbInputs = 0;	
	if(nbInputsStr != null) nbInputs = Integer.valueOf(nbInputsStr);
	CATRgnReportServices services = new CATRgnReportServices(context, request);
	if(isTerminate) {
		String role = (String) context.getRole();
		if (role != null && (!role.equals("null") || !role.equals("")|| !role.equals(" "))) {
			String reportId = emxGetParameter(request, RGNUtil.REPORT_ID);
			String reportName = emxGetParameter(request, RGNUtil.REPORT_NAME);
			String reportTitle = emxGetParameter(request, RGNUtil.REPORT_TITLE);
			String reportDescription = emxGetParameter(request, RGNUtil.REPORT_DESCR);
			String templateId = emxGetParameter(request, RGNUtil.REPORT_MODEL_ID);

			ReportInputInformation inputInfo = new ReportInputInformation(context, templateId, emxGetParameter(request, RGNUtil.REPORT_TEMPLATE_ID));
			TemplateParameter[] tps = CATRgnReportServices.getTemplateRepresentation(context, templateId).getParameters();
			
			String configId = emxGetParameter(request, "configId");
			if (configId != null && !configId.isEmpty() && !"none".equals(configId))
				inputInfo.setConfigId(configId);
			String targetDocumentId = emxGetParameter(request, "targetDocumentId");
			if (targetDocumentId != null && !targetDocumentId.isEmpty())
				inputInfo.setTargetDocumentId(targetDocumentId);
			for(int i = 0; i < nbInputs; i++) {
				TemplateParameter tp = tps[i];
				String oid = emxGetParameter(request, RGNUtil.InputId(i));
				inputInfo.addParameter(
						tp,
						Arrays.asList((tp.isPLMObject() ? oid : emxGetParameter(request,RGNUtil.InputValue(i))).split("\\|")));
			}

			try {
				if (isEditMode) services.updateReport(reportId, reportName, reportTitle, reportDescription, inputInfo);
				else {
					objectId =  services.PLMID2PhysID(services.createReport(reportName, reportTitle, reportDescription, inputInfo));
				}
			} catch (Throwable e) {
				SystemReportGenerationLogger.trace(e.getMessage(), e);
				errStr = isEditMode ? "emxRGN.Error.ReportUpdate" : "emxRGN.Error.ReportCreation";
			}
		} else {
			errStr = "emxRGN.Error.RoleIsBadOrMissing";
		}
	} else {
		StringBuffer actionUrlBuff = new StringBuffer();
		if(fromCreateDialog) actionUrlBuff.append("emxCATRgnReportCreateParamsDialogFS.jsp");
		if(fromParamDialog) actionUrlBuff.append("emxCATRgnReportCreateConfigDialogFS.jsp");
		
		actionUrlBuff.append("?targetLocation=");
		actionUrlBuff.append(targetLocation);
		
		if(mode != null) {
			actionUrlBuff.append("&mode=");
			actionUrlBuff.append(mode);
		}
			
		if(objectId != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.REPORT_ID);
			actionUrlBuff.append("=");
			actionUrlBuff.append(objectId);
		}
		
		String reportGenerationName = emxGetParameter(request,"reportNameField");
		if(reportGenerationName == null) reportGenerationName = emxGetParameter(request, RGNUtil.REPORT_NAME);
		if(reportGenerationName != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.REPORT_NAME);
			actionUrlBuff.append("=");
			actionUrlBuff.append(CATRgnReportServices.encodeUTF8(reportGenerationName));
		}

		String reportGenerationTitle = fromCreateDialog ? emxGetParameter(request,"reportTitleField") : emxGetParameter(request, RGNUtil.REPORT_TITLE);
		if(reportGenerationTitle != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.REPORT_TITLE);
			actionUrlBuff.append("=");
			actionUrlBuff.append(CATRgnReportServices.encodeUTF8(reportGenerationTitle));	
		}

		String reportGenerationDescription = fromCreateDialog ? emxGetParameter(request,"reportDescriptionField") : emxGetParameter(request, RGNUtil.REPORT_DESCR);
		if(reportGenerationDescription != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.REPORT_DESCR);
			actionUrlBuff.append("=");
			actionUrlBuff.append(CATRgnReportServices.encodeUTF8(reportGenerationDescription));	
		}
		
		//If coming from CreateDialog, the model and template ids are coming from a default search jsp that need to fill a xxxOID field
		//else we get the classical hidden field xxxId wich is saved everywhere
		String reportModelId = fromCreateDialog ? emxGetParameter(request,"reportmodelOID") : emxGetParameter(request,RGNUtil.REPORT_MODEL_ID);
		if(reportModelId != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.REPORT_MODEL_ID);
			actionUrlBuff.append("=");
			actionUrlBuff.append(reportModelId);
		}
		
		String reportTemplateId = fromCreateDialog ? emxGetParameter(request,"reporttemplateOID") : emxGetParameter(request,RGNUtil.REPORT_TEMPLATE_ID);
		if(reportTemplateId != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.REPORT_TEMPLATE_ID);
			actionUrlBuff.append("=");
			actionUrlBuff.append(reportTemplateId);
		}
		
		String targetDocumentId = fromCreateDialog ? emxGetParameter(request,"targetDocumentOID") : emxGetParameter(request, RGNUtil.TARGET_DOCUMENT_ID);
		if(targetDocumentId != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.TARGET_DOCUMENT_ID);
			actionUrlBuff.append("=");
			actionUrlBuff.append(targetDocumentId);
		}

		//Inputs treatment
		if(nbInputsStr != null) {
			actionUrlBuff.append("&");
			actionUrlBuff.append(RGNUtil.REPORT_NB_INPUTS);
			actionUrlBuff.append("=");
			actionUrlBuff.append(nbInputsStr);
		}
		
		if(nbInputs>0) {
			for(int i = 0; i < nbInputs; i++) {
				String fieldName = RGNUtil.InputId(i);
				actionUrlBuff.append("&"); 
				actionUrlBuff.append(fieldName);
				actionUrlBuff.append("=");
				actionUrlBuff.append(emxGetParameter(request, fieldName));
				fieldName = RGNUtil.InputValue(i);
				actionUrlBuff.append("&"); 
				actionUrlBuff.append(fieldName);
				actionUrlBuff.append("=");
				actionUrlBuff.append(emxGetParameter(request, fieldName));
			}
		}

		String configId = fromCreateDialog ? emxGetParameter(request,"configId") : emxGetParameter(request,RGNUtil.REPORT_CONFIG_ID);
        if(configId != null) {
            actionUrlBuff.append("&");
            actionUrlBuff.append(RGNUtil.REPORT_CONFIG_ID);
            actionUrlBuff.append("=");
            actionUrlBuff.append(configId);
        }

		String role = (String) context.getRole();
		if (role != null && (!role.equals("null") || !role.equals("")|| !role.equals(" "))) {
			try{
				actionURL = actionUrlBuff.toString();
			} catch (Exception e) {
				errStr = e.toString();
			}
		} else {
			I18nServerContext i18nCtx = new I18nServerContext(services.requestInfo);
			errStr = I18nUtil.STR_ROLE_IS_BAD_OR_MISSING.get(i18nCtx);
		}
	}
	

%>

<script language="javascript" src="../common/scripts/emxUICore.js">
</script>
<script language="javascript" src="../common/scripts/emxUIConstants.js">
</script>


<script type="text/javascript" language="javascript">
	<% if ( errStr != null) { %>
		alert("<%=XSSUtil.encodeForJavaScript(context, errStr)%>");
	<% };%>
	if (<%=XSSUtil.encodeForJavaScript(context, String.valueOf(isSlideIn))%>) 	{
	    	var slidein = findFrame(getTopWindow(), "slideInFrame");
		<%	if ( actionURL != null) { %>
		    	slidein.document.location.href="<%=XSSUtil.encodeForJavaScript(context, actionURL)%>";
		<% 	} else { %>
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
				rgnMyDesk.querySelectorAll('li > a')[0].click(); // select report menu item
		<% 	}; %>
  	} else {
		<%	if ( actionURL != null) { %>
				getTopWindow().document.location.href="<%=XSSUtil.encodeForJavaScript(context, actionURL)%>";
		<% 	} else { %>
	    		parent.window.opener.document.location = parent.window.opener.document.location;
				parent.window.close();	
		<% 	}; %>
   	}
</script>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


