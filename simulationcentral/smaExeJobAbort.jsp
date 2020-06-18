<%--  smaExeJobAbort.jsp   - jsp that posts/refreshes the job summary 
 * page with appropriate filter
 * (c) Dassault Systemes, 2007, 2008
 *  
--%>
<%-- Common Includes --%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationJob"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.ExecutionServiceUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>
<html>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>

<%
    String objectAction = emxGetParameter(request, "objectAction");
    String submitAction = emxGetParameter(request, "submitAction");
    String refreshFrame = emxGetParameter(request, "refreshFrame");
    StringBuilder contentURL = null;

    String simObjectId = emxGetParameter(request, "objectId");
    String[] sRowIds = null;
    String parentId = null;
    String[] relIds = null;
    String[] objIds = null;
    String[] parIds = null;
    String sError = "";
    int nObjs = 0;
    boolean isSimJobObj = false;
    final String TYPE_SIMULATIONJOB =
        SimulationUtil.getSchemaProperty(
            SimulationConstants.SYMBOLIC_type_SimulationJob);
    DomainObject doObj = new DomainObject(simObjectId);
    
    String type_TestCase = SimulationUtil.getSchemaProperty(DomainConstants.TYPE_TEST_CASE );
    String type_TestExecution = SimulationUtil.getSchemaProperty(DomainConstants.TYPE_TEST_EXECUTION);
    String type_Task = SimulationUtil.getSchemaProperty(DomainConstants.TYPE_TASK);
    String type_Template = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationTemplate);
    if(simObjectId == null || simObjectId.equalsIgnoreCase("") || type_TestCase.equalsIgnoreCase(doObj.getType(context))
        || type_TestExecution.equalsIgnoreCase(doObj.getType(context))
        || type_Task.equalsIgnoreCase(doObj.getType(context))){
        sRowIds = emxGetParameterValues(request, "emxTableRowId");
        
        nObjs = sRowIds.length;
        relIds = new String[nObjs];
        objIds = new String[nObjs];
        parIds = new String[nObjs];
        for (int i = 0; i < nObjs; i++)
        {
            StringList sIds = convertRowId(sRowIds[i]);
            relIds[i] = (String) sIds.get(0);
            objIds[i] = (String) sIds.get(1);
            parIds[i] = (String) sIds.get(2);

            if (sRowIds[i].startsWith("nada"))
            {
                sRowIds[i] = sRowIds[i].substring(4);
            }

        }
        // Many of the commands below are single select commands
        // so get the object id from the first item selected
        simObjectId = objIds[0];
        doObj.setId(simObjectId);
        parentId = parIds[0];
    }
    if(doObj.isKindOf(context,TYPE_SIMULATIONJOB))
    {
        isSimJobObj = true;
    }
    
    
    SimulationJob simJob = null;
        
    if ( (objectAction == null) || (objectAction.equals("")) )
    {
        emxNavErrorObject.addMessage(
            "smaExeJobAbort.jsp objectAction not found");
        objectAction = "";
    }
    DomainObject simObj = DomainObject.newInstance(context, simObjectId);
    boolean isTemp = type_Template.equalsIgnoreCase(simObj.getType(context));
    if (isTemp){
        sError = 
            SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Job.NoSimulation");
            emxNavErrorObject.addMessage(sError);
        objectAction = "";
    }
    if(objectAction.equals("abort")){
        if (isSimJobObj)
        {
            simJob = new SimulationJob(simObjectId);
        } else{ 
            Simulation sim = new Simulation(simObjectId);
            simJob = sim.getJob(context);    
        }
        
        
        String jobId = simJob.getId(context);
        String jobStatus = simJob.getStatus(context);
        jobStatus = jobStatus != null ? jobStatus : "";
        boolean canAbort = false;
        
        if(jobStatus.equals(SimulationConstants.JOB_STATUS_RUNNING) ||
            jobStatus.equals(SimulationConstants.JOB_STATUS_PAUSED) ||
            jobStatus.equals(SimulationConstants.JOB_STATUS_WAITING))
            canAbort = true;
        
        if(jobId!=null && canAbort)
        {
            String [] jpoArgs = {jobId,"MODIFY" };
            HashMap eedInfo=(HashMap)JPO.invoke( context, 
                "jpo.simulation.Job", null, 
                "getEEDData", jpoArgs, HashMap.class);
            
            String eedJobId = (String)eedInfo.get("eedJobId");
            //ExecutionServiceUtil.updateJobDescriptor(context, jobId, "Execution", "Done", "Canceled", null, System.currentTimeMillis()+"", eedJobId);
            String URL = (String)eedInfo.get("eedURL"); 
            URL = URL+"/execution/"+eedJobId+"/cancel";
            String ticket = (String)eedInfo.get("ticket"); 
         // javascript for calling webservices
            %>
            <script language = javascript>
            var ticket = "<%=ticket%>";
            var submitAction = "<%=submitAction%>";
            var refreshFrame = "<%=refreshFrame%>";
            
            var eedURLRest = "<%=URL%>";
            
             var httpRequest = new XMLHttpRequest();
             
             httpRequest.open('PUT', eedURLRest, true);
             httpRequest.setRequestHeader('Content-Type', 'text/xml,charset=utf-8');
             httpRequest.setRequestHeader('EEDTicket', ticket);
             
             httpRequest.onreadystatechange = function () {
                 if (httpRequest.readyState == 4) {
                     if (httpRequest.status == 200) {
                         var jobRet = httpRequest.responseText;
                         refreshCallerFrame(submitAction, refreshFrame);
                     }
					 else if(httpRequest.status == 500)
					 {
					 <%
					 ExecutionServiceUtil.updateJobDescriptor(context, jobId, "Execution", "Done", "Canceled", null, String.valueOf(System.currentTimeMillis()), eedJobId);
					 %>
					 refreshCallerFrame(submitAction, refreshFrame);
					 }
                 }
             }
             httpRequest.send();
           </script>
          <%
        }
        else{
            emxNavErrorObject.addMessage(
            		SimulationUtil.getI18NString(context,
                    "smaHome.cmdChecks.JobNotRunning"));
        }
    }

