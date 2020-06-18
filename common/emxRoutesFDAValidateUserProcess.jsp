<%--  
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@  include file = "../emxUICommonAppInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UINavigatorUtil,com.matrixone.apps.domain.util.BackgroundProcess" %>
<%@ page import="java.util.Base64" %>
<%
String username = new String(Base64.getDecoder().decode(emxGetParameter(request,"userName")));
String pwd = new String(Base64.getDecoder().decode(emxGetParameter(request,"passWord")));
boolean showUserName = "true".equalsIgnoreCase(emxGetParameter(request, "showUserName"));

String contextUser = context.getUser();
String contextPassword = context.getPassword();
String strLanguage = request.getHeader("Accept-Language");
boolean bcasesensitive = true;
boolean bExternalAuth = "TRUE".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxFramework.External.Authentication"));

String strResult = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context, "print system casesensitive", true);
if(strResult != null)
{
	matrix.util.StringList strlTemp = com.matrixone.apps.domain.util.FrameworkUtil.split(strResult,"=");

	if(strlTemp != null && strlTemp.size() > 0 && "off".equalsIgnoreCase( (String) strlTemp.get(1)))
	{
	    bcasesensitive = false;
	}
}

if(!showUserName)
{
 username = contextUser;
}

if(!bcasesensitive) {
    username = username.toLowerCase();
    contextUser = contextUser.toLowerCase();
}

String i18NInvalidUserPassword = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Login.InvalidUserPassword");
String result = "<result>success</result>";
String message = "<errorMsg><![CDATA[]]></errorMsg>";
boolean bXMLResponseTag = true;

if (bExternalAuth) {
	if (showUserName && username.equals(contextUser)) {
		//
	    // For R2015x only!
	    // If passport URL exist then go to 3DPassport server, else there may be other external authentication mechanism
	    // and we fall out to the authentication using context object
	    //
	   	String passportURL = PropertyUtil.getEnvironmentProperty(context, "PASSPORT_URL");
	    boolean is3DPassportServerInUse = (passportURL != null && passportURL.length() > 0);
	    try {
			PersonUtil.checkFDAAuthentication(context, username, pwd, passportURL, is3DPassportServerInUse, session, bXMLResponseTag);				
		} catch (Exception er) {
			String sErrMsg    = er.getMessage();
			String[] aXMLTags = sErrMsg.split(":");	
			result 	= aXMLTags[0];
			message = aXMLTags[1];		
		}	   	
	}else {
		result = "<result>fail</result>";
        message = "<errorMsg> <![CDATA[" + i18NInvalidUserPassword + "]]> </errorMsg>";
	} 
} else {
    String strMaxCount = EnoviaResourceBundle.getProperty(context, "emxFramework.Routes.VerificationCount");
    String strCount = (String)session.getValue("VerificationCount");
    int maxCount = Integer.parseInt(strMaxCount);
    int count = (strCount != null && !"".equals(strCount))?Integer.parseInt(strCount):0;

	if(!(username.equals(contextUser) && pwd.equals(context.getPassword()))) {
	    if(count == maxCount-1) {
	        com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
	        matrix.util.StringList personIds = new matrix.util.StringList();
	        personIds.add(person.getId());

	        //send notification to people configured in property file
	        String notificationUsers = EnoviaResourceBundle.getProperty(context, "emxFramework.Routes.NotifyPeople");
	        String subject = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Routes.PersonInactivatedMessage");
	        String mailMessage = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Routes.PersonInactivatedSubject");
	        if(notificationUsers != null)
	        {
	         matrix.util.StringList notificationUserList = com.matrixone.apps.domain.util.FrameworkUtil.split(notificationUsers,",");
	         com.matrixone.apps.domain.util.MailUtil.sendMessage(context,
	                                    notificationUserList,
	                                    null,
	                                    null,
	                                    subject,
	                                    context.getUser() + " " + mailMessage,
	                                    null);
	        }

	        try {	            
	            BackgroundProcess backgroundProcess = new BackgroundProcess();
	            Object objectArray[]	 = {context, personIds};
	            Class objectTypeArray[]  = {context.getClass(),personIds.getClass()};
	            Person object = new Person(person.getId());
	            backgroundProcess.submitJob(context, person, "deactivatePersonInBackGround", objectArray, objectTypeArray);
	        } catch(Exception ex) {
	        	session.invalidate();
	            throw new FrameworkException(ex);
	        }
	        //person.triggerDemoteAction(context, personIds);
	        session.invalidate();

	        String failedAuthentication1 = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.UserAuthentication.Fail1");
	        String failedAuthentication2 = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.UserAuthentication.Fail2");
	        
            result = "<result>block</result>";
            message = "<errorMsg> <![CDATA["+failedAuthentication1 + " " + maxCount + " " + failedAuthentication2+ "]]> </errorMsg>";            
	    } else {
            result = "<result>fail</result>";
            message = "<errorMsg> <![CDATA["+i18NInvalidUserPassword+ "]]> </errorMsg>";            
	        session.putValue("VerificationCount", new Integer(++ count).toString());
	    }
	} else {
	    session.removeAttribute("VerificationCount");
	}
}
out.clear();
out.println("<mxFDAAuth>" + result + message +"</mxFDAAuth>");
%>
