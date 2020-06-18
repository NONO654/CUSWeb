<%--  emxComponentsPotentialCustomersSummary.jsp -- This page redirects to emxTable.jsp to display potential Customers summary

  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsPotentialCustomersSummary.jsp.rca 1.7 Wed Oct 22 16:18:10 2008 przemek Experimental przemek $;
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>


<%
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String companyId = com.matrixone.apps.common.Person.getPerson(context).getCompanyId(context);
  
  String languageStr  = request.getHeader("Accept-Language");
  String strHeading = EnoviaResourceBundle.getProperty(context, "emxSupplierCentralNetStringResource", context.getLocale(), "emxSupplierSourcing.PotentialCustomers.Heading");
  
  StringBuffer strbufURL = new StringBuffer(1024);
  strbufURL.append("../common/emxTable.jsp?");
  strbufURL.append("&program=emxCompany:getCustomers");
  strbufURL.append("&objectId=");
  strbufURL.append(XSSUtil.encodeForURL(context,companyId));
  strbufURL.append("&table=SCSPotentialCustomersSummary");
  strbufURL.append("&sortColumnName=Name");
  strbufURL.append("&sortDirection=ascending");
  strbufURL.append("&header=");
  strbufURL.append(XSSUtil.encodeForURL(context,strHeading));
  strbufURL.append("&selection=multiple");
  strbufURL.append("&toolbar=SCSPotentialCustomersToolbar");
  strbufURL.append("&PrinterFriendly=true&HelpMarker=emxhelppotentialcustomers");
  strbufURL.append("&suiteKey=Components");

%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<!-- //XSSOK -->
<form action="<%=strbufURL.toString()%>" name="PotentialCustomers" method="post" target="content">
</form>

<script language="JavaScript">
    document.PotentialCustomers.submit();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
