<!DOCTYPE html>
 <%@page import="com.matrixone.apps.program.GanttChart"%>
 <%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
 <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"> 

<%@ include file="../../emxUICommonAppInclude.inc"%>

<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<script language="javascript" src="../../common/scripts/emxUICore.js"></script>
<script type="text/javascript"
	src="../../common/scripts/jquery-latest.js"></script>
<script type="text/javascript"
	src="../../webapps/AmdLoader/AmdLoader.js"></script>
<html>
<body id="ganttbody">
<FORM id="ganttForm" name="ganttForm" METHOD=POST ACTION="">
</FORM>
</body>
<%
	String mode = request.getParameter("mode");
	String objectId = request.getParameter("objectId");
	String objectType = request.getParameter("objectType");
	String referenceId = request.getParameter("referenceId");
	String viewId = request.getParameter("viewId");
	String fromIFWE = request.getParameter("fromIFWE");
	String physicalId = request.getParameter("physicalId");
	String title = request.getParameter("title");
	String languageString = GanttChart.getLanguage(context);
	boolean renderGanttChart = true; 
	String widgetErrMessage = "";
		ProjectSpace project = new ProjectSpace(objectId);
	
		//Check for widget
		if(ProgramCentralUtil.isNotNullString(fromIFWE) && "true".equalsIgnoreCase(fromIFWE)){
		//Get ObjectId	
		project.setId(physicalId);
		try {
			String otherObjectId = project.getInfo(context, ProgramCentralConstants.SELECT_ID);
			if (ProgramCentralUtil.isNotNullString(otherObjectId)&& !otherObjectId.equalsIgnoreCase(objectId)) {
				objectId = otherObjectId;
			}
		} catch (Exception r) {
			r.printStackTrace();
			renderGanttChart = false;
			widgetErrMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.Common.NoProjectFound", languageString);
			widgetErrMessage = "<h3>" + widgetErrMessage + ":" + title + "</h3>";
		}
	}
	
	if(ProgramCentralConstants.VIEW_BASELINE_VERSUS_CURRENT_BASELINE.equals(viewId)
			&& UIUtil.isNullOrEmpty(referenceId) && renderGanttChart) {
	
		//TODO Move this code to ProejctSpace bean.
		StringList baselineSelect = new StringList();
		baselineSelect.add(ProgramCentralConstants.SELECT_ID);
		baselineSelect.add(ProgramCentralConstants.SELECT_ATTRIBUTE_TASK_BASELINE_CURRENT_FINISH_DATE);
		MapList baselines = project.getProjectBaselines(context, baselineSelect, null);
		if(!baselines.isEmpty()){
			baselines.sort(ProgramCentralConstants.SELECT_ATTRIBUTE_TASK_BASELINE_CURRENT_FINISH_DATE, ProgramCentralConstants.DESCENDING_SORT, ProgramCentralConstants.SORTTYPE_DATE);
			Map baseline = (Map)baselines.get(0);
			referenceId = (String) baseline.get(ProgramCentralConstants.SELECT_ID);
		}else{
			referenceId = ProgramCentralConstants.EMPTY_STRING;
    }
    }
	
	StringBuffer sbParams = new StringBuffer();
	Enumeration enu = (Enumeration) request.getParameterNames();
	sbParams.append("&").append("referenceId").append("=").append(referenceId);
	while(enu.hasMoreElements()){
		String param = (String)enu.nextElement();
		if("mode".equals(param)){ continue;}
		Object value = (Object)emxGetParameter(request, param);
		sbParams.append("&").append(param).append("=").append(value);
    }
	String sParams = sbParams.toString();
%>  
<script language="javascript">
var AppConstants;
var renderGantt = '<%=XSSUtil.encodeURLForServer(context, Boolean.toString(renderGanttChart))%>';
var widgetErrMsg = '<%=widgetErrMessage%>';
if(renderGantt =="true"){
var mode = '<%=XSSUtil.encodeURLForServer(context, mode)%>';
var objectId = '<%=XSSUtil.encodeURLForServer(context, objectId)%>';
var objectType = '<%=XSSUtil.encodeURLForServer(context, objectType)%>';
var referenceId = '<%=XSSUtil.encodeURLForServer(context, referenceId)%>';
var viewId = '<%=XSSUtil.encodeURLForServer(context, viewId)%>';
var languageString = '<%=XSSUtil.encodeURLForServer(context, languageString)%>';
var commonParameter ="";
// if ( mode             != "null") {commonParameter +=  "&" + "mode"               + "=" + mode              ;}
if ( objectId         != "null") {commonParameter +=  "&" + "objectId"           + "=" + objectId          ;}
if ( objectType       != "null") {commonParameter +=  "&" + "objectType"         + "=" + objectType        ;}
if ( referenceId      != "null") {commonParameter +=  "&" + "referenceId"        + "=" + referenceId       ;}
if ( viewId           != "null") {commonParameter +=  "&" + "viewId"             + "=" + viewId            ;}
if ( languageString   != "null") {commonParameter +=  "&" + "languageString"     + "=" + languageString    ;}

languageString = languageString.charAt(0).toUpperCase() + languageString.slice(1);
var viewURL = "../gantt/emxGanttChart.jsp?mode="+ mode + commonParameter;
var taskRepository = "data/emxGanttService.jsp?mode=" + mode + commonParameter;
//var loadFieldURL = "data/emxGanttService.jsp?mode=loadFieldString" + commonParameter;
var getInfra = "data/emxGanttService.jsp?mode=getInfra" + commonParameter;
var cacheTaskChangeDataURL = "../gantt/data/emxGanttService.jsp?mode=cacheTaskChangeData&"+commonParameter;
var cacheDependencyDataURL = "../gantt/data/emxGanttService.jsp?mode=cacheDependencyChangeData" + commonParameter;
var cacheCustomColumnURL = "../gantt/data/emxGanttService.jsp?mode=cacheCustomColumn" + commonParameter;
var saveDataURL = "../gantt/data/emxGanttService.jsp?mode=saveData " + commonParameter;
var resetDataURL = "../gantt/data/emxGanttService.jsp?mode=resetData" + commonParameter;
var preDeleteCheckUrl = "../../programcentral/gantt/data/emxGanttService.jsp?mode=preDeleteCheck";
var getExternalProjectsNameUrl = "../../programcentral/gantt/data/emxGanttService.jsp?mode=getExternalProjectsName&objectId="+objectId;
var getCriticalTaskArrayUrl = "../gantt/data/emxGanttService.jsp?mode=getCriticalTasks" + commonParameter;

var validationMsgValueMap=null;
var getAssignments = "data/emxGanttService.jsp?mode=getAssignments" + commonParameter;
var getResources = "data/emxGanttService.jsp?mode=getResources" + commonParameter;
var assign = "data/emxGanttService.jsp?mode=assign" + commonParameter;

require(["DS/ENOGantt/ENOGantt"]);
}else{

	var bodyElm = document.getElementById("ganttbody");
	var title = '<%=XSSUtil.encodeURLForServer(context, title)%>';
	bodyElm.innerHTML = widgetErrMsg;
}
</script>
</html>

