<%--  emxProgramCentralMemberDeleteProcess.jsp

  Performs the action to remove members of the given project.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralMemberDeleteProcess.jsp.rca 1.20 Wed Oct 22 15:49:29 2008 przemek Experimental przemek $";
  2001/08/10 2:00 pm LN
--%>

<%--

Change History:
Date       Change By  Release   Bug/Functionality        Details
-----------------------------------------------------------------------------------------------------------------------------
3-Apr-09   wqy        V6R2010   372552                   Change the logic for refreshing the page, when loggedUser remove from 
                                                         Project member page

--%>


<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%
  com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,"PROGRAM");
  com.matrixone.apps.common.MemberRelationship member = (com.matrixone.apps.common.MemberRelationship) DomainRelationship.newInstance(context, DomainConstants.RELATIONSHIP_MEMBER);
  com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);
  // Get project id from the request.
  String projectId  = emxGetParameter(request, "objectId");  
  // added for bug no 310681,337605
  String languageStr = request.getHeader("Accept-Language");
  // Get ids to remove from the request.
  String[] people = emxGetParameterValues(request, "emxTableRowId");
  people = ProgramCentralUtil.parseTableRowId(context,people);

  // Set project id.
  project.setId(projectId);

  HashMap permissionMap    = new HashMap();
  //Gets project owner
  //String projectOwner = project.getInfo(context, project.SELECT_OWNER).toString();

  StringList busSelects = new StringList();
  busSelects.add(member.SELECT_NAME);
  busSelects.add(project.SELECT_OWNER);
  //added for the bug no 310681,337605
  busSelects.add(project.SELECT_PROJECT_VISIBILITY);
  Map resultMap=project.getInfo(context, busSelects);
  String projectOwner = (String)resultMap.get(project.SELECT_OWNER);
  String projVisibility =(String)resultMap.get(project.SELECT_PROJECT_VISIBILITY);
  String loggedUser = context.getUser();
  String personName = "";
  //end the bug no 310681,337605
  //Added:3-Apr-09:wqy:R207:PRG Bug :372552
  matrix.util.StringList slPersonNameList = new matrix.util.StringList();
  //End:R207:PRG Bug :372552

  boolean hasOwner = false;

  Map groupRoleMap = new HashMap();
  StringList pList = new StringList();
  if ( people != null ) {
    // get the number of people
    int numUsers = people.length;
    int numPersons = 0;

    for (int i=0; numUsers>i; i++) {
      //check if it is an id or a group/role name
      if(people[i].indexOf("personid") == -1) {
        //is a group or role name pass access = "None" for removing
        //the access
        groupRoleMap.put(people[i], "None");
      }
      else {
        //obtain the person id
        int pVal = people[i].indexOf("_") + 1;
        String personId = people[i].substring(pVal, people[i].length());
        pList.add(personId);
        numPersons++;
      }
    }

    try {
      // start a write transaction and lock business object
      project.startTransaction(context, true);

      // build string array to remove from project
      ArrayList members = new ArrayList();

      if(pList != null && !pList.isEmpty()) {
        StringItr pListItr = new StringItr(pList);
        while(pListItr.next()) {
          // Loop through and get each selected member's relationshipId.
          String relationshipId = "";
          personName = "";

          // build the busSelects, relSelects, and busWhere
          StringList relSelects = new StringList();
          relSelects.add(member.SELECT_ID);
          String relWhere = "\"" + project.SELECT_MEMBERSHIP_ID + "\" == " +
                           (String) pListItr.obj() + "";

          // Create a map of the member's information.
          Map personMap = (Map) new HashMap();
          MapList personList = project.getMembers(context, busSelects, relSelects, null, relWhere);
          if (personList.size() > 0) {
            personMap = (Map) personList.get(0);
            //get the projectRole/UserName of the selected person
            relationshipId = (String)personMap.get(member.SELECT_ID);
            personName = (String)personMap.get(member.SELECT_NAME);
            //Added:3-Apr-09:wqy:R207:PRG Bug :372552
            slPersonNameList.add(personName);
            //End:R207:PRG Bug :372552
            
          }

          permissionMap.put(personName, "None");
          //only deletes if it is not the project owner
          if (projectOwner.equals(personName)){
            hasOwner = true;
          }
          else {
            members.add((String) relationshipId);
          }
        }
      }
         
        
        if(! members.isEmpty()){
          String relIds[] = new String[members.size()];
          Iterator membersItr = members.iterator();
          int i = 0;
          while(membersItr.hasNext()) {
            relIds[i] = (String) membersItr.next();
            i++;
          }
          project.removeMembers(context, relIds);
        }

        if (groupRoleMap != null) {             
            project.setGroupRoleMembership(context,groupRoleMap);
        }
        //Folder operation started below.
        StringList strSelects = new StringList();
        strSelects.add(workspaceVault.SELECT_ID);
        MapList folderList = workspaceVault.getWorkspaceVaults(context, project, strSelects, 0);
        //added by ixe for 0670077
        workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
        //end of 0670077
        %>
        <framework:mapListItr mapList="<%= folderList %>" mapName="folderMap">
        <%
             workspaceVault.setId((String)folderMap.get(workspaceVault.SELECT_ID));
             //Remove person from folders.
             if(permissionMap != null){ 
                  workspaceVault.setUserPermissions(context, permissionMap);
             }
             //Remove Role from folders.
             //Added:26-Jul-11:P6E:R212:PRG Bug :112586V6R2012x_
             if(groupRoleMap != null) {
                  workspaceVault.setUserPermissions(context,groupRoleMap);
             }
           //End:26-Jul-11:P6E:R212:PRG Bug :112586V6R2012x_
         %>
          </framework:mapListItr>
         <%
        // commit the data
        ContextUtil.commitTransaction(context);
    } catch (Exception e) {
        ContextUtil.abortTransaction(context);
        throw e;
    }
  }
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    <%-- XSSOK--%>
     if(<%=hasOwner%>) {
      alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ProjectOwnerCanNotBeDeleted</emxUtil:i18nScript>");
    }
     var tree = getTopWindow().objDetailsTree;
     if(tree == null){
    	 parent.location.reload();
     } else {
     if(!tree)
     {
        tree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
     }
 <%
     //Loop through all ids passed in for delete and remove them from the navigation tree
    if (pList != null) {
      Iterator peopleItr = pList.iterator();
      while (peopleItr.hasNext()) {
        String temppeopleId = (String) peopleItr.next();
%>
        tree.deleteObject("<%=temppeopleId%>",false);
<%
      } //end while itr has next
    } //end if folders does not equal null
%>
    //added for the bug no 337605 -begin
    var currentObjId = "<%=XSSUtil.encodeForJavaScript(context,projectId)%>";
    var objRootNode = tree.getCurrentRoot();
    var strObjID = objRootNode.objectID;
    //added for the bug no 337605 -end
    tree.refresh();
     }
