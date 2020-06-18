<%--  silentief.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ page import="com.matrixone.apps.framework.ui.*, com.matrixone.apps.domain.util.*" %>

<%@ include file="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@page import = "com.matrixone.apps.domain.util.*" %>

<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>

<%
	String requestURI				= request.getRequestURI();

    String pathWithIEFDir			= requestURI.substring(0, requestURI.lastIndexOf('/'));
    String pathWithIntegrationsDir  = pathWithIEFDir.substring(0, pathWithIEFDir.lastIndexOf('/'));
    String pathWithAppName			= pathWithIntegrationsDir.substring(0, pathWithIntegrationsDir.lastIndexOf('/'));

    String referer					= request.getRequestURL().toString();
    String refServer				= referer.substring( 0, referer.indexOf(Framework.getPagePathURL("")));
    String appName					= application.getInitParameter("ematrix.page.path");

    if(appName == null) 
		appName = "";

    String requestCookie	= request.getHeader("Cookie");
	String responseCookie	= response.getHeader("Set-Cookie");

	String sessionId = "JSESSIONID=" + session.getId();

	if(requestCookie != null && !requestCookie.equals(""))
	{
		sessionId = requestCookie;		
	}
	else if(responseCookie != null && !responseCookie.equals(""))
	{
		sessionId = responseCookie;		
	}

    String virtualPath				= refServer + appName;

	System.out.println("virtualPath: " + virtualPath);

	Context context					= Framework.getFrameContext(session);
	
    ResourceBundle mcadIntegrationBundle			= ResourceBundle.getBundle("ief");
    String acceptLanguage							= request.getHeader("Accept-Language");
    MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);
	String browserHeading							= serverResourceBundle.getString("mcadIntegration.Server.Title.SilentIEFBrowserHeading");
	String warningMessage							= serverResourceBundle.getString("mcadIntegration.Server.Message.BatchProcessorWarning");

    session.setAttribute("MCADIntegration-CurrentApplicationName", "verdi");

	String appletPort								= Request.getParameter(request,"appletPort");

	if(appletPort == null  || appletPort.equals(""))
	{
		 warningMessage = serverResourceBundle.getString(("mcadIntegration.Server.Message.SilentAppletPageMessage"));
		 appletPort		= "";
	}
	
	String mcadCharset				= null;
	boolean debugFlag				= true;
	boolean bCustomLiveConnect		= false;
	String isMultiPortRangeEnabled	= null;
	String multiPortRangeMax		= null;
	String multiPortRangeMin		= null;
	
	try
	{
		mcadCharset	= mcadIntegrationBundle.getString("mcadIntegration.MCADCharset");
	}
	catch(MissingResourceException _ex)
	{
		System.out.println("Charset not set for IEF");
	}
	try
	{
		isMultiPortRangeEnabled = mcadIntegrationBundle.getString("mcadIntegration.EnableMultiPortRange");
	}
	catch(MissingResourceException excepton)
	{
		System.out.println("EnableMultiPortRange property missing");
	}
	try
	{
		multiPortRangeMax = mcadIntegrationBundle.getString("mcadIntegration.MultiPortRangeMax");
	}
	catch(MissingResourceException excepton)
	{
		System.out.println("MultiPortRangeMax property missing");
	}
	try
	{
		multiPortRangeMin = mcadIntegrationBundle.getString("mcadIntegration.MultiPortRangeMin");
	}
	catch(MissingResourceException excepton)
	{
		System.out.println("MultiPortRangeMin property missing");
	}

	String appletForNS	= "../WebClient/iefApplet.jar, ../WebClient/FcsClient.jar";

%>
<html>
	<head>
		<title>
		    <!--XSSOK-->
			<%=browserHeading%>
		</title>

	<script language="JavaScript">

	function callJSMethodFromApplet()
	{
		var retVal = "";
		try
		{
			var integFrame = getIntegrationFrame(this);
			var mxmcadApplet = integFrame.getAppletObject(); 
			var jsMethodName = mxmcadApplet.getJSMethodName();
			if(jsMethodName != "")
			{
				retVal = eval( jsMethodName + "();" );
				try
				{
					if(retVal == "")
						retVal = "true";
					mxmcadApplet.setJSMethodRetVal(retVal);
				}
				catch(error1)
				{
					alert("Error from callJSMethodFromApplet - can not set retVal ::" + error1.description);
				}
			}
		}
		catch(error)
		{
			alert("Error from callJSMethodFromApplet ::" + error.description);
		}

		window.setTimeout("callJSMethodFromApplet()", 200);
	}

	function isPoppedUpWindowOpened()
	{
		if (top.modalDialog && top.modalDialog.contentWindow && !(top.modalDialog.contentWindow.closed))
			return "true";
		else
			return "false";
	}

	function redirectToNewURL(arg)
	{
		if(isCustomLiveConnect)
		{
			arg = getAppletObject().getJSArgs(0);
		}

		sForwardURL = arg;
		setTimeout('top.window.location = sForwardURL;',2500);
	}

	
