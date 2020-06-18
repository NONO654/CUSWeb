<html>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="java.io.*" %>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >  
	<script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
	<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
	<link rel="stylesheet" type="text/css" href="../common/styles/emxUIForm.css">	
	
</head>

<%
	String noCustoAttrMsg = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.label.NoCustoAttributeMsg");
	//String noCustoAttrMsg = "No Extension attributes to edit on this object "; 
%>
	<body>
		<form  name="formEditDisplay" method="post" onSubmit="submitForm();">
			<div id="error">
			  <h2><%= noCustoAttrMsg %></h2>
			</div>
		</form>
	</body>
<script language="javascript" type="text/javaScript">
function submitForm()
{
	top.closeSlideInDialog();
}
</script>
</html>
