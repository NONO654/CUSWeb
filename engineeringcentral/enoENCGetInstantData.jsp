<%--  enoENCGetInstantData.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.util.PartMgtUtil"%>
<%
out.clear();
response.setContentType("text/plain; charset=UTF-8");

String strOut = "";
String comma = ",";

String functionality = emxGetParameter(request, "functionality");

if(("checkIsRawMaterialType").equals(functionality)){
	boolean isOfParentType =  false;
		String selectedChildType = emxGetParameter(request, "childType");
		String parentType = emxGetParameter(request, "parentType");
		String typeRawMaterial = PropertyUtil.getSchemaProperty(context, parentType);
		isOfParentType = mxType.isOfParentType(context, selectedChildType, typeRawMaterial);
		strOut = String.valueOf(isOfParentType);

}

else if(("checkifChangeEnabled").equals(functionality)){
	String objectId = emxGetParameter(request, "objectId");
	boolean isChangeControlled = PartMgtUtil.isChangeControlled(context, objectId);
	strOut = String.valueOf(isChangeControlled);
}

%>
<%=strOut%>

