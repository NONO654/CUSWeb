<%--  emxProgramCentralTemplateDrivenDashboardDetails.jsp
  
  Displays the current user's Dashboard.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralTemplateDrivenDashboardDetails.jsp.rca 1.5 Mon Mar  2 04:01:13 2009 ds-ssadula Experimental $";
--%>


<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
    String isFromDashboard      = emxGetParameter(request,"isFromDashboard");
	isFromDashboard = XSSUtil.encodeURLForServer(context, isFromDashboard);
	String isFromProgramDashboard = emxGetParameter(request,"isFromProgramDashboard");
	isFromProgramDashboard = XSSUtil.encodeURLForServer(context,isFromProgramDashboard);
	String isPortalMode = emxGetParameter(request,"portalMode");
	isPortalMode = XSSUtil.encodeURLForServer(context,isPortalMode);
    String objectId             = emxGetParameter(request, "objectId");
    objectId = XSSUtil.encodeURLForServer(context, objectId);
    String templateFilterName   = emxGetParameter(request, "PMCProjectTemplatesCommand");
    templateFilterName = XSSUtil.encodeURLForServer(context, templateFilterName);
    String includeLvlFilterName = emxGetParameter(request, "PMCIncludeLevelCommand");
    includeLvlFilterName = XSSUtil.encodeURLForServer(context, includeLvlFilterName);
    String showWBSTasks         = emxGetParameter(request, "PMCShowWBSTasksCommand");
    showWBSTasks = XSSUtil.encodeURLForServer(context, showWBSTasks);
    String wbsTask              = emxGetParameter(request,"wbsTask");
    wbsTask = XSSUtil.encodeURLForServer(context, wbsTask);
    String showTemplates              = emxGetParameter(request,"showTemplates");
    showTemplates = XSSUtil.encodeURLForServer(context, showTemplates);
    String includeLevel              = emxGetParameter(request,"includeLevel");
    includeLevel = XSSUtil.encodeURLForServer(context, includeLevel);
    String objectIdOfDashbrd    = emxGetParameter(request, "dashboardName");
    //objectIdOfDashbrd = XSSUtil.encodeURLForServer(context, objectIdOfDashbrd);
    String templateFilterOptionsName = emxGetParameter(request, "PMCProjectTemplateListOptionsCommand");
    templateFilterOptionsName = XSSUtil.encodeURLForServer(context, templateFilterOptionsName);
    String strcategoryTreeName =emxGetParameter(request, "categoryTreeName");
    strcategoryTreeName = XSSUtil.encodeURLForServer(context, strcategoryTreeName);
 
	 if (includeLevel==null)
	 {
	     includeLevel = "0";
	 }
 	StringBuffer contentURL     = new StringBuffer(50);
 	contentURL.append("../common/emxIndentedTable.jsp?")
	 	          .append("toolbar=PMCDashboardToolbarMenu&")
	 	          .append("program=emxTemplateDrivenDashboard:getRelatedProjects&")
	 	          .append("table=PMCDashboardDetailsTable&")	 	         
  	              .append("PMCProjectTemplateListOptionsCommand="+templateFilterOptionsName+"&")
	 	          .append("PMCProjectTemplatesCommand="+templateFilterName+"&")
	 	          .append("PMCIncludeLevelCommand="+includeLvlFilterName+"&")
	 	          .append("PMCShowWBSTasksCommand="+showWBSTasks+"&")
	 	          .append("wbsTask="+wbsTask+"&")
	 	          .append("showTemplates="+showTemplates+"&")
	 	          .append("includeLevel="+includeLevel+"&")
				  .append("showRMB=false&") 
	 	          .append("suiteKey=ProgramCentral&HelpMarker=emxhelpdashboardsdetails&")
                  .append("categoryTreeName="+strcategoryTreeName+"&");
 	          
	if("true".equalsIgnoreCase(isFromDashboard))
	{
	     contentURL.append("header=emxProgramCentral.ProgramTop.DashboardDetails&")
         .append("dashboardName="+XSSUtil.encodeForURL(context, objectIdOfDashbrd)+"&")
         .append("showActionsMenu=true&") 
          .append("selection=multiple&")
	               .append("isFromDashboard=true");               
	}
	else
	{  
         contentURL.append("header=emxProgramCentral.Common.DashboardsNew&")         
	              .append("showActionsMenu=false&")
	              .append("objectId="+XSSUtil.encodeForURL(context, objectId)+"&")          
	              .append("isFromDashboard=false&")
         		  .append("isFromProgramDashboard=true");
	    
	    //    .append("calculations=false&amp;")
	    //   .append("objectCompare=false&amp;")
	    //    .append("&PrinterFriendly=true&amp;")
	}

%>
   <script language="Javascript" type="text/javaScript">           
   <%  
   if("true".equalsIgnoreCase(isFromDashboard) || "Active".equalsIgnoreCase(showTemplates))
   {
	%>	
	<%-- XSSOK--%>
	parent.document.location.href="<%=contentURL.toString()%>";
		<%
   }
   else if("true".equalsIgnoreCase(isFromProgramDashboard))
   {
   %>
   <%-- XSSOK--%>
	document.location.href="<%=contentURL.toString()%>";
	 <%
	  }
 %>
   </script>	
	

<html>
        
<body>
   
</body>
</html>
