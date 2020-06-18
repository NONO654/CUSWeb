<%--  emxComponentsCompanyDeleteProcess.jsp  - The Company delete object processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddExistingLocationsProcess.jsp.rca 1.6 Wed Oct 22 16:18:24 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>	
<%
    String objectId = emxGetParameter(request,"objectId");
    DomainObject domOrg = new DomainObject(objectId);

    String relOrgLocation         = PropertyUtil.getSchemaProperty(context, "relationship_OrganizationLocation");

    DomainObject domObj = DomainObject.newInstance(context);
    DomainRelationship domRel = null;
    AttributeList attrRelListLocation = null;
    DomainRelationship domOrgRelWithCompany = null;

    String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
    if(checkBoxId != null )
    {
        try
        {
            StringTokenizer st = null;
            String sRelId = "";
            String sObjId = "";
            for(int i=0;i<checkBoxId.length;i++)
            {
                st = new StringTokenizer(checkBoxId[i], "|");
                sRelId = st.nextToken();
                sObjId = st.nextToken();

                domObj.setId(sObjId);
                domRel = new DomainRelationship(sRelId);
                attrRelListLocation = domRel.getAttributeValues(context);

                domOrgRelWithCompany = DomainRelationship.connect(context,domOrg,relOrgLocation,domObj);
                domOrgRelWithCompany.setAttributeValues(context, attrRelListLocation);
           }
        }
        catch (Exception e)
        {
            session.setAttribute("error.message", e.getMessage());
        }
    }
%>

<script language="Javascript">
<%
    if(checkBoxId != null )
    {
%>
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
<%
    }
%>
        getTopWindow().close();
</script>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
