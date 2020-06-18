<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@page import="com.matrixone.apps.common.TaskDateRollup"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="com.matrixone.apps.common.Issue"%>
<%@page import="com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.DomainObject" %>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="matrix.db.AccessConstants"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.common.MemberRelationship"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.MailUtil"%>
<%@page import="com.matrixone.apps.common.Person"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.program.Experiment"%>


<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%

String strMode = request.getParameter("mode");
String strObjectId = request.getParameter("objectid");
if(UIUtil.isNullOrEmpty(strObjectId)){
	strObjectId = request.getParameter("parentOID");
}
if(UIUtil.isNullOrEmpty(strObjectId)){
	strObjectId = request.getParameter("objectId");
}
if(UIUtil.isNullOrEmpty(strObjectId)){
	strObjectId = request.getParameter("physicalId");
}
//Following Keys are added to cache Exp data in its corresponding Project context.
//Added for IR-572373-3DEXPERIENCER2016x
String expProjectId=ProgramCentralConstants.EMPTY_STRING;
if(!UIUtil.isNullOrEmpty(strObjectId)){
 expProjectId = Experiment.getProjectIdFromExperiment(context, strObjectId);
}
strObjectId = XSSUtil.encodeURLForServer(context, strObjectId);
String projectKey = expProjectId+":";
String isProjectGanttChartLoadedKey = expProjectId+":isGanttChartloaded";
String strSelectedTaskRowId = request.getParameter("emxTableRowId");
String contentURL = DomainObject.EMPTY_STRING;

