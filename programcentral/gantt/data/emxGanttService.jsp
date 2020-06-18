<%@page import="javax.json.JsonReader"%>
<%@page import="javax.json.Json"%>
<%@page contentType="text/xml;charset=ISO-8859-1" %>
<%@page import="com.matrixone.json.JSONObject"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Iterator"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.JsonArray"%>
<%@page import="javax.json.JsonArrayBuilder"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="java.util.Vector"%>
<%@page import="java.util.stream.Collectors"%>
<%@page import="com.dassault_systemes.enovia.e6wv2.foundation.jaxb.Dataobject"%>
<%@page import="com.dassault_systemes.enovia.tskv2.ProjectSequence"%>
<%@include file="../emxGantt.inc" %>

<%!
	MapList getExternalProjects(Context context, Map<String, String> paramMap){
		MapList externalProjectMapList = new MapList();
		try {
			String strProjectId = (String) paramMap.get("projectId");
			externalProjectMapList = (MapList) JPO.invoke(context, "emxProjectSpace", null,
														  "getActiveProjects", JPO.packArgs(paramMap),MapList.class);

			Iterator itr = externalProjectMapList.iterator();
			while (itr.hasNext()) {
				Map mpExcludeProject = (Map) itr.next();

				String id = (String) mpExcludeProject.get(DomainConstants.SELECT_ID);
				if (strProjectId.equals(id)) {
					externalProjectMapList.remove(mpExcludeProject);
					itr = externalProjectMapList.iterator();
				}

				String strType = (String) mpExcludeProject.get(DomainConstants.SELECT_TYPE);
				if (DomainConstants.TYPE_PROJECT_CONCEPT.equals(strType)) {
					externalProjectMapList.remove(mpExcludeProject);
					itr = externalProjectMapList.iterator();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return externalProjectMapList;
	}

JsonObjectBuilder getExternalProjectTaskId(Context context, Map<String, String> paramMap){
	JsonObjectBuilder jsonQueryBuilder = Json.createObjectBuilder();
	try {
		String extProjectName = (String) paramMap.get("extProjectName");
		String fromSequenceId = (String) paramMap.get("fromSequenceId");
		StringList busSelects = new StringList(2);
    	busSelects.add(ProgramCentralConstants.SELECT_ID);
    	busSelects.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
    	String busWhere = "name=='"+extProjectName+"'";
		String typePattern = ProgramCentralConstants.TYPE_PROJECT_SPACE + "," + ProgramCentralConstants.TYPE_PROJECT_CONCEPT;
		MapList projectList = DomainObject.findObjects(context, typePattern, "*", "*", "*",DomainConstants.QUERY_WILDCARD, busWhere, true, busSelects);
		if(projectList.size()==0){
			jsonQueryBuilder.add("success","404");
		}else{
			String taskID = "";
			Map project = (Map) projectList.get(0);
			String projectId = (String)project.get(ProgramCentralConstants.SELECT_ID);
			String projectPALId = (String)project.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);

			ProjectSequence extps = new ProjectSequence(context, projectPALId);
			Map<String,Dataobject>  extSequenceData = extps.getSequenceData(context);
			Set<String> keys = extSequenceData.keySet();

			for (String key : keys) {
				String seqID = (String) extSequenceData.get(key).getDataelements().get(ProgramCentralConstants.KEY_SEQ_ID);
				if(seqID.equalsIgnoreCase(fromSequenceId)){
					taskID = key;
					break;
					}
				}
				if(ProgramCentralUtil.isNullString(taskID)){
					jsonQueryBuilder.add("success","404");
				}else{
					jsonQueryBuilder.add("success","200");
					jsonQueryBuilder.add("taskId",taskID);
				}
		}
		
	} catch (Exception e) {
		e.printStackTrace();
		jsonQueryBuilder.add("success","404");
	}
	return jsonQueryBuilder;
}
//======================= API to return last Sequence ID for a Project .
JsonObjectBuilder getExternalProjectLastSequenceId(Context context, Map<String, String> paramMap){
	JsonObjectBuilder jsonQueryBuilder = Json.createObjectBuilder();
	try {
		String projectId = (String) paramMap.get("projectId");
		String lastSeq = "0";
		StringList busSelects = new StringList();
    	busSelects.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
			DomainObject project = new DomainObject(projectId);
			String projectPALId = (String)project.getInfo(context, ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);

			ProjectSequence extps = new ProjectSequence(context, projectPALId);
			Map<String,Dataobject>  extSequenceData = extps.getSequenceData(context);
			Set<String> keys = extSequenceData.keySet();

			for (String key : keys) {
				String seqID = (String) extSequenceData.get(key).getDataelements().get(ProgramCentralConstants.KEY_SEQ_ID);
				if(Integer.parseInt(seqID)>=Integer.parseInt(lastSeq)){
					lastSeq = seqID;
				}
			}	
				if(ProgramCentralUtil.isNullString(lastSeq)){
					jsonQueryBuilder.add("success","404");
				}else{
					jsonQueryBuilder.add("success","200");
					jsonQueryBuilder.add("lastSequence",lastSeq);
				}
		
	} catch (Exception e) {
		e.printStackTrace();
		jsonQueryBuilder.add("success","404");
	}
	return jsonQueryBuilder;
}
//==
%>

<%

//In absence of below code, IE caches and shows old data of filter, this does not allow IE to 
//cache the filter data and show latest data.
response.addHeader("Pragma", "no-cache");
response.addHeader("Cache-Control", "no-cache");
response.addHeader("Cache-Control", "must-revalidate");
response.addHeader("Expires", "Mon, 8 Aug 2006 10:00:00 GMT");

String outPutString = DomainConstants.EMPTY_STRING;

try {
	String mode = emxGetParameter(request,"mode");
	String objectId = emxGetParameter(request,"objectId");
	String language = emxGetParameter(request,"language");
	
	if ("full".equalsIgnoreCase(mode)) {
		GanttChart ganttChart = new GanttChart(context,request);
		outPutString = ganttChart.load();
		
	} else if("cacheTaskChangeData".equalsIgnoreCase(mode)) {
		GanttChart ganttChart = new GanttChart(context,request);
		String queryString = request.getQueryString();
		ganttChart.cacheTaskChangeData(queryString);		
		
	} else if("cacheDependencyChangeData".equalsIgnoreCase(mode)) {
		JsonObjectBuilder jsonQueryBuilder = Json.createObjectBuilder();
		Enumeration nameEnumration = emxGetParameterNames(request);
		while(nameEnumration.hasMoreElements()){
			Object obj = nameEnumration.nextElement();
			String key = (String)obj;
			String value = emxGetParameter(request,key);
			jsonQueryBuilder.add(key, value);				
		}		
		JsonObject queryStringPayLoad =jsonQueryBuilder.build();		
		
		JsonReader jsonReader = Json.createReader(request.getReader());
		JsonArray requestPayload = jsonReader.readArray();
		jsonReader.close();
		
		GanttChart ganttChart = new GanttChart(context,request);
		ganttChart.cacheDependencyData(requestPayload,queryStringPayLoad);
		
	} else if("cacheCustomColumn".equalsIgnoreCase(mode)) {

		String queryString = request.getQueryString();

		GanttChart ganttChart = new GanttChart(context,request);
		Object object = ganttChart.cacheCustomColumnData(queryString);
		
	} else if("saveData".equalsIgnoreCase(mode)) {
		GanttChart ganttChart = new GanttChart(context,request);
		List<Map<String,Map>> startDateMapList  = (List<Map<String,Map>>)session.getAttribute("startDateMapList");
		List<Map<String,Map>> finishDateMapList = (List<Map<String,Map>>)session.getAttribute("finishDateMapList");
		List<Map<String,Map>> durationMapList 	= (List<Map<String,Map>>)session.getAttribute("durationMapList");
		List<Map<String,Map>> dependencyMapList = (List<Map<String,Map>>)session.getAttribute("dependencyMapList");
		
		MapList customColumnMapList = (MapList)session.getAttribute("customColumnMapList");
		
		Map allDataMap = new HashMap();
		allDataMap.put("startDateMapList",startDateMapList);
		allDataMap.put("finishDateMapList",finishDateMapList);
		allDataMap.put("durationMapList",durationMapList);
		allDataMap.put("dependencyMapList",dependencyMapList);
		allDataMap.put("taskIdToOrderJSONStr", request.getParameter("taskIdToOrderJSONStr"));
		
		session.removeAttribute("durationMapList");
		session.removeAttribute("startDateMapList");
		session.removeAttribute("finishDateMapList");
		session.removeAttribute("dependencyMapList");
		session.removeAttribute("customColumnMapList");
		
        request.getParameterNames();	
		JsonObjectBuilder jsonQueryBuilder = Json.createObjectBuilder();
		
		Enumeration en = request.getParameterNames();
		while(en.hasMoreElements()){
			Object obj = en.nextElement();
			String key = (String)obj;
			String value = request.getParameter(key);
			jsonQueryBuilder.add(key, value);				
		}		
			
		JsonObject queryStringPayLoad =jsonQueryBuilder.build();		
		JsonReader jsonReader = Json.createReader(request.getReader());
		JsonObject requestPayload = jsonReader.readObject();
		jsonReader.close();

		JsonObjectBuilder syncRequestPayloadBuilder = Json.createObjectBuilder();
		
		syncRequestPayloadBuilder.add("requestPayload", requestPayload);
		syncRequestPayloadBuilder.add("queryStringPayLoad", queryStringPayLoad);
		
		outPutString = ganttChart.sync(allDataMap, customColumnMapList, syncRequestPayloadBuilder.build()).toString();
		
	} else if("resetData".equalsIgnoreCase(mode)) {
		
		List<Map<String,Map>> startDateMapList  = (List<Map<String,Map>>)session.getAttribute("startDateMapList");
		List<Map<String,Map>> finishDateMapList = (List<Map<String,Map>>)session.getAttribute("finishDateMapList");
		List<Map<String,Map>> durationMapList 	= (List<Map<String,Map>>)session.getAttribute("durationMapList");
		List<Map<String,Map>> dependencyMapList = (List<Map<String,Map>>)session.getAttribute("dependencyMapList");
		
		if(startDateMapList == null && finishDateMapList == null && durationMapList == null && dependencyMapList == null) {
			outPutString="false";
		} else {
			session.removeAttribute("durationMapList");
			session.removeAttribute("startDateMapList");
			session.removeAttribute("finishDateMapList");
			session.removeAttribute("dependencyMapList");
			outPutString = "true";	
		}
		
	} else if("basic".equalsIgnoreCase(mode)) {
		GanttChart ganttChart = new GanttChart(context,request);
		MapList taskInfoMapList = (MapList) session.getAttribute("objectList");
		outPutString = ganttChart.load(taskInfoMapList);
		
	} /* else if("loadFieldString".equalsIgnoreCase(mode)) {
		GanttChart ganttChart = new GanttChart(context,request);
		out.clear();		
		response.setContentType("application/json;charset=UTF-8");
		JsonArray fieldArray = ganttChart.getFieldNameTypeString();
		out.write(fieldArray.toString());
		return;
		
	} */ else if("loadcolumnLabelDataIndexValueMap".equalsIgnoreCase(mode)) {
		GanttChart ganttChart = new GanttChart(context,request);
		out.clear();
		response.setContentType("application/json;charset=UTF-8");
		JsonArray fieldArray = ganttChart.getColumnArray();
		out.write(fieldArray.toString());
		return;
		
	} else if("getInfra".equalsIgnoreCase(mode)) {
		GanttChart ganttChart = new GanttChart(context,request);
		out.clear();
		response.setContentType("application/json;charset=UTF-8");
		JsonObject infra = ganttChart.getInfra(context);
		out.write(infra.toString());
		return;
		
	} else if("preDeleteCheck".equalsIgnoreCase(mode)) {
		out.clear();		
		response.setContentType("application/json;charset=UTF-8");
		GanttChart ganttChart = new GanttChart(context,request);
		JsonObject jsonObjresponse = ganttChart.preDeleteCheck();
		out.write(jsonObjresponse.toString());
		return; 
	} else if("getExternalProjectsName".equalsIgnoreCase(mode)) {
		out.clear();		
		response.setContentType("application/json;charset=UTF-8");
		
		Map<String, String> paramMap = new HashMap<String, String>();
		paramMap.put("projectId", objectId);
		List<Map<String, String>> externalProjectMapList = getExternalProjects(context, paramMap);
		JsonArrayBuilder externalProjectNameArr = Json.createArrayBuilder();
		for(Map<String, String> externalProjectMap : externalProjectMapList) {
			String extProjectName = externalProjectMap.get(ProgramCentralConstants.SELECT_NAME);
			externalProjectNameArr.add(extProjectName);
		}
		out.write(externalProjectNameArr.build().toString());
		return; 
	} else if("getCriticalTasks".equalsIgnoreCase(mode)){
		GanttChart ganttChart = new GanttChart(context,request);
		JsonArray jsonArray = ganttChart.getCriticalTasks(context);
		out.write(jsonArray.toString());
		return;
	} 

else if("getAssignments".equalsIgnoreCase(mode)){
	String taskId = emxGetParameter(request, "taskId");
	String taskProjectId = emxGetParameter(request, "taskProjectId");
	String projectStart = emxGetParameter(request, "projectStart");
	String projectEnd = emxGetParameter(request, "projectEnd");
	GanttChart ganttChart = new GanttChart(context, request);
		try {
			Map selectedTaskInfo = new HashMap();
			selectedTaskInfo.put(ProgramCentralConstants.SELECT_ID, taskId);
			selectedTaskInfo.put(ProgramCentralConstants.SELECT_PROJECT_ID, taskProjectId);
			selectedTaskInfo.put("Project Start", projectStart);
			selectedTaskInfo.put("Project End", projectEnd);
			JsonObject json = ganttChart.getAssignments(context, selectedTaskInfo);
			out.write(json.toString());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return;
	} else if("getResources".equalsIgnoreCase(mode)){
		String resourceName = emxGetParameter(request, "query");
		GanttChart ganttChart = new GanttChart(context, request);
		try {
			JsonObject json = ganttChart.getResources(context, resourceName);
			out.write(json.toString());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return;
	} else if("assign".equalsIgnoreCase(mode)){
		String taskId = emxGetParameter(request, "taskId");
		String resourceId = emxGetParameter(request, "resourceId");
		String taskProjectId = emxGetParameter(request, "taskProjectId");
		String projectStart = emxGetParameter(request, "projectStart");
		String projectEnd = emxGetParameter(request, "projectEnd");

		Map selectedTaskInfo = new HashMap();
		selectedTaskInfo.put(ProgramCentralConstants.SELECT_ID, taskId);
		selectedTaskInfo.put(ProgramCentralConstants.SELECT_PROJECT_ID, taskProjectId);
		selectedTaskInfo.put("Project Start", projectStart);
		selectedTaskInfo.put("Project End", projectEnd);

		GanttChart ganttChart = new GanttChart(context, request);
		JsonObject json = ganttChart.assign(context, selectedTaskInfo, resourceId);
		out.write(json.toString());
		return;
	} else if("getExternalProjectsTaskId".equalsIgnoreCase(mode)) {
		out.clear();		
		response.setContentType("application/json;charset=UTF-8");
		String extProjectName = emxGetParameter(request,"extProjectName");
		String fromSequenceId = emxGetParameter(request,"fromSequenceId");
		
		Map<String, String> paramMap = new HashMap<String, String>();
		paramMap.put("extProjectName", extProjectName);
		paramMap.put("fromSequenceId", fromSequenceId);
		
		JsonObjectBuilder jsonObjResponse = getExternalProjectTaskId(context, paramMap);

		out.write(jsonObjResponse.build().toString());
		return; 
	}	else if("getProjectsLastSeq".equalsIgnoreCase(mode)) {
		out.clear();		
		response.setContentType("application/json;charset=UTF-8");
		String projectId = emxGetParameter(request,"projectId");
		
		Map<String, String> paramMap = new HashMap<String, String>();
		paramMap.put("projectId", projectId);
		
		JsonObjectBuilder jsonObjResponse = getExternalProjectLastSequenceId(context, paramMap);

		out.write(jsonObjResponse.build().toString());
		return; 
	}else if("getCustomizationFlag".equalsIgnoreCase(mode)) {
		out.clear();		
		response.setContentType("application/json;charset=UTF-8");
		boolean isCustomizedEnvironment = (Boolean)JPO.invoke(context,"emxGantt",null,"getCustomizationFlag",JPO.packArgs(""),Boolean.class);		
		JsonObjectBuilder jsonObjResponse = Json.createObjectBuilder();
		jsonObjResponse.add("isCustomizedEnvironment",isCustomizedEnvironment);		
		out.write(jsonObjResponse.build().toString());
		return; 
	} 
} catch(Exception e) {
	e.printStackTrace();
}
%>
<%=outPutString %> <%--XSSOK--%>
