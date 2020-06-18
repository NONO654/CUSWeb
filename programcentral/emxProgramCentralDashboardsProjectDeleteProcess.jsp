<%--
  emxProgramCentralDashboardsProjectDeleteProcess.jsp

  Deletes the selected projects from a dashboard collection

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralDashboardsProjectDeleteProcess.jsp.rca 1.9 Wed Oct 22 15:49:27 2008 przemek Experimental przemek $";
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file="../emxUICommonAppInclude.inc"%>

<%
  String dashboardName = emxGetParameter(request,  "dashboardName" );
  dashboardName = ".dashboard-" + dashboardName; // prepend .dashboard- to the name
  String[] projectBusID = ( String[] )emxGetParameterValues(request,"chkProgramIds" );
  try
  {
    // start a write transaction and lock business object
    ContextUtil.startTransaction( context, true );

    //to find the set for this dashboard name
    SetList sl = matrix.db.Set.getSets( context , true);
    Iterator setItr = sl.iterator();

    while ( setItr.hasNext() )
    {
      matrix.db.Set curSet = ( matrix.db.Set )setItr.next();

      if ( curSet.getName().equals( dashboardName ) )
      {
      //now remove the selected projects from this set
      BusinessObjectList bo = curSet.getBusinessObjects(context);
      for ( int i = 0; i < projectBusID.length; i++ )
    {
      String busId = projectBusID[i];

      for(int j=0;j<bo.size();j++)
      {
        BusinessObject bussObject=bo.getElement(j);
        if((bussObject.getObjectId()).equals(busId))
        {
        curSet.removeBusinessObject(bussObject);
      }
      }
    }

    curSet.setBusinessObjects( context );
        break; // don't need to continue looping
      } // end if
    } // end while

    // commit the data
    ContextUtil.commitTransaction( context );
  }
  catch (Exception e)
  {
    ContextUtil.abortTransaction(context);
    e.printStackTrace();
    //out.println("Exception");
  }
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    //parent.document.location.reload();
	parent.document.location.href=parent.document.location.href;
    // Stop hiding here -->//]]>
  </script>
</html>
