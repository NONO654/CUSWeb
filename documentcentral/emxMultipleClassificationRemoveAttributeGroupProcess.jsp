<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: This page is used to delete business objects
   Parameters :


   Author     :
   Date       :
   History    :


   static const char RCSID[] = $Id: emxMultipleClassificationRemoveAttributeGroupProcess.jsp.rca 1.7 Wed Oct 22 16:54:21 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../documentcentral/emxMultipleClassificationUtils.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
//String timeStamp = emxGetParameter(request, "timeStamp");
//HashMap requestMap = tableBean.getRequestMap(timeStamp);
//String parentId = (String)requestMap.get("objectId");

    StringBuffer selectedAttributeGroupss = new StringBuffer();

    String parentId = emxGetParameter(request, "objectId");
//  System.out.println("parentId: " + parentId);
    //String objIds[] = emxGetParameterValues(request,"emxTableRowId");
    String objIds = emxGetParameter(request,"rowids");

    StringList strAttrList =new StringList();
    String sObjId = "";
    StringTokenizer st   = new StringTokenizer(objIds,"|");
    while(st.hasMoreTokens())
    {
        sObjId   = st.nextToken();
        strAttrList.addElement(sObjId);
    }


    try {
        com.matrixone.apps.classification.Classification cls = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, parentId, "Classification");
        cls.removeAttributeGroups(context, strAttrList);
    }
    catch(Exception e){
        emxNavErrorObject.addMessage(e.toString().trim());
    }


%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript">

try{
    parent.document.location.href=parent.document.location.href;
}catch(e)
{
    getTopWindow().refreshTablePage();
    getTopWindow().closeWindow();
}
</script>




