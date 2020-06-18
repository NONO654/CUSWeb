<%--  emxComponentsCollaborationRequestAcceptRejectProcess.jsp

  This page is called form the Profile Admin Home page.
  It accepts or rejects collaboration requests based on the selections
  in the Profile Admin Home page.

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCollaborationRequestAcceptRejectProcess.jsp.rca 1.10 Wed Oct 22 16:18:47 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_BuyerAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

    String attrShareTypes = DomainConstants.ATTRIBUTE_SHARE_TYPES;
    String[] arrayReqValues = emxGetParameterValues(request,"emxTableRowId");
    DomainRelationship relObject = null;
    DomainObject busFrom = null;
    DomainObject busTo = null;
    String sMode = emxGetParameter(request, "mode");
    String sRelationId = "";
    String sShareTypesValues = "";

    if(arrayReqValues != null)
    {
        try
        {
            ContextUtil.startTransaction(context, true);
            StringTokenizer st = null;
            for (int iParamIndex = 0; iParamIndex < arrayReqValues.length; iParamIndex++)
            {
                st = new StringTokenizer(arrayReqValues[iParamIndex], "|");
                sRelationId = st.nextToken();
                
                ContextUtil.pushContext(context);

                if("accept".equals(sMode))
                {
                    relObject = new DomainRelationship(sRelationId);
                    relObject.open(context);
                    busFrom = new DomainObject(relObject.getFrom());
                    busTo = new DomainObject(relObject.getTo());
                    sShareTypesValues = relObject.getAttributeString(context,attrShareTypes);
                    MqlUtil.mqlCommand(context, "trigger off;", true);
					try{// Added for IR-053899V6R2011x
                    	relObject.remove(context);
                    } finally { // Added for IR-053899V6R2011x
                    	MqlUtil.mqlCommand(context, "trigger on;", true);
                    }// Added for IR-053899V6R2011x
                    relObject.close(context);
                
                    relObject = DomainRelationship.connect(context,busFrom,Company.RELATIONSHIP_COLLABORATION_PARTNER,busTo);
                    relObject.setAttributeValue(context,attrShareTypes,sShareTypesValues);
                    MqlUtil.mqlCommand(context, "trigger off;", true);
					try{// Added for IR-053899V6R2011x
	                    relObject = DomainRelationship.connect(context,busTo,Company.RELATIONSHIP_COLLABORATION_PARTNER,busFrom);
	                    relObject.setAttributeValue(context,attrShareTypes,sShareTypesValues);
                    } finally {// Added for IR-053899V6R2011x
                        MqlUtil.mqlCommand(context, "trigger on;", true);
                    }// Added for IR-053899V6R2011x
                }
                else if("reject".equals(sMode))
                {
                    DomainRelationship.disconnect(context, sRelationId);
                }
                ContextUtil.popContext(context);
            }
            ContextUtil.commitTransaction(context);
        }
        catch (Exception e)
        {
            ContextUtil.abortTransaction(context);
            session.setAttribute("error.message", e.getMessage());
        }
    }
%>
    <script>
    getTopWindow().refreshTablePage();
    </script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


