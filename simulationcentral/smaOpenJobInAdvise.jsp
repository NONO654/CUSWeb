<%-- Common Includes --%>
<%@page import="java.util.Iterator"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.domain.util.MqlUtil"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.Parameters"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.AccessUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.AnalyticsCase" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.AnalyticsCaseEntityWUtil"%>

<%@page import = "com.matrixone.apps.domain.util.ContextUtil" %>

<%@page import = "matrix.db.BusinessObject" %>
<%@page import = "matrix.db.RelationshipType" %>
<%@page import = "matrix.db.Relationship" %>
<%@page import = "matrix.db.Attribute" %>
<%@page import = "matrix.db.Context"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "matrix.db.User"%>
<%@page import = "matrix.util.MatrixException"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "matrix.util.ErrorMessage"%>

<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>
<%@page import = "java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "java.util.Vector"%>
<%@page import = "java.util.Random" %>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationJob"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.JobDescriptor"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"	src="./smaAdviseLaunchHelper.js"></script>
<script	type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js" ></script>
<script type="text/javascript" src="../simulationcentral/smaAdviseOpenWidget.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<!--  <html> and <head> were added by something above here.   -->
</head>
<body>

<%
    boolean closeTop = false;

	String[] rowIds = null;
	String jobId = "";

    String objectAction = emxGetParameter(request, "objectAction");
    String strObjId = emxGetParameter(request, "objectId");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String sRowIds[] = request.getParameterValues("emxTableRowId");
    String parentOid = null;
    String runAsStr = emxGetParameter(request, "runAs");		 
    boolean runAs = Boolean.parseBoolean(runAsStr);
    
    List<String> caseIdList = new ArrayList<String>();

    // Possibilities are 
    // 1.(sRowIds.length > 0) => single / multiple emxTableRow ids from Performance Study
    // 							which contain objectids in them 
    // 2.(sRowIds.length = 0) => single object id from ProcessCompose. This has to be
    // changed into the form of emxTableRowID
	if(sRowIds == null){
		sRowIds = new String[1];
		sRowIds[0] = "|"+strObjId+"|0";
	}
	
	String symbtype_case = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_AnalyticsCase);
	String symbRel_vaultedObject = SimulationUtil.getSchemaProperty( DomainConstants.RELATIONSHIP_VAULTED_OBJECTS);
	String vault = SimulationUIUtil.getUserDefaultVault(context);
	String symbPolicy_case = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_policy_AnalyticsCase);
	StringList selects = new StringList(1);
	String name = "";
       
	selects.addElement(DomainObject.SELECT_ID);
       selects.addElement(DomainObject.SELECT_TYPE);
       selects.addElement(DomainObject.SELECT_NAME);
       
       String sRel = "*";
	String sTypes = "SYMBOLIC_type_AnalyticsCase,Analytics Case";
	Boolean needsNewCase = true;
	
	List<String> jobIdArray = new ArrayList<String>();
	String caseName = "";
	String caseId = null;
	
	for(int i=0; i<sRowIds.length; i++){
		String thisRowId = sRowIds[i];
		rowIds = thisRowId.split("\\|");
		jobIdArray.add(rowIds[1]);
	}

	for(int j=0; j<jobIdArray.size(); j++){
		
		SimulationJob simJob = new SimulationJob(jobIdArray.get(j));
		caseName = simJob.getInfo(context, "name");
		name = "AnalyticsCase-" + caseName + "-" + System.currentTimeMillis();
		
		MapList ML = simJob.getRelatedObjects(context,sRel,sTypes,true,false,0,selects,
				null,null,null,0,null,null,null);
		
		Iterator itr = ML.listIterator();
		while (itr.hasNext()){
			
			Map busMap = (Map) itr.next();
			String busType = (String) busMap.get(DomainObject.SELECT_TYPE);
			String thisCaseId = (String) busMap.get (DomainObject.SELECT_ID);
			
			Boolean caseWithAllJobs = AnalyticsCaseEntityWUtil.checkIfAllJobsExistInCase(context, thisCaseId, jobIdArray);
			
			if(caseWithAllJobs){
				needsNewCase = false;
				caseId = thisCaseId;
				break;
			}
		}
		
		if(! needsNewCase) {
			break;
		}	
	}
	
	if(needsNewCase){
		ContextUtil.startTransaction(context, true);
		DomainObject caseObject = new DomainObject();
		caseObject.createObject(context, symbtype_case, name, null, symbPolicy_case, vault);
		caseObject.open(context);
		caseId = caseObject.getId(context);
		String attr_title = SimulationUtil.getSchemaProperty(DomainSymbolicConstants.SYMBOLIC_attribute_Title);
		caseObject.setAttributeValue(context, attr_title, name);
		
		for(int k=0; k<jobIdArray.size(); k++){
			HashMap programMap = new HashMap();
			HashMap paramMap = new HashMap();
			paramMap.put("New OID", jobIdArray.get(k)); //ID of connector from job to activity
			paramMap.put("New Value", jobIdArray.get(k)); //Job ID analytics case should be connected to
			paramMap.put("objectId", caseId);  //This is the case id.
			programMap.put("paramMap", paramMap);
			JPO.invoke(
				context,
				"jpo.simulation.AnalyticsCase",
				null,
				"CreateAndConnect",
				JPO.packArgs(programMap));
		}
		ContextUtil.commitTransaction(context);
	}
	
	if(caseId != null){
	%>
	<script>
		openResultAnalytics("<%=caseId%>");
	</script>
	<%
	}else{
	%>
	<script>
		openResultAnalytics("invalid_id");
	</script>
	<%
	}

%>
</body>
</html>