var getJavaState = function () {
    var maxJavaMajorVersion = 0, maxJavaMinorVersion = 0,
        updates = {},
        pluginName = 'Java(TM)',
        name,
        i, l,
        plugin, pluginTag, jvms,
        saveVersion = function (major, minor) {
            if (major >= maxJavaMajorVersion) {
                maxJavaMajorVersion = major;
                if (!updates[major]) {
                    updates[major] = [];
                }
                updates[major].push(parseInt(minor, 10));
            }
        };

    if (navigator.plugins && navigator.plugins.length) {
        for (i = 0, l = navigator.plugins.length; i < l; i++) {
            name = navigator.plugins[i].name;
            //The version of the plugin is only contained in the name with the following format "Java(TM) Platform SE 6 U20"
            if (name.indexOf(pluginName) !== -1) {
                saveVersion(parseInt(name[21], 10), parseInt(name.substring(24), 10));
            }else if (name.indexOf('Java Plug-in') !== -1) {
                saveVersion(parseInt(name.substring(15), 10), parseInt(name.substring(19), 10));
            }
        }
    } else {
        // No plugins, we are very probably in IE
        pluginTag = '<' +
                'object classid="clsid:CAFEEFAC-DEC7-0000-0001-ABCDEFFEDCBA" ' +
                'id="deployJavaPlugin" width="0" height="0">' +
                '<' + '/' + 'object' + '>';
        document.write(pluginTag);
        plugin = document.getElementById('deployJavaPlugin');
        jvms = plugin.jvms;
        if (jvms) {
            for (i = 0, l = jvms.getLength(); i < l; i++) {
                name = jvms.get(i).version;
                saveVersion(parseInt(name[2], 10), parseInt(name.substring(6), 10) || 0);
            }
        }
    }
    maxJavaMinorVersion = Math.max(Math.max.apply(Math, updates[maxJavaMajorVersion] || [0]), 0);
    
    //case where no java plugin has been found
    if (0 === maxJavaMajorVersion && 0 === maxJavaMinorVersion) {
        return {state: 'nojava'};
    }
    // Min Java version is V7 U17
    if (maxJavaMajorVersion < 7) {
        return {state: 'outdated'};
    }

    if ((maxJavaMajorVersion === 7) && (maxJavaMinorVersion < 11)) {
        return {state: 'outdated'};
    }
    return {
        state: 'ok',
        version: maxJavaMajorVersion,
        update: maxJavaMinorVersion
    };
};

function getJreSpecificJars()
{
	var statestatus = getJavaState();
	var status = statestatus.state; 
	if(status.indexOf('ok') !== -1)
	{
		var version = statestatus.version + '_' + statestatus.update;	
		if (version.indexOf('7_45') !== -1 || version.indexOf('6_65') !== -1){
			return "../WebClient/iefApplet_j7u45.jar, ../WebClient/FcsClient_j7u45.jar";		
		}
		else{
			return "../WebClient/iefApplet.jar, ../WebClient/FcsClient.jar";		
		}
	}
	
	return "../WebClient/iefApplet.jar, ../WebClient/FcsClient.jar";			
}

	</script>
		

	</head>	
	<%@ include file="silentiefutils.inc" %>
	<body>
