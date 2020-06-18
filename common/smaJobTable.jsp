<%--
  (c) Dassault Systemes, 2007, 2008

  smaJobTable extended emxTable to update the table content at some specified
  some specified interval based on the refresh data of the job. 
--%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Calendar"%>

<%@include file = "emxNavigatorInclude.inc"%>

<%-- Include the emxTable --%>
<jsp:include page="emxIndentedTable.jsp" flush="false"/>

<script language="JavaScript" src="scripts/emxUITableUtil.js"
 type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUICore.js"
 type="text/javascript"></script>

<%
    int    iRefreshProperty	= -1;
    int    iRefreshRate  = -1;
    int    iWaitAmount  = 150000;

    String scResource    = "smaSimulationCentralStringResource";
    String scStatus      = null;
    String scRefreshInfo = null;
    String scObjectID    = emxGetParameter(request, "objectId");
    String scRunType     = emxGetParameter(request, "runType");
    long timeStart = Calendar.getInstance().getTimeInMillis();

    //
    // - Job Status values
    //

    final String RUNNING    = SimulationConstants.JOB_STATUS_RUNNING;
    final String PAUSED     = SimulationConstants.JOB_STATUS_PAUSED;
    final String NOTSTARTED = SimulationConstants.JOB_STATUS_NOTSTARTED;
    try
    {
        //
        // - Get the refresh data  of the SIMULATION. 
        //   This data returned is based on the runType
        //   either Simulation or Simulation Activity.
        //   For a simulation it will include status,
        //   job start and end, and current activity.
        //   For an activity it will include status,
        //   activity start and end, and current step.
        //
        //   The data is returned based on the latest job. 
        //   This might not be a valid assumption. 
        //   There should be a method to return overall
        //   status for the SIMULATION - Naresh.
        //

        String [] azArg    = {scObjectID,scRunType};
        scRefreshInfo = (String)JPO.invoke(
                         context, "jpo.simulation.SIMULATIONS",
                         null, "getRefreshData", azArg, String.class);

        //
        // Depending on the runType the refresh data will imply
        // the following.
        //
        // Activity:   Status|StartTime|EndTime|CurrentStep
        // Simulation: Status|StartTime|EndTime|ActivityName
        // 
        // - Split the string using "|" as delimiter
        // - Remember the status information
        //
        String[] ascRefreshInfo = scRefreshInfo.split("\\|", -1);
        //-- read the javadoc to understand the use of -1. 
        //-- This ensures that split() returns 4 elements.
        //-- status is the first item returned for either runType

        scStatus = ascRefreshInfo[0];
        if ( RUNNING.equals(scStatus) || PAUSED.equals(scStatus)
			|| NOTSTARTED.equals(scStatus))
        {
            //
            // The job is NOT STARTED Or RUNNING or Paused. This implies 
            // that the columns in the table have to be updated.
            //

            //
            // - Get the job page refresh rate from the properties file
            //
            String scRefreshRate = SimulationUtil.getProperty(context,
                                     "smaSimulationCentral.JobPage" +
                                     ".RefreshRate");
            if ( scRefreshRate != null &&
                 scRefreshRate.length() > 0 )
            {
                iRefreshRate = Integer.parseInt(scRefreshRate);
                iRefreshProperty = iRefreshRate;
            }

            if (NOTSTARTED.equals(scStatus))
            {
                if (iRefreshRate > 5000 ) iRefreshRate = 5000;
            }
            
            String scWait = SimulationUtil.getProperty(context,
                "smaSimulationCentral.JobPage" +
                ".WaitAmount");
            if ( scWait != null && scWait.length() > 0 )
            {
                iWaitAmount = Integer.parseInt(scWait);
            }

        } // If PAUSED Or RUNNING or NOTSTARTED

    } // try
    catch( Exception zExcept )
    {
        iRefreshRate = -1;
	    iWaitAmount  = 150000;
    }
%>

