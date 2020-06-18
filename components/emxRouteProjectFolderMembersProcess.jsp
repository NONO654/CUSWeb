<%--
  emxProgramCentralAccessProcess.jsp

  Performs the action to change vault permissions.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Exp $;
--%>


<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>


<%
  com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);

  //Get parameters from url
  String objectId          = (String) emxGetParameter(request, "objectId");
  String topParentHolderId = (String) emxGetParameter(request, "topParentHolderId");
  String action            = (String) emxGetParameter(request, "action");
  String[] members         = request.getParameterValues("selectedIds"); //Get qualityIds from url that need to be deleted
  String[] people          = request.getParameterValues("checkbox");

  //Get results returned from search
  StringList searchResultList = (StringList)session.getAttribute("searchResultList");
  //remove session variable
  session.removeAttribute("searchResultList");

  HashMap permissionMap    = new HashMap();

  workspaceVault.setId(objectId);
  workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
  try {
    // start a write transaction and lock business object
    workspaceVault.startTransaction(context, true);

    if (action == null && people != null)
    {
      action = "group_role";
    }

    if ("add".equals(action) || "edit".equals(action)) {
      if ( members != null )
      {
        // get the number of risks to delete
        int numMembers = members.length;
        for (int i=0; numMembers>i; i++)
        {
          String membershipName = (String) members[i];
          String defaultVaultAccess = null;
            defaultVaultAccess = (String) emxGetParameter (request, "editAccess"+membershipName);

          // check for "null_value" for win9x compatiblity  || defaultVaultAccess.equals("null_value")
          if (defaultVaultAccess == null) {
            defaultVaultAccess = "Read";
          }

          //Create permissionMap with key = user name and value = access
          permissionMap.put(membershipName, defaultVaultAccess);
        }
        workspaceVault.setUserPermissions(context, permissionMap);
      }
    } //end if action == add

    if ("group_role".equals(action)) {
      // get the number of risks to delete
      int numMembers = people.length;
      String defaultVaultAccess = "Read";
      for (int i=0; numMembers>i; i++)
      {
        String membershipName = (String) people[i];
        //Create permissionMap with key = user name and value = access
        permissionMap.put(membershipName, defaultVaultAccess);
      }
      workspaceVault.setUserPermissions(context, permissionMap);
    } //end if action == add

    if ("delete".equals(action)) {
        Iterator itr = Arrays.asList(members).iterator();
        while (itr.hasNext())
        {
            String userName = (String) itr.next();
            if ("on".equalsIgnoreCase(userName))
            {
              // should use a different control name for the check all box
              continue;
            }
            permissionMap.put(userName, "None");
        }
        workspaceVault.setUserPermissions(context, (Map) permissionMap);
    } //end if action == delete

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
<%
  //page is called from a pop-up window.
  if (!"delete".equals(action)) {
%>
      parent.window.getWindowOpener().parent.document.location.reload();
      window.closeWindow();
<%
  }
%>

<%
  //page is called from main window
  if ("delete".equals(action)) {
%>
      parent.document.location.reload();
<%
  }
%>
  //Stop hiding here -->//]]>
  </script>
</html>
