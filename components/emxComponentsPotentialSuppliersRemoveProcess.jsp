<%--  emxComponentsPotentialSuppliersRemoveProcess.jsp   -  This page removes the selected Potential Suppliers
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPotentialSuppliersRemoveProcess.jsp.rca 1.6 Wed Oct 22 16:18:13 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");

  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  String relId = null;
  if(checkBoxId != null )
  {
      try
      {
          for(int i=0;i<checkBoxId.length;i++)
          {
			 relId = checkBoxId[i];
			 int index = relId.indexOf("|");
			 if( index > 0 )
			 {
				 relId = relId.substring(0, index);
			 }
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
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
      getTopWindow().refreshTablePage();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

