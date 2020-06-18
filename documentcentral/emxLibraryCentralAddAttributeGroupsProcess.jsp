<%--  emxLibraryCentralAddAttributeGroupsProcess.jsp
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<jsp:useBean id="attributeGroupBean" class="com.matrixone.apps.classification.AttributeGroup" scope="session"/>

<%
    final String PARAM_SELECTED_ATTRIBUTEGROUPS          = "selectedAttributeGroups";
    //----Getting parameter from request---------------------------


    String objectId                   = emxGetParameter(request, "objectId");
    StringList slAttrList            = new StringList();

    slAttrList = attributeGroupBean.getAttributeGroups();
    com.matrixone.apps.classification.Classification clsObject = (com.matrixone.apps.classification.Classification)DomainObject.newInstance(context, objectId, "Classification");
    clsObject.addAttributeGroups(context, slAttrList);
%>
<script language="javascript">
    try{
        getTopWindow().getWindowOpener().parent.document.location.href=getTopWindow().getWindowOpener().parent.document.location.href;
		//getTopWindow().closeWindow();
		// Changes added by PSA11 start(IR-553116-3DEXPERIENCER2018x).
		top.close();
		// Changes added by PSA11 end.
    }catch(e){
        getTopWindow().getWindowOpener().parent.refreshTablePage();
        //getTopWindow().closeWindow();
		// Changes added by PSA11 start(IR-553116-3DEXPERIENCER2018x).
		top.close();
		// Changes added by PSA11 end.		
    }
</script>
<%@include file ="../common/emxNavigatorBottomErrorInclude.inc"%>
