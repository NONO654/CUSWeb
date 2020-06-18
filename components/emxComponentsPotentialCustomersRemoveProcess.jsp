<%--  emxComponentsPotentialCustomersRemoveProcess.jsp   -  This page removes the selected Potential Customers
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPotentialCustomersRemoveProcess.jsp.rca 1.5 Wed Oct 22 16:18:14 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>

<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");

  StringBuffer selCustomerID = new StringBuffer(24);
  selCustomerID.append("from[");
  selCustomerID.append(DomainObject.RELATIONSHIP_SUPPLIER);
  selCustomerID.append("].id");

  String relId = null;

  Company company = (Company)DomainObject.newInstance(context,DomainConstants.TYPE_COMPANY);

  if(checkBoxId != null )
  {
      try
      {  
          for(int i=0;i<checkBoxId.length;i++)
          {
             company.setId(checkBoxId[i]);
             relId = (String)company.getInfo(context, selCustomerID.toString());
             DomainRelationship.disconnect(context, relId);
          }       
      }
      catch(Exception Ex)
      {
           session.putValue("error.message", Ex.toString());
      }
  }
%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script language="Javascript">
      getTopWindow().refreshTablePage();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

