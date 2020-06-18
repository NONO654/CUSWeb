<%--  emxProgramCentralAssigneeMultipleAddPreProcess.jsp

  Applies the results of the member search to the task.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralAssigneeMultipleAddPreProcess.jsp.rca 1.7 Wed Oct 22 15:50:31 2008 przemek Experimental przemek $";
--%>

<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
 
  String objectId = emxGetParameter( request, "objectId");

  String targetSearchPage = "emxProgramCentralAssigneeMultipleAddProcess.jsp?";

  //Need to pass several parameters to search page
  HashMap searchMap = new HashMap();
  searchMap.put("targetSearchPage", targetSearchPage);
  searchMap.put("objectId", objectId);
  session.setAttribute("personSearchMap", searchMap);
  //modified:ms9:07-12-10:IR-069215V6R2012    start

  // [MODIFIED::PRG:rg6:Dec 23,2010: :R211::Cause-No Project Name fetched for subtasks]
        //DomainObject domProjectObj = DomainObject.newInstance(context,objectId);
        //String strProjectName = domProjectObj.getName(context);
  // [END MODIFIED::PRG:rg6:Dec 23,2010: :R211]

  // [ADDED::PRG:rg6:Dec 23, 2010:IR-060464V6R2012 :R211::Start]
          // to fetch the project name from task (subtask also) at any level.
  String strProjectName = "";
  if(null != objectId && !"".equalsIgnoreCase(objectId.trim())){
      StringList slBusSelects = new StringList(1);
      slBusSelects.add(DomainConstants.SELECT_NAME);
      com.matrixone.apps.program.Task taskObj = new com.matrixone.apps.program.Task();
      taskObj.setId(objectId);
      Map projectInfo = taskObj.getProject(context, slBusSelects);
       strProjectName  = (String) projectInfo.get(DomainConstants.SELECT_NAME);
  }
  //[End::PRG:rg6:Dec 23, 2010: :R211::Start]

  boolean isSCEnabled = com.matrixone.apps.program.ProjectSpace.isSCEnabled(context);

%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    //showDetailsPopup("emxProgramCentralSearchFS.jsp?mode=personSearch");
    //Added 5 June 2010 vm3 PRG:210
    //var url = "../common/emxFullSearch.jsp?field=TYPES=type_Person&table=PMCCommonPersonSearchTable&form=PMCCommonPersonSearchForm&selection=multiple&includeOIDprogram=emxCommonPersonSearch:includeTaskAssignee&objectId="+"
    //modified:ms9:28-06-11:IR-109753V6R2012x

    if (<%=isSCEnabled%>) {
        var url = "../common/emxFullSearch.jsp?field=TYPES=type_Person:POLICY=policy_Person:CURRENT=policy_Person.state_Active&table=PMCCommonPersonSearchTable&excludeOIDprogram=emxProgramCentralUtil:getexcludeOIDforPersonSearch&form=PMCCommonPersonSearchForm&default=PRG_PEOPLE_PROJECT_MANAGEMENT="+"<%=XSSUtil.encodeForJavaScript(context,strProjectName)%>"+"&selection=multiple"+"&submitURL=../programcentral/emxProgramCentralCommonPersonSearchUtil.jsp&mode=addMultipleTaskAssignee";
    }
    else {
        var url = "../common/emxFullSearch.jsp?field=TYPES=type_Person:POLICY=policy_Person:CURRENT=policy_Person.state_Active&table=PMCCommonPersonSearchTable&excludeOIDprogram=emxProgramCentralUtil:getexcludeOIDforPersonSearch&form=PMCCommonPersonSearchForm&default=PRG_PEOPLE_PROJECT_MANAGEMENT="+"<%=XSSUtil.encodeForJavaScript(context,strProjectName)%>"+"&selection=multiple"+"&submitURL=../programcentral/emxProgramCentralCommonPersonSearchUtil.jsp&mode=addMultipleTaskAssignee";
    }
    //End:ms9:28-06-11:IR-109753V6R2012x
  //modified:ms9:07-12-10:IR-069215V6R2012    end
  //End - Added 5 June 2010 vm3 PRG:210
    showModalDialog(url);
<%--
      showModalDialog("emxProgramCentralSearchFS.jsp?mode=personSearch", 700, 700, true);
--%>
    // Stop hiding here -->//]]>
  </script>
</html>
