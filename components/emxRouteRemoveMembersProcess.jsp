<%--  emxRouteRemoveMembersProcess.jsp  --  DisConnecting Members from Route

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $ Exp $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String[] selPersons   = emxGetParameterValues(request, "chkItem");
  selPersons		= (selPersons != null) ? selPersons : emxGetParameterValues(request, "emxTableRowId");
  String sTemplateId   = emxGetParameter(request,"templateId");
  String routeId   = emxGetParameter(request, "routeId");
  String objectId = emxGetParameter(request,"objectId");
  String portalMode = emxGetParameter(request,"portalMode");
  String keyValue = emxGetParameter(request,"keyValue");
  String fromRouteAccessSummaryPage = emxGetParameter(request, "fromRouteAccessSummaryPage");
  boolean isRouteTemplateRevised=false;
  String objType = "";
  String objState = "";
  routeId = routeId != null ? routeId : objectId;
  if(routeId != null && !"null".equals(routeId) && !"".equals(routeId)) {
    DomainObject domainObj = new DomainObject(routeId);
    StringList selects = new StringList(2);
    selects.add(DomainObject.SELECT_TYPE);
    selects.add(DomainObject.SELECT_CURRENT);

    Map objDetailsMap = domainObj.getInfo(context,selects);
    objType = (String)objDetailsMap.get(DomainObject.SELECT_TYPE);
    objState = (String)objDetailsMap.get(DomainObject.SELECT_CURRENT);
  }
  boolean isTemplate = false;
  boolean isRouteTemplateActive = false;
  Vector taskUserList=new Vector();
  Vector personIdList=new Vector();
  String[] revPersons=new String[selPersons.length];
  StringList objectSelects=new StringList();
  StringList relSelects=new StringList();
  StringList relationshipSelects = new StringList(3);
  relationshipSelects.add(RouteTemplate.SELECT_ROUTE_TASK_USER);
  relationshipSelects.add("to.id");
  relationshipSelects.add("to.type");
  String revisedTemplateId="";
  
  if(objType.equals(DomainObject.TYPE_ROUTE_TEMPLATE)) {
    RouteTemplate boRouteTemplate = (RouteTemplate)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TEMPLATE);
      boRouteTemplate.setId(routeId);
      objState = (String)boRouteTemplate.getInfo(context,DomainObject.SELECT_CURRENT);
     //Modified for Bug No:341550 Rev1 Dated 11/21/2007 Begin. 
    if(objState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE)) {
    	MapList actualMemberList = DomainRelationship.getInfo(context, selPersons, relationshipSelects);
              Iterator personItr = actualMemberList.iterator();
        while(personItr.hasNext()) {
                  Map map = (Map)personItr.next();
                  String personType=(String)map.get("to.type");
                  String personId=(String)map.get("to.id");
                  String routeUserAttrVal=(String)map.get(RouteTemplate.SELECT_ROUTE_TASK_USER);
            if(personType.equals(DomainObject.TYPE_ROUTE_TASK_USER)) {
                          taskUserList.addElement(routeUserAttrVal);
                      }
            if(personType.equals(DomainObject.TYPE_PERSON)) {
                          personIdList.addElement(personId);
                      }
                  }
                revisedTemplateId = boRouteTemplate.revise(context);
                boRouteTemplate.setId(revisedTemplateId);
                isRouteTemplateRevised=true;
        MapList revisedMemberList=boRouteTemplate.getRouteTemplateMembers(context, objectSelects, relSelects, false);
                Iterator mapItr = revisedMemberList.iterator();
                int index=-1;
        while(mapItr.hasNext()) {
                  Map memberMap = (Map)mapItr.next();
                  String memberId=(String)memberMap.get(DomainObject.SELECT_ID);
                  String memberType=(String)memberMap.get(DomainObject.SELECT_TYPE);
                  String taskUserName=(String)memberMap.get(RouteTemplate.SELECT_ROUTE_TASK_USER);
                  String relId=(String)memberMap.get(DomainObject.SELECT_RELATIONSHIP_ID);
            	  if(memberType.equals(DomainObject.TYPE_ROUTE_TASK_USER)&&taskUserList.contains(taskUserName)) {
                      index++;
                      revPersons[index]=relId;
                  }
            	  if(memberType.equals(DomainObject.TYPE_PERSON)&&personIdList.contains(memberId)) {
                      index++;
                      revPersons[index]=relId;
                  }
                 }
                isRouteTemplateActive = true;
                selPersons=revPersons;
  }
    if("true".equals(fromRouteAccessSummaryPage)) {
       Route.removeRouteMembers(context, selPersons, boRouteTemplate); 
	} else {
    boRouteTemplate.removeMembers(context, selPersons);
  }
  } else {
    Route boRoute = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
    boRoute.setId(routeId);
    try {
		  //No Need to retain Task when we remove person from the Route through access page.
	      boRoute.RemoveMembers(context, selPersons);
	    } catch(Exception e) {
      		throw new FrameworkException("error:" + e.getMessage());
    }
  }

  String relatedObjectId = emxGetParameter(request,"objectId");
  String scopeId   = emxGetParameter(request,"scopeId");
  String sTemplateName   = emxGetParameter(request,"templateName");
  String fromPage = emxGetParameter(request,"fromPage");
  String supplierOrgId = emxGetParameter(request,"supplierOrgId");
  String strpopUpURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, revisedTemplateId) + "&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory);

%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="ContenForm" method="post" target="_parent">
  <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=sTemplateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="scopeId" value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=sTemplateName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="supplierOrgId" value="<xss:encodeForHTMLAttribute><%=supplierOrgId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>"/>
</form>

<script language="javascript">
	var fromAccessPage = "true" == "<%=XSSUtil.encodeForJavaScript(context, fromRouteAccessSummaryPage)%>";
	//XSSOK
    if("<%=isRouteTemplateRevised%>" == "true") {
    	//XSSOK
    	parent.window.location = "<%=strpopUpURL%>";
		} else {
			if(fromAccessPage){
				getTopWindow().refreshSpecificPage("APPAccess");
				getTopWindow().refreshSpecificPage("APPTasksGraphical");
				getTopWindow().refreshSpecificPage("APPTask");
			} else {
				parent.window.location = parent.window.location;
			}
		}	
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
