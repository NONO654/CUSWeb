<%--  emxComponentsAddGroup.jsp   - The Person add Groups processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddGroup.jsp.rca 1.7 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  
  com.matrixone.apps.common.Person personID = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PERSON);
    
  String objectId= emxGetParameter(request,"objectId");
  String fromPage= emxGetParameter(request,"fromPage");
  String strLanguage = request.getHeader("Accept-Language");

  if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(fromPage))
  {
      fromPage="";
  }


  boolean hasException = false;
  String keyPerson = null;
  keyPerson = emxGetParameter(request,"keyPerson");


  if(fromPage.equals("CreatePerson"))
  {
	  String strGroups = (String) formBean.getElementValue("groupList");
	  if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strGroups))
      {
		  strGroups = "";
      }
	  String strGroup[] = request.getParameterValues("emxTableRowId");
	
	  if(strGroup==null)
      {
         %> 
         <script language="javascript">
         		 alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Message.PleaseMakeASelection")%>");
         	</script>
         
         		<%
          return;
      }

	  strGroup       = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(strGroup);
	  
	  if (strGroup!=null )
	  {
	    for(int i = 0; i < strGroup.length; i++)
	    {
	      strGroups += strGroup[i].trim()+"|";
	    }
	    formBean.setElementValue("groupList",strGroups);
	}
  }
  else
  {
  // Check for roles again in case someone has bookmarked the Add Roles page
  Person person = Person.getPerson(context);
  String accessUsers = "role_OrganizationManager,role_VPLMAdmin";
  if (!(PersonUtil.hasAnyAssignment(context, accessUsers)))
  {
	  response.setStatus(HttpServletResponse.SC_FORBIDDEN);
	  String msg=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.AddGroup.NoAccess")+context.getUser();
	  hasException = true;
%>	  
	<script type="text/javascript">
		alert("<%=msg%>");
	</script>
  

<%
  }
  else
  {
  String sPersonName = "";
  if(objectId != null) 
  {
    personID.setId(objectId);
    personID.open(context);
    sPersonName = personID.getInfo(context,DomainConstants.SELECT_NAME);
    personID.close(context);
  }
  
  matrix.db.Person personObj = new matrix.db.Person(sPersonName);

  String strRoles = "";

  String strGroup[] = request.getParameterValues("emxTableRowId");
  strGroup		= com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(strGroup);
  String strGroups = "";
  if (strGroup!=null ) 
  {
    for(int i = 0; i < strGroup.length; i++) 
    {
      strGroups += "{"+strGroup[i].trim()+"} ";
    }
    
    personObj.open(context);
    UserItr userItr = new UserItr(personObj.getAssignments(context));
    personObj.close(context);
    User userObj = null;

    while(userItr.next()) 
    {
      userObj = userItr.obj();
      if(userObj instanceof matrix.db.Group)
      {
          strGroups += "{"+userObj.getName()+"} ";
      }
      else if(userObj instanceof matrix.db.Role)
      {
          strRoles += "{"+userObj.getName()+"} ";
      }
    }

    // Start the mql command that will update the person's groups.

    // Execute the mql command.
    try
    {
        MQLCommand mqlCmd = new MQLCommand();
        mqlCmd.open( context );
        mqlCmd.executeCommand( context, "exec prog $1 $2 $3 $4","eServicecommonUpdateAssignments.tcl",sPersonName,strRoles,strGroups);
        String mqlErr = mqlCmd.getError().trim();
        if (mqlErr.length() > 0)
        {
          Exception ex = new Exception(mqlErr);
          throw ex;
        }
    }
    catch(FrameworkException fx)
    {
      fx.printStackTrace();
      hasException = true;
    }
	//Code Added for the clearCache
	PersonUtil.clearUserCacheProperty(context, sPersonName, PersonUtil.PROPERTY_ASSIGNMENT);
  }
}
  }
%>

<script>

<%
  if(!hasException && fromPage.equals("CreatePerson"))
	{
%>
    var keyPerson = "<%=XSSUtil.encodeForURL(context, keyPerson)%>";
	getTopWindow().getWindowOpener().document.location.href= "../components/emxComponentsPeopleRoleSummary.jsp?keyPerson="+keyPerson;
	getTopWindow().closeWindow();
<% 	}
  else
	{
%>
	getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
	getTopWindow().closeWindow();
<%
	}
%>

</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %> 
