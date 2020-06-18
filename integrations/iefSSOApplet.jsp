<%--  iefSSOApplet..jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   iefSSOApplet.jsp name is used in IEFSSOHelper.java
--%>
<%@ page import="matrix.db.*,com.matrixone.apps.domain.util.*,matrix.util.*,java.io.File,java.io.*,java.net.*,java.util.*"%>
<%@ page import="com.matrixone.servlet.Framework,com.matrixone.servlet.FrameworkServlet,com.matrixone.MCADIntegration.utils.MCADUrlUtil"%>
<html>
<head>
<%!

public void copyEnoviaUserName(String ticketvalue,String remoteUser,String ssoServer)
{
	
			String enoviaUsername	= null;
			InputStreamReader in	= null;
			BufferedReader br		= null;
			Writer outputFile		= null;
			
			try
			{
				if(ticketvalue != null && !"".equals(ticketvalue))
				{
					
					StringBuffer ticketURL	= new StringBuffer();
					
					ticketURL.append(ssoServer);
					ticketURL.append("/TicketInformationServlet?ticket=");
					ticketURL.append(ticketvalue);
									
					URL TicketInformationServletURL = new URL (ticketURL.toString());
					URLConnection conn		= TicketInformationServletURL.openConnection();
					
							
					in		= new InputStreamReader(conn.getInputStream());
					br		= new BufferedReader(in);
					
					if(br != null)
						enoviaUsername	= br.readLine();

					System.out.println("[iefSSOApplet.jsp] Enovia username :"+enoviaUsername);
	
					if(enoviaUsername != null && !"".equals(enoviaUsername))
					{
						File ticketDirectory = new File ("ticket");
	
						if ((!ticketDirectory.exists()) && (!ticketDirectory.isDirectory()))
						{
							ticketDirectory.mkdir();				
						}

						String ticketString = "ticket/" + remoteUser;					
								
						outputFile = new BufferedWriter(new FileWriter(ticketString));
						if(outputFile != null)
							outputFile.write(enoviaUsername);
						
					}
				}
			}
			catch(Exception e)
			{
				System.out.println(e.getMessage());
			}
			finally
			{				
				try
				{
					if(br != null)
						br.close();
					
					if(outputFile != null)
						outputFile.close();
				}
				catch(Exception e)
				{
					System.out.println("unable to close the file :"+e.getMessage());
				}
			}
}

%>
<script language="javascript">
<% 
    String ssoticket =Request.getParameter(request,"ticket");
	String ssoServer = (String)session.getAttribute("IEFSSOServerURL");
	String ssohttpsUrl 	= null;
	String portDirectory =Request.getParameter(request,"portDirectory");
	String portFile =Request.getParameter(request,"portFile");
	
	if(ssoServer == null) 
	{
			session.setAttribute("IEFSSOServerURL", "dummyValue");
%>
    //XSSOK
    top.location.href = "./iefSSOApplet.jsp?ticket="+'<%=Request.getParameter(request,"ticket")%>'+"&service=" + '<%=request.getRequestURL()%>'+"&portDirectory="+'<%=portDirectory%>'+"&portFile="+'<%=portFile%>';
<%
}
else
{
			String ticketvalue	=Request.getParameter(request,"ticket");
			
			//Read the SSO server url from properties file.
			java.util.ResourceBundle iefProperties = java.util.PropertyResourceBundle.getBundle("ief",java.util.Locale.getDefault());
			ssoServer = (String)iefProperties.getString("mcadIntegration.Server.SSOServerUrl");	
			ssohttpsUrl = (String)iefProperties.getString("mcadIntegration.Server.SSOHttpsUrl");
			
			//Copy enovia username from casserver to enovia server.
			//and store it in file with name = remoteuser
			//copyEnoviaUserName(ticketvalue,remoteUser,ssoServer);
			
			//Remove  session value immediately here 
			session.removeAttribute("IEFSSOServerURL");
}

%>

