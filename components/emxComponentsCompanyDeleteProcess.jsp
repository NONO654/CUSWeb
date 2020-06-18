<%--  emxComponentsCompanyDeleteProcess.jsp  - The Company delete object processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCompanyDeleteProcess.jsp.rca 1.8 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_SupplierDevelopmentManager,role_VPLMProjectLeader,role_BuyerAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

    DomainObject domObj = DomainObject.newInstance(context);
    String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
    checkBoxId = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(checkBoxId);

    if(checkBoxId != null )
    {
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
                    sRelId = st.nextToken();
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
                  //This code is added to delete Holder Object connect to Company----Start
                    String strHolderId = domObj.getInfo(context,"from["+DomainConstants.RELATIONSHIP_CURRENCY_CONVERSION_HOLDER+"].to.id");
                    if(UIUtil.isNotNullAndNotEmpty(strHolderId)) {
                    	DomainObject domainObject = DomainObject.newInstance(context,strHolderId);
                        ContextUtil.pushContext(context);
                        domainObject.deleteObject(context);
                        ContextUtil.popContext(context);	
                    }                  	
                    //This code is added to delete Holder Object connected to Company----End
                    domObj.deleteObject(context);
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
