<%--  smaResumeWaitingTask.jsp 
  -- jsp launched from run command of simulation activity property page.

 * (c) Dassault Systemes, 2009
 *  
--%>


<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.common.util.JobUtil"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.StringValidator"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationActivity"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.Map"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "java.net.InetAddress"%>


<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
	matrix.db.Context context2 = 
	    (matrix.db.Context)request.getAttribute("context");
	if (context2 != null)
    context = context2;
	    
	String objectId = emxGetParameter(request, "objectId");
	String workitem = emxGetParameter(request, "workitem");
    String hostName = "";
    String operation = "continue";
    String startCommand = "";
    String jobId = emxGetParameter(request, "jobId");;
    boolean hadError = false;
    boolean isFiperHost = false;
    URLBuilder contentURL = getURLBuilder(request);
    StringBuilder windowName = new StringBuilder(50);

    final String LOCALE = context.getSession().getLanguage();

    if (objectId!= null && !objectId.equals(""))
    {
        String[] rowIds = emxGetParameterValues(request, "emxTableRowId");

        Map argsMap = new HashMap();
        argsMap.put("objectId", objectId);
        argsMap.put("selectedFiles", rowIds);

        String jobExecInfo =
            (String) JPO.invoke(
                context,
                "jpo.simulation.Job",
                null,
                "selectImportFilesAndResumeJob",
                JPO.packArgs(argsMap),
                String.class);

        if (jobExecInfo == null || jobExecInfo.length() == 0)
        {
            emxNavErrorObject.addMessage(
                SimulationUtil.getI18NString(context,
                    "Error.JobRun.NoJobInfo"));
            return;
        }
        // get EED data with modify acess
                    String [] jpoArgs = {jobExecInfo,"MODIFY" };
                    HashMap eedInfo=(HashMap)JPO.invoke( context, 
                        "jpo.simulation.Job", null, 
                        "getEEDData", jpoArgs, HashMap.class);
                    StringBuffer eedURL =  new StringBuffer(); 
                    String ticket = (String)eedInfo.get("ticket");
                    String infoUrl = (String)eedInfo.get("eedURL");
                    if (!infoUrl.endsWith("/"))
                        infoUrl = infoUrl + "/";
                    String objectAction = "claim";
                    String itemId = "";
                        // add path arguments for resuming item
                        eedURL.append(infoUrl)
                            .append("execution/")
                            .append(jobId).append("/workitem/")
                            .append(workitem).append("/resume");
                    %>
                    <script language="javascript">
                    var dataStr = "";
                    var ticket1 = "<%=ticket%>";
                    try
                    {
                        var myXMLHTTPRequest = new XMLHttpRequest();
                        myXMLHTTPRequest.open(
                                "PUT", 
                                "<%=eedURL.toString()%>", 
                                false);
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
                               alert("***"+status);
                        }
                        catch (e)
                        {
                            dataStr = "";
                        }                       
                    }
                    </script>
                   <% 
    }
%>


<Script>
//var getWindowOpener() = getTopWindow().getWindowOpener();
getTopWindow().closeWindow();
//if (getWindowOpener() != null) 
//{
	//alert("getWindowOpener() = "+getWindowOpener() );
	//getWindowOpener().closeWindow();
 //}

</Script>


