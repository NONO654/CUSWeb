<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<html>
	<head>
	  <meta charset="utf-8" />
	</head>
	<body style="height:100%;width:100%;">
	
		<%
		
	    String stationData = emxGetParameter(request, "stationData");
		String objectAction = emxGetParameter(request, "objectAction");
		String serverName = emxGetParameter(request, "serverName");
		StringBuffer contentURL =  new StringBuffer(); 
		String contentStr = "";
	    String sError = "";

		// set content url to point to emxTable and set the program jpo
		// to the method to get the maplist for station or group rows 
		// the station data was past in to the jsp and is passed
		// to the table jsp as part of the url

		if ("getStations".equalsIgnoreCase(objectAction))
		{
			// update station data from COS
			String[] methodargs = new String[] { stationData };
			try
			{
			    String retVal = JPO.invoke( context, 
			        "jpo.simulation.SimulationHost", null, 
			        "updateStations", methodargs, String.class);
			    if (retVal != null && retVal.length() > 0)
			    {
					%>
				    <script language="javascript">
				      alert("<%=retVal%>");
				    </script>
					<%			    	
			    }
			}
			catch (Exception ex)
			{
				sError = ErrorUtil.getMessage(ex, false);
			    emxNavErrorObject.addMessage(sError);
			} 

			contentURL.append("../common/emxTable.jsp?")
	           .append("program=jpo.simulation.SimulationHost:getStationList")
	           .append("&table=SMAStation_ApplicationData")
	           .append("&objectAction=").append(objectAction)
	           .append("&header=smaSimulationCentral.Station.Data.PageHeading")
	           .append("&showTabHeader=false&portalMode=true")
	           .append("&Export=false&showRMB=false")
	           .append("&PrinterFriendly=false")
	           .append("&showClipboard=false&multiColumnSort=false")
	           .append("&objectCompare=false")
	           .append("&disableSorting=true")
	           .append("&selection=multiple")
            	.append("&toolbar=SMAStations_Toolbar")
	           .append("&HelpMarker=SMAStation_ApplicationListView")
	           .append("&suiteKey=SimulationCentral")
	           .append("&massUpdate=false");
			if (null != serverName && serverName.length() > 0)
				contentURL.append("&serverName=").append(serverName);
		}
		else if ("getStationGroups".equalsIgnoreCase(objectAction))
		{
			// show station groups
			contentURL.append("../common/emxTable.jsp?")
	           .append("program=jpo.simulation.SimulationHostGroup:getHostGroupTableList")
	           .append("&table=SMAHostGroup_List")
	           .append("&objectAction=").append(objectAction)
	           .append("&header=smaSimulationCentral.HostGroups.Name")
	           .append("&showTabHeader=false&portalMode=true")
	           .append("&Export=false")
	           .append("&showRMB=false")
	           .append("&PrinterFriendly=false")
	           .append("&showClipboard=false")
	           .append("&objectCompare=false")
	           .append("&disableSorting=true")
	           .append("&selection=multiple")
         		.append("&toolbar=SMAHostGroups_ListToolbar")
	           .append("&HelpMarker=SMAStationAdmin_ShowHostGroups")
	           .append("&suiteKey=SimulationCentral")
	           .append("&massUpdate=false");
			if (null != serverName && serverName.length() > 0)
				contentURL.append("&serverName=").append(serverName);
			
		}
		else if ("createFromCOS".equalsIgnoreCase(objectAction))
		{
			String selectedStations = 
				emxGetParameter(request, "selectedStations");
			// update station data from COS
			String[] methodargs = new String[] 
					{ stationData,selectedStations };
			try
			{
				sError =JPO.invoke( context, 
			        "jpo.simulation.SimulationHost", null, 
			        "createStationsFromCOS", methodargs, String.class);
			    if (sError != null && sError.length() > 0)
			    {
			    	// remove OIDs from message since creating object from cos
			    	// so don't need oids for a push to cos
                    String [] hostInfo = sError.split(":::");
                    sError = hostInfo[0];
					%>
				    <script language="javascript">
				      alert("<%=sError%>");
				    </script>
					<%			    	
			    }
		        sError = "";		    	
			}
			catch (Exception ex)
			{
				sError = ErrorUtil.getMessage(ex, false);
			    emxNavErrorObject.addMessage(sError);
			} 
			contentURL.append("../common/emxTable.jsp?")
	           .append("program=jpo.simulation.SimulationHost:getStationList")
	           .append("&table=SMAStation_ApplicationData")
	           .append("&objectAction=getStations")
	           .append("&header=smaSimulationCentral.Station.Data.PageHeading")
	           .append("&showTabHeader=false&portalMode=true")
	           .append("&Export=false")
	           .append("&PrinterFriendly=false")
	           .append("&showClipboard=false")
	           .append("&objectCompare=false")
	           .append("&disableSorting=true")
	           .append("&selection=multiple")
         	   .append("&toolbar=SMAStations_Toolbar")
	           .append("&HelpMarker=SMAStation_ApplicationListView")
	           .append("&suiteKey=SimulationCentral")
	           .append("&massUpdate=false");
		}
		else if ("wiDisplay".equalsIgnoreCase(objectAction))
		{
			String stationName = emxGetParameter(request, "stationName");
			String header =  SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Station.WorkItemHeader",
                "P1", stationName);

			// show station groups
			contentURL.append("../common/emxTable.jsp?")
	           .append("program=jpo.simulation.SimulationHost:getWorkItemList")
	           .append("&table=SMAStation_WorkItemData")
	           .append("&objectAction=").append(objectAction)
	           .append("&header=").append(header)
	           .append("&Export=false")
               .append("&toolbar=SMAStationAdmin_WorkItemsToolbar")
	           .append("&showRMB=false")
	           .append("&PrinterFriendly=false")
	           .append("&showClipboard=false")
	           .append("&objectCompare=false")
	           .append("&disableSorting=true")
	           .append("&selection=none")
	           .append("&HelpMarker=SMAStation_WorkItemData")
	           .append("&suiteKey=SimulationCentral")
	           .append("&massUpdate=false");
		}
				
		if (sError != null && sError.length() == 0)
		{
			contentStr = contentURL.toString();
			
			%>		
		<form style="display: hidden"  action='<%=contentStr%>' method="POST" id="form2">
		  <input type="hidden" id="stationData" name="stationData" value='<%=stationData%>'/>
		</form>
			<script language="javascript">
                objForm = document.forms["form2"];
                objForm.submit();
			</script>
		<%
		}
		%>		
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
	</body>
</html>
