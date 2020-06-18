<%--  emxProgramCentralMemberUpdateProcess.jsp

  Updates the members of the given project.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralMemberUpdateProcess.jsp.rca 1.16 Wed Oct 22 15:49:24 2008 przemek Experimental przemek $";
  2001/08/10 2:00 pm LN
--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,"PROGRAM");

  // Get the project id from the request and set the project id.
  String projectId = (String) emxGetParameter(request, "busId");
  String personId = (String) emxGetParameter(request, "personId");
  String userType = (String) emxGetParameter(request, "userType");
  String relationshipId = (String) emxGetParameter(request, "relationshipId");

  project.setId(projectId);
  com.matrixone.apps.common.MemberRelationship member = new com.matrixone.apps.common.MemberRelationship(relationshipId);

  try {
    // start a write transaction and lock business object
    project.startTransaction(context, true);

    String projectRole = (String) emxGetParameter(request, "ProjectRole");
    String projectAccess = (String) emxGetParameter(request, "ProjectAccess");

    HashMap map = new HashMap();
    //the user modified could be of type person
    //currently project role applies only to user of type person
    if(userType.equals(project.TYPE_PERSON)) {
      if(projectRole != null && !projectRole.equals("null")) {
        map.put(member.ATTRIBUTE_PROJECT_ROLE, projectRole);
      }
      if(projectAccess != null && !projectAccess.equals("null") && !projectAccess.equals("")) {
        map.put(member.ATTRIBUTE_PROJECT_ACCESS, projectAccess);
      }
      //set the attributes, trigger does the rest
      member.setAttributeValues(context, map);
    }
    else {
      //user of type group or role
      map.put(personId, projectAccess);
      project.setGroupRoleMembership(context, map);
    }

    // commit the data
    ContextUtil.commitTransaction(context);

  } catch (Exception e) {
    ContextUtil.abortTransaction(context);
      throw e;
  }
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    //parent.window.getWindowOpener().parent.document.focus();
    parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
    parent.window.closeWindow();
    // Stop hiding here -->//]]>
  </script>
</html>
