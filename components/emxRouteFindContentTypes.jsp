<%--  emxRouteFindContentTypes.jsp - The processing page for  main search Type Chooser

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

	  static const char RCSID[] = $Id: emxRouteFindContentTypes.jsp.rca 1.7 Wed Oct 22 16:18:26 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@include file = "../emxJSValidation.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
 String searchTypes = "";
 String relType=DomainObject.RELATIONSHIP_OBJECT_ROUTE;
 String sDocType = PropertyUtil.getSchemaProperty(context, "type_Document");
 String fldName=emxGetParameter(request, "fieldNameDisplay");

 String mqlCmd = "print relationship \"" + relType + "\" select fromtype dump";

 // Use the list returned from mql to populate
 // the type chooser
 //
 try
 {
   searchTypes = MqlUtil.mqlCommand(context, mqlCmd);
   String strMemberListType = PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_type_MemberList);
   if(searchTypes.contains(strMemberListType) ){
	   searchTypes=searchTypes.replace(strMemberListType,"");
   }
 }
 catch (FrameworkException fe)
 {
   searchTypes = " ";
 }
%>
<HTML>
<body>
<form name="TypeChooser" method="post">
<input type="hidden" name="InclusionList" value="<xss:encodeForHTMLAttribute><%=searchTypes%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sDocType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="selTypeDisplay" value="Document" />

<script language="javascript">
strURL = "../common/emxTypeChooser.jsp?fieldNameActual=selType&fieldNameDisplay=<%=XSSUtil.encodeForURL(context, fldName)%>&formName=frmPowerSearch&ShowIcons=true&ObserveHidden=false&SelectType=&SelectAbstractTypes=true";
</script>
<%
if (emxGetParameter(request, "fromPage").equals("FullSearch"))

{
	
	
	%>
	<script language="javascript">
	strURL = "../common/emxTypeChooser.jsp?formName=full_search&frameName=window&fieldNameActual=hidden_ADDCONTENTTYPE&fieldNameDisplay=ADDCONTENTTYPE&ShowIcons=true&SelectAbstractTypes=true&ObserveHidden=false";
	</script>
	
<%	
}
%>
	<script language="javascript">
document.TypeChooser.action=strURL;
document.TypeChooser.submit();
</script>
</form>
</body>
</HTML>
