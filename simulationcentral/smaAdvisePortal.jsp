<html>
<head>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script	type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js" ></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>

	<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
	<script type="text/javascript" src="../simulationcentral/smaAdviseHelp.js"></script>
	<script>
		window.onbeforeunload = removeGlobalLinks;
	   	window.onunload = removeGlobalLinksTryAgain;
	</script>
	
	<link rel="stylesheet" type="text/css" href="./styles/smaAdviseHelp.css">
	
	<%
		String commonDir = request.getParameter("COMMON_DIR");
		if(commonDir==null) {
			commonDir = "../common";
		}
		String suiteDir = request.getParameter("SUITE_DIR");
		if(suiteDir == null) {
			suiteDir = "../simulationcentral";
		}
		//String portalURL = commonDir + "/emxPortal.jsp?portal=SMAHome_Advise&header=smaSimulationCentral.Advise&suiteKey=SimulationCentral&HelpMarker=SMAHome_Advise" ;
		String portalURL = commonDir + "/"+"emxIndentedTable.jsp?" + "massUpdate=false&" + "jsTreeID=null&" + "toolbar=SMAAdvise_Cases_ListToolbar&" + "portal=SMAHome_Advise&"+
				"table=SMAAnalyticsCase_GlobalResults&"+"expandProgramMenu=SMAAdvise_Expand&" + "header=smaSimulationCentral.Advise&" + "portalMode=true&" + "selection=multiple&" + "Export=false&"+
				"mode=edit&"+"inquiry=SMAAnalyticsCase_FindAll&"+"PrinterFriendly=false&" + "sortColumnName=Modified&" + "suiteKey=SimulationCentral&" + "SuiteDirectory=simulationcentral&"+
				"HelpMarker=SMAHome_SMAHome_Advise_TabCases&"+"StringResourceFileId=smaSimulationCentralStringResource&" + "sortDirection=descending&" + "portalCmdName=SMAHome_SMAHome_Advise_TabCases";
	%>
<script type="text/javascript">
	//pre load the splash screen
	var splash = new Image();
	splash.src = "../webapps/SMASLMAdviseUI/assets/images/smaAdviseSplash.png"; 
</script>
</head>
<body onunload="removeAdviseHelp();">
	<div class="sim-ui-portal-container" id="portalDiv">
		<iframe class="sim-ui-portal-frame" name="subContent" id="portalFrame" src="<%=portalURL%>"></iframe>
	</div>
	<script type="text/javascript">
		sessionStorage.adviseReferrer =  location.href;
		jQuery(document).ready(function(){ addHelpLinkToGlobalToolBar("", "<%=suiteDir%>" + "/smaAdviseHelp.jsp"); });
	</script>	
</body>
</html>
