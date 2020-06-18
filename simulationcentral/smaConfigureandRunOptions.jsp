<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.CacheUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.Map"%>
<script type="text/javascript"
    src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%

            Map requestMap = UINavigatorUtil
                    .getRequestParameterMap(pageContext);

            String objectId = (String) requestMap.get("objectId");

            HashMap programMap = new HashMap();
            programMap.put("requestMap", requestMap);
            
            programMap.put("stream", SimulationConstants.EXT_NAME_PROCESS_EXEC_OPTION);
             
            String[] args = JPO.packArgs(programMap);
            
            try{
                
                JPO.invoke( context, 
                "jpo.simulation.ExecutionOption", null, 
                "SaveValuesInXmlOfProcess",args,Boolean.class);
            }
            catch(Exception e){
                e.printStackTrace();
            }
            
            StringBuffer contentURL = new StringBuffer();

            contentURL
            .append("../simulationcentral/smaRunExePreProcessing.jsp?")
            .append("objectId=").append(objectId);
%>
<script>
var url = "<%=contentURL.toString()%>";
var topWin = getTopWindow().getWindowOpener().getTopWindow();
topWin.childWindow = getTopWindow();
if((topWin.sessionStorage.windowsUser == "" || topWin.sessionStorage.windowsUser == null) 
		&& (topWin.sessionStorage.linuxUser == ""  || topWin.sessionStorage.linuxUser == null) 
		&& (topWin.sessionStorage.isightV5User == "" || topWin.sessionStorage.isightV5User == null))
 {
    url = url+"&runApplication=run";
} else {
        url = url+"&runApplication=ConfigureAndRun";
}
        getTopWindow().location.href = url;
</script>
