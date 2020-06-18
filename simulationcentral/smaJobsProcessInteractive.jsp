<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>


<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>

<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />



<html>
<head>
<meta charset="utf-8" />
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

</head>
<body style="height: 100%; width: 100%;">


	<%
        String sError = "";
        String objectAction = emxGetParameter(request, "action");

        //get the tableDataMap  from the table bean
        String timeStamp = emxGetParameter(request, "timeStamp");
        HashMap tableDataMap = (HashMap) tableBean.getTableData(timeStamp);
        MapList objectList = (MapList)tableDataMap.get("ObjectList");

        // flag which indicates processing being done
        // affects how we close the window because
        // one command opens the jsp in a hidden window and one
        // as a popup
        boolean runPauseBefore = false;

        /////////////////
        // Get selected rows from the request map
        String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");
        if (null != sRowIds)
        {
            // can only claim one pending item at a time
            if ("claim".equals(objectAction) && sRowIds.length > 1)
            {
                sError =
                    SimulationUtil.getI18NString(context,
                    "smaSimulationCentral.Job.Pending.RunOne" );
                emxNavErrorObject.addMessage(sError);

            }
            for (int i = 0;
                i < sRowIds.length &&  sError.length() == 0;
                i++)
            {
                String rowId = sRowIds[i];
                Map rowMap = (Map)
                    objectList.get(Integer.parseInt(rowId));
                String status = (String)rowMap.get("Status");
                String path = (String)rowMap.get("Path");
                String appType = (String)rowMap.get("AppType");
                String jobOID = (String)rowMap.get("jobOID");
                String itemId = (String)rowMap.get("itemId");
                String jobId = (String)rowMap.get("jobId");
                String stepType = (String)rowMap.get("Type");

                if ("Paused Before".equals(status) &&
                    "claim".equals(objectAction))
                {
                       runPauseBefore = true;
                }

                // must run items that are paused before prior to
                // completing them
                if ("Paused Before".equals(status) &&
                    "complete".equals(objectAction))
                {
                    sError =
                        SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Job.Pending.BadState","ITEM",path);
                    emxNavErrorObject.addMessage(sError);
                    runPauseBefore = true;
                }
                // V6 interactive items must be processed from wintop
                else if (SimulationUtil.getProperty(context,"smaSimulationCentral.V6Interactive").equals(appType))
                {
                    sError =
                        SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Job.Pending.BadV6State","ITEM",path);
                    emxNavErrorObject.addMessage(sError);
                }
                else
                {
                    // get EED data with modify acess
                    String [] jpoArgs = {jobOID,"MODIFY" };
                    HashMap eedInfo=(HashMap)JPO.invoke( context,
                        "jpo.simulation.Job", null,
                        "getEEDData", jpoArgs, HashMap.class);
                    StringBuffer eedURL =  new StringBuffer();
                    String ticket = (String)eedInfo.get("ticket");
                    String infoUrl = (String)eedInfo.get("eedURL");
                    String isInteractiveUpload = "false";
                    if (!infoUrl.endsWith("/"))
                        infoUrl = infoUrl + "/";
                    if ("claim".equals(objectAction))
                    {
                        // add path arguments for resuming item
                        eedURL.append(infoUrl)
                            .append("execution/")
                            .append(jobId).append("/workitem/")
                            .append(itemId).append("/resume");

                        // The workitem id is not available so difficult to judge if this is pause after is interactive step case
                       if(stepType.equalsIgnoreCase("Upload") && "Paused After".equals(status))
                       {
                           isInteractiveUpload = "true";
                        String URL = "../common/emxTableEdit.jsp?program=jpo.simulation.Job:getImportStepWaitingInfo&"+
                            "table=SMAImportStep_WaitingInfo&objectBased=false&xmlAttribute=attribute_Definition&xmlTableTag=WaitingInfo&"+
                            "disableSorting=true&multiColumnSort=false&"+
                            "postProcessURL=../simulationcentral/smaResumeWaitingTask.jsp?"+"objectId="+jobOID+"&workitem="+itemId+"&jobId="+jobId+
                            "&header=smaSimulationCentral.ImportRule.SelectFiles&selection=multiple&HelpMarker=SMAJob_ResumeWaitingJob"+
                            "&objectId="+jobOID+
                            "&workitem="+itemId;

                        %>
	<script language="javascript">
                        var strURL = "<%=URL%>";
                        getTopWindow().location.href = strURL;
                        </script>
	<%
                       }
                    }
                    else if ("complete".equals(objectAction))
                    {
                        // add path arguments for completing item
                        eedURL.append(infoUrl)
                            .append("execution/")
                            .append(jobId).append("/workitem/")
                            .append(itemId).append("/complete");
                     }
                        %>
	<script language="javascript">
                        var isInteractiveUploadItem =
                        	"<%=isInteractiveUpload%>";
                        if(isInteractiveUploadItem == "false")
                        {

                        var dataStr = "";
                        var ticket1 = "<%=ticket%>";
                        try
                        {
                            var myXMLHTTPRequest = new XMLHttpRequest();
                            myXMLHTTPRequest.open(
                                    "PUT",
                                    "<%=eedURL.toString()%>",
                                    false);
															myXMLHTTPRequest.onreadystatechange = function()  {
				                             if (myXMLHTTPRequest.readyState === 4) {
				                              	if(myXMLHTTPRequest.status === 200 ){
				                               		if(getTopWindow().getWindowOpener()){
				                               			getTopWindow().getWindowOpener().closeWindow();
				                               		}
				                               		getTopWindow().closeWindow()
				                               	}
				                               	else{
				                               		alert('Failed to complete the job');
				                               		getTopWindow().closeWindow();
				                               	}
			                                }
			                            }
                            myXMLHTTPRequest.setRequestHeader(
                                    'Content-Type', 'text/xml');
                            myXMLHTTPRequest.setRequestHeader(
                                    'EEDTicket', ticket1);
                            myXMLHTTPRequest.send(null);
                            dataStr = myXMLHTTPRequest.responseText;
                        }
                        catch (e)
                        {
                            dataStr = "";
                        }
                        if (dataStr != null && dataStr.length > 0)
                        {
                            try
                            {
                                   var xmlDoc = $.parseXML(dataStr);
                                   status = $(xmlDoc).find("Status").text();
                                   alert(status);
                            }
                            catch (e)
                            {
                                dataStr = "";
                            }
                        }
                        }
                        </script>
	<%


                }
            }
        }
        %>
	<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
	<%
  // flag to see if need to close top window or also getWindowOpener()
  if (runPauseBefore)
  {
%>
	<script language="javascript">
            getTopWindow().closeWindow();
        </script>
	<%
  }

%>
</body>
</html>
