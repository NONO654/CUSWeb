<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationActivity"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SIMULATIONS"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationJob"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.util.StringList"%>


<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<html>
    <head>
      <meta charset="utf-8" />
      <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
    
    </head>
    <body style="height:100%;width:100%;">

    <% 
        String sError = "";
        String objId = emxGetParameter(request,"objectId");
        String jobObjectId = emxGetParameter(request,"jobObjectId");
        String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");
        String parentId = null;
        String[] relIds = null;
        String[] objIds = null;
        String[] parIds = null;
        int nObjs = 0;
        if(objId == null || objId.equals(""))
        {
            nObjs = sRowIds.length;
            relIds = new String[nObjs];
            objIds = new String[nObjs];
            parIds = new String[nObjs];
            for (int i = 0; i < nObjs; i++)
            {
                StringList sIds = SimulationContentUtil.convertRowId(sRowIds[i]);
                relIds[i] = (String) sIds.get(0);
                objIds[i] = (String) sIds.get(1);
                parIds[i] = (String) sIds.get(2);

                if (sRowIds[i].startsWith("nada"))
                {
                    sRowIds[i] = sRowIds[i].substring(4);
                }

            }
            
            objId = objIds[0];
            parentId = parIds[0];
        }
        
        DomainObject DO = new DomainObject(objId);
        String jobId = null;
        String jobName = null;
        String physicalId = null;
        SimulationJob simJob = null;
        String status = null;
        final String TYPE_SIMULATION =
            SimulationUtil.getSchemaProperty(
                    SimulationConstants.SYMBOLIC_type_SIMULATIONS);
        
        String ISAct=FrameworkUtil.getType(context, DO);
        if(ISAct.equals("Simulation Activity"))
        {
            SimulationActivity act=new SimulationActivity(objId);
            String simulationId = act.getAbsoluteParentSimulationOid(context);
            objId=simulationId;
        }
        
        // sanity check that we have a simulation
        if (DO.isKindOf(context, TYPE_SIMULATION))
        {
        	if(jobObjectId == null || jobObjectId.equals("")) {
	            // get related current job.
	            SIMULATIONS sim = new SIMULATIONS(objId);
	            simJob = sim.getJob(context);
        	} else {
        		simJob = new SimulationJob(jobObjectId);
        	}
            jobId = simJob != null ? simJob.getId(context) : null;  
            jobName = simJob != null ? simJob.getName(context) : null;  
            status = simJob != null ? simJob.getStatus(context): null;
            physicalId = simJob != null ?
                 simJob.getInfo(context,SimulationConstants.PHYSICAL_ID) 
                 : "";
        }
        else {
            sError = 
                SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Job.NoSimulation");
            emxNavErrorObject.addMessage(sError);
        }
        
        if (null == simJob)
        {
            sError = 
                SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Job.Pending.NoJob");
            emxNavErrorObject.addMessage(sError);
            
        }
        else if(!SimulationConstants.JOB_STATUS_WAITING.equals(status))
        {
            sError = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Job.Pending.NoInteractiveItems" );
            emxNavErrorObject.addMessage(sError);
        }
        else
        {
            // set content url to point to emxTable and set the program jpo
            // to the method to get the maplist for the station rows 
            // the stsation data is gotten in a webservice call to the EED
            // made in java script
            // it is past to the program jpo by using a post of a form 
            // containing the url and an argument set through jQuery
            // for the station data xml returned by the web service call
            StringBuffer contentURL =  new StringBuffer(); 
            contentURL.append("../common/emxTable.jsp?")
                       .append("program=jpo.simulation.Job:getPendingItems")
                       .append("&table=SMAJob_PendingItems")
                       .append("&header=smaSimulationCentral.Job.Pending.PageHeading")
                       .append("&Export=false")
                       .append("&PrinterFriendly=false")
                       .append("&showClipboard=false")
                       .append("&objectCompare=false")
                       .append("&disableSorting=true")
                       .append("&jobId=").append(jobId)
                       .append("&objectId=").append(objId)
                       .append("&selection=multiple")
                       .append("&toolbar=SMAJobsInteractive_Toolbar")
                       .append("&HelpMarker=SMAJob_PendingItems")
                       .append("&suiteKey=SimulationCentral")
                       .append("&mode=view")
                       .append("&massUpdate=false");
            
            //  call a jpo method to get the EED url to use
            // for the station data query web service call
            String [] jpoArgs = {jobId,"READ" };
            HashMap eedInfo=(HashMap)JPO.invoke( context, 
                "jpo.simulation.Job", null, 
                "getEEDData", jpoArgs, HashMap.class);
    
            StringBuffer eedURL =  new StringBuffer(); 
            String ticket = (String)eedInfo.get("ticket");
            eedURL.append((String)eedInfo.get("eedURL"))
                    .append("/workitem/query");
                  
        // use java script to define the form holding the content url
        // so the station data can be past as a POST method since it
        // may be to long to pass in a GET method by setting the href
        
        // also make the web service call to get the station data in the
        // java script so it runs on the client not the server
        %>

    <form style="display: hidden" action="<%=contentURL.toString()%>"
        method="POST" id="form">
        <input type="hidden" id="pendingData" name="pendingData" value="" />
    </form>

    <script language="javascript">
        var dataStr = "";
        var ticket1 = "<%=ticket%>";
        var physId = "<%=physicalId%>";
      crit = "<Criteria status=\"RUNNING\"><ApplicationId>";
      crit = crit +  physId + "</ApplicationId><WorkItemCriteria>";
      crit = crit + "<WorkItem status=\"PAUSED BEFORE\" interactiveType=\"\"/>";
      crit = crit + "<WorkItem status=\"PAUSED AFTER\" interactiveType=\"\"/>";
      crit = crit + "</WorkItemCriteria></Criteria>" ;
        try
        {
            var myXMLHTTPRequest = new XMLHttpRequest();
            myXMLHTTPRequest.open("GET", "<%=eedURL.toString()%>", false);
            myXMLHTTPRequest.setRequestHeader('EEDTicket', ticket1);
            myXMLHTTPRequest.setRequestHeader('Criteria',crit);
            myXMLHTTPRequest.setRequestHeader('Cache-Control','no-cache');
            myXMLHTTPRequest.setRequestHeader('Pragma','no-cache');
            myXMLHTTPRequest.send(null);
            dataStr = myXMLHTTPRequest.responseText.htmlEncode();
            if (dataStr == null) dataStr = "";
        }
        catch (err)
        {
            alert ("Request had exception " + err.toString());
            var vDebug = "";
            for (var prop in err)
            { 
               vDebug += "property: "+ prop+ " value: ["+ err[prop]+ "]\n";
            }
            alert(vDebug);
            dataStr = "";
        }
        $("#pendingData").val(dataStr);
        $("#form").submit();
    </script>
    <% 
    }
    %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
        // if we have an error 
        if (sError.length()>0 )
        {
%>
<script language = javascript>
closeWindow();
</script>
<%
            return;  
        }    
%>

</body>
</html>
