<%--  emxParseBusinessRule.jsp  -  Search summary frameset

  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxEngrCommonPartSearchResultsFS.jsp.rca 1.22 Wed Oct 22 15:51:49 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<jsp:useBean id="emxParseBusinessRule" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  System.out.println("Begin emxParseBusinessRule.jsp");
  String tableBeanName = "emxParseBusinessRule";

  framesetObject fs = new framesetObject();

  String suiteKey = emxGetParameter(request, "suiteKey");
  fs.setSuiteKey(suiteKey);

  fs.setDirectory("PackagesManagement");
  fs.removeDialogWarning();
  
  // Specify URL to come in middle of frameset
  String contentURL = "emxPackagesConfigurationImport.jsp";
  // start

  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue))
  {
    contentURL += "&mx.page.filter=" + filterValue;
    fs.setFilterValue(filterValue);
  }
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpfindselect";
  String strLang = context.getSession().getLanguage();
  String formHeader = EnoviaResourceBundle.getProperty(context,"emxPackagesManagementStringResource",context.getLocale(),"emxPackagesManagement.label.PackageImportTitle");
  fs.initFrameset(formHeader,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxPackagesManagementStringResource");

  String roleList ="role_GlobalUser";

  //fs.createFooterLink("emxDataSpecialization.label.PackageImportFileSubmit","parent.window.close()",roleList,false,true,"emxUIButtonDone.gif",0);
  //fs.createFooterLink("emxDataSpecialization.label.PackageImportFileSubmit","document.forms['ImportForm'].submit()",roleList,false,true,"emxUIButtonDone.gif",0);
  fs.createFooterLink("emxPackagesManagement.label.PackageImportFileSubmit","submitForm()",roleList,false,true,"emxUIButtonDone.gif",0);
  //fs.createFooterLink("emxFramework.Command.Cancel","parent.window.close()",roleList,false,true,"emxUIButtonCancel.gif",0);
  fs.createFooterLink("emxPackagesManagement.label.PackageImportCancel","top.closeSlideInDialog()",roleList,false,true,"emxUIButtonCancel.gif",0);

  
  fs.writePage(out);

/*
catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

}*/
%>

