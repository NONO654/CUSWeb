<%--  emxProgramCentralCostItemSelectorDialogFS

  Frameset for Cost Category List page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralCostItemSelectorDialogFS.jsp.rca 1.11 Wed Oct 22 15:49:51 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%--Breaks without the useBean--%>
<jsp:useBean id="financialTemplateCategory" scope="page" class="com.matrixone.apps.program.FinancialTemplateCategory"/>

<%
//  com.matrixone.apps.program.FinancialTemplateCategory financialTemplateCategory =
//   (com.matrixone.apps.program.FinancialTemplateCategory) DomainObject.newInstance(context,
//    DomainConstants.TYPE_FINANCIAL_TEMPLATE_CATEGORY, "PROGRAM");

  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String objectId   = emxGetParameter(request,"objectId");
  String fieldName  = emxGetParameter(request,"fieldName");
  String fieldId    = emxGetParameter(request,"fieldId");
  String Directory  = appDirectory;
  framesetObject fs = new framesetObject();
  fs.useCache(false);
  fs.setDirectory(Directory);
  fs.setFieldParams(fieldName,fieldId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------
//Added:31-July-09:nr2:R208:PRG:Bug:373431 
%>
<script language="Javascript">
      window.getWindowOpener().parent.frames[1].getChildWindow(parent.window);
</script>
<%
//End:R208:PRG:Bug:373431
  // see if Cost Categories to determine if done button  should be shown
  StringList busSelects =  new StringList();

  MapList financialTemplateList = new MapList();
    fs.setObjectId(objectId);

  busSelects.add(financialTemplateCategory.SELECT_ID);
  busSelects.add(financialTemplateCategory.SELECT_NAME);
  financialTemplateList = financialTemplateCategory.getCostCategories(context, 1, busSelects, null);


  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralCostItemSelectorDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.Common.SelectCostCategories";
  String HelpMarker = "emxhelpfolderselectdialog";
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  String submitStr = "emxProgramCentral.Button.Done";
  String cancelStr = "emxProgramCentral.Button.Cancel";

  if(!financialTemplateList.isEmpty()) {
    String targetProcessPage = "emxProgramCentralCostItemSelectorProcess.jsp?objectId=" + objectId;
    fs.createFooterLink(submitStr,
                         "parent.doSelect('" + targetProcessPage + "','')", "role_GlobalUser",
                           false, true, "emxUIButtonDone.gif", 0);
  }

  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);
  
  // ----------------- Do Not Edit Below ------------------------------
  fs.writeSelectPage(out);
%>
