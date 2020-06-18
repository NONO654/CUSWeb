<%--  emxMultipleClassificationAddAttributesProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program



  static const char RCSID[] = $Id: emxMultipleClassificationAddAttributesProcess.jsp.rca 1.1.2.1 Wed Oct 22 16:54:24 2008 przemek Experimental przemek $

   --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../documentcentral/emxMultipleClassificationUtils.inc" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%
	final String PARAM_SELECTED_ATTRIBUTES          = "selectedAttributes";
     //----Getting parameter from request---------------------------


	String parentId = "";
	parentId = emxGetParameter(request, "parentId");
	String selectedAttributes = "";
	selectedAttributes= emxGetParameter(request, PARAM_SELECTED_ATTRIBUTES);
	String strAttr = "";
	HashMap requestMap = new HashMap();

	StringList strAttrList = new StringList();
    StringTokenizer strTokens = new StringTokenizer(selectedAttributes,";");
	while (strTokens.hasMoreTokens())
	{
		  strAttr = strTokens.nextToken();
		  strAttrList.addElement(strAttr);
	}
	AttributeGroup ag = new AttributeGroup();
	ag.setName(parentId);
	ag.addAttributes(context,strAttrList);
%>
<script language="javascript">

try{
parent.window.getWindowOpener().parent.document.location.href=parent.window.getWindowOpener().parent.document.location.href;
parent.closeWindow();
}catch(e)
{
	getTopWindow().refreshTablePage();
	getTopWindow().closeWindow();
}
</script>
