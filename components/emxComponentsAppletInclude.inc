<%-- emxComponentsAppletInclude.inc - 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsAppletInclude.inc.rca 1.7 Wed Oct 22 16:18:57 2008 przemek Experimental przemek $"
--%>

<%@ page import="java.util.*,com.matrixone.apps.domain.util.FrameworkProperties"%>
<%!

private static final String APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_UNIX = "http://java.sun.com/javase/downloads/index.jsp";
private static final String APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_WINDOWS = "http://java.sun.com/update/1.6.0/jinstall-6u14-windows-i586.cab";
private static final String APPLET_DEFAULT_CODEBASE_PLUG_IN_VER = "1,6,0,14";
private static final String jarFiles = "FileUploadApplet.jar,FcsClient.jar";
private static final String jarFiles_j7u45 = "FileUploadApplet_j7u45.jar,FcsClient_j7u45.jar";

boolean isEmpty(String checkValue) {
    return checkValue == null || checkValue.equals("") || "null".equals(checkValue); 
}


void addApplet(HttpServletRequest request, HttpServletResponse response, JspWriter out, matrix.db.Context context, String appletClass, int width, int height, HashMap props)  throws Exception
{
    String userAgent = request.getHeader("User-Agent").toLowerCase();
    boolean unixClient = userAgent.indexOf("x11") != -1 || userAgent.indexOf("hp-ux") != -1 || userAgent.indexOf("sunos") != -1;
    String appAppletCodeBase = com.matrixone.servlet.Framework.getFullClientSideURL(request,response, "") + "/WebClient";
    String name = "gui"; 
    
    String jreVersion = FrameworkProperties.getProperty(context,"emxFramework.Applet.JREVersion");
    String codeBasePlugInVer = FrameworkProperties.getProperty(context,"emxFramework.Applet.CODEBASE_JavaPlugIn");
    String codeBasePlugInURL = null;
    
    
    boolean useDefaultPlugInInfo = isEmpty(codeBasePlugInVer);

    if(!useDefaultPlugInInfo) {
        if(unixClient)
        {
            codeBasePlugInURL = (String)FrameworkProperties.getProperty(context,"emxFramework.Unix.JavaPlugInURL");
            useDefaultPlugInInfo = isEmpty(codeBasePlugInURL);
        } else {
            codeBasePlugInURL = (String)FrameworkProperties.getProperty(context,"emxFramework.Windows.JavaPlugInURL");
            useDefaultPlugInInfo = isEmpty(codeBasePlugInURL);
        }
    }
    
    if(useDefaultPlugInInfo) {
        codeBasePlugInVer = APPLET_DEFAULT_CODEBASE_PLUG_IN_VER;
        codeBasePlugInURL = unixClient ? APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_UNIX : APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_WINDOWS;
    }
    
    out.println("<script src=\"../common/scripts/enoviaJavaPluginUtil.js\" type=\"text/javascript\"></script>");
    out.println("<script src=\"../common/scripts/emxUIEmbeddedObjects.js\" type=\"text/javascript\"></script>");
    out.println("<script type=\"text/javascript\">");   
    out.println("var objEmb = new ObjectEmbedder();");
	out.println("objEmb.setType(OBJECT_TAG);");
	out.println("objEmb.addAttribute(\"classid\",\"clsid:" + jreVersion + "\");");
    out.println("objEmb.addAttribute(\"name\",\"" + name + "\");");
    String codebase = codeBasePlugInURL + "#Version=" + codeBasePlugInVer;
    out.println("objEmb.addAttribute(\"codebase\",\"" + codebase + "\");"); 
    out.println("objEmb.addAttribute(\"WIDTH\",\"" + width + "\");"); 
    out.println("objEmb.addAttribute(\"HEIGHT\",\"" + height + "\");");
    out.println("objEmb.addParameter(\"java_code\",\"" + appletClass + "\");");
    out.println("objEmb.addParameter(\"java_codebase\",\"" + appAppletCodeBase + "\");");
    out.println("if(getJavaState().state == \"ok\" && getJavaState().version == \"7\"  && getJavaState().update == \"45\"){ objEmb.addParameter(\"java_archive\",\"" + jarFiles_j7u45 + "\");} ");
    out.println("else{objEmb.addParameter(\"java_archive\",\"" + jarFiles + "\");}");
    String type = "application/x-java-applet";
    out.println("objEmb.addParameter(\"type\",\"" + type + "\");");
    out.println("objEmb.addParameter(\"scriptable\",\"true\");");

    String key;
    String value;
    Iterator iter = props.keySet().iterator();
    while (iter.hasNext())
    {
        key = (String)iter.next();
        value = (String)props.get(key);
        out.println("objEmb.addParameter(\"" + key + "\",\"" + value + "\");");
    }

    out.println("objEmb.addEmbedAttribute(\"type\",\"" + type + "\");");
    out.println("objEmb.addEmbedAttribute(\"code\",\"" + appletClass + "\");");
    out.println("objEmb.addEmbedAttribute(\"name\",\"" + name + "\");");
    out.println("objEmb.addEmbedAttribute(\"java_code\",\"" + appletClass + "\");");
    out.println("objEmb.addEmbedAttribute(\"java_codebase\",\"" + appAppletCodeBase + "\");");
    
    out.println("if(getJavaState().state == \"ok\" && getJavaState().version == \"7\"  && getJavaState().update == \"45\"){objEmb.addEmbedAttribute(\"java_archive\",\"" + jarFiles_j7u45 + "\");} ");
    out.println("else{objEmb.addEmbedAttribute(\"java_archive\",\"" + jarFiles + "\");}");
    out.println("objEmb.addEmbedAttribute(\"width\",\"" + width + "\");"); 
    out.println("objEmb.addEmbedAttribute(\"height\",\"" + height + "\");");
    out.println("objEmb.addEmbedAttribute(\"scriptable\",\"true\");");

    iter = props.keySet().iterator();
    while (iter.hasNext())
    {
        key = (String)iter.next();
        value = (String)props.get(key);
        out.println("objEmb.addEmbedAttribute(\"" + key + "\",\"" + value + "\");");
    }
    out.println("objEmb.addEmbedAttribute(\"pluginspage\",\"" + codeBasePlugInURL + "\");");
    out.println("objEmb.draw();\n</script>");
}%>

 <script language="javascript">
 
 function getApplet() {
        if (document.applets.length > 0) {
          // IE keeps it here
          if(isIE){
               var app = document.applets.gui;
          	   return app;
         }
        } else if (document.embeds.length > 0) {
            // firefox keeps it here
            return document.embeds.gui;
		} else {
   		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.CanNotStartApplet</emxUtil:i18nScript>");
   		return "";
		}
	}
 
  </script>
