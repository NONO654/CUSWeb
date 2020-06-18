<%--
   emxLibraryCentralAtrributeGroupNameValidation.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file ="../emxUICommonAppInclude.inc"%>
<%@include file ="../documentcentral/emxLibraryCentralUtils.inc"%>

<% 
    String attributeGroupName   = emxGetParameter(request,"AGName");
    AttributeGroup attrGrp      = AttributeGroup.getInstance(context,attributeGroupName);
    String isAGNameExists       = "false";
    if (!UIUtil.isNullOrEmpty(attrGrp.getName())) {
        isAGNameExists          = "true";
    }
    out.clear();
    out.println("<isAGNameExists>" + isAGNameExists + "</isAGNameExists>");
%>
