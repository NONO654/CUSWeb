<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
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

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<html>
	<head>
	  <meta charset="utf-8" />
	</head>
	<body style="height:100%;width:100%;">
	
<%
        String locale = context.getSession().getLanguage();
		String sError = "";
		List<String> stationNoObjs = new ArrayList<String>();
		StringBuilder stationNoObjsStr = new StringBuilder();
		String objectAction = emxGetParameter(request, "objectAction");
		String serverName = emxGetParameter(request, "serverName");
		
	    String[] jpoargs = new String[1];
	    jpoargs[0] = serverName;
	    serverName =
			(String)JPO.invoke( context, 
	        "jpo.simulation.SimulationHost", null, 
	        "getCosServerName", jpoargs, String.class);
		String stationName = "dummy";
	    String cosError = SimulationUtil.getI18NString(context,
	        "Error.Station.COSError",
	        "smaSimulationCentralStringResource", locale);
	    String reqError = SimulationUtil.getI18NString(context,
	            "Error.Station.COSRequestError");

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
		// set content url to point to smaStationUpdate.jsp so the
		// query data can be used to update any host business objects.
		// Based on the action the jsp will either reset the href to 
		// emxTable.jsp to display the station or group data from the 
		// query. Or, it will create new stations using the station data
		// Or it will reset the href to emxTable.jsp with the work item
		// details. The data is past to the program jpo by using a post 
		// of a form containing the url and an argument set through 
		// jQuery for the station data xml returned by the web service 
		// call. 
        URLBuilder contentURL = new URLBuilder(
        	request.getRequestURI().length(),
        	request.getCharacterEncoding());
        contentURL.append("../simulationcentral/smaStationUpdate.jsp?");
        contentURL.append("locale=").appendEncoded(context,locale);
        if (null != serverName)
            contentURL.append("&serverName=").append(serverName);
        
        // get selected row information
		if ("createFromCOS".equalsIgnoreCase(objectAction) || 
				"wiDisplay".equalsIgnoreCase(objectAction))
		{
			
			int nObjs = 0;
			/////////////////
			// Get selected rows from the request
			String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");
			
			// check if row ids is null if not get row id info
			if ( (sRowIds != null))
			{
				// get the selected stations
				// stations will have an id in the form of
				// name|status.  If the id is not of this form
				// then an application row was selected and will be ingnored
				nObjs = sRowIds.length;
		        if (nObjs > 1 && "wiDisplay".equalsIgnoreCase(objectAction))
		        {
		  			sError = SimulationUtil.getI18NString(context,
		  					"Error.Station.PickOnlyOne");
					 %>
					   <script language="javascript">
					   alert("<%=sError%>");
					   closeWindow();
					   </script>
					<%
		            return;
		        }
				boolean wrongStationPicked = false;
			 	for (int i = 0; i < nObjs; i++)
			 	{
			    	String sRowId = sRowIds[i];
			    	
			    	// if we have a row id make sure it is in the form of
			    	// name|status
			    	if (null != sRowId && sRowId.length() > 0)
			    	{
			    		String [] rowInfo = sRowId.split( "\\|"); 
			    		
			    		// make sure we have a station name and status
			    		if (rowInfo != null && rowInfo.length == 2)
			    		{
			    			stationName = rowInfo[0];
			     			stationNoObjs.add(stationName);
			     			stationNoObjsStr.append(stationName).append('|');
			    		}
			    		// if more than two, also have oid
			    		if (rowInfo != null && rowInfo.length > 2 )
			    		{
			    			stationName = rowInfo[0];
							String oid = rowInfo[2];
							
							// we should not have oid when creating 
							// from cos
							if (!oid.isEmpty() && 
								"createFromCOS".equalsIgnoreCase(objectAction))
							{
								wrongStationPicked = true;
								break;
							}
							else
							{
				        		stationNoObjs.add(stationName);
				        		stationNoObjsStr.append(stationName).append('|');      					
							}
			    		}
			    		if (rowInfo != null && rowInfo.length > 3 )
			    		{
			    			// we should not create a private station
			    			if(!("fiper".equalsIgnoreCase(rowInfo[3]))&& 
								"createFromCOS".equalsIgnoreCase(objectAction))
			    			{
			    				wrongStationPicked = true;
			    				break;
			    			}
			    		}
			    	}
			    }
			    if (wrongStationPicked || stationNoObjs.size() == 0)
			    {
			  			sError = SimulationUtil.getI18NString(context,
			  					"Error.Station.Is.Selected");
				           %>
				   	       <script language="javascript">
				   	    	alert("<%=sError%>");
				   	    	getTopWindow().refreshTablePage();
				   	       </script>
				   		   <%
			    }
			    else
			    {
			    	stationNoObjsStr.deleteCharAt(stationNoObjsStr.length()-1);
		        	contentURL.append("&selectedStations=").append(stationNoObjsStr);
			    }
			}
			else 
			{
				// if no rows are selected and the action is wiDisplay
				// means we are comming from the refresh on the 
				// the work items popup and the station name is set
				// by the javascript method handling the refresh button
				if ("wiDisplay".equalsIgnoreCase(objectAction))
				{
	    			stationName = emxGetParameter(request, "stationName");
	     			stationNoObjs.add(stationName);
	     			stationNoObjsStr.append(stationName);
		        	contentURL.append("&selectedStations=").append(stationNoObjsStr);					
				}
			}
		}
		
		if (sError.length() == 0)
		{
		//  call a jpo method to get the EED url to use
		// for the station data query web service call
	        String[] args = new String[1];
	        args[0] = serverName;
			HashMap<String,String> eedInfo=
				(HashMap<String,String>)JPO.invoke( context, 
	            "jpo.simulation.SimulationHost", null, 
	            "getEEDData", args, HashMap.class);
	
	        StringBuffer eedURL =  new StringBuffer(); 
			String ticket = eedInfo.get("ticket");
			String infoUrl = eedInfo.get("eedURL");
			if (!infoUrl.endsWith("/"))
				infoUrl = infoUrl + "/";
	        if ("wiDisplay".equalsIgnoreCase(objectAction)) {
				// add path/query arguments for resuming a station
				eedURL.append(infoUrl).append("admin/station/")
					.append(stationNoObjs.get(0)).append("/displayWorkItems");
			} 
			else {
	        	eedURL.append(infoUrl)
	                .append("admin/station/query");
	        	if ("getStationGroups".equalsIgnoreCase(objectAction))
	        	{
	        		eedURL.append("?DRMMode=fiperGrp");
	        	}
		}
        
        // use java script to define the form holding the content url
        // so the station data can be past as a POST method since it
        // may be to long to pass in a GET method by setting the href
        
        // also make the web service call to get the station data in the
        // java script so it runs on the client not the server
%>
		
		<form style="display: hidden" action="<%=contentURL.toString()%>" method="POST" id="form">
		  <input type="hidden" id="stationData" name="stationData" value=""/>
		  <input type="hidden" id="objectAction" name="objectAction" value="<%=objectAction%>"/>
		  <input type="hidden" id="stationName" name="stationName" value="<%=stationName%>"/>
		</form>
		
		<script language="javascript">
		
        var dataStr = "";
        var eedURL1 =  "<%=eedURL.toString()%>";
        var ticket1 = "<%=ticket%>";
      	jQuery.ajax({ 
      		url : eedURL1,
      		type : "GET",
          	cache:false,
			beforeSend: function (request)
            {
                    request.setRequestHeader("EEDTicket", ticket1);
                    
            },
      		success : function(returndata, status, xhr) {
	           	dataStr = (new XMLSerializer()).serializeToString(returndata.documentElement);
                dataStr = dataStr.replace(/%/g,'*+*');
                dataStr = dataStr.replace(/</g,'&*LT*&');
                dataStr = dataStr.replace(/>/g,'&*GT*&');
    			// replace single quotes so javascript does not break
    			// use strange replacement string so can put single 
    			// quote back in jpo method
    			// note: need 2$$ for each $ to be replaced
          		dataStr = dataStr.replace(/'/g, "$$$$$$$$****");
          		dataStr = dataStr.replace(/"/g, '%%%%####');
	            $("#stationData").val(dataStr);
	   			$("#form").submit();
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
                 {
                	 alert ("<%=reqError%>");	
                 }
 	             $("#stationData").val("");
	   			 $("#form").submit();
      		}
      	});
		
		</script>
		<%
		}
		%>
		
	</body>
</html>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
