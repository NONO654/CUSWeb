<%--  emxXMLError.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%
//String Resource file to be used
String ResFileId = "emxFrameworkStringResource";
String pageTopic = emxGetParameter(request, "pageTopic");
String htmlFile = emxGetParameter(request, "htmlFile");

String STR_ERROR_HELP = "";

if((pageTopic == null || "".equals(pageTopic) || "null".equals(pageTopic)) && (htmlFile == null || "".equals(htmlFile) || "null".equals(htmlFile))){
	try{
	STR_ERROR_HELP = UINavigatorUtil.getI18nString("emxFramework.XMLHelp.ErrorMessage", ResFileId, request.getHeader("Accept-Language"));
	}catch (Exception ex){
		// String must not have been in Properties file
	}
} else if ((pageTopic != null))
{
	String[] messageValues = new String[2];
	messageValues[0] = pageTopic;
	STR_ERROR_HELP = MessageUtil.getMessage(context,null,
	                                 "emxFramework.XMLHelp.ErrorMessage2",
	                                 messageValues,null,
	                                 request.getLocale(),ResFileId);
}
else if ((htmlFile != null)){
    String[] msgValues = new String[2];
    msgValues[0] = htmlFile;
    STR_ERROR_HELP = MessageUtil.getMessage(context,null,
                                     "emxFramework.XMLHelp.ErrorMessage3",
                                     msgValues,null,
                                     request.getLocale(),ResFileId);
}
STR_ERROR_HELP = XSSUtil.encodeForHTML(context, STR_ERROR_HELP);
 out.clear();
%><%=STR_ERROR_HELP%>
