<%--  smaRunLogFS.jsp   - jsp launched from job status remarks icon"
 * (c) Dassault Systemes, 2007, 2008
 *  
--%>

<%@page import="java.util.Iterator"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template, 
        com.dassault_systemes.smaslm.matrix.common.SimulationUtil,
        com.dassault_systemes.smaslm.matrix.common.SimulationConstants,
        java.util.Map, com.matrixone.apps.domain.util.MapList,
        com.dassault_systemes.smaslm.matrix.server.SlmUtil,
        matrix.util.StringList, com.matrixone.apps.domain.DomainObject,
        com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"  src="./smaAdviseLaunchHelper.js"></script>

<%
    String objectId = emxGetParameter(request, "objectId");
StringBuilder contentURL = new StringBuilder(175);
final String RELATIONSHIP_SIMULATION_TEMPLATE_CONTENT = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_relationship_SimulationTemplateContent);
final String RELATIONSHIP_SIMULATION_TEMPLATE_VIEW = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_relationship_SimulationTemplateView);
final String kindOfSimualtion = SlmUtil.getKindOfString(SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_Simulation));
final String TYPE_SimulationTemplate =
    SimulationUtil.getSchemaProperty(
            SimulationConstants.SYMBOLIC_type_SimulationTemplate);
final String TYPE_SimulationTemplateView =
    SimulationUtil.getSchemaProperty(
            SimulationConstants.SYMBOLIC_type_SimulationTemplateView);
final String TITLE =  SimulationUtil.getSelectAttributeTitleString();
boolean isXSUser = SimulationContentUtil.isXSUser(context, null);
Template DO = null;
boolean isSimulationTemplate = false, isTemplateView = false;
String templateViewId = null, simId = null, templateId = null, templateTitle = null;
if (objectId != null)
{
    DO = new Template(objectId);
    StringList templateSelects = new StringList(new String[] {SimulationConstants.PHYSICAL_ID, TITLE});     
    Map templateInfo = DO.getInfo(context, templateSelects);
    templateId = (String)(templateInfo.get(SimulationConstants.PHYSICAL_ID));
    templateTitle = (String)(templateInfo.get(TITLE));
    
    MapList mapList = DO.getContentAndViewInfo(context);
    Map map = null;
    String relationshipName = null;
    for (int i = 0; i < mapList.size(); i++) 
    {
        map = (Map) mapList.get(i);
        relationshipName = (String) map.get("relationship");
        if (RELATIONSHIP_SIMULATION_TEMPLATE_CONTENT.equals(relationshipName))
        {
            isSimulationTemplate = Boolean.valueOf((String)map.get(kindOfSimualtion));
            simId = (String) map.get("physicalid");
        } else if (RELATIONSHIP_SIMULATION_TEMPLATE_VIEW.equals(relationshipName)) {
            isTemplateView = true;
            templateViewId = (String) map.get("physicalid");
        }
    }
}
String appName = "Process Composer", licensedAppName = "ENOPRCB_AP"; 
if (isSimulationTemplate && isTemplateView && isXSUser) {
    appName = "Process Experience Studio";
    licensedAppName = "SIMEXPS_AP";
    contentURL.append("../simulationcentral/smaExperienceStudio.jsp").append("?viewId=").append(templateViewId).append("&simId=").append(simId).append("&objectId=").append(templateId).append("&templateTitle=").append(templateTitle);
            } else {
                appName = "Process Composer"; 
                licensedAppName = "ENOPRCB_AP";
    contentURL.append("../common/emxTree.jsp?objectId="+objectId);
}

%>
            <script>
            var appsMenuList = new Array();
            appsMenuList[0] = 'SMAScenario_Definition_New';
            getTopWindow().changeProduct('SIMULIA', "<%=appName%>", "<%=licensedAppName%>", appsMenuList, "<%=licensedAppName%>", null);
            
            var ddFrame = findFrame(getTopWindow(),"content");
             ddFrame.location.href="<%=contentURL.toString()%>";
            </script>

            






