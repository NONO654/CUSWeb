<%--
  emxProgramCentralDashboardsCreateProcess.jsp

  Performs the action that creates a program.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralDashboardsCreateProcess.jsp.rca 1.15 Wed Oct 22 15:49:18 2008 przemek Experimental przemek $";
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file="../emxUICommonAppInclude.inc"%>

<%
	//Check license before creating a dashboard
	//
  //ComponentsUtil.checkLicenseReserved(context, "PRG");
  ComponentsUtil.checkLicenseReserved(context,ProgramCentralConstants.PGE_LICENSE_ARRAY);
  String strSelectedProjects = (String) emxGetParameter(request, "AddProjectOID");
  StringList searchResultList =  FrameworkUtil.split(strSelectedProjects, "|");
  String dashboardName = (String) emxGetParameter(request, "DashboardCreateName");
  String dashboardDesc = (String) emxGetParameter(request, "Description");

  // Start :372529
  String modeVal = emxGetParameter(request,  "mode" );
  // End :372529
  Properties createDBProp = (Properties) session.getAttribute("createDBProp_KEY");
   boolean duplicate = false;
   MapList  dashboardMapList =null;
   HashMap programMap = new HashMap();
   String[] arrJPOArguments = JPO.packArgs(programMap);
   dashboardMapList = JPO.invoke(context, "emxDashboardBase", null, "getDashboards",arrJPOArguments,MapList.class);
    
   Iterator itr = dashboardMapList.iterator();
	while (itr.hasNext())
	{
		Map map = (Map) itr.next();
		String name = (String) map.get(DomainConstants.SELECT_NAME);
		if(name.equalsIgnoreCase(dashboardName)){
			duplicate = true;
			break;
		}
	}
   if(duplicate){
	 %>
		<script language="javascript" type="text/javaScript">
		 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Program.DashBoardNameAlreadyExists</framework:i18nScript>");
		</script>
    <%
    return;
   }

  if(createDBProp != null )
  {
    dashboardName = createDBProp.getProperty("strParamDashBoad_KEY");
    dashboardDesc = createDBProp.getProperty("strDBDesc_KEY");
  }
  session.removeAttribute("createDBProp_KEY");

  dashboardName = ".dashboard-" + dashboardName; // prepend .dashboard- to the user-entered name
  if (dashboardDesc != null && !dashboardDesc.equals("")){
    int descLength = dashboardDesc.length();
    if (descLength > 255){
      dashboardDesc = dashboardDesc.substring(0,255);
    }
  }

  if ( searchResultList != null )
  {
    try {
      // start a write transaction and lock business object
      ContextUtil.startTransaction( context, true );
      // create the new set with the user's entered dashboard name
      String vaultName = null;
      matrix.db.Set myNewSet = new matrix.db.Set( dashboardName );
      myNewSet.open( context );
      // add the projects that the user selected
      for ( int i = 0; i < searchResultList.size(); i++ ) {
        String busId = ( String )searchResultList.elementAt( i );
        myNewSet.add( new BusinessObject( busId ) );
      }
      // commit the data
      myNewSet.setBusinessObjects( context );

      // Set description
      if (dashboardDesc != null && !dashboardDesc.equals("")){
      //PRG:RG6:R213:Mql Injection:parameterized Mql:21-Oct-2011:start
        String sCommandStatement = "modify set $1 add property description value $2";
        String output =  MqlUtil.mqlCommand(context, sCommandStatement,dashboardName,dashboardDesc); 
        //PRG:RG6:R213:Mql Injection:parameterized Mql:21-Oct-2011:End
      }

      ContextUtil.commitTransaction( context );
    }
    catch (Exception e) {
      ContextUtil.abortTransaction( context );
      throw e;
    }
  } // end if maplist

  //clean up
  session.removeAttribute("searchResultList");
  session.removeAttribute("projectSearchMap");
  // Start :372529
if(modeVal != null && "createDahsboard".equals(modeVal)){
%>
<html>
  <body>
   <script language="javascript" type="text/javaScript">
	parent.getWindowOpener().parent.getWindowOpener().parent.refreshTablePage();
        parent.getWindowOpener().parent.closeWindow();
        parent.closeWindow();
   </script>
  <body>
</html>
<%} else {%>
<html>
  <body>
    <script language="javascript" type="text/javaScript">
      //<![CDATA[
      <!-- hide JavaScript from non-JavaScript browsers
      //Added:30-Sep-2010:vf2:R2012
      //parent.getWindowOpener().parent.getWindowOpener().parent.location.href = parent.getWindowOpener().parent.getWindowOpener().parent.location.href;
      parent.getWindowOpener().parent.getWindowOpener().parent.refreshTablePage();
      //End:30-Sep-2010:vf2:R2012
        parent.getWindowOpener().parent.closeWindow();
        parent.closeWindow();
      // Stop hiding here -->
      //]]>
    </script>
  <body>
</html>
<%
// End :372529
}
%>

