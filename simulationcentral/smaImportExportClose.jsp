<html>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@page import="java.net.URLEncoder" %>
<%@page import = "java.net.URLDecoder" %>
<script type="text/javascript"  src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../simulationcentral/smaGeneral.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%
    String results = emxGetParameter(request, "results"); 
    Locale reqlocale = request.getLocale();
    String[] methodargs2 = { results, reqlocale.toString() };
    results = (String) JPO.invoke(context, "jpo.simulation.Job", null,
            "formatLogMsg", methodargs2, String.class);
    results = URLEncoder.encode( results, "UTF-8" );
    String method = emxGetParameter(request, "method");
    String mylocale = context.getSession().getLanguage();
    String cosError = SimulationUtil.getI18NString(context,
            "Error.Station.COSError");

    String reqError = SimulationUtil.getI18NString(context,
            "Error.Station.COSRequestError");
    String sError = "";

%>
<%
    if ("parameterImport".equalsIgnoreCase(method)) {
                results = MessageServices.massageMessage(results, false);
%>
<script language="javascript">
    if (getTopWindow() && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow())
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
</script>
<%
    } else if ("attributeImport".equalsIgnoreCase(method)) {
                results = MessageServices.massageMessage(results, false);
%>
<script language="javascript">
    if (getTopWindow() && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow())
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
</script>
<%
    } else if ("attributeExport".equalsIgnoreCase(method)) {
                results = MessageServices.massageMessage(results, false);
                String[] methodargs3 = {results, reqlocale.toString()};
                results = (String) JPO.invoke(context, "jpo.simulation.Job",
                        null, "formatLogMsg", methodargs3, String.class);
%>
<script language="javascript">
    if (getTopWindow() && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow())
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
</script>
<%
    } else if ("runAs".equalsIgnoreCase(method)) {
        results = MessageServices.massageMessage(results, false);
%>
<script language="javascript">
        makeRunJob("", "ConfigureAndRun");
        if(getTopWindow().childWindow){
        getTopWindow().childWindow.closeWindow();
        }

</script>
<%
    }
            if (results.equals("")) {
%>
<script language=javascript>
closeWindow();
</script>
<%
    } else {
        // if we are doing a host import and we need to push to cos
        // the new oids will be in the second part of the results
        if ("hostImport".equalsIgnoreCase(method) && 
                results.indexOf("::::") == -1 &&  results.indexOf("!!!!") == -1)
        {
            String [] hostInfo = results.split(":::");
            results = hostInfo[0];
            // if we do not have oids it means we had an error
            // display it and close the window.
            if (hostInfo.length == 1)
            {
                   %>
                   <script language="javascript">
                    alert("<%=URLDecoder.decode(results, "UTF-8")%>");
              closeWindow();
                   </script>
                   <%
                
            }
            if (hostInfo.length == 2 && hostInfo[1].length() > 0)
            {
                ArrayList<String> objIds = new ArrayList<String>();
                ArrayList<String> stationNames = new ArrayList<String>();
                String [] hosts = hostInfo[1].split( "\\|"); 
                
                // get the station name and OID
                for (String host:hosts)
                {
                    String [] stationInfo = host.split(":");
                    
                    // should always be two since internally built string
                    if (stationInfo.length == 2)
                    {
                        objIds.add(stationInfo[0]);
                        stationNames.add(stationInfo[1]);
                    }
                }
                
                //rebuild the oid str to pass to JPO method 
                StringBuilder objIdStr = new StringBuilder();
                for (String oid:objIds)
                {
                    objIdStr.append(oid).append('|');
                }
                objIdStr.deleteCharAt(objIdStr.length()-1);
                
                // check for modify access for existing stations
                for (int i=0; i < objIds.size(); i++)
                {
                      // add try catch block for invalid password exception 
                      // when user does not have access
                      try
                      {
                          if ( ! AccessUtil.hasAccess(
                                context, objIds.get(i), "modify"))
                          {
                              sError = 
                                    SimulationUtil.getI18NString(context,
                                        "smaSimulation.StationNoModify",
                                        "P1", stationNames.get(i));
                              break;
                          }              
                      }
                      catch (Exception ex)
                      {
                          sError = 
                                    SimulationUtil.getI18NString(context,
                                        "smaSimulation.StationNoModify",
                                        "P1", stationNames.get(i));
                              break;                          
                      }
                }
                if (sError != null && sError.length() > 0)
                {                   
                   %>
                   <script language="javascript">
                    alert("<%=sError%>");
              closeWindow();
                   </script>
                   <%
                }
                else
                {
                 String serverName = emxGetParameter(request, "serverName");
            
                 String[] jpoargs = new String[1];
                 jpoargs[0] = serverName;
                 serverName =
                    (String)JPO.invoke( context, 
                     "jpo.simulation.SimulationHost", null, 
                     "getCosServerName", jpoargs, String.class);
                  String[] methodargs = 
                        new String[] { objIdStr.toString(),"true","false",serverName };
                  HashMap<String, String> stationDataMap = null;
                  try
                  {
                     // get EED data and station info.  
                     // this includes eed url and a ticket and the station xml
                     stationDataMap = 
                        (HashMap<String, String>) JPO
                        .invoke(context, "jpo.simulation.SimulationHostGroup",
                        null, "getStationUpdateData", 
                        methodargs, HashMap.class);
                   }
                   catch (Exception ex)
                   {
                       sError = ErrorUtil.getMessage(ex, false);
                       %>
                       <script language="javascript">
                        alert("<%=sError%>");
                  closeWindow();
                       </script>
                       <%
                   }
        
                   // check if we had an error
                   sError = stationDataMap.get("exception");
                   if (sError != null && sError.length() > 0)
                   {
                       %>
                       <script language="javascript">
                        alert("<%=sError%>");
                  closeWindow();
                       </script>
                       <%
                   }
                   else
                   {
                      // build URL to continue jsp so synced attribute
                      // can be set if the eed web service succeeded
                        URLBuilder contentURL = new URLBuilder(
                            request.getRequestURI().length(),
                            request.getCharacterEncoding());
                        contentURL.append(
                            "../simulationcentral/smaHostGroupUtilContinue.jsp?");
                        contentURL.append("locale=").appendEncoded(context,mylocale);
                        contentURL.append("&objectAction=pushToCosClose&objIdStr=")
                            .append( objIdStr.toString());
                        
                      // get data for the web service call
                      // and call the update web service with the data
                        String ticket = 
                                stationDataMap.get("ticket");
                        String infoUrl = 
                                stationDataMap.get("eedURL");
                        String stationData = 
                                stationDataMap.get("stationXml");
                        stationData = stationData.replace("'", "\\'");
                        if (!infoUrl.endsWith("/"))
                            infoUrl = infoUrl + "/";
                        StringBuffer eedURL = new StringBuffer();
                        eedURL.append(infoUrl).append(
                                "admin/station/update");
                        %>
                        <form style="display: hidden" action="<%=contentURL.toString()%>" method="POST" id="form">
                          <input type="hidden" id="stationData" name="stationData" value=""/>
                        </form>
                        <script language="javascript">
                        var dataStr = "";
                        var ticket1 = "<%=ticket%>";
                        var stationXml = '<%=stationData%>';
                        var eedURL1 =  "<%=eedURL.toString()%>";
                        jQuery.ajax({ 
                            url : eedURL1,
                            type : "PUT",
                          cache:false,
                            beforeSend : function(request) {
                                request.setRequestHeader("EEDTicket", ticket1);
                            },
                            data : stationXml,
                            contentType : "text/xml",
                            success : function(returndata, status, xhr) {
                                dataStr = returndata;
                                if (dataStr != null && dataStr.length > 0)
                                {
                                        alert(dataStr);
                                        $("#form").submit();
                                    }
                            },
                            error : function(jqXHR, textStatus, errorThrown) 
                            {
                                 if (jqXHR.status === 0) 
                                     alert ("<%=cosError%>");
                                 else if (jqXHR.responseText != null &&
                                             jqXHR.responseText.length >0 )
                                 {
                                        alert  (jqXHR.responseText) ;
                                 }
                                 else
                                     alert ("<%=reqError%>");                            
                              closeWindow();
                            }
                        });
                        </script>
                        <%
                      }
                    }
                  }             
                }
                // host import returns a string that can be split by "::::"
                // it will return new host relation info and possibly modified
                // host info for removing hosts from old folders
                // the new and modified string are separated by "!!!!"
                // each host in the new or modified info is separated by "::::"
                // for each host it contains the host id "|" host-folder relation id
                // if the "::::" sparator is not found then this is an error message
                // that should be displayed
                else if ("hostImport".equalsIgnoreCase(method) && 
                    (results.indexOf("::::") != -1 || results.indexOf("!!!!") != -1)) {
                    // get the passed in arguments for host import
                    String refreshFrame = emxGetParameter(request,
                            "refreshFrame");
                    String selectedRow = emxGetParameter(request, "selectedRow");
                    String[] hostInfo = results.split("!!!!");
                    if (hostInfo.length == 0)
                        results = "";
                    else
                        results = hostInfo[0];
                    String modInfo = "";
                    String sXML = "";
                    if (hostInfo.length > 1) {
                        modInfo = hostInfo[1];
                        // remove trailing separator
                        modInfo = modInfo.substring(0, modInfo.length() - 4);
                    }
                    // if no modify data...add new hosts into folder
                    if (modInfo.length() == 0 && results.length() > 0) {
                        // remove trailing separator
                        results = results.substring(0, results.length() - 4);
                        // split the string using jpo host separator
                        // each split string will contain the new
                        // host id and folder relation id 
                        String[] relList = results.split("::::");
                        StringList contentData = new StringList(relList.length);
                        for (int j = 0; j < relList.length; j++) {
                            contentData.add(relList[j]);
                        }
                        // build returning xml java string so new
                        // hosts show up under the folder
                        String action = "add";
                        String message = "";
                        sXML = StructureBrowserUtil.convertToXMLString(context,
                                action, message, selectedRow, contentData,
                                refreshFrame, false);
                    }
%>
<script language=javascript>
    removeStr = '<%=modInfo%>
    ';
    if (removeStr.length > 0) {
        // If we are moving hosts to new folder need to reload the page 
        // since don't know how to remove the hosts from the old folder 
        // in the toc.  By refreshing the page it will reload
        var frameTOCContent = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(), "smaHomeTOCContent");
        if (frameTOCContent) {
            frameTOCContent.location.href = frameTOCContent.location.href;
        }

    }
</script>
<%=sXML%>
<script language=javascript>
closeWindow();
</script>
<%
    return;
                } else {

                    if ("importZRF".equalsIgnoreCase(method)) {
%>
<script language=javascript>
    var frameTOCContent = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),
            "SMAHome_SMAHome_Advise_TabCases");
    if (frameTOCContent) {
        frameTOCContent.location.href = frameTOCContent.location.href;
    }
    getTopWindow().closeWindow();
