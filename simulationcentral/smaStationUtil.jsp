<%-- (c) Dassault Systemes, 2010 --%>
<%--
  Actions on the Station List page.
--%>

<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>

<%@page import="java.util.HashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="matrix.db.JPO"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%
	// What is it that we want to do?
    // Possible objectAction values:
    //    stop - stop station gracefully waits for work to complete
    //    stopForce - force station shutdown
    //    restart - gracefully stops the stations and then restarts it 
    //    restartForce - force stops the stations and then restarts it 
    //    suspend - suspends the station no work sent to it
    //    resume - resumes station

    String objectAction = emxGetParameter(request, "objectAction");
    String locale = context.getSession().getLanguage();
    String sError = "";
    String cosError = SimulationUtil.getI18NString(context,
            "Error.Station.COSError");
	String serverName = emxGetParameter(request, "serverName");
	
    String[] jpoargs = new String[1];
    jpoargs[0] = serverName;
    serverName =
		(String)JPO.invoke( context, 
        "jpo.simulation.SimulationHost", null, 
        "getCosServerName", jpoargs, String.class);
    // sanity check should never happen
    if ( (objectAction == null) || (objectAction.equals("")) )
    {
        sError = SimulationUtil.getI18NString(context,
                "Error.ContentUtil.NoAction");
        emxNavErrorObject.addMessage(sError);
        objectAction = "";
    }
    else
    {
        // get an interned string ref for faster reference compares
        objectAction = objectAction.intern();
    }
    
    // flag indicating if we need selected stations for the command
    boolean needStations = true;
    String href = "";  
    // pause and resume of server does not need any selected stations		
    if ("pauseServer".equals(objectAction)  || "resumeServer".equals(objectAction))
    {
    	needStations = false;
		HashMap requestMap = 
				UINavigatorUtil.getRequestParameterMap(pageContext);
    	href = SlmUIUtil.getCommandHref(context,
	        "SMACOSServer_Details", null, null, requestMap);
    }

    int nObjs = 0;
    /////////////////
    // Get selected rows from the request
    String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");

    // sRowIds should never be null since these commands must have a
    // selection multiple setting and are thus caught 
    // by M1 if nothing is selected
    if ( ((sRowIds == null) || (sRowIds.length == 0)) &&  needStations)
    {
    	sError =  EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.PleaseSelectitem");
        emxNavErrorObject.addMessage(sError);
    }

    else 
    {
    	List<String> stations = new ArrayList<String>();
    	if (needStations)
    	{
	    	// get the selected stations
	    	// stations will have an id in the form of
	    	// name|status.  
	    	nObjs = sRowIds.length;
	        for (int i = 0; i < nObjs; i++)
	        {
	        	String sRowId = sRowIds[i];
	        	
	        	// if we have an id make sure it is in the form of
	        	// name|status
	        	if (null != sRowId && sRowId.length() > 0)
	        	{
	        		String [] rowInfo = sRowId.split( "\\|"); 
	        		
	        		// make sure we have a station name 
	        		if (rowInfo != null && rowInfo.length > 0)
	        		{
	        			String stationName = rowInfo[0];
	        			stations.add(stationName);
	        		}
	        	}
	        }
    	}
        
        // If we have not selected any appropriate stations indicate 
        // error.  Any selected application rows are skipped
        if (stations.size() == 0 &&  needStations)
        {
			sError = SimulationUtil.getI18NString(context,
					"Error.Station.Not.Selected");
			emxNavErrorObject.addMessage(sError);

		} else {
			// get EED data this include eed url and a ticket
			// the ticket is not based on any plm object
		    String[] args = new String[1];
		    args[0] = serverName;
			HashMap<String,String> eedInfo=
				(HashMap<String,String>)JPO.invoke( context, 
		        "jpo.simulation.SimulationHost", null, 
		        "getEEDData", args, HashMap.class);


			// set restart and force flags and check if we are 
			// restarting on shutdown or doing a forced stop
			String restart = "False";
			String force = "";
			if (objectAction.startsWith("restart"))
				restart = "True";
			if (objectAction.endsWith("Force"))
				force = "True";
			
			// get EED info
			String ticket = eedInfo.get("ticket");
			String infoUrl = eedInfo.get("eedURL");
			if (!infoUrl.endsWith("/"))
				infoUrl = infoUrl + "/";
			StringBuffer eedURL = new StringBuffer();

			if ("suspend".equalsIgnoreCase(objectAction)) {
				// add path/query arguments for suspending a station
				eedURL.append(infoUrl).append(
						"admin/station/suspend?Resume=False");
				for (String station : stations) {
					eedURL.append("&stationName=").append(station);
				}
			} else if ("resume".equalsIgnoreCase(objectAction)) {
				// add path/query arguments for resuming a station
				eedURL.append(infoUrl).append("admin/station/resume");
				int i = 0;
				for (String station : stations) {
					if (i == 0) {
						eedURL.append("?stationName=").append(station);
					} else {
						eedURL.append("&stationName=").append(station);
					}
					i++;
				}
			} else if ("resumeServer".equalsIgnoreCase(objectAction)) {
				// add resumeEED for resuming the server
				eedURL.append(infoUrl).append("admin/server/resume");
			} else if ("pauseServer".equalsIgnoreCase(objectAction)) {
				// add pauseEED for pausing the server
				eedURL.append(infoUrl).append("admin/server/pause");
			} else {

				// add path/query arguments for stopping/restarting
				eedURL.append(infoUrl)
						.append("admin/station/shutdown?Restart=")
						.append(restart);
				for (String station : stations) {
					eedURL.append("&stationName=").append(station);
				}
			}
%>
<script language="javascript">
            var dataStr = "";
            var ticket1 = "<%=ticket%>";
            var force1 = "<%=force%>";
            var href = "<%=href%>";
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
                myXMLHTTPRequest.setRequestHeader(
                		'Cache-Control','no-cache');
                myXMLHTTPRequest.setRequestHeader(
                		'Pragma','no-cache');
                myXMLHTTPRequest.send(null);
                dataStr = myXMLHTTPRequest.responseText;
                if (force1.length > 0)
                {
	                var myXMLHTTPRequest2 = new XMLHttpRequest();
	                myXMLHTTPRequest2.open(
	                        "PUT", 
	                        "<%=eedURL.toString()%>", 
	                              false);
	                myXMLHTTPRequest2.setRequestHeader(
	                        'Content-Type', 'text/xml');
	                myXMLHTTPRequest2.setRequestHeader(
	                        'EEDTicket', ticket1);
	                myXMLHTTPRequest2.setRequestHeader(
	                		'Cache-Control','no-cache');
	                myXMLHTTPRequest2.setRequestHeader(
	                		'Pragma','no-cache');
	                myXMLHTTPRequest2.send(null);
	                dataStr = myXMLHTTPRequest2.responseText;
                }
            }
            catch (err)
            {
                alert ("<%=cosError%>");
                // do not print out trace for now
                //var vDebug = "";
                //for (var prop in err)
                //{ 
                //   vDebug += 
                //	   "property: "+prop+ " value: ["+ err[prop]+ "]\n";
                //}
                //alert(vDebug);
                dataStr = "";
            }
            if (dataStr != null && dataStr.length > 0)
            {
				alert(dataStr);
                if (href.length > 0)
                {
  			      	var frame = null;  
  			      	frame = findFrame(getTopWindow(),"content"); 
  			      	if (frame) 
  			      	{
  			        	frame.location.href = href;
  			      	}
                	
                }
			}
</script>
<%
        }
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>


