<%-- emxRouteFindContentDialogFS.jsp-Create Frameset for FindContent Search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

--%>

<%@ include file = "../emxUIFramesetUtil.inc"%>
<%@ include file = "./emxComponentsCommonUtilAppInclude.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%


String keyValue=emxGetParameter(request,"keyValue");


if(keyValue == null){
     keyValue = formBean.newFormKey(session);
}
 formBean.processForm(session,request,"keyValue");

   // Prepare the proper contentUrl with all the required parameters
   String objectId       = emxGetParameter(request,"objectId");
   String sProjectId     = emxGetParameter(request,"projectId");
   String sParentId      = emxGetParameter(request,"routeId");
   String sTemplateId    = emxGetParameter(request,"templateId");
   String sTemplateName  = emxGetParameter(request,"template");
   String sContentId     = emxGetParameter(request,"contentId");
   String sContent       = emxGetParameter(request,"content");
   String searchType     = emxGetParameter(request,"searchType");
   String sfromPage      = emxGetParameter(request,"fromPage");
   String visblToParent = emxGetParameter(request,"visblToParent");
   String routeStart = emxGetParameter(request,"routeStart");
   String workspaceFolderId = emxGetParameter(request,"workspaceFolderId");
   String workspaceFolder   = emxGetParameter(request,"workspaceFolder");
   String sURL                    = "";
   String PageHeading             = "emxComponents.FindContent.Heading";
   String HelpMarker              = "emxhelpfindcontentroute";


   String routeCompletionAction1  = emxGetParameter(request,"routeCompletionAction");
  objectId                =  (String) formBean.getElementValue("objectId");
  String parentId         =  (String) formBean.getElementValue("parentId");
  String scopeId          =  (String) formBean.getElementValue("scopeId");
  String templateId       =  (String) formBean.getElementValue("templateId");
  String templateName     =  (String) formBean.getElementValue("template");
  String routeId          =  (String) formBean.getElementValue("routeId");
  String routeAutoName    =  (String) formBean.getElementValue("routeAutoName");
  String routeName        =  (String) formBean.getElementValue("routeName");
  String routeDescription =  (String) formBean.getElementValue("routeDescription");

// Added for IR-043275V6R2011 Dated 22nd Mar 2010 Begins.
  String sCurrentRouteName=emxGetParameter(request,"routeName");
  String sCurrentRouteDescription=emxGetParameter(request,"routeDescription");
  if(null == sCurrentRouteName)
  {
	  routeName=sCurrentRouteName;
  }
  if(null == sCurrentRouteDescription)
  {
	  routeDescription=sCurrentRouteDescription;
  }
  String vRouteName1        =  (String) formBean.getElementValue("vRouteName1");
  String vDescription1 =  (String) formBean.getElementValue("vDescription1");
  if(vRouteName1==null)
  {
	   vRouteName1="";
  }
  if(vDescription1==null)
  {
	  vDescription1="";
  }
  vRouteName1=vRouteName1.replace("|amp|amp", "&");
  vDescription1=vDescription1.replace("|amp|amp", "&");
  if(null==routeName)
  {
	  routeName=vRouteName1;
  }
  if(null==routeDescription)
  {
	  routeDescription=vDescription1;
  }
