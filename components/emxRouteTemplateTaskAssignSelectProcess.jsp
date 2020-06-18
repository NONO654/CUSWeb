<%--  emxRouteTaskAssignSelectProcess.jsp   -   Process Page for Route Task Assignee
   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteTemplateTaskAssignSelectProcess.jsp.rca 1.9 Wed Oct 22 16:17:57 2008 przemek Experimental przemek $
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxComponentsUtil.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<html>
    <body>
      <script language="javascript">

       //function to change the parameter value in the URL.
		function changeURLParam(strURL, paramName, paramValue){
		    var paramPoint = strURL.indexOf(paramName);
		
		    if (paramPoint > -1){
		        var remainingURL = strURL.substring(paramPoint + 1,strURL.length);
		        var amppoint = remainingURL.indexOf("&");
		        if(amppoint > -1)
		        {
		            remainingURL = remainingURL.substring(amppoint, strURL.length);
		        }
		        else
		        {
		            remainingURL = "";
		        }
		        strURL = strURL.substring(0,paramPoint-1);
		        strURL += remainingURL;
		    }
		
		    if ((paramValue != null) || (paramValue != '') || (paramValue != 'undefined')){
		        if (strURL.indexOf("?") == -1){
		            strURL += "?" + paramName + "=" + paramValue;
		        }else{
		            strURL += "&" + paramName + "=" + paramValue;
		        }
		    }
		    return strURL;
		}
		getTopWindow().closeWindow();
        getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
        parentLoc = getTopWindow().getWindowOpener().location.href;
<%
 DomainObject newPersonObject = DomainObject.newInstance(context);
  // Get page parameters.
  String routeId                    = emxGetParameter(request,"routeId");
  String routeNodeId                = emxGetParameter(request,"routeNodeId");
  String TaskAssignee               = emxGetParameter(request,"TaskAssignee");
  routeNodeId=routeNodeId+"~";
  String childIds[] = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
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

  DomainObject rtaskUser = DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TASK_USER, DomainConstants.TEAM);
  rtaskUser.createObject(context,DomainConstants.TYPE_ROUTE_TASK_USER,null,null,DomainObject.POLICY_ROUTE_TASK_USER,context.getVault().getName());

  while(sAssigneeToken.hasMoreTokens()) {
    sAssigneeId       = (String)sAssigneeToken.nextToken();
    sAssigneeName     = (String)sAssigneeToken.nextToken();
    if(sAssigneeId.equalsIgnoreCase("Role"))
    {
       sAssigneeName = (String) com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"role",sAssigneeName,true);
    }
    else
    {
        sAssigneeName = (String) com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"group",sAssigneeName,true);
    }
   }
///if block is exected if this page is called from Edit all task dialog page or else
// block gets executed if its called from route wizard.

    MapList mlRelInfo = null;
	Map mapRelInfo = null;
	String strOldAssigneeType = null;
	StringList slRelSelect = new StringList("to.id");
	slRelSelect.add("to.type");

	if(routeId != null && !"".equals(routeId) && !"null".equals(routeId)) {
    	while(stToken.hasMoreTokens()) {
      		sRelId = (String)stToken.nextToken();
      		
      		// Find the old assignee id from route node relationship's to side.
      		mlRelInfo = DomainRelationship.getInfo(context, new String[]{sRelId}, slRelSelect);
      		oldPersonId = null;
      		if (mlRelInfo != null && mlRelInfo.size() > 0) {
      		    mapRelInfo = (Map)mlRelInfo.get(0);
      		    if (mapRelInfo != null) {
      		        oldPersonId = (String)mapRelInfo.get("to.id");
      		        strOldAssigneeType = (String)mapRelInfo.get("to.type"); 
      		    }
      		}
			
      		// If assignees are different then only reassign
      		if (sAssigneeId != null && oldPersonId != null && !(oldPersonId.equals(sAssigneeId))) {
        		DomainRelationship dmrRouteNodeRel = new DomainRelationship(sRelId);
        		
        		if("none".equals(sAssigneeId)) {
          			dmrRouteNodeRel.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
          			dmrRouteNodeRel.modifyTo(context,sRelId,rtaskUser);
        		}
        		else if("Role".equals(sAssigneeId) || "Group".equals(sAssigneeId)) {
        		    // If old assignee is also an RTU then reuse that object
        		    DomainRelationship.setAttributeValue(context, sRelId, DomainObject.ATTRIBUTE_ROUTE_TASK_USER, sAssigneeName);
        		    if (!DomainObject.TYPE_ROUTE_TASK_USER.equals(strOldAssigneeType)) {
        		        DomainRelationship.modifyTo(context, sRelId, rtaskUser);        
        		    }
        		}
        		else {
        		    newPersonObject.setId(sAssigneeId);
        		    DomainRelationship.modifyTo(context, sRelId, newPersonObject);
        		    DomainRelationship.setAttributeValue(context, sRelId, DomainObject.ATTRIBUTE_ROUTE_TASK_USER, "");
        		}
      		}
    	}//~while
%>
		//
		// When Active Route Template is edited, a revision is created and that is supposed to be edited
		// The parameter sent in the parent's url does not cotain the latest route template id.
		// So, update the parameter in the url of parent window
		//
		parentLoc = changeURLParam(parentLoc,'routeId','<%=XSSUtil.encodeForJavaScript(context, routeId)%>');
<%    	    
  	}//~if
    else {

    	MapList maplst = (MapList)session.getAttribute("taskMapList");
    

    while(stToken.hasMoreTokens()) {

     sRelId = (String)stToken.nextToken();
     if(stToken.hasMoreTokens())
        oldPersonId   = (String)stToken.nextToken();
     if(stToken.hasMoreTokens())
        oldPersonName = (String)stToken.nextToken();
     Iterator mapItr = maplst.iterator();

     while(mapItr.hasNext()) {
       Map map = (Map)mapItr.next();

       if(((String)map.get("PersonId")).equals(oldPersonId) && ((String)map.get("PersonName")).equals(oldPersonName) && ((String)map.get(relRouteNode)).equals(sRelId)) {
          map.put("PersonId",sAssigneeId);
          if("Role".equals(sAssigneeId)){
            map.put("name",PropertyUtil.getSchemaProperty(context,sAssigneeName));
            map.put("PersonName",PropertyUtil.getSchemaProperty(context,sAssigneeName));
          }else if("none".equals(sAssigneeId)){
            map.put("name","none");
            map.put("PersonName","none");
          }else{
            newPersonObject.setId(sAssigneeId);
            map.put("name",newPersonObject.getName(context));
            map.put("PersonName",sAssigneeName);
          }
          maplst.set(maplst.indexOf(map),map);
          break;

        }
     }
   }
     session.putValue("taskMapList",maplst);

 }
 
%>
		
		parentLoc = changeURLParam(parentLoc,'slctdd','<%=XSSUtil.encodeForJavaScript(context, slctdd)%>');
        parentLoc = changeURLParam(parentLoc,'slctmm','<%=XSSUtil.encodeForJavaScript(context, slctmm)%>');
        parentLoc = changeURLParam(parentLoc,'slctyy','<%=XSSUtil.encodeForJavaScript(context, slctyy)%>');
        
        getTopWindow().getWindowOpener().location.href = parentLoc;
        
        window.closeWindow();
      </script>
    </body>
  </html>
