<%--
  Display rules pages in diagramming
  Author: qw9
--%>

<html>

<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.db.Context"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%--
  load scripts here :
--%>

<head>
	<script>
		//for fixing session expire issue due JSP load inside the webUX dialog
		function deleteAllCookies() {
			var cookies = document.cookie.split(";");
			for (var i = 0; i < cookies.length; i++) {
				var cookie = cookies[i];
				var eqPos = cookie.indexOf("=");
				var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
				document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT";
			}
		}
		sessionStorage.clear();
		localStorage.clear();
		deleteAllCookies();
		var topMostEnoviaWindow = true;
	</script>

	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="Javascript" src="../common/scripts/emxUICoreMenu.js"></script>
	<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
	<script language="Javascript" src="../common/scripts/emxUISlideIn.js"></script>

	<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>
	<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
	<link rel="stylesheet" href="../common/styles/emxUIDefault.css" />

</head>

<body>

	<%
String protocol = "";
String mcsURL = "";
try {
	protocol = emxGetParameter(request, "protocol");
	//For fixing JSP issues on 3DDashboard
	//IR-546034,IR-642238,IR-644490,IR-641094,IR-637542,IR-637025
	if(null != request.getServerName()) {
		mcsURL = protocol+"//"+(request.getServerName());
	}
	if(null == session.getAttribute("ematrix.mcsurl") && !"".equals(mcsURL)) {
		session.setAttribute("ematrix.mcsurl", mcsURL);	
	}	
	if(null == session.getAttribute("emxCommonAppInitialized")) {
		session.setAttribute("emxCommonAppInitialized", true);	
	}
}catch(Exception ex){
	ex.printStackTrace();
}  	        

    String objectAction      = emxGetParameter(request, "objectAction");
    String objectId          = emxGetParameter(request, "objectId");
    String stepId         	 = emxGetParameter(request, "stepId");
    String adapterName 		 = emxGetParameter(request, "adapterName");
    String isActivity 		 = emxGetParameter(request, "isActivity");
    String parentId          = emxGetParameter(request, "parentOID");
    String connected         = emxGetParameter(request, "connected");
    String fromAct           = emxGetParameter(request, "fromAct");
    String toAct             = emxGetParameter(request, "toAct");
    String url = "", frameName="";

    if(objectAction.equals("showDownloadRules")) {
    	url = "../common/emxTable.jsp?targetLocation=popup"
    				+"&table=SMAExportRule_Results&objectBased=false&header=smaSimulationCentral.ExportRule.ExportRules"
    				+"&suiteKey=SimulationCentral&Export=false&PrinterFriendly=false&showClipboard=false&objectCompare=false"
    				+"&xmlAttribute=attribute_Definition&disableSorting=true&toolbar=SMAExportRule_ListToolbar&selection=multiple"
    				+"&HelpMarker=SMAImportExport_TabExportRule&hideLaunch=true&pagination=0"
    				+"&program=jpo.simulation.XmlTable:getDataProcessorStepTable&suiteKey=SimulationCentral";
    	
    	url += "&objectId="+objectId;
    	url += "&stepId="+stepId;
    	url += "&adapterName="+adapterName;
    	
    	String objStr = adapterName+"~"+stepId+"~"+ objectId +"~Download"; 
		url += "&objectId=0~"+objStr+"&parentOID=0~"+objStr;
		frameName = "SMAImportExport_TabExportRule";
    }
	
	else if(objectAction.equals("showUploadRules")) {
    	url = "../common/emxTable.jsp?program=jpo.simulation.XmlTable:getDataProcessorStepTable&table=SMAImportRule_Results&objectBased=false"
			+"&header=smaSimulationCentral.ImportRule.ImportRules&Export=false&PrinterFriendly=false&showClipboard=false&objectCompare=false&xmlAttribute=attribute_Definition"
			+"&disableSorting=true&toolbar=SMAImportRule_ListToolbar&selection=multiple&HelpMarker=SMAImportExport_TabImportRule&hideLaunch=true&pagination=0"
			+"&suiteKey=SimulationCentral";
    	
    	url += "&objectId="+objectId;
    	url += "&stepId="+stepId;
    	url += "&adapterName="+adapterName;
    	
    	String objStr = adapterName+"~"+stepId+"~" + objectId +"~Upload";
		url += "&objectId=0~"+objStr+"&parentOID=0~"+objStr;
		frameName = "SMAImportExport_TabImportRule";
    }
    
	else if(objectAction.equals("showDeleteRules")) {
    	url = "../common/emxTable.jsp?program=jpo.simulation.XmlTable:getDataProcessorStepTable&table=SMADeleteRule_Results"
    			+"&objectBased=false&Export=false&PrinterFriendly=false&showClipboard=false&objectCompare=false"
    			+"&xmlAttribute=attribute_Definition&disableSorting=true&toolbar=SMADeleteRule_ListToolbar&selection=multiple"
    			+"&HelpMarker=SMAImportExport_TabDeleteRule&hideLaunch=true&pagination=0&suiteKey=SimulationCentral&fromDiagramming=true";
    	
    	url += "&objectId="+objectId;
    	url += "&stepId="+stepId;
    	url += "&adapterName="+adapterName;
    	
    	String objStr = adapterName+"~"+stepId+"~" + objectId + "~Upload";
		url += "&objectId=0~"+objStr+"&parentOID=0~"+objStr;
		frameName = "SMAImportExport_TabDeleteRule";
    }
    
    
	else if(objectAction.equals("showContent")) {
		
		url = "../common/emxIndentedTable.jsp?customize=true&showRMB=true"
    			+"&header=Common.Content.PageHeading&expandProgramMenu=SMAContent_Filter&multiColumnSort=false&sortColumnName=Title"
    			+"&sortDirection=ascending&selection=multiple&Export=false&PrinterFriendly=false"
    			+"&massPromoteDemote=false&triggerValidation=false&showClipboard=false"
    			+"&targetLocation=popup&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource"
    			+"&SuiteDirectory=simulationcentral&fromPCWWidget=true";
		
		if("true".equalsIgnoreCase(isActivity)){	
	    	url += "&table=SMAActivityContent_Results&HelpMarker=SMAActivity_NavTreeContent&toolbar=SMA_ActivityContentToolbar";
	    	
		}else{
			url += "&table=SMAContent_Results&HelpMarker=SMASimulation_NavTreeContent&toolbar=SMA_ProcessContentToolbar";
		}
    	
    	url += "&objectId="+objectId;
    	
		frameName = "detailsDisplay";
    }
    else if(objectAction.equals("showAttributeGrpsPage")) {
		url = "../common/emxTable.jsp?table=SMACommon_AttributeGroups&objectBased=false&header=Common.AttributeGroup.PageHeading&"
					+"toolbar=SMACommon_NavTreeAttributeGroupsToolbar&selection=multiple&program=jpo.simulation.AttributeGroup%3AgetAttributeGroupsTable"
					+"&Export=false&HelpMarker=SMACommon_NavTreeAttributeGroups&emxSuiteDirectory=simulationcentral&otherTollbarParams=&suiteKey=SimulationCentral"
					+"&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null";

		url += "&objectId="+objectId;

		frameName = "detailsDisplay";
  }

    else if(objectAction.equals("showInstantiationPage")) {
        url = "../simulationcentral/smaFTSInstantiateTemplate.jsp?mode=InstantiateInActivity&fromWidget=true";
        url += "&parentOID="+parentId;
        url += "&objectId="+objectId;
        url += "&connected="+connected;
        url += "&fromAct="+fromAct;
        url += "&toAct="+toAct;
        frameName = "detailsDisplay";
    }
	else if(objectAction.equals("showExecutionOptions")) {
		
		if(isActivity.equals("true")) {
			url = "../common/emxForm.jsp?form=SMAActivityExecutionOption&PrinterFriendly=false&selection=multiple&Export=false"
	    			+"&HelpMarker=SMACompose_ActivityExecutionOption&mode=view&categoryTreeName=type_SimulationActivity&isSelfTargeted=true"
	    			+"&toolbar=SMAExecutionOption_ListToolbar&formHeader=smaSimulationCentral.HomeExecutionOption"
	    			+"&emxSuiteDirectory=simulationcentral&otherTollbarParams=&suiteKey=SimulationCentral"
	    			+"&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral";	
		}
		else {
			url ="../common/emxForm.jsp?form=SMAProcessExecutionOption&PrinterFriendly=false&selection=multiple&Export=false"
					+"&HelpMarker=SMACompose_ProcessExecutionOption&mode=view&categoryTreeName=type_Simulation&isSelfTargeted=true"
					+"&toolbar=SMAExecutionOption_ProcessListToolbar&formHeader=smaSimulationCentral.HomeExecutionOption"
					+"&emxSuiteDirectory=simulationcentral&otherTollbarParams=&suiteKey=SimulationCentral"
					+"&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null";
		}
    	
    	url += "&objectId="+objectId;
		frameName = "detailsDisplay";
    }
    
	else if(objectAction.equals("showParameters")) {
		
		url ="../common/emxIndentedTable.jsp?table=SMASimulation_Parameters&header=Common.Parameters.PageHeading&selection=multiple"
				+"&HelpMarker=SMASimulation_NavTreeParameters&program=jpo.simulation.XmlTable%3AgetTableForParameter&Export=false"
				+"&PrinterFriendly=false&objectBased=false&xmlAttribute=attribute_Parameters&xmlTableTag=ParameterList&"
				+"toolbar=SMASimulation_ParametersToolbar&disableSorting=true&sortColumnName=None&multiColumnSort=false&showRMB=false"
				+"&showClipboard=false&emxSuiteDirectory=simulationcentral&otherTollbarParams=&suiteKey=SimulationCentral"
				+"&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null";
		    	
    	url += "&objectId="+objectId;
    	
    	if(isActivity.equals("true")) {
    		// append parent id

    		
    		url += "&parentOID="+parentId;
    	}
    	
		frameName = "detailsDisplay";
    }
    //Show impact graph
    else if(objectAction.equals("showImpactGraph")) {
		 url =  "../simulationcentral/smaImpactGraph.jsp?pageHeader=ImpactGraph.PageHeading&"
                  +"toolbar=SMAHome_ImpactGraphToolbar&export=false&PrinterFriendly=false&HelpMarker=SMASimulation_NavTreeImpactGraph&"
			   +"StringResourceFileId=smaSimulationCentralStringResource&suiteKey=SimulationCentral&categoryTreeName=type_Simulation&emxSuiteDirectory=simulationcentral&"
			   +"otherTollbarParams=&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null";

		 url += "&objectId="+objectId;
		 frameName = "detailsDisplay";
	  }
	  //show Image
	  else if(objectAction.equals("showImagePage")) {
		url = "../components/emxImageManager.jsp?isPopup=true&toolbar=APPImageManagerToolBar&header=Common.Images.PageHeading&HelpMarker=SMACommon_NavTreeImageManager&"
				+"emxSuiteDirectory=simulationcentral&isStructure=true&otherTollbarParams=isStructure&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&"
				+"SuiteDirectory=simulationcentral";

		url += "&objectId="+objectId;
		frameName = "imageDisplay";
		}
		//show connectors
		else if(objectAction.equals("showConnector")) {
			url = "../simulationcentral/smaHomeUtil.jsp?objectAction=ConnectorList&newUI=true&HelpMarker=SMAConnectorList&"
			 + "suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null";
			frameName = "content";
		}
		// show attribute groups
		else if(objectAction.equals("showAdminAttributeGroups")) {
			url = "../simulationcentral/smaHomeUtil.jsp?objectAction=AttributeGroupList&newUI=true&HelpMarker=SMAAttributeGroupList&"
			+ "suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null";
			frameName = "content";
		}
		// show attribute groups
		else if(objectAction.equals("showAttributes")) {
			url = "../simulationcentral/smaHomeUtil.jsp?objectAction=AttributeList&newUI=true&HelpMarker=AttributeList&"
			+ "suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&widgetId=null";
			frameName = "content";
		}
    
%>
	<iframe id="smaDiagrammingFrame" name="<%=frameName%>" src="<%=url%>" width="100%" height="100%" frameborder="0"
		border="0"></iframe>
	<iframe class="hidden-frame" name="hiddenFrame" src="../common/emxNavigator.jsp"></iframe>
	<script>
		var cf = document.getElementById("smaDiagrammingFrame");
		//for fixing session expire issue due JSP load inside the webUX dialog
		cf.onunload = function (event) {
			deleteAllCookies();
			sessionStorage.clear();
			localStorage.clear();
		};
	</script>
</body>
</html>
