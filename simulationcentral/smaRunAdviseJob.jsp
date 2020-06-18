<%--  smaRunAdviseJob.jsp - main page for opening an analytics case
 * (c) Dassault Systemes, 2013
 *
--%>
<%-- Common Includes --%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONObject"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="matrix.util.MatrixException"%>
<%@page import="com.matrixone.apps.common.util.ComponentsUtil" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@page import="com.dassault_systemes.smaslm.matrix.server.AnalyticsCaseEntityWUtil"%>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<!-- Load the web components polyfill -->
	<!-- <script type="text/javascript" src="../webapps/Polymer/platform.js"></script> -->
	<script type="text/javascript" src="../webapps/Polymer-1.1.4/webcomponents-lite.js"></script>
	<!-- Load Polymer and any other web components -->
	<link rel="import" href="../webapps/SMAProcSP/sp-encryption/sp-encryption.html"/>
	
<%
	/****************************************************************
	 * For this JSP, the correct context must be obtained from
	 * request.getAttribute("context"). This is the context of the
	 * containing jsp that is calling us, and was put there by the
	 * containing jsp.
	 * Otherwise, this jsp ends up with its own context, separate from
	 * that of the containing jsp, which also results in a separate
	 * database context, which is not good.
	 ****************************************************************/
	matrix.db.Context context2 = (matrix.db.Context) request
			.getAttribute("context");
	if (context2 != null)
		context = context2;
	
	// check for appropriate lic
	Boolean hasLicense = false;
			
	try{
		ComponentsUtil.checkLicenseReserved(context, "RIW");
		hasLicense = true;
	}
	catch(Exception e){
		throw new MatrixException("No available license for Results Analytics.");
	}
	
	if(!"SIMREII_AP".equals(emxGetParameter(request,"appName"))){
		%>
		<script type="text/javascript">
			history.replaceState(null, '',window.location.href+'&appName=SIMREII_AP');
		</script>
		<%
	}
	
	// Get the 3DSpace/Server URL.
	String myAppsURL = "";
	try{
		myAppsURL = FrameworkUtil.getMyAppsURL(context, request,response);
	} catch (Exception ex){
		myAppsURL = "";
	}
	
	String runAsStr = emxGetParameter(request, "runAs");
	String setStation = emxGetParameter(request, "setStation");
	String objId = emxGetParameter(request, "objectId");
	String emxTableRowId = emxGetParameter(request, "emxTableRowId");
	String fromExt =  emxGetParameter(request, "fromExt");
	String currentUser = context.getUser();
	
	// We open only one case, so choose the first item from the selected list
	String[] sRowIds = null;
	
	try {
		if(objId == null || objId.equalsIgnoreCase("")){
			if(emxTableRowId!=null && emxTableRowId.length()>4) {
				sRowIds = emxTableRowId.split("(\\Q" + "|" + "\\E)+");
				// we open only one case, so choose the first item from the selected list
				objId = sRowIds[1];
			}
		}
		if (objId == null || objId.equalsIgnoreCase("")) {
			String rowID = (String) session
					.getAttribute("specialRowID");
			session.removeAttribute("specialRowID");
			sRowIds = rowID.split("(\\Q" + "|" + "\\E)+");
			// we open only one case, so choose the first item from the selected list
			objId = sRowIds[1];
		}
	} catch (Exception e) {
		//do nothing
	}
	
	boolean bFromExt = false;
	if(fromExt!=null && "true".equalsIgnoreCase(fromExt)) {
		bFromExt = true;
		%>
		<script type="text/javascript">
			document.location.href = "../common/emxNavigator.jsp?appName=SIMREII_AP&objectId=<%=objId%>";
		</script>
		<%
	}
	
	// Build the Launch Info 
	JSONObject launchInfoJSON = AnalyticsCaseEntityWUtil
									.getAnalyticsLaunchInfoAsJSON(
											context, objId, request, myAppsURL);
	
%>

	<title>Isight Results Analytics</title>
	<script type="text/javascript">
		//pre load the splash screen
		var splash = new Image();
		splash.src = "../webapps/SMASLMAdviseUI/assets/images/smaAdviseSplash.png"; 
	</script>
	<script	type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js" ></script>
	
	<!-- we use the trim function from core -->
	<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
	
	
	<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
	<script	src="../plugins/libs/jqueryui/1.10.3/js/jquery.ui.custom.min.js"	type="text/javascript"></script>
		
	<script type="text/javascript"	src="./smaAdviseLaunchHelper.js"></script>
	<script type="text/javascript"	src="./smaAdviseHelp.js"></script>
	
	<script>
		var a = null,
			b = false;
		window.onbeforeunload = function(event){
			console.warn('Running onbeforeunload code');
			var relaunchID = relaunchAnalyticsCase();
			// Relaunch the case again
			if (relaunchID.length > 0){
				if(b || whichBrowser().toLowerCase !== 'chrome'){
					removeGlobalLinks();
					return;
				}
				a = setTimeout(
					function () {
						b = true;
						event.stopPropagation();
						event.preventDefault();
						window.location.href = "./smaRunAdviseJob.jsp?runAs=true&setStation=true&objectId="+relaunchID;
					}, 500);
				return 'Relaunching Results Analytics Case';
			} else {
				// Return to landing
				removeGlobalLinks();
			}
		};
	   	window.onunload = function(event){
	   		console.warn('Running onunload code');
			if(a){
				clearTimeout(a);
			}
	   		removeGlobalLinksTryAgain();
	   	};
	</script>
	
	<link rel="stylesheet" type="text/css"	href="./styles/smaAdviseLaunchHelper.css">
	<link rel="stylesheet" type="text/css" href="./styles/smaAdviseHelp.css">
