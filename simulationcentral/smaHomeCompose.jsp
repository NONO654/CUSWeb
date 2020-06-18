<%-- (c) Dassault Systemes, 2008 --%>


<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
String contentURL = "../common/emxIndentedTable.jsp?inquiry=SMAFindCompose_OwnedMod7DaysSimulation,SMAFindCompose_OwnedMod30DaysSimulation,SMAFindCompose_OwnedSimulation,SMAFindCompose_AllMod7DaysSimulation,SMAFindCompose_AllMod30DaysSimulation,SMAFindCompose_AllSimulation&inquiryLabel=smaSimulationCentral.MySimulations.Owned.Modified.within.Seven.Days,smaSimulationCentral.MySimulations.Owned.Modified.within.Thirty.Days,smaSimulationCentral.MySimulations.Owned,smaSimulationCentral.MySimulations.All.Modified.within.Seven.Days,smaSimulationCentral.MySimulations.All.Modified.within.Thirty.Days,smaSimulationCentral.MySimulations.All&table=SMAListSimulationsNew&selection=multiple&header=smaSimulationCentral.SimProcs.Name&disableSorting=true&multiColumnSort=false&toolbar=SMAProcessListToolbar&suiteKey=SimulationCentral&expandProgram=jpo.simulation.Simulation:getOrderedActivities";
String widgetURL = "../widget/bpsWidget.jsp?bps_widget=SMACompose_NavigatorExperience";
String composeNavTitle = EnoviaResourceBundle.getProperty(context, "SimulationCentral", "smaSimulationCentral.SCE.Composer", context.getLocale().getLanguage());
%>
<html>
<head>
<title></title>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaGeneral.js"></script>
<script>
function toggleRibbon (navDiv)
{
    var navFrm = document.getElementById(navDiv);
    if (navFrm.className == "OPEN")
        navFrm.className = "CLOSE"
    else
        navFrm.className = "OPEN"
}
</script>
<style>
.OPEN {
    visibility: ; 
    display: ;
    } 
.CLOSE {
    visibility: hidden; 
    display: none;
    }
    
div.header {
    background: none repeat scroll 0 0 #CECECE;
    border: 1px solid #BCBCBC;
    border-radius: 4px 4px 0 0;
    color: #333333;
    cursor: pointer;
    font-weight: bold;
    line-height: 16px;
    text-align: center;
    vertical-align: middle;
}
div.header:hover {
    background: none repeat scroll 0 0 #D5E8F2;
    border: 1px solid #04A3CF;
    color: #04A3CF;
}
</style>
</head>
<body>
<div id="smaComposeNavigationDiv" onclick="toggleRibbon('smaHomeComposeNav');" class="header"><%= composeNavTitle %></div> 
    <iframe src="<%=widgetURL %>" id="smaHomeComposeNav" class="OPEN"
        name="smaHomeComposeNav" width="100%" height="60" frameborder="0" border="0" scrolling="no"></iframe>

    <iframe src="<%=contentURL %>" id="smaHomeComposeContent"
        name="smaHomeComposeContent"  width="100%" height="800" frameborder="0" border="0"></iframe>
</body>
</html>