if("Blank".equalsIgnoreCase(strMode)){
		String isGanttChartloaded = (String)session.getAttribute(isProjectGanttChartLoadedKey);
			String objectId = (String)session.getAttribute(expProjectId);
		
	String structure = (String)session.getAttribute(projectKey+"structure");
		String strPreviousObjectURL = DomainObject.EMPTY_STRING;
		if("TRUE".equalsIgnoreCase(isGanttChartloaded)||UIUtil.isNotNullAndNotEmpty(objectId)){
			if(objectId==null){
				objectId = request.getParameter("objectId");
			}
			objectId = XSSUtil.encodeURLForServer(context, objectId);	
		if("compare".equals(structure)){				
			strPreviousObjectURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=compareWBS&subMode=EntireStructure&objectid="+objectId;
		}else{
			strPreviousObjectURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=launchWBS&objectid="+objectId;
		}
			%>
	   		<script language="javascript" type="text/javaScript">
	    <%--XSSOK--%>
		  var URL = "<%=strPreviousObjectURL%>";
	    		  document.location.href = URL;
	        </script>
	   		<%
	   		session.removeAttribute(isProjectGanttChartLoadedKey);
	   		session.removeAttribute("ExperimentObjectId");
		}else{
			session.removeAttribute("ExperimentObjectId");
			String strEmptyReportMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
					"emxProgramCentral.Experiment.EmptyMsg", context.getSession().getLanguage());  
		%><div align='center'>
		<%= strEmptyReportMsg %>
		</div>
		<%
		return;
		}
}else if("BlankProjectBaselineStructure".equalsIgnoreCase(strMode)){
	String parentOID = request.getParameter("parentOID");	//project id
	parentOID = XSSUtil.encodeURLForServer(context, parentOID);
	String objectId = ProgramCentralConstants.EMPTY_STRING;	//baseline id
	String strPreviousObjectURL = DomainObject.EMPTY_STRING;
	
	String isGanttChartloaded = (String)session.getAttribute("isBaselineGanttLoaded");
	String structure = (String)session.getAttribute("ProjectBaselineStructure");
	try{
	if("TRUE".equalsIgnoreCase(isGanttChartloaded)){

		objectId = (String)session.getAttribute("ProjectBaselineObjectId");
		if("compare".equals(structure)){				
			strPreviousObjectURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=compareProjectBaselines&subMode=EntireStructure&objectid="+objectId;
		}else{
			if(objectId==null){
				objectId = request.getParameter("objectId");
			}
			objectId = XSSUtil.encodeURLForServer(context, objectId);
			strPreviousObjectURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=launchProjectBaselineWBS&objectid="+objectId;
		}
		%>
   		<script language="javascript" type="text/javaScript">
    <%--XSSOK--%>
	  var URL = "<%=strPreviousObjectURL%>";
    		  document.location.href = URL;
        </script>
   		<%
   		session.removeAttribute("isBaselineGanttLoaded");
   		session.removeAttribute("ProjectBaselineObjectId");
	
	}else{
		//Get project's latest baseline. 
	ProjectSpace project = new ProjectSpace(parentOID);
	StringList baselineSelect = new StringList();
	baselineSelect.add(ProgramCentralConstants.SELECT_ID);
	baselineSelect.add(ProgramCentralConstants.SELECT_ATTRIBUTE_TASK_BASELINE_CURRENT_FINISH_DATE);
	MapList baselines = project.getProjectBaselines(context, baselineSelect, null);
		
		//get baseline Id
	if(!baselines.isEmpty()){
		baselines.sort(ProgramCentralConstants.SELECT_ATTRIBUTE_TASK_BASELINE_CURRENT_FINISH_DATE, ProgramCentralConstants.DESCENDING_SORT, ProgramCentralConstants.SORTTYPE_DATE);
		Map baseline = (Map)baselines.get(0);
		objectId = (String) baseline.get(ProgramCentralConstants.SELECT_ID);
		}else{
			objectId = parentOID;	
		}
	}
	}catch(Exception e){
		e.printStackTrace();
		throw e;
	}
	session.setAttribute("ProjectBaselineObjectId", objectId);
	session.setAttribute("parentOID", parentOID);
	session.removeAttribute("isBaselineGanttLoaded");	//Very important to delete this variable
	contentURL = "../common/emxIndentedTable.jsp?table=PMCScheduleBaselineTable&multiColumnSort=true&jsTreeID=null&parentOID=" + XSSUtil.encodeURLForServer(context, parentOID) + "&objectId=" + XSSUtil.encodeURLForServer(context, objectId) + "&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&HelpMarker=emxhelpwbstasklist&findMxLink=false&freezePane=Name&showPageHeader=false&header=emxProgramCentral.Common.WorkBreakdownStructureSB&selection=multiple&sortColumnName=ID&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&expandProgram=emxProjectBaseline:getWBSTasks&expandLevel=1&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false";
	contentURL += "&cellwrap=false&parallelLoading=true";

	%><script language="javascript" type="text/javaScript"><%--XSSOK--%>	
		var url = "<%=contentURL%>";
		var topFrame = findFrame(getTopWindow(), "PMCProjectBaselineStructure");	
		topFrame.location.href = url;
	</script><%
	
}else if("launchWBS".equalsIgnoreCase(strMode)){
		//remove earlier comparison instances from session
		session.removeAttribute("structure");
		session.removeAttribute(projectKey+"ExperimentId1");
		session.removeAttribute(projectKey+"ExperimentId2");
		
		String projectId = Experiment.getProjectIdFromExperiment(context, strObjectId);
				
		session.setAttribute(projectId,strObjectId);
		session.setAttribute("ExperimentObjectId",strObjectId); //This is for Flattened view..
		String portal = request.getParameter("portal");
		String isGanttChartloaded = (String)session.getAttribute(isProjectGanttChartLoadedKey);
		boolean isGanttLoaded = "True".equalsIgnoreCase(isGanttChartloaded);
		Experiment experiment = new Experiment();
		experiment.setId(strObjectId);
		String strContentFrame = "PMCWhatIfExperimentStructure";
		
		if(!isGanttLoaded){
		if(experiment.isExperimentEditable(context, strObjectId)){
			DomainObject project = DomainObject.newInstance(context,strObjectId);
			boolean hasAccess = project.checkAccess(context, (short) AccessConstants.cModify);//ProgramCentralUtil.hasAccessToModifyProject(context,strObjectId);
		
		if(hasAccess){
				contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfWBSViewTable&multiColumnSort=true&jsTreeID=null&parentOID="
						+ XSSUtil.encodeURLForServer(context, strObjectId)
						+ "&toolbar=PMCWhatIFExperimentActionToolbar&connectionProgram=emxTask:cutPasteTasksInWBS&objectId="
						+ XSSUtil.encodeURLForServer(context, strObjectId)
						+ "&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&HelpMarker=emxhelpwbstasklist&findMxLink=false&resequenceRelationship=relationship_Subtask&freezePane=Name&showPageHeader=false&header=emxProgramCentral.Common.WorkBreakdownStructureSB&editLink=true&selection=multiple&sortColumnName=ID&SuiteDirectory=programcentral&postProcessJPO=emxTask:updateScheduleChanges&StringResourceFileId=emxProgramCentralStringResource&editRelationship=relationship_Subtask&expandProgram=emxTask:getWBSSubtasks&expandLevel=1&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false";
		}else{
				contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfWBSViewTable&multiColumnSort=true&jsTreeID=null&parentOID="
						+ XSSUtil.encodeURLForServer(context, strObjectId)
						+ "&toolbar=&connectionProgram=emxTask:cutPasteTasksInWBS&objectId="
						+ XSSUtil.encodeURLForServer(context, strObjectId)
						+ "&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&HelpMarker=emxhelpwbstasklist&findMxLink=false&resequenceRelationship=relationship_Subtask&freezePane=Name&showPageHeader=false&header=emxProgramCentral.Common.WorkBreakdownStructureSB&selection=multiple&sortColumnName=ID&SuiteDirectory=programcentral&postProcessJPO=emxTask:updateScheduleChanges&StringResourceFileId=emxProgramCentralStringResource&editRelationship=relationship_Subtask&expandProgram=emxTask:getWBSSubtasks&expandLevel=1&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false";
		}
		}else{
			contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfWBSViewTable&multiColumnSort=true&jsTreeID=null&parentOID="
					+ XSSUtil.encodeURLForServer(context, strObjectId) + "&toolbar=&objectId="
					+ XSSUtil.encodeURLForServer(context, strObjectId)
					+ "&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&HelpMarker=emxhelpwbstasklist&findMxLink=false&freezePane=Name&showPageHeader=false&header=emxProgramCentral.Common.WorkBreakdownStructureSB&selection=multiple&sortColumnName=ID&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&expandProgram=emxTask:getWBSSubtasks&expandLevel=1&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false";
		}
		contentURL += "&cellwrap=false&portalMode=true&parallelLoading=true&hideLaunchButton=true";
		}else{
		contentURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=GanttChart&portal=PMCWhatIfPortal&parentOID="
				+ (XSSUtil.encodeURLForServer(context, strObjectId));
			strContentFrame = "PMCGantt";
		}
		%>
		<script language="javascript" type="text/javaScript">
		<%--XSSOK--%>	var url = "<%=contentURL%>";
				url = url + "&maxCellsToDraw=2000&scrollPageSize=50";
		var contentFrame = "<%=strContentFrame%>";
			var topFrame = findFrame(getTopWindow(), contentFrame);	
			topFrame.location.href = url;
		</script>
		<%
}else if("launchProjectBaselineWBS".equalsIgnoreCase(strMode)){
	
	
	String parentOID = (String)emxGetParameter(request, "parentOID");
	String objectId = request.getParameter("objectid");
	objectId = XSSUtil.encodeURLForServer(context, objectId);
	session.removeAttribute("ProjectBaselineStructure");
	session.removeAttribute("ProjectBaselineId1");
	session.removeAttribute("ProjectBaselineId2");
	
	session.setAttribute("ProjectBaselineObjectId", objectId);
	String isGanttChartloaded = (String)session.getAttribute("isBaselineGanttLoaded");
	boolean isGanttLoaded = "True".equalsIgnoreCase(isGanttChartloaded);
	String strContentFrame = "PMCProjectBaselineStructure";
	StringBuffer sbUrl = new StringBuffer();
	if(!isGanttLoaded){
	sbUrl.append("../common/emxIndentedTable.jsp?").append("objectId=").append(objectId);
	sbUrl.append("&parentOID=").append(XSSUtil.encodeURLForServer(context, parentOID));
	sbUrl.append("&table=PMCScheduleBaselineTable");
	sbUrl.append("&multiColumnSort=true");
	sbUrl.append("&jsTreeID=null");
	sbUrl.append("&emxSuiteDirectory=programcentral");
	sbUrl.append("&suiteKey=ProgramCentral");
	sbUrl.append("&HelpMarker=emxhelpwbstasklist");
	sbUrl.append("&findMxLink=false");
	sbUrl.append("&cellwrap=false&portalMode=true");
	sbUrl.append("&freezePane=Name");
	sbUrl.append("&showPageHeader=false");
	sbUrl.append("&header=emxProgramCentral.Common.WorkBreakdownStructureSB");
	sbUrl.append("&selection=multiple");
	sbUrl.append("&sortColumnName=ID");
	sbUrl.append("&SuiteDirectory=programcentral");
	sbUrl.append("&StringResourceFileId=emxProgramCentralStringResource");
	sbUrl.append("&expandProgram=emxProjectBaseline:getWBSTasks");
	sbUrl.append("&expandLevel=1");
	sbUrl.append("&massPromoteDemote=false");
	sbUrl.append("&rowGrouping=false");
	sbUrl.append("&objectCompare=false");
	sbUrl.append("&showClipboard=false");
	sbUrl.append("&showPageURLIcon=false");
	sbUrl.append("&triggerValidation=false");
	sbUrl.append("&displayView=details");
	sbUrl.append("&multiColumnSort=false");
	sbUrl.append("&showRMB=false");
	sbUrl.append("&parallelLoading=true");
	}else{
		sbUrl.append("../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=ProjectBaselineGanttChart&parentOID=").append(XSSUtil.encodeURLForServer(context, parentOID));
		strContentFrame = "PMCProjectBaselineGantt";
	}
	contentURL = sbUrl.toString();
	
	%>
	<script language="javascript" type="text/javaScript">
	<%--XSSOK--%>	var url = "<%=contentURL%>";
	url = url + "&maxCellsToDraw=2000&scrollPageSize=50";
	var contentFrame = "<%=strContentFrame%>";
	
		var topFrame = findFrame(getTopWindow(), contentFrame);	
		topFrame.location.href = url;
	</script>
	<%
}else if("GanttChart".equalsIgnoreCase(strMode)){
	String strView = ProgramCentralConstants.VIEW_WBS;
	String parentOID = DomainObject.EMPTY_STRING;
	String objectId = DomainObject.EMPTY_STRING;
	String referenceId = DomainObject.EMPTY_STRING;
	String languageString = context.getLocale().getLanguage();
	String tempId = (String)request.getParameter("parentOID");
	
	String portal = request.getParameter("portal");
	String fromIFWE = request.getParameter("fromIFWE");
	String physicalId = "";
	String title = "";
	
	if(ProgramCentralUtil.isNotNullString(fromIFWE) && "true".equalsIgnoreCase(fromIFWE)){
		physicalId = request.getParameter("physicalId");
		title = request.getParameter("title");
	}
	//Get objectId from session for Experiment 
	if("PMCWhatIfPortal".equalsIgnoreCase(portal)){
		objectId = (String) session.getAttribute(projectKey+"ExperimentId1");
		referenceId = (String)session.getAttribute(projectKey+"ExperimentId2"); //project id in this case	
		strView = ProgramCentralConstants.VIEW_EXPERIMENT_VERSUS_PROJECT;
		if(UIUtil.isNullOrEmpty(objectId)){
			objectId = (String)session.getAttribute(expProjectId); // Experiment id
		}		
		if(UIUtil.isNullOrEmpty(referenceId)){
			strView = ProgramCentralConstants.VIEW_WBS;
			//referenceId = request.getParameter("parentOID"); //project id in this case 		
		}		
		if(UIUtil.isNullOrEmpty(objectId)){
			objectId = request.getParameter("objectId");
	}
	}else{
		objectId = request.getParameter("objectId");
	}
	
	if("PMCProjectTemplateWBSPortal".equalsIgnoreCase(portal)){
		strView = ProgramCentralConstants.VIEW_TEMPLATE_WBS;
	}
	
	objectId = XSSUtil.encodeURLForServer(context,objectId);
	if(ProgramCentralUtil.isNullString(fromIFWE) && ProgramCentralUtil.isNotNullString(objectId) ){
		DomainObject proj = new DomainObject(objectId);
		physicalId = (String)proj.getInfo(context, ProgramCentralConstants.SELECT_PHYSICALID);
	}
	String i18nPlanned = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Gantt.ViewLabel.Planned",context.getSession().getLanguage());
	StringBuffer sbUrl = new StringBuffer();
	sbUrl.append("../webapps/ENOGantt/gantt-widget.html?");
	sbUrl.append("objectId=").append(objectId); 
	sbUrl.append("&referenceId=").append(referenceId);
	sbUrl.append("&languageString=").append(languageString);
	sbUrl.append("&mode=full");
	sbUrl.append("&viewId=").append(strView);
	sbUrl.append("&fromIFWE=").append(fromIFWE);
	sbUrl.append("&physicalId=").append(physicalId);
	sbUrl.append("&title=").append(title);

   	contentURL = sbUrl.toString();   	
	
   	session.setAttribute(isProjectGanttChartLoadedKey,"TRUE");
	session.removeAttribute("durationMapList");
	session.removeAttribute("startDateMapList");
	session.removeAttribute("finishDateMapList");
	session.removeAttribute("dependencyMapList");
	session.removeAttribute("customColumnMapList");
	%>
	<script language="javascript">
	<%--XSSOK--%>	var url = "<%=contentURL%>";
        //var topFrame = findFrame(getTopWindow(), "PMCGantt");
        //topFrame.location.href = url;
        window.location.href = url;
	</script>
	<% 
}else if("ProjectBaselineGanttChart".equalsIgnoreCase(strMode)){
	String strView = ProgramCentralConstants.VIEW_BASELINE_VERSUS_CURRENT_BASELINE2;
	String parentOID = DomainObject.EMPTY_STRING;
	String objectId = DomainObject.EMPTY_STRING;
	String referenceId = DomainObject.EMPTY_STRING;
	String languageString = context.getLocale().getLanguage();
	String tempId = (String)request.getParameter("parentOID");
	
	objectId = (String) session.getAttribute("ProjectBaselineId1");
	referenceId = (String)session.getAttribute("ProjectBaselineId2"); //project id in this case
	if(UIUtil.isNullOrEmpty(objectId)){
	objectId = (String)session.getAttribute("ProjectBaselineObjectId"); 
	}		
	if(UIUtil.isNullOrEmpty(referenceId)){
		strView = ProgramCentralConstants.VIEW_BASELINE_WBS;
	}		
	if(UIUtil.isNullOrEmpty(objectId)){
		objectId = request.getParameter("objectId");
	}
	
	if(tempId.equals(referenceId)){
		tempId = objectId;
		objectId = referenceId;
		referenceId = tempId;
	}
	objectId = XSSUtil.encodeURLForServer(context,objectId);
	referenceId = XSSUtil.encodeURLForServer(context,referenceId);
	String i18nPlanned = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Gantt.ViewLabel.Planned",context.getSession().getLanguage());
	StringBuffer sbUrl = new StringBuffer();
	sbUrl.append("../webapps/ENOGantt/gantt-widget.html?");
	sbUrl.append("objectId=").append(objectId);
	sbUrl.append("&referenceId=").append(referenceId);
	sbUrl.append("&languageString=").append(languageString);
	sbUrl.append("&mode=full");
	sbUrl.append("&viewId=").append(strView);
   	contentURL = sbUrl.toString();   	
	
   	session.setAttribute("isBaselineGanttLoaded", "TRUE");
	session.removeAttribute("durationMapList");
	session.removeAttribute("startDateMapList");
	session.removeAttribute("finishDateMapList");
	session.removeAttribute("dependencyMapList");
	session.removeAttribute("customColumnMapList");
	%>
	<script language="javascript">
	<%--XSSOK--%>	var url = "<%=contentURL%>";
        //var topFrame = findFrame(getTopWindow(), "PMCGantt");
        //topFrame.location.href = url;
        window.location.href = url;
	</script>
	<% 
}else if("Experiment".equalsIgnoreCase(strMode)){
	String projectId = request.getParameter("objectId");
	String strUrl  = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=createExperiment&objectId="+XSSUtil.encodeURLForServer(context,projectId);
%>
	<script language="javascript">
		var topFrame = findFrame(getTopWindow(), "PMCWhatIfProjectExperimentsList");
		setTimeout(function() {
			topFrame.toggleProgress('visible');
		<%--XSSOK--%>	document.location.href = "<%=strUrl%>";
	    },100);
	</script>
	<%
}else if("createExperiment".equalsIgnoreCase(strMode)){
	String projectId = request.getParameter("objectId");
	if(ProgramCentralUtil.isNotNullString(projectId)){
		Experiment expObject 	= new Experiment(projectId);
		String projName 		= expObject.getName(context);
	
		//create an experiment
		try{
			expObject.create(context,projectId);
			long rol = System.currentTimeMillis();
			PropertyUtil.setRPEValue(context, "IsExperiment", "TRUE", true);
			TaskDateRollup.rolloutProject(context, new StringList(expObject.getObjectId(context)), true, true);
			System.out.println("Rollup time................."+(System.currentTimeMillis()-rol));
		}catch(FrameworkException fe){
			fe.printStackTrace();
		}finally{
			PropertyUtil.setRPEValue(context, "IsExperiment", "FALSE", true);
		}
		
						
		String lang = context.getSession().getLanguage();
		
			String strSubject = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
				"emxProgramCentral.Experiment.CreateExperimentNotificationSubject", lang);
			
			String strBody = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
				"emxProgramCentral.Experiment.CreateExperimentNotificationContent", lang);
		
			strBody +=" "+expObject.getName(context)+"\n\n";
		strBody +="Project Name:"+ projName;
			
			Person person = Person.getPerson(context);
		 
			StringList slTo = new StringList();
			slTo.add(person.getName(context));
			 
			MailUtil.sendNotification(context, slTo, null, null,
										  strSubject, null, null, strBody, null, null,
										  null, null,
										  "emxProgramCentralStringResource");
	%>
	<script language="javascript">
		var topFrame = findFrame(getTopWindow(), "PMCWhatIfProjectExperimentsList");	
			setTimeout(function() {
				topFrame.toggleProgress('hidden');
				topFrame.location.href = topFrame.location.href;
		    },100);
			
	</script>
	<%
	}

}else if("deleteExperiment".equalsIgnoreCase(strMode)){
		boolean hasDeleteAccess = true;
		boolean hasAccess = false;
		boolean isConnectedWithRoute = false;
		
		String strLanguage = context.getSession().getLanguage();
		String strContextPersonName = context.getUser();
		String strErrorMsg = DomainObject.EMPTY_STRING;
		String strWarningMsg = DomainObject.EMPTY_STRING;
		
		String[] selectedRowIds = emxGetParameterValues(request, "emxTableRowId");
		selectedRowIds = ProgramCentralUtil.parseTableRowId(context, selectedRowIds);
   		Map mapRowId = (Map)ProgramCentralUtil.parseTableRowId(context,strSelectedTaskRowId);
   		
   		String SELECT_EXP_ROUTE_ID = "from[Object Route].to.id";
   		
   		StringList slSelectable = new StringList();
   		slSelectable.addElement(DomainObject.SELECT_ID);
   		slSelectable.addElement(DomainObject.SELECT_NAME);
   		slSelectable.addElement(DomainObject.SELECT_TYPE);
   		slSelectable.addElement(DomainObject.SELECT_OWNER);
   		slSelectable.addElement(DomainObject.SELECT_ORIGINATOR);
   		slSelectable.addElement(SELECT_EXP_ROUTE_ID);
   		
   		MapList experimentInfoList = new MapList();
   		try{
   			ProgramCentralUtil.pushUserContext(context);
   			experimentInfoList = DomainObject.getInfo(context,selectedRowIds,slSelectable);
   		}finally{
   			ProgramCentralUtil.popUserContext(context);
   		}
   		Iterator<Map> experimentInfoListIterator = experimentInfoList.iterator();
   		
   		String experimentId = ProgramCentralConstants.EMPTY_STRING;
   		String experimentType = ProgramCentralConstants.EMPTY_STRING;
   		String experimentName = ProgramCentralConstants.EMPTY_STRING;
   		String expOwnerName = ProgramCentralConstants.EMPTY_STRING;
   		String expOriginatorName = ProgramCentralConstants.EMPTY_STRING;
   		String projectName = ProgramCentralConstants.EMPTY_STRING;
   		String experimentIds = ProgramCentralConstants.EMPTY_STRING;
   		
   		StringList slExperimentsConnectedToRoute = new StringList();
   		StringList slSubExperiments = new StringList();
   		StringList slExperimentsWithoutAccess = new StringList();
   		StringList slExperimentsToBeDeleted = new StringList();
   		   		   		   		
   		while(experimentInfoListIterator.hasNext()){
   			Map mpExpInfo = (Map)experimentInfoListIterator.next();
   			experimentId = (String)mpExpInfo.get(DomainObject.SELECT_ID);
	   		experimentType = (String)mpExpInfo.get(DomainObject.SELECT_TYPE);
	   		experimentName = (String)mpExpInfo.get(DomainObject.SELECT_NAME);
	   		expOwnerName = (String)mpExpInfo.get(DomainObject.SELECT_OWNER);
	   		expOriginatorName = (String)mpExpInfo.get(DomainObject.SELECT_ORIGINATOR);
	   		Object object = mpExpInfo.get(SELECT_EXP_ROUTE_ID);
	   			   		
	   		if(ProgramCentralConstants.TYPE_PROJECT_SPACE.equalsIgnoreCase(experimentType)){
	   			projectName = experimentName;
   		 	}else if(!strContextPersonName.equalsIgnoreCase(expOwnerName) && !strContextPersonName.equalsIgnoreCase(expOriginatorName)){
	   			slExperimentsWithoutAccess.add(experimentName);
	   		}else if(Experiment.isUsedAsSubTask(context,experimentId)){
	   			slSubExperiments.add(experimentName);
	   		}else if(object != null){
	   			slExperimentsConnectedToRoute.add(experimentName);
	   			
	   			if(ProgramCentralUtil.isNotNullString(experimentIds)){
	   				experimentIds = experimentIds + ProgramCentralConstants.COMMA + experimentId;
	   			}else {
	   				experimentIds = experimentId;
	   			}
	   		}
	   		else{
	   			slExperimentsToBeDeleted.add(experimentName);
	   			if(ProgramCentralUtil.isNotNullString(experimentIds)){
	   				experimentIds = experimentIds + ProgramCentralConstants.COMMA + experimentId;
	   			}else {
	   				experimentIds = experimentId;
	   			}
	   		}
   		}	
   		
   		String expName = ProgramCentralConstants.EMPTY_STRING;
   		if(ProgramCentralUtil.isNotNullString(projectName)){
   			String[] messageValues = new String[1];
            messageValues[0] = projectName;
            
   			strErrorMsg = MessageUtil.getMessage(context, null,"emxProgramCentral.Experiment.DeleteExperiment", messageValues, null, context.getLocale(), "emxProgramCentralStringResource");
   			strErrorMsg = strErrorMsg + "\\n \\n";;
 		}
   		
   		if(!slExperimentsWithoutAccess.isEmpty()){
   			expName = ProgramCentralConstants.EMPTY_STRING;
   			String strNoAccessErrorMsg = EnoviaResourceBundle.getProperty(context, ProgramCentralConstants.PROGRAMCENTRAL,"emxProgramCentral.Experiment.AccessWarning", strLanguage);
   			strErrorMsg = strErrorMsg + strNoAccessErrorMsg + "\\n";
   			
   			Iterator<String> slExperimentsWithoutAccessIterator = slExperimentsWithoutAccess.iterator();
   			
   			while(slExperimentsWithoutAccessIterator.hasNext()){
   				if(ProgramCentralUtil.isNotNullString(expName)){
   					expName = expName + ProgramCentralConstants.COMMA + ProgramCentralConstants.SPACE + slExperimentsWithoutAccessIterator.next();
   				} else{
   					 expName = slExperimentsWithoutAccessIterator.next();
   				}
   			}
   			strErrorMsg = strErrorMsg + expName + "\\n \\n";
   		}
   		
   		if(!slSubExperiments.isEmpty()){
   			expName = ProgramCentralConstants.EMPTY_STRING;
   			String strSubExperimentErrorMsg = EnoviaResourceBundle.getProperty(context, ProgramCentralConstants.PROGRAMCENTRAL, "emxProgramCentral.Experiment.DeleteWarning", strLanguage);
   			strErrorMsg = strErrorMsg + strSubExperimentErrorMsg + "\\n";
   			Iterator<String> slSubExperimentsIterator = slSubExperiments.iterator();
   			
   			while(slSubExperimentsIterator.hasNext()){
   				if(ProgramCentralUtil.isNotNullString(expName)){
   					expName = expName + ProgramCentralConstants.COMMA + ProgramCentralConstants.SPACE + slSubExperimentsIterator.next();
   				} else {
   					expName = slSubExperimentsIterator.next();
   				}
   			}
   			strErrorMsg = strErrorMsg + expName + "\\n \\n";
   		}
   		   		
   		if(!slExperimentsConnectedToRoute.isEmpty()){
   			expName = ProgramCentralConstants.EMPTY_STRING;
   			strWarningMsg = EnoviaResourceBundle.getProperty(context, ProgramCentralConstants.PROGRAMCENTRAL, "emxProgramCentral.ChangeProject.Experiment.DeleteWarning", strLanguage);
   			strWarningMsg = strWarningMsg + "\\n";
   			Iterator<String> slExperimentsConnectedToRouteIterator = slExperimentsConnectedToRoute.iterator();
   			
   			while(slExperimentsConnectedToRouteIterator.hasNext()){
   				if(ProgramCentralUtil.isNotNullString(expName)){
   					expName = expName + ProgramCentralConstants.COMMA + ProgramCentralConstants.SPACE + slExperimentsConnectedToRouteIterator.next();
   				} else{
   					expName = slExperimentsConnectedToRouteIterator.next();
   				}
   			}
   			strWarningMsg = strWarningMsg + expName + "\\n \\n";
   		}
   		
   		if(!slExperimentsToBeDeleted.isEmpty()){
   			expName = ProgramCentralConstants.EMPTY_STRING;
   			String strExperimentDeletionWarningMsg = EnoviaResourceBundle.getProperty(context, ProgramCentralConstants.PROGRAMCENTRAL, "emxProgramCentral.Project.ConfirmExperimentDelete", strLanguage);
   			strWarningMsg = strWarningMsg + strExperimentDeletionWarningMsg + "\\n";
			Iterator<String> slExperimentsToBeDeletedIterator = slExperimentsToBeDeleted.iterator();
   			
   			while(slExperimentsToBeDeletedIterator.hasNext()){
   				if(ProgramCentralUtil.isNotNullString(expName)){
   					expName = expName + ProgramCentralConstants.COMMA + ProgramCentralConstants.SPACE + slExperimentsToBeDeletedIterator.next();
   				} else {
   					expName = slExperimentsToBeDeletedIterator.next();
   				}
   			}
   			strWarningMsg = strWarningMsg + expName + "\\n \\n";
   		}
   		
   		if(!slExperimentsToBeDeleted.isEmpty() || !slExperimentsConnectedToRoute.isEmpty()){
   			if(ProgramCentralUtil.isNotNullString(strErrorMsg)){
   				strWarningMsg = strErrorMsg + strWarningMsg;
   			}
	   		
				String strURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=deleteExperimentObject&ExperimentId="+XSSUtil.encodeURLForServer(context,experimentIds);
				%>
				<script language="javascript" type="text/javaScript">
				var topFrame = findFrame(getTopWindow(), "PMCWhatIfProjectExperimentsList");
				var confirmMsg = "<%=strWarningMsg%>";
				 var result = confirm(confirmMsg);
				  if(result){
				<%--XSSOK--%>	  var URL = "<%=strURL%>";
					  
					  setTimeout(function() {
							topFrame.toggleProgress('visible');
							document.location.href = URL;
					  },100);
					  
				  }
				</script>
				<%
   		
   		}else{
   			%>
   			<script language="javascript" type="text/javaScript">
	   			var errorMessage = "<%=strErrorMsg%>";
	   			alert(errorMessage);
	   			
   		 	</script>
   			<%
   		}
}else if("deleteExperimentObject".equalsIgnoreCase(strMode)){
   		String sExperimentProjectId = request.getParameter("ExperimentId");
   		StringList experimentIds = FrameworkUtil.split(sExperimentProjectId, ProgramCentralConstants.COMMA);
   		Experiment expObject = new Experiment();
   		
   		String experimentId1 = (String)session.getAttribute(projectKey+"ExperimentId1");
   		String experimentId2 = (String)session.getAttribute(projectKey+"ExperimentId2");
   		
   		String isRefreshStructurePane = "false";
   		if(experimentIds.contains(experimentId1) || experimentIds.contains(experimentId2)){
   			isRefreshStructurePane = "true";
   		}
   		session.removeAttribute("ExperimentId1");
		session.removeAttribute("ExperimentId2");
   		Iterator<String> experimentIdsIterator = experimentIds.iterator();
   		while(experimentIdsIterator.hasNext()){
   			String experimentId = experimentIdsIterator.next();
   			expObject.setId(experimentId);
   			expObject.delete(context, experimentId);
   		}
   		   		
   		String strURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=Blank";
   		%>
   		<script language="javascript">
   			var topFrame = findFrame(getTopWindow(), "PMCWhatIfProjectExperimentsList");	
   			var isRefresh = "<%=XSSUtil.encodeForJavaScript(context, isRefreshStructurePane)%>";
   			var url = "<%=XSSUtil.encodeForJavaScript(context, strURL)%>";
				if(isRefresh=="true"){
					var topFrames = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");	
					topFrames.location.href = url;
				}
		 topFrame.location.href = topFrame.location.href;
  	       </script>
   	       <%
}else if("compareWBS".equalsIgnoreCase(strMode)){
		session.setAttribute(projectKey+"structure", "compare");
		String portal = request.getParameter("portal");
		String isGanttChartloaded = (String)session.getAttribute(isProjectGanttChartLoadedKey);
		boolean isGanttLoaded = false;;
		if("TRUE".equalsIgnoreCase(isGanttChartloaded)){
			isGanttLoaded = true;
		}
		boolean invalidSelection = true;
	    String[] selectedRowIds = emxGetParameterValues(request, "emxTableRowId");
	    String subMode = request.getParameter("subMode");
        String expandLevel = "1";
        String expandFilter = "true";
	    boolean isModifiedRowsOnly = false;
	    boolean iscompareEntireStructure = false;
	    String reportType = "Complete_Summary_Report";
	    String matchBasedOn = ProgramCentralConstants.SELECT_ATTRIBUTE_SOURCE_ID;
	    String showDiffIcons  = "true";
	    String showSummaryDiffIcons  = "true";
	    if("DifferenceOnly".equalsIgnoreCase(subMode)){
	    	isModifiedRowsOnly = true;
	    	invalidSelection = false;
	    	reportType = "Difference_Only_Report";
	    	expandLevel = "0";
	    	expandFilter = "false";
	    	showDiffIcons  = "false";
	 	    showSummaryDiffIcons  = "false";
	    }else if("EntireStructure".equalsIgnoreCase(subMode)){
	    	iscompareEntireStructure = true;
	    	 invalidSelection = false;
	    }
		String objectId1 = DomainObject.EMPTY_STRING;
		String objectId2 = DomainObject.EMPTY_STRING;
		String parentId = DomainObject.EMPTY_STRING;
		String objectType1 = ProgramCentralConstants.TYPE_EXPERIMENT;
		String objectType2 = ProgramCentralConstants.TYPE_EXPERIMENT;
		
		if(!isModifiedRowsOnly && !iscompareEntireStructure){
			if(null == selectedRowIds || selectedRowIds.length == 0){
				objectId1 = (String)request.getParameter("objectid1");
				objectId2 = (String)request.getParameter("objectId2");
				parentId = objectId2;
				invalidSelection = false;
			} 
			else if(selectedRowIds.length ==1){
			Map<String,String> mapRowId = ProgramCentralUtil.parseTableRowId(context,strSelectedTaskRowId);
			objectId1 = mapRowId.get("objectId");
			objectId2 = mapRowId.get("parentOId");
			parentId = mapRowId.get("parentOId");
			
			if(ProgramCentralUtil.isNotNullString(parentId)){
				invalidSelection = false;
				objectType2 = ProgramCentralConstants.TYPE_PROJECT_SPACE;
			}
		}
		else if(selectedRowIds.length ==2){
			Map<String,String> firstRowMap = ProgramCentralUtil.parseTableRowId(context,selectedRowIds[0]);
			Map<String,String> secondRowMap = ProgramCentralUtil.parseTableRowId(context,selectedRowIds[1]);
			String firstRowId = firstRowMap.get("objectId");
			String firstRowParentId = firstRowMap.get("parentOId");
			
			String secondRowId = secondRowMap.get("objectId");
			String secondRowParentId = secondRowMap.get("parentOId");
			
			objectId1 = firstRowId;
			objectId2 = secondRowId;
			parentId = firstRowParentId;
									
			if(ProgramCentralUtil.isNullString(firstRowParentId)){
				objectId2 = firstRowId;
				objectId1 = secondRowId;
				parentId = secondRowParentId;
				objectType2 = ProgramCentralConstants.TYPE_PROJECT_SPACE;
			}
			
			 invalidSelection = false;
		}	 
		} 
		else {
			objectId1 = (String)session.getAttribute(projectKey+"ExperimentId1");
			objectId2 = (String)session.getAttribute(projectKey+"ExperimentId2");
			parentId = (String)session.getAttribute(projectKey+"ExperimentParentId");
			objectType1 = (String)session.getAttribute("objectType1");
			objectType2 = (String)session.getAttribute("objectType2");
		}
		
		String strContentFrame = "PMCWhatIfExperimentStructure";
		if(!invalidSelection) {
			if(!isGanttLoaded){
			contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfCompareViewTable&toolbar=PMCWhatIfSyncToolbar&expandProgram=emxWhatIf:getExperimentWBSSubtasks&reportType="+reportType+"&IsStructureCompare=TRUE&updateInPostProcess=true&compareLevel=1&expandLevel="+expandLevel+"&expandFilter="+expandFilter+"&resequenceRelationship=relationship_Subtask&refreshTableContent=true&summaryIcons="+showSummaryDiffIcons+"&diffCodeIcons="+showDiffIcons+"&objectId=";
			 contentURL += XSSUtil.encodeURLForServer(context,objectId1) +","+ XSSUtil.encodeURLForServer(context,objectId2);
			 contentURL += "&ParentobjectId="+XSSUtil.encodeURLForServer(context,parentId)+"&objectId1="+XSSUtil.encodeURLForServer(context,objectId1)+"&objectId2="+XSSUtil.encodeURLForServer(context,objectId2);
			 contentURL += "&compareBy=Name,ID,Dependency,ConstraintType,Constraint Date,PhaseEstimatedDuration,PhaseEstimatedStartDate,PhaseEstimatedEndDate,Description&objectCompare=false&showClipboard=false&customize=false&rowGrouping=false&inlineIcons=false&displayView=details&syncEntireRow=true&SortDirection=ascending&SortColumnName=dupId&matchBasedOn="+ XSSUtil.encodeURLForServer(context,matchBasedOn)+"&selection=multiple&editRootNode=false&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&hideRootSelection=true&showRMB=false";
			 contentURL += "&portalMode=true&displayEntireStructure=true&objectType1="+XSSUtil.encodeURLForServer(context,objectType1)+"&objectType2="+XSSUtil.encodeURLForServer(context,objectType2)+"&postProcessJPO=emxWhatIf:postProcessAction&subMode="+XSSUtil.encodeURLForServer(context,subMode);
			 contentURL += "&showPageURLIcon=false&hideLaunchButton=true&parallelLoading=true";
			} else {
				contentURL ="../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=GanttChart&parentOID="+XSSUtil.encodeURLForServer(context,parentId)+"&portal="+portal;
				strContentFrame = "PMCGantt";
			}
			objectId1 = XSSUtil.encodeURLForServer(context, objectId1);
			objectId2 = XSSUtil.encodeURLForServer(context, objectId2);
			parentId = XSSUtil.encodeURLForServer(context, parentId);
			 session.setAttribute(projectKey+"ExperimentId1",objectId1);
			 session.setAttribute(projectKey+"ExperimentId2",objectId2);
			 session.setAttribute(projectKey+"ExperimentParentId",parentId);
			 
			 session.setAttribute("objectType1",objectType1);
			 session.setAttribute("objectType2",objectType2);
		} else{
			String strMsg = EnoviaResourceBundle.getProperty(context, ProgramCentralConstants.PROGRAMCENTRAL, 
					"emxProgramCentral.Experiment.WBSCompareWarningMessage", context.getSession().getLanguage());
			%>
			<script language="javascript" type="text/javaScript">
	       		var vMsg = "<%=strMsg%>";
	       		alert(vMsg);
	 		</script>
			<%
			return;
		}
		%>
   		<script language="javascript">
   		<%--XSSOK--%>	var url = "<%=contentURL%>";
   		var contentFrame = "<%=strContentFrame%>";
   		var topFrame = findFrame(getTopWindow(), contentFrame);
   		topFrame.location.href = url;   		
   		</script>
   		<%
}else if("compareProjectBaselines".equalsIgnoreCase(strMode)){
	session.setAttribute("ProjectBaselineStructure", "compare");
	String isGanttChartloaded = (String)session.getAttribute("isBaselineGanttLoaded");
	boolean isGanttLoaded = false;
	if("TRUE".equalsIgnoreCase(isGanttChartloaded)){
		isGanttLoaded = true;
	}
	boolean invalidSelection = true;
    String[] selectedRowIds = emxGetParameterValues(request, "emxTableRowId");
    String subMode = request.getParameter("subMode");
    String expandLevel = "1";
    String expandFilter = "true";
    boolean isModifiedRowsOnly = false;
    boolean iscompareEntireStructure = false;
    String reportType = "Complete_Summary_Report";
    String matchBasedOn = ProgramCentralConstants.SELECT_ATTRIBUTE_SOURCE_ID;
    String showDiffIcons  = "true";
    String showSummaryDiffIcons  = "true";
    if("DifferenceOnly".equalsIgnoreCase(subMode)){
    	isModifiedRowsOnly = true;
    	invalidSelection = false;
    	reportType = "Difference_Only_Report";
    	expandLevel = "0";
    	expandFilter = "false";
    	showDiffIcons  = "false";
 	    showSummaryDiffIcons  = "false";
    }else if("EntireStructure".equalsIgnoreCase(subMode)){
    	iscompareEntireStructure = true;
    	 invalidSelection = false;
    }
	String objectId1 = DomainObject.EMPTY_STRING;
	String objectId2 = DomainObject.EMPTY_STRING;
	String parentId = DomainObject.EMPTY_STRING;
	String objectType1 = ProgramCentralConstants.TYPE_PROJECT_BASELINE;
	String objectType2 = ProgramCentralConstants.TYPE_PROJECT_BASELINE;
	
	if(!isModifiedRowsOnly && !iscompareEntireStructure){
	
	if(null == selectedRowIds || selectedRowIds.length == 0){
	objectId1 = (String)session.getAttribute("ProjectBaselineId1");
	objectId2 = (String)session.getAttribute("ProjectBaselineId2");				
	} else if(selectedRowIds.length ==1){
		
		Map<String,String> mapRowId = ProgramCentralUtil.parseTableRowId(context,strSelectedTaskRowId);
		objectId1 = mapRowId.get("objectId");
		objectId2 = mapRowId.get("parentOId");
		parentId = mapRowId.get("parentOId");
		
		if(ProgramCentralUtil.isNotNullString(parentId)){
			invalidSelection = false;
			objectType2 = ProgramCentralConstants.TYPE_PROJECT_SPACE;
		}
	} else if(selectedRowIds.length ==2){
		Map<String,String> firstRowMap = ProgramCentralUtil.parseTableRowId(context,selectedRowIds[0]);
		Map<String,String> secondRowMap = ProgramCentralUtil.parseTableRowId(context,selectedRowIds[1]);
		String firstRowId = firstRowMap.get("objectId");
		String firstRowParentId = firstRowMap.get("parentOId");
		
		String secondRowId = secondRowMap.get("objectId");
		String secondRowParentId = secondRowMap.get("parentOId");
		
		objectId1 = firstRowId;
		objectId2 = secondRowId;
		parentId = firstRowParentId;
								
		if(ProgramCentralUtil.isNullString(firstRowParentId)){
			objectId2 = firstRowId;
			objectId1 = secondRowId;
			parentId = secondRowParentId;
			objectType2 = ProgramCentralConstants.TYPE_PROJECT_SPACE;
		}
		
		 invalidSelection = false;
	}	 
	} else {
		objectId1 = (String)session.getAttribute("ProjectBaselineId1");
		objectId2 = (String)session.getAttribute("ProjectBaselineId2");
		parentId = (String)session.getAttribute("ProjectBaselineParentId");
		objectType1 = (String)session.getAttribute("ProjectBaselineType1");
		objectType2 = (String)session.getAttribute("ProjectBaselineType2");
	}
	
	String strContentFrame = "PMCProjectBaselineStructure";
	if(!invalidSelection) {
		
		if(!isGanttLoaded){
		contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfCompareViewTable&toolbar=PMCProjectBaselineCompareToolbar&expandProgram=emxWhatIf:getExperimentWBSSubtasks&reportType="+reportType+"&IsStructureCompare=TRUE&updateInPostProcess=true&compareLevel=1&expandLevel="+expandLevel+"&expandFilter="+expandFilter+"&resequenceRelationship=relationship_Subtask&refreshTableContent=true&summaryIcons="+showSummaryDiffIcons+"&diffCodeIcons="+showDiffIcons+"&objectId=";
		 contentURL += XSSUtil.encodeURLForServer(context,objectId1) +","+ XSSUtil.encodeURLForServer(context,objectId2);
		 contentURL += "&ParentobjectId="+XSSUtil.encodeURLForServer(context,parentId)+"&objectId1="+XSSUtil.encodeURLForServer(context,objectId1)+"&objectId2="+XSSUtil.encodeURLForServer(context,objectId2);
		 contentURL += "&compareBy=Name,ID,Dependency,ConstraintType,Constraint Date,PhaseEstimatedDuration,PhaseEstimatedStartDate,PhaseEstimatedEndDate,Description&objectCompare=false&showClipboard=false&customize=false&rowGrouping=false&inlineIcons=false&displayView=details&syncEntireRow=true&SortDirection=ascending&SortColumnName=dupId&matchBasedOn="+ XSSUtil.encodeURLForServer(context,matchBasedOn)+"&selection=multiple&editRootNode=false&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&hideRootSelection=true&showRMB=false";
		 contentURL += "&objectType1="+XSSUtil.encodeURLForServer(context,objectType1)+"&objectType2="+XSSUtil.encodeURLForServer(context,objectType2)+"&postProcessJPO=emxWhatIf:postProcessAction&subMode="+XSSUtil.encodeURLForServer(context,subMode);
		} else {
			contentURL ="../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=ProjectBaselineGanttChart&parentOID="+XSSUtil.encodeURLForServer(context,parentId);
			strContentFrame = "PMCProjectBaselineGantt";
		}
		objectId1 = XSSUtil.encodeURLForServer(context, objectId1);
		objectId2 = XSSUtil.encodeURLForServer(context, objectId2);
		parentId = XSSUtil.encodeURLForServer(context, parentId);
		 session.setAttribute("ProjectBaselineId1",objectId1);
		 session.setAttribute("ProjectBaselineId2",objectId2);
		 session.setAttribute("ProjectBaselineParentId",parentId);
		 
		 session.setAttribute("ProjectBaselineType1",objectType1);
		 session.setAttribute("ProjectBaselineType2",objectType2);
	} else{
		String strMsg = EnoviaResourceBundle.getProperty(context, ProgramCentralConstants.PROGRAMCENTRAL, 
				"emxProgramCentral.ProjectBaseline.WBSCompareWarningMessage", context.getSession().getLanguage());
		%>
		<script language="javascript" type="text/javaScript">
       		var vMsg = "<%=strMsg%>";
       		alert(vMsg);
 		</script>
		<%
		return;
	}
	%>
		<script language="javascript">
		<%--XSSOK--%>	var url = "<%=contentURL%>";
		var contentFrame = "<%=strContentFrame%>";
			var topFrame = findFrame(getTopWindow(), contentFrame);	
			topFrame.location.href = url;
		</script>
		<%
}else if("addApprover".equalsIgnoreCase(strMode)){
	    String fieldNameDisplay = request.getParameter("fieldNameDisplay");
	    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
	    String fieldNameActual = request.getParameter("fieldNameActual");
	    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
	    String fieldNameOID = request.getParameter("fieldNameOID");
	    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
	    String strProjectId = request.getParameter("objectId");
	    
		 if(ProgramCentralUtil.isNullString(strProjectId)){
			 strProjectId = request.getParameter("parentOID");
		 }
		 strProjectId = XSSUtil.encodeURLForServer(context, strProjectId);
		 String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person&table=PMCCommonPersonSearchTable&selection=multiple&includeOIDprogram=emxWhatIf:includeProjectMemberForApprover&showInitialResults=true";
		 strURL +="&objectId="+strProjectId;
		 strURL +="&submitURL=../common/AEFSearchUtil.jsp";
		 strURL +="&fieldNameDisplay="+fieldNameDisplay;
		 strURL +="&fieldNameActual="+fieldNameActual;
		 strURL +="&fieldNameOID="+fieldNameOID;
		 
		%>
			<script language="javascript">
			<%--XSSOK--%>	var url = "<%=strURL%>";
			url = url + "&frameNameForField="+parent.name;
				showModalDialog(url);
			</script>
		<%
}else if("addAssignee".equalsIgnoreCase(strMode)){
    String fieldNameDisplay = request.getParameter("fieldNameDisplay");
    fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
    String fieldNameActual = request.getParameter("fieldNameActual");
    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
    String fieldNameOID = request.getParameter("fieldNameOID");
    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
    String strProjectId = request.getParameter("objectId");
    
	 if(ProgramCentralUtil.isNullString(strProjectId)){
		 strProjectId = request.getParameter("parentOID");
	 }
	 strProjectId = XSSUtil.encodeURLForServer(context, strProjectId);
	 String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:USERROLE=Project Lead,VPLMProjectLeader&table=PMCCommonPersonSearchTable&selection=multiple&includeOIDprogram=emxWhatIf:includeProjectMemberForAssignee&showInitialResults=true";
	 strURL +="&objectId="+strProjectId;
	 strURL +="&submitURL=../common/AEFSearchUtil.jsp";
	 strURL +="&fieldNameDisplay="+fieldNameDisplay;
	 strURL +="&fieldNameActual="+fieldNameActual;
	 strURL +="&fieldNameOID="+fieldNameOID;
	%>
		<script language="javascript">
	<%--XSSOK--%>		var url = "<%=strURL%>";
	url = url + "&frameNameForField="+parent.name;
			showModalDialog(url);
		</script>
	<%
}else if("searchExperiment".equalsIgnoreCase(strMode)){
	String fieldNameDisplay = request.getParameter("fieldNameDisplay");
	fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
    String fieldNameActual = request.getParameter("fieldNameActual");
    fieldNameActual = XSSUtil.encodeURLForServer(context, fieldNameActual);
    String fieldNameOID = request.getParameter("fieldNameOID");
    fieldNameOID = XSSUtil.encodeURLForServer(context, fieldNameOID);
    String strProjectId = request.getParameter("objectId");
    
	 if(ProgramCentralUtil.isNullString(strProjectId)){
		 strProjectId = request.getParameter("parentOID");
	 } 
	strProjectId = XSSUtil.encodeURLForServer(context, strProjectId);
	String strURL = "../common/emxFullSearch.jsp?table=PMCGenericProjectSpaceSearchResults&field=TYPES=type_Experiment&selection=single&showInitialResults=true&includeOIDprogram=emxWhatIf:includeExperimentProject";
	strURL +="&objectId="+strProjectId;
	strURL +="&submitURL=../common/AEFSearchUtil.jsp";
	strURL +="&fieldNameDisplay="+fieldNameDisplay;
	strURL +="&fieldNameActual="+fieldNameActual;
	strURL +="&fieldNameOID="+fieldNameOID;
	%>
	<script language="javascript">
	<%--XSSOK--%>	var url = "<%=strURL%>";
	url = url + "&frameNameForField="+parent.name;
	showModalDialog(url);
	</script>
<%
}else if("deleteIssue".equalsIgnoreCase(strMode)){
	String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String strObjectIds[] = strObjectIds = Issue.getObjectIds(arrTableRowIds);
   
    session.setAttribute("rowIds", strObjectIds);
    String strURL = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=deleteIssueObjects&rowIds="+strObjectIds;
    %>
	<script language="javascript" type="text/javaScript">
	 var result = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.ChangeProject.Issue.DeleteWarning</framework:i18nScript>");
	  if(result){//XSSOK
		  var URL = "<%=strURL%>";
		  document.location.href = URL;
	  }
	</script>
	
<%
}else if("deleteIssueObjects".equalsIgnoreCase(strMode)){
	Experiment experiment  = new Experiment();
	String[] strObjectIds = (String[])session.getAttribute("rowIds");
	experiment.deleteIssue(context, strObjectIds);
	
	session.removeAttribute("rowIds");
	%>
		<script language="javascript">
			var detailsDisplay_1 = findFrame(getTopWindow(), "PMCWhatIfProjectChangeList");	
		    var detailsDisplay_2 = findFrame(getTopWindow(), "PMCWhatIfProjectExperimentsList");			 
			detailsDisplay_1.refreshSBTable();
			detailsDisplay_2.refreshSBTable();
		</script>
	<%
}else if("searchRouteTemplate".equalsIgnoreCase(strMode)){
	String fieldNameDisplay = request.getParameter("fieldNameDisplay");
	fieldNameDisplay = XSSUtil.encodeURLForServer(context, fieldNameDisplay);
    String fieldNameActual = request.getParameter("fieldNameActual");
    String fieldNameOID = request.getParameter("fieldNameOID");
    String strProjectId = request.getParameter("rootObjectId");
    
	 
	String strURL = "../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:CURRENT=policy_RouteTemplate.state_Active:LATESTREVISION=TRUE&table=RouteTemplateSummary&selection=single&showInitialResults=true&chooserType=CustomChooser&HelpMarker=emxhelpfullsearch&includeOIDprogram=emxRouteTemplate:getRouteTemplateIncludeIDs&displayView=details";
	strURL +="&objectId="+XSSUtil.encodeURLForServer(context,strProjectId);
	strURL +="&fieldNameDisplay="+XSSUtil.encodeURLForServer(context,fieldNameDisplay);
	strURL +="&fieldNameActual="+XSSUtil.encodeURLForServer(context,fieldNameActual);
	strURL +="&fieldNameOID="+XSSUtil.encodeURLForServer(context,fieldNameOID);
	strURL += "&submitURL=../programcentral/emxProgramCentralResourceRequestAutonomySearchSelect.jsp";
	%>
	<script language="javascript">
	<%--XSSOK--%>	var url = "<%=strURL%>";
		document.location.href = url;
	</script>
<%
}else if("promote".equalsIgnoreCase(strMode)){
    String issueObjectId = request.getParameter("objectId");
    Issue issue = (Issue)DomainObject.newInstance(context,"Issue");
    
    if(ProgramCentralUtil.isNotNullString(issueObjectId)){
    	try{
    		issue.setId(issueObjectId);
        	issue.promote(context);
    	}catch(Exception e){
    		e.printStackTrace();
    	}
    	%>
    	<script language="javascript">
	    	var topFrame = findFrame(getTopWindow(), "PMCWhatIfProjectChangeList");	
	    	topFrame.emxEditableTable.refreshStructureWithOutSort();
    	</script>
    	<%
    }
}else if("launchRoute".equalsIgnoreCase(strMode)){
    String issueObjectId = request.getParameter("objectId");
    String strURL = "../common/emxIndentedTable.jsp?program=emxRoute:getMyRoutes,emxRoute:getActiveRoutes,emxRoute:getInActiveRoutes";
    strURL += "&table=PMCWhatIfRouteSummaryTable&freezePane=Name&header=emxComponents.Routes.Heading2";
    strURL += "&programLabel=emxComponents.Filter.All,emxComponents.Filter.Active,emxComponents.Filter.Complete";
    strURL += "&emxSuiteDirectory=components&SuiteDirectory=components&suiteKey=Components&StringResourceFileId=emxComponentsStringResource";
    strURL += "&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false";
    strURL += "&sortColumnName=Name&sortDirection=ascending&selection=multiple&HelpMarker=emxhelproutes&objectId="+XSSUtil.encodeURLForServer(context,issueObjectId); 
   
    	%>
    	<script language="javascript">
   <%--XSSOK--%>
 	var url = "<%=strURL%>";
		document.location.href = url;
    	</script>
    	<%
    
}else if("defaultCompareWBS".equalsIgnoreCase(strMode)){
	String SELECT_PROJECT_ID = "to[Experiment].from.id";
	String experimentId = request.getParameter("objectId");
	DomainObject experiment = DomainObject.newInstance(context, experimentId);
	
	String projectId =experiment.getInfo(context,SELECT_PROJECT_ID);
	
	contentURL = "../common/emxIndentedTable.jsp?table=PMCWhatIfCompareViewTable&expandProgram=emxWhatIf:getExperimentWBSSubtasks&reportType=Complete_Summary_Report&IsStructureCompare=TRUE&expandLevel=0&objectId=";
	contentURL += XSSUtil.encodeURLForServer(context,experimentId) +","+ XSSUtil.encodeURLForServer(context,projectId);
	contentURL += "&ParentobjectId="+XSSUtil.encodeURLForServer(context,projectId)+"&objectId1="+XSSUtil.encodeURLForServer(context,experimentId)+"&objectId2="+XSSUtil.encodeURLForServer(context,projectId);
	contentURL += "&compareBy=Name,ID,Dependency,ConstraintType,Constraint Date,PhaseEstimatedDuration,PhaseEstimatedStartDate,PhaseEstimatedEndDate,Description&objectCompare=false&showClipboard=false&customize=false&rowGrouping=false&inlineIcons=false&displayView=details&syncEntireRow=true&SortDirection=ascending&SortColumnName=dupId&matchBasedOn=TaskId&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&showRMB=false";

	%>
	<script language="javascript">
<%--XSSOK--%>		var url = "<%=contentURL%>";
		document.location.href = url;
	</script>
	<%
}else if("defaultLaunchProjectBaselines".equalsIgnoreCase(strMode)){
	String SELECT_PROJECT_ID = "to[Project Baseline].from.id";
	String baselineId = request.getParameter("objectId");
	DomainObject baseline = DomainObject.newInstance(context, baselineId);
	
	String projectId =baseline.getInfo(context,SELECT_PROJECT_ID);
	
	StringBuffer sbUrl = new StringBuffer();
	sbUrl.append("../common/emxIndentedTable.jsp?").append("objectId=").append(XSSUtil.encodeURLForServer(context, baselineId));
	sbUrl.append("&parentOID=").append(XSSUtil.encodeURLForServer(context, projectId));
	sbUrl.append("&table=PMCScheduleBaselineTable");
	sbUrl.append("&multiColumnSort=true");
	sbUrl.append("&jsTreeID=null");
	sbUrl.append("&emxSuiteDirectory=programcentral");
	sbUrl.append("&suiteKey=ProgramCentral");
	sbUrl.append("&HelpMarker=emxhelpwbstasklist");
	sbUrl.append("&findMxLink=false");
	sbUrl.append("&cellwrap=false&portalMode=true");
	sbUrl.append("&freezePane=Name");
	sbUrl.append("&showPageHeader=false");
	sbUrl.append("&header=emxProgramCentral.Common.WorkBreakdownStructureSB");
	sbUrl.append("&selection=multiple");
	sbUrl.append("&sortColumnName=ID");
	sbUrl.append("&SuiteDirectory=programcentral");
	sbUrl.append("&StringResourceFileId=emxProgramCentralStringResource");
	sbUrl.append("&expandProgram=emxProjectBaseline:getWBSTasks");
	sbUrl.append("&expandLevel=1");
	sbUrl.append("&massPromoteDemote=false");
	sbUrl.append("&rowGrouping=false");
	sbUrl.append("&objectCompare=false");
	sbUrl.append("&showClipboard=false");
	sbUrl.append("&showPageURLIcon=false");
	sbUrl.append("&triggerValidation=false");
	sbUrl.append("&displayView=details");
	sbUrl.append("&multiColumnSort=false");
	sbUrl.append("&showRMB=false");
	contentURL = sbUrl.toString();
	%>
	<script language="javascript">
<%--XSSOK--%>		var url = "<%=contentURL%>";
		document.location.href = url;
	</script>
	<%
}else if("errorMsg".equalsIgnoreCase(strMode)){
	JsonObjectBuilder jsonObjectBuilder = Json.createObjectBuilder();
	String errorMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.Experiment.InvalidSync", context.getSession().getLanguage());
	jsonObjectBuilder.add("Error",errorMsg);

	out.clear();
	out.write(jsonObjectBuilder.build().toString());
	return;
}else if("ProjectBaseline".equalsIgnoreCase(strMode)){
	String projectId = request.getParameter("objectId");
	String strUrl  = "../programcentral/emxProgramCentralWhatIfAnalysis.jsp?mode=createProjectBaseline&objectId="+XSSUtil.encodeURLForServer(context,projectId);
%>
	<script language="javascript">
		var topFrame = findFrame(getTopWindow(), "PMCProjectBaselinesList");
		setTimeout(function() {
			topFrame.toggleProgress('visible');
		<%--XSSOK--%>	document.location.href = "<%=strUrl%>";
	    },100);
	</script>
	<%
}else if("createProjectBaseline".equalsIgnoreCase(strMode)){
	String projectId = request.getParameter("objectId");
	
		ProjectSpace project = (ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,"PROGRAM");
		
		ProjectBaseline projectBaseline = new ProjectBaseline();
	if(ProgramCentralUtil.isNotNullString(projectId)){
		//create an project baseline
		try{
			PropertyUtil.setRPEValue(context, "IsExperiment", "TRUE", true);
			
			project.setId(projectId);		
		projectBaseline.create(context,projectId);		
						
			TaskDateRollup.rolloutProject(context, new StringList(projectBaseline.getObjectId(context)), true,true);
			
		}catch(FrameworkException fe){
			fe.printStackTrace();
		}finally{
			PropertyUtil.setRPEValue(context, "IsExperiment", "FALSE", true);
		}

		String lang = context.getSession().getLanguage();
		String strSubject = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
						"emxProgramCentral.ProjectBaseline.CreateNotificationSubject", lang);
		String strBody = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
					"emxProgramCentral.ProjectBaseline.CreateNotificationContent", lang);
		strBody +=" "+projectBaseline.getName(context)+"\n\n";
		strBody +="Project Name:"+ project.getName(context);
			
		Person person = Person.getPerson(context);
		 
		StringList slTo = new StringList();
		slTo.add(person.getName(context));
			 
		MailUtil.sendNotification(context, slTo, null, null,strSubject, null, null, strBody, null, null, null, null,"emxProgramCentralStringResource");
	 	
