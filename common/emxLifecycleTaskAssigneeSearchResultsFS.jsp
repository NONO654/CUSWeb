<%--  emxLifecycleTaskAssigneeSearchResultsFS.jsp  -   Search Result FS page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTaskAssigneeSearchResultsFS.jsp.rca 1.5.3.2 Wed Oct 22 15:47:52 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.DomainObject"%>
<jsp:useBean id="emxCommonRoutePersonSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  framesetObject fs = new framesetObject();
	String tableBeanName = "emxCommonRoutePersonSearchResultsFS";
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String suiteKey     = emxGetParameter(request,"suiteKey");

  fs.setDirectory(appDirectory);

  String objectId 			= emxGetParameter(request,"objectId");
  	String strSearchType    	= emxGetParameter(request,"searchType"); 
	
  	String strHidePersonSearch = emxGetParameter(request,"hidePersonSearch");
	String strHideRoleSearch   = emxGetParameter(request,"hideRoleSearch");
	String strHideGroupSearch  = emxGetParameter(request,"hideGroupSearch");
	
	
  
  	StringBuffer strContentURL = new StringBuffer(640);
  	strContentURL.append("emxLifecycleTaskAssigneeSearchResults.jsp"+"?hidePersonSearch="+strHidePersonSearch+"&hideRoleSearch="+strHideRoleSearch+"&hideGroupSearch="+strHideGroupSearch);
  
	 if ("Person".equals(strSearchType)) {
		String strFirstName   = emxGetParameter(request,"firstName");
		String strLastName    = emxGetParameter(request,"lastName");
		String strUserName    = emxGetParameter(request,"userName");
		String strCompanyName = emxGetParameter(request,"companyName");
		
		strContentURL.append("&initSource=");
		strContentURL.append(initSource);
		strContentURL.append("&UserName=");
		strContentURL.append(strUserName);
		strContentURL.append("&FirstName=");
		strContentURL.append(strFirstName);
		strContentURL.append("&LastName=");
		strContentURL.append(strLastName);
		strContentURL.append("&companyName=");
		strContentURL.append(strCompanyName);
		strContentURL.append("&beanName=");
		strContentURL.append(tableBeanName);
		strContentURL.append("&showWarning=false");
		strContentURL.append("&searchType=");
		strContentURL.append(strSearchType);
	 }
	 else if ("Role".equals(strSearchType)) {    
		String sName            = emxGetParameter(request,"txtName");
		String sTopChecked      = emxGetParameter(request,"chkTopLevel");
		String sSubChecked      = emxGetParameter(request,"chkSubLevel");     

		strContentURL.append("&initSource=");
		strContentURL.append(initSource);
		strContentURL.append("&txtName=");
		strContentURL.append(sName);
		strContentURL.append("&chkTopLevel=");
		strContentURL.append(sTopChecked);
		strContentURL.append("&chkSubLevel=");
		strContentURL.append(sSubChecked);    
		strContentURL.append("&beanName=");
		strContentURL.append(tableBeanName);
		strContentURL.append("&searchType=");
		strContentURL.append(strSearchType);
	}
	else if ("Group".equals(strSearchType)) {
	    
	     String sName            	= emxGetParameter(request,"txtName");
	     String sTopChecked      	= emxGetParameter(request,"chkTopLevel");
	     String sSubChecked     	= emxGetParameter(request,"chkSubLevel");     
	
	     strContentURL.append("&initSource=");
	     strContentURL.append(initSource);
	     strContentURL.append("&txtName=");
	     strContentURL.append(sName);
	     strContentURL.append("&chkTopLevel=");
	     strContentURL.append(sTopChecked);
	     strContentURL.append("&chkSubLevel=");
	     strContentURL.append(sSubChecked);    
	     strContentURL.append("&beanName=");
	     strContentURL.append(tableBeanName);
		strContentURL.append("&searchType=");
		strContentURL.append(strSearchType);
  	}
	else {
		strContentURL.append("");
	}

	  // Specify URL to come in middle of frameset
	  String contentURL = strContentURL.toString();

  fs.setStringResourceFile("emxFrameworkStringResource");
  // Page Heading - Internationalized
  String PageHeading = "emxFramework.SelectPeople.Step2Heading";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "";
    
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  
  fs.createFooterLink("emxFramework.Button.Submit",
			          "selectDone()",
			          "role_GlobalUser",
			          false,
			          true,
			          "common/images/buttonDialogDone.gif",
			          3);
  
  fs.createFooterLink("emxFramework.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
