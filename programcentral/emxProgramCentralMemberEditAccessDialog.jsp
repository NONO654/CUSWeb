<%--  emxProgramCentralMemberEditAccessDialog.jsp

  Allows the user to edit the project Access

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralMemberEditAccessDialog.jsp.rca 1.20 Wed Oct 22 15:50:32 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,"PROGRAM");

  //For Localized Values
  String languageStr = request.getHeader("Accept-Language");

  // static-purpose beans
  com.matrixone.apps.common.Person person = null;
  com.matrixone.apps.common.MemberRelationship member =  (com.matrixone.apps.common.MemberRelationship) DomainRelationship.newInstance(context, DomainConstants.RELATIONSHIP_MEMBER);

  // Get business object id from URL
  String projectId = emxGetParameter(request, "busId");
  String personId = emxGetParameter(request, "personId");
  String userType = emxGetParameter(request, "userType");

  project.setId (projectId);
  String role = null;
  String access = null;
  String userName = "";
  String relationshipId = "";
  StringList slMemberRoles = new StringList();
  
  StringList busSelects = new StringList();
  busSelects.add(person.SELECT_NAME);
  busSelects.add(person.SELECT_FIRST_NAME);
  busSelects.add(person.SELECT_LAST_NAME);

  StringList memberSelect = new StringList();
  memberSelect.add(member.SELECT_ID);
  memberSelect.add(member.SELECT_PROJECT_ROLE);
  memberSelect.add(member.SELECT_PROJECT_ACCESS);

  // String for member where clause
  String memberWhere = "id == " + personId;

  MapList personList = new MapList();
  //user being modified could of type person or group or role
  //if it is a person then the access and project role can be
  //obtained from the relationship
  StringList i18nRoleList  = new StringList();
  String i18nRole = null;
  StringList roleList = new StringList();
  if(userType.equals(member.TYPE_PERSON)) {
    // Create a map of the person's information.
    personList = project.getMembers(context, busSelects, memberSelect, memberWhere, null, false);
    if (personList.size() > 0) {
      Map personMap = (Map) personList.get(0);
      //get the role/UserName of the selected person
      access = (String)personMap.get(member.SELECT_PROJECT_ACCESS);
      role = (String)personMap.get(member.SELECT_PROJECT_ROLE);
      userName = (String)personMap.get(person.SELECT_LAST_NAME)+ ", " + (String)personMap.get(person.SELECT_FIRST_NAME);
      relationshipId = (String)personMap.get(member.SELECT_ID);
    }
    
	    
    if(role.startsWith("role_")){
      i18nRole = i18nNow.getRoleI18NString(PropertyUtil.getSchemaProperty(context,role), languageStr);
    } else {
      i18nRole = i18nNow.getRangeI18NString(member.ATTRIBUTE_PROJECT_ROLE,role, languageStr);
    }
    
    
      Map memberMap = member.getTypeAttributes(context, member.RELATIONSHIP_MEMBER);
    
    Map roleMap = (Map) memberMap.get(member.ATTRIBUTE_PROJECT_ROLE);
    roleList = (StringList)roleMap.get("choices");
    
//    Create Localized values for Role Lists - Range from Attribute "Project Role"
      i18nRoleList  = new StringList();
      
    String showRDORoles = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.showRDORoles");
    if(showRDORoles!= null && !"true".equalsIgnoreCase(showRDORoles))
    {
      //To filter out any Role choices which have a symbolic name and start with "role_"
      Iterator roleItr = roleList.iterator();
          while(roleItr.hasNext()){
        if(((String)roleItr.next()).startsWith("role_")){
          roleItr.remove();
        }
      }
    }
    	
       
      StringItr rolesList2 = new StringItr(roleList);
      while(rolesList2.next())
      {
          String sProjectRole = (String)rolesList2.obj();
          // IR Fix 310707 - End
          if(sProjectRole.startsWith("role_"))
          {
              String sIntProjectRole = PropertyUtil.getSchemaProperty(context, sProjectRole);
              
                if(ProgramCentralUtil.isNullString(sIntProjectRole))  // modified by rg6 problem with role role_ChangeBoards i18 value is blank 
                {
                  sIntProjectRole = sProjectRole;
                }
                else
                {
                    sIntProjectRole = i18nNow.getRoleI18NString(sIntProjectRole, context.getSession().getLanguage());
        
                  // Check if the RDO role is repeating
                  if (i18nRoleList.contains(sIntProjectRole)) 
    {
                	  if (!"".equals(sIntProjectRole))
      {
                		  sIntProjectRole += EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                				  "emxProgramCentral.MemberRoles.Suffix.RDO", context.getSession().getLanguage());
      }

                  }
              }
              //Added:29-Apr-09:WQY:R207:PRG Bug :373332
              i18nRoleList.add(sIntProjectRole);
              //End:R207:PRG Bug :373332
    	                }
    	                else
    	                {
              //Added:29-Apr-09:WQY:R207:PRG Bug :373332
              String sIntProjectRole = i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_PROJECT_ROLE,sProjectRole, context.getSession().getLanguage());
              //End:R207:PRG Bug :373332
    	        
              // Check if the Project Role role is repeating
              if (i18nRoleList.contains(sIntProjectRole)) 
              {
            	  if (!"".equals(sIntProjectRole))
            	  {
            		  sIntProjectRole += EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
            				  "emxProgramCentral.MemberRoles.Suffix.ProjectRole", context.getSession().getLanguage());
    	      }
    	  
    }
    
              i18nRoleList.add(sIntProjectRole);
        
    }
    }
    
  } else {
    //get group role memberships
    personList = project.getMembers(context, busSelects, memberSelect, null, null, true);
    Iterator personListItr = personList.iterator();
    while (personListItr.hasNext())
    {
      Map userMap = (Map) personListItr.next();
      if(userMap.get(person.SELECT_NAME).equals(personId)) {
        access = (String)userMap.get(member.SELECT_PROJECT_ACCESS);
        userName = (String)userMap.get(person.SELECT_NAME);
        break;
      }
    }
  }
  //build the choices for access
  StringList accessList = mxAttr.getChoices(context,
                                            member.ATTRIBUTE_PROJECT_ACCESS);
  accessList.remove("Project Owner");

  //Create Localized version of Access List
  StringList i18nAccessList = new StringList();
  StringItr strItr = new StringItr(accessList);


  while(strItr.next())
  {
      i18nAccessList.addElement(i18nNow.getRangeI18NString(member.ATTRIBUTE_PROJECT_ACCESS,strItr.obj(),languageStr));
  }
  String i18nSelectedAccess = i18nNow.getRangeI18NString(member.ATTRIBUTE_PROJECT_ACCESS,access,languageStr);
