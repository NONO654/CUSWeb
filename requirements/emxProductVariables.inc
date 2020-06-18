
<%--  emxProductVariables.inc

 Define globals for the Product Central Suite

 Copyright (c) 1992-2018 Dassault Systemes.

 All Rights Reserved.
 This program contains proprietary and trade secret information
 of MatrixOne, Inc.  Copyright notice is precautionary only and
 does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: /ENORequirementsManagementBase/CNext/webroot/requirements/emxProductVariables.inc 1.3.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$
--%>

<%
  
  // Get suite sub-directory name from properties file.
	final String  suiteDir = EnoviaResourceBundle.getProperty(context,
          "eServiceSuiteRequirements.Directory");

	final String  appDirectory = EnoviaResourceBundle.getProperty(context,
          "eServiceSuiteRequirements.Directory");

  // Get the proxy prefix.
	String  proxy = Framework.getPropertyValue("ematrix.proxy.server");
  if (proxy == null) {
    proxy = "";
  }

  // Get the URL for the top ematrix directory.
  final String topUrl = proxy + Framework.getPropertyValue("ematrix.page.path");

  // Get the URL for the suite.
	final String suiteUrl = topUrl + "/" + suiteDir;

  // Get the URL for the images.
  final String imagesUrl = suiteUrl + "/images";

  // Define the date format.
  final String dateFormat = (new Integer(java.text.DateFormat.MEDIUM)).toString();

  // Set the time zone.
	String  timeZone = (String) session.getAttribute("timeZone");

  // All our users can send mail
  String canRead = "true";
  String canSend = "true";
  session.setAttribute("canIconMailInbox", canRead);
  session.setAttribute("canIconMailSendMail", canSend);
%>
