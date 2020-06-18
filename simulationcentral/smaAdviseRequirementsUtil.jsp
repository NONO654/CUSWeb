<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="matrix.db.Context"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.common.util.DebugUtil"%>

<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>

<%@page import="matrix.db.JPO"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.common.Search"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "java.util.HashMap"%>


<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.AnalyticsCaseEntityWUtil"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

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
    String parentRowId = "";
	String caseId = "";
    StringBuffer data = new StringBuffer(1);
    String timeStamp = emxGetParameter(request, "timeStamp");

    if (timeStamp!=null)
    {
	    HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
	    parentRowId = (requestMap.get("emxTableRowId") != null) ? (String)requestMap.get("emxTableRowId") : "";
	    caseId = (requestMap.get("objectId") != null) ? (String)requestMap.get("objectId") : "";
    }
    else
    {
    	parentRowId = (request.getParameter("emxTableRowId") != null) ? request.getParameter("emxTableRowId") : "";
    	caseId = (request.getParameter("objectId") != null) ? request.getParameter("objectId") : "";
    }

    //Get the list of child entities to add
    String[] childRowIds = request.getParameterValues("emxTableRowId");
    String selectedReqIds = "";

    HashMap paramMap = new HashMap();
    List existingReqList = null;
    String reqListString = "";
    
	if (! caseId.isEmpty()){
		// Get the list of attached requirements only when there is a case id.
		paramMap.put("objectId", caseId);
		existingReqList = AnalyticsCaseEntityWUtil.getRequirementsListForAnalytics(context, paramMap);
		
		boolean existingReqs = false;
		String[] arrSplitRowId = null;
		
	    if (existingReqList != null && !existingReqList.isEmpty()){
	    	existingReqs = true;
	    }
	    
	    if (childRowIds.length > 0) {
	    	//Make a ";" separated list with no spaces in between
	    	for (int i=0; i<childRowIds.length; i++) {
	    		
	    		String childString = childRowIds[i];
	    		
	    		//Stop connecting duplicate requirements
	    		if(existingReqs == true) {
	    			for (int a=0; a<existingReqList.size(); a++){
	    				if (((String) existingReqList.get(a)).indexOf(childString) > -1){
	    					continue;
	    				}
	    			}
	    		}
	    		
	    		if (childString.indexOf('|') > -1) {
					arrSplitRowId = childString.split("\\|");
					if(! arrSplitRowId[1].contains(caseId)){
						selectedReqIds += arrSplitRowId[1] + ";" ;
					}
				}
	    	}
	    	
	    	if (selectedReqIds.length() > 0){
	    		selectedReqIds = selectedReqIds.substring(0, selectedReqIds.length() - 1);
	    		selectedReqIds = selectedReqIds.replaceAll("[|]","");
	    		selectedReqIds = selectedReqIds.replaceAll("\\s","");
	    	}
	    	
	    	try {
	    		if (selectedReqIds.length() > 0){
	    			ContextUtil.startTransaction(context, true);

    				// Replace the object id delimiter ';' with a '|'
		    		// JPO expects a '|'
		    		selectedReqIds = selectedReqIds.replaceAll(";", "|");
    		

	            	//Launch JPO to connect the new requirement objects to our case
	            	paramMap.put("New OID", selectedReqIds.trim()); //List of requirement ids
	            	paramMap.put("New Value", selectedReqIds.trim()); //List of requirement ids
	            	paramMap.put("Relationship Symbolic Name", SimulationConstants.SYMBOLIC_relationship_AnalyticsRequirement);

	            	HashMap programMap = new HashMap();
	            	programMap.put("paramMap", paramMap);

	            	JPO.invoke(
	                        context,
	                        "jpo.simulation.AnalyticsCase",
	                        null,
	                        "CreateAndConnect",
	                        JPO.packArgs(programMap));
	            	ContextUtil.commitTransaction(context);
	              	DebugUtil.dumpObject("Requirements Connected: ", selectedReqIds);
	              	
	              	existingReqList = AnalyticsCaseEntityWUtil.getRequirementsListForAnalytics(context, paramMap);
	    		}
	    		
	    		if(existingReqList != null && ! existingReqList.isEmpty()){
	    			for(int i=0;i<existingReqList.size();i++){
	    				reqListString += existingReqList.get(i)+";";
	    			}
	    		}
	    		
	    	} catch (Exception ex){
	    		DebugUtil.dumpObject(ex);
	    		throw (ex);
	       	} finally {
	    		DebugUtil.dumpObject("Completed connecting and importing requirements");
	    	}
	    }
	} else {
		// No Analytics Case. Just pass the selected requirements to the callback...
		for(int i=0; i<childRowIds.length; i++){
			reqListString += childRowIds[i].split("\\|")[1] + ";";
		}
		
	}
	
    %>
    <script>
    	//d3b change for IR-328248-3DEXPERIENCER2015x (from opener=window.opener)
    	//contentWindow for chrome, ff. window for ie10
    	//var opener = getTopWindow().getWindowOpener().frames['content'].frames['widgetframe'].contentWindow || getTopWindow().getWindowOpener().frames['content'].frames['widgetframe'].window;
    	// FIX for IR: IR-467591-3DEXPERIENCER2017x
    	var opener = getTopWindow().frames['content'].frames['widgetframe'].contentWindow || getTopWindow().frames['content'].frames['widgetframe'].window;
    	if (opener){
    		if(opener.proxy){
    			opener.proxy.fireNamedCallback('setRequirementsFromPLM', '<%=reqListString%>');
    		}
    		else{
    			throw 'proxy not found';
    		}
    		getTopWindow().closeWindow();
    	}
    </script>

</body>
</html>
