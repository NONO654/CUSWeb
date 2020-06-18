<%--  emxRouteWizardTaskAssignSelectProcess.jsp    -   Process Page for Route Task Assignee
   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxRouteWizardTaskAssignSelectProcess.jsp.rca 1.10 Wed Oct 22 16:18:04 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
String keyValue=emxGetParameter(request,"keyValue");

if(keyValue == null){
    keyValue = formBean.newFormKey(session);
}

formBean.processForm(session,request,"keyValue");



 DomainObject newPersonObject = DomainObject.newInstance(context);
  // Get page parameters.
  String routeId                    = emxGetParameter(request,"routeId");
  String routeNodeId                = emxGetParameter(request,"routeNodeId");
  String TaskAssignee               = emxGetParameter(request,"TaskAssignee");
  String childIds[] = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
  
  if (childIds.length<=0) {
	  %>
	                  <script language="javascript">
	                      alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.RouteTaskAssignee.SelectOneOption")%>");
	                  </script>
	  <%                      
	                  return;
}
  
  if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(TaskAssignee))
  {
      TaskAssignee=childIds[0];
  }

  String sAssigneeId                = "";
  String sAssigneeName              = "";
  StringTokenizer stToken           = new StringTokenizer(routeNodeId, "~");
  StringTokenizer sAssigneeToken    = new StringTokenizer(TaskAssignee, "~");
  String relRouteNode               = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");
  String sRelId                     = "";
  String oldPersonId                = "";
  String oldPersonName              = "";

  String slctdd                     = emxGetParameter(request,"slctdd");
  String slctmm                     = emxGetParameter(request,"slctmm");
  String slctyy                     = emxGetParameter(request,"slctyy");
  String fromPage                   =  emxGetParameter(request,"fromPage");
  String roleGroupName = "";

  if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(fromPage))
  {
      fromPage="";
  }
  
  DomainObject rtaskUser = DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TASK_USER, DomainConstants.TEAM);
  rtaskUser.createObject(context,DomainConstants.TYPE_ROUTE_TASK_USER,null,null,DomainObject.POLICY_ROUTE_TASK_USER,context.getVault().getName());

  while(sAssigneeToken.hasMoreTokens()) {
    sAssigneeId       = (String)sAssigneeToken.nextToken();
    sAssigneeName     = (String)sAssigneeToken.nextToken();
   }
  /*UI adoption Modification*/
 if(sAssigneeId.equals("Role")) {
     roleGroupName=FrameworkUtil.getAliasForAdmin(context,"role",sAssigneeName,true);
 } else if(sAssigneeId.equals("Group")) {
     roleGroupName=FrameworkUtil.getAliasForAdmin(context,"group",sAssigneeName,true);
 }else if(sAssigneeId.equals("UserGroup")){
	 sAssigneeId = sAssigneeName;
	 sAssigneeName = new DomainObject(sAssigneeId).getInfo(context,DomainConstants.SELECT_NAME);
 } else if(sAssigneeId.equals("none")) {
     roleGroupName= sAssigneeName;
 }
  
  if(fromPage.equalsIgnoreCase("Route"))
  {
      //do nothing , popluating the fields is being done in the refresh part
  }
  else
  {

///if block is exected if this page is called from Edit all task dialog page or else
// block gets executed if its called from route wizard.
  if(routeId != null && !"".equals(routeId) && !"null".equals(routeId)) {
		
      StringList relationshipSelects = new StringList(DomainRelationship.SELECT_TO_ID);
      MapList mlRouteNodeInfo = null;
      Map mapInfo = null;	
      while(stToken.hasMoreTokens()) {
	      sRelId    = (String)stToken.nextToken();
	      
	      mlRouteNodeInfo = DomainRelationship.getInfo(context, new String[]{sRelId}, relationshipSelects);
	      mapInfo = (Map)mlRouteNodeInfo.get(0);
	      oldPersonId = (String)mapInfo.get(DomainRelationship.SELECT_TO_ID);
	      
	      if (sAssigneeId != null && oldPersonId != null && !(oldPersonId.equals(sAssigneeId))) {
		        DomainRelationship DoRelShip = new DomainRelationship(sRelId);
		        if ("none".equals(sAssigneeId)) {
			          DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
			          DoRelShip.modifyTo(context, sRelId, rtaskUser);
		        }
		        else if("Role".equals(sAssigneeId) || "Group".equals(sAssigneeId)) {
			          DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,sAssigneeName);
			          DoRelShip.modifyTo(context, sRelId, rtaskUser);
		        }
		        else {
			          newPersonObject.setId(sAssigneeId);
			          DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
			          DoRelShip.modifyTo(context, sRelId, newPersonObject);
		        }
	      }
    }
  } else {
    MapList maplst = (MapList)formBean.getElementValue("taskMapList");


    while(stToken.hasMoreTokens()) {

     sRelId        = (String)stToken.nextToken();
     oldPersonId   = (String)stToken.nextToken();
     oldPersonName = (String)stToken.nextToken();
     Iterator mapItr = maplst.iterator();


     while(mapItr.hasNext()) {
       Map map = (Map)mapItr.next();

       if(((String)map.get("PersonId")).equals(oldPersonId) && ((String)map.get("PersonName")).equals(oldPersonName) && ((String)map.get(relRouteNode)).equals(sRelId)) {


          map.put("PersonId",sAssigneeId);


          if("Role".equals(sAssigneeId) || "Group".equals(sAssigneeId)){
            map.put("name",PropertyUtil.getSchemaProperty(context,sAssigneeName));
            map.put("PersonName",PropertyUtil.getSchemaProperty(context,sAssigneeName));
          }else if("none".equals(sAssigneeId)){
            map.put("name","none");
            map.put("PersonName","none");
          }else{

            map.put("name",sAssigneeName);
            map.put("PersonName",sAssigneeName);
          }


          maplst.set(maplst.indexOf(map),map);



          break;

        }
     }
   }

   formBean.setElementValue("taskMapList",maplst);
   formBean.setFormValues(session);
 }
}
%>
  <html>
    <body>
      <script language="javascript">
      var fromPage="<%=XSSUtil.encodeForJavaScript(context, fromPage)%>";
      var roleGroupName="<%=XSSUtil.encodeForJavaScript(context, roleGroupName)%>";
     
	function refreshParent() {

        var objForm = getTopWindow().getWindowOpener().document.forms[0];

        if (!objForm) {
            return;
        }

        var formElements = objForm.elements;

        for(var i=0;i<formElements.length;i++)
        {
			     if(fromPage=="Route")
			     {
              if(formElements[i].name == "personId" && formElements[i-9].checked) //for Route
			     {
            var formElement = formElements[i];
        			
        			for(var j=0; j<formElement.options.length; j++)
            {
					
					if (formElement.options[j].value == "Person~<%=XSSUtil.encodeForJavaScript(context, sAssigneeId) %>")
                {
                            formElement.options[j].selected=true;
                }else if (formElement.options[j].value == "UserGroup~<%=XSSUtil.encodeForJavaScript(context, sAssigneeId) %>")
                	{
                	 formElement.options[j].selected=true;
                	}
                        else if(formElement.options[j].value == "<%=XSSUtil.encodeForJavaScript(context, sAssigneeId) %>~"+roleGroupName) //since Route uses the symbolic names in the fields
                {
                                  formElement.options[j].selected=true;
                }
            }
              }
			     }
			     else
			     {   
			     
        		if(formElements[i].name == "personId" && formElements[i-4].checked) //for Route wizard
            {
        			var formElement=formElements[i];
        			
                for(var j=0; j<formElement.options.length; j++)
                {
                        if(formElement.options[j].value == "<%=XSSUtil.encodeForJavaScript(context, sAssigneeId) %>~<%=XSSUtil.encodeForJavaScript(context, sAssigneeName)%>") 
                        {
                            formElement.options[j].selected=true;
                        }
                    }
                        }
                    } 
                }
         getTopWindow().closeWindow();
            }
       refreshParent();
       
      </script>
    </body>
  </html>
  
  