</head>

<body>
	<div class='embeddedWidget' style="display:none;position:absolute;margin:0px;padding:0px;right:0px;left:0px;top:0px;bottom:0px;">
	<!-- <iframe id="widgetframe" sandbox="allow-same-origin allow-forms allow-scripts allow-popups allow-top-navigation" style="position:absolute;margin:0px;padding:0px;right:0px;left:0px;top:0px;bottom:0px;width:100%;height:100%;border:0;"></iframe>-->
	<iframe id="widgetframe" style="position:absolute;margin:0px;padding:0px;right:0px;left:0px;top:0px;bottom:0px;width:100%;height:100%;border:0;"></iframe>
	<sp-encryption id="encryptor"></sp-encryption>
	
	<script type="text/javascript">
		var userSelectedStation = '',
			isStationSet = "<%=setStation%>",
			launchInfo = <%=launchInfoJSON%>;
			mcsUrl = "<%=myAppsURL%>";
			
		localStorage['RA_MCS_URL'] = mcsUrl;
		
		// Check if launchInfo is empty.
		// If yes go back to landing
		if (typeof launchInfo === 'undefined' || launchInfo === null){
			adviseGoBack('Error retrieving the Results Analytics launch information from the server.',
					'Error retrieving the Results Analytics launch information.', false);
		}
		
		// Only set the user selected affinity when executed from Configure And Run
		if(isStationSet && isStationSet === 'true'){
			if(window.sessionStorage && window.sessionStorage.setAffinityTo){
				userSelectedStation = window.sessionStorage.setAffinityTo;
			}	
		}
		
		var adviseLaunchInfo =
			new AdviseLaunchInfo(
				launchInfo['caseID'],
				launchInfo['ticketURL'],
				launchInfo['eedURL'],
				launchInfo['eedTicket'],
				launchInfo['encodedJobXML'],
				launchInfo['runInfo'],
				launchInfo['clientip'],
				launchInfo['mcsUrl'],
				"<%=runAsStr%>",
				launchInfo['proxyServer'],
				launchInfo['currentUser'],
				userSelectedStation);
		
		if (typeof $simjq === 'undefined') {
			$simjq = jQuery.noConflict();
		}
		
		// only when inside 3DD
		if(window.parent && window.parent.adviseLaunching){
			window.parent.adviseLaunching();
		}
		window.adviseClosing = function(){
			$simjq('.embeddedWidget').hide();
			//adviseGoBack(null, null, true);
			adviseGoBack(null);
			// only when inside 3DD
			if(window.parent && window.parent.adviseClosing){
				window.parent.adviseClosing();
			}
		};
		window.adviseLaunchDone = function(){
			$simjq('.sim-ui-advise-tutorial').hide();
			$simjq('.sim-ui-advise-splash-background').hide();
			// only when inside 3DD
			if(window.parent && window.parent.adviseLaunchDone){
				window.parent.adviseLaunchDone();
			}
		};
		
		if(<%=bFromExt%>) {
			document.location.href = "../common/emxNavigator.jsp?treeMenu=type_AnalyticsCase&objectId=<%=objId%>";
		}  else {
			jQuery(document).ready(function() {
				addHelpLinkToGlobalToolBar("", "../simulationcentral/smaAdviseHelp.jsp");
				$simjq('.embeddedWidget').hide();
				readyFunction(adviseLaunchInfo);
				saveRICase();
			});
		}
		var topBar = window.getTopWindow().document.querySelector("#topbar");
		if(topBar){
			topBar.style.width="100%";
            topBar.style.position="absolute";
		}
		
	</script>
	</div>
	
	<div class="sim-ui-advise-splash-background">
		<div class="sim-ui-advise-splash">
			<div class="sim-ui-advise-splash-progress-container">
				<div class="sim-ui-splash-progressbar"></div>
				<div class="sim-ui-launch-cancel">
				<span style="top: -3px;left: 4px;position: absolute;">x</span></div>
				<div class="sim-ui-splash-progressmessage"></div>
			</div>
			<div class="sim-ui-splash-tutorial-link" onclick="helpClickEvent('', '');" style="display:none">
				<a>Start Tutorial...</a>
			</div>
		</div>
	</div>
	
	<div class="sim-ui-errpop-veil sim-ui-errpop-noshow">
		<div class="sim-ui-errpop-dsfont sim-ui-errpop-base">
			<p class="sim-ui-errpop-header">Results Analytics Error</p>
			<div class="sim-ui-errpop-card" id="sim-ui-errpop-msgcard"></div>
			<div class="sim-ui-errpop-card sim-ui-errpop-noshow" id="sim-ui-errpop-tracecard"></div>
			<div id="sim-ui-errpop-buttons">
				<!--<button id="sim-ui-errpop-trace" class="sim-ui-errpop-noshow">Show Trace</button> -->
				<button id="sim-ui-errpop-ok" class="sim-ui-errpop-btn-primary sim-ui-errpop-noshow">Ok</button>
				<button id="sim-ui-errpop-close" class="sim-ui-errpop-btn-primary">Close</button>
			</div>
		</div>
	</div>
	
	<!-- div class="sim-ui-advise-job-log" style="position:absolute;top:0;left:0;width:100px;height:100px;z-index:10002;font-size:6px;">
	</div-->
	<div class="sim-ui-advise-alert-message">
		<div class="sim-ui-advise-alert-message-text"></div>
	</div>
</body>
</html>
