<%--  emxENCGetInstantData.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%
out.clear();
response.setContentType("text/plain; charset=UTF-8");

String strOut = "";
String comma = ",";

String functionality = emxGetParameter(request, "functionality");
String selectedChildType = emxGetParameter(request, "childType");
String parentType = emxGetParameter(request, "parentType");

if(!UIUtil.isNullOrEmpty(functionality) && functionality.equals("checkIsRawMaterialType")){
	boolean isOfParentType =  false;
	try{
		String typeRawMaterial = PropertyUtil.getSchemaProperty(context, parentType);
		isOfParentType = mxType.isOfParentType(context, selectedChildType, typeRawMaterial);
		strOut = String.valueOf(isOfParentType);
	}
	catch(Exception e){
		e.printStackTrace();
	}
}

%>
<%=strOut%>