</script>
<%
    }

                    else {
                        String title = "";
                        Boolean execute = false;
                        if ("RunJob".equalsIgnoreCase(method)) {
                            String jobId = emxGetParameter(request, "jobId");
                            if (jobId != null)
                                execute = true;
                            if (execute && !jobId.equals("")) {
                                String[] methodargs = {jobId};
                                SlmUIUtil.deleteObjects(context, methodargs);
                            }
                        }
                        String locale = context.getSession().getLanguage();
                        String resStr = SimulationUtil.getI18NString(context,
                                        "smaSimulationCentral.ImportExportClose.Result");

                        String methStr = SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.ImportExportClose."
                                        + method);

                        title = methStr + " " + resStr;
                        String closeLabel = SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.Button.Close");
                        // build header html sting 
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
                        int resultsL = results.length();
                        int windowHeight = 175;
                        if (resultsL >= 50 && resultsL < 100)
                            windowHeight = 195;
                        else if (resultsL >= 100)
                            windowHeight = 250;
%>
<script language="JavaScript">
    window.moveTo(0, 0)
    if (navigator.appName == "Microsoft Internet Explorer") {
        window.resizeTo(400,
<%=windowHeight%>
    )
    } else {
        window.resizeTo(400,
<%=windowHeight%>
    + 50)
    }
</script>
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
        <%= URLDecoder.decode(results, "UTF-8")%>
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
<%
    }
        }
    }
%>

