<%-- emxCommonAppletInclude.inc - 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonAppletInclude.inc.rca 1.5 Wed Oct 22 15:48:49 2008 przemek Experimental przemek $"
--%>

<%@ page import="java.util.*,
				org.jdom.*,
             	org.jdom.output.*"%>
<%!
public Element addApplet(String plugInCodeBase, 
				String appletClass, String name, 
				String codeBase, String jarFiles, 
				String width, String height, HashMap props ) throws Exception {  
				                                  
    // load java plug-in using dynamic versioning
    // if installed version of the plug in is 1.5 or above then do not download
    // else download from the URl specified by codebase property

    //OBJECT
    Element elmObj = new Element("object");
    elmObj.setAttribute("classid","clsid:8AD9C840-044E-11D1-B3E9-00805F499D93");
    elmObj.setAttribute("name",name);
	elmObj.setAttribute("codebase",plugInCodeBase + "#Version=1,5,0,0");
	elmObj.setAttribute("width",width);
	elmObj.setAttribute("height",height);
	//EMBED
    Element elmEmbed = new Element("embed");
	elmEmbed.setAttribute("code",appletClass);
	elmEmbed.setAttribute("name",name);
	elmEmbed.setAttribute("width",width);
	elmEmbed.setAttribute("height",height);
	//common properties to both tags
	props.put("java_code",appletClass);
	props.put("java_codebase",codeBase);
	props.put("java_archive",jarFiles);
	props.put("type","application/x-java-applet;version=1.5");
	props.put("scriptable","true");
	props.put("mayscript","true");

    String key;
    Iterator iter = props.keySet().iterator();
    while (iter.hasNext())
    {
        key = (String)iter.next();
        //add param name value pairs to object tag
		Element elmParam = new Element("param");
		elmParam.setAttribute("name",key);
		elmParam.setAttribute("value",(String)props.get(key));
		elmObj.addContent(elmParam);
		//add attribute name value pairs to embed tag
		elmEmbed.setAttribute(key,(String)props.get(key));
	}
	//add plugin @ to embed
	elmEmbed.setAttribute("pluginspage","http://java.sun.com/javase/downloads/index_jdk5.jsp");

	//comment tag
	Element elmComment = new Element("comment");
	//noembed tag
	Element elmNoembed = new Element("noembed");
	String str = "alt='Your browser understands the &lt;APPLET&gt;" +
				" tag but isn\'t running the applet, for some reason.'" + 
				" Your browser is completely ignoring the &lt;APPLET&gt; tag!";
	elmNoembed.addContent(str);
	//add noembed to embed
	elmEmbed.addContent(elmNoembed);
	//add embed to comment
	elmComment.addContent(elmEmbed);
	//add comment to object
	elmObj.addContent(elmComment);
	
	return elmObj;
}

/*
//need to get a string version fo future
String addApplet(String plugInCodeBase, 
		String appletClass, String name, 
		String codeBase, String jarFiles, 
		int width, int height, HashMap props ) throws Exception {

	Element elm = addApplet(plugInCodeBase, 
			appletClass, name, 
			codeBase, jarFiles, 
			width, height, props );
	return elm.toString();
}
*/
%>
             	
