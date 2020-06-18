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
   if(objectId==null)
   {
        objectId="";
   }
   /*Take all the entered values in the Simple Route Create Dialog */
   String sProjectId     = emxGetParameter(request,"projectId");
   String sParentId      = emxGetParameter(request,"routeId");

   String searchType     = emxGetParameter(request,"searchType");
   String sfromPage      = emxGetParameter(request,"fromPage");
   String sURL                    = "";
   String PageHeading             = "emxComponents.FindContent.Heading";
   String HelpMarker              = "emxhelpfindcontentroute";

   String routeStart = emxGetParameter(request,"routeInitiateManner");
   String sRouteInstructions      = emxGetParameter(request,"routeInstructions");
   String sRouteAction     = emxGetParameter(request,"routeAction");
   
   String sRouteDueDate      = emxGetParameter(request,"routeDueDate");
   String scopeId          =  emxGetParameter(request,"scopeId");
   String parentId         =  (String) formBean.getElementValue("parentId");
    String routeMemberFilter=emxGetParameter(request,"routeMemberFilter");
    String routeMemberString=emxGetParameter(request,"routeMemberString");
   String searchDocId=(String) formBean.getElementValue("ContentId");

    

  Hashtable hashRouteWizFirst  =  (Hashtable)formBean.getElementValue("hashRouteWizFirst");
  if(hashRouteWizFirst==null)
  {
        hashRouteWizFirst=new Hashtable();
  }

/*Start inserting all the request parameter in to a data structure as key value paris*/
      if(parentId!= null && parentId.equals("null")){
              hashRouteWizFirst.put("objectId",parentId);
      }
      else{
             hashRouteWizFirst.put("objectId",objectId);
      }
  if(routeStart != null){
  hashRouteWizFirst.put("routeInitiateManner",routeStart);
  }
  if(sRouteAction != null){
  hashRouteWizFirst.put("routeAction",sRouteAction);
  }
  if(sRouteDueDate != null){
  hashRouteWizFirst.put("routeDueDate",sRouteDueDate);
  }
  if(sRouteInstructions != null){
  hashRouteWizFirst.put("routeInstructions",sRouteInstructions);
  }
  if(routeMemberFilter != null){
  hashRouteWizFirst.put("routeMemberFilter",routeMemberFilter);
  }
  if(routeMemberString != null){
  hashRouteWizFirst.put("routeMemberString",routeMemberString);
  }

  formBean.setElementValue("hashRouteWizFirst",hashRouteWizFirst);
  formBean.setFormValues(session);

  searchFramesetObject fs = new searchFramesetObject();
  String queryLimit = emxGetParameter(request, "queryLimit");
  if(queryLimit == null){
	  sURL = "emxRouteFindContentDialog.jsp?loadPage=../components/emxRouteSimpleFindContentDialogFS.jsp&mode=findGeneralSearch&keyValue="+keyValue+"&scopeId="+scopeId+"&invokePurpose=QuickRouteContent&queryLimit=100";
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
