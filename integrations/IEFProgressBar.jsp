<%--  IEFProgressBar.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context	= integSessionData.getClonedContext(session);
	boolean isDebugEnabled			= integSessionData.getLocalConfigObject().isTurnDebugOn();

	String progressBarLabel			= integSessionData.getStringResource("mcadIntegration.Server.Title.ProgressBar");
	String objectsProcessedLabel	= integSessionData.getStringResource("mcadIntegration.Server.Message.ObjectsProcessed");
	String filesTransferredLabel	= integSessionData.getStringResource("mcadIntegration.Server.Message.FilesTransferred");

	String metaDataLabel 			= integSessionData.getStringResource("mcadIntegration.Server.Message.MetaData");
	String fileTransferLabel 		= integSessionData.getStringResource("mcadIntegration.Server.Message.FileTransfer");
	String activityBarLabel 		= integSessionData.getStringResource("mcadIntegration.Server.Message.ActivityBar");
	String cancelButtonLabel		= integSessionData.getStringResource("mcadIntegration.Server.Message.Cancel");

	String progessWindowType		=Request.getParameter(request,"progessWindowType");
	String metaMaxCount				=Request.getParameter(request,"metaMaxCount");
	String fileMaxCount				=Request.getParameter(request,"fileMaxCount");
	String notifyCaller				=Request.getParameter(request,"notifyCaller");
	if(progessWindowType == null)
		progessWindowType = "MetaData";

	if(metaMaxCount == null)
		metaMaxCount = "0";

	if(fileMaxCount == null)
		fileMaxCount = "0";

	if(notifyCaller == null)
		notifyCaller = "false";

	String appletForNS	= "../WebClient/iefApplet.jar";

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

%>

<HTML>
<HEAD>
<!--XSSOK-->
<TITLE><%= progressBarLabel %></TITLE>
<script language="javascript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript">

	var timerid;
	var cancelSelected = false;

	window.onload=function()
	{
		timerid = setInterval("checkOpenerExistence()", 1000)
	}

	function checkOpenerExistence()
	{
		try
		{
			if(!top.opener.top.modalDialog || !top.opener.top.modalDialog.contentWindow || top.opener.top.modalDialog.contentWindow != self)
			{
				self.close();
			}
		}
		catch (error)
		{
		}
	}

	window.onunload=function()
	{
		clearInterval(timerid);
	}

	function getDecAppletProgressObject()
	{
		if (document.applets.length > 0) 
		{
			// IE keeps it here
			var app = document.applets.IEFProgressBar;
			return app;
		} else if (document.embeds.length > 0) 
		{
			// firefox keeps it here		
				return document.embeds.IEFProgressBar;	
		} else {		
			return "";
		}		
	}

	function updateProgressBar(metaCurrentCount, fileCurrentCount)
	{
		if(metaCurrentCount != 0 && metaCurrentCount <= <%= XSSUtil.encodeForJavaScript(context,metaMaxCount) %>)
			getDecAppletProgressObject().updateProgressBar("MetaData", metaCurrentCount, "<%= objectsProcessedLabel %>");
		
		if(fileCurrentCount != 0 && fileCurrentCount <= <%= XSSUtil.encodeForJavaScript(context,fileMaxCount) %>)
			getDecAppletProgressObject().updateProgressBar("FileTransfer", fileCurrentCount, "<%= filesTransferredLabel %>");		
	}

	function cancelOperation()
	{
		if(!cancelSelected && top.opener!=null)
		{
			cancelSelected = true;
			top.opener.abortOperation();
		}
	}

	function notifyManager()
	{
		var integFrame	= getIntegrationFrame(this);
		integFrame.getAppletObject().callCommandHandler(null,"notifyUIManager", "");
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
			return "../WebClient/iefApplet_j7u45.jar";		
		}
		else{
			return "../WebClient/iefApplet.jar";		
		}
	}
	
	return "../WebClient/iefApplet.jar";			
}

</SCRIPT>
</HEAD>

<BODY topmargin="0" leftmargin="0">
	<table align="center" height="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
		<td>
