<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<html>
	<head>
	  <meta charset="utf-8" />
	</head>
	<body style="height:100%;width:100%;">
	
		<%
		
		String serverName = emxGetParameter(request, "serverName");
		
	    String[] jpoargs = new String[1];
	    jpoargs[0] = serverName;
	    serverName =
			(String)JPO.invoke( context, 
	        "jpo.simulation.SimulationHost", null, 
	        "getCosServerName", jpoargs, String.class);
		// set content url to point to emxTable and set the program jpo
		// to the method to get the maplist for the event rows 
		// the event data is gotten in a webservice call to the EED
		// made in java script
		// it is past to the program jpo by using a submit of a form 
		// containing the event data in a hidden field
		// which is set using jQuery to set the from field
		// for the event data xml returned by the web service call
		
		String headerStr = serverName + " "  + SimulationUtil.getI18NString(context,
                    "smaSimulationCentral.EventLog.Header");

		StringBuffer contentURL =  new StringBuffer(); 
		contentURL.append("../common/emxTable.jsp?")
		           .append("program=jpo.simulation.SimulationHost:getEventData")
		           .append("&table=SMAStationAdmin_EventData")
		           .append("&header=").append(headerStr)
		           .append("&Export=false")
		           .append("&PrinterFriendly=false")
		           .append("&showClipboard=false")
		           .append("&objectCompare=false")
		           .append("&HelpMarker=SMAStationAdmin_EventData")
		           .append("&suiteKey=SimulationCentral")
		           .append("&massUpdate=false");
		
		//  call a jpo method to get the EED url to use
		// for the event data query web service call
    String[] args = new String[1];
    args[0] = serverName;
	HashMap<String,String> eedInfo=
		(HashMap<String,String>)JPO.invoke( context, 
        "jpo.simulation.SimulationHost", null, 
        "getEEDData", args, HashMap.class);


        StringBuffer eedURL =  new StringBuffer(); 
        eedURL.append(eedInfo.get("eedURL"))
                .append("/admin/eventLog");
        
		String ticket = eedInfo.get("ticket");
        // use java script to define the form holding the content url
        // so the event data can be past as a POST method since it
        // may be to long to pass in a GET method by setting the href
        
        // also make the web service call to get the station data in the
        // java script so it runs on the client not the server
		%>
		
		<form style="display: hidden" action="<%=contentURL.toString()%>" method="POST" id="form">
		  <input type="hidden" id="eventData" name="eventData" value=""/>
		</form>
		
		<script language="javascript">
            var dataStr = "";
            var ticket1 = "<%=ticket%>";
            try
            {
			    var myXMLHTTPRequest = new XMLHttpRequest();
			    myXMLHTTPRequest.open(
			    		"GET", "<%=eedURL.toString()%>", false);
	            myXMLHTTPRequest.setRequestHeader(
	            		'Cache-Control','no-cache');
	            myXMLHTTPRequest.setRequestHeader(
	            		'Pragma','no-cache');
                myXMLHTTPRequest.setRequestHeader(
                        'EEDTicket', ticket1);
			    myXMLHTTPRequest.send(null);
                dataStr = myXMLHTTPRequest.responseText;
	           	var dataLen = dataStr.length;
	           	
	           	// if data to big to POST display last part of the log
	           	if (dataLen > 800000) {	     
	           		var start = dataLen - 800000;
	           		var newStart = dataStr.indexOf('<record',start);
	           		if (newStart < 0) {
	           			dataStr = '';
	           		}
	           		else {
	           			dataStr = '<log>' + dataStr.substring(newStart,dataLen);
	           		}
	           	}
                dataStr = dataStr.replace(/%/g,'*+*');
                dataStr = dataStr.replace(/</g,'&*LT*&');
                dataStr = dataStr.replace(/>/g,'&*GT*&');
    			// replace single quotes so javascript does not break
    			// use strange replacement string so can put single 
    			// quote back in jpo method
    			// note: need 2$$ for each $ to be replaced
          		dataStr = dataStr.replace(/'/g, "$$$$$$$$****");
          		dataStr = dataStr.replace(/"/g, '%%%%####');
            }
            catch (e)
            {
            }
            $("#eventData").val(dataStr);
			$("#form").submit();
		</script>
	</body>
</html>
