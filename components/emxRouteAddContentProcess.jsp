<%--  emxRouteAddContentProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteAddContentProcess.jsp.rca 1.15 Wed Oct 22 16:18:18 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
  String routeId   = emxGetParameter(request, "objectId");
String fromPage   = emxGetParameter(request, "fromPage");
String frameName   = emxGetParameter(request, "frameName");
DomainObject dombj = new  DomainObject(routeId);
StringList sList = new StringList();
sList.addElement(DomainConstants.SELECT_TYPE);
sList.addElement("relationship[Route Task].to.id");
Map mp =dombj.getInfo(context,sList);
String stype =(String)mp.get(DomainConstants.SELECT_TYPE);
if(stype.equals(DomainConstants.TYPE_INBOX_TASK))
{
	routeId = (String)mp.get("relationship[Route Task].to.id");
}
  String strLanguage      = emxGetParameter(request,"strLanguage");
  Route boRoute = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  String [] selObjects = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
  boRoute.setId(routeId);
  StringList selectTypeStmts  =  new StringList();
  selectTypeStmts.add(boRoute.SELECT_NAME);
  DomainObject docObj      = DomainObject.newInstance(context);
  String[] filterObjects = new String[selObjects.length];
  StringBuffer connectObjects = new StringBuffer();
  Access docAccess		= null;
  String accessGrantor 	= null;
  String docName 			= "";
  String contextUser = context.getUser();
  String COMMON_ACCESS_GRANTOR = "Common Access Grantor";
  String strAccessError   = i18nNow.getI18nString("emxComponents.Issue.CheckAccess","emxComponentsStringResource", strLanguage);
  MapList contentList =  new MapList();
  StringList selects = new StringList();
  selects.add(DomainConstants.SELECT_ID);
  selects.add(DomainConstants.SELECT_CURRENT);
  selects.add(DomainConstants.SELECT_NAME);
  selects.add(DomainConstants.SELECT_POLICY);
  for(int i=0; i < selObjects.length; i++){
       docObj.setId(selObjects[i]);
       Map objMap = docObj.getInfo(context,selects);
       docName = (String)objMap.get(DomainConstants.SELECT_NAME);
       StringList grantorList = com.matrixone.apps.common.Route.getGranteeGrantor(context, selObjects[i]);
       if(grantorList.contains(COMMON_ACCESS_GRANTOR))
       {
           docAccess = docObj.getAccessForGranteeGrantor(context, contextUser, COMMON_ACCESS_GRANTOR);
       } else if(grantorList.contains(AccessUtil.ROUTE_ACCESS_GRANTOR)){
           docAccess = docObj.getAccessForGranteeGrantor(context, contextUser, AccessUtil.ROUTE_ACCESS_GRANTOR);
       } else {
           docAccess = docObj.getAccessMask(context);
       }
       if(AccessUtil.hasReadAccess(docAccess)) {
            contentList.add(objMap);
       } else {
           connectObjects.append(docName);
           connectObjects.append(",");
       }
       }
    strAccessError = strAccessError + connectObjects.toString();
	if(connectObjects.length() == 0)
	{
  try {
   boRoute.AddContent(context,contentList);
    // to grant access to all the members on the route
    //handled through Object Route Trigger...
  } catch(Exception e) { }

  // Publish event 'Content Added' at route level
  try
  {
   for (int i = 0; i < selObjects.length; i++) {
    SubscriptionManager subscriptionMgr = boRoute.getSubscriptionManager();
    subscriptionMgr.publishEvent(context, boRoute.EVENT_CONTENT_ADDED,selObjects[i]);
   }
  }catch(Exception e) {
                System.out.println("error.message:"+e.getMessage());
                }
	}

%>

<script language="javascript">
  var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
  var frameNameToRefresh = "<%=frameName%>";
  if(frameNameToRefresh != null && frameNameToRefresh != "null"){
	  var frameToRefresh = findFrame(getTopWindow().getWindowOpener().getTopWindow(), frameNameToRefresh);
	  if(frameToRefresh){
		  frameToRefresh.location.href = frameToRefresh.location.href;
	  }
  }else{
  //MOdified for the Bug No:326829 11/17/2006 Begin
  <% 	if(connectObjects.length() == 0 && (fromPage != null && !"".equals(fromPage) && "addFromTaskSummary".equals(fromPage)))
	{
  %>
 	var refreshFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), getTopWindow().getWindowOpener().name);
	if(refreshFrame){
		refreshFrame.document.location.href = getTopWindow().getWindowOpener().location.href;
	}
        <%
	} else if(connectObjects.length() == 0){%>
		refreshCurrentFrame(getTopWindow().getWindowOpener().getTopWindow(),getTopWindow().getWindowOpener().name, getTopWindow().getWindowOpener().location.href);
    <%} else {%>
       alert("<%=XSSUtil.encodeForJavaScript(context, strAccessError)%>");
       <%}%>
  }
	getTopWindow().closeWindow();
 //MOdified for the Bug No:326829 11/17/2006 Begin
</script>