<script language="JavaScript">
//!
//! - Create global script variables
//!
var iIntervalID      = -1;
var iRefreshInterval = <%=iRefreshRate%>;
var scRefresh_Orig   = "<%=scRefreshInfo%>";
var origTime   = "<%=timeStart%>";
var waitAmount = <%=iWaitAmount%>;
var scURL            = "smaJobGetRefreshData.jsp" +
                       "?objectId=<%=scObjectID%>" +
                       "&runType=<%=scRunType%>";


var scRUNNING    = "<%=RUNNING%>";
var scPAUSED     = "<%=PAUSED%>";
var scNOTSTARTED = "<%=NOTSTARTED%>";


//!
//! Function to refresh the table content based on refresh data.
//!
function refreshTableData()
{
    //!
    //! - Append random number as a work around to force the processing
    //!   of the request. If the URL is not different the browser
    //!   returns the cached response.
    //!
    var scURL_Lcl = scURL + "&random=" + Math.random();

    //!
    //! - Send the request and get back the response. The returned
    //!   response has white space characters which have to be
    //!   trimmed to get the actual refresh data string.
    //!
    var scRefresh_Lcl = emxUICore.getData(scURL_Lcl);
    var diffT = 0;
    scRefresh_Lcl = scRefresh_Lcl.replace(/^\s*/, "").replace(/\s*$/, "");
    if (scRefresh_Lcl.length > 0)
    {
        var dataArr = scRefresh_Lcl.split('###');
        if (dataArr.length > 1)
        {
            scRefresh_Lcl = dataArr[0];
            var newTime = dataArr[1];
            var origT = origTime.valueOf() ;
            var newT = newTime.valueOf() ;
            diffT = newT - origTime;
        }
    }
    if ( scRefresh_Lcl != null )
    {
        //!
        //! Reset refresh interval once job starts running
        //!
		if (scRefresh_Lcl.indexOf(scPAUSED )== 0  ||
			scRefresh_Lcl.indexOf(scRUNNING )== 0  )
		{
			if (iRefreshInterval < <%=iRefreshProperty%>)
			{
				iRefreshInterval = <%=iRefreshProperty%>;
				if ( iIntervalID != -1 )
				{
					self.clearInterval(iIntervalID);
				}
				iIntervalID = 
					self.setInterval("refreshTableData()", iRefreshInterval);
			}
		}
        // if have not started and passed the wait amount
        // clear the interval
        if (scRefresh_Lcl.indexOf(scNOTSTARTED )== 0  &&
            diffT > waitAmount)
        {
            if ( iIntervalID != -1 )
            {
                self.clearInterval(iIntervalID);
            }
        }
        
        if ( scRefresh_Lcl != scRefresh_Orig )
        {
            //!
            //! - The queried refresh data is not same as the original 
            //!   stored data. The table content have to be updated. 
            //!   Reload the table content. The ideal solution would be 
            //!   to update just the modified fields in the table.
            //! 
            //! - Store the queried refresh value
            //!
            self.listDisplay.location.reload();

            scRefresh_Orig = scRefresh_Lcl;

            //!
            //! - If the queried refresh status is not Running or Paused 
            //!   or NotStarted clear the interval set on this window
            //!
			if (scRefresh_Lcl.indexOf(scRUNNING) != 0 &&
				scRefresh_Lcl.indexOf(scPAUSED) != 0 &&
				scRefresh_Lcl.indexOf(scNOTSTARTED )!= 0 )
            {
                if ( iIntervalID != -1 )
                {
                    self.clearInterval(iIntervalID);
                }
            }
            
        } //! If the queried status NOT EQUAL to original status

    } //! If the queried status is NOT NULL

} //! refreshTableData

//!
//! - If there is valid refresh interval set the interval
//!
if ( iRefreshInterval > 0 )
{
    iIntervalID = self.setInterval("refreshTableData()", iRefreshInterval);
}
</script>
