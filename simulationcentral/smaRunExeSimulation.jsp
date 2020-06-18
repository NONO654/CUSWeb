<%--  smaTaskRunConduit.jsp   - intermediary jsp launched when selecting done 
 * on simulation/simulation activity run dialog"
 * (c) Dassault Systemes, 2007, 2008
 *  
--%>
<%-- Common Includes --%>

<%@page import="com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "java.util.Enumeration"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.XmlTableUtil"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.jdom.Document"%>
<%@page import="com.matrixone.jdom.Element"%>
<%@page import="java.net.URL"%>
<%@page import = "java.util.Calendar"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>


<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaGeneral.js"></script>
<script type="text/javascript" src="../simulationcentral/smaEncryption.js"></script>
<script type="text/javascript" src="../webapps/Forge-0.6.34/forge.min.js"></script>


<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../plugins/UWA/js/UWA_Swym_Alone_full.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>





<%
    // If an error occurred, don't continue
    /*String errorMsg = emxNavErrorObject.toString();
    if ( errorMsg != null && errorMsg.length() > 0 ) 
        return;*/

    /****************************************************************
     * This jsp is called as a postProcessUrl.
     * For this, the correct context must be obtained from
     * request.getAttribute("context"). This is the context of the
     * containing jsp that is calling us, and was put there by the
     * containing jsp.
     * Otherwise, this jsp ends up with its own context, separate from
     * that of the containing jsp, which also results in a separate
     * database context, which is not good.
     ****************************************************************/
     matrix.db.Context context2 = 
         (matrix.db.Context)request.getAttribute("context");
     if (context2 != null)
         context = context2;
     String jobMonitorTabURL = "";
     String refreshRate = SimulationConstants.JobPageRefreshRate;//SimulationUtil.getProperty("smaSimulationCentral.JobPage.RefreshRate");
     //parameters for the EEP ticket and EED URL
     
    String runApplication = emxGetParameter(request, "runApplication");
    if(runApplication == null || "".equalsIgnoreCase(runApplication))
        runApplication="run";
 
     String ticket ="";
     String eedURL = "";
     String serverLoc = "";
     String serverHostName = "";
     String encodedJobXML = "";
     String jobXML = "";
     String localHostName = "localhost";
     String clientname = "";
     String runInfo = "";
     String ticketUrl = "";
     String csrfWSURL = "";
     String tempServerString = "";
     String failJobUrl = "";
     String abortJobConfirmMessage = 
         SimulationUtil.getI18NString(context,
             "Confirm.SMAHome_ActionsAbort");
     String jobSubmitSuccessfulMessage = 
         SimulationUtil.getI18NString(context,
             "Success.JobSubmit.Message");
     
    String objId = emxGetParameter(request, "objectId");

    String stepId = emxGetParameter(request, "stepId");
	String mcsUser = context.getUser();
	String eedID="";
	String hasLocalHostStr="";
	
	StringBuffer cosURL= new StringBuffer();
        try
        {
            //  call a jpo method to get the EED url to use
            // for the drm list COS web service call
            HashMap<String,String> eedInfo = (HashMap<String,String>)JPO.invoke(context, 
               "jpo.simulation.SimulationHost", null, 
               "getEEDData", null, HashMap.class);
            
            cosURL.append(eedInfo.get("eedURL")).append("/admin");
        }
        catch(Exception e)
        {
            //Missing SMAExeConfiguration.properties file
            cosURL.append("/admin");
        }
		
    try 
    {
        DomainObject simObj = DomainObject.newInstance(context, objId);
        if(simObj.getType(context).equals(
            SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationTemplate))){
            String errMsg = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Job.NoSimulation");

        emxNavErrorObject.addMessage(errMsg);
        
        %>
        <script>
            alert("<%=errMsg%>");
        </script>
        <%
        throw new FrameworkException(errMsg);
        }

        Simulation sim = new Simulation(objId);
        String status = "";
        if(sim.isKindOf(context, 
            SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationActivity)))
        {
            String id = sim.getInfo(context, 
                "relationship["+SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationActivity)+"].from.id");
            sim = new Simulation(id);
        }
        if(sim.isTemplateParent(context)){
            String errMsg = SimulationUtil.getI18NString(context,
                "smaHome.cmdChecks.Run.TemplContent");

        emxNavErrorObject.addMessage(errMsg);
        
        %>
        <script>
            alert("<%=errMsg%>");
        </script>
        <%
        throw new FrameworkException(errMsg);
        }
        
        status = sim.getRunStatus(context);    
        
        if(status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_RUNNING)
            ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_PAUSED)
            ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_NOTSTARTED)
            ||status.equalsIgnoreCase(SimulationConstants.JOB_STATUS_WAITING))
        {
            String attrName=sim.getInfo(context, "attribute[Title]");
            String errMsg = SimulationUtil.getI18NString(context,
                    "Error.JobDelete.JobRunning");

            emxNavErrorObject.addMessage(errMsg);
            String errorMessage = StringResource.format(
                    errMsg, "P1", attrName);
            
            
            // TODO i18n externalize the message
            // also close the popup window
            String blockRunMessage =  "The run command cannot be executed as process is currently running or paused or not started.";
            %>
            <script>
                alert('<%= blockRunMessage %>');
            </script>
            <% 
           
            throw new FrameworkException(errorMessage);
          
        }
        
        
        // get client IP and name
        String clientip = getClient_IP(request);
        
         java.net.InetAddress address = java.net.InetAddress.getByName(clientip);
        
        if (address instanceof java.net.Inet6Address)
        {
            clientname = address.getHostName();
        } 
        byte[] addr = null ;
        if(clientname == null || clientname.isEmpty())
        {
            StringList iplist = FrameworkUtil.split(clientip, ".");
            addr = new byte[iplist.size()];
            for(int i=0;i<iplist.size();i++)
            {
                addr[i] = (byte)Integer.parseInt((String)iplist.get(i));
            }
            
            clientname = java.net.InetAddress.getByAddress(addr).getHostName();
        }
        
    // Get the server Location
         java.net.InetAddress localMachine =
             java.net.InetAddress.getLocalHost();
          localHostName = localMachine.getHostAddress();
          
         // The url is of the form
        // http://machineName:port/ematrix/simulationcentral/
        String httpString =  emxGetParameter(request, "httpString");
        String hostName =  emxGetParameter(request, "hostName");
        String rootContext =  emxGetParameter(request, "rootContext");
            
        serverLoc = httpString+"//"+hostName + "/"+rootContext;
        serverHostName = hostName; 

        ticketUrl = serverLoc + "/ticket/get?accept=text/plain";
        csrfWSURL = serverLoc + "/resources/slmservices/token/CSRF";

        HashMap paramMap = new HashMap();
        HashMap programMap = new HashMap();

        paramMap.put("objectId",objId);
        paramMap.put("mcsURL",serverLoc);
        
        if(stepId != null && !stepId.equals("null") && stepId.length()>0)
        {
            paramMap.put("stepId",stepId);
        }
        programMap.put("paramMap",paramMap);
        
        
        
        String[] methodargs = JPO.packArgs(programMap);
        Document jobDoc = null;
        try
        {
            jobDoc = (Document) JPO.invoke(context, "jpo.simulation.Job", null, 
            "processExeSimulationJob",methodargs,Document.class );
        
        }catch(Exception e)
        {
            
            String errorMessage = e.getMessage();
            errorMessage = MessageServices.massageMessage(errorMessage);
            %>
            <script>
                alert('<%= errorMessage %>');
            </script>
            <% 
            throw new FrameworkException(errorMessage);
        }
        
        Element rootNode = jobDoc.getRootElement();
        
        ticket = rootNode.getChildText("EEDTicket");
        Element applicationNode = rootNode.getChild("Application");
		hasLocalHostStr = applicationNode.getChild("HasLocalHost").getText();
        
        eedURL = rootNode.getChild("EEDInfo").
                 getAttributeValue("eedWsURL");
        
		eedID = rootNode.getChild("EEDInfo").
                 getAttributeValue("eedID");
				 
        //if there is "/" at the end of URL, remove it
        int index = eedURL.lastIndexOf("/");
        int length = eedURL.length();
        if(length-index==1){
            eedURL=eedURL.substring(0,length-1);
        }
        
        jobXML = XmlTableUtil
                .toString(jobDoc);
        
        String logLevel = sim.getExecutionOptionFieldValue(context, "logLevel", null, "Information");
		
        runInfo = "<RunInfo logLevel=\""+logLevel+"\" submissionHost=\"\"></RunInfo>";
        runInfo = StringUtil.htmlEncode(runInfo).trim();
        
        encodedJobXML = StringUtil.htmlEncode(jobXML).trim();
        
        jobXML = jobXML.trim();
        jobMonitorTabURL = "../simulationcentral/smaRunLogFS.jsp?jsTreeID=null&parentOID="+objId+"&portal=SMAHome_Discover&objectId="+objId+"&suiteKey=SimulationCentral&HelpMarker=SMADiscover_JobMonitor&showPageHeader=false&portalCmdName=SMADiscover_JobMonitor&portalMode=true&mode=advanced";
        System.out.println("jobXML: "+ jobXML);
        System.out.println("jobXMLEncoded: "+ encodedJobXML);
        
        //set up url in case we need to fail the job if the EED is bad
        try
        {
            // get the job id info and resource string 
            String appName = applicationNode.getAttributeValue("name");
            String JobObjId = 
                applicationNode.getChild("PLMObject").getText();
            String resourceStr = 
                applicationNode.getChild("AppResource").getText();
			
			long timeNow = Calendar.getInstance().getTimeInMillis();
            String timeStr = Long.toString(timeNow);
    
            
            StringBuilder  failJobUrlBld= 
                new StringBuilder(serverLoc);
            failJobUrlBld.append(resourceStr).append("/jobinfo/job/")
                .append(JobObjId).append("/").append(appName)
                .append("/state").append("?State=Done")
                .append("&CC=Failed").append("&StartDate=")
                .append(timeStr).append("&EndDate=").append(timeStr);
            
            failJobUrl = failJobUrlBld.toString();
        }
        catch (Exception ex)
        {
            // ignore problems since can't fail the job
        }

    }
    catch (FrameworkException ex)
    {
        //throw new MatrixException(ErrorUtil.getMessage(ex));
        //throw new MatrixException("Cannot run");
        //throw new FrameworkException(ex);
        
        //throw ex;
        out.close();
    }
    
   %>
   
   <%!
   
   public static String getClient_IP(HttpServletRequest request) {  
       String _IP = request.getHeader("X-Forwarded-For");  
       if (_IP == null || _IP.length() == 0 || "unknown".equalsIgnoreCase(_IP)) {  
           _IP = request.getHeader("Proxy-Client-_IP");  
       }  
       if (_IP == null || _IP.length() == 0 || "unknown".equalsIgnoreCase(_IP)) {  
           _IP = request.getHeader("WL-Proxy-Client-_IP");  
       }  
       if (_IP == null || _IP.length() == 0 || "unknown".equalsIgnoreCase(_IP)) {  
           _IP = request.getHeader("HTTP_CLIENT__IP");  
       }  
       if (_IP == null || _IP.length() == 0 || "unknown".equalsIgnoreCase(_IP)) {  
           _IP = request.getHeader("HTTP_X_FORWARDED_FOR");  
       }  
       if (_IP == null || _IP.length() == 0 || "unknown".equalsIgnoreCase(_IP)) {  
           _IP = request.getRemoteAddr();  
           
       } 
        if(_IP != null || _IP.length() >0)
           {
               if(_IP.equals("127.0.0.1"))
               {
                   try{
                   java.net.InetAddress localHostIP =
                             java.net.InetAddress.getLocalHost();
                          _IP = localHostIP.getHostAddress(); 
                   }
                   catch(Exception ex)
                   {
                       // handle exception or ignore it for local host case
                   }
               }
       }  
       return _IP;  
   }

   %>
   
   <html>
   
   <script type="text/javascript">

   var topWin = getTopWindow();
   var frameJobMonitor = findFrame(topWin, "SMADiscover_JobMonitor");
    
    pubKey = "";
    var mcsURL = "<%=serverHostName%>";
    var ticket1 = "<%=ticket%>";
    var eedURL1 = "<%=eedURL%>" + '/execution/run/workflow';
    var eedURLRest = "<%=eedURL%>"+'/execution/pubkey';
    var serverName = "<%=request.getServerName() %>"
    var encodedJobXML1 = "<%=encodedJobXML%>";
    var mcsServerString = "<%=tempServerString%>";
    var runApplication = "<%=runApplication%>";
    var subHost = "<%=clientname%>";
    var runInfo = "<%=runInfo%>";
    var objectID = "<%=objId%>";
    var abortJobConfirmMessage = "<%=abortJobConfirmMessage%>";
    var jobSubmitSuccessfulMessage = "<%=jobSubmitSuccessfulMessage%>";
    var failJobUrl = "<%=failJobUrl%>";
    var mcsTicketUrl = "<%=ticketUrl.toString()%>";
    var csrfWSURL = "<%=csrfWSURL.toString()%>";

    if(runApplication == "ConfigureAndRun") {
        topWin.getWindowOpener().sessionStorage.eedURL = eedURL1;
        topWin.sessionStorage.eedURL = eedURL1;
        topWin.getWindowOpener().sessionStorage.encodedJobxml = encodedJobXML1;
        topWin.getWindowOpener().sessionStorage.mcsServerString = mcsServerString;
        topWin.getWindowOpener().sessionStorage.ticket = ticket1;
        topWin.getWindowOpener().sessionStorage.runINFO = runInfo;
        topWin.getWindowOpener().sessionStorage.abortConfirmMessage = abortJobConfirmMessage;
        topWin.getWindowOpener().sessionStorage.jobSubmitSuccessfulMessage = jobSubmitSuccessfulMessage;
        topWin.getWindowOpener().sessionStorage.failJobUrl = failJobUrl;
        topWin.getWindowOpener().sessionStorage.mcsTicketUrl = mcsTicketUrl;
    } else {
        topWin.sessionStorage.eedURL = eedURL1;
        topWin.sessionStorage.encodedJobxml = encodedJobXML1;
        topWin.sessionStorage.mcsServerString = mcsServerString;
        topWin.sessionStorage.ticket = ticket1;
        topWin.sessionStorage.runINFO = runInfo;
        topWin.sessionStorage.jobSubmitSuccessfulMessage = jobSubmitSuccessfulMessage;
        topWin.sessionStorage.abortConfirmMessage = abortJobConfirmMessage;
        topWin.sessionStorage.failJobUrl = failJobUrl;
        topWin.sessionStorage.mcsTicketUrl = mcsTicketUrl;
    }
    
    function runJobEXE() {

             var xmlhttpGetPubKey = new XMLHttpRequest();
             
             xmlhttpGetPubKey.open('GET', eedURLRest, true);
             xmlhttpGetPubKey.setRequestHeader('Content-Type', 'text/xml,charset=utf-8');
             xmlhttpGetPubKey.setRequestHeader('EEDTicket', ticket1);
             
             xmlhttpGetPubKey.onreadystatechange = function () {
                 if (xmlhttpGetPubKey.readyState == 4) {
                     if (xmlhttpGetPubKey.status == 200) {
                         var jobRet = xmlhttpGetPubKey.responseText;
                          var xmlDoc = $.parseXML(jobRet);
                          pubKey = $(xmlDoc).find("KeyRep").text();
                          if(runApplication == "ConfigureAndRun")
                              makeConfigureAndRunJob(pubKey);
                          else
                              {
                               pubKey = encodeURIComponent(pubKey);
                          getEncryptedCredentials(pubKey);
                     }
                     }
                     else
                     {
                        failTheJob("<%=ticketUrl.toString()%>", 
                                "<%=failJobUrl.toString()%>","", "<%=csrfWSURL.toString()%>");
                     }
                 }
             }
             xmlhttpGetPubKey.send();
        }