<%
// added for the bug no 337605, 310681 
      //Added:3-Apr-09:wqy:R207:PRG Bug :372552
      if((("Members").equals(projVisibility)) && !loggedUser.equals(projectOwner)&& slPersonNameList.contains(loggedUser))
      {
      //End:R207:PRG Bug :372552
        String pageHeader= ProgramCentralUtil.i18nStringNow("emxProgramCentral.ProgramTop.Projects",languageStr);
        String activeProjects = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.ActiveProjects",languageStr);
        String completedProjects = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.CompletedProjects",languageStr);
        String allProjects = ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.All",languageStr);

        String for_url= "../common/emxTable.jsp?program=emxProjectSpace:getActiveProjects,emxProjectSpace:getCompletedProjects,emxProjectSpace:getAllProjects&programLabel="+XSSUtil.encodeForURL(context, activeProjects)+","+XSSUtil.encodeForURL(context, completedProjects)+","+XSSUtil.encodeForURL(context, allProjects)+"&table=PMCProjectSpaceMyDesk&selection=multiple&header="+pageHeader+"&sortColumnName=Type&sortDirection=ascending&Export=false&toolbar=PMCProjectSummaryToolBar&HelpMarker=emxhelpprojectsummary&FilterFramePage=../programcentral/emxProgramVaultFilterInclude.jsp&FilterFrameSize=40";

 %>
       var projectSummaryFrame = getTopWindow().findFrame(getTopWindow(),"content");
       if(strObjID != currentObjId){
       var selectedNode = tree.getSelectedNode();
       var newProjectNode = selectedNode.getParent();
       var projectNode = newProjectNode.getParent();
       tree.setSelectedNode(projectNode, true);
       projectNode.removeChild(newProjectNode.objectID,true);
       }else if(projectSummaryFrame){
           projectSummaryFrame.location.href="<%=XSSUtil.encodeForJavaScript(context,for_url)%>";
       }else{
         parent.location.href = "<%=for_url%>"; <%--- XSSOK --%>
 }
 <%
      }
      else 
      {// end the bug no 337605, 310681
%>
        parent.document.location.href = parent.document.location.href;
<%
      }
%>
    // Stop hiding here -->//]]>
  </script>
</html>
