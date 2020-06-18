<html>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>

<head>
</head>
<%
	//emxFramework.LicenseRefresh.Failure=License refresh has failed. Please try Again in some time.
	//emxFramework.LicenseRefresh.Success=License for $1 has been refreshed successfully.
	try{
		matrix.util.LicenseUtil.refreshAuthorizedProducts(context);
		String successMsg = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.LicenseRefresh.Success");
		successMsg = successMsg.replace("$1", context.getUser());
		emxNavErrorObject.addMessage(successMsg);
	}catch(Exception e){
		String failureMsg = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.LicenseRefresh.Failure");
		emxNavErrorObject.addMessage(failureMsg);
	}

%>
<body>
	<%@include file="emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
