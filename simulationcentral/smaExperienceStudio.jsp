<%--
	Author(s): d6u
	Date: 11/01/14
	Copyright: (c) Dassault Systemes, 2014, 2015
	Description: Launched on click of any Template from Experience Studio landing page.
				 It's purpose is to create or fetch the corresponding Template view object and redirect to Experience Studio
--%>

<!--This imports most of the classes needed-->
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.Template,
				  com.matrixone.apps.domain.util.MapList"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>

<%@page import = "java.util.*"%>

<script src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUICore.js"></script>

<%!

	private final String TEMPLATE_VIEW_RELATIONSHIP = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_relationship_SimulationTemplateView);
	private final String TEMPLATE_VIEW_TYPE = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationTemplateView);
	private final String TEMPLATE_CONTENT_RELATIONSHIP = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_relationship_SimulationTemplateContent);
	private final StringList OBJECTSELECT_PHYSICALID = new StringList(SimulationConstants.PHYSICAL_ID);
	final String TITLE =  SimulationUtil.getSelectAttributeTitleString();

	private ArrayList<String> errorList = new ArrayList<String>();

%>

<%
	String simId = null,
		   templateId = null,
		   templateTitle = null,
		   templateViewId = null;

	boolean hasXSLicense;


	try {
		/*License check*/
		hasXSLicense = Boolean.parseBoolean(SimulationContentUtil.checkLicense(context, SimulationConstants.APP_EXPERIENCE_STUDIO));
		if (!hasXSLicense) {
			throw new Exception("You do not have the license for Process Experience Studio");
		}

		/*Get Template Id in whose context Experience Studio is being launched*/
		HashMap<String, String> requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
		String parentTemplateId = (String)requestMap.get("objectId");
		if(parentTemplateId == null) {
			throw new Exception("Process Experience Studio cannot be launched without Simulation template context");
		}

		Template template = new Template(parentTemplateId);

		/*Get physical id, title for the template object*/
		StringList templateSelects = new StringList(new String[] {SimulationConstants.PHYSICAL_ID, TITLE});
	 	Map templateInfo = template.getInfo(context, templateSelects);
	 	templateId = (String)(templateInfo.get(SimulationConstants.PHYSICAL_ID));
	 	templateTitle = (String)(templateInfo.get(TITLE));

		/*Get content id and template view id*/
		MapList contentAndViewInfo = template.getContentAndViewInfo(context);
		for (Object details: contentAndViewInfo) {
			Map objMap = (Map)details;
			String REL_NAME = (String)objMap.get("relationship");
			String physicalId = (String)objMap.get("physicalid");
			if (REL_NAME.equals(TEMPLATE_VIEW_RELATIONSHIP)) {
				templateViewId = physicalId;
			}
			if (REL_NAME.equals(TEMPLATE_CONTENT_RELATIONSHIP)) {
				simId = physicalId;
			}
		}
		if (templateViewId == null){
			throw new Exception("There is no Custom view defined for this Template. Please produce one and then try.");
		}

		//Redirect to Experience Studio with Ids of template,template view and process in the query string
		StringBuilder contentURL = new StringBuilder();
		contentURL.append("../webapps/SMAProcXSUI/xs-app/xs-app.html")
     	 .append("?viewId=").append(templateViewId)
     	 .append("&templateId=").append(templateId)
     	 .append("&simId=").append(simId)
		 .append("&templateTitle=").append(templateTitle);
		%>

		<script>
             //If everything worked without any exceptions, redirect to Experience Studio page.
		     //Change topbar title
			 var appsMenuList = new Array();
	         appsMenuList[0] = 'SMAScenario_Definition_New';
	         getTopWindow().changeProduct('SIMULIA', 'Process Experience Studio', 'SIMEXPS_AP', appsMenuList, 'SIMEXPS_AP', null);


			//Redirect to Experience Studio application
			var contentFrame = findFrame(getTopWindow(),"content");
			contentFrame.location.href = "<%=contentURL.toString()%>";
		</script>
	<%
	} catch (Exception ex) {
		//emxNavErrorObject.addMessage(ex.getMessage());
		String errorMessage = ex.getMessage();
	    //Redirect to Experiences landing page
		String landingPageURL = "../simulationcentral/smaHomeUtil.jsp?objectAction=EntryInExperienceStudio&newUI=true&HelpMarker=SMAHome_ExperienceStudioEntry";
	%>
		<script>
			window.alert('<%=errorMessage%>');
			var contentFrame = findFrame(getTopWindow(),"content");
			contentFrame.location.href = "<%=landingPageURL%>";
		</script>
	<%}

	%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
