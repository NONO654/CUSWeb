<%--  MCADCheckinUnrecognizedNodesHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>

<%! 
	public String getRecognitionProgramsSelectControlString(Context context, MCADIntegrationSessionData integSessionData, String integrationName) throws MCADException
    {
        StringBuffer recognitionProgramSelectControlBuffer = new StringBuffer(" <select name=\"RecognitionProgramComboControl\" onChange=\"parent.selectedRecognitionProgram(this)\">\n");

		recognitionProgramSelectControlBuffer.append(" <option value=\"" + MCADAppletServletProtocol.VIEW_NONE + "\">" + integSessionData.getStringResource("mcadIntegration.Server.FieldName.None") + "</option>\n");
        
		Hashtable recognitionProgLabelNameMap   = integSessionData.getGlobalConfigObject(integrationName,context).getRecognitionPrograms();
        if(recognitionProgLabelNameMap != null)
        {
            Enumeration availablePrograms = recognitionProgLabelNameMap.keys();
            while(availablePrograms.hasMoreElements())
            {
                String programLabel = (String)availablePrograms.nextElement();
				Vector programNames = (Vector)recognitionProgLabelNameMap.get(programLabel);
                String programName	= (String)programNames.elementAt(0);

                recognitionProgramSelectControlBuffer.append(" <option value=\"" + programName + "\""+ "  "+"id=\"" + programLabel  +  "\">" + programLabel + "</option>\n");
            }
        }

        recognitionProgramSelectControlBuffer.append(" </select>\n");

        return recognitionProgramSelectControlBuffer.toString();
    }
%>

<%
	String integrationName	= request.getParameter("integrationName");
	String operationName	= request.getParameter("operation");

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
%>

<html>
<head>
	<title>emxTableControls</title>
	<style type=text/css > body { background-color: #DDDECB; } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; } 
	</style>
</head>
<body>
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
		<tr>
			<td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
	</table>
	<table border="0" cellspacing="2" cellpadding="2" width="100%">
		<tr>
		    <!--XSSOK-->
			<td class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.UnrecognizedNodes") %></td>
			<td align='left'><img src='images/utilSpace.gif' width='34' height='27' name=progress></td>

			<td align="right"><!--XSSOK-->
			<b><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.RecognitionProgram")%></b><!--XSSOK-->
			<%=getRecognitionProgramsSelectControlString(integSessionData.getClonedContext(session), integSessionData, integrationName)%></td>
		</tr>
	</table>
</body>
</html>
