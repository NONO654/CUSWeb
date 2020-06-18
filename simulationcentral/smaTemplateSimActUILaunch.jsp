<%--  smaTaskRunConduit.jsp   - intermediary jsp launched when selecting done
 * on simulation/simulation activity run dialog"
 * (c) Dassault Systemes, 2007, 2008
 *
--%>
<%-- Common Includes --%>

<%@page import="com.dassault_systemes.smaslm.matrix.server.COSWUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
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
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template"%>

<script type="text/javascript" src="../webapps/Polymer-1.6.1/webcomponents-lite.min.js"></script>
<script src="../webapps/AmdLoader/AmdLoader.js"></script>




<link rel="import" id= "spRunImport" href="../webapps/SMAProcSP/sp-run/sp-run.html">
<link rel="import" id= "spCosImport" href="../webapps/SMAProcSP/sp-cos/sp-cos.html">

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>






<%
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

     String ticket ="";
     String eedURL = "";
     String runInfo = "";
     String tempServerString = "";
     String modelXML = "";

     String objId = emxGetParameter(request, "objectId");
     String isTask = emxGetParameter(request, "isTask");
     String[] sRowIds = null;
     sRowIds = emxGetParameterValues(request, "emxTableRowId");
     if (sRowIds != null && sRowIds.length > 0)
     {
         StringList ids = FrameworkUtil.split(sRowIds[0], "|");
         objId = (String)ids.get(0);
     }
     //Template simObj = DomainObject.newInstance(context, objId);
     Template simObj = new Template(objId);
     if (!simObj.isSimActUIEnabledToLaunch(context))
     {
         %>
         <script>
         alert("Could not launch External UI");
         </script>
         <%
         return;
     }

     String physicalID = simObj.getInfo(context, "physicalid");
     String applicationData ="";
    // Get the parameters needed by smaRunTask
    try
    {
        // get client IP and name
        String httpString = emxGetParameter(request, "httpString");
        String hostName = emxGetParameter(request, "hostName");
        String rootContext = emxGetParameter(request, "rootContext");
        String serverLoc = httpString+"//"+hostName + "/"+rootContext;

        HashMap paramMap = new HashMap();
        HashMap programMap = new HashMap();

        paramMap.put("objectId",objId);
        paramMap.put("MCSURL",serverLoc);
        programMap.put("paramMap",paramMap);

        String[] methodargs = JPO.packArgs(programMap);
        modelXML = (String) JPO.invoke(context, "jpo.simulation.Template", null,
            "getSimActUIModelXML",methodargs,String.class );

        modelXML = "<?xml version='1.0' encoding='UTF-8' ?>"+modelXML;

        HashMap cosDataMap = COSWUtil.getCOSTicket(context, objId);

        ticket = (String)cosDataMap.get("ticket");

        cosDataMap = COSWUtil.getCOSURL(context);

        eedURL = (String)cosDataMap.get("url");

        int index = eedURL.lastIndexOf("/");
        int length = eedURL.length();
        if(length-index==1){
            eedURL=eedURL.substring(0,length-1);
        }

		 applicationData =
	   "<JobInfo><Application name=\"Execution\" updatePLM=\"false\"><PLMObject physicalid=\""+physicalID+"\">"+objId+"</PLMObject><AppUrl>"+serverLoc+"</AppUrl><AppResource>/resources/slmservices</AppResource><HasLocalHost>true</HasLocalHost></Application></JobInfo>";
         runInfo = "<RunInfo logLevel='Debug' submissionHost=''></RunInfo>";
        //modelXML = modelXML.replaceAll("\"", "'");
      modelXML = modelXML.replace("\n", "").replace("\r", "");
       //applicationData = applicationData.replaceAll("\"", "'");
    }
    catch (FrameworkException ex)
    {
    }

   %>

   <script type="text/javascript">

   var topWin = getTopWindow();
    pubKey = "";
    var ticket1 = "<%=ticket%>";
    var eedURL1 = "<%=eedURL%>" + '/execution/run';
    var eedURLRest = "<%=eedURL%>"+'/execution/pubkey';
    var runInfo = "<%=runInfo%>";
    var modelxml = "<%=XSSUtil.encodeForJavaScript(context,modelXML)%>";
    var appData = "<%=XSSUtil.encodeForJavaScript(context,applicationData)%>";
    var objId = "<%=objId%>";
	  var retData = "";
    var isTask="<%=isTask%>";
    if(isTask=="null")
    	{
    	 isTask="false";
    	}

      var link = document.querySelector('#spRunImport');
      // Go if the async Import loaded quickly. Otherwise wait for it.
      if (link.import && link.import.readyState === 'complete' ) {
          submitJob();
      } else {
          link.addEventListener('load', function(){
              submitJob();
          });
      }

      function submitJob () {

        window.require(['UWA/Class/Promise', 'UWA/Utils'],function(UWAPromise, Utils){
          var spRun = document.createElement('sp-run');
          var spCos = document.createElement('sp-cos');

          this.document.getElementsByTagName('head')[0].appendChild(spRun);
          this.document.getElementsByTagName('head')[0].appendChild(spCos);
          window.Promise = UWAPromise;
          spCos.refreshCosConfigurations(function(){
            spRun.runEXML(null, modelxml, objId, null, null, appData, true, null );
            spRun.addEventListener('success', function(){
              alert("External UI Launch request submitted succesfully");
                var topWin = getTopWindow();
                      if(isTask==="false") {
                        if(topWin.getWindowOpener() != null) {
                            topWin = topWin.getWindowOpener().getTopWindow();
                        }
                        var hiddenFrame = findFrame(topWin,"hiddenFrame");
                        var psURL = "../simulationcentral/smaHomeUtil.jsp?objectAction=EntryInPerformanceStudy";
                        hiddenFrame.location.href = psURL;
                    }
            });
            spRun.addEventListener('error', function(event){
              alert('Failed to Launch External UI ');
            });
          });
        });
  }
    </script>
