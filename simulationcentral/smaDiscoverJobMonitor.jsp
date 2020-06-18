<%-- (c) Dassault Systemes, 2008 --%>


<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.util.StringList"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SIMULATIONS"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationJob"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.JobDescriptor"%>
<%@page import="com.dassault_systemes.smaslm.common.util.XMLUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Set"%>
<%@page import="com.matrixone.jdom.Document"%>
<%@page import="com.matrixone.jdom.Element"%>
<%@page import="com.matrixone.jdom.output.XMLOutputter"%>
<%@page import="matrix.db.FileList"%>

<%@page import="java.util.Iterator"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.ByteArrayOutputStream"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.IOException"%>
<%@page import="com.dassault_systemes.smaslm.common.util.JobUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<script type="text/javascript"
    src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
    final String PARAM_FILE_CHAR_ENCODING = "UTF-8";
            String simJobId = emxGetParameter(request, "objectId");
            String eedJobId = emxGetParameter(request, "EEDJobId");
            String refreshRate = 
                SimulationUtil.getProperty(context,
                    "smaSimulationCentral.JobPage.RefreshRate");
            refreshRate.trim();
            if(refreshRate!=null && "".equalsIgnoreCase(refreshRate)){
                try{
                    Integer.valueOf(refreshRate);
                }catch(Exception e){
                    refreshRate= SimulationConstants.JobPageRefreshRate;
                }
            }
            else
                refreshRate= SimulationConstants.JobPageRefreshRate;
            SimulationJob simJob = new SimulationJob(simJobId);
            String jobStatus = simJob.getStatus(context);
            String jobName = simJob.getInfo(context, "name");
            String ticket = "";
            String eedURL = "";
            
            if( (jobStatus != null || !jobStatus.equalsIgnoreCase(""))
                && (jobStatus.equalsIgnoreCase(SimulationConstants.JOB_STATUS_RUNNING) 
                ||  jobStatus.equalsIgnoreCase(SimulationConstants.JOB_STATUS_PAUSED)
                ||  jobStatus.equalsIgnoreCase(SimulationConstants.JOB_STATUS_WAITING)))
            {
            %>
<html>
<head>
<meta charset="utf-8" />
<title>Job Log</title>
</head>
<body>
    <style>
#JobLog {
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    width: 100%;
    border-collapse: collapse;
    background-color: #FFFFFF;
}

#JobLog td,#JobLog th {
    font-size: 0.8em;
    border: 1px solid #C0C0C0;
    padding: 3px 7px 2px 7px;
}

#JobLog th {
    font-size: 1.1em;
    text-align: center;
    padding-top: 5px;
    padding-bottom: 4px;
    background-color: #BCD2EE;
    color: #000000;
}

#JobLog tr.alt td {
    color: #000000;
    background-color: #C0C0C0;
}
</style>
    <div id="tabs">
        <ul>
            <p>
            <table id="JobLog" align="left">
                <thead>
                    <tr>
                        <th>Severity</th>
                        <th>Message</th>
                        <th>Time</th>
                        <th>Source</th>
                    </tr>
                </thead>
            </table>
            </p>
        </ul>

        <% 
                HashMap paramMap = new HashMap();
                HashMap programMap = new HashMap();

                paramMap.put("objectId",simJobId);
                paramMap.put("iPLMObjAccessType", "MODIFY");
                programMap.put("paramMap",paramMap);

                String[] methodargs = JPO.packArgs(programMap);
                Document jobDoc = 
                    (Document) JPO.invoke(context, 
                        "jpo.simulation.Job", null, 
                        "getExeJobXML",methodargs,
                        Document.class );

                Element rootNode = jobDoc.getRootElement();
                ticket = rootNode.getChildText("EEDTicket");
                
                eedURL = rootNode.
                getChild("EEDInfo").
                getAttributeValue("eedWsURL");
                
                
                JobDescriptor jobDescptr = 
                    new JobDescriptor(context, simJobId);

                eedJobId = jobDescptr.getFiperJobId();
                eedURL = eedURL+"/job/"+eedJobId+"/log";
                %>
        <script language=javascript>
                var jobLogString ;
                jQuery.ajax(
                    {
                        url : "<%=eedURL.toString()%>",
                        type : "GET",
                        cache:false,
                        beforeSend: function(request)
                        {
                            var ticketString = "<%=ticket.toString()%>";
                            request.setRequestHeader("EEDTicket", ticketString);
                        },
                        success : function(returndata,status,xhr)
                        {                            
                            renderJobLog(returndata);
                        },
                        error :  function(  jqXHR,  textStatus,  errorThrown ){
                           alert("error in log web service");
                           alert("status "+textStatus);
                           alert("Error thrown "+errorThrown);
                        }
                    }
                );
function renderJobLog(returnData)
{
    var table = document.getElementById("JobLog");
    logEntryNode = returnData.getElementsByTagName("LogEntry");
    for (i=0;i<logEntryNode.length;i++)
      { 
          var row = table.insertRow(-1);
          
          if (i % 2 != 0)
              row.style.backgroundColor="#F0F0F0";
          
          var severityCell  = row.insertCell(0);
          var messageCell  = row.insertCell(1);
          var timeCell = row.insertCell(2);
          var sourceCell = row.insertCell(3);

          timeCell.innerHTML = logEntryNode[i].getElementsByTagName("Time")[0].childNodes[0].nodeValue;
          sourceCell.innerHTML = logEntryNode[i].getAttribute('source');
          messageCell.innerHTML = logEntryNode[i].getElementsByTagName("Msg")[0].childNodes[0].nodeValue;
          severityCell.innerHTML = logEntryNode[i].getAttribute('severity');
      }

    }
$(function() {
    var frameJobMonitor = sbFindFrame(getTopWindow(), "SMADiscover_JobMonitor");
setInterval(
        function(){
            if(frameJobMonitor == null)
                getTopWindow().location.href = 
                    getTopWindow().location.href;
            else    
                frameJobMonitor.location.href = 
                    frameJobMonitor.location.href;
        }, 
        <%=refreshRate%>);
});
                </script>
        <% 
            }
            else{
            StringBuffer contentURL = new StringBuffer();
            contentURL
                    .append("../common/emxIndentedTable.jsp?")
                    .append("table=SMASimulation_JobLog&")
                    .append("selection=none&")
                    .append("HelpMarker=SMADiscover_JobMonitor&")
                    .append("program=jpo.simulation.XmlTable:getTableForJobLog&")
                    .append("toolbar=SMAJobLog_ToolBar&")
                    .append("Export=true&")
                    .append("PrinterFriendly=true&")
                    .append("objectBased=false&")
                    .append("multiColumnSort=false&")
                    .append("sortColumnName=Time&")
                    .append("mode=view&")
                    .append("displayView=details&")
                    .append("hideLaunchButton=false&")
                    .append("portalMode=true&")
                    .append("objectId=")
                    .append(simJobId);
            
            String toURL = contentURL.toString();
            if (simJobId != null) {
%>
        <script>
var frameJobMonitor = 
    sbFindFrame(getTopWindow(), "SMADiscover_JobMonitor");
    
    if(frameJobMonitor == null)
       getTopWindow().location.href = "<%= toURL%>";
    else
       frameJobMonitor.location.href = "<%=toURL%>";
       
        </script>
        <%
    }
            }
%>
    </div>
</body>
</html>
