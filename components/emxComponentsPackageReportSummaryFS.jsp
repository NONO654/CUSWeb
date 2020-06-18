<%-- emxComponentsPackageReportSummaryFS.jsp - This page is the Frameset for reviewing specification summary.
  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxComponentsPackageReportSummaryFS.jsp.rca 1.12 Wed Oct 22 16:18:52 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<jsp:useBean id  =  "emxComponentsPackageReportSummaryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  
  String tableBeanName = "emxComponentsPackageReportSummaryFS";
  framesetObject fs = new framesetObject();
  
  fs.setDirectory(appDirectory);
  String initSource = emxGetParameter(request,"initSource");
  String bTeam =  emxGetParameter(request,"bTeam");
  String objectId = emxGetParameter(request,"objectId");
  
  
  
  Enumeration paramEnum = emxGetParameterNames (request);
	StringBuffer contentURL = new StringBuffer();
	contentURL.append("emxComponentsPackageReportSummary.jsp?");
	while (paramEnum.hasMoreElements()) {
		String parameter = (String)paramEnum.nextElement();
		String[] values = emxGetParameterValues(request, parameter);
		if(parameter.equals("incBOMStructure"))
		{
		 if (values[0] == null || "null".equals(values[0]) || values[0].length() <= 0 )
		  {
			 values[0] = "false";
		  }
		}
		if(parameter.equals("initSource") && values[0] == null)
  {
      values[0] = "";
  }
    	contentURL.append(parameter).append("=").append(XSSUtil.encodeForJavaScript(context,values[0])).append("&");
		}
			  contentURL.append("beanName=").append(XSSUtil.encodeForJavaScript(context,tableBeanName)).append("&showWarning=").append(XSSUtil.encodeForJavaScript(context,"false"));
		
  //enter only if  teamcentral is installed or not. 
  if( bTeam !=null && !"null".equals(bTeam) && !"".equals(bTeam) && "true".equals(bTeam))
  {   
        String sArchiveName =emxGetParameter(request,"txtArchiveName");
        String sWorkspaceFolderId = emxGetParameter(request,"folderId");
        String sWorkspaceFolderName =emxGetParameter(request,"txtWSFolder");
         //Creating property keys and putting into session for displaying correct values for Internationalization characters. 
        Properties createPackageprop = new Properties();
        createPackageprop.setProperty("workspaceFolderId_KEY",sWorkspaceFolderId);
        createPackageprop.setProperty("archiveName_KEY",sArchiveName);
        createPackageprop.setProperty("workspaceFolderName_KEY",sWorkspaceFolderName); 
        session.putValue("createPackage_KEY",createPackageprop);
  }
  
  fs.setBeanName(tableBeanName);
  
  // Page Heading - Internationalized
  String PageHeading = "emxComponents.Common.PackageReportPageHeading";
 

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbomdownloadpackage";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(XSSUtil.encodeForJavaScript(context,objectId));

  if (acc.has(Access.cRead)) {
   // Role based access
   String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator,role_ComponentEngineer,role_SupplierEngineer,role_SupplierRepresentative,role_SupplierQualityEngineer";

   fs.createFooterLink("emxComponents.Button.Previous",
                      "prevMethod()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      0);

   fs.createCommonLink("emxComponents.Common.Done",
                      "doneMethod()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      4);

  fs.createCommonLink("emxComponents.Common.Cancel",
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
