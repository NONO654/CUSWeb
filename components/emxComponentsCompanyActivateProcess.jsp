<%--  emxComponentsCompanyActivateProcess.jsp   -  This page activates/deactivates the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCompanyActivateProcess.jsp.rca 1.7 Wed Oct 22 16:18:35 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%

String accessUsers = "role_BuyerAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

    DomainObject domObj = DomainObject.newInstance(context);
    String sState = "";

    String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
    if(checkBoxId != null )
    {
        try
        {
            String stateActive = FrameworkUtil.lookupStateName(context, DomainConstants.POLICY_ORGANIZATION, "state_Active");
            StringTokenizer st = null;
            String sRelId = "";
            String sObjId = "";
            for(int i=0;i<checkBoxId.length;i++)
            {
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
    
                domObj.setId(sObjId);
    
                sState = domObj.getInfo(context,DomainObject.SELECT_CURRENT);
    
                if(!sState.equals(stateActive))
                {
                    domObj.open(context);
                    domObj.promote(context);
                    domObj.close(context);
                }
            }
        }
        catch (Exception e)
        {
            session.setAttribute("error.message", e.getMessage());
        }
    }
%>

<script language="Javascript">
      getTopWindow().refreshTablePage();
</script>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
