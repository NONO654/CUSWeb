<%-- emxCPCPartAddSupplier.jsp

   (c) Dassault Systemes, 1993-2016.  All rights reserved.

--%>

<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.ArrayList" %>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.common.Organization"%>
<%@page import="com.matrixone.apps.common.Company"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxCPCInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.MapList" %>
<%@ page import = "matrix.db.Context" %>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
String objName="";
String objCompanyID="";
try {
	String strPartIds = emxGetParameter(request, "emxTableRowId");
	StringTokenizer tokenizer = new StringTokenizer(strPartIds, "|");
	ArrayList objectSelects = new ArrayList();
	while(tokenizer.hasMoreTokens()){
		String id = tokenizer.nextToken();
		objectSelects.add(id);
	}

	DomainObject domainObject2=new DomainObject((String)objectSelects.get(1));
	objName = domainObject2.getInfo(context,DomainConstants.SELECT_NAME);
	objCompanyID = domainObject2.getInfo(context,DomainConstants.SELECT_ID);
} catch (Exception e){
	e.printStackTrace();

}

%>
<script language="javascript">
      getTopWindow().getWindowOpener().document.forms[0].SupplierDisplay.value = "<xss:encodeForJavaScript><%=objName%></xss:encodeForJavaScript>";
      getTopWindow().getWindowOpener().document.forms[0].SupplierOID.value = "<xss:encodeForJavaScript><%=objCompanyID%></xss:encodeForJavaScript>";
      getTopWindow().close();
</script>

