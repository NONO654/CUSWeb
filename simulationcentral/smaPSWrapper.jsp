<%--
  All jsp usage in Performance Study
--%>
<html>
  <head>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.db.Context"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%
    String objectAction = emxGetParameter(request, "objectAction");
    String objectId = XSSUtil.encodeForURL(context, emxGetParameter(request, "objectId"));
    String url = "";

    if("copy".equals(objectAction)) {
        url = "../common/emxForm.jsp?objectAction=copySimulation&fromPage=PerformanceStudy&form=SMACommon_Copy&mode=edit&formHeader=Common.Copy.Generic.PageHeading&preProcessJPO=jpo.simulation.SimulationUI%3ApreCopy&postProcessURL=..%2Fsimulationcentral%2FsmaCopyUtil.jsp&postProcessProgram=jpo.simulation.SimulationUI%3ApostCopy&targetLocation=slidein&HelpMarker=SMASimulation_PropsCopy&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null&hideCancel=true&resetForm=true";
        url += "&objectId=" + objectId;
        url += "&parentOID=" + objectId;

    } else if("revise".equals(objectAction)) {
        url = "../common/emxForm.jsp?form=SMASimulation_Revise&mode=edit&formHeader=Common.Revise.PageHeading&objectAction=reviseSimulation&preProcessJPO=jpo.simulation.SimulationUI%3ApreRevise&postProcessURL=../simulationcentral/smaReviseUtil.jsp&postProcessProgram=jpo.simulation.SimulationUI:postRevise&submitAction=doNothing&HelpMarker=SMASimulation_RevisionsRevise&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null&submitLocation=PerformanceStudy&hideCancel=true";
        url += "&objectId=" + objectId;
        url += "&parentOID=" + objectId;

    } else if("newSimProcessFromExp".equals(objectAction)) {
        url = "../common/emxIndentedTable.jsp?program=jpo.simulation.SLMLiteTables:getMySimulationTemplates&toolbar=SMASLMLite_Templates_ListToolbar&table=SMADiscover_ListMyTemplates&massUpdate=false&mode=view&suiteKey=SimulationCentral&PrinterFriendly=false&selection=multiple&Export=true&sortColumnName=Modified&sortDirection=descending&HelpMarker=SMADiscover_ListMyTemplates";

    } else if("newSimCompanionProcess".equals(objectAction)) {
        url = "../common/emxForm.jsp?mode=edit&form=SMASimulationCompanion_Create&formHeader=smaSimulationCentral.SMAActions.CreateNewCompanionProcess&postProcessURL=../simulationcentral/smaInstantiateCompanionProcess.jsp?submitAction=treeContent&suiteKey=SimulationCentral&SuiteDirectory=simulationcentral";

    } else if("newSimProcess".equals(objectAction)) {
        url = "../common/emxCreate.jsp?form=SMASimulation_Create&header=smaSimulationCentral.CreateSimProc.Name&postProcessURL=../simulationcentral/smaCreateNewProcess.jsp?postProcessProgram=jpo.simulation.Simulation:postCreate&policy=policy_Simulation&type=type_Simulation&submitAction=treeContent&suiteKey=SimulationCentral&SuiteDirectory=simulationcentral&typeChooser=false&nameField=keyin&findMxLink=false&HelpMarker=SMAHome_CreateNewSimProcess";

    } else {
        url = "data:text/plain,Invalid%20object%20action";
    }
%>
    <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUICoreMenu.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUISlideIn.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>
    <style>
      html, body {
        padding:0;
        margin:0;
      }
    </style>
  </head>
  <body>
    <iframe name="detailsDisplay" src="<%=url%>" width="100%" height="100%" frameborder="0" border="0"></iframe>
    <iframe name="hiddenFrame" id="hiddenFrame" width="0%" height="0%" frameborder="0" border="0" style="display:none;"></iframe>
  </body>
</html>
