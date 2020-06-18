<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>


<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript"
	src="../plugins/UWA/js/UWA_Swym_Alone_full.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
    String runApplication = emxGetParameter(request, "runApplication");
if(runApplication == null || "".equalsIgnoreCase(runApplication))
    runApplication="run";

String objId = emxGetParameter(request, "objectId");
String isFromRMB = emxGetParameter(request, "isFromRMB");
String stepId = emxGetParameter(request, "stepId");
String isTask = emxGetParameter(request, "isTask");
String keepOpen = emxGetParameter(request, "keepOpen");
stepId = (stepId != null && stepId.length()>0)? stepId : "null"; 
String parentId = null;
String[] relIds = null;
String[] objIds = null;
String[] parIds = null;
int nObjs = 0;
DomainObject Do = new DomainObject(objId);
String type_TestCase = SimulationUtil.getSchemaProperty(DomainConstants.TYPE_TEST_CASE );
String type_TestExecution = SimulationUtil.getSchemaProperty(DomainConstants.TYPE_TEST_EXECUTION);
String type_Task = SimulationUtil.getSchemaProperty(DomainConstants.TYPE_TASK);
String type_TestMethod = PropertyUtil.getSchemaProperty("type_TestMethod");
String[] sRowIds = null;

if(objId == null || objId.equalsIgnoreCase("") || type_TestCase.equalsIgnoreCase(Do.getType(context))
    || type_TestExecution.equalsIgnoreCase(Do.getType(context))
    || type_TestMethod.equalsIgnoreCase(Do.getType(context))
    || type_Task.equalsIgnoreCase(Do.getType(context))
    ||(isFromRMB!=null && isFromRMB.equalsIgnoreCase("true"))){
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
    objId = objIds[0];
    parentId = parIds[0];
}

    
%>
<%!
   private StringList convertRowId( String sRowIds )
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
<script type="text/javascript">
   var runApplicationVar = "<%=runApplication%>";
   var objIdVar = "<%=objId%>";
   var stepIDvar = "<%=stepId%>";
   var keepOpen = "<%=keepOpen%>";
   var topWin = getTopWindow();
   var httpString = topWin.location.protocol;
   var hostName = topWin.location.host;
   var rootContext = topWin.location.pathname;
	var runURL = "";
	var isTask="<%=isTask%>";
   if (rootContext !== null && rootContext.length > 0) {
       rootContext = rootContext.substring(1); //filter off the first slash - /
       rootContext = rootContext.substring(0, rootContext.indexOf("/"));
   } else {
       //uh-oh, can't determine the root context, set to default
       rootContext = "enovia";
   }

   if (runApplicationVar == "ExternalUILaunch") {
       runURL = "../simulationcentral/smaTemplateSimActUILaunch.jsp?objectId="
               + objIdVar + "&httpString=" + httpString + "&rootContext="
               + rootContext + "&hostName=" + hostName + "&stepId="
               + stepIDvar + "&isTask=" + isTask;
       var hiddenFrame = findFrame(topWin, "hiddenFrame");
       hiddenFrame.location.href = runURL;
   } else {
       runURL = "../simulationcentral/smaRunExeSimulation.jsp?objectId="
               + objIdVar + "&runApplication=" + runApplicationVar
               + "&httpString=" + httpString + "&rootContext=" + rootContext
               + "&hostName=" + hostName + "&stepId=" + stepIDvar;

       if (runApplicationVar == "ConfigureAndRun") {
           topWin.location.href = runURL;
       } else {
           var frameListHidden;
           if (topWin.getWindowOpener()) {
               frameListHidden = findFrame(topWin.getWindowOpener()
                       .getTopWindow(), "listHidden");
               if (frameListHidden == null)
                   frameListHidden = findFrame(topWin.getWindowOpener()
                           .getTopWindow(), "hiddenFrame");
               if (!keepOpen || keepOpen != "true")
                   topWin.closeWindow();
           } else {
               frameListHidden = findFrame(topWin, "listHidden");
               if (frameListHidden == null)
                   frameListHidden = findFrame(topWin, "hiddenFrame");
           }
           frameListHidden.location.href = runURL;
       }
   }
</script>