function showAlert(message, closeWindow)
{
	alert("You can safely close this browser");
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

</script>

</head>
<body>
<% 
	
	String appletForNS	= "../WebClient/iefApplet.jar";
	String seesionId	= session.getId();
	String ssocookie	= request.getHeader("Cookie");
	String remoteUser   =  null;
	
	
	Framework.isLoggedIn(request);
	Context context = null;
	context = Framework.getMainContext(request.getSession());
	if(context != null)
	{
		remoteUser = context.getUser();
	}
	
	if(remoteUser == null || remoteUser.length() == 0 )
	{	
		remoteUser = request.getRemoteUser();
	}
	
	if(remoteUser != null && remoteUser.indexOf("\\") != -1)
	{	
		int delim = remoteUser.indexOf("\\");
	    remoteUser = remoteUser.substring(delim+1);
	}
	
	System.out.println("[iefSSOApplet.jsp]:::  remoteUser ----> " + remoteUser);
	System.out.println("[iefSSOApplet.jsp]:::  ssocookie ----> " + ssocookie);
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
		document.writeln('<applet name="MxMCADApplet" ARCHIVE='+jarstoload+' align=middle code="com.matrixone.MCADIntegration.client.applet.SSOApplet.class" codebase = "./" WIDTH=1 HEIGHT=1 MAYSCRIPT >');
		//XSSOK
        document.writeln(buildParamTag('ssocookie','<%=ssocookie%>'));
		document.writeln(buildParamTag('codebase_lookup','FALSE')); 
        //XSSOK
        document.writeln(buildParamTag('ssoticket','<%=ssoticket%>'));                
        //XSSOK		
		document.writeln(buildParamTag('ssoserver','<%=ssoServer%>')); 
		//XSSOK
		document.writeln(buildParamTag('ssohttpsurl','<%=ssohttpsUrl%>')); 
		//XSSOK
		document.writeln(buildParamTag('remoteUser','<%=remoteUser%>')); 
		//XSSOK
		document.writeln(buildParamTag('portDirectory','<%=portDirectory%>')); 
		//XSSOK
		document.writeln(buildParamTag('portFile','<%=portFile%>')); 
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

		out.println("objEmb.addAttribute(\"WIDTH\",\"1\");"); 
		out.println("objEmb.addAttribute(\"HEIGHT\",\"1\");");
		out.println("objEmb.addAttribute(\"align\",\"middle\");"); 
		out.println("objEmb.addParameter(\"java_code\",\"com.matrixone.MCADIntegration.client.applet.SSOApplet.class\");");
		out.println("objEmb.addParameter(\"java_codebase\",\"" + "./" + "\");");
		out.println("objEmb.addParameter(\"java_archive\",getJreSpecificJars());");
		out.println("objEmb.addParameter(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addParameter(\"mayscript\",\"true\");");
		out.println("objEmb.addParameter(\"ssocookie\",\"" + ssocookie + "\");");
		out.println("objEmb.addParameter(\"ssoticket\",\"" + ssoticket + "\");");
		out.println("objEmb.addParameter(\"ssoserver\",\"" + ssoServer + "\");");
		out.println("objEmb.addParameter(\"ssohttpsurl\",\"" + ssohttpsUrl + "\");");
		out.println("objEmb.addParameter(\"remoteUser\",\"" + remoteUser + "\");");
		out.println("objEmb.addParameter(\"portDirectory\",\"" + portDirectory + "\");");
		out.println("objEmb.addParameter(\"portFile\",\"" + portFile + "\");");

		String type = "application/x-java-applet";
		out.println("objEmb.addParameter(\"java_type\",\"" + type + "\");");

		out.println("objEmb.addEmbedAttribute(\"name\",\"" + name + "\");");
		out.println("objEmb.addEmbedAttribute(\"type\",\"" + type + "\");");
		out.println("objEmb.addEmbedAttribute(\"java_version\",\"" + javaVersionFx + "\");");
		out.println("objEmb.addEmbedAttribute(\"align\",\"middle\");");
		out.println("objEmb.addEmbedAttribute(\"codebase\",\"" + "./" + "\");"); 
		out.println("objEmb.addEmbedAttribute(\"WIDTH\",\"1\");"); 
		out.println("objEmb.addEmbedAttribute(\"HEIGHT\",\"1\");");
		out.println("objEmb.addEmbedAttribute(\"archive\",getJreSpecificJars());");
		out.println("objEmb.addEmbedAttribute(\"code\",\"com.matrixone.MCADIntegration.client.applet.SSOApplet.class\");");
		out.println("objEmb.addEmbedAttribute(\"mayscript\",\"true\");");
		out.println("objEmb.addEmbedAttribute(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addEmbedAttribute(\"ssocookie\",\"" + ssocookie + "\");");
		out.println("objEmb.addEmbedAttribute(\"ssoticket\",\"" + ssoticket + "\");");
		out.println("objEmb.addEmbedAttribute(\"ssoserver\",\"" + ssoServer + "\");");
		out.println("objEmb.addEmbedAttribute(\"ssohttpsurl\",\"" + ssohttpsUrl + "\");");
		out.println("objEmb.addEmbedAttribute(\"remoteUser\",\"" + remoteUser + "\");");
		out.println("objEmb.addEmbedAttribute(\"portDirectory\",\"" + portDirectory + "\");");
		out.println("objEmb.addEmbedAttribute(\"portFile\",\"" + portFile + "\");");
		out.println("objEmb.draw();\n</script>");
	}
%>	
			<center><b>SSO Applet.</b></center>
			<br><br><br><br>
			<center>Please wait while SSO Applet is loading...</center>
</body>
</html>
