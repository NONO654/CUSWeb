<%--
   emxLibraryCentralClassificationAttributeValidation.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@page import="com.matrixone.apps.classification.ClassificationAttributesCreationUtil"%>
<%@include file ="../emxUICommonAppInclude.inc"%>

<% 
String attrName = "";

Enumeration paramNames = emxGetParameterNames(request);
while (paramNames.hasMoreElements()) {
	String paramName = (String) paramNames.nextElement();
	String paramValue = emxGetParameter(request, paramName);
	if(paramName.equals("Name")){
		attrName = paramValue;
		break;
	}
}

StringBuilder sbName = new StringBuilder();		
String[] nameSplit = attrName.split(" ");
for(int i = 0; i < nameSplit.length; i++){
	if(nameSplit[i].length() > 0){
		if(sbName.length() > 0)
			sbName.append(" ");
		sbName.append(nameSplit[i]);
	}
}
attrName = sbName.toString();

attrName = ClassificationAttributesCreationUtil.checkIfAttributeExists(context, attrName);
out.clear();
out.println("<ValidationError>"+attrName+"</ValidationError>");
%>
