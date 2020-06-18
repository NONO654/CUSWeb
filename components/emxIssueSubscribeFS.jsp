<%--  emxIssueSubscribeFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxIssueSubscribeFS.jsp.rca 1.1.7.5 Wed Oct 22 16:17:46 2008 przemek Experimental przemek $
   21:36:41 ajoseph Exp $"
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>



<%
	String objectId = emxGetParameter(request, "objectId");
	String suiteKey = emxGetParameter(request, "suiteKey");
	String strHelpMarker = emxGetParameter(request,"HelpMarker");
	String strLanguage = request.getHeader("Accept-Language");
	String pageHeader = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.Subscription.PageHeader");
	pageHeader = UINavigatorUtil.parseHeader(context, pageContext, pageHeader, objectId, "Framework", strLanguage);
    if(pageHeader == null || pageHeader.trim().length() == 0)
    {
    	pageHeader = "Subscription";
    }

    // Create Frameset Object
    framesetObject fs = new framesetObject();
    fs.useCache(false);
    fs.setDirectory(appDirectory);

   StringBuffer sfb = new StringBuffer();
	boolean appendAmp = false;
	Enumeration enumParamNames = request.getParameterNames();
	while(enumParamNames.hasMoreElements()) {
	    String paramName = (String) enumParamNames.nextElement();
	    String paramValue = request.getParameter(paramName);

	    if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue)) {
	        if(appendAmp)
	        	sfb.append("&");
	        else
	        	appendAmp = true;

	        sfb.append(paramName);
	        sfb.append("=");
	        sfb.append(paramValue);
	    }
	}



    // Setting String resourse Property File
    fs.setStringResourceFile("emxComponentsStringResource");

    // Specify URL to come in middle of frameset
    StringBuffer contentUrl =
                new StringBuffer("emxPushSubscriptionBody.jsp?");
    
    contentUrl.append(sfb.toString());
    
    // ------------------Init Frameset-----------------------------------------
    // initFrameset(java.lang.String pageHeading, java.lang.String helpMarker,
    //            java.lang.String contentURL, boolean UsePrinterFriendly,
    //            boolean IsDialogPage, boolean ShowPagination, boolean
    //                                       ShowConversion)
    fs.initFrameset(pageHeader,strHelpMarker,contentUrl.toString(),
                                            false,false,false,false);
    fs.writePage(out);
%>


