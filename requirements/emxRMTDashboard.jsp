<%@page import="javax.json.JsonObjectBuilder"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>


<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@page import  = "javax.json.JsonArray"%>
<%@page import  = "matrix.db.AttributeType"%>
<%@page import  = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import  = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import  = "com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import  = "matrix.db.Policy"%>
<%@page import  = "matrix.db.StateRequirementList"%>
<%@page import  = "javax.json.JsonObject"%>
<%@page import  = "javax.json.Json"%>
<%@page import  = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%-- @quickreview LX6     IR-348544-3DEXPERIENCER2016x 	R417-FUN044564: Structure Display page controls & commands are in active state when Quick Chart is invoked and behavior of it is inconsistent with various commands.--%>
<%-- @quickreview HAT1 ZUD IR-428176-3DEXPERIENCER2016x  19-Apr-2016   R418: [IPAD Specific] : "Quick Chart" window doesn't shows "close" button.--%>
<%
	String sObjectId		= request.getParameter("objectId"); 
	String sRequest			= request.getParameter("requestType");
	String expandedTypes	= request.getParameter("RMTCustomTypes");
	if(sRequest != null){
		//START LX6 IR-348544-3DEXPERIENCER2016x
		if("getAttributeMissingValues".equalsIgnoreCase(sRequest)){
        	String strIds = emxGetParameter(request,"ids");
        	String strPIds = emxGetParameter(request,"pIds");
        	String[] arrIds = strIds.split(",");
        	String[] arrPIds = strPIds.split(",");
        	StringList values = new StringList(); 
        	for(int i=0;i<arrIds.length;i++){
        		String tuplets = "";
        		String relType="";
        		String id = arrIds[i];
        		String pId = arrPIds[i];
        		DomainObject domId = DomainObject.newInstance(context,id);
        		String objType = domId.getType(context);

        		String objTypes = ReqSchemaUtil.getRequirementType(context) + ","
                    + ReqSchemaUtil.getChapterType(context)+","
        			+ ReqSchemaUtil.getRequirementSpecificationType(context);
			    StringList objSelect = new StringList(DomainConstants.SELECT_ID);
			    objSelect.add(DomainConstants.SELECT_TYPE);
			    StringList relSelect = new StringList(DomainConstants.SELECT_RELATIONSHIP_ID);
			    relSelect.add(DomainConstants.SELECT_RELATIONSHIP_TYPE);
			    // Get the child relationship objects and sort them based on the Tree Order attribute...
			    MapList relObjects = domId.getRelatedObjects(context, "*", objTypes, objSelect, relSelect, true, false, (short) 1, "", "");
			    for(int j=0;j<relObjects.size();j++){
			    	Map objMap = (Map)relObjects.get(j);
			    	String parentObj = (String)objMap.get(DomainConstants.SELECT_ID);
			    	if(parentObj.equalsIgnoreCase(pId)){
			    		relType = (String)objMap.get(DomainConstants.SELECT_RELATIONSHIP_TYPE);
			    	}
			    }
			    tuplets = objType+":"+relType;
			    values.add(tuplets);
        	}
        	PrintWriter OUT = response.getWriter();
    		out.clear();
    		out.write(values.toString());
    		return;
		}else if("errorMessage".equalsIgnoreCase(sRequest)){
			String sLanguage		= request.getHeader("Accept-Language");
			String sLabelTestCases		= i18nNow.getI18nString("emxRequirements.Alert.NoReqsForQuickchart", "emxRequirementsStringResource" 	, sLanguage);
			PrintWriter OUT = response.getWriter();
    		out.clear();
    		out.write(sLabelTestCases);
		}else{
		//END LX6 IR-348544-3DEXPERIENCER2016x
			HashMap params 		= new HashMap();
			params.put("objectId"				, sObjectId			 );
			params.put("requestType"			, sRequest			 );
			String initargs[]	= {};	
			JsonArray aData	= (JsonArray)JPO.invoke(context, "emxRMTDashBoardBase", initargs, "getRequirementsDashboardData", JPO.packArgs (params), JsonArray.class);
			response.setContentType("application/json");
			// Get the printwriter object from response to write the required json object to the output stream      
			PrintWriter OUT = response.getWriter();
			out.clear();
			out.write(aData.toString());
			return;
		}
		
	}else{ 
		DomainObject rootObj = DomainObject.newInstance(context, sObjectId);
		rootObj.openObject(context);
		String rootObjType = rootObj.getTypeName();
		rootObj.close(context);
		String strAttributeList = EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.attributeList");
		String[] strAttributes = strAttributeList.split(",");	
		String sLanguage		= request.getHeader("Accept-Language");
		String sHeader 			= "emxGNV.String.RequirementsDashboard";
		String expandProgram 	= request.getParameter("selectedProgram");
		String sParamOID		= "";
		String sOID				= request.getParameter("objectId");		
		String initargs[]	= {};
		HashMap params 		= new HashMap();
		
		params.put("language"				, sLanguage );
		params.put("selectedProgram"		, expandProgram );	
			
		String sLabelSelected 		= i18nNow.getI18nString("emxComponents.Common.Selected"							, "emxComponentsStringResource" 	, sLanguage);
		String sLabelHidePanel 		= i18nNow.getI18nString("emxRequirements.dashboard.HidePanel"					, "emxRequirementsStringResource" 	, sLanguage);
        String sLabelTotal 			= MessageUtil.getMessage(context, null, "emxRequirements.dashboard.RequirementsInTotal",
                   							new String[] {"<span id='nbReq' style=\"color:#000000;font-weight:bold;\"></span>"}, null, context.getLocale(), "emxRequirementsStringResource");
		String sLabelTableName 		= i18nNow.getI18nString("emxRequirements.dashboard.Table"						, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelBasic 			= i18nNow.getI18nString("emxRequirements.dashboard.Basic"						, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelDetails 		= i18nNow.getI18nString("emxRequirements.Table.Details"							, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelAssignees		= i18nNow.getI18nString("emxRequirements.dashboard.Assignment"					, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelStatus 		= i18nNow.getI18nString("emxFramework.Basic.State"								, "emxComponentsStringResource" 	, sLanguage);
		String sLabelPendingEC 		= i18nNow.getI18nString("emxRequirements.dashboard.RelatedChanges"				, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelResponsibility = i18nNow.getI18nString("emxRequirements.Form.Label.DesignResponsibility"		, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelTestCases		= i18nNow.getI18nString("emxRequirements.Tree.TestCase"							, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelPLMParameter	= i18nNow.getI18nString("emxRequirements.Label.Parameters"						, "emxRequirementsStringResource" 	, sLanguage);
		String sLabelValidation		= i18nNow.getI18nString("emxFramework.Relationship.Requirement_Validation"		, "emxFrameworkStringResource" 		, sLanguage);
		String sLabelTimeline		= i18nNow.getI18nString("emxFramework.Attribute.Timeline"						, "emxFrameworkStringResource" 		, sLanguage);
		String sDashboard			= i18nNow.getI18nString("emxRequirements.dashboard.dashboard"					, "emxRequirementsStringResource" 	, sLanguage);
		String coveredLabel         = i18nNow.getI18nString("emxRequirements.dashboard.coveredRequirement"			, "emxRequirementsStringResource" 	, sLanguage);
		String notCoveredLabel      = i18nNow.getI18nString("emxRequirements.dashboard.notCoveredRequirement"		, "emxRequirementsStringResource" 	, sLanguage);
		String refinedLabel         = i18nNow.getI18nString("emxRequirements.dashboard.refinedRequirement"			, "emxRequirementsStringResource" 	, sLanguage);
		String notRefinedLabel      = i18nNow.getI18nString("emxRequirements.dashboard.notrefinedRequirement"		, "emxRequirementsStringResource" 	, sLanguage);
		String sCoveredLabel		= i18nNow.getI18nString("emxRequirements.Dashboard.CoveredReqs", "emxRequirementsStringResource", sLanguage);
		String sRefinedLabel		= i18nNow.getI18nString("emxRequirements.Dashboard.RefinedReqs", "emxRequirementsStringResource", sLanguage);
		String sSubReqsLabel		= i18nNow.getI18nString("emxRequirements.Dashboard.SubRequirement", "emxRequirementsStringResource", sLanguage);
		String sAllReqs				= i18nNow.getI18nString("emxRequirements.QuickChart.Requirement.AllRequirements", "emxRequirementsStringResource", sLanguage);
		String sColourList          = EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.Color.List");

		JsonObjectBuilder AttributeRangeColours = Json.createObjectBuilder();
		Policy policyObj = new Policy (ReqSchemaUtil.getRequirementType(context));
		StateRequirementList States = policyObj.getStateRequirements(context);
		StringList ReqStateList = new StringList();
		StringList ChildrenTypes = ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getRequirementType(context));
		ChildrenTypes.add(ReqSchemaUtil.getRequirementType(context));
		String jsReqTypes = ChildrenTypes.toString();
		for(int i=0;i<strAttributes.length;i++){
				String attributeName = strAttributes[i];
				if(!attributeName.equalsIgnoreCase("Derived Requirement")&&!attributeName.equalsIgnoreCase("Sub Requirement")){
				String ranges = null;
				if(attributeName.equalsIgnoreCase("Classification")){
					attributeName = "Requirement Classification";
				}
				StringList values = FrameworkUtil.getRanges(context, attributeName);
				 JsonObjectBuilder rangesColour = Json.createObjectBuilder();
				 JsonObjectBuilder attributeJSON = Json.createObjectBuilder();
				attributeName = attributeName.replaceAll(" ","_");
				if(!attributeName.equalsIgnoreCase("Sub Requirement")&&!attributeName.equalsIgnoreCase("Derived Requirement")){
					for (int z = 0; z < values.size(); z++) {
						String range = (String)values.get(z);
						String rangeProperty = "emxFramework.Range."+attributeName+"."+range;		
						String propertyValue = i18nNow.getI18nString(rangeProperty	, "emxFrameworkStringResource" 	, sLanguage);
						String colourProperty = "emxRequirements.Range."+attributeName+"."+range+".Colour";
						String colour = null;
						try{
						colour = EnoviaResourceBundle.getProperty(context, colourProperty);
						}catch(Exception e){
							//property doesn't exist
							colour = "";
						}
						rangesColour.add(propertyValue, colour);
					}
					if(attributeName.contains("Classification")){
						attributeName = "Classification";
					}
					AttributeRangeColours.add(attributeName, rangesColour.build());
				}
			}
		}
		
		
		
		if(!States.isEmpty()){
			for(int i=0;i<States.size();i++){
				String stateName = ((StateRequirement)States.get(i)).getName();
				String strResource = "emxRequirements.dashboard.Requirement."+ stateName;
				String state = i18nNow.getI18nString(strResource, "emxRequirementsStringResource" 	, sLanguage);
				ReqStateList.add(state);
			}
		}
		Policy policyTCObj = new Policy (ReqSchemaUtil.getTestCaseType(context));
		StateRequirementList TCStates = policyTCObj.getStateRequirements(context);
		StringList TestCaseStateList = new StringList();
		if(!TCStates.isEmpty()){
			for(int i=0;i<TCStates.size();i++){
				String stateName = ((StateRequirement)TCStates.get(i)).getName();
				String strResource = "emxRequirements.dashboard.TestCase."+ stateName;
				String state = i18nNow.getI18nString(strResource, "emxRequirementsStringResource" 	, sLanguage);
				TestCaseStateList.add(state);
			}
		}
	%>	
	<html style='height:100%;'>
		<head>
	<% 	if(!"".equals(sOID)) { %>
			<script type="text/javascript">
				var footerurl = 'foot URL';
				addStyleSheet("emxUIDOMLayout");
			</script>
	<% 	} %>		
			<link rel="stylesheet" type="text/css" href="styles/common.css">			
			<link rel="stylesheet" type="text/css" href="styles/panelRight.css">	
			<!-- <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css"> -->
			<link rel="stylesheet" type="text/css" href="../requirements/styles/jquery-ui-smoothness.css">
			<link rel="stylesheet" type="text/css" href="../common/styles/emxDashboardCommon.css">
	        <script src="../webapps/AmdLoader/AmdLoader.js"></script>
	        <script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
	        <script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
			<!-- <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script> -->
			<script type="text/javascript" src="../plugins/libs/jquery/2.0.3/jquery.js"></script> 
			<!-- <script type="text/javascript" src="../requirements/scripts/plugins/jquery.ui-RMT.js"></script> -->
			<script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts.js"></script>
			<script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts-more.js"></script>
			<script type="text/javascript">
			var myFrame = $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
			myFrame.Highcharts = Highcharts;
			var objectId = "<%=sObjectId%>";
			var reqTypes = "<%=jsReqTypes%>"; 
			var rootObjType = "<%=rootObjType%>";
			getTopWindow().rootObjType=rootObjType;
			var CHARTS = new Array();
			myFrame.CHARTS = CHARTS;
			getTopWindow().myCharts=CHARTS;
			var colourArrayList = '<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.Color.List")%>';
			var expandedTypes = '<%=expandedTypes%>';
			var RequirementStates = '<%=ReqStateList.toString().replace("[","").replace("]","").replace(" ","")%>'.split(',');<%--XSSOK--%>
			var TestCaseStates = '<%=TestCaseStateList.toString().replace("[","").replace("]","").replace(" ","")%>'.split(',');<%--XSSOK--%>
			var BARCHARTLIMIT = parseInt('<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.pieChartLimit")%>');
			var excludedObjects = '<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.excludedObjects")%>'.split(",");
			var rangeValues;
			var TestCaseAttributeName = "<%=sLabelTestCases%>";
			myFrame.TestCaseAttributeName = TestCaseAttributeName;
			var ParameterAttributeName ="<%=sLabelPLMParameter%>";
			myFrame.ParameterAttributeName = ParameterAttributeName;
			var coveredAttributeName = "<%=sCoveredLabel%>";
			myFrame.coveredAttributeName = coveredAttributeName;
			var refinedAttributeName = "<statusValues%=sRefinedLabel%>";
			myFrame.refinedAttributeName = refinedAttributeName;
			var oXML = findFrame(getTopWindow(), "detailsDisplay").oXML;
			var colMap = findFrame(getTopWindow(), "detailsDisplay").colMap;
			var CHARTSVALUES = new Array();
			var statusLabel = "<%=sLabelStatus%>";
			var statusValues = new Array(0); 
			<%
			for(int i=0;i<ReqStateList.size();i++){
				String state=  ((StateRequirement)States.get(i)).getName();
				String translatedState = i18nNow.getI18nString("emxFramework.State.Requirement."+state, "emxFrameworkStringResource" 		, sLanguage);
				%>
				statusValues.push("<%=translatedState%>");
				<%	
			}
			%>
			myFrame.statusValues = statusValues;
			var statusColours = "<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.State.Colour")%>";
			var priorityValues = ["","",""];
			priorityValues[0] ="<%=i18nNow.getI18nString("emxFramework.Range.Priority.Urgent", "emxFrameworkStringResource" 			, sLanguage)%>";
			priorityValues[1] = "<%=i18nNow.getI18nString("emxFramework.Range.Priority.High", "emxFrameworkStringResource" 			, sLanguage)%>";
			priorityValues[2] = "<%=i18nNow.getI18nString("emxFramework.Range.Priority.Medium", "emxFrameworkStringResource" 			, sLanguage)%>";
			priorityValues[3] = "<%=i18nNow.getI18nString("emxFramework.Range.Priority.Low", "emxFrameworkStringResource" 			, sLanguage)%>";
			priorityValues[4] = "<%=i18nNow.getI18nString("emxFramework.Range.Priority.Pre-assigned", "emxFrameworkStringResource" 	, sLanguage)%>";
			myFrame.priorityValues = priorityValues;
			var difficultyValues = ["","",""];
			difficultyValues[0] = "<%=i18nNow.getI18nString("emxFramework.Range.Priority.Low", "emxFrameworkStringResource" 			, sLanguage)%>";
			difficultyValues[1] = "<%=i18nNow.getI18nString("emxFramework.Range.Priority.Medium", "emxFrameworkStringResource" 			, sLanguage)%>";
			difficultyValues[2] = "<%=i18nNow.getI18nString("emxFramework.Range.Priority.High", "emxFrameworkStringResource" 			, sLanguage)%>";
			myFrame.difficultyValues = difficultyValues;
			var classificationValues = ["","","",""];
			classificationValues[0] = "<%=i18nNow.getI18nString("emxRequirements.Range.Classification.Constraint", "emxRequirementsStringResource" 	, sLanguage)%>";
			classificationValues[1] = "<%=i18nNow.getI18nString("emxRequirements.Range.Classification.Functional", "emxRequirementsStringResource" 	, sLanguage)%>";
			classificationValues[2] = "<%=i18nNow.getI18nString("emxRequirements.Range.Classification.NonFunctional", "emxRequirementsStringResource" 	, sLanguage)%>";
			classificationValues[3] = "<%=i18nNow.getI18nString("emxRequirements.Range.Classification.None", "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.classificationValues = classificationValues;
			var changeValues = ["",""];
			changeValues[0] = "<%=i18nNow.getI18nString("emxFramework.Range.Default_Selection.No", "emxFrameworkStringResource" 	, sLanguage)%>";
			changeValues[1] = "<%=i18nNow.getI18nString("emxFramework.Range.Default_Selection.Yes", "emxFrameworkStringResource" 	, sLanguage)%>";
			myFrame.changeValues = changeValues;
			var ECColours = "<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.EC.Colour")%>";
			var sLabelActive    = "<%=i18nNow.getI18nString("emxRequirements.Filter.Active"							, "emxRequirementsStringResource" 	, sLanguage)%>";
			var sLabelReleased	= "<%=i18nNow.getI18nString("emxRequirements.dashboard.Released"					, "emxRequirementsStringResource" 	, sLanguage)%>";
			var sLabelAny		= "<%=i18nNow.getI18nString("emxRequirements.dashboard.Any"							, "emxRequirementsStringResource" 	, sLanguage)%>";
			var sLabelNone		= "<%=i18nNow.getI18nString("emxRequirements.dashboard.None"						, "emxRequirementsStringResource" 	, sLanguage)%>";
			var validationValues = ["","","","",""];
			validationValues[0] = "<%=i18nNow.getI18nString("emxFramework.Range.Validation_Status.Not_Validated", "emxFrameworkStringResource" 	, sLanguage)%>";
			validationValues[1] = "<%=i18nNow.getI18nString("emxFramework.Range.Validation_Status.Validation_Failed", "emxFrameworkStringResource" 	, sLanguage)%>";
			validationValues[2] = "<%=i18nNow.getI18nString("emxFramework.Range.Validation_Status.Validation_Passed", "emxFrameworkStringResource" 	, sLanguage)%>";
			validationValues[3] = "<%=i18nNow.getI18nString("emxRequirements.QuickChart.Validation_Status.NotReplayed", "emxRequirementsStringResource" 	, sLanguage)%>";
			validationValues[4] = "<%=i18nNow.getI18nString("emxRequirements.QuickChart.Validation_Status.hasNoTestCases", "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.validationValues=validationValues;
			engValidationValues = ["","","","",""];
			engValidationValues[0] = "<%=i18nNow.getI18nString("emxFramework.Range.Validation_Status.Not_Validated", "emxFrameworkStringResource" 	, "en")%>";
			engValidationValues[1] = "<%=i18nNow.getI18nString("emxFramework.Range.Validation_Status.Validation_Failed", "emxFrameworkStringResource" 	, "en")%>";
			engValidationValues[2] = "<%=i18nNow.getI18nString("emxFramework.Range.Validation_Status.Validation_Passed", "emxFrameworkStringResource" 	, "en")%>";
			engValidationValues[3] = "<%=i18nNow.getI18nString("emxRequirements.QuickChart.Validation_Status.NotReplayed", "emxRequirementsStringResource" 	, "en")%>";
			engValidationValues[4] = "<%=i18nNow.getI18nString("emxRequirements.QuickChart.Validation_Status.hasNoTestCases", "emxRequirementsStringResource" 	, "en")%>";
			
			myFrame.engValidationValues = engValidationValues;
			var validationColours = "<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.Validation.Colour")%>";
			var coveredValues = ["",""];
			coveredValues[0] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.coveredRequirement"			, "emxRequirementsStringResource" 	, sLanguage)%>";
			coveredValues[1] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.notCoveredRequirement"			, "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.coveredValues = coveredValues;
			var refinedValues = ["",""];
			refinedValues[0] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.refinedRequirement"			, "emxRequirementsStringResource" 	, sLanguage)%>";
			refinedValues[1] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.notrefinedRequirement"		, "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.refinedValues = refinedValues;
			var subValues = ["",""];
			subValues[0] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.hasSubReq"						, "emxRequirementsStringResource" 	, sLanguage)%>";
			subValues[1] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.hasNoSubReq"					, "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.subValues=subValues;
			var TestCasesValues = ["",""];
			TestCasesValues[0] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.hasTestCases"						, "emxRequirementsStringResource" 	, sLanguage)%>";
			TestCasesValues[1] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.hasNoTestCases"					, "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.TestCasesValues = TestCasesValues;
			var testCasesColours = "<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.TestCases.Colour")%>";
			var parameterLabel = "<%=sLabelPLMParameter%>";
			var PLMParameterValues = ["",""];
			PLMParameterValues[0] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.hasParameters"						, "emxRequirementsStringResource" 	, sLanguage)%>";
			PLMParameterValues[1] = "<%=i18nNow.getI18nString("emxRequirements.dashboard.hasNoParameters"					, "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.PLMParameterValues = PLMParameterValues;
			var parameterColours = "<%=EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.Parameters.Colour")%>";
			var subReqs = "<%=sSubReqsLabel%>";
			var colMap = findFrame(getTopWindow(), "detailsDisplay").colMap;
			var oXML = findFrame(getTopWindow(), "detailsDisplay").oXML;
			var aCategoriesResponsibility	= null;
			var aCategoriesTimeline			= null;		
			var chartStatus = null;
			var chartEC = null;
			var ResponsibilityChart = null;
			var chartTestCase = null;
			var chartValidation = null;
			var TimeLineChart = null;
			var FILTERING_OBJECTS_MANAGEMENT = [];
			myFrame.FILTERING_OBJECTS_MANAGEMENT = FILTERING_OBJECTS_MANAGEMENT;
			var summaryReqs = "<%=i18nNow.getI18nString("emxRequirements.QuickChart.Summary.Requirements"	, "emxRequirementsStringResource" 	, sLanguage)%>";
			myFrame.summaryReqs = summaryReqs;
			var allReqs = "<%=sAllReqs%>";
			myFrame.allReqs = allReqs;
			var colourRanges = <%=AttributeRangeColours.build()%>;
			myFrame.colourRanges = colourRanges;
			var reqTypesArray =  "<%=jsReqTypes%>".replace(/\[|\]/g,"").split(", ");
			getTopWindow().reqTypesArray = reqTypesArray;
			require(['DS/ENORMTCustoSB/panelRightContext'], function(){
				var OXMLTypeArg = createOXmlReqTypes(reqTypesArray);
				getTopWindow().OXMLTypeArg = OXMLTypeArg;
			});
			var gColourList = '<%=sColourList%>';
	
	function initPageCustom() {		
		var dashboardHeaders = document.getElementsByClassName("header");
		for(var i = 0; i<dashboardHeaders.length;i++){
			var headerName = dashboardHeaders[i].id;
			$('#'+headerName).css('border-radius', '4px 4px 4px 4px');
		}
		var dashboardCharts = document.getElementsByClassName("chart chartBorder");
		for(var i = 0; i<dashboardCharts.length;i++){
			var chartName = dashboardCharts[i].id;
			$('#'+chartName).fadeOut(10);
		}
	}		

	function generateColourList(ranges){
		var rangesLength = ranges.length;
		var selectedColours =  [];
		var colors = gColourList.split(",");
		for(var i=0;i<rangesLength;i++){
			var range = ranges[i];
			if(range!=null){
				selectedColours.push(colors[i]);
			}else{
				//generate last colours randomly
				selectedColours.push("#"+(Math.random().toString(16) + '000000').slice(2, 8));
			}	
		}	
		return selectedColours;
	}
		
	function DisplayBarChart(idChart,ranges, values,attributeName,colourArray){
		var colors = generateColourList(attributeName,ranges);
		var showLegendCheckBox=true;
		var Chart = new Highcharts.Chart({
			chart: {
				type			: 'bar',
				renderTo		: idChart.id,
				marginTop		: 15,
				marginRight		: 20,
				marginBottom	: 50,
				zoomType		: 'y',
				reflow			: false
			},
			colors : colors,
			title		: { text		: null  },
			credits 	: { enabled 	: false },
			exporting	: { enabled 	: false },
			legend		: { enabled 	: false },
			tooltip		: { enabled 	: false	},
			legend: {
				 layout: 'horizontal',
				 align: 'center',
		         verticalAlign: 'bottom',
	             borderWidth: 1,
	             backgroundColor: '#FFFFFF',
	             shadow: true,
	             y: 10
	        },
			plotOptions: {
				series: {
					pointWidth: 20,
	                pointPadding: 10,
	                cursor:'pointer',
	                point: {
	                    events: {
	                        click: function () {
	                        	this.series.select(false);
	                        	this.series.hide();
	                        	return updateTable(attributeName,this.series.name,false,Chart);
	                        }
	                    }
	                }
				},
				column: {
		            pointWidth: 10,
		            borderWidth: 1,
		            colorByPoint: true
		        },
				bar: {
					pointWidth: 20,
	                pointPadding: 0,
					dataLabels: { enabled : true },
					events: {
	                    legendItemClick: 
	                    	function(event) {
	                    		var show =true;
	                    		if(this.visible){
	                    			show=false;
	                    		}
	                    		return updateTable(attributeName,this.name,show,Chart);

	                    }
					}
				}						
			},				
			xAxis: {
				categories: [""],
				title: {
        			text: null
    			}
			},
			yAxis: {
				allowDecimals: false,
				alternateGridColor: '#F1F1F1',
				title: { text: null }
			}
		});
		for(var i=0; i<values.length; i++){
	        Chart.addSeries({                        
	            name: ranges[i],
	            data:  [values[i]]
	        }, true);
	        if(values[i]==0){
	        	Chart.series[i].hide();
			}
	        
	    }
		Chart.attributeName = attributeName;
		CHARTS[idChart.id] = Chart;
		updateObjectInFILTERING_OBJECTS_MANAGEMENT(attributeName,ranges,values);
		return Chart;
	}
	
	function displayPieChart(idChart,ranges, values,attributeName,colourArray){
		var colors = generateColourList(attributeName,ranges);
		var Chart = new Highcharts.Chart({
			chart: {
				type		: 'pie',
				renderTo	: idChart,
				marginRight	: 20,
				zoomType	: 'y'
			},
			colors : colors,
			title		: { text		: null  },
			credits 	: { enabled 	: false },
			exporting	: { enabled 	: false },
			plotOptions: {
				pie: {
					dataLabels: { 
						distance	: 5,
						enabled 	: true ,
						format		: '{point.name}: {point.percentage:.1f} %', 
						style		: { fontSize : '10px' }
					},
					point : {
						events:{
							legendItemClick : function() {
								updateTable(attributeName,this.name,!this.visible,Chart);									
							}
	                	}
					}
				},
				series: {
					allowPointSelect: false,
					showInLegend : true,
					point: {
	                    events: {
	                        click: function () {
	                        	this.setVisible(false);
	                        	return updateTable(attributeName,this.name,this.visible,Chart);
	                        }
	                    }
	                }
	            }
			},				
			xAxis: {
				categories: ranges,
				title: { text: null }						
			},
			yAxis: {
				alternateGridColor: '#F1F1F1',
				title: { text: null }						
			},
			tooltip: {
				formatter: function() {
					return '<b>'+ this.point.name +'</b>: '+ this.y;
				}
			} ,					
 			series: [{
				name: 'EC',
				data: [null]
			}]  
		});
		Chart.attributeName = attributeName;
		var data = [];
		for (var i=0;i<ranges.length;i++){
			data.push([ranges[i],values[i]])
		}
		Chart.series[0].setData(data);
		for(var i=0;i<values.length;i++){
			if(values[i]==0){
				Chart.series[0].data[i].setVisible(false);
			}
		}
		CHARTS[idChart.id] = Chart;
		updateObjectInFILTERING_OBJECTS_MANAGEMENT(attributeName,ranges,values);
		return Chart;
	}
	
	
	function displayChart(idHeader, idChart, idFilter,attributeName,colourArray){
		var colMapSize = colMap.columns.length;
		var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r");
		var valueIndex = null;
		var ranges = null;
		var values = null;
		if(attributeName=="SubRequirement"){
			ranges = subValues;
			values = getSubRequirementValues(attributeName,ranges);	
		}else if(attributeName ==  'CoveredRequirements'||attributeName ==  'RefiningRequirements'){
			ranges = attributeName == 'CoveredRequirements'?coveredValues:refinedValues;
			values = getDerivedRequirements(attributeName,ranges);
		}else{
			ranges = Object.keys(colMap['columns'][attributeName].rangeValues);
			values = getValues(attributeName);	
		}
		var Chart;
		if(ranges.length<=BARCHARTLIMIT){
			Chart = DisplayBarChart(idChart,ranges, values[0],attributeName,colourArray);
		}else{
			//display pieChart
			Chart = displayPieChart(idChart,ranges, values[0],attributeName,colourArray);
		}
		return Chart;
	}
	
	
	
	function toggleFilteredChart(idHeader, idChart, idFilter,attribute,colourArray) {
		var visibleChart	= $(idChart).is(':visible');	
		var visibleFilter 	= $(idFilter).css('visibility');	
		var chart;
		$(idHeader).toggleClass("expanded");
		if(visibleChart) {
			if(visibleFilter == "visible") {
				
				$(idFilter).css('border-bottom', '1px solid #5f747d'); 
				$(idHeader).css('border-radius', '4px 4px 0px 0px');
			} else {
				$(idHeader).css('border-radius', '4px 4px 4px 4px');
			}
			$(idChart).fadeOut(160);
			delete FILTERING_OBJECTS_MANAGEMENT[normalizeChars(attribute)];
			if(CHARTS[idChart.id]){
				delete CHARTS[idChart.id];
			}
			refreshViewHide(false,attribute);
			refreshQuickCharts();
		} else {
			
			var isEmpty=false;
			$(idHeader).css('border-radius', '4px 4px 0px 0px');
			$(idChart).fadeIn(160);
			$(idFilter).css('border-bottom', 'none');
			if($(idChart)[0].innerHTML.length==0){
				isEmpty = true;
			}
			if(isEmpty){
				chart = displayChart(idHeader, idChart, idFilter,attribute,colourArray);
			}else{
				chart = refreshChart(idChart.id, attribute);
			}
			//chart.setSize($(idChart).width(),$(idChart).height(), false);
		}    
	}			
	
	
	function selectTable(tableSelected) {
			tableName = tableSelected;
			updateTable();
		} 
				
		
		function resetFilter(idHeader, idChart, idFilter) {
			updateTable();
		}
				
			var oXML = findFrame(getTopWindow(), "detailsDisplay").oXML;
			var object = emxUICore.selectNodes(oXML, "/mxRoot/rows//r")[0];
			var objectId = object.attributes[0].value;
			var chartStatus;
			var chartPriority;
			var chartEC;
			var chartDifficulty;
			var chartResponsibility;
			var chartClassification;
			var chartSpecification;
			var chartSubRequirement;
			var chartDerRequirement;
			var chartTestCase;
			var chartPLMParameter;
			var chartValidation;
			var chartTimeline;
			var rightHeight = "330px";
			</script>	
			
		</head>
		<!--HAT1 ZUD IR-428176-3DEXPERIENCER2016x     R418: [IPAD Specific] : "Quick Chart" window doesn't shows "close" button. -->
		<body onLoad="initPageCustom();resizeFrames()" style="position: relative;height:100%;margin:0;padding:0;border:none">
		<div style="position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px; overflow: auto;"> 
		
	<% 	if(!"".equals(sOID)) { %>
			<form name="tableHeaderForm">
				<div id="pageHeadDiv" class="pageHead" >
					<table>
						<tr>
							<td class="page-title" style="resize:both">
								<h2><%=sDashboard%></h2>
							</td>
						</tr>
					</table>
				</div>
			</form>
			<div id="divPageBody" style="overflow-y: auto;top:40px;resize:both;display:block">
	<% 	} %>
			<!-- <div id="middle" onclick="showPanel();">
				<img  class="unhide" src="../common/images/utilTabsetArrow.gif" />
			</div>	 -->
			<div id="right" style="display:block;resize:both;top:0px;bottom:0px;overflow-x:hidden;overflow-y:auto;position:absolute">	
				<table width="100%">			
					<%-- <tr><td colspan="2">
						<div class="title link hidden"  onmouseover="this.style.color='#207cca';" onmouseout="this.style.color='transparent';" onclick="hidePanel();"><img  class="hide" src="../common/images/utilTabsetArrow.gif" /> <%=sLabelHidePanel%></div>
						<div class="title link" style="float:right;" onclick="resetSB();"><%=sLabelTotal%></div>								
					</td></tr>	 --%>
<%for(int i=0;i<strAttributes.length;i++){
	String colourList = "";
	String attribute = strAttributes[i].replace(" ","");
	String headerName = "divHeader"+attribute;
	String filterName = "divFilter"+attribute;
	String chartName = "divChart"+attribute;
	String dashSize = "170px";
	if(attribute.equalsIgnoreCase(ReqSchemaUtil.getSubRequirementRelationship(context).replace(" ",""))){
		dashSize = "130px";
		
	}
	String sLabel= i18nNow.getI18nString("emxRequirements.Dashboard." +attribute, "emxRequirementsStringResource", sLanguage);
 	if(!attribute.equalsIgnoreCase(ReqSchemaUtil.getDerivedRequirementRelationship(context).replace(" ",""))){
 		String property = "emxRequirements.Dashboard."+attribute+".Colour" ;
 		try{
 			colourList =  EnoviaResourceBundle.getProperty(context,property);
 		}catch(Exception e){
 			colourList="";
 		}
 		if(!attribute.equals("SubRequirement")||!ChildrenTypes.contains(rootObjType)){
%>					
					<tr><td colspan="2" id="dashBoard">
						<div class="header"	id="<%=headerName%>" onclick="toggleFilteredChart(<%=headerName%>, <%=chartName%>,<%=filterName%>,'<%=attribute%>','<%=colourList%>');"><%=sLabel%></div><%--XSSOK--%>
						<div class="filter" id="<%=filterName%>"  onclick="resetFilter(<%=headerName%>, <%=chartName%>, <%=filterName%>)"></div><%--XSSOK--%>
						<div class="chart chartBorder"	id="<%=chartName%>"  style="height:<%=dashSize%>;cursor:pointer;"></div><%--XSSOK--%>
					</td></tr>

<%		
		}
	}else{ 
	//for covered
	String covered = null;
	String refined = null;	
	try{
		covered =  EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.DerivedRequirement.Covered.Colour");
		refined =  EnoviaResourceBundle.getProperty(context,"emxRequirements.Dashboard.DerivedRequirement.Refined.Colour");
	}catch(Exception e){
		//ignore this exception
	}
	
			
%>
					<tr><td width="50%">
						<div class="header small posLeft" id="divHeaderCoveredDerReq" onclick="toggleFilteredChart(divHeaderCoveredDerReq, divChartCoveredDerReq, divFilterCoveredDerReq,'CoveredRequirements','<%=covered%>');toggleFilteredChart(divHeaderRefinedDerReq, divChartRefinedDerReq, divFilterRefinedDerReq,'RefiningRequirements','<%=refined%>');"><%=sCoveredLabel%></div>			
						<div class="filter small posLeft" id="divFilterCoveredDerReq" onclick="resetFilter(divHeaderSubRequirement, divChartSubRequirement, divFilterSubRequirement);"></div>
						<div class="chart chartBorder small posLeft" id="divChartCoveredDerReq"  style="height:130px;cursor:pointer;"></div>			
						</td><td width="50%">
						<div class="header small posRight"	id="divHeaderRefinedDerReq" onclick="toggleFilteredChart(divHeaderCoveredDerReq, divChartCoveredDerReq, divFilterCoveredDerReq,'CoveredRequirements','<%=covered%>');toggleFilteredChart(divHeaderRefinedDerReq, divChartRefinedDerReq, divFilterRefinedDerReq,'RefiningRequirements','<%=refined%>');"><%=sRefinedLabel%></div>			
						<div class="filter small posRight" id="divFilterRefinedDerReq" onclick="resetFilter(divHeaderDerRequirement, divChartDerRequirement, divFilterDerRequirement);"></div>
						<div class="chart chartBorder small posRight"	id="divChartRefinedDerReq"  style="height:130px;cursor:pointer;"></div>			
					</td></tr>		
<%	}
}
%>
					<tr><td colspan="2">
						<div class="header"	id="divHeaderStatus" onclick="toggleChartFilter(divHeaderStatus, divChartStatus, chartStatus, divFilterStatus);"><%=sLabelStatus%></div>			
						<div class="filter" id="divFilterStatus"  onclick="resetFilter(divHeaderStatus, divChartStatus, divFilterStatus);"></div>
						<div class="chart chartBorder"	id="divChartStatus"  style="height:240px;cursor:pointer;"></div>			
					</td></tr>
					<tr><td colspan="2">
						<div class="header"	id="divHeaderEC" onclick="toggleChartFilter(divHeaderEC, divChartEC, chartEC, divFilterEC);"><%=sLabelPendingEC%></div>			
						<div class="filter" id="divFilterEC" onclick="resetFilter('RelatedChanges', divChartEC, divFilterEC);"></div>
						<div class="chart chartBorder"	id="divChartEC"  style="height:140px;cursor:pointer;"></div>			
					</td></tr>			
					<%-- <tr><td colspan="2">
						<div class="header"	id="divHeaderResponsibility" onclick="toggleChartFilter(divHeaderResponsibility, divChartResponsibility, chartResponsibility, divFilterResponsibility);"><%=sLabelResponsibility%></div>			
						<div class="filter" id="divFilterResponsibility" onclick="resetFilter(divHeaderResponsibility, divChartResponsibility, divFilterResponsibility');"></div>
						<div class="chart chartBorder"	id="divChartResponsibility"  style="height:130px;cursor:pointer;"></div>	<!-- MODIFFFFFFF height !!!!!!!!!!!!!!!!!! -->		
					</td></tr>	 --%>
					<tr><td colspan="2">
						<div class="header" id="divHeaderTestCase" onclick="toggleChartFilter(divHeaderTestCase, divChartTestCase, chartTestCase, divFilterTestCase);"><%=sLabelTestCases%></div>			
						<div class="filter" id="divFilterTestCase" onclick="resetFilter(divHeaderTestCase, divChartTestCase, divFilterTestCase);"></div>
						<div class="chart chartBorder" id="divChartTestCase"  style="height:120px;cursor:pointer;"></div>
					</td></tr>		
					<tr><td colspan="2">
						<div class="header" id="divHeaderPLMParameter" onclick="toggleChartFilter(divHeaderPLMParameter, divChartPLMParameter, chartPLMParameter, divFilterPLMParameter);"><%=sLabelPLMParameter%></div>		
						<div class="filter" id="divFilterPLMParameter" onclick="resetFilter(divHeaderPLMParameter, divChartPLMParameter, divFilterPLMParameter);"></div>
						<div class="chart chartBorder" id="divChartPLMParameter"  style="height:120px;cursor:pointer;"></div>
					</td></tr>	
					<tr><td colspan="2">
						<div class="header"	id="divHeaderValidation" onclick="toggleChartFilter(divHeaderValidation, divChartValidation, chartValidation, divFilterValidation);"><%=sLabelValidation%></div>			
						<div class="filter" id="divFilterValidation" onclick="resetFilter(divHeaderValidation, divChartValidation, divFilterValidation);"></div>
						<div class="chart chartBorder"	id="divChartValidation"  style="height:200px;cursor:pointer;"></div>			
					</td></tr>					
<%-- 					<tr><td colspan="2">
						<div class="header"	id="divHeaderTimeline" onclick="toggleChartFilter(divHeaderTimeline, divChartTimeline, chartTimeline, divFilterTimeline);"><%=sLabelTimeline%></div>			
						<div class="filter" id="divFilterTimeline" onclick="resetFilter(divHeaderTimeline, divChartTimeline, divFilterTimeline);"></div>
						<div class="chart chartBorder"	id="divChartTimeline"  style="height:220px;cursor:pointer;"></div>			
					</td></tr>	 --%>				
				</table>				
				<br/>
			</div>			
			</div>
			<div id="divPageFoot" style="display:block;resize:both;bottom:0px;position:absolute">
				<div id="divDialogButtons">
					<table>
						<tr>
							<td class=nbRequirements align="left"><%=sAllReqs %></td>
							<td class='buttons' align="right">
								<table>
									<tbody>
										<tr>
											<td>
												<div id="cancelImage">
													<a onclick="closePanel()" href="javascript:void(0)">
													<img alt="Cancel" border="0" src="images/buttonDialogCancel.gif">
													</a>
												</div>
											</td>
											<td>
												<div id='cancelText'>
													<a class='button' onclick="closePanel()" href="javascript:void(0)">Close</a>
												</div>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
					</table>
				</div>	
			</div>
			</div>
		</body>
	</head>
<%
}
%>


