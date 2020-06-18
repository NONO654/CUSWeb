<%-- (c) Dassault Systemes, 2013 --%>
<%--
  Process various SLM commands on the SLM Home page.
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
  
   
   StringBuffer buf = new StringBuffer();
   Map requestMap      = UINavigatorUtil.getRequestParameterMap(pageContext);
   //get object id
   String objectAction = emxGetParameter(request, "objectAction");
   String emxSuiteDirectory = emxGetParameter(request,"emxSuiteDirectory");
   String lang = context.getSession().getLanguage();
   
   String type= UITreeUtil.getTreeMenuName(application, session, context, objectAction, emxSuiteDirectory);
   
   // get the type menu
   UIMenu typemenu     = new UIMenu();
   HashMap typemenumap = typemenu.getMenu(context, type);
   String showrmb = typemenu.getSetting(typemenumap, "Show RMB");
   String rmbmenu = typemenu.getSetting(typemenumap, "RMB Menu");
   
   //go and see settings on the RMB Menu
   HashMap rmbmenumap = typemenu.getMenu(context, rmbmenu);

   
   //get the child commands
   MapList children = (MapList)rmbmenumap.get("children");
   
   //iterate through the commands
   // to the action items and create
   // new Menuitems
   Iterator itr = children.iterator();
   while (itr.hasNext())
   {
       Map mp = new HashMap();
       mp     = (HashMap)itr.next();
       String typeC = (String)mp.get("type");
       if("command".equals(typeC))
       {
           //treemenu.addItem(new emxUIMenuItem(objMilestone.icon, objMilestone.label, objMilestone.url));
           UICache command = new UICache();

           
           HashMap commandmap = command.getCommand(context, (String)mp.get("name"));
           
           HashMap settings = (HashMap)commandmap.get(UICache.SETTINGS);
           
           String href = (String)commandmap.get("href");
           String regSuite = (String)settings.get("Registered Suite");
           String target = (String)settings.get("Target Location");
           String label = EnoviaResourceBundle.getProperty(context,
               regSuite,
               (String)commandmap.get("label"),lang);
           
           String icon = (String)settings.get("Image");
           
           
           
           icon = correctforMacro(icon,regSuite,objectAction,false);
           href = correctforMacro(href,regSuite,objectAction,true);
           
           
           if(!buf.toString().contains("new emxUIMenu"))
           {
               buf.append("treeRMBMenu=new emxUIMenu();");
           }
               
           buf.append("treeRMBMenu.addItem(new emxUIMenuItem(\'");
           buf.append(icon);
           buf.append("\',\"");
           buf.append(label);
           buf.append("\",\"");
           buf.append(href);
           buf.append("\",\"");
           buf.append(target+"\"));");
           
           
       }
       
   }
   
   out.clear();
   response.setContentType("text/xml; charset=UTF-8");
%>
<%!
private String correctforMacro(String icon,String regSuite,String oid,Boolean addOID)
{
    try
    {
        String temp = icon.substring( icon.indexOf("/"),icon.length());
        String other = icon.substring( icon.indexOf("{")+1,icon.indexOf("_"));
        String returnS = "";
        if(icon!=null && icon.contains("${SUITE_DIR}"))
        {
            returnS =  ("../"+regSuite.toLowerCase()+temp);
        }
        else if(icon!=null && icon.contains("../") )
        {
            returnS =  (icon);
        }
        else
        {
            returnS =  ("../"+other.toLowerCase()+temp);
            
        }
        if(addOID)
        {
            returnS= returnS + "&objectId=" + oid;
        }
        return returnS;
    }
    catch(Exception e)
    {
        return "";
    }
}
%>


<%=buf.toString() %>
