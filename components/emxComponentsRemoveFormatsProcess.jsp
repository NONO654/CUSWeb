<%-- emxComponentsRemoveFormatsProcess.jsp   -  This page disconnects the business objects connected to the Organization.
  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsRemoveFormatsProcess.jsp.rca 1.6 Wed Oct 22 16:18:56 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<!-- content begins here -->

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
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
             DomainRelationship.disconnect(context,sRelId);
          }       
 
      }catch(Exception Ex){
           session.putValue("error.message", Ex.toString());
      }
  }

%>
<script language="Javascript">
      getTopWindow().refreshTablePage();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
