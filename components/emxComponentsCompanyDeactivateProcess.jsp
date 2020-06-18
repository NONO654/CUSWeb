<%--  emxComponentsCompanyDeactivateProcess.jsp   -  This page activates/deactivates the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCompanyDeactivateProcess.jsp.rca 1.10 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $
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

    DomainObject domObj         = DomainObject.newInstance(context);
    String sState = "";
    Hashtable businessUnitData  = null;
    ArrayList businessUnits     = null;
    MapList businessUnitMapList = null;

    String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
    if(checkBoxId != null )
    {
        String stateActive          = FrameworkUtil.lookupStateName(context, DomainConstants.POLICY_ORGANIZATION, "state_Active");
        String sRelDivision         = PropertyUtil.getSchemaProperty(context, "relationship_Division" );
        String sTypeBusinessUnit    = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");

        StringList selectTypeStmts  = new StringList();
        selectTypeStmts.add(DomainObject.SELECT_NAME);
        selectTypeStmts.add(DomainObject.SELECT_ID);

        StringList selectRelStmts   = new StringList();

        try
        {
            StringTokenizer st = null;
            String sRelId = "";
            String sObjId = "";
            for(int i=0;i<checkBoxId.length;i++)
            {
                if(checkBoxId[i].indexOf("|") != -1)
                {
                    st = new StringTokenizer(checkBoxId[i], "|");
                    sObjId = st.nextToken();
                }
                else
                {
                    sObjId = checkBoxId[i];
                }
				//Modified for Bug 354460
                String[] args = new String[] { sObjId };
                Boolean canDeleteOrDeactivate = (Boolean)JPO.invoke(context, "emxCompany", null, "canDeleteOrDeactivateCompany", args, Boolean.class);
                if ( canDeleteOrDeactivate.booleanValue() )
                {

                    domObj.setId(sObjId);

                    sState = domObj.getInfo(context,DomainObject.SELECT_CURRENT);

                    if(sState.equals(stateActive))
                    {
                        domObj.open(context);
                        domObj.demote(context);

                        //Deactivate the BusinessUnits under that company
                        // This code can be moved to the Company bean when we do the clean up.

                        businessUnitMapList =  domObj.expandSelect(context,
                                                                sRelDivision,
                                                                sTypeBusinessUnit,
                                                                selectTypeStmts,
                                                                selectRelStmts,
                                                                false,
                                                                true,
                                                                (short)0,
                                                                "",
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                null,
                                                                false);

                        businessUnits = (ArrayList)businessUnitMapList;

                        int busUnitSize  =  0;
                        busUnitSize = businessUnits.size();
                        for (int index=0; index <busUnitSize ; index++)
                        {
                            businessUnitData = (Hashtable)businessUnits.get(index);
                            BusinessObject businessunit = new BusinessObject((String) businessUnitData.get("id"));
                            businessunit.demote(context);
                        }

                        domObj.close(context);
                    }
                }
				else
                {
                    %>
					<script language="Javascript">
					        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Company.DeactivateorDelete</emxUtil:i18nScript>");
					</script>                 
                    <%
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
