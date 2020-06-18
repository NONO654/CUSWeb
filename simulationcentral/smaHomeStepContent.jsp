<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>
<script language="javascript" src="../plugins/libs/jquery/2.0.0/jquery.min.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<%

String objectId = emxGetParameter(request, "objectId");
String title = emxGetParameter(request, "Title");
String type = emxGetParameter(request, "type");
String eName = emxGetParameter(request, "eName");
String row = emxGetParameter(request, "row");
if(eName==null)
    eName= "";

StringBuffer contentURL = null;

		if(title.contains(SimulationConstants.XML_ACTIVITY_IMPORT) ||
		    eName.contains("OSCommand"))
		{
		    contentURL = new StringBuffer(); 
            contentURL.append("../common/emxPortal.jsp?")
                       .append("portal=SMAOSCommand_DetailsView")
                       .append("&objectId=").append(objectId);
		}
		if(title.contains(SimulationConstants.XML_ACTIVITY_IMPORT) ||
		    eName.contains("Upload"))
		{
		      contentURL = new StringBuffer(); 
		      contentURL.append("../common/emxTable.jsp?")
		                 .append("mode=view")
		                 .append("&table=SMAImportRule_Results")
		                 .append("&objectBased=false")
		                 .append("&header=smaSimulationCentral.ImportRule.ImportRules")
		                 .append("&Export=false")
		                 .append("&PrinterFriendly=false")
		                 .append("&showClipboard=false")
		                 .append("&objectCompare=false")
		                 .append("&xmlAttribute=attribute_Definition")		                 
		                 .append("&disableSorting=true")
		                 .append("&selection=multiple")
		                 .append("&HelpMarker=SMAImportExport_TabImportRule")
		                 .append("&hideLaunch=true")
		                 .append("&suiteKey=SimulationCentral")
		                 .append("&pagination=0")
		                 .append("&toolbar=SMAImportRule_ListToolbar")
		                 .append("&objectId=").append(objectId);
		                 
                if(eName.contains("Upload"))
                {
                    contentURL.
                    append("&program=jpo.simulation.XmlTable:getDataProcessorStepTable")
                    .append("&xmlTableTag=").append(title);
                }
                else
                {
                    contentURL.
                    append("&program=jpo.simulation.XmlTable:getTable")
                    .append("&xmlTableTag=ImportRules");
                }
		                      
		}
		
		else if(title.contains(SimulationConstants.XML_ACTIVITY_DELETE)||
            eName.contains("Delete"))
		{
		    contentURL = new StringBuffer(); 
		    contentURL.append("../common/emxTable.jsp?mode=view")
						.append("&table=SMADeleteRule_Results")
						.append("&objectBased=false")
						.append("&suiteKey=SimulationCentral")
						.append("&header=smaSimulationCentral.DeleteRule.DeleteRules")
						.append("&objectCompare=false")
						.append("&xmlAttribute=attribute_Definition")
						.append("&disableSorting=true")
						.append("&toolbar=SMADeleteRule_ListToolbar")
						.append("&selection=multiple")
						.append("&HelpMarker=SMAImportExport_TabDeleteRule")
						.append("&hideLaunch=true")
						.append("&amp;pagination=0")
						.append("&objectId=").append(objectId);
		    
		    if(eName.contains("Delete"))
            {
                contentURL.
                append("&program=jpo.simulation.XmlTable:getDataProcessorStepTable")
                .append("&xmlTableTag=").append(title);
            }
            else
            {
                contentURL.
                append("&program=jpo.simulation.XmlTable:getTable")
                .append("&xmlTableTag=DeleteRules");
            }


		}
		else if(title.contains(SimulationConstants.XML_ACTIVITY_EXPORT)||
            eName.contains("Download"))
		{
		    contentURL = new StringBuffer(); 
		    contentURL.append("../common/emxTable.jsp?")
		                .append("&table=SMAExportRule_Results")
						.append("&objectBased=false")
						.append("&header=smaSimulationCentral.ExportRule.ExportRules")
						.append("&suiteKey=SimulationCentral")
						.append("&Export=false")
						.append("&PrinterFriendly=false")
						.append("&showClipboard=false")
						.append("&objectCompare=false")
						.append("&xmlAttribute=attribute_Definition")
						.append("&disableSorting=true")
						.append("&toolbar=SMAExportRule_ListToolbar")
						.append("&selection=multiple")
						.append("&HelpMarker=SMAImportExport_TabExportRule")
						.append("&hideLaunch=true")
						.append("&pagination=0")
						.append("&objectId=")
		                .append(objectId);
		    
		    
		    if(eName.contains("Download"))
            {
                contentURL.
                append("&program=jpo.simulation.XmlTable:getDataProcessorStepTable")
                .append("&xmlTableTag=").append(title)
                .append("&stepType=").append(type)
                .append("&adapterName=").append(eName);
            }
            else
            {
                contentURL.
                append("&program=jpo.simulation.XmlTable:getTable")
                .append("&xmlTableTag=ExportRules");
            }
		}
		else if(title.contains(SimulationConstants.XML_JOB_PARAMETERS))
		{
		    contentURL = new StringBuffer(); 
		    contentURL.append("../common/emxTable.jsp?table=SMASimulation_Parameters")
					    .append("&header=Common.Parameters.PageHeading")
						.append("&selection=multiple")
						.append("&HelpMarker=SMASimulation_NavTreeParameters")
						.append("&suiteKey=SimulationCentral")
						.append("&program=jpo.simulation.XmlTable:getTable")
						.append("&Export=false")
						.append("&PrinterFriendly=false")
						.append("&objectBased=false")
						.append("&xmlAttribute=attribute_Parameters")
						.append("&xmlTableTag=ParameterList")
						.append("&toolbar=SMASimulation_ParametersToolbar")
						.append("&postProcessJPO=jpo.simulation.SimulationParameters:editParameters")
						.append("&mode=view")
						.append("&disableSorting=true")
						.append("&multiColumnSort=false")
						.append("&objectId=")
		                .append(objectId);
		}
		else if(title.contains(SimulationConstants.XML_ACTIVITY_EXECUTE))
		{
		    contentURL = new StringBuffer(); 
		    contentURL.append("../common/emxTable.jsp?table=SMAConnectorOption_ResultsValues")
		                .append("&program=jpo.simulation.ConnectorOption:getConnUseTable")
						.append("&objectBased=false")
						.append("&postProcessJPO=jpo.simulation.ConnectorOption:postConnUseTable")
						.append("&suiteKey=SimulationCentral")
						.append("&header=Activity.ConnectorOptions.PageHeading")
						.append("&toolbar=SMAConnectorOptionValues_ListToolbar")
						.append("&selection=multiple")
						.append("&HelpMarker=SMAActivity_NavTreeOptions")
						.append("&objectId=")
						.append(objectId);
		}

if(contentURL!=null)
{
    session.setAttribute("selectedStep", title);
    %>
    <script language="javascript">
    highLightStepRow("<%=row%>");
    window.location.href = "<%=contentURL.toString()%>";
    </script>
    <%
}
else if(row!=null)
{
    %>
    <script language="javascript">
    highLightStepRow("<%=row%>");
    </script>
    <%
}
%>
