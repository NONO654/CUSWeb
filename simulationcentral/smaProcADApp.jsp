<%--
	Author(s): ER8
	Date: 02/03/2015
	Copyright: (c) Dassault Systemes, 2014, 2015
	Description: Home page for the Simulation Companion app.  Launched from Performance Study. 
--%>

                    
<%@include file = "../common/emxNavigatorInclude.inc"%>
 
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.COSWUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>

<%!
private final String MODE_3DXABQ = "3DXABQ";
private final String TEMPLATE_3DXABQ = "3DX Abaqus Process";

private final String TEMPLATE_RELATIONSHIP = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_relationship_SimulationTemplate);
private final StringList OBJECTSELECT_PHYSICALID = new StringList(SimulationConstants.PHYSICAL_ID);

/**
* Returns any special UI mode the user might be in, based on license
**/	
private String getUIMode(Context context) {
	String uiMode = "";
	
	// look for SXA license
	// TODO: implement this for real once we know the license name
/* 	boolean sxaLicense = Boolean.parseBoolean(SimulationContentUtil.checkLicense(context, SimulationConstants.???));
	if (sxaLicense)	{
		uiMode = MODE_3DXABQ;
	}
 */	
 
 	return uiMode;
}

/**
* Gets the template for a process
**/	
private DomainObject getProcessTemplate(Context context, String processID) {
	DomainObject templateObject = null;		 		 
 	 
	try {
		DomainObject processObject = DomainObject.newInstance(context, processID);			
		
	 	Map templateSelects = (Map)processObject.getRelatedObject(context, 
	 			TEMPLATE_RELATIONSHIP,		//Relationship type 
				true, 						//Relationship is 'To' the tremplate object
				OBJECTSELECT_PHYSICALID, 	//Object selects
				null						//Relationship selects
		);		
		if (null != templateSelects) {
			
			String templateID = (String)(templateSelects.get(SimulationConstants.PHYSICAL_ID));
			if ((null != templateID) && (templateID.length() > 0)) {
				templateObject = DomainObject.newInstance(context, templateID);	
			}
		}
	} 
	catch(FrameworkException e){
		templateObject = null;
	}
 	
	return templateObject;
}

/**
* Validates a process for a user based on UI mode
**/	
private boolean validateProcessForMode(Context context, String processID, String uiMode) {
	boolean isValidProcess = true;

	if (MODE_3DXABQ == uiMode) {
		isValidProcess = validate3DXABQProcess(context, processID);
	}
	
	return isValidProcess;
}

/**
* Validates a process for a user in the 3DX-Abaqus UI mode
**/	
private boolean validate3DXABQProcess(Context context, String processID) {
	// 3DX ABAQUS mode requires that process was created from particular template
	boolean isValidProcess = false;

 	try {
		// get process template
		DomainObject templateObj = getProcessTemplate(context, processID);
		if (null != templateObj) {
			// make sure template is the right one, by seeing if the name starts with the right string
			String templateName = templateObj.getInfo(context, "name");
			if ((null != templateName) && (templateName.startsWith(TEMPLATE_3DXABQ))) {
				isValidProcess = true;
			}
		}
	}
	catch (FrameworkException e) {
		isValidProcess = false;
	}
	
 	return isValidProcess;
}
%>

<%
// get user name
String mcsUser = context.getUser();

// get UI mode
String uiMode = getUIMode(context);

String processID = null;
String securityContext = null;
HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
processID = (String)requestMap.get("objectId");
securityContext = (String)requestMap.get("securityContext");

if(processID == null) {	
	throw new Exception("Simulation Companion cannot be launched without a Simulation Process"); 
}

// see if process is valid for the UI mode
boolean isValidProcessForMode = true;
if (uiMode.length() > 0) {
	isValidProcessForMode = validateProcessForMode(context, processID, uiMode);
}