%>
<%!
 private StringList convertRowId(String sRowIds)
{
    // If called from emxTable, the row ids might be
    //   <connection id>|<selected object id>
    // If called from an emxIndentedTable, the row ids are:
    //   <conection id>|<selected object id>|<parent object id>|<indented table ordering tag>
    // In either case, pull out the <selected object id>.

    // Special case if user selected root... connection id will be
    // an empty string which causes split to not return an element
    // thus making everything off by 1

    if ( sRowIds.startsWith("|") )
        sRowIds = "nada" + sRowIds;

    // Get the ids
    StringList sIdList = FrameworkUtil.split(sRowIds, "|");

        // Make sure list has at least 3 elements in it
    while ( sIdList.size() < 3 ){
         String nullString = null;
        sIdList.addElement(nullString);
         }

    String first = (String)sIdList.get(0);
    if (first.equals("nada"))
        sIdList.set(0, null);

    return sIdList;
}
%>
<script language = javascript>
function refreshCallerFrame (submitAction, refreshFrame)
{
    var refreshWindow = getTopWindow().getWindowOpener()? getTopWindow().getWindowOpener() : getTopWindow();
    refreshWindow = findFrame(getTopWindow(),refreshFrame);
    // considering Abort Command is only resides in Jobs Page
    refreshWindow = refreshWindow ? refreshWindow : findFrame(getTopWindow(),"SMASimulation_NavTreeJobs");
    // If Jobs page not found then refresh top frame
    if(!refreshWindow){
        refreshWindow = getTopWindow().getWindowOpener()? getTopWindow().getWindowOpener() : getTopWindow();
    }
    
    if ("refreshCaller" == submitAction)
    {
        var refreshUrl = refreshWindow.document.location.href;
        if(refreshUrl.indexOf("emxIndentedTable.jsp") >= 0){
            refreshWindow.refreshSBTable(refreshWindow.configuredTableName);
        } else {
           refreshWindow.document.location.href=refreshWindow.document.location.href;
        }                            
     }
    if ("doNothing" == submitAction)
    {
        return false;                            
     }
}
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>
