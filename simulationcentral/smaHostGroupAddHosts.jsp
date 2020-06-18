<%-- (c) Dassault Systemes, 2014 --%>
<%--
  Actions for host groups
--%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>

<%@page import="java.util.HashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%-- (c) Dassault Systemes, 2014 --%>
<%--
  Actions for host groups
--%>

<%@page import="matrix.db.JPO"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
	// What is it that we want to do?
    // Possible objectAction values: 

    String objectAction = emxGetParameter(request, "objectAction");
    String locale = context.getSession().getLanguage();
    String sError = "";    
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

    String cosError = SimulationUtil.getI18NString(context,
            "Error.Station.COSError");

      String reqError = SimulationUtil.getI18NString(context,
            "Error.Station.COSRequestError");

    // process adding hosts to the group selected 
    // this from the add hosts command from the station list page
    // where the user picks the group from a combo-box pull-down
	if ("addHosts".equalsIgnoreCase(objectAction))
	{
	    String groupID = emxGetParameter(request, "GroupName");
	    // add try catch block for invalid password exception 
	    // when user does not have access
	    try
	    {
	        if ( ! AccessUtil.hasAccess(
	          		context, groupID, "modify"))
	        {
	            DomainObject hostObj = 
	                    new DomainObject(groupID);
	
	          	  sError = 
	          		SimulationUtil.getI18NString(context,
	          			"smaSimulation.StationGroupAddNoModify",
	                    "P1", 
	                    SimulationUtil.getObjectName(context, hostObj));
	        }	  
	    }
	    catch (Exception ex)
	    {	    	
            DomainObject hostObj = 
                    new DomainObject(groupID);

          	  sError = 
          		SimulationUtil.getI18NString(context,
          			"smaSimulation.StationGroupAddNoModify",
                    "P1", 
                    SimulationUtil.getObjectName(context, hostObj));
	    }
      	if (sError != null && sError.length() > 0)
     	{	        		
          	%>
  	       <script language="javascript">
  	    	alert("<%=sError%>");
		    doCancel('listHidden','null','null');
  	       </script>
  		   <%
     	 }
      	 else
      	 {
		    String stationIds = emxGetParameter(request, "stationIds");
			String[] methodargs = new String[] { groupID, stationIds};
			HashMap returnMap = null;
		    returnMap = (HashMap) JPO.invoke( context, 
	            "jpo.simulation.SimulationHostGroup", null, 
	            "addHosts", methodargs, HashMap.class);
		    if ( returnMap != null )
		    {
		        // Check for error
		        String action = (String) returnMap.get("Action");
		        if ( "STOP".equalsIgnoreCase(action) )
		        {
			        sError = (String) returnMap.get("Message");
			        emxNavErrorObject.addMessage(sError);
					%>
				    <script language="javascript">
				      alert("<%=sError%>");
				      doCancel('listHidden','null','null');
				    </script>
					<%
		        }
		        else
		        {
		    		String[] methodargs2 = 
		    				new String[] { stationIds,"true","true",serverName };
	    			HashMap<String, String> stationDataMap = null;
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
	    			        contentURL.append("&objectAction=pushToCosAddHost&objIdStr=")
	    			        	.append(stationIds);
	    					
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
	  		        		    doCancel('listHidden','null','null');
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
		}
	}
    // process adding hosts to the group 
    // this from the add hosts command from the station group page
    // where the user selected a group and got a multi select chooser 
    // to select the hosts to be added to the group
	else if ("addHostsToGroup".equalsIgnoreCase(objectAction))
	{
	    String objectId = null;
	    String[] objIds = null;
	    String[] parIds = null;
	    int nObjs = 0;
		final Enumeration paramNames=request.getParameterNames();
		HashMap paramMap = new HashMap();
            Enumeration params = request.getParameterNames();
            while (params.hasMoreElements())
            {
                String name = (String) params.nextElement();
                String value = emxGetParameter(request, name);
                paramMap.put(name,value);
			}
			String parentRowId = (String)paramMap.get("emxParentIds");
			matrix.util.StringList sList = null;
			sList = com.matrixone.apps.domain.util.FrameworkUtil.split(parentRowId,"|");
			if(sList.size() == 4){
			parentRowId = (String)sList.get(2);
			}
		String groupID = parentRowId;
	    /////////////////
	    // Get selected rows from the request map
	     String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");
	sList = com.matrixone.apps.domain.util.FrameworkUtil.split(sRowIds[0],"|");
	if(sList.size() == 3){
    sRowIds[0] = (String)sList.get(0);
    }else{
    sRowIds[0] = (String)sList.get(1);
    }

	    // sRowIds should never be null since these commands must have a
	    // selection single/multiple setting and are thus caught 
	    // by M1 if nothing is selected
	    if ( (sRowIds == null) || (sRowIds.length == 0) )
	    {
			emxNavErrorObject.addMessage(EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.PleaseSelectitem"));
		}
	    nObjs = sRowIds.length;
	    StringBuilder stationsStr = new StringBuilder();
	    for (int i = 0; i < nObjs;i++ )
	    {
		    // add try catch block for invalid password exception 
		    // when user does not have access
		    try
		    {
	            if ( ! AccessUtil.hasAccess(
	              		context, sRowIds[i], "fromconnect"))
	            {
	                DomainObject hostObj = 
	                        new DomainObject(sRowIds[i]);
	
	              	  sError = 
	              		SimulationUtil.getI18NString(context,
	              			"smaSimulation.StationGroupAddNoAccess",
	                        "P1", 
	                        SimulationUtil.getObjectName(context, hostObj));
	              	  break;
	            }	
		    }
		    catch (Exception ex)
		    {
                DomainObject hostObj = 
                        new DomainObject(sRowIds[i]);

              	  sError = 
              		SimulationUtil.getI18NString(context,
              			"smaSimulation.StationGroupAddNoAccess",
                        "P1", 
                        SimulationUtil.getObjectName(context, hostObj));
              	  break;		    	
		    }
      		stationsStr.append(sRowIds[i]).append('|');
	    }
	    // add try catch block for invalid password exception 
	    // when user does not have access
	    try
	    {
	        if ( ! AccessUtil.hasAccess(
	          		context, groupID, "modify"))
	        {
	            DomainObject hostObj = 
	                    new DomainObject(groupID);
	
	          	  sError = 
	          		SimulationUtil.getI18NString(context,
	          			"smaSimulation.StationGroupAddNoModify",
	                    "P1", 
	                    SimulationUtil.getObjectName(context, hostObj));
	        }	    
	    }
	    catch (Exception ex)
	    {
            DomainObject hostObj = 
                    new DomainObject(groupID);

          	  sError = 
          		SimulationUtil.getI18NString(context,
          			"smaSimulation.StationGroupAddNoModify",
                    "P1", 
                    SimulationUtil.getObjectName(context, hostObj));	    	
	    }
      	if (sError != null && sError.length() > 0)
     	{	        		
          	%>
  	       <script language="javascript">
  	    	alert("<%=sError%>");
		      getTopWindow().closeWindow();
  	       </script>
  		   <%
     	 }
      	 else
      	 {

			stationsStr.deleteCharAt(stationsStr.length()-1);
	
			String[] methodargs = new String[] {
					groupID, stationsStr.toString(),"false"};
			HashMap returnMap = null;
		    returnMap = (HashMap) JPO.invoke( context, 
	            "jpo.simulation.SimulationHostGroup", null, 
	            "addHosts", methodargs, HashMap.class);
		    if ( returnMap != null )
		    {
		        // Check for error
		        String action = (String) returnMap.get("Action");
		        if ( "STOP".equalsIgnoreCase(action) )
		        {
			        sError = (String) returnMap.get("Message");
			        emxNavErrorObject.addMessage(sError);
			        %>
			          <script language="javascript">
		                alert("<%=sError%>");
			           </script>
		            <%
		        }
		        else if ( "CONTINUE".equalsIgnoreCase(action) )
		        {
			        String msg = (String) returnMap.get("Message");
		    		String[] methodargs2 = 
		    				new String[] { stationsStr.toString(),"true","false",serverName };
	    			HashMap<String, String> stationDataMap = null;
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
	    			        contentURL.append("&objectAction=pushToCos&objIdStr=")
	    			        	.append(stationsStr.toString());
	    					
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
		    <script language="javascript">
		      getTopWindow().closeWindow();
		    </script>
			<%
      	 }
	} 
	else if ("refreshTable".equalsIgnoreCase(objectAction)) 
	{
%>
	    <script language="javascript">
	    	getTopWindow().refreshTablePage();
	    </script>
<%
	}
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
