<%--
	CharacteristicMaster3dSearchIntermediate.jsp

   Copyright (c) 2007-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Enovia MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.
--%>	
<%-- k3d : for handling 3dSearch as window-shade & pop-up  --%>
<%@page import="java.util.Map"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%
	Map<String, String[]> parameters	= request.getParameterMap();
	
	String key			= null;
	String[] valArrays	= null;
	StringBuilder sbUrl	= new StringBuilder();
	sbUrl.append("../common/emxFullSearch.jsp?");
	
	for (Map.Entry<String, String[]> entry : parameters.entrySet()) {
		key			= entry.getKey();
		valArrays	= entry.getValue();
		
		for (String val : valArrays) {
			sbUrl.append('&');
			sbUrl.append(key);
			sbUrl.append('=');
			sbUrl.append(val);
		}
	}
%>
<script>
	showModalDialog("<%=XSSUtil.encodeForJavaScript(context, sbUrl.toString()) %>");
</script>
