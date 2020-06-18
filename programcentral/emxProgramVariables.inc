<%--
  emxProgramVariables.inc

  Define globals for the Program Central Suite

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramVariables.inc.rca 1.14 Wed Oct 22 15:50:33 2008 przemek Experimental przemek $"
--%>

<% 
  // Get suite sub-directory name from properties file.
  matrix.db.Context _ctx = Framework.getFrameContext(session);
  final String suiteDir =  EnoviaResourceBundle.getProperty(_ctx, "eServiceSuiteProgramCentral.Directory");
	final String   appDirectory =  EnoviaResourceBundle.getProperty(_ctx, "eServiceSuiteProgramCentral.Directory");
        _ctx.shutdown();
	_ctx = null;

  // Get the proxy prefix.
  String proxy = Framework.getPropertyValue("ematrix.proxy.server");
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
    final String dateFormat = (new Integer(eMatrixDateFormat.getEMatrixDisplayDateFormat())).toString();
  
  // Set the time zone.
 	final String timeZone = (String) session.getAttribute("timeZone");      
  
%>

