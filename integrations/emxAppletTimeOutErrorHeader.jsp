<%--  emxAppletTimeOutErrorHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file = "MCADTopInclude.inc" %>
<%
	String acceptLanguage		= request.getHeader("Accept-Language");
	String I18NResourceBundle	= "emxIEFDesignCenterStringResource";
	String errorMessage			= UINavigatorUtil.getI18nString("emxIEFDesignCenter.Common.ERROR", "emxIEFDesignCenterStringResource", acceptLanguage);
%>

<html>
<head>
    <!--XSSOK-->
	<title><%=errorMessage%></title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>

<body>
	<form name="attributeSearchOptions">
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>&nbsp;</tr>
		<tr>
            <td><img src="images/utilSpace.gif" width="1" height="1"></td>
        </tr>
        <tr>
            <td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
        </tr>
        </table>
        <table border="0" width="100%" cellpadding="0">
        <tr>
		    <!--XSSOK-->
            <td class="pageHeader"><%=errorMessage%></td>
        </tr>
        </table>
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
        </tr>
        </table>
        <table border="0" cellspacing="0" cellpadding="0" width="100%">       	
    </table>
	</form>
</body>
</html>
