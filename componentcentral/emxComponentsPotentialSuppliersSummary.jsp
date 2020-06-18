<%--  emxComponentsPotentialSuppliersSummary.jsp -- This page redirects to emxTable.jsp to display potential suppliers summary

  (c) Dassault Systemes, 1993-2016.  All rights reserved.
  static const char RCSID[] = $Id: emxComponentsPotentialSuppliersSummary.jsp.rca 1.9 Wed Apr  2 16:26:29 2008 przemek Experimental przemek $;
--%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file="../emxUIFramesetUtil.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
  StringBuffer strbufURL = new StringBuffer(1024);

try{
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String submitButton = emxGetParameter(request,"submitButton");
  String companyId = com.matrixone.apps.common.Person.getPerson(context).getCompanyId(context);

  String languageStr  = request.getHeader("Accept-Language");
  //Fix for the bug 309625
  String strHeading = "emxComponentCentral.PotentialSuppliers.Heading";
  strbufURL.append("../common/emxIndentedTable.jsp?");  // Flat table to Structure Browser conversion
  strbufURL.append("&program=emxCompany:getSuppliers");
  strbufURL.append("&objectId=");
  strbufURL.append(companyId);
  strbufURL.append("&table=APPPotentialSuppliersSummary");
  strbufURL.append("&sortColumnName=Name");
  strbufURL.append("&sortDirection=ascending");
  strbufURL.append("&header=");
  strbufURL.append(strHeading);
  strbufURL.append("&selection=single");
// As part of addressing IR-100177V6R2012x, this toolbar is not required to be present here and
// the functionality can be achieved from going to Tools -> People and Organizations
//  strbufURL.append("&toolbar=APPPotentialSuppliersToolbar");
  strbufURL.append("&PrinterFriendly=true&HelpMarker=emxhelppotentialsuppliers");
  strbufURL.append("&suiteKey=ComponentCentral");

  if(submitButton !=null && submitButton.equalsIgnoreCase("true"))
  	strbufURL.append("&submitLabel=emxComponentCentral.Button.Submit&submitURL=../componentcentral/emxCPCPartAddSupplier.jsp");  // Flat table to Structure Browser conversion
}catch(Exception err){
	err.printStackTrace();
	}
%>
<body onLoad="javascript:PotentialSuppliersOnLoad();">
<form action="<%=strbufURL.toString()%>" name="PotentialSuppliers" method="post">
</form>
</body>

<script language="Javascript">
  function PotentialSuppliersOnLoad()
  {
    document.PotentialSuppliers.submit();
  }
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
