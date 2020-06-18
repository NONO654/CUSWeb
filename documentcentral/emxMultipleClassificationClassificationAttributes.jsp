<%--  emxClassificationAttributes.jsp   -
    This page queries the required data from database to display
    the required properties for Generic Document

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "";
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%
try {
	String oid = emxGetParameter(request, "objectId");
	String mode = emxGetParameter(request, "mode");
	String manualEdit = emxGetParameter(request, "manualedit");
	String editable = emxGetParameter(request, "Editable");
	String suiteKey = emxGetParameter(request,"suiteKey");

	if (mode == null) {
		mode = "view";
	}

	if (editable == null) {
		editable = "False";
	}

	if (suiteKey == null) {
		suiteKey = "Framework";
	}

	if (manualEdit == null) {
		manualEdit = "False";
	}

	String maxColsStr = emxGetParameter(request, "maxCols");
	if (maxColsStr == null) {
		maxColsStr = "2";
	}

	Integer maxCols = new Integer(Integer.parseInt(maxColsStr));

	HashMap mainMap = new HashMap();
	HashMap paramMap = new HashMap();
	HashMap requestMap = new HashMap();
	HashMap settingMap = new HashMap();
	HashMap fieldMap = new HashMap();

	//Fill in the Request Map

	requestMap.put("mode", mode);
	requestMap.put("languageStr", request.getHeader("Accept-Language"));
	requestMap.put("localeObj", request.getLocale());
	requestMap.put("timeZone",(String)session.getValue("timeZone"));

	//Fill in the field setting map
	settingMap.put("Registered Suite", suiteKey);
	settingMap.put("Field Type", "ClassificationAttributes");
	settingMap.put("Allow Manual Edit", manualEdit);
	settingMap.put("Editable", editable);

	//Fill in the fields Map
	fieldMap.put("settings", settingMap);

	//Fill in Param Map
	paramMap.put("objectId", oid);

	//Fill in Main Map
	mainMap.put("requestMap", requestMap);
	mainMap.put("paramMap", paramMap);
	mainMap.put("fieldMap", fieldMap);
	mainMap.put("maxCols", maxCols);




	String[] args = JPO.packArgs(mainMap);
	String[] constructor = { null };


	String clsHtml = (String) JPO.invoke(context,
			"emxMultipleClassificationAttributeFormHtml", constructor,
			"getHTMLFields", args, String.class);
	pageContext.getOut().print("<TR>" + clsHtml + "</TR>");
} catch (Exception e) {
	System.out.println(e.getMessage());
	e.printStackTrace();
}

%>
