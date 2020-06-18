<%--  emxComponentsValidateUserProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsValidateUserProcess.jsp.rca 1.14 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>


<html>
<body>

<form name="newForm" method="post">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<%
String username = emxGetParameter(request,"userName");
String pwd = emxGetParameter(request,"passWord");
String showUserName = emxGetParameter(request,"showUserName");
String fromPage = emxGetParameter(request,"fromPage");
String keyValue = emxGetParameter(request,"keyValue");
// Added for bug 354935
boolean bcasesensitive = true;
String strQuery = "print system casesensitive";
String strResult = MqlUtil.mqlCommand(context,strQuery);
if(strResult != null)
{
	StringList strlTemp = FrameworkUtil.split(strResult,"=");

	if(strlTemp != null && strlTemp.size() > 0 && "off".equalsIgnoreCase( (String) strlTemp.get(1)))
	{
	    bcasesensitive = false;
	}
}
// Ended
if("false".equalsIgnoreCase(showUserName))
{
 username = (context.getUser()).toString();
}
String errMsg = null;
String sExternalAuth = EnoviaResourceBundle.getProperty(context,"emxFramework.External.Authentication");
boolean bExternalAuth = false;
if (sExternalAuth != null && sExternalAuth.equalsIgnoreCase("TRUE"))
{
    bExternalAuth = true;
}

if (bExternalAuth) {
	if ("true".equalsIgnoreCase(showUserName) && ((bcasesensitive)?!username.equals(context.getUser()):!username.equalsIgnoreCase(context.getUser())))
        {
            Exception e = new Exception("Invalid User Name");
            throw e;
        }
	if ("true".equalsIgnoreCase(showUserName) && username.equals(context.getUser())) {
		String passportURL = PropertyUtil.getEnvironmentProperty(context, "PASSPORT_URL");
		boolean is3DPassportServerInUse = (passportURL != null && passportURL.length() > 0);
		try {
			//The last argument if passed as true will give the alert in XML Tag format.
			PersonUtil.checkFDAAuthentication(context, username, pwd, passportURL, is3DPassportServerInUse, session, false);
		} catch (Exception er) {
			String sErrMsg = er.getMessage();
			%>

<script language="Javascript">
alert("<%=XSSUtil.encodeForJavaScript(context, sErrMsg)%>");
parent.window.location.href =parent.window.location.href;
</script>

<%
			return;
		}
	}
} else {
    String strMaxCount = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.VerificationCount");
    String strCount = (String)session.getValue("VerificationCount");
    int maxCount = Integer.parseInt(strMaxCount);
    int count = (strCount != null && !"".equals(strCount))?Integer.parseInt(strCount):0;

    if(count == maxCount-1 && (((bcasesensitive)?!username.equals(context.getUser()):!username.equalsIgnoreCase(context.getUser())) || !pwd.equals(context.getPassword())))
    {
        com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
        StringList personIds = new StringList();
        personIds.add(person.getId());

        //send notification to people configured in property file
        String notificationUsers = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.NotifyPeople");
        String subject = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Routes.PersonInactivatedMessage", context.getLocale());
        String message = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Routes.PersonInactivatedSubject", context.getLocale());
        if(notificationUsers != null)
        {
         StringList notificationUserList = FrameworkUtil.split(notificationUsers,",");
         MailUtil.sendMessage(context,
                                    notificationUserList,
                                    null,
                                    null,
                                    subject,
                                    context.getUser() + " " + message,
                                    null);
        }

        person.triggerDemoteAction(context,personIds);
        session.invalidate();

        String failedAuthentication1 = ComponentsUtil.i18nStringNow("emxComponents.UserAuthentication.Fail1",request.getHeader("Accept-Language"));
        String failedAuthentication2 = ComponentsUtil.i18nStringNow("emxComponents.UserAuthentication.Fail2",request.getHeader("Accept-Language"));
        errMsg = failedAuthentication1 + " " + maxCount + " " + failedAuthentication2;
%>

<script language="Javascript">
alert("<%=XSSUtil.encodeForJavaScript(context, errMsg)%>");
window.closeWindow();
</script>

<%

        return;
    }
    else if (((bcasesensitive)?!username.equals(context.getUser()):!username.equalsIgnoreCase(context.getUser())) || !pwd.equals(context.getPassword()))
    {
        session.putValue("error.message",ComponentsUtil.i18nStringNow("emxComponents.UserAuthentication.Error",request.getHeader("Accept-Language")));
        session.putValue("VerificationCount",new Integer(++ count).toString());
%>

<script language="Javascript">
  //parent.window.getWindowOpener().parent.location.reload();
  //getTopWindow().close();
  parent.window.location.reload();
</script>

<%
        return;
    }
    else
    {
        session.removeAttribute("VerificationCount");
    }
}
if( (fromPage == null) || (fromPage.equals("")))
{
%>

 <input type="hidden" name="taskId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"taskId")%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"routeId")%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="approvalStatus" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"approvalStatus")%></xss:encodeForHTMLAttribute>" />
    <!-- Added for the Bug 319287 Begin -->
     <input type="hidden" name="Comments" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"Comments")%></xss:encodeForHTMLAttribute>" />
    <!-- Added for the Bug 319287  End -->
    <!-- Added for the Bug 359515 Begin -->
     <input type="hidden" name="isEncoded" value='true' />
    <!-- Added for the Bug 359515  End -->    
    <input type="hidden" name="flag" value="fda" />

   <script language="javascript" type="text/javascript">
   document.newForm.method = "post";
   document.newForm.action = "emxTaskCompleteProcess.jsp";
   document.newForm.submit();
  </script>
<%
}else{
%>
  <script language="javascript" type="text/javascript">
   document.newForm.method = "post";
   document.newForm.action = "emxUserTasksSummaryLinksProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&fromPage=<%=XSSUtil.encodeForURL(context, fromPage)%>&isFDAEntered=true&returnBack=true";
   document.newForm.submit();
  </script>
<%
}
%>
</form>
</body>
</html>
