<html>

<%@page import="com.dassault_systemes.smaslm.common.util.XMLUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page
	import="com.dassault_systemes.smaslm.common.util.StringValidator"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.jdom.Document"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringResource"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="java.util.regex.Pattern"%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../simulationcentral/smaGeneral.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
String fileContent = "";
String fileName = "";
String objectAction = emxGetParameter(request, "objectAction");
String objId = emxGetParameter(request, "objectId");
if(objId == null){
    objId = emxGetParameter(request, "emxTableRowId");            
}

if ("parameterExport".equals(objectAction))
{
    try
    {
        fileName = "SimulationParameters.xml";
        String sRowIds[] = 
            emxGetParameterValues(request, "emxTableRowId");
        int numRows = (sRowIds != null) ?  sRowIds.length: 0;
        StringBuilder rowStr = new StringBuilder();
        
        // create row id string as comma separated list
        for (int ii=0; ii<numRows; ii++ )
        {
            if (rowStr.length() > 0)
                rowStr = rowStr.append(",");
            
            String ids[] = null;
            final String SPLIT_CHAR = "\\";
            if (sRowIds[ii].contains(
                SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
            {
                ids = sRowIds[ii].split(
                    SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
            } 
            else if (sRowIds[ii].contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
            {
                ids = sRowIds[ii].split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
            }
            
            if (ids == null)
                rowStr = rowStr.append(sRowIds[ii]);
            else
                rowStr = rowStr.append(ids[0]);
        }
        String paramIds = rowStr.toString();
        paramIds = paramIds.replaceAll("\\|", "");
        String [] methodargs = {objId,paramIds};

        fileContent = (String)JPO.invoke(
            context, "jpo.simulation.SimulationParameters", null,
            "getParameterXml", methodargs, String.class);
    }
    catch (Exception ex)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
    }
}
else if ("attributeExport".equals(objectAction))
{
    try
    {
        fileName = "SimulationAttributes.xml";
        String [] methodargs = {objId};

        fileContent = (String)JPO.invoke(
            context, "jpo.simulation.AttributeGroup", null,
            "getAttributeXml", methodargs, String.class);
    }
    catch (Exception ex)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
    }
}
else if ("hostExport".equals(objectAction))
{
    try
    {
        fileName = "SimulationHosts.xml";
        String[] methodargs = new String[] { objId,"true" };
        HashMap<String, String> stationDataMap = null;
        // get EED data and station info.  
        // this includes eed url and a ticket and the station xml
        stationDataMap = (HashMap<String, String>) JPO
            .invoke(context, "jpo.simulation.SimulationHostGroup",
            null, "getStationUpdateData", 
            methodargs, HashMap.class);

        String errorStr = stationDataMap.get("exception");
        if (errorStr != null && errorStr.length() > 0)
        {
                emxNavErrorObject.addMessage(errorStr);             
        }
        else
        {

            fileContent = stationDataMap.get("stationXml");
            
            // remove escapes since writing to file and not pushing to COS
            fileContent = fileContent.replace("\\\\", "\\");

            // get xml formatted for writing to file
            com.matrixone.jdom.Document doc = XMLUtil.parseXML(fileContent);
            fileContent = XMLUtil.toIndentedXML(doc, "  ");
        }
    } catch (Exception ex) {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
    }
}
else {
    String errorMsg = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Parameter.InvalidAction");
    String ErrorStr = StringResource.format(errorMsg, "P1", XSSUtil.encodeForJavaScript(context, objectAction));
    emxNavErrorObject.addMessage(ErrorStr);
}

String title = SimulationUtil.getI18NString(context,
    "smaSimulationCentral.ImportExportClose."+ objectAction);

String closeLabel = SimulationUtil.getI18NString(context,
"smaSimulationCentral.Button.Close");

StringBuilder paramHTML = new StringBuilder(100);
StringBuilder headerHTML = new StringBuilder(100);

headerHTML.append("<div id=\"pageHeadDiv\"> ");
headerHTML
.append("<TABLE> <TR> <TD class=\"page-title\"> <h2>");
headerHTML.append(title).append("</h2></TD> </TR>");
headerHTML.append(" </TABLE></div> ");

// build toolbar 
StringBuilder toolBarHTML = new StringBuilder(100);
toolBarHTML.append("<TABLE bgcolor=\"#E0E0E0\" ");
toolBarHTML
.append("border=\"1px\" borderColor=\"#CCCCCC\" ");
toolBarHTML.append("width=\"100%\" ");
toolBarHTML
.append("cellspacing=\"0\" cellpadding=\"0\">");
toolBarHTML
.append("<TR> <TD><TABLE ><TR valign=\"bottom\">");
String endToolBarHTML = "</TR></TABLE></TD></TR> </TABLE>";

paramHTML.append(headerHTML.toString());
paramHTML.append(toolBarHTML.toString());
paramHTML.append(endToolBarHTML);

fileContent = StringUtil.htmlEncodeForHostExport(fileContent).trim();
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css"
    type="text/css">
<title><%=title%></title>
</head>
<body style="margin: 0px; padding: 0px;">
    <%=paramHTML.toString()%>
    <br>
    <br>
    <div id="divPageBody" style="margin: 5px; padding: 5px;">

<script language="Javascript">

var fileContent = "<%= fileContent %>";
var fileName = "<%= fileName%>";
var objectAction = "<%=XSSUtil.encodeForJavaScript(context, objectAction)%>" ;
var blob = new Blob(["\ufeff", htmlUnescapeForHostExport(fileContent)]);

if(window.navigator.msSaveOrOpenBlob)
	{
	//for IE
	window.navigator.msSaveOrOpenBlob(blob, fileName);
    }
else
	{
	 //for chrome and Firefox
		   var link = document.createElement('a');
		   link.href =  URL.createObjectURL(blob);
		   link.download = fileName;
		   document.body.appendChild(link);
		   link.click();
}
</script>
    </div>
    <form action="result" method="post">
        <br>
        <div id="divPageFoot">
            <table>
                <tr>
                    <td class="functions"></td>
                    <td class="buttons">
                        <table>
                            <tr>
                                <td><a href="javascript:getTopWindow().closeWindow();"><img
                                        src="../common/images/buttonDialogCancel.gif" border="0"
                                        alt="<%=closeLabel%>"></a></td>
                                <td><a href="javascript:getTopWindow().closeWindow();" class="button"><%=closeLabel%></a></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
