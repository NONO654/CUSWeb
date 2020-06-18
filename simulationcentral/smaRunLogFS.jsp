<%--  smaRunLogFS.jsp   - jsp launched from job status remarks icon"
 * (c) Dassault Systemes, 2007, 2008
 *  
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SIMULATIONS"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationJob"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.JobDescriptor"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<%
    String objId = emxGetParameter(request, "objectId");
final String TYPE_SIMULATION =
    SimulationUtil.getSchemaProperty(
            SimulationConstants.SYMBOLIC_type_SIMULATIONS);
final String TYPE_SimulationJob =
    SimulationUtil.getSchemaProperty(
            SimulationConstants.SYMBOLIC_type_SimulationJob);

DomainObject DO = null;
boolean isNewV6ISightSimulation = true;
String eedJobId = "";
String source = "";
String logHeader="";
if (objId != null)
{
    DO = new DomainObject(objId);
    if (DO.isKindOf(context, TYPE_SIMULATION))
    {
        SIMULATIONS sim = new SIMULATIONS(objId);
        SimulationJob simJob = sim.getJob(context);
        isNewV6ISightSimulation = sim.isNewV6ISightSimulation(context);
        objId = simJob != null ? simJob.getId(context) : null;  
    }
}
SimulationJob simJob = new SimulationJob(objId);
String jobStatus = "", jobName = "", jobStartTime = "", jobEndTime = "";
if (objId != null && simJob.isKindOf(context, TYPE_SimulationJob))
{
    try {
    jobStatus = simJob.getStatus(context);
    jobName = simJob.getName(context);
    jobStartTime = simJob.getStartTime(context);
    jobEndTime = simJob.getEndTime(context);
    if (isNewV6ISightSimulation)
    {
        JobDescriptor jobDescptr = new JobDescriptor(context, objId);
        eedJobId = jobDescptr.getFiperJobId();
        source = "../simulationcentral/smaDiscoverJobMonitor.jsp?objectId=" + objId + "&EEDJobId=" + eedJobId + "&jobStatus="+jobStatus;
    }
    } catch (Exception e) {
        
    }
%>
<script type="text/javascript">
var frameJobMonitor = 
    sbFindFrame(getTopWindow(), "SMADiscover_JobMonitor");
    
if(frameJobMonitor == null)
    getTopWindow().location.href = "<%= source%>";
else 
    frameJobMonitor.location.href = "<%= source%>";
    
</script>
<%
} else {
    //String locale = context.getSession().getLanguage();
    String message = SimulationUtil.getI18NString(context,"smaSimulationCentral.JobLog.ErrMsg.noLogObject");
    out.println(message);
}
%>