function failJobEXE() {

              failTheJobForSecureStation("<%=ticketUrl.toString()%>", 
                                "<%=failJobUrl.toString()%>", "<%=csrfWSURL.toString()%>");
        }
        
function getEncryptedCredentials(pubKey)
{
    jQuery.ajax
    (
        {
            url : "../simulationcentral/smaEncriptedCredentials.jsp?pubKey="+pubKey+"&runApplication="+runApplication,
                    type : "POST",
                    dataType : "text",
                    success : function (returndata,status,xhr)
                        {
							emxUICore.trim(returndata); 
							makeRunJob(returndata, runApplication);
						}
        }
    );
}

function makeConfigureAndRunJob(pubKey)
    {
        jQuery.ajax
        (
            {
                url : "<%=ticketUrl.toString()%>",
                type : "GET",
                cache:false,
                success : function (returndata,status,xhr)
                {
                    try
                    {
                        var ticket;
                        try{
                            ticket = String(returndata.documentElement.childNodes[1].textContent);
                        }
                        catch(error)
                        {
                            var myData1 = String(returndata);
                                                        var sMyData1 = myData1.split('\n');
                            var ticketStr = sMyData1[0].split("ticket=");
                            ticket = ticketStr[1];
                        }
                      
                        var encryptedCreds = 
                            getEncodedCredentials(ticket, pubKey);
                        topWin.getWindowOpener().sessionStorage.extCreds 
                        = encryptedCreds;
						makeRunJob(encryptedCreds, runApplication);
                    }
                    catch(error)
                    {
                        alert(error)
                    }
                }
            }
        );
    }
	
	var cosURL =  "<%=cosURL.toString()%>";