%>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
  <body class="white">
    <form name="ProjectMembersModify" action="" method="post" onsubmit="submitFormEdit();return false">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="userType" value="<xss:encodeForHTMLAttribute><%=userType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="personId" value="<xss:encodeForHTMLAttribute><%=personId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="relationshipId" value="<xss:encodeForHTMLAttribute><%=relationshipId%></xss:encodeForHTMLAttribute>" />

      <table border="0" width="100%">
        <tr>
          <td>
            <table border="0" width="100%">
              <tr>
                <td class="label" width="35%">
                <framework:ifExpr expr='<%= userType.equals(member.TYPE_PERSON) %>'>
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.UserName</framework:i18n>
                </framework:ifExpr>
                <framework:ifExpr expr='<%= userType.equals("Group") %>'>
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.GroupName</framework:i18n>
                </framework:ifExpr>
                <framework:ifExpr expr='<%= userType.equals("Role") %>'>
                    <framework:i18n localize="i18nId">emxProgramCentral.Common.RoleName</framework:i18n>
                </framework:ifExpr>
                </td>
                <td class="field"><%= userName %></td>
              </tr>

             <tr>
               <td class="label" width="35%">
                 <framework:i18n localize="i18nId">emxProgramCentral.Common.MemberAccess</framework:i18n>
               </td>
               <framework:ifExpr expr="<%= access.equalsIgnoreCase(\"Project Owner\") %>">
               <!-- Added 9/9/2010 ms9: IR-063744V6R2011x  -->
                 <td class="field"><%= i18nSelectedAccess %></td>
               <!-- End 9/9/2010 ms9: IR-063744V6R2011x  -->
               </framework:ifExpr>
               <framework:ifExpr expr="<%= !access.equalsIgnoreCase(\"Project Owner\") %>">
                 <td class="field">
                   <select name="ProjectAccess">
                     <framework:optionList
                       valueList="<%=accessList%>"
                       optionList="<%=i18nAccessList%>"
                       selected="<%= i18nSelectedAccess %>"/>
                   </select>
                 </td>
               </framework:ifExpr>
             </tr>
             <framework:ifExpr expr='<%= userType.equalsIgnoreCase(member.TYPE_PERSON) %>'>
             <tr>
                <td class="label" nowrap="nowrap">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.MemberRole</framework:i18n>
                  </td>
                  <td class="field">
                    <select name="ProjectRole">
                      <framework:optionList
                        valueList="<%=roleList%>"
                        optionList="<%=i18nRoleList%>"
                        selected="<%=i18nRole %>"/>
                    </select>
                  </td>
                </tr>
              </framework:ifExpr>

             <framework:ifExpr expr="<%= access.equalsIgnoreCase(\"Project Owner\") %>">
               <tr>
                 <td align="center" colspan="2" nowrap="nowrap"> <br />
                   (<i><framework:i18n localize="i18nId">emxProgramCentral.Common.Note</framework:i18n></i> :
                   <b> <framework:i18n localize="i18nId"> emxProgramCentral.Common.ProjectOwner</framework:i18n> </b>
                   <framework:i18n localize="i18nId"> emxProgramCentral.Common.AccessCannotBeChanged </framework:i18n>)
                 </td>
               </tr>
             </framework:ifExpr>

           </table>
         </td>
       </tr>
      </table>
      <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />
    </form>
  </body>

  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    function submitFormEdit() {
      f = document.ProjectMembersModify;
      f.action="emxProgramCentralMemberUpdateProcess.jsp";
      f.submit();
    }
    // Stop hiding here -->//]]>
  </script>

</html>