// Added for IR-043275V6R2011 Dated 22nd Mar 2010 Ends.

  String selectedAction   =  (String) formBean.getElementValue("selectedAction");
  String portalMode       =  (String) formBean.getElementValue("portalMode");
  String routeBasePurpose =  (String) formBean.getElementValue("routeBasePurpose");
  String routeAutoStop    =  (String) formBean.getElementValue("routeAutoStop");
  String selscope         =  (String) formBean.getElementValue("selscope");
  String routeCompletionAction    =  (String) formBean.getElementValue("routeCompletionAction");
  String supplierOrgId    =  (String) formBean.getElementValue("supplierOrgId");
  String suiteKey         =  (String) formBean.getElementValue("suiteKey");

  selscope=emxGetParameter(request,"selscope");
  if(selscope == null ){
    scopeId="";
  }else if(selscope.equals("All")){
    scopeId="";
  }else if(selscope.equals("Organization")){
    scopeId="Organization";
  }else{
    scopeId=workspaceFolderId;
  }
  Hashtable hashRouteWizFirst  =  (Hashtable)formBean.getElementValue("hashRouteWizFirst");
   if(hashRouteWizFirst!=null)
   {
      if(routeAutoName == null || routeAutoName.equals("") || routeAutoName.equals("null")){
         hashRouteWizFirst.put("routeName",routeName);
         hashRouteWizFirst.put("routeAutoName","");
      }else{
         hashRouteWizFirst.put("routeName","");
      }

 //modified for the Issue 336838
      if(routeAutoName != null && !routeAutoName.equals("null") && !routeAutoName.equals(""))
      {
            hashRouteWizFirst.put("routeAutoName",routeAutoName);
            hashRouteWizFirst.put("routeName","");
      }else{
         hashRouteWizFirst.put("routeAutoName","");
      }


      if(templateId!= null && !templateId.equals("null")){
           hashRouteWizFirst.put("templateId",templateId);
      }

      if(templateName!= null && !templateName.equals("null")){
           hashRouteWizFirst.put("templateName",templateName);
      }

      if(routeBasePurpose!= null && !routeBasePurpose.equals("null")){
         hashRouteWizFirst.put("routeBasePurpose",routeBasePurpose);
      }
      
      if(routeAutoStop!= null && !routeAutoStop.equals("null")){
          hashRouteWizFirst.put("routeAutoStop",routeAutoStop);
       }

       if(visblToParent == null || visblToParent.equals("null")){
            visblToParent = "";
      }
      hashRouteWizFirst.put("visblToParent",visblToParent);


      if(routeCompletionAction!= null && !routeCompletionAction.equals("null")){
           hashRouteWizFirst.put("routeCompletionAction",routeCompletionAction);
      }


      if(selscope!= null && !selscope.equals("null")){
         hashRouteWizFirst.put("selscope",selscope);
         if(selscope.equals("ScopeName")){
             hashRouteWizFirst.put("selscopeId",workspaceFolderId);
             hashRouteWizFirst.put("selscopeName",workspaceFolder);
             scopeId = workspaceFolderId;
         }
      }

      if(parentId!= null && parentId.equals("null")){
              hashRouteWizFirst.put("objectId",parentId);
      }

      if(routeStart == null || routeStart.equals("null")){
            routeStart = "";
      }

      if(routeDescription == null || routeDescription.equals("null")){
            routeDescription = "";
      }
  hashRouteWizFirst.put("routeStart",routeStart);
  hashRouteWizFirst.put("routeDescription",routeDescription);

  formBean.setElementValue("hashRouteWizFirst",hashRouteWizFirst);
  formBean.setFormValues(session);
}
  searchFramesetObject fs = new searchFramesetObject();
  String queryLimit = emxGetParameter(request, "queryLimit");
  if(queryLimit == null){
	  sURL = "emxRouteFindContentDialog.jsp?loadPage=../components/emxRouteFindContentDialogFS.jsp&mode=findGeneralSearch&queryLimit=100&keyValue="+keyValue+"&scopeId="+scopeId;
	  fs.setQueryLimit(100);
  }else{
      String queryString = emxGetQueryString(request);
	  sURL = "emxRouteFindContentDialog.jsp?mode=findGeneralSearch&keyValue="+keyValue+"&scopeId="+scopeId+ "&"+queryString;
	  fs.setQueryLimit(Integer.parseInt(queryLimit));
  }

  // Create search Link. One call of this method for one search link on the left side
  fs.initFrameset(PageHeading,sURL,"emxComponents.SearchCommon.SearchHeading",false);
  fs.setStringResourceFile("emxComponentsStringResource");

  fs.setHelpMarker(HelpMarker);
  fs.setDirectory(appDirectory);
  fs.createSearchLink("emxComponents.FindFiles.GeneralSearch",
                      com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sURL),
                      "role_GlobalUser"
                     );

  fs.writePage(out);
%>
