<%-- (c) Dassault Systemes, 2013 --%>


<%@page import="com.matrixone.servlet.Framework"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>

<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="javascript" src="../plugins/libs/jquery/2.0.0/jquery.min.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>



<%
    
	String objectId = emxGetParameter(request, "emxTableRowId");
	if (objectId == null)
	{
	    objectId = emxGetParameter(request, "objectId");
	}

    String header =  SimulationUtil.getI18NString
							    (context,"smaSimulationCentral.Activity.Steps");
    
    String cssurl = Framework.getClientSideURL(response, 
                        "simulationcentral/styles/smaUIDefinition.css");
	
	
	
	
    StringBuffer buf = new StringBuffer();
     buf.append("../common/emxIndentedTable.jsp?")
	    .append("table=SMAStep_ActivityTable")
	    .append("&customize=false")
	    .append("&header=").append(header)
	    .append("&objectBased=false")
	    .append("&program=jpo.simulation.Steps:getColumnTitleSteps")
	    .append("&expandProgram=jpo.simulation.Steps:getColumnTitleSteps")
	    .append("&mode=view")
	    .append("&disableSorting=true")
	    .append("&multiColumnSort=false")
	    .append("&sortColumnName=none")
	    .append("&expandProgramMenu=SMAStep_Expand")
	    .append("&expandLevelFilter=false")
	    .append("&PrinterFriendly=false") 
	    .append("&Export=false")
	    .append("&rowGrouping=false")
	    .append("&autoFilter=false")
	    .append("&displayView=details")
	    .append("&categoryTreeName=type_SimulationActivity")
	    .append("&objectId=")
        .append(objectId);
     
     
     String tocURL = buf.toString();
     

%>

<html style="height:100%;">

    <head>
        <title></title>
        <link rel="stylesheet" type="text/css" href="<%=cssurl%>"/>
    </head>
    
    <body onload=initSteps()>
        <div id="StepsContainer">
          <div id="StepResize" class="smaHomeResize">
             <span id="StepResizeSpan" class="smaHomeResizeBtn" id="min" onclick="resizeStep()" title="Minimize Step Explorer">
                 <img id="StepResizeImage" src="../simulationcentral/images/smaIconMinimize.gif">
             </span>
          </div> 
          <div id="stepsTree">
              <iframe id="StepsTable" name="StepsTable" marginwidth="0"  marginheight="0"  src="<%=tocURL%>" style="width:100%; height:100%;">   
              </iframe>
          </div>
          <div id="stepsDetails">
              <iframe id="StepsContent" name="StepsContent"  marginwidth="0"  marginheight="0"  style="width:100%; height:100%;background:#ededed;">
              </iframe>
          </div>
        </div>
     </body>
     
 </html>
