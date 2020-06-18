<%--  emxEngrMarkupChangeProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<script type="text/javascript" src="../common/scripts/emxUIModal.js "></script>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%
String formName = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "formName"));
String fieldNameDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameDisplay"));
String fieldNameActual = emxGetParameter(request, "fieldNameActual");
String selectedItem = emxGetParameter(request, "emxTableRowId");
StringTokenizer strTokens = new StringTokenizer(selectedItem,"|");
String objectId = XSSUtil.encodeForJavaScript(context,strTokens.nextToken());
DomainObject dom = new DomainObject(objectId);
String name = dom.getInfo(context,DomainConstants.SELECT_NAME);

//Added for Bug 356795 starts
String sType = dom.getInfo(context,DomainConstants.SELECT_TYPE);
String sRev = dom.getInfo(context,DomainConstants.SELECT_REVISION);
i18nNow i18nInstance = new i18nNow();
String sLanguage = request.getHeader("Accept-Language");
//String sAccessAlert = (String)i18nInstance.GetString("emxEngineeringCentralStringResource", sLanguage,"emxEngineeringCentral.Common.NoFromConnectAccess");
String sAccessAlert = (String)EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.NoFromConnectAccess");
sAccessAlert+=" "+sType+" "+name+" "+sRev;
Access access = new Access();
access = dom.getAccessMask(context);
boolean accessFromConnect = access.hasFromConnectAccess();
//Added for Bug 356795 ends

%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
function selectDone()
{
	//Added for Bug 356795 starts
	//XSSOK
	var access = "<%= accessFromConnect %>";
	if(access=='true')
	{
	//Added for Bug 356795 ends
	//XSSOK
    getTopWindow().getWindowOpener().document.<%=formName%>.<%=fieldNameDisplay%>.value = "<%= name %>";
    //XSSOK
    getTopWindow().getWindowOpener().document.<%=formName%>.<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>.value = "<%= objectId %>";
    //XSSOK
    if("<%=fieldNameDisplay%>" == "partToRemove") {
    	//XSSOK
    	getTopWindow().getWindowOpener().document.<%=formName%>.objectId.value = "<%= objectId %>";
    }
    getTopWindow().closeWindow();
	
	//Added for Bug 356795 starts
	}
	else
	{
		//XSSOK
		alert("<%=sAccessAlert%>");
		return;
	}
	//Added for Bug 356795 ends
}
</script>
<html>
<body onload=selectDone()>
