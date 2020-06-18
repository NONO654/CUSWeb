<%--  emxComponentsRemoveGroup.jsp   - The Person remove Group processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsRemoveGroup.jsp.rca 1.5 Wed Oct 22 16:18:16 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,
                      DomainConstants.TYPE_PERSON);

  String strGroup[] = emxGetParameterValues(request, "chkGroup");
  strGroup = strGroup == null ? com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId")) : strGroup;
  String objectId = emxGetParameter(request,"objectId");
  person.setId(objectId);
  person.open(context);
  String sPersonName = person.getInfo(context,DomainConstants.SELECT_NAME);
  person.close(context);

  boolean hasException = false;

  matrix.db.Person personObj = new matrix.db.Person(sPersonName);

  String strRoles = "";
  String strGroups = "";
  if (strGroup != null) 
  {
    personObj.open(context);
    UserItr userItr = new UserItr(personObj.getAssignments(context));
    personObj.close(context);
    User userObj = null;
    String sExistingGroup = "";
    String sGroupName = "";
    boolean keepInList = true;
    while(userItr.next()) 
    {
        keepInList = true;
        userObj = userItr.obj();
        if(userObj instanceof matrix.db.Role)
        {
            strRoles += "{"+userObj.getName()+"} ";
        }
        else if(userObj instanceof matrix.db.Group)
        {
            sExistingGroup = userObj.getName();
            for(int i = 0; i < strGroup.length; i++) 
            {
                sGroupName = strGroup[i].trim();
                if (sGroupName.equals(sExistingGroup))
                {
                    keepInList = false;
                }
            }
            if(keepInList)
            {
                strGroups += "{"+sExistingGroup+"} ";
            }
        }
    }
    
    String cmd = "exec prog eServicecommonUpdateAssignments.tcl {" + sPersonName + "} { " + strRoles +"} { " + strGroups +"};";
    hasException = false;

    // Execute the mql command.
    try
    {
       MQLCommand mqlCmd = new MQLCommand();
       mqlCmd.open( context );
       mqlCmd.executeCommand( context, cmd );
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
  }

%>

<script>

<%
  if(!hasException)
  {
%>
	parent.location.href = parent.location.href;
<%
  }
%>

</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
