<%-- (c) Dassault Systemes, 2013-2018 --%>
<%--
  Process type Menu of objects to generate RMB
--%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UIMenu"%>
<%@page import="com.matrixone.apps.framework.ui.UICache"%>
<%@page import="com.matrixone.apps.framework.ui.UIComponent"%>


<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>





<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%

   Map requestMap      = UINavigatorUtil.getRequestParameterMap(pageContext);
   //get object id
   String objectId = emxGetParameter(request, "objectId");
   String emxSuiteDirectory = emxGetParameter(request,"emxSuiteDirectory");
   String lang = request.getHeader("Accept-Language");
   
   String type= UITreeUtil.getTreeMenuName(application, session, 
                                  context, objectId, emxSuiteDirectory);
   
   // get the type menu
   UIMenu typemenu     = new UIMenu();
   HashMap typemenumap = typemenu.getMenu(context, type);
   String showrmb = UIMenu.getSetting(typemenumap, "Show Navigator RMB");
   String rmbmenu = UIMenu.getSetting(typemenumap, "Navigator RMB Menu");
   
   if(showrmb == null || "".equals(showrmb))
       return;
   if(rmbmenu == null || "".equals(rmbmenu))
       return;
   //go and see settings on the RMB Menu
   HashMap rmbmenumap = typemenu.getMenu(context, rmbmenu);
   //get the child commands
   if(rmbmenu.isEmpty())
       return;
   MapList children = (MapList)rmbmenumap.get("children"); 
   
   String rmbDataString = UIMenu.getNavigatorRMBDataString
                                    (context, objectId, children, lang);
   
   out.clear();
   response.setContentType("text/xml; charset=UTF-8");
%>
 <!-- //XSSOK -->
<%=rmbDataString %>
