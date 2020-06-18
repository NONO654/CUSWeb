<%--  emxCreateRouteTemplateWizardMembersDialogFS.jsp   -  Display Frameset for AccessMembers
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCreateRouteTemplateWizardMembersDialogFS.jsp.rca 1.12 Wed Oct 22 16:18:51 2008 przemek Experimental przemek $
--%>
  <%@include file = "../emxUIFramesetUtil.inc"%>
  <%@include file = "emxRouteInclude.inc"%>

  <jsp:useBean id="emxRouteTemplateMembersDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
  <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

  <%

        String keyValue=emxGetParameter(request,"keyValue");
    String toAccessPage=emxGetParameter(request,"toAccessPage");

        if(keyValue == null){
                    keyValue = formBean.newFormKey(session);
        }
        formBean.processForm(session,request,"keyValue");


        formBean.setElementValue("toAccessPage",toAccessPage);


    framesetObject fs = new framesetObject();
    fs.setDirectory(appDirectory);

    String initSource = (String)formBean.getElementValue("initSource");

    if(initSource == null || initSource.equals("null")){
      initSource = "";
    }



     String jsTreeID    =  (String) formBean.getElementValue("jsTreeID");
     String suiteKey    =  (String) formBean.getElementValue("suiteKey");
     String portalMode  =  (String) formBean.getElementValue("portalMode");
     String relatedObjectId  =  (String) formBean.getElementValue("objectId");
     String routeId          =  (String) formBean.getElementValue("routeId");
     String supplierOrgId    =  (String) formBean.getElementValue("supplierOrgId");
     String templateId  =  (String) formBean.getElementValue("templateId");
     String scopeId     =  (String) formBean.getElementValue("scopeId");
     String templateName  =  (String) formBean.getElementValue("templateName");
     String routeAction   =  (String) formBean.getElementValue("selectedAction");
     toAccessPage  =  (String) formBean.getElementValue("toAccessPage");


     String stateSelect[]    = emxGetParameterValues(request, "stateSelect");


     if(!"null".equals(stateSelect) && !(stateSelect == null)){


      HashMap hashStateMap = new HashMap();
      for(int i = 0 ; i < stateSelect.length; i++){

        StringTokenizer sTok =  new StringTokenizer(stateSelect[i], "#");
        while(sTok.hasMoreTokens()){
          String obId = sTok.nextToken();
          if(obId != null && !"".equals(obId) && !"null".equals(obId)){
            hashStateMap.put(obId , sTok.nextToken());
          }
        }
      }

       formBean.setElementValue("hashStateMap",hashStateMap);

     }


       String tableBeanName = "emxRouteTemplateMembersDialogFS";


    // flag to find if user coming back from step 4 to 3

      // Specify URL to come in middle of frameset
    StringBuffer contentURL = new StringBuffer(128);
    contentURL.append("emxCreateRouteTemplateWizardMembersDialog.jsp");

    // add these parameters to each content URL, and any others the App needs
    contentURL.append("?suiteKey=");
    contentURL.append(suiteKey);
    contentURL.append("&initSource=");
    contentURL.append(initSource);
    contentURL.append("&jsTreeID=");
    contentURL.append(jsTreeID);
    contentURL.append("&objectId=");
    contentURL.append(relatedObjectId);
    contentURL.append("&routeId=");
    contentURL.append(routeId);
    contentURL.append("&templateId=");
    contentURL.append(templateId);
    contentURL.append("&scopeId=");
    contentURL.append(scopeId);
    contentURL.append("&templateName=");
    contentURL.append(templateName);
    contentURL.append("&selectedAction=");
    contentURL.append(routeAction);
    contentURL.append("&supplierOrgId=");
    contentURL.append(supplierOrgId);
    contentURL.append("&portalMode=");
    contentURL.append(portalMode);
    contentURL.append("&showWarning=false");
    contentURL.append("&keyValue=");
      contentURL.append(keyValue);
      contentURL.append("&beanName=");
      contentURL.append("emxRouteTemplateMembersDialogFS");




    fs.setStringResourceFile("emxComponentsStringResource");

    // Page Heading - Internationalized
    String PageHeading = "emxComponents.AddMembersDialogFS.AddMembersforRT";

    // Marker to pass into Help Pages
    // icon launches new window with help frameset inside

    String HelpMarker= "emxhelpcreateroutetemplatewizard2";//emxhelproutecreatememadd

    //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
    fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,true,false);

    fs.setBeanName(tableBeanName);

fs.createCommonLink("emxComponents.AddMembersDialog.AddPeople",
                        "addMembers()",
                        "role_GlobalUser",
                        false,
                        true,
                        "../common/images/iconActionAddPerson.png",
                        true,
                        3);

fs.useCache(false);
/*String availability  = (String)formBean.getElementValue("availability");
/*if(availability == null || ! availability.equals("Workspace")){                        
fs.createCommonLink("emxComponents.AddMembersDialog.AddRole",
                        "addRole()",
                        "role_GlobalUser",
                        false,
                        true,
                        "../common/images/iconActionAddRole.png",
                        true,
                        3);
fs.createCommonLink("emxComponents.AddMembersDialog.AddGroup",
                        "addGroup()",
                        "role_GlobalUser",
                        false,
                        true,
                        "../common/images/iconActionAddPersons.png",
                        true,
                        3);
 } 
fs.createCommonLink("emxComponents.AddMembersDialog.AddMemberList",
                        "addMemberList()",
                        "role_GlobalUser",
                        false,
                        true,
                        "../common/images/iconActionAddMemberList.png",
                        true,
                        3);
} */
fs.createCommonLink("emxFramework.Common.RouteAccessAddUserGroups",
        "addUserGroup()",
        "role_GlobalUser",
        false,
        true,
        "../common/images/iconActionAddPersons.png",
        true,
        3);

fs.createCommonLink("emxComponents.Button.RemoveSelected",
                      "removeMembers()",
                      "role_GlobalUser",
                      false,
                      true,
                      "../common/images/iconActionRemoveResource.png",
                      true,
                      0);						


//15 nov

    fs.createCommonLink("emxComponents.Button.Previous",
                      "goBack()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);

   fs.createCommonLink("emxComponents.Button.Next",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

   fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

    fs.removeDialogWarning();
    fs.writePage(out);

%>


