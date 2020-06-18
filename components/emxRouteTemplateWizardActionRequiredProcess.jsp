<%--  emxRouteTemplateWizardActionRequiredProcess.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $: Exp $
--%>


<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String keyValue=emxGetParameter(request,"keyValue");
  String isRouteTemplateRevised=emxGetParameter(request,"isRouteTemplateRevised");

  String portalMode  = (String)formBean.getElementValue("portalMode");

  DomainObject routeObject = DomainObject.newInstance(context);
  DomainObject personObject = DomainObject.newInstance(context);

  DomainRelationship routeNode = null;

   String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");

  // String sourcePage  = emxGetParameter(request,"sourcePage");
   String sourcePage  = (String)formBean.getElementValue("sourcePage");
   String routeId  = (String)formBean.getElementValue("objectId");
   
   if ((sourcePage == null) || sourcePage.equals("null")){
      sourcePage = "";
   }

     String sRadioNames    = emxGetParameter(request, "radioNames");
     String sRouteNodeSecs = emxGetParameter(request, "routeNodeSecs" );



   StringTokenizer sTokNodeSecs = new StringTokenizer(sRouteNodeSecs, "|");
   StringTokenizer sTokRadioNames = new StringTokenizer(sRadioNames, "|");



   HashMap parallelNodeMap = new HashMap();
   HashMap radioSelectedMap	= new HashMap();


   while(sTokRadioNames.hasMoreElements()) {


     String sTokRadioName = sTokRadioNames.nextToken().trim();
     String sRadioValue = emxGetParameter(request,sTokRadioName );


     radioSelectedMap.put(sTokRadioName,sRadioValue);

     String sNodeIds[] = emxGetParameterValues(request, sTokNodeSecs.nextToken().trim());

     for(int i=0; i <sNodeIds.length; i++){
        String sRouteNodeId = sNodeIds[i];
        if ("EditAllTasks".equals(sourcePage)) 
    	{
               routeNode = DomainRelationship.newInstance(context,sRouteNodeId);
               routeNode.setAttributeValue(context,sAttParallelNodeProcessionRule,sRadioValue);
         	}else{
         	   parallelNodeMap.put(sRouteNodeId , sRadioValue);
         	}
        
     }

  }//while


  formBean.setElementValue("radioSelectedMap", radioSelectedMap);
  formBean.setFormValues(session);
  if (!("EditAllTasks".equals(sourcePage))) {
     formBean.setElementValue("parallelNodeMap" , parallelNodeMap);
     formBean.setFormValues(session);

  }

  if (!("EditAllTasks".equals(sourcePage))){
   Map paramMap = (Map)formBean.getElementValue("strParams");

    if (paramMap != null){
      Iterator keyItr = paramMap.keySet().iterator();
      while (keyItr.hasNext()){
        String name = (String) keyItr.next();
        String value = (String) paramMap.get(name);
        request.setAttribute(name, value);
      }
    }

    String routeOrder = (String)formBean.getElementValue("routeOrder");
    String routeAction = (String)formBean.getElementValue("routeAction");
    String routeInstructions = (String)formBean.getElementValue("routeInstructions");
    String routeTime = (String)formBean.getElementValue("routeTime");
    String personName = (String)formBean.getElementValue("personName");
    String templateId = (String)formBean.getElementValue("templateId");
    String template = (String)formBean.getElementValue("template");
    String routeNodes = (String)formBean.getElementValue("routeNode");
    String folderId = (String)formBean.getElementValue("folderId");
    String workspaceId = (String)formBean.getElementValue("workspaceId");



    String sRoute               = i18nNow.getI18nString( "emxComponents.Common.Route", "emxComponentsStringResource", sLanguage);
    String sRouteName           = "";
    String sDescription         = "";
    String  routeAutoName       = null;
    String objectId             = "";
    String allTasksAssigned     = "true";

    boolean boolSubRoute        = false;


   formBean.removeElement("strParams");


   Hashtable routeDetails = (Hashtable)formBean.getElementValue("hashRouteWizFirst");


if(routeDetails != null){
        objectId        = (String)routeDetails.get("objectId");
        routeAutoName   = (String)routeDetails.get("routenameAuto");
        if ((routeAutoName != null) && ("checked".equals(routeAutoName))){
                sRouteName      = "Auto Name";
        }else{
                sRouteName      = (String)routeDetails.get("routeName");
        }
        sDescription    = (String)routeDetails.get("routeDescription");
}



  MapList taskMapList = (MapList)formBean.getElementValue("taskMapList");

  Iterator mapItr     = taskMapList.iterator();
  HashMap map         = new HashMap();
  while(mapItr.hasNext()){
        map = (HashMap)mapItr.next();
        if("none".equals((String)map.get("PersonName"))){
                allTasksAssigned = "false";
                break;
        }
  }
  }
%>

    <html>
    <body>
    <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>

    </body>
    </html>

    <script language="javascript">//XSSOK
    submitWithCSRF("emxRouteTemplateFinalProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&sourcePage=<%=XSSUtil.encodeForURL(context, sourcePage)%>&objectId=<%=XSSUtil.encodeForURL(context, routeId)%>&isRouteTemplateRevised=<%= XSSUtil.encodeForURL(context,isRouteTemplateRevised) %>", window);
          
    </script>