<%	
	if(isPropertyAvailable == false)
	{	
%>		

<SCRIPT LANGUAGE="JavaScript">		
	function writeAppletTag() 
	{		
var jarstoload = getJreSpecificJars();
		document.writeln('<applet name="IEFProgressBar" width="410" height="120" ARCHIVE='+jarstoload+' code="com.matrixone.MCADIntegration.client.progressbar.IEFProgressWindow.class" codebase = "./"  MAYSCRIPT >');
        document.writeln(buildParamTag('ProgessWindowType','<xss:encodeForHTMLAttribute><%= progessWindowType%></xss:encodeForHTMLAttribute>'));
        document.writeln(buildParamTag('MetaMaxCount','<xss:encodeForHTMLAttribute><%= metaMaxCount %></xss:encodeForHTMLAttribute>'));                
document.writeln(buildParamTag('codebase_lookup','FALSE'));        
		document.writeln(buildParamTag('FileMaxCount','<xss:encodeForHTMLAttribute><%= fileMaxCount %></xss:encodeForHTMLAttribute>')); 
		//XSSOK
		document.writeln(buildParamTag('MetaDataLabel','<%= metaDataLabel %>')); 
		//XSSOK
		document.writeln(buildParamTag('FileTransferLabel','<%= fileTransferLabel %>')); 
		//XSSOK
		document.writeln(buildParamTag('ActivityBarLabel','<%= activityBarLabel %>')); 
		//XSSOK
		document.writeln(buildParamTag('CancelButtonLabel','<%= cancelButtonLabel %>')); 
		document.writeln(buildParamTag('NotifyCaller','<xss:encodeForHTMLAttribute><%= notifyCaller %></xss:encodeForHTMLAttribute>')); 
		document.writeln(buildParamTag('cache_option','Plugin')); 
		document.writeln(buildParamTag('cache_archive',getJreSpecificJars())); 
		document.writeln(buildParamTag('cache_version','A.0.0.1')); 
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
		String name = "IEFProgressBar"; 

		out.println("<script src=../common/scripts/emxUIEmbeddedObjects.js type=\"text/javascript\"></script>");
		out.println("<script type=\"text/javascript\">");   
		out.println("var objEmb = new ObjectEmbedder();");
		out.println("objEmb.setType(OBJECT_TAG);");

		out.println("objEmb.addAttribute(\"name\",\"" + name + "\");");		
		out.println("objEmb.addAttribute(\"classid\",\"clsid:" + jreVersionClassid + "\");");

		out.println("objEmb.addAttribute(\"WIDTH\",\"410\");"); 
		out.println("objEmb.addAttribute(\"HEIGHT\",\"120\");");
		out.println("objEmb.addParameter(\"java_archive\",getJreSpecificJars());");
		out.println("objEmb.addParameter(\"java_code\",\"com.matrixone.MCADIntegration.client.progressbar.IEFProgressWindow.class\");");
		out.println("objEmb.addParameter(\"java_codebase\",\"" + "./" + "\");");
		out.println("objEmb.addParameter(\"mayscript\",\"true\");");		
		out.println("objEmb.addParameter(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addParameter(\"ProgessWindowType\",\"" + XSSUtil.encodeForHTMLAttribute(context,progessWindowType) + "\");");
		out.println("objEmb.addParameter(\"MetaMaxCount\",\"" + XSSUtil.encodeForHTMLAttribute(context,metaMaxCount) + "\");");
		out.println("objEmb.addParameter(\"FileMaxCount\",\"" + XSSUtil.encodeForHTMLAttribute(context,fileMaxCount) + "\");");
		out.println("objEmb.addParameter(\"MetaDataLabel\",\"" + metaDataLabel + "\");");
		out.println("objEmb.addParameter(\"FileTransferLabel\",\"" + fileTransferLabel + "\");");
		out.println("objEmb.addParameter(\"ActivityBarLabel\",\"" + activityBarLabel + "\");");
		out.println("objEmb.addParameter(\"CancelButtonLabel\",\"" + cancelButtonLabel + "\");");
		out.println("objEmb.addParameter(\"NotifyCaller\",\"" + XSSUtil.encodeForHTMLAttribute(context,notifyCaller) + "\");");
		out.println("objEmb.addParameter(\"cache_option\",\"Plugin\");");
		out.println("objEmb.addParameter(\"cache_archive\",getJreSpecificJars());");
		out.println("objEmb.addParameter(\"cache_version\",\"A.0.0.1\");");

		String type = "application/x-java-applet";
		out.println("objEmb.addParameter(\"java_type\",\"" + type + "\");");

		out.println("objEmb.addEmbedAttribute(\"name\",\"" + name + "\");");
		out.println("objEmb.addEmbedAttribute(\"type\",\"" + type + "\");");
		out.println("objEmb.addEmbedAttribute(\"java_version\",\"" + javaVersionFx + "\");");
		out.println("objEmb.addEmbedAttribute(\"codebase\",\"" + "./" + "\");"); 
		out.println("objEmb.addEmbedAttribute(\"WIDTH\",\"410\");"); 
		out.println("objEmb.addEmbedAttribute(\"HEIGHT\",\"120\");");
		out.println("objEmb.addEmbedAttribute(\"archive\",getJreSpecificJars());");
		out.println("objEmb.addEmbedAttribute(\"code\",\"com.matrixone.MCADIntegration.client.progressbar.IEFProgressWindow.class\");");
		out.println("objEmb.addEmbedAttribute(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addEmbedAttribute(\"mayscript\",\"true\");");		
		out.println("objEmb.addEmbedAttribute(\"ProgessWindowType\",\"" + XSSUtil.encodeForHTMLAttribute(context,progessWindowType) + "\");");
		out.println("objEmb.addEmbedAttribute(\"MetaMaxCount\",\"" + XSSUtil.encodeForHTMLAttribute(context,metaMaxCount) + "\");");
		out.println("objEmb.addEmbedAttribute(\"FileMaxCount\",\"" + XSSUtil.encodeForHTMLAttribute(context,fileMaxCount) + "\");");
		out.println("objEmb.addEmbedAttribute(\"MetaDataLabel\",\"" + metaDataLabel + "\");");
		out.println("objEmb.addEmbedAttribute(\"FileTransferLabel\",\"" + fileTransferLabel + "\");");
		out.println("objEmb.addEmbedAttribute(\"ActivityBarLabel\",\"" + activityBarLabel + "\");");
		out.println("objEmb.addEmbedAttribute(\"CancelButtonLabel\",\"" + cancelButtonLabel + "\");");
		out.println("objEmb.addEmbedAttribute(\"NotifyCaller\",\"" + XSSUtil.encodeForHTMLAttribute(context,notifyCaller) + "\");");
		out.println("objEmb.addEmbedAttribute(\"cache_option\",\"Plugin\");");
		out.println("objEmb.addEmbedAttribute(\"cache_archive\",getJreSpecificJars());");
		out.println("objEmb.addEmbedAttribute(\"cache_version\",\"A.0.0.1\");");
		out.println("objEmb.draw();\n</script>");
	}	
%>
		</td>
		</tr>
	</table>
</BODY>
</HTML>
