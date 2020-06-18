 <%--  emxProgramCentralDependencyAddDialogFS.jsp  -  Awards the quotation for a RTS

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralDependencyAddDialogFS.jsp.rca 1.11 Wed Oct 22 15:49:53 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="emxProgramCentralDependencyAddDialogFS" scope="session" class="com.matrixone.apps.framework.ui.UITable"/>

<%
  com.matrixone.apps.program.Task task =
   (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  
  String jsTreeID      = emxGetParameter(request,"jsTreeID");
  String objectId      = emxGetParameter(request,"objectId");
  String busId         = emxGetParameter(request, "busId");
//  String hasEditAccess = emxGetParameter(request,"hasEditAccess");
  String mode          = emxGetParameter(request,"mode");
  String hiddenView = emxGetParameter(request, "hiddenView");
  String topTaskId = emxGetParameter(request, "topTaskId");
  String cleanupTimeStamp = emxGetParameter(request, "cleanupTimeStamp");
  String Directory     = appDirectory;
  String tableBeanName = "emxProgramCentralDependencyAddDialogFS";
  /*External Cross project Dependency*/
  String externalDependency = emxGetParameter(request,"externalDependency");
  externalDependency = XSSUtil.encodeForURL(context, externalDependency);
  String subProjectId = emxGetParameter(request,"TemplateId");
  subProjectId = XSSUtil.encodeForURL(context, subProjectId);
  /*External Cross project Dependency*/
  // has edit access?
  task.setId(objectId);
  boolean hasEditAccess = task.checkAccess(context, (short) AccessConstants.cModify);

  framesetObject fs = new framesetObject();
  fs.useCache(false);
  fs.setBeanName(tableBeanName);
  fs.setDirectory(Directory);
  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  if(null == hiddenView) { hiddenView = "true"; }

  // ----------------- Do Not Edit Above ------------------------------
  // Specify URL to come in middle of frameset
  // add these parameters to each content URL, and any others the App needs
  String contentURL = "emxProgramCentralDependencyAddDialog.jsp?objectId="+objectId;
  contentURL += "&initSource=" + initSource+ "&busId=" + busId;
  contentURL += "&jsTreeID=" + jsTreeID;
  contentURL += "&beanName=" + tableBeanName + "&popup=false";
  contentURL += "&hasEditAccess=" + hasEditAccess;
  contentURL += "&mode=" + mode + "&topTaskId="+topTaskId + "&cleanupTimeStamp="+cleanupTimeStamp;
  contentURL += "&externalDependency="+externalDependency+"&TemplateId="+subProjectId;
  if(hiddenView.equals("false")){
      contentURL += "&expanded=true";
     // added by ixe for IR-011601V6R2011
      contentURL += "&action=plus";
  }
  //Added:nr2:PRG:R212:26 July 2011:IR-029016V6R2012x
  else{
	  contentURL += "&action=minus";
  }
  //End:nr2:PRG:R212:26 July 2011:IR-029016V6R2012x

  // Page Heading - Internationalized
  String PageHeading = "emxProgramCentral.Dependency.AssignWBSTaskDependency";
  String HelpMarker = "emxhelpdependencyadddialog";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  String clear     = "emxProgramCentral.Common.Clear";
  String showAll = "emxProgramCentral.Button.ShowAllWBSTasks";
  String hideAll = "emxProgramCentral.Button.HideAllWBSTasks";
  String doneStr   = "emxProgramCentral.Button.Done";
  String cancelStr = "emxProgramCentral.Button.Cancel";

  fs.createHeaderLink(clear, "clearAll()", "role_GlobalUser",
                      false, true, "default", 3);

  if("true".equals(hiddenView)){
    fs.createHeaderLink(showAll, "submitShowAllWBS()", "role_GlobalUser",
                        false, true, "default", 0);
  }

  if("false".equals(hiddenView)){
    fs.createHeaderLink(hideAll, "submitHideAllWBS()", "role_GlobalUser",
                        false, true, "default", 0);
  }

  fs.createFooterLink(doneStr, "submitFormAdd()", "role_GlobalUser",
                      false, true, "common/images/buttonDialogDone.gif", 0);

  fs.createFooterLink(cancelStr, "submitClose()", "role_GlobalUser",
                      false, true, "common/images/buttonDialogCancel.gif", 0);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);

%>
