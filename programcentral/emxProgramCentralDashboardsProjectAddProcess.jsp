<%--
  emxProgramCentralDashboardsProjectAddProcess.jsp

  Adds the selected project to the dashboard collection.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralDashboardsProjectAddProcess.jsp.rca 1.14 Wed Oct 22 15:49:36 2008 przemek Experimental przemek $";
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file="../emxUICommonAppInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>


<%--<jsp:useBean id="formBean" scope="page" class="com.matrixone.apps.common.util.FormBean"/>--%>

<%

 //Get all selected project Ids and parse it
 
  String[] strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
  for (int i=0;i<strTableRowIds.length;i++)
	  {
	      Map mpRow = ProgramCentralUtil.parseTableRowId(context,strTableRowIds[i]);
	      strTableRowIds[i] = (String) mpRow.get("objectId");   
	  }
     
  String dashboardName = emxGetParameter(request,  "dashboardName" );
  dashboardName = FrameworkUtil.findAndReplace(dashboardName, "|*|", "&");

  Properties detailsDBProp = (Properties) session.getAttribute("detailsDBProp_KEY");
  if(detailsDBProp != null && dashboardName == null)
  {
      dashboardName = detailsDBProp.getProperty("strParamDashBoad_KEY");
  }

    dashboardName = ".dashboard-" + dashboardName; // prepend .dashboard- to the name
  if ( null != strTableRowIds && strTableRowIds.length>0)
  {
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
      //add the projects to this set
      BusinessObjectList busList = curSet.getBusinessObjects( context );
      for ( int i = 0; i < strTableRowIds.length; i++ )
      {
        String busId = strTableRowIds[ i ];
       
        BusinessObject bo = new BusinessObject(busId);
        curSet.add(bo);
        //busList.addElement(new BusinessObject( busId ));
      }
       //curSet.appendList(busList);
      // commit the data
          curSet.setBusinessObjects( context );
      break; // don't need to continue looping
    } // end if
      } // end while

      ContextUtil.commitTransaction( context );
    }
  catch (Exception e)
  {
      ContextUtil.abortTransaction( context );
      throw e;
    }
  } // end if maplist
%>
<!-- Following is added to refresh the page -->
<html>
<body>
<script language="javascript" type="text/javaScript">
    //<![CDATA[
    //<!-- hide JavaScript from non-JavaScript browsers
      //getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
      getTopWindow().closeWindow();
      if(getTopWindow().getWindowOpener().getTopWindow())
    	  {
    	  getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
    	  }
    // Stop hiding here -->
    //]]>
  </script>
<body>
</html>
