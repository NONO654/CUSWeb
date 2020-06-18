<%--  emxLoadToolbar.jsp : to get the toolbar object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   AUTHOR: Anup Patel (AP3) 27/08/13
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%
String toolbar   = emxGetParameter(request, "toolbar");
String objectId  = emxGetParameter(request, "objectId");
if(UIUtil.isNotNullAndNotEmpty(toolbar)){
	Vector userRoleList = PersonUtil.getAssignments(context);
	String language     = request.getHeader("Accept-Language");
	HashMap requestMap  = UINavigatorUtil.getRequestParameterMap(request);
	HashMap tempMap     = UITreeUtil.getToolbar(context,toolbar,userRoleList,objectId,requestMap,language);
    String catObj       = UIToolbar.loadCategoryToolbar(context, tempMap, requestMap, null).toString();
    out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(catObj);
	return;
}
%>