%>
			<script language="javascript">
				var topFrame = findFrame(getTopWindow(), "PMCProjectBaselinesList");	
					setTimeout(function() {
						topFrame.toggleProgress('hidden');
						topFrame.location.href = topFrame.location.href;
				    },100);
					
			</script>
			<%
			}

		}else if ("PMCProjectBaselineList".equalsIgnoreCase(strMode)) {
       		String strURL = "../common/emxIndentedTable.jsp?table=PMCProjectBaselineSummaryTable&toolbar=PMCProjectBaselineActions&expandProgram=emxProjectBaseline:getProjectBaselines&postProcessJPO=emxProjectBaseline:postProcessRefresh&sortColumnName=BaselineEndDate&sortDirection=descending&freezePane=Name&selection=multiple&hideHeader=true&customize=false&rowGrouping=false&showPageURLIcon=false&hideLaunchButton=true&export=false&displayView=details&export=false&objectCompare=false&showClipboard=false&multiColumnSort=false&findMxLink=false&showRMB=false&massPromoteDemote=false&expandLevelFilter=false&triggerValidation=false&cellwrap=false&suiteKey=ProgramCentral&SuiteDirectory=programcentral&header=emxProgramCentral.Common.BaselinesSB";
       		String objectId = emxGetParameter(request, "objectId");
       		
       		Map paramMap = new HashMap(1);
 	    	    paramMap.put("objectId",objectId);
                
             String[] methodArgs = JPO.packArgs(paramMap);
            boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxTask", null, "hasModifyAccess", methodArgs, Boolean.class);
             
            Enumeration requestParams = emxGetParameterNames(request);
  		  	StringBuilder url = new StringBuilder();
               		
  		  	if(requestParams != null){
        		  while(requestParams.hasMoreElements()){
	        		  String param = (String)requestParams.nextElement();  
	        		  String value = emxGetParameter(request,param);
	        		  url.append("&"+param);
	        		  url.append("="+XSSUtil.encodeURLForServer(context, value));
	        		  
        		  }
        		  strURL = strURL + url.toString();
  		  	}
       		
       		if(hasModifyAccess){
       			strURL = strURL + "&editLink=true";
       		}
          %>
           <script language="javascript">
         		 var strUrl = "<%=strURL%>";
         		 document.location.href = strUrl;
           </script> 
         <%
        }	
%>
