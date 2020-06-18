<%--  emxLibraryCentralAddAttributesProcess.jsp
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program
 --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../documentcentral/emxMultipleClassificationUtils.inc" %>
<jsp:useBean id="attributeBean" class="com.matrixone.apps.classification.AttributeGroup" scope="session"/>

<%
    final String PARAM_SELECTED_ATTRIBUTES          = "selectedAttributes";
     //----Getting parameter from request---------------------------
    String parentId           = emxGetParameter(request, "parentId");
    //parentId = FrameworkUtil.decodeURL(parentId, strCharSet);
    StringList slAttrList     = new StringList();
    slAttrList                = attributeBean.getAttributes();
    AttributeGroup agObject         = new AttributeGroup();
    agObject.setName(parentId);
    agObject.addAttributes(context,slAttrList);
%>

<script language="javascript">
try {
	// Changes added by PSA11 start(IR-551461-3DEXPERIENCER2018x).
	var refreshURL = getTopWindow().opener.document.location.href;
	refreshURL = refreshURL.replace("persist=true","persist=false");
	getTopWindow().opener.document.location.href = refreshURL;
	// Changes added by PSA11 end.
    getTopWindow().closeWindow();
}catch(e){
    getTopWindow().getWindowOpener().refreshTablePage();
    getTopWindow().closeWindow();
}
</script>
