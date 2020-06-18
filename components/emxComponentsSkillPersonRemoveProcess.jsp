<%--  emxLibSkillPersonRemoveProcess.jsp   -  This page disconnects the person from the skill
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSkillPersonRemoveProcess.jsp.rca 1.4 Wed Oct 22 16:18:16 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_ResourceManager,role_VPLMProjectAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(checkBoxId != null )
  {
      try
      {
          // Initialize disconnect command
          //sbMqlCommand.append("start transaction;");
          ContextUtil.startTransaction(context, true);
          for(int i=0;i<checkBoxId.length;i++)
          {
            if(checkBoxId[i].indexOf("|") != -1)
            {
              StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
              String sRelId = st.nextToken();
              String sObjId = st.nextToken();
              StringBuffer sbMqlCommand = new StringBuffer(128);
              sbMqlCommand.append("disconnect connection ");
              sbMqlCommand.append(sRelId);
              sbMqlCommand.append(";");
              MqlUtil.mqlCommand(context,sbMqlCommand.toString());
            }

          }
          //sbMqlCommand.append("commit transaction;");
          ContextUtil.commitTransaction(context);
          // performs disconnect command

      }catch(Exception Ex){
           session.putValue("error.message", Ex.toString());
      }
  }

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
 getTopWindow().refreshTablePage();
    // parent.document.location.reload();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

