<%--  emxUITopPageInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "../emxUITopInclude.inc"%>
<%
 String retstr = "";
 String paramValue = emxGetParameter(request, "paramValue");
 retstr = XSSUtil.encodeForHTMLAttribute(context, paramValue);
/*
 String encodeType = emxGetParameter(request, "encodeType");
 String decodeType = emxGetParameter(request, "decodeType");
 if(decodeType != null  && !"".equals(decodeType)  ) 
 {
	 switch(decodeType.toLowerCase())
	 {
	 	case "htmlattribute" :
	 		retstr = XSSUtil.decodeForHTMLAttribute(context, paramValue);
	 		break;
	 	case "url" :
			retstr = XSSUtil.decodeForURL(context, paramValue);
			break;
	 	case "javascript" :
			retstr = XSSUtil.decodeForJavaScript(context, paramValue);
			break;
	 	case "html" :
			retstr = XSSUtil.decodeForHTML(context, paramValue);
			break;
	 	case "css" :
	 		retstr = XSSUtil.decodeForCSS(context, paramValue);
	 		break;
	 	case "xml" :
			retstr = XSSUtil.decodeForXML(context, paramValue);
			break;
	 	default:
	 		retstr = XSSUtil.decodeForHTMLAttribute(context, paramValue);
	 		break;
	 }
 } else {
	 switch(encodeType.toLowerCase())
	 {
	 	case "htmlattribute" :
	 		retstr = XSSUtil.encodeForHTMLAttribute(context, paramValue);
	 		break;
	 	case "url" :
			retstr = XSSUtil.encodeForURL(context, paramValue);
			break;
	 	case "javascript" :
			retstr = XSSUtil.encodeForJavaScript(context, paramValue);
			break;
	 	case "html" :
			retstr = XSSUtil.encodeForHTML(context, paramValue);
			break;
	 	case "css" :
	 		retstr = XSSUtil.encodeForCSS(context, paramValue);
	 		break;
	 	case "xml" :
			retstr = XSSUtil.encodeForXML(context, paramValue);
			break;
	 	default:
	 		retstr = XSSUtil.encodeForHTMLAttribute(context, paramValue);
	 		break;
	 }
 }
*/
%>
  <%=retstr%>