// get license info
boolean scLicense = Boolean.parseBoolean(SimulationContentUtil.checkLicense(context, SimulationConstants.APP_SIMULATION_COMPANION));
boolean psLicense = Boolean.parseBoolean(SimulationContentUtil.checkLicense(context, SimulationConstants.APP_PERFORMANCE_STUDY));

// get EED URL
HashMap cosURLMap = COSWUtil.getCOSURL(context);
String eedBaseURL = (String)cosURLMap.get("url");
if (eedBaseURL.lastIndexOf('/') == (eedBaseURL.length() - 1)) {
	eedBaseURL = eedBaseURL.substring(0, eedBaseURL.length() - 1);
}
%>

<html>
	<head>
		<title>Simulation Companion</title>
		<meta name="viewport" content="width=device-width, initial-scale=1">
	
		<script src="../webapps/AmdLoader/AmdLoader.js"></script>
		<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>

	    <!-- Include the platform library for polyfill -->
        <script>
              var SMApolyfillPatch = {};
              SMApolyfillPatch.createObjectURL = window.URL.createObjectURL;
        </script>
	    <script src="../webapps/Polymer-1.1.4/webcomponents-lite.min.js"></script>
        <script>
              window.URL.createObjectURL = SMApolyfillPatch.createObjectURL;
        </script>
	
 		<link rel="stylesheet" href="../webapps/UIKIT/UIKIT.css"/>
        <link rel="stylesheet" href="../webapps/SMAProcADUI/ad-app/ad-app.css">
		
		<link rel="import" href="../webapps/SMAProcADUI/ad-app-main/ad-app-main.html">
		<link rel="import" href="../webapps/SMAProcSP/sp-variable/sp-variable.html">
	</head>
 
  	<polymer-body>
<% if (isValidProcessForMode && scLicense) { %>
		<sp-variable id="mcsUser" name="mcsUser" value="<%=mcsUser%>"></sp-variable>
		<sp-variable id="eedBaseURL" name="eedBaseURL" value="<%=eedBaseURL%>"></sp-variable>
		<sp-variable id="uiMode" name="uiMode" value="<%=uiMode%>"></sp-variable>

 		<ad-app-main scl="<%=scLicense%>" psl="<%=psLicense%>" procId="<%=processID%>" securityContext="<%=securityContext%>" jspLaunch></ad-app-main>
<% } else { %> 		
		<div id="licenseErrorMessage" class="alert-message alert-error">You do not have the appropriate license for this application.  Please contact your system administrator.</div>
<% } 
				StringBuilder contentURL1 = new StringBuilder(175);
	            /* contentURL1.append("../simulationcentral/smaHomeUtil.jsp?")
	            .append("objectAction=showInBrowseTab")
	            .append("&objectId=").append(newObjectId); */
	             String url = SimulationUtil.getProperty(context,
	                "smaSimulationCentral.Entry.SMAProc_ad-app");
	            contentURL1.append(url)
	            .append("?emxSuiteDirectory=simulationcentral&suiteKey=SimulationCentral")
	            .append("&objectId=").append(processID);
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
            
            var topFrm = getTopWindow();
            frame = emxUICore.findFrame(topFrm,"content");
            if (frame == null || frame == undefined)
                {
                topFrm = getTopWindow().getWindowOpener().getTopWindow();
                frame = emxUICore.findFrame(topFrm,"content");
                }
            topFrm.currentApp = "SIMCOMP_AP";
            var appsMenuList = new Array();
            appsMenuList[0] = 'SMAScenario_Definition_New';
            topFrm.changeProduct('SIMULIA', 'Simulation Companion', 'SIMCOMP_AP', appsMenuList, 'SIMCOMP_AP', null); 
            topFrm.showMyDesk();
            
            try
            {
               var hFra = findFrame(getTopWindow(),"content");
               hFra.location.href = "<%=contentURL1.toString()%>";
            }
            catch(error)
            {}
            </script>			
   	</polymer-body>
   	
</html>