<%	
	boolean isPropertyAvailable = false;
	boolean isSafari = false;
	boolean isMSIE = false;
	String javaVersionFx = "";
	String jreVersionClassid = "";
	String user_agent = null;		

	try{
		user_agent = request.getHeader( "User-Agent" ).toLowerCase();		
		isSafari = ( user_agent != null && user_agent.indexOf( "safari" ) != -1 );
		isMSIE = ( user_agent != null && user_agent.indexOf( "msie" ) != -1 );	
		javaVersionFx = FrameworkProperties.getProperty(context,"emxFramework.Applet.Firefox.JREVersion");	
		if(null != javaVersionFx && !"null".equals(javaVersionFx) && !javaVersionFx.equals("") && isMSIE != true && isSafari != true)
			isPropertyAvailable = true;
	}catch(Exception excepton){
			isPropertyAvailable = false;
	}

	if(isPropertyAvailable == false)
	{
		try{
			jreVersionClassid = FrameworkProperties.getProperty(context,"emxFramework.Applet.JREVersion");		
			if((null != jreVersionClassid && !"null".equals(jreVersionClassid) && !jreVersionClassid.equals("")) && (isMSIE == true ))
				isPropertyAvailable = true;
		}catch(Exception excepton){
			isPropertyAvailable = false;
		}
	}

	if(isSafari == true)
		isPropertyAvailable = false;	
	
	if(isPropertyAvailable == false)
	{		
%>
<SCRIPT LANGUAGE="JavaScript">		
	function writeAppletTag() 
	{		
var jarstoload = getJreSpecificJars();
		document.writeln('<applet name="MxMCADApplet" ARCHIVE='+jarstoload+' align=middle code="com.matrixone.MCADIntegration.client.applet.DSCApplet.class" codebase = "./" WIDTH=1 HEIGHT=1 MAYSCRIPT >');
		//XSSOK
        document.writeln(buildParamTag('VIRTUALPATH','<%=virtualPath%>'));
		//XSSOK
        document.writeln(buildParamTag('ROOT','<%=refServer%>'));                
		document.writeln(buildParamTag('DEBUG','<%=debugFlag%>')); 
		document.writeln(buildParamTag('DEBUGFILEPATH','')); 
		//XSSOK
		var appletPortVar = '<%=appletPort%>';
		if(appletPortVar == null || appletPortVar.length == 0)
		{
		    //XSSOK
			document.writeln(buildParamTag('MULTIPORTRANGEENABLED','<%=isMultiPortRangeEnabled%>')); 
			//XSSOK
			document.writeln(buildParamTag('MULTIPORTRANGEMAX','<%=multiPortRangeMax%>')); 
			//XSSOK
			document.writeln(buildParamTag('MULTIPORTRANGEMIN','<%=multiPortRangeMin%>')); 
			document.writeln(buildParamTag('REDIRECT','TRUE')); 
		}else{
		    //XSSOK
			document.writeln(buildParamTag('PORT','<%=appletPort%>')); 
		}		
		//XSSOK
		document.writeln(buildParamTag('MCADCHARSET','<%=mcadCharset%>')); 
		//XSSOK
		document.writeln(buildParamTag('ACCEPTLANGUAGE','<%=acceptLanguage%>')); 
		document.writeln(buildParamTag('USERLOGGEDIN','FALSE')); 
		document.writeln(buildParamTag('CUSTOMLIVECONNECT','<%=isCustomLiveConnect%>')); 
		document.writeln(buildParamTag('cache_archive',jarstoload));
		//XSSOK
		document.writeln(buildParamTag('sessionId','<%=sessionId%>')); 
        document.writeln('</applet>');                
	}

	function buildParamTag(name, value) 
	{
		return '<PARAM NAME="' + name + '" VALUE="' + value + '">';
    }
	
	writeAppletTag();
	
</SCRIPT>
			
<%
	}else
	{
		String name = "MxMCADApplet"; 	

		out.println("<script src=../common/scripts/emxUIEmbeddedObjects.js type=\"text/javascript\"></script>");
		out.println("<script type=\"text/javascript\">");   
		out.println("var objEmb = new ObjectEmbedder();");
		out.println("objEmb.setType(OBJECT_TAG);");		
		out.println("objEmb.addAttribute(\"name\",\"" + name + "\");");
		out.println("objEmb.addAttribute(\"classid\",\"clsid:" + jreVersionClassid + "\");");		
		
		out.println("objEmb.addAttribute(\"align\",\"middle\");"); 		
		out.println("objEmb.addAttribute(\"WIDTH\",\"1\");"); 
		out.println("objEmb.addAttribute(\"HEIGHT\",\"1\");");				
                out.println("objEmb.addParameter(\"cache_archive\",getJreSpecificJars());");		
		
		out.println("objEmb.addParameter(\"java_archive\",getJreSpecificJars());");
		out.println("objEmb.addParameter(\"java_code\",\"com.matrixone.MCADIntegration.client.applet.DSCApplet.class\");");
		out.println("objEmb.addParameter(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addParameter(\"java_codebase\",\"" + "./" + "\");");
		out.println("objEmb.addParameter(\"mayscript\",\"true\");");
		out.println("objEmb.addParameter(\"VIRTUALPATH\",\"" + virtualPath + "\");");
		out.println("objEmb.addParameter(\"ROOT\",\"" + refServer + "\");");
		out.println("objEmb.addParameter(\"DEBUG\",\"" + debugFlag + "\");");
		out.println("objEmb.addParameter(\"DEBUGFILEPATH\",\"\");");
		if(appletPort == null || appletPort.length() == 0)
		{
			out.println("objEmb.addParameter(\"MULTIPORTRANGEENABLED\",\"" + isMultiPortRangeEnabled + "\");");
			out.println("objEmb.addParameter(\"MULTIPORTRANGEMAX\",\"" + multiPortRangeMax + "\");");
			out.println("objEmb.addParameter(\"MULTIPORTRANGEMIN\",\"" + multiPortRangeMin + "\");");
			out.println("objEmb.addParameter(\"REDIRECT\",\"TRUE\");");
		}else
		{
			out.println("objEmb.addParameter(\"PORT\",\"" + appletPort + "\");");
		}
		out.println("objEmb.addParameter(\"MCADCHARSET\",\"" + mcadCharset + "\");");
		out.println("objEmb.addParameter(\"ACCEPTLANGUAGE\",\"" + acceptLanguage + "\");");
		out.println("objEmb.addParameter(\"USERLOGGEDIN\",\"FALSE\");");
		out.println("objEmb.addParameter(\"CUSTOMLIVECONNECT\",\"" + isCustomLiveConnect + "\");");
		out.println("objEmb.addParameter(\"sessionId\",\"" + sessionId + "\");");
				
		String type = "application/x-java-applet";
		out.println("objEmb.addParameter(\"java_type\",\"" + type + "\");");
		out.println("objEmb.addEmbedAttribute(\"type\",\"" + type + "\");");		
		out.println("objEmb.addEmbedAttribute(\"java_version\",\"" + javaVersionFx + "\");");				
		out.println("objEmb.addEmbedAttribute(\"name\",\"" + name + "\");");
		out.println("objEmb.addEmbedAttribute(\"align\",\"middle\");");			
        out.println("objEmb.addEmbedAttribute(\"codebase\",\"" + "./" + "\");"); 		
        out.println("objEmb.addEmbedAttribute(\"WIDTH\",\"1\");"); 
		out.println("objEmb.addEmbedAttribute(\"HEIGHT\",\"1\");");			
		out.println("objEmb.addEmbedAttribute(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addEmbedAttribute(\"archive\",getJreSpecificJars());");		
        out.println("objEmb.addEmbedAttribute(\"code\",\"com.matrixone.MCADIntegration.client.applet.DSCApplet.class\");");			
        out.println("objEmb.addEmbedAttribute(\"mayscript\",\"true\");");		
		out.println("objEmb.addEmbedAttribute(\"VIRTUALPATH\",\"" + virtualPath + "\");");
		out.println("objEmb.addEmbedAttribute(\"ROOT\",\"" + refServer + "\");");
		out.println("objEmb.addEmbedAttribute(\"DEBUG\",\"" + debugFlag + "\");");		
		out.println("objEmb.addEmbedAttribute(\"DEBUGFILEPATH\",\"\");");
		if(appletPort == null || appletPort.length() == 0)
		{
			out.println("objEmb.addEmbedAttribute(\"MULTIPORTRANGEENABLED\",\"" + isMultiPortRangeEnabled + "\");");
			out.println("objEmb.addEmbedAttribute(\"MULTIPORTRANGEMAX\",\"" + multiPortRangeMax + "\");");
			out.println("objEmb.addEmbedAttribute(\"MULTIPORTRANGEMIN\",\"" + multiPortRangeMin + "\");");
			out.println("objEmb.addEmbedAttribute(\"REDIRECT\",\"TRUE\");");
		}else
		{
			out.println("objEmb.addEmbedAttribute(\"PORT\",\"" + appletPort + "\");");
		}
		out.println("objEmb.addEmbedAttribute(\"MCADCHARSET\",\"" + mcadCharset + "\");");
		out.println("objEmb.addEmbedAttribute(\"ACCEPTLANGUAGE\",\"" + acceptLanguage + "\");");
		out.println("objEmb.addEmbedAttribute(\"USERLOGGEDIN\",\"FALSE\");");
		out.println("objEmb.addEmbedAttribute(\"CUSTOMLIVECONNECT\",\"" + isCustomLiveConnect + "\");");
		out.println("objEmb.addEmbedAttribute(\"sessionId\",\"" + sessionId + "\");");
		out.println("objEmb.draw();\n</script>");
	}
%>	
		<%@include file = "MCADBottomErrorInclude.inc"%>

		<i><b><font color="#0000FF"><div id="loggedinUser"></div></font></b></i>
		<p><i><b><font color="#0000FF"><!--XSSOK-->
			<%=warningMessage%>
		</font></b></i></p>
    </body>
</html>