var cosMajor;
var cosMinor;
var cosFix;
var enoviaUser = "<%=mcsUser%>";
var eedID1 = "<%=eedID%>";
var stationName="";
var stationUser="";
var stationCOSIP="";
var space3D="";
var portNum="";
var eedJobId;
var validClient=false;
var userMsg="Your Job failed to start. Could not determine Private Station URI";
var deferreds = [new jQuery.Deferred(), new jQuery.Deferred(), new jQuery.Deferred()];
var that = this;
var hasLocalHost = "<%=hasLocalHostStr%>";
var successPort="";

if(hasLocalHost=="true")
{
   jQuery.ajax({
        url: cosURL,
        type: 'GET',
        beforeSend: function(request){
            request.setRequestHeader('Accept', 'application/json');
       },
        success: function(response){
        	that.cosMajor = response.SystemInfo["@major"];
			that.cosMinor = response.SystemInfo["@minor"];
			that.cosFix = response.SystemInfo["@fix"];
			
			if((cosMajor > 6)||((cosMajor == 6) && (cosMinor > 418))||((cosMajor == 6) && (cosMinor == 418) && (cosFix >= 3)))
	{
		var LOCAL_STATION_DOMAIN = 'dslauncher.3ds.com',
            LOCAL_STATION_PORTS = ['35125', '45341', '55447'],
            STATION_PATH = '/SMAExeStation-REST';

            var pingStation = function (port, index, pingFailure) {
                
                var stationBaseUri = 'https://' + LOCAL_STATION_DOMAIN + ':' + port + STATION_PATH + '/station/info';
				jQuery.ajax({
        url: stationBaseUri,
        type: 'GET',
	beforeSend: function(request){
            request.setRequestHeader('Accept', 'application/json');
        },
        success: function(response){
        	that.stationName = response.StationData.name;
			that.stationUser = response.StationData.user;
			that.stationCOSIP = response.StationData.cosid;
			that.space3D = response.StationData.spaceurl;
			that.portNum=port;
			if(enoviaUser.toUpperCase() != stationUser.toUpperCase())
				{	
					userMsg="Your Job failed to start. Please check that you are using the same user for your local station";
				}
				else if(eedID1!=stationCOSIP)
				{
					userMsg="Your Job failed to start. Please check that your local station is connected to the right execution engine.";
				}
								else if(space3D.search(mcsURL)==-1)
				{
					userMsg="Your Job failed to start. Please check that your local station is connected to the right 3DExperience Platform";
				}
				else 
				{
					that.validClient=true;
					that.successPort = port;
					runJobEXE();
				}
deferreds[index].resolve();
			},
        error: function(err){
deferreds[index].resolve();
          pingFailure();
		  }
    });
	 
			};
            
            // manually chain callback
            pingStation(LOCAL_STATION_PORTS[0], 0, function () {
                        console.log("Port "+LOCAL_STATION_PORTS[0]+" is inactive ");
                    });
			pingStation(LOCAL_STATION_PORTS[1], 1, function () {
                       console.log("Port "+LOCAL_STATION_PORTS[1]+" is inactive ");
                    });
			pingStation(LOCAL_STATION_PORTS[2], 2, function () {
                        console.log("Port "+LOCAL_STATION_PORTS[2]+" is inactive ");
                    });					
               
			  jQuery.when(deferreds[0], deferreds[1], deferreds[2]).done(
        function() {
			console.log("All pings to secure private stations are complete.");
			if(!validClient)
			{
				alert(userMsg);
				failJobEXE();
			}
          });
			  
	}
		
			},
        error: function(err){
            noStations();
        }
    });

}
else
{
	runJobEXE();
}
    </script>
    
   
    </html>
