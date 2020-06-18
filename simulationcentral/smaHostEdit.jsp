<%-- (c) Dassault Systemes, 2014 --%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>


<%
    String objectAction = emxGetParameter(request, "objectAction");
    String objId        = emxGetParameter(request, "objectId");
    String groupName    = emxGetParameter(request,"HostGroupDisplay");
    String oldGroupName = emxGetParameter(request,"HostGroupfieldValue");
    String sError = "";
    String locale = context.getSession().getLanguage();
    String cosError = SimulationUtil.getI18NString(context,
            "Error.Station.COSError");

    String reqError = SimulationUtil.getI18NString(context,
            "Error.Station.COSRequestError");

	String serverName = emxGetParameter(request, "serverName");
	
    String[] jpoargs = new String[1];
    jpoargs[0] = serverName;
    serverName =
		(String)JPO.invoke( context, 
        "jpo.simulation.SimulationHost", null, 
        "getCosServerName", jpoargs, String.class);
    
    HashMap paramMap = new HashMap();
    HashMap programMap = new HashMap();
    Enumeration prms = request.getParameterNames();
    while (prms.hasMoreElements())
    {
        String name = (String) prms.nextElement();
        String value = emxGetParameter(request, name);
        paramMap.put(name,value);
    }
    programMap.put("objectId",objId);
    programMap.put("HostGroupDisplay",groupName);
    programMap.put("HostGroupfieldValue",oldGroupName);

    programMap.put("paramMap",paramMap);

    String[] args = JPO.packArgs(programMap);

    if ("editHost".equalsIgnoreCase(objectAction))
    {
		HashMap<String, String> stationDataMap = null;
		try
		{
			// get EED data and station info.  
			// this includes eed url and a ticket and the station xml
			stationDataMap = 
				(HashMap<String, String>) JPO
				.invoke(context, "jpo.simulation.SimulationHost",
				null, "editHost", 
				args, HashMap.class);
		}
		catch (Exception ex)
		{
			sError = ErrorUtil.getMessage(ex, false);
		    emxNavErrorObject.addMessage(sError);
		} 
		if (sError != null && sError.length() == 0)
		{
    		String[] methodargs2 = 
    				new String[] { objId,"true","false",serverName };
			try
			{
				// get EED data and station info.  
				// this includes eed url and a ticket and the station xml
				stationDataMap = 
					(HashMap<String, String>) JPO
					.invoke(context, "jpo.simulation.SimulationHostGroup",
					null, "getStationUpdateData", 
					methodargs2, HashMap.class);
			}
			catch (Exception ex)
			{
			      emxNavErrorObject.addMessage(
			      	ErrorUtil.getMessage(ex, false));
			}
			// check if we had an error
			String errorStr = stationDataMap.get("exception");
			if (errorStr != null && errorStr.length() > 0)
			{
		  	     emxNavErrorObject.addMessage(errorStr);				
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
			        contentURL.append("locale=").appendEncoded(context,locale);
			        contentURL.append("&objectAction=pushToCosEdit&objIdStr=")
			        	.append(objId);
					
				  // get data for the web service call
				  // and call the update web service with the data
					String ticket = 
							stationDataMap.get("ticket");
					String infoUrl = 
							stationDataMap.get("eedURL");
					String stationData = 
							stationDataMap.get("stationXml");

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
                    var oAjaxReq = new XMLHttpRequest();
                    oAjaxReq.open("PUT",eedURL1, false);
                    oAjaxReq.setRequestHeader("EEDTicket", ticket1);
                    oAjaxReq.setRequestHeader("Content-Type", "text/xml");
                    oAjaxReq.setRequestHeader('Cache-Control','no-cache');
                    oAjaxReq.setRequestHeader('Pragma','no-cache');
                    oAjaxReq.onreadystatechange = function(){
                        if(oAjaxReq.readyState != 4) return;
                        if(oAjaxReq.status === 0) {
	                    	 alert ("<%=cosError%>");
                        }
                        else if (oAjaxReq.status == 200){
	                  		dataStr = oAjaxReq.responseText;
	  		            	if (dataStr != null && dataStr.length > 0)
	  		            	{
	        					alert(dataStr);
	        					$("#form").submit();
	        				}
                        }
                        else if (oAjaxReq.responseText!= null &&
                        		oAjaxReq.responseText.length >0) {
                        	alert  (oAjaxReq.responseText) ;
                        }
                        else {
                        	 alert ("<%=reqError%>");	
                        }
                    };
                    try {
                    	oAjaxReq.send(stationXml);
                    }
                    catch (error)
                    {
                    	if (error == null)
                    		alert ("<%=reqError%>");	
                    	else if ("NetworkError" == error.name)
                    		alert ("<%=cosError%>");
                    	else
                    		alert ("<%=reqError%>");	
                    }
					</script>
					<%
			}
			
		}
    }
    if ("editHostGroup".equalsIgnoreCase(objectAction))
    {
		HashMap<String, String> stationDataMap = null;
		String relatedHosts = "";
		try
		{
			// get EED data and station info.  
			// this includes eed url and a ticket and the station xml
			stationDataMap = 
				(HashMap<String, String>) JPO
				.invoke(context, "jpo.simulation.SimulationHostGroup",
				null, "editHost", 
				args, HashMap.class);
			relatedHosts = (String)stationDataMap.get("RelatedHosts");
			if (null == relatedHosts)relatedHosts = "";
		}
		catch (Exception ex)
		{
			sError = ErrorUtil.getMessage(ex, false);
		    emxNavErrorObject.addMessage(sError);
		} 
		if (sError != null && sError.length() == 0)
		{
			relatedHosts = relatedHosts + objId;
    		String[] methodargs2 = 
    				new String[] { relatedHosts,"true","false",serverName };
			try
			{
				// get EED data and station info.  
				// this includes eed url and a ticket and the station xml
				stationDataMap = 
					(HashMap<String, String>) JPO
					.invoke(context, "jpo.simulation.SimulationHostGroup",
					null, "getStationUpdateData", 
					methodargs2, HashMap.class);
			}
			catch (Exception ex)
			{
			      emxNavErrorObject.addMessage(
			      	ErrorUtil.getMessage(ex, false));
			}
			// check if we had an error
			String errorStr = stationDataMap.get("exception");
			if (errorStr != null && errorStr.length() > 0)
			{
		  	     emxNavErrorObject.addMessage(errorStr);				
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
			        contentURL.append("locale=").appendEncoded(context,locale);
			        contentURL.append("&objectAction=pushToCosEdit&objIdStr=")
			        	.append(relatedHosts);
					
				  // get data for the web service call
				  // and call the update web service with the data
					String ticket = 
							stationDataMap.get("ticket");
					String infoUrl = 
							stationDataMap.get("eedURL");
					String stationData = 
							stationDataMap.get("stationXml");
					
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
                    var oAjaxReq = new XMLHttpRequest();
                    oAjaxReq.open("PUT",eedURL1, false);
                    oAjaxReq.setRequestHeader("EEDTicket", ticket1);
                    oAjaxReq.setRequestHeader("Content-Type", "text/xml");
                    oAjaxReq.setRequestHeader('Cache-Control','no-cache');
                    oAjaxReq.setRequestHeader('Pragma','no-cache');
                    oAjaxReq.onreadystatechange = function(){
                        if(oAjaxReq.readyState != 4) return;
                        if(oAjaxReq.status === 0) {
	                    	 alert ("<%=cosError%>");
                        }
                        else if (oAjaxReq.status == 200){
	                  		dataStr = oAjaxReq.responseText;
	  		            	if (dataStr != null && dataStr.length > 0)
	  		            	{
	        					alert(dataStr);
	        					$("#form").submit();
	        				}
                        }
                        else if (oAjaxReq.responseText!= null &&
                        		oAjaxReq.responseText.length >0) {
                        	alert  (oAjaxReq.responseText) ;
                        }
                        else {
                        	 alert ("<%=reqError%>");	
                        }
                    };
                    try {
                    	oAjaxReq.send(stationXml);
                    }
                    catch (error)
                    {
                    	if (error == null)
                    		alert ("<%=reqError%>");	
                    	else if ("NetworkError" == error.name)
                    		alert ("<%=cosError%>");
                    	else
                    		alert ("<%=reqError%>");	
                    }
					</script>
					<%
			}
			
		}
    }    
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
