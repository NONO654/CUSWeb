<%--  emxProgramCentralDashboardsDetailsFS.jsp  - Frameset page for Dashboard Summary page.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralDashboardsDetailsFS.jsp.rca 1.35 Wed Oct 22 15:49:56 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxProgramCentralCommonUtilAppInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
  String jsTreeID      = emxGetParameter(request,"jsTreeID");
  String suiteKey      = emxGetParameter(request,"suiteKey");
  String initSource    = emxGetParameter(request,"initSource");
  String dashboardName = emxGetParameter(request,"dashboardName");
  String objectId      = emxGetParameter(request,"objectId");
  String objectName    = emxGetParameter(request,"objectName");
  String Directory     = appDirectory;
  
  dashboardName = FrameworkUtil.findAndReplace(dashboardName,"|*|","&");
  //Start : 372387
  String mode          = emxGetParameter(request,"mode");
  if(!"remove".equalsIgnoreCase(mode))
  {
  //End : 372387
if (dashboardName != null && !"".equals(dashboardName)) {

  //Replace the * with ' back again,since it has been replaced earlier in getName() of emxDashboardBase.bug# 310787
  dashboardName = FrameworkUtil.findAndReplace(dashboardName,"*","'");
}

  framesetObject fs = new framesetObject();
  fs.useCache(false);
  fs.setDirectory(Directory);  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  if (dashboardName == null || "null".equals(dashboardName)) {
    dashboardName = "";
  }
  String contentURL = "emxProgramCentralDashboardsDetails.jsp?";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

  //Need to pass dashboard name & description to create process page
  Properties detailsDBProp = new Properties();

  if(dashboardName!=null && !"null".equals(dashboardName)){
    detailsDBProp.setProperty("strParamDashBoad_KEY",dashboardName);
  }
  session.putValue("detailsDBProp_KEY",detailsDBProp );

  // Page Heading - Internationalized
  String PageHeading = "";
  String HelpMarker = "emxhelpdashboardsdetails";

  //If the page is called from the dashboard summary page then just display
  //the header Dashboard Details
  if (dashboardName != null && !"".equals(dashboardName)) {
    PageHeading = "emxProgramCentral.ProgramTop.DashboardDetails";
    fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false,4);
  }
  //else if the page is called from within the context of a project, display the
  //project name
  else {
    PageHeading = "emxProgramCentral.Common.Dashboards";
    fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,true,false);
  }  //end else

  //Only display the header and footer buttons if the page is called from the
  //Dashboard summary page
  if(dashboardName != null && !"".equals(dashboardName))
  {
    String createNewDashboard = "emxProgramCentral.Common.CreateDashboard";
    String addProject = "emxProgramCentral.Common.AddProject";
    String delProject = "emxProgramCentral.Common.DeleteSelected";
    String createNewDashboardURL = "emxProgramCentralDashboardsCreateDialogFS.jsp";
    String addProjectURL = "emxProgramCentralDashboardsProjectPreSearch.jsp";

    // only display links if we are dispplaying a dashboard.  If we have a
    // program, there will be an objectId and it is not appropriate to display
    // the create dashboard, add project to dashboard and remove project from
    // dashboard links.
    if (objectId == null && dashboardName != null){
      fs.createHeaderLink( createNewDashboard, createNewDashboardURL, "role_GlobalUser",
                           true, false, "default", 3);

      fs.createHeaderLink( addProject, addProjectURL, "role_GlobalUser",
                           true, false, "default", 5);

      fs.createFooterLink(delProject, "submitDelete()", "role_GlobalUser",
                          false, true, "default", 0);
    }
  } //end if page is called from summary page

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
  //Start : 372387
  }
  else
  {
      %>
      <script language="javascript" type="text/javaScript">
      //Modified:26-May-2010:vf2:R210 PRG:IR-053244
      // var msg = confirm("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ConfirmDelete</emxUtil:i18nScript>");
      //if(msg) {  
      //End:26-May-2010:vf2:R210 PRG:IR-053244     
      <%
          if (dashboardName != null && !"".equals(dashboardName)) {    	      
    	      dashboardName = ".dashboard-" + dashboardName; // prepend .dashboard- to the name    	     
    	      String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");
    	      String strId = null;
    
    	      try
    	      {
    	        //Start a write transaction and lock business object
    	        ContextUtil.startTransaction(context, true);

    	        //To find the set for this dashboard name
    	        SetList sl = matrix.db.Set.getSets( context , true);
    	        Iterator setItr = sl.iterator();

    	        while (setItr.hasNext())
    	        {
    	          matrix.db.Set curSet = (matrix.db.Set)setItr.next();
    	          if (curSet.getName().equals(dashboardName))
    	          {
	    	          //now remove the selected projects from this set
	    	          BusinessObjectList bo = curSet.getBusinessObjects(context);
	    	          for ( int i = 0; i < emxTableRowId.length; i++ )
	    	          {
	    	              strId = emxTableRowId[i];       	    	             
	    	              strId = strId.substring(1,strId.length());   
	    	              String busId = strId.substring(0,strId.indexOf("|")); 	    
		    	          for(int j=0; j<bo.size(); j++)
		    	          {
		    	            BusinessObject bussObject = bo.getElement(j);	
		    	            
		    	            if((bussObject.getObjectId()).equals(busId))  
		    	            {
		    	               curSet.removeBusinessObject(bussObject);		    	           
		    	            }
	       	           }
	    	         }	
	    	        curSet.setBusinessObjects(context);
	    	        break;
    	          } 
    	        } 
    	        // commit the data
    	        ContextUtil.commitTransaction(context);    	     
    	        %>    	       
    	          getTopWindow().refreshTablePage();    	       
    	        <%
    	      }
    	      catch (Exception e)
    	      {
    	        ContextUtil.abortTransaction(context);
    	        e.printStackTrace();    	       
    	      }
    	  }      
      %>
      //Modified:26-May-2010:vf2:R210 PRG:IR-053244
      //}
      //End:26-May-2010:vf2:R210 PRG:IR-053244
       </script>       
      <%	 
  }
  //End : 372387
%>

<html>
</html>
