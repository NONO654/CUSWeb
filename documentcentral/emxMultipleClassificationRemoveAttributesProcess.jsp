<%--  emxMultipleClassificationRemoveAttributesProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxMultipleClassificationRemoveAttributesProcess.jsp.rca 1.1.2.1 Wed Oct 22 16:54:23 2008 przemek Experimental przemek $";

   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../documentcentral/emxMultipleClassificationUtils.inc" %>

<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">


</script>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>
<%

	String strAttr = "";
	String parentId = emxGetParameter(request, "parentId");
	String selectedAttributes = emxGetParameter(request, "selectedAttributes");
	AttributeGroup attrGrp = new AttributeGroup();
	StringList strAttrList = new StringList();
	StringTokenizer strTokens = new StringTokenizer(selectedAttributes,",");
	while (strTokens.hasMoreTokens())
	{
		  strAttr = strTokens.nextToken();
		  strAttrList.addElement(strAttr);
	}
	attrGrp.setName(parentId);
	attrGrp.removeAttributes(context,strAttrList);
%>
<script language="javascript">
getTopWindow().refreshTablePage();
</script>
