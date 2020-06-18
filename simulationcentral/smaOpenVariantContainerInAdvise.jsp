<%-- smaOpenVariantContainerInAdvise.jsp
This jsp takes a Simulation Process object/physical Id
as input and creates an Analytics case and connects the
process object to the case as Analytics Data.
--%>

<%-- Common Includes --%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import="com.matrixone.apps.common.util.ComponentsUtil" %>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.AnalyticsCaseEntityWUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONArray"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONObject"%>
<%@page import="com.dassault_systemes.smaslm.common.util.DebugUtil"%>


<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script type="text/javascript"	src="./smaAdviseLaunchHelper.js"></script>
	</head>
	<body>
		<%
			matrix.db.Context context2 = (matrix.db.Context) request
					.getAttribute("context");
			if (context2 != null)
				context = context2;
			
			Boolean hasLicense = false;
			
			//do license check
			try{
				ComponentsUtil.checkLicenseReserved(context, "RIW");
				hasLicense = true;
			}
			catch(Exception e){
				throw new MatrixException("No available license for Results Analytics.");
			}

			String action = emxGetParameter(request, "action");
			String suiteDir = request.getParameter("SUITE_DIR");
			if(suiteDir == null) {
				suiteDir = "../simulationcentral";
			}
			String commonDir = request.getParameter("COMMON_DIR");
			if(commonDir==null) {
				commonDir = "../common";
			}
			String RA_LANDING_PAGE = commonDir + "/emxNavigator.jsp?appName=SIMREII_AP";
			
			if(action.equalsIgnoreCase("READSESSION")){
				%>
				<!--  Read the session and extract object id -->
				<script>
					var sessionData = sessionStorage.getItem('ADVISE_DATA'),
						launchRALanding = true;
					
					// purge session storage
					sessionStorage.removeItem('ADVISE_DATA')
					
					if (typeof sessionData !== 'undefined' &&
							sessionData !== null){
						
						sessionData = JSON.parse(sessionData);
						var oId = sessionData.data_id ? sessionData.data_id : '',
							stamp = sessionData.stamp ? sessionData.stamp : '';

						if(oId.length > 0 &&
								Date.now() - parseFloat(stamp) < 600000){
							launchRALanding = false;
							window.location.href = '<%=suiteDir%>' + '/smaOpenVariantContainerInAdvise.jsp?objectId=' + 
													oId + '&action=connectAndLaunch';
						}
					}
					if(launchRALanding)
						window.location.href = "<%=RA_LANDING_PAGE%>";
				</script>
				<%
			} else if(action.equalsIgnoreCase("CONNECTANDLAUNCH")){
				
				// May be plm object id or physical id
				String objId = emxGetParameter(request, "objectId");
				String emxTableRowId = emxGetParameter(request, "emxTableRowId");
				String[] sRowIds = null;
				
				try {
					if(objId == null || objId.equalsIgnoreCase("")){
						if(emxTableRowId!=null && emxTableRowId.length()>4) {
							sRowIds = emxTableRowId.split("(\\Q" + "|" + "\\E)+");
							// We open only one case, so choose the first item from the selected list
							objId = sRowIds[1];
						}
					}
					if(objId == null || objId.equalsIgnoreCase("")){
						throw new Exception("No object id was found.");
					}
					
					// Get the info about the supplied object
					JSONArray processArray = new JSONArray(AnalyticsCaseEntityWUtil.getObjectInfo(context, objId+";"));
					JSONObject processInfo = (JSONObject) processArray.get(0);
					
					if(((String)processInfo.get("typename"))
							.equalsIgnoreCase(
									SimulationUtil.getSchemaProperty(
											SimulationConstants.SYMBOLIC_type_Simulation))){
						
						// Check for any existing connected cases
						String caseId = AnalyticsCaseEntityWUtil.getConnectedCase(context, objId);
						
						// Create a new Analytics case
						if(caseId == null || caseId.isEmpty()) {
							
							caseId = AnalyticsCaseEntityWUtil
									.createAnalyticsCaseObject(
										context,
										(String) processInfo.get("title"),
										"",
										"",
										false,
										null,
										null);
							
							// Connect the variant container to the new case.
							AnalyticsCaseEntityWUtil
								.connectVariantContainerToAnalyticsCase(
									context, caseId, objId, true);
						}
							
						
						if(caseId != null && !caseId.isEmpty()){
							String runURL = suiteDir+"/smaRunAdviseJob.jsp?"+"emxTableRowId=|"+caseId+"||0,0";
							%>
							
							<!--  Initiate RA launch -->
							<script>
								<%-- var raUrl =  "<%=commonDir%>" + "/emxNavigator.jsp?appName=SIMREII_AP&ContentPage=" + encodeURIComponent("<%=runURL%>"); --%>
								initiateLoad('<%=runURL%>', "0");
							</script>
							
							<%
						}
					}
				} catch (Exception e) {
					DebugUtil.dumpObject("Open Variant Error", e.getMessage());
					throw new MatrixException("Error creating a Results Analytics case for this process object.");
				}
			} else {
				%>
				<script>
					window.location.href = "<%=RA_LANDING_PAGE%>";
				</script>
				<%
				
			}
		%>
	</body>
</html>

