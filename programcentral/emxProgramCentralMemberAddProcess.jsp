<%--  emxProgramCentralMemberAddProcess.jsp

  Performs the action to apply members to a given project.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralMemberAddProcess.jsp.rca 1.20 Wed Oct 22 15:49:23 2008 przemek Experimental przemek $";
  2001/08/10 2:00 pm LN
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
  com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
  com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);

  //Get paramters from url
  String objectId = emxGetParameter(request, "objectId");
  String errorMessage = "";
  //Get results returned from search
  StringList searchResultList = (StringList)session.getAttribute("searchResultList");
  //remove session variable
  session.removeAttribute("searchResultList");

  // set the id
  project.setId(objectId);
  String objectName = (String) project.getName(context);

  //Used to get name to add user to all Folders with Inherited Read Access
  StringList newMemNameList = new StringList();

  // Get a list of the current project members.
  MapList queryResultList = new MapList();
  StringList busSelects = new StringList (5);
  busSelects.add(person.SELECT_ID);
  busSelects.add(person.SELECT_NAME);
  busSelects.add(person.SELECT_FIRST_NAME);
  busSelects.add(person.SELECT_LAST_NAME);
  busSelects.add(person.SELECT_COMPANY_NAME);
  StringList relSelects = new StringList(2);
  relSelects.add(MemberRelationship.SELECT_PROJECT_ROLE);
  relSelects.add(MemberRelationship.SELECT_PROJECT_ACCESS);
  queryResultList = project.getMembers(context, busSelects, relSelects, null, null);
  Iterator queryResultItr = queryResultList.iterator();
  HashMap currentMemberMap = new HashMap();
  while (queryResultItr.hasNext())
  {
    Map memberMap = (Map) queryResultItr.next();
    String name = (String) memberMap.get(person.SELECT_LAST_NAME);
    name += ", " + (String) memberMap.get(person.SELECT_FIRST_NAME);
    currentMemberMap.put(memberMap.get(person.SELECT_ID),name);
  }

  if (searchResultList != null)
  {
    try {
      // start a write transaction and lock business object
      project.startTransaction(context, true);
      Iterator resultListItr = searchResultList.iterator();
      Map map = new HashMap(searchResultList.size());
      while (resultListItr.hasNext())
      {
        String selectedValue = (String) resultListItr.next();
        StringTokenizer str = new StringTokenizer(selectedValue, ",");

        String selectedPerson = null;
        String projectAccess = null;
        String projectRole = null;

        if(str.hasMoreTokens()) {
          selectedPerson = str.nextToken();
        }
        if(str.hasMoreTokens()) {
          projectAccess = str.nextToken();
        }
        if(str.hasMoreTokens()) {
          projectRole = str.nextToken();
        }

        Map attributes = new HashMap(2);
        if(projectAccess != null && !"null".equals(projectAccess) && !"".equals(projectAccess))
        {
          attributes.put(project.ATTRIBUTE_PROJECT_ACCESS, projectAccess);
        }
        if(projectRole != null && !"null".equals(projectRole) && !"".equals(projectRole))
        {
          attributes.put(project.ATTRIBUTE_PROJECT_ROLE, projectRole);
        }
        if (!currentMemberMap.containsKey(selectedPerson)) 
        {
          map.put(selectedPerson, attributes);
          person.setId(selectedPerson);
          newMemNameList.add((String) person.getName(context));
        }
        else 
        {
          errorMessage += currentMemberMap.get(selectedPerson) + " is already a member ";
%>
                <script language="JavaScript" type="text/javascript">
                                                alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
                                                window.closeWindow();
                </script>
<%
        }
        
      }
      project.addMembers(context, map);

      if(newMemNameList != null && newMemNameList.size() > 0)
      {
        //Add the new member to all folders with Read/Inherited rights
        MapList vaultList = null;
        //Set busSelects
        busSelects.clear();
        busSelects.add(workspaceVault.SELECT_NAME);
        busSelects.add(workspaceVault.SELECT_ID);
        busSelects.add(workspaceVault.SELECT_GLOBAL_READ);
        busSelects.add(workspaceVault.SELECT_ACCESS_TYPE);
        busSelects.add(ProgramCentralConstants.SELECT_ATTRIBUTE_PROJECT_ROLE_VAULT_ACCESS);
        busSelects.add(ProgramCentralConstants.SELECT_ATTRIBUTE_DEFAULT_USER_ACCESS);

        i18nNow i18nnow = new i18nNow();
        String inheritedType = EnoviaResourceBundle.getProperty(context, "Framework", 
  			  "emxFramework.Range.Access_Type.Inherited", "en-us");
        String readAccess = EnoviaResourceBundle.getProperty(context, "Framework", 
    			  "emxFramework.Range.Project_Member_Access.Read", "en-us");

        workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
        vaultList = workspaceVault.getWorkspaceVaults(context, project, busSelects, 0);
        
        MapList inheritedVL = new MapList();
 
        if (vaultList != null && vaultList.size() > 0)
        {        
            String strAccessXML = null;
            ProjectRoleVaultAccess vaultAccess=null;
            String defaultAccess = null;
            String strVaultId = null;
            
            for(int i=0; i < vaultList.size(); i++)
            {
                Map vaultMap = (Map) vaultList.get(i);          
                String read = (String) vaultMap.get(workspaceVault.SELECT_GLOBAL_READ);
                String access = (String) vaultMap.get(workspaceVault.SELECT_ACCESS_TYPE);
                String strThisVaultId=(String)vaultMap.get(workspaceVault.SELECT_ID);
                workspaceVault.setId(strThisVaultId);
                   defaultAccess = (String) vaultMap.get(ProgramCentralConstants.SELECT_ATTRIBUTE_DEFAULT_USER_ACCESS);
                   strAccessXML = (String) vaultMap.get(ProgramCentralConstants.SELECT_ATTRIBUTE_PROJECT_ROLE_VAULT_ACCESS);
                vaultAccess = new ProjectRoleVaultAccess(context, strAccessXML);
                   
               for(int k = 0; k < newMemNameList.size(); k++)
                {
                    String strMember = (String) newMemNameList.get(k);
                    Map mapPersonAttribute= (Map)map.get(PersonUtil.getPersonObjectID(context,strMember));
                    String strRole= (String)mapPersonAttribute.get(project.ATTRIBUTE_PROJECT_ROLE);
                    String roleVaultAccess = vaultAccess.getAccess(strRole);
                    Map accessMap = new HashMap();
            	   
                    if(null !=roleVaultAccess && !"".equals(roleVaultAccess) && !ProgramCentralConstants.VAULT_ACCESS_NONE.equalsIgnoreCase(roleVaultAccess))
                {
                         accessMap.put(strMember, roleVaultAccess);
                }
                    else
                 {
                        accessMap.put(strMember, defaultAccess);
                 }
                    
                    inheritedVL.add(new HashMap(vaultMap));
                   workspaceVault.setUserPermissions(context, accessMap);  
               } 	   

            }
        }
      }

      // commit the data
      ContextUtil.commitTransaction(context);

    }
    catch (Exception e)
    {
      ContextUtil.abortTransaction(context);
        throw e;
    }
  }
%>

<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.program.ProjectRoleVaultAccess"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<html>
  <body class="white">
  <form name="finishAction" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>  
    <script language="javascript" type="text/javaScript">//<![CDATA[
      <!-- hide JavaScript from non-JavaScript browsers
        //parent.window.getWindowOpener().parent.document.focus();
        
        if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
          getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();      
  getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;      
  getTopWindow().closeWindow();
  
  // Stop hiding here -->//]]>
    </script>
  </form>
</html>
