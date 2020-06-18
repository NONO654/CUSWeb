
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.common.util.DebugUtil"%>

<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>

<%@page import="matrix.db.JPO"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>

<%@page import="java.util.HashMap"%>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

	<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
</head>
<body>
	<%
	String strAction = request.getParameter("action");
	String strObjId = request.getParameter("objectId");
	String strAnalyticsSrcDestRelation = SimulationConstants.SYMBOLIC_relationship_AnalyticsData;
	
	if(strAction.equalsIgnoreCase("addDataSet") || strAction.equalsIgnoreCase("addFromDisk"))
	{
	%>
	<script>
		if(typeof $simjq=='undefined') {
			$simjq = jQuery.noConflict();
		}
	
		function callConnectObjects() {
			var parentObjectId = "<%=strObjId%>";
			var srcDestRelName = "<%=strAnalyticsSrcDestRelation%>";
			var tableRowIds = "";
			
			/** Get the selected domain objects ids.
			* The ids would have been posted to the hiddden 
			* addDataSetForm by the search util dialog boxes 
			*/
			var objectsToConnect = $simjq('#DataSet').val();
			
			if (objectsToConnect.length === 0 ){
				objectsToConnect = $simjq('#DataSetOID').val();
			}
			
			/*Ensure there is no spaces in the list of selected domain ids.
			*Must be ";" separated list"
			*/
			objectsToConnect = objectsToConnect.replace(/\s/g, "");
			
			/* Call this jsp with a different action to invoke connect */
			window.location= './smaAdviseDataSetUtils.jsp?action=connectAll&timestamp=' + (new Date).getTime() + 
							'&objectId=' + parentObjectId + '&childObjects=' + objectsToConnect.trim();
			return false;
		}
	</script>
	
	<div id="divPageBody">
		<form id="addDataSetForm">
			<table class="form">
				<tbody>
					<tr id="calc_DataSet">
						<td>
	<%
	
		if(strAction.equalsIgnoreCase("addDataSet"))
		{
	%>
							<input value="" id="DataSetDisplay" name="DataSetDisplay" type="hidden" fieldlabel="Data Sets" title="Data Sets" />
							<input value="" id="DataSet" name="DataSet" type="hidden" />
							<input value="" id="DataSetOID" name="DataSetOID" type="hidden" />
	<%
		}
		else{
	%>
							<input value="" id="DataSetDisplay" name="Files on DiskDisplay" type="hidden" fieldlabel="Data Sets" title="Data Sets" />
							<input value="" id="DataSet" name="Files on Disk" type="hidden" />
							<input value="" id="DataSetOID" name="Files on DiskOID" type="hidden" />
	<%
		}
	%>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	
	<script type="text/javascript">
		$simjq(document).ready(function() {
			
			//Shady workaround!
			// The search dialog is expecting an object by name emxCreateForm to exist in the document.	
			document.emxCreateForm = $simjq("#addDataSetForm")[0];
			
			/*Keeps checking if the search dialog has 
			returned the object ids that are to be connected.
			*/
			var t = setInterval(function(){
				var dataset = $simjq("#DataSet").val();
				if(dataset.length>16){
					clearInterval(t);
					callConnectObjects();
				}
			}, 100);
	<%
	
		if(strAction.equalsIgnoreCase("addDataSet"))
		{
	%>
			console.log('Adding Dataset ...');
			var url = '../common/emxFullSearch.jsp?selection=single&formName=emxCreateForm&field=TYPES=type_Simulation,type_DesignSight,type_SimulationJob,type_DOCUMENTS:isVersionObject!=True&fieldNameActual=DataSet&suiteKey=SimulationCentral&fieldNameOID=DataSetOID&showInitialResults=true&table=AEFGeneralSearchResults&fieldNameDisplay=DataSetDisplay&submitURL=../simulationcentral/smaFTSSearchPostUtilAction.jsp?slmmode=chooser';
	<%
		}
		else{
	%>
			console.log('Adding file from disk ...');
			var url = './smaAdviseCreateFromFiles.jsp?dummyArg=1&fieldNameActual=File%20on%20Disk&fieldNameDisplay=File%20on%20DiskDisplay&fieldNameOID=File%20on%20DiskOID&suiteKey=SimulationCentral&targetLocation=popup';
	<%
		}
	%>
			


			var w = null;
			try{
				// try using showChooser
				w = showChooser(url, '600', '600', 'true', '', 'DataSet');
			}catch(e){
				// try/catch implemented for IR-331685-3DEXPERIENCER2015x
				// problem happened in showChooser, try window.open
				w = getTopWindow().open(url,'DataSet','scrollbars=yes, width=600, height=600, top=0, left=0');
				if (w == null || typeof(w)=='undefined'){
					// if w is null or undefined, then the popup blocker is in use and needs to be disabled
					alert('Add Data Sets window was blocked. Please disable your pop-up blocker and try again.');
				}
			}
		});
	</script>
	
	<%
	}
	else if(strAction.equalsIgnoreCase("removeDataSet")) //unlink data set
	{
		/* Loop through the selected table row id fields and get the 
		relationship ids for all the objects marked for disconnect */
		
		/*emxTableRowId = <relnID>|<objectid>*/
		
		String[] linkedObjectIds = (String[])emxGetParameterValues(request, "emxTableRowId");
		StringList relIds = new StringList();
		
		for (int i = 0; i<linkedObjectIds.length; i++){
			String dataSetId = linkedObjectIds[i];
			int idx = dataSetId.indexOf("|");
			if (idx > 0){
				
				DebugUtil.dumpObject("Object to disconnect: ", dataSetId.substring(0, idx));
				
				relIds.add(dataSetId.substring(0, idx));
			}
		}
		
		StringList relationshipSelects = new StringList("from.id");
		relationshipSelects.add("to.id");
		MapList mlRelInfos = new MapList();
		
		String[] arrayIds  = new String[relIds.size()];
		arrayIds = (String[])relIds.toArray(arrayIds);

		mlRelInfos = DomainRelationship.getInfo(context, arrayIds, relationshipSelects);

		DomainRelationship.disconnect(context, arrayIds);
	%>
		<script>
			/* Reload only the connected data sets
			table in case details page */
			/* parent.location.reload(); */
			window.parent.location.href = window.parent.location.href;
			
			
		</script>
	<%		
	}
	
	else 
	{
		try {
			String caseId = request.getParameter("objectId");
			String objectsToConnect = request.getParameter("childObjects");
			%>
			<script>
				console.log("<%=objectsToConnect%>");
				console.log("<%=caseId%>");
			</script>
			<%
			
			if(caseId != null) {
				
				ContextUtil.startTransaction(context, true);
				
				/* Launch JPO to connect the new domain objects to our case */
	        	HashMap programMap = new HashMap();
	        	HashMap paramMap = new HashMap();
	        	paramMap.put("New OID", objectsToConnect); //ID of connector from job to activity
	        	paramMap.put("New Value", objectsToConnect); //Job ID advise case should be connected to
	        	paramMap.put("objectId", caseId);  //This is the case id.
	        	programMap.put("paramMap", paramMap);
	        	
	        	JPO.invoke(
	                    context,
	                    "jpo.simulation.AnalyticsCase",
	                    null,
	                    "CreateAndConnect",
	                    JPO.packArgs(programMap));
	        	
	        	ContextUtil.commitTransaction(context);			
			}			
		}
		catch (Exception ex){
			ContextUtil.abortTransaction(context);
			throw ex;
		}
		
		%>
		<script>
			/* Reload only the connected data sets
			table in case details page */
			window.parent.location.href = window.parent.location.href;
		</script>
	<%
	}
	%>
</body>
</html>


