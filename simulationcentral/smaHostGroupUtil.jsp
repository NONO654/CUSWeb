<%-- (c) Dassault Systemes, 2014 --%>
<%--
  Actions for host groups
--%>

<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil" %>
<%@page import="com.matrixone.apps.domain.util.CacheUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
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
  // deleteHostGroupApplications-delete apps from group and related host
  // deleteHostSharedDrives - delete shared drives from group & related host
  // addHosts-add a host to a group brings up dialog with combo box to pick group
  // removeHosts-removes the host from the group
  // pushToCos - send station data to the EED continue jsp will call
  //             JPO method to mark sync if all went well
  // deleteHost - deletes host business object
  // deleteGroup - deletes host group business object

  String objectAction = emxGetParameter(request, "objectAction");
	String serverName = emxGetParameter(request, "serverName");
	
    String[] jpoargs = new String[1];
    jpoargs[0] = serverName;
    serverName =
		(String)JPO.invoke( context, 
        "jpo.simulation.SimulationHost", null, 
        "getCosServerName", jpoargs, String.class);

    String objId = emxGetParameter(request, "objectId");
  String locale = context.getSession().getLanguage();
  String sError = "";
  List<String> stationObjs = new ArrayList<String>();
  List<String> stationNoObjs = new ArrayList<String>();
  List<String> objIds = new ArrayList<String>();
  List<String> objModes = new ArrayList<String>();
  StringBuilder stationObjsStr = new StringBuilder();
  StringBuilder stationNoObjsStr = new StringBuilder();
  StringBuilder objIdStr = new StringBuilder();
        
  String cosError = SimulationUtil.getI18NString(context,
          "Error.Station.COSError");

  String reqError = SimulationUtil.getI18NString(context,
          "Error.Station.COSRequestError");

  // sanity check should never happen
    if ( (objectAction == null) || (objectAction.equals(""))  )
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
    if(objectAction.equalsIgnoreCase("applyAccess"))
	{
        String strObjId = emxGetParameter(request, "objectId");
        System.out.println("OID: " + strObjId);
        String[] args = new String[1];
        args[0] = strObjId;
        // invoke jpo to apply access from host group
        // to all the related hosts
        try
        {
	        JPO.invoke(context,
	            "jpo.simulation.SimulationHostGroup", null,
	            "applyAccess", args);
        	String accessMsg = SimulationUtil.getI18NString(context,
  					"smaSimulationCentral.StationGroup.AccessApplied");
	           %>
	   	       <script language="javascript">
	   	    	alert("<%=accessMsg%>");
	   	       </script>
	   		   <%
        }
        catch (Exception ex)
        {
        	String errorMsg = ex.getMessage();
	           %>
	   	       <script language="javascript">
	   	    	alert("<%=errorMsg%>");
	   	       </script>
	   		   <%
        }  	      
        return;
	}  
    if(objectAction.equalsIgnoreCase("deleteHostGroupApplications"))
	  {
       String sRowIds[] = request.getParameterValues("emxTableRowId");
       String strObjId = emxGetParameter(request, "objectId");
       String parentOid = null;
       // get selected application rows
       if (sRowIds != null && sRowIds.length != 0)
       {
          parentOid = strObjId;
          strObjId = null;
       }
       String[] args = new String[2];
       
       // set up jpo args which include host oid and
       // "|" separated list of application row ids
       args[0] = parentOid;
       String rowsToDelete = "";
       for (int k=0; k<sRowIds.length; k++)
       {
           rowsToDelete = rowsToDelete + sRowIds[k] + "|";
       }
       
       // removing trailing "|"
       args[1] = 
           rowsToDelete.substring(0,rowsToDelete.length() - 1);
       
       // invoke jpo to delete applications from host group
       // and any related hosts
       JPO.invoke(context,
           "jpo.simulation.SimulationHostGroup", null,
           "deleteApplications", args, Boolean.class);
       // refresh the table after the delete
  %>
  	      <script language="javascript">
          if ( getTopWindow().refreshTablePage )
          {
              getTopWindow().refreshTablePage();
          }
  	      </script>
  <%
  	      return;
	  }
    if(objectAction.equalsIgnoreCase("deleteHostSharedDrives"))
	{
       String sRowIds[] = request.getParameterValues("emxTableRowId");
       String strObjId = emxGetParameter(request, "objectId");
       String parentOid = null;
       // get selected application rows
       if (sRowIds != null && sRowIds.length != 0)
       {
          parentOid = strObjId;
          strObjId = null;
       }
       String[] args = new String[2];
       
       // set up jpo args which include host oid and
       // "|" separated list of application row ids
       args[0] = parentOid;
       String rowsToDelete = "";
       for (int k=0; k<sRowIds.length; k++)
       {
           rowsToDelete = rowsToDelete + sRowIds[k] + "|";
       }
       
       // removing trailing "|"
       args[1] = 
           rowsToDelete.substring(0,rowsToDelete.length() - 1);
       
       // invoke jpo to delete applications from host group
       // and any related hosts
       JPO.invoke(context,
           "jpo.simulation.SimulationHostGroup", null,
           "deleteSharedDrives", args, Boolean.class);
       // refresh the table after the delete
  %>
  	      <script language="javascript">
          if ( getTopWindow().refreshTablePage )
          {
              getTopWindow().refreshTablePage();
          }
  	      </script>
  <%
  	      return;
	}
      int nObjs = 0;
      /////////////////
      // Get selected rows from the request
      String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");
  
      // check if row ids is null if not get row id info
      // pushToCos does not need a selected row
      if ( (sRowIds != null))
      {
      	// get the selected stations
      	// stations will have an id in the form of
      	// name|status.  If the id is not of this form
      	// then an application row was selected and will be ingnored
      	nObjs = sRowIds.length;
       	for (int i = 0; i < nObjs; i++)
       	{
          	String sRowId = sRowIds[i];
          	
          	// if we have an id make sure it is in the form of
          	// name|status
          	if (null != sRowId && sRowId.length() > 0)
          	{
          		String [] rowInfo = sRowId.split( "\\|"); 
          		
          		// make sure we have a station name and status
          		if (rowInfo != null && rowInfo.length == 2)
          		{
          			String stationName = rowInfo[0];
  	        		stationNoObjs.add(stationName);
  	        		stationNoObjsStr.append(stationName).append('|');
          		}
          		if (rowInfo != null && rowInfo.length > 2 )
          		{
          			String stationName = rowInfo[0];
      				String oid = rowInfo[2];
      				if (!oid.isEmpty())
      				{
	  	        		stationObjs.add(stationName);
	  	        		stationObjsStr.append(stationName).append('|');
		        		objIds.add(oid);
		        		objIdStr.append(oid).append('|');
      				}
      				else
      				{
      	        		stationNoObjs.add(stationName);
      	        		stationNoObjsStr.append(stationName).append('|');      					
      				}
          		}
          		if (rowInfo != null && rowInfo.length > 3 )
          		{
          			objModes.add(rowInfo[3]);
          		}
          	}
        }
          
      }
      if ("pushToCos".equalsIgnoreCase(objectAction))
      {
    	  // get any selected stations
    	  String stationArg = "";
	      if (stationNoObjs.size() > 0 || stationObjs.size() == 0)
	      {
	  			sError = SimulationUtil.getI18NString(context,
	  					"Error.Station.Not.Selected");
	  			emxNavErrorObject.addMessage(sError);
	      }
	      else
	      {
	    	
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
		                        "P1", stationObjs.get(i));
		              	  break;
		              }	
	    		  }
	    		  catch (Exception ex)
	    		  {
	              	  sError = 
	              		SimulationUtil.getI18NString(context,
	              			"smaSimulation.StationNoModify",
	                        "P1", stationObjs.get(i));
	              	  break;	    			  
	    		  }
	    	 }
	       	 if (sError != null && sError.length() > 0)
	      	 {	        		
	           %>
	   	       <script language="javascript">
	   	    	alert("<%=sError%>");
	   	       </script>
	   		   <%
	      	 }
	         else
	         {
    		   objIdStr.deleteCharAt(objIdStr.length()-1);
    		   stationArg = objIdStr.toString();
	  		   String[] methodargs = new String[] { stationArg,"true","false",serverName };
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
			  	    stationObjsStr.deleteCharAt(stationObjsStr.length()-1);
			        URLBuilder contentURL = new URLBuilder(
			        	request.getRequestURI().length(),
			        	request.getCharacterEncoding());
			        contentURL.append(
			        	"../simulationcentral/smaHostGroupUtilContinue.jsp?");
			        contentURL.append("locale=").appendEncoded(context,locale);
			        contentURL.append("&objectAction=pushToCos&objIdStr=")
			        	.append(stationArg);
					
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
					  <input type="hidden" id="serverName" name="serverName" value="<%=serverName%>"/>
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
	              		}
	              	});
					</script>
					<%
			   }
	         }
	      }
      }
      else if ("addHosts".equalsIgnoreCase(objectAction) || 
    		  "removeHosts".equalsIgnoreCase(objectAction))
      {
	      // If we have not selected any appropriate stations indicate 
	      // error.  Any selected application rows are skipped
	      if (stationNoObjs.size() > 0  || stationObjs.size() == 0)
	      {
	  			sError = SimulationUtil.getI18NString(context,
	  					"Error.Station.Not.Selected");
	  			emxNavErrorObject.addMessage(sError);
	      }
	      else
	      {
	    	
	    	 for (int i=0; i < objIds.size(); i++)
	    	 {
	    		  String reqAccess = "fromconnect";
	    		  if ("removeHosts".equalsIgnoreCase(objectAction))
	    			  reqAccess = "fromdisconnect";
	    		  // add try catch block for invalid password exception 
	    		  // when user does not have access
	    		  try
	    		  {
		              if ( ! AccessUtil.hasAccess(
		              		context, objIds.get(i), reqAccess))
		              {
		              	  sError = 
		              		SimulationUtil.getI18NString(context,
		              			"smaSimulation.StationGroupAddNoAccess",
		                        "P1", stationObjs.get(i));
		              	  break;
		              }	 
	    		  }
	    		  catch (Exception ex)
	    		  {
	              	  sError = 
	              		SimulationUtil.getI18NString(context,
	              			"smaSimulation.StationGroupAddNoAccess",
	                        "P1", stationObjs.get(i));
	              	  break;
	              }	 	    			  
	    	 }
	       	 if (sError != null && sError.length() > 0)
	      	 {	        		
	           %>
	   	       <script language="javascript">
	   	    	alert("<%=sError%>");
	   	       </script>
	   		   <%
	      	 }
	       	 else
	       	 {
		    	 stationObjsStr.deleteCharAt(stationObjsStr.length()-1);
		  	     if ("addHosts".equalsIgnoreCase(objectAction))
		  	     {
		  		    StringBuilder contentURL = new StringBuilder(175);
		  		    contentURL
		  			    .append("../common/emxForm.jsp")
		  			    .append("?form=SMAHostGroup_Select")
		  			    .append("&objectBased=false")
		  			    .append("&mode=edit")
		                .append("&formHeader=smaSimulationCentral.HostGroup.Select")
		  			    .append("&stationIds=").append(stationObjsStr)
		  			    .append("&HelpMarker=SMAHostGroup_Select")
		  			    .append("&suiteKey=SimulationCentral")
		  			    .append("&submitAction=doNothing")
		  			    .append("&targetLocation=listHidden")
		  	            .append("&postProcessURL=../simulationcentral/smaHostGroupAddHosts.jsp?objectAction=addHosts");
		  		    %>
		  			<script language="javascript">
		              showModalDialog("<%=contentURL.toString()%>", 350, 250, false)
		  
		  			</script>
		  			<%
		  	     }
		         else if ("removeHosts".equalsIgnoreCase(objectAction))
		         {
		  		    String[] methodargs = new String[] { stationObjsStr.toString() };
		  		    JPO.invoke( context, 
		              "jpo.simulation.SimulationHostGroup", null, 
		              "disconnectHostsFromGroup", methodargs);
		 			HashMap requestMap = 
			 			UINavigatorUtil.getRequestParameterMap(pageContext);
			 		String href = SlmUIUtil.getCommandHref(context,
			 			"SMAStationList", null, null, requestMap);
		  		    %>
		  	        <script language="javascript">
		      		var frame = null;  
			      	frame = findFrame(getTopWindow(),"SMAStationList"); 
			      	if (frame) 
			      	{
			        	frame.location.href = "<%=href%>";
			      	}
		  	        </script>
		  		    <%
		         }
		      }
	      }
      }
      else if ("groupRemoveHosts".equalsIgnoreCase(objectAction))
      {
	      // If we have not selected any appropriate stations indicate 
	      // error.  Any selected application rows are skipped
	      if (stationNoObjs.size() > 0  || stationObjs.size() == 0)
	      {
	  			sError = SimulationUtil.getI18NString(context,
	  					"Error.Station.Not.Selected");
	  			emxNavErrorObject.addMessage(sError);
	      }
	      else
	      {
	    	
	    	 for (int i=0; i < objIds.size(); i++)
	    	 {
	    		  String reqAccess = "fromdisconnect";
	    		  // add try catch block for invalid password exception 
	    		  // when user does not have access
	    		  try
	    		  {
		              if ( ! AccessUtil.hasAccess(
		              		context, objIds.get(i), reqAccess))
		              {
		              	  sError = 
		              		SimulationUtil.getI18NString(context,
		              			"smaSimulation.StationGroupAddNoAccess",
		                        "P1", stationObjs.get(i));
		              	  break;
		              }	    	
	    		  }
	    		  catch (Exception ex)
	    		  {
	              	  sError = 
	              		SimulationUtil.getI18NString(context,
	              			"smaSimulation.StationGroupAddNoAccess",
	                        "P1", stationObjs.get(i));
	              	  break;	    			  
	    		  }
	    	 }
	       	 if (sError != null && sError.length() > 0)
	      	 {	        		
	           %>
	   	       <script language="javascript">
	   	    	alert("<%=sError%>");
	   	       </script>
	   		   <%
	      	 }
	       	 else
	       	 {
		    	stationObjsStr.deleteCharAt(stationObjsStr.length()-1);
	  		    String[] methodargs = new String[] { stationObjsStr.toString() };
	  		    JPO.invoke( context, 
	              "jpo.simulation.SimulationHostGroup", null, 
	              "disconnectHostsFromGroup", methodargs);
	  		    %>
	  	        <script language="javascript">
	               getTopWindow().refreshTablePage();
	  	        </script>
	  		    <%
	       	 }
	      }
      }
      else if ("deleteHosts".equalsIgnoreCase(objectAction) ||
    		  "deleteGroup".equalsIgnoreCase(objectAction))
      {
      	// delete the business object if an object selected
		HashMap requestMap = 
			UINavigatorUtil.getRequestParameterMap(pageContext);
    	String href = SlmUIUtil.getCommandHref(context,
	        "SMAStationList", null, null, requestMap);
    	String channelCmd = "SMAStationList";
    	String drmMode = "fiper";
    	if ("deleteGroup".equalsIgnoreCase(objectAction))
       	{
	    	href = SlmUIUtil.getCommandHref(context,
			    "SMAStationAdmin_ShowHostGroups", 
			    null, null, requestMap);
	    	channelCmd = "SMAStationAdmin_ShowHostGroups";
	    	drmMode = "fiperGrp";
       	}
      	if ( objIds.size() > 0)
      	{
	    	 for (int i=0; i < objIds.size(); i++)
      		 {
	    		  // add try catch block for invalid password exception 
	    		  // when user does not have access
	    		  try
	    		  {
		              if ( ! AccessUtil.hasAccess(
		            		context, objIds.get(i), "delete") )
		              {
		              	  sError = 
		              		SimulationUtil.getI18NString(context,
		              			"smaSimulation.DeleteStationNoAccess",
		                        "P1", stationObjs.get(i));
		            	  if ("deleteGroup".equalsIgnoreCase(objectAction))
		                	  sError = 
		      	              		SimulationUtil.getI18NString(context,
		      		              			"smaSimulation.DeleteStationGroupNoAccess",
		      		                        "P1", stationObjs.get(i));
		              }
	    		  }
	    		  catch (Exception ex)
	    		  {
	              	  sError = 
	              		SimulationUtil.getI18NString(context,
	              			"smaSimulation.DeleteStationNoAccess",
	                        "P1", stationObjs.get(i));
	            	  if ("deleteGroup".equalsIgnoreCase(objectAction))
	                	  sError = 
	      	              		SimulationUtil.getI18NString(context,
	      		              			"smaSimulation.DeleteStationGroupNoAccess",
	      		                        "P1", stationObjs.get(i));	    			  
	    		  }
      		  }
              if (sError == null || sError.length() == 0)
              {
            	    String[] oidsToDelete = new String[objIds.size()];
            	    oidsToDelete = objIds.toArray(oidsToDelete);			      	try
			      	{
			           SlmUIUtil.removeTOCReferences(
			               	context, oidsToDelete, true);
			      	}
			      	catch (Exception ex)
			      	{
			              sError = ex.getMessage();
			      	}
              }
      	}
      	if (sError != null && sError.length() > 0)
      	{	        		
           %>
   	    <script language="javascript">
   	    	alert("<%=sError%>");
   	    </script>
   		<%
      	}
      	else if (stationObjs.size() > 0 || stationNoObjs.size() > 0)
      	{
      	    String[] args = new String[1];
      	    args[0] = serverName;
      		HashMap<String,String> eedInfo=
      			(HashMap<String,String>)JPO.invoke( context, 
      	        "jpo.simulation.SimulationHost", null, 
      	        "getEEDData", args, HashMap.class);


			String ticket = 
					eedInfo.get("ticket");
			String infoUrl = 
					eedInfo.get("eedURL");
			if (!infoUrl.endsWith("/"))
				infoUrl = infoUrl + "/";
			StringBuffer eedURL = new StringBuffer();
			eedURL.append(infoUrl).append(
					"admin/station/");
			int i = 0;
			for (String station : stationObjs) {
				if (i == 0) {
					eedURL.append("?stationName=").append(station);
				} else {
					eedURL.append("&stationName=").append(station);
				}
				i++;
			}
			for (String station : stationNoObjs) {
				if (i == 0) {
					eedURL.append("?stationName=").append(station);
				} else {
					eedURL.append("&stationName=").append(station);
				}
				i++;
			}
			eedURL.append("&DRMMode=").append(drmMode);
           %>
   	    	<script language="javascript">
              var dataStr = "";
              jQuery.ajax(
                  {
                      url : "<%=eedURL.toString()%>",
                      type : "DELETE",
                      cache:false,
                      beforeSend: function(request)
                      {
                          var ticketString = "<%=ticket%>";
                          request.setRequestHeader("EEDTicket", ticketString);
                      },
                      success : function(returndata,status,xhr)
                      {       
                    	dataStr = returndata;
    		            if (dataStr != null && dataStr.length > 0)
    		            {
                    		alert(returndata);
    		            }
      			      	var frame = null;  
      			      	frame = findFrame(getTopWindow(),"<%=channelCmd%>"); 
      			      	if (frame) 
      			      	{
      			        	frame.location.href = "<%=href%>";
      			      	}
                      },
                      error :  function( jqXHR, textStatus, errorThrown)
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
      			      	var frame = null;  
      			      	frame = findFrame(getTopWindow(),"<%=channelCmd%>"); 
      			      	if (frame) 
      			      	{
      			        	frame.location.href = "<%=href%>";
      			      	}
                      }
                  }
              );
   	    
   	    	</script>
   		<%
      	}
    }
    else if ("exportToXml".equalsIgnoreCase(objectAction))
    {
      	if (stationNoObjs.size() > 0 || stationObjs.size() == 0)
      	{
	  		sError = SimulationUtil.getI18NString(context,
	  			"Error.Station.Not.Selected");
	  		emxNavErrorObject.addMessage(sError);      			
      	}
  		else
  		{
      	  // get any selected stations
      	  String stationArg = "";
      	  if (stationObjs.size() > 0)
      	  {
      		  objIdStr.deleteCharAt(objIdStr.length()-1);
      		  stationArg = objIdStr.toString();
  	          URLBuilder contentURL1 = getURLBuilder(request);
  			  contentURL1.append("../simulationcentral/smaExportFileUtil.jsp?")
  			        .append("objectId=").append(stationArg)
  			        .append("&objectAction=").append("hostExport");
  			  %>
  				<script language="javascript">
  				getTopWindow().location.href = "<%=contentURL1.toString()%>";
  				</script>
  			  <%
      	  }
  		}
    }
    else if ("removeServer".equalsIgnoreCase(objectAction) )
    {
	      	// call method that will remove server from tenant page
			HashMap requestMap = 
				UINavigatorUtil.getRequestParameterMap(pageContext);
	      	
	      	// find the command to reload the list once the server is removed
	    	String href = SlmUIUtil.getCommandHref(context,
		        "SMACOSServer_Details", null, null, requestMap);
	      	if ( stationNoObjs.size() > 0)
	      	{
		    	stationNoObjsStr.deleteCharAt(stationNoObjsStr.length()-1);
		    	{
		            String[] args = new String[] { stationNoObjsStr.toString() };
		            try
		            {
						JPO.invoke(context, "jpo.simulation.SimulationHost",
							null, "removeServer", args, null);
			
						String user = context.getUser();
						user = user.replaceAll(" ", "_");
					 	CacheUtil.setCacheObject(context, SimulationConstants.COS_SERVER_NAME+user, 
					 			"");
			           %>
			   	    	<script language="javascript">
			 			    var frame = null;  
			 			    frame = findFrame(getTopWindow(),"content"); 
			 			    if (frame) 
			 			    {
			 			       frame.location.href = "<%=href%>";
			 			    }
			   	    	</script>
			   		  <%
		            }
		            catch (Exception ex)
		            {
		            	sError = ex.getLocalizedMessage();
			  	        emxNavErrorObject.addMessage(
				  	        	ErrorUtil.getMessage(ex, false));
		 	           %>
		 	   	       <script language="javascript">
		 	   	    	alert("<%=sError%>");
		 	   	       </script>
		 	   		   <%
		            }
		      	}
	      	}
      }
      else if ("setDefaultServer".equalsIgnoreCase(objectAction) )
      {
      	// call method that will remove server from tenant page
		HashMap requestMap = 
			UINavigatorUtil.getRequestParameterMap(pageContext);
      	
      	// find the command to reload the list once the server is removed
    	String href = SlmUIUtil.getCommandHref(context,
	        "SMACOSServer_Details", null, null, requestMap);
      	if ( stationNoObjs.size() > 0)
      	{
	       stationNoObjsStr.deleteCharAt(stationNoObjsStr.length()-1);
    	   
    	   // set default server in cache so it can be retrieved in plm services
    	   PropertyUtil.setAdminProperty(
                	context, null, null, SimulationConstants.COS_SERVER_DEFAULT, stationNoObjsStr.toString());

           %>
   	    	<script language="javascript">
 			    var frame = null;  
 			    frame = findFrame(getTopWindow(),"content"); 
 			    if (frame) 
 			    {
 			       frame.location.href = "<%=href%>";
 			    }
   	    	</script>
   		  <%
      	}
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
