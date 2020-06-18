<%--  emxDeleteRoute.jsp - Remove Event, Publish/Subscribe, Folder and Route Objects
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxDeleteRoute.jsp.rca 1.25 Wed Oct 22 16:18:10 2008 przemek Experimental przemek $
--%>


<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%
  Route route = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  String routeId     = null;
  String sRouteIds   = emxGetParameter(request, "routeId");
  String sMessage    = emxGetParameter(request, "txtDescription");
  String objectId    = emxGetParameter(request, "objectId");
  String sPageName   = emxGetParameter(request, "pageName");
  String sSuiteKey   = emxGetParameter(request, "suiteKey");
  String portalMode  = emxGetParameter(request,"portalMode");
  Vector routeIds           =  new Vector();
  StringTokenizer stToken   = new StringTokenizer(sRouteIds,"~");
  while (stToken.hasMoreTokens()){
    try {
	//Bug No:303878 Dt :05-May-2005
	String strToken  = stToken.nextToken();
	if(strToken.indexOf('|')>0){
		routeId        =strToken.substring(strToken.indexOf('|')+1,strToken.length()); 
	}else{
		routeId        =strToken;
    }
	//Bug No:303878 Dt :05-May-2005
      route.setId(routeId);
      String sSubject = route.getType(context) + " " + route.getName(context) + " " +ComponentsUtil.i18nStringNow("emxComponents.DeleteRoute.DeleteNotification",sLanguage);
      route.deleteRoute(context, sMessage, sSubject);
      routeIds.add(routeId);
    } catch (Exception ex ){
      session.putValue("error.message",ex.getMessage());
    }
 }

%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
<%

   if(objectId != null && !"".equals(objectId) ) {
%>

      var tree = parent.window.getWindowOpener().getTopWindow().objStructureTree;
      if( tree != null && tree != 'undefined' && tree != 'null' )  {
<%
        for(int i=0; i<routeIds.size(); i++){
%>
          tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, ((String)routeIds.elementAt(i)).trim())%>");
<%
        }
%>
      }
<%
   }
if(sPageName!=null && !sPageName.equals("")){
   if(sSuiteKey != null && sSuiteKey.equals("TRUE")){
%>
      parent.window.getWindowOpener().parent.location.href = parent.window.getWindowOpener().parent.location.href;
<%
    }else{
%>
      parent.window.getWindowOpener().parent.location.href='<%= XSSUtil.encodeForURL(context, sPageName) %>?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>';
<%  }
} else {
%>
  if ('true' == '<%=XSSUtil.encodeForJavaScript(context, portalMode)%>') {
    if(getTopWindow().getWindowOpener().parent != null)
    {  
    	getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
    }
  }else  {
              <%
                 if(objectId == null || "".equals(objectId))
                      {
              %>
                            if(getTopWindow().getWindowOpener().getTopWindow().refreshTablePage)
                                {  
                                    getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
                                }  
                            else
                                {  
                                    getTopWindow().getWindowOpener().getTopWindow().location.href = getTopWindow().getWindowOpener().getTopWindow().location.href;
                                }
              <%
                 }
                 else{
                %>
                            if(getTopWindow().getWindowOpener().getTopWindow().refreshTablePage)
                                {  
                                    getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
                                }  
                            else
                                {  
                                    getTopWindow().getWindowOpener().getTopWindow().location.href = getTopWindow().getWindowOpener().getTopWindow().location.href;
                                }
                <%
                         }
               %>
           }
  <%
  }
  %>
  getTopWindow().closeWindow();
</script>
