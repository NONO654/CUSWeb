<%--emxBOMManagementDownloadPackageReportDialogFS.jsp
  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] =$ID: emxComponentsPackageReportDialogFS.jsp,v 1.6 2005/02/08 20:55:50 abadrayani Exp $"
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>


<%

 	String tableBeanName = "emxBOMManagementPackageReportDialogFS";
	framesetObject fs = new framesetObject();

	fs.setDirectory(appDirectory);

	String initSource = emxGetParameter(request,"initSource");
   
	// Collecting all the parameters
  
	Enumeration paramEnum = emxGetParameterNames (request);
	StringBuffer contentURL = new StringBuffer();
	contentURL.append("emxBOMManagementDownloadPackageReportDialog.jsp?");
	while (paramEnum.hasMoreElements()) {
		String parameter = (String)paramEnum.nextElement();
		String[] values = emxGetParameterValues(request, parameter);
		if(parameter.equals("initSource") && values[0] == null)
		{
			 values[0] = "";
		}
		contentURL.append(parameter).append("=").append(XSSUtil.encodeForJavaScript(context,values[0])).append("&");
	}
    
  // Page Heading - Internationalized
  String PageHeading = "emxBOMManagement.DownloadPackage.PackageReportPageHeaderStep1";
  
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbomdownloadpackage";
  
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,true,false,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  
  if (acc.has(Access.cRead)) {
 // Role based access
 String roleList = "";

  fs.createCommonLink("emxEngineeringCentral.Button.Next",
                      "doneMethod()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      4);

  fs.createCommonLink("emxEngineeringCentral.Common.Cancel",
                      "window.closeWindow()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);


  }
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
