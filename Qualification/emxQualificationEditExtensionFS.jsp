<%--  emxQualificationAddExtensionFS.jsp  -  add Extension Frameset by YI3

  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxEngrCommonPartSearchResultsFS.jsp.rca 1.22 Wed Oct 22 15:51:49 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<jsp:useBean id="emxQualification" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%

  framesetObject fs = new framesetObject();

  String suiteKey = emxGetParameter(request, "suiteKey");
  String objectId = emxGetParameter(request, "objectId");
  String timeStamp = emxGetParameter(request, "timeStamp");
  /*
  Enumeration eNumParameters = emxGetParameterNames(request);

  while( eNumParameters.hasMoreElements() ) {
	  String parmName  = (String)eNumParameters.nextElement();
	  System.out.println("param : " + parmName + " - value : " + emxGetParameter(request, parmName));
  }*/
  //fs.setSuiteKey(suiteKey);
  fs.setDirectory("Qualification");
  fs.removeDialogWarning();
  
  // Specify URL to come in middle of frameset
  String contentURL = "emxQualificationEditExtension.jsp";
  contentURL += "?mode=edit";
  contentURL += "&suiteKey=" + suiteKey + "&objectId=" +  objectId ;
  contentURL += "&timeStamp="+timeStamp;
 
 //System.out.println("YI3 - URL :" + contentURL);
  // start

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpfindselect";
  String strLang = context.getSession().getLanguage();
  String formHeader = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.label.ModifyAttributesCmd");
  fs.initFrameset(formHeader,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxQualificationStringResource");
  String roleList ="role_GlobalUser";
  fs.createFooterLink("emxQualification.label.Submit","submitForm()",roleList,false,true,"common/images/buttonDialogDone.gif",0);
  fs.createFooterLink("emxQualification.label.Cancel","top.closeSlideInDialog()",roleList,false,true,"common/images/buttonDialogCancel.gif",0);

  
  fs.writePage(out);

%>

