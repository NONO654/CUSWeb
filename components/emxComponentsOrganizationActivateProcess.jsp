<%--  emxComponentsOrganizationActivateProcess.jsp   -  This page activates the selected objects whose policy is Organization
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsOrganizationActivateProcess.jsp.rca 1.4 Wed Oct 22 16:17:42 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  
  String url = "";
  String delId  ="";
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  String selectedPeople[] = new String[checkBoxId.length];

  if(checkBoxId != null )
  {
      try
      {  
          DomainObject domObject = null;
          String sState = null;
          String stateActive = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_ORGANIZATION, "state_Active");
          StringTokenizer st = null;
          String sRelId = "";
          String sObjId = "";
          for(int i=0;i<checkBoxId.length;i++)
          {
            // In inactive people Summary page, only the persob object id is passed, no relationship id
            // so, condition is being checked for "|", which divides relId and objectId
            if(checkBoxId[i].indexOf("|") != -1)
            {
             st = new StringTokenizer(checkBoxId[i], "|");
             sRelId = st.nextToken();
             sObjId = st.nextToken();
            }
            else
            {
              sObjId = checkBoxId[i];
            }

             domObject = new DomainObject(sObjId);
             domObject.open(context);
             sState = domObject.getInfo(context,DomainObject.SELECT_CURRENT);

             if(!sState.equals(stateActive))
             {
                 try
                 {
                     domObject.promote(context);
                 }
                 catch (MatrixException me)
                 {
                     session.setAttribute("error.message", me.getMessage());
                 }
             }
             domObject.close(context);
          }       
 
      }catch(Exception Ex){
           session.putValue("error.message", Ex.toString());
      }
  }

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
      getTopWindow().refreshTablePage();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

