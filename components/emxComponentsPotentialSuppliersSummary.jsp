<%--  emxComponentsPotentialSuppliersSummary.jsp -- This page redirects to emxTable.jsp to display potential suppliers summary

  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsPotentialSuppliersSummary.jsp.rca 1.10 Wed Oct 22 16:17:44 2008 przemek Experimental przemek $;
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>


<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String companyId = com.matrixone.apps.common.Person.getPerson(context).getCompanyId(context);
  
  String languageStr  = request.getHeader("Accept-Language");
  //Fix for the bug 309625
  String strHeading = "emxComponents.PotentialSuppliers.Heading";
  
  StringBuffer strbufURL = new StringBuffer(1024);
  strbufURL.append("../common/emxTable.jsp?");
  strbufURL.append("&program=emxCompany:getSuppliers");
  strbufURL.append("&objectId=");
  strbufURL.append(XSSUtil.encodeForURL(context,companyId));
  strbufURL.append("&table=APPPotentialSuppliersSummary");
  strbufURL.append("&sortColumnName=Name");
  strbufURL.append("&sortDirection=ascending");
  strbufURL.append("&header=");
  strbufURL.append(strHeading);
  strbufURL.append("&selection=multiple");
  strbufURL.append("&toolbar=APPPotentialSuppliersToolbar");
  strbufURL.append("&PrinterFriendly=true&HelpMarker=emxhelppotentialsuppliers");
  strbufURL.append("&suiteKey=Components");

%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<!-- //XSSOK -->
<form action="<%=strbufURL.toString()%>" name="PotentialSuppliers" method="post" target="content">
</form>

<script language="JavaScript">
    document.PotentialSuppliers.submit();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
