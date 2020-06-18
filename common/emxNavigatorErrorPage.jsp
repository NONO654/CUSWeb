<%--
   emxNavigatorError.jsp -- error page referenced by emxNavigatorInclude.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxNavigatorErrorPage.jsp.rca 1.8 Wed Oct 22 15:48:38 2008 przemek Experimental przemek $";
--%>

<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.*" isErrorPage="true"%>
<!DOCTYPE html>
<html>
<head>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<%
String errorCode = Request.getParameter(request,"errorCode");
if("401".equals(errorCode)){
%>
<script type="text/javascript">
if(getTopWindow() !== window){
	//XSSOK
	getTopWindow().location.href = "<%=Framework.getClientSideURL(response, "common/emxNavigatorErrorPage.jsp?errorCode=401")%>";	
}
</script>
<%
}
String contextPath = request.getContextPath();
matrix.db.Context context = null;//Framework.getContext(session);
try
{
  context = Framework.getFrameContext(session);
}
catch (Exception ex)
{
}
%>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<%@include file = "../emxMQLNotice.inc"%>
<style>
body.errorNotice {
	background-image:url(<%=XSSUtil.encodeForHTML(context, contextPath)%>/utilContentBackground.gif);
	font:normal 12px Verdana, Geneva, sans-serif;
}

#messageBox {
	margin: 50px;
	
	filter: progid:DXImageTransform.Microsoft.dropShadow(color=#818181, offX=17, offY=17, positive=true);
	box-shadow: 7px 7px 8px #818181;
	-webkit-box-shadow: 7px 7px 8px #818181;
	-moz-box-shadow: 7px 7px 8px #818181;
	
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#FFFFFF endColorstr=#BBBBBB);
	background:-webkit-gradient(linear, left getTopWindow(), left bottom, from(#fff), to(#bbb));
	background:-moz-linear-gradient(getTopWindow(), #fff, #bbb);
	
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
	-khtml-border-radius: 10px;
	border-radius: 10px;
	
	padding: 10px 20px 20px 20px;
	max-width: 50%;
	min-width: 300px;
	text-align:center;
		
		
	margin-left: auto;
	margin-right: auto;
	border: solid 4px #C30;
}
.errorNumber {
	font: bold 16px Arial, Geneva, sans-serif;
}
</style>
</head>
<body class="errorNotice">
<%
	String languageStr = Request.getLanguage(request);
	String error = null;
	String errorMessage = null;
	if("401".equals(errorCode)){
		error =  EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.ValidationError.CSRFError",request.getLocale());
		errorMessage =  EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.ValidationError.Message",request.getLocale());
	}else{
		error =  EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.ServerError.Error",request.getLocale());
		errorMessage =  EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.ServerError.Message",request.getLocale());
	}
%>

<div id="messageBox">
<div>
<img src="<%=XSSUtil.encodeForHTMLAttribute(context, contextPath)%>/common/images/iconStatusAlert.gif" height="48" width="48"/><br />
	<%
		if(errorCode != null && !"".equals(errorCode)){
			//XSSOK
			%><span class="errorNumber"><%=error%> : <%=XSSUtil.encodeForHTML(context,errorCode)%></span><%
		}else{
			//XSSOK
			%><span class="errorNumber"><%=error%></span><%
		}
	%>
</div><!-- //XSSOK -->
<%=errorMessage%></div>
</body>
</html>

