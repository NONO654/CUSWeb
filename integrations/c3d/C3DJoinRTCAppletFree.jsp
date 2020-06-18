<%-- 
   C3DJoinRTCAppletFree.jsp
   
   This file will launch AV applet in RTC mode and participant of the meeting can join the session hosted
   by host of the meeting.

   Copyright Dassault Systemes, 1992-2011. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   This JSP file will be launched from C3DController servlet in response to action "Join Meeting".

--%>
<%@ page contentType="text/html; charset=UTF-8" import="java.net.InetAddress,org.owasp.esapi.*"%>
<%@ page errorPage="error.jsp" %>

<%@page import="com.ds.enovia.c3d.controller.C3DResourceBundle"%>
<%@ page import="com.ds.enovia.vif.util.ENOVIFUtil"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.lang.*,matrix.db.*, matrix.util.* ,com.matrixone.servlet.*,java.util.*,com.matrixone.apps.domain.util.*" %>

<%

	String username		= "";
	String enoID 		= request.getParameter("id");
	String mID 		= request.getParameter("mid");
	String enoFormat 	= request.getParameter("format");
	String enoFileName 	= request.getParameter("filename");
	String jVueServer	= request.getParameter("jVueServer");

	String sMeetingID	= request.getParameter("CSI_ClbSessionID");
	System.out.println("[C3D:Join RTC]: Meeting ID: " + sMeetingID);

	String sCollabUsers = "";

	String localeLanguage = "en";

	if(enoFileName == null || enoFileName.length() == 0)
	{		
		 enoFileName 	= request.getParameter("fileName");
	}

	matrix.db.Context context = Framework.getFrameContext(session);
	username				  = context.getUser();
	localeLanguage			  = context.getLocale().getLanguage();
	request.getSession().setAttribute("markupId",mID);

	String jVueServerURL = null;
	String assetID		  = request.getParameter("aID");
	String workflowID	  = request.getParameter("wID");
	String acceptLanguage = request.getHeader("Accept-Language");
	
	request.getSession().setAttribute("Accept-Language",acceptLanguage);
	
//[IR-334572]:START	
	//Old code commented below & moved to function in java file.
	//String scheme		 = request.getScheme();    
	//String serverName	 = request.getServerName();   
	//int serverPort		 = request.getServerPort();  
	//String contextPath	 = request.getContextPath();	
	//String path = scheme+"://"+serverName+":"+serverPort+contextPath; 
	//String path =request.getRequestURL().substring(0,request.getRequestURL().indexOf(request.getServletPath()));
	
	String path = ENOVIFUtil.GetURLUpToContextPathFrmRequest(request);	
	System.out.println("*****URL upto context path: " + path);
	String c3dservlet = path + "/servlet/C3DControllerServlet";
	System.out.println("*****c3dservlet: " + c3dservlet);	
//[IR-334572]:END
	
	InetAddress ia = InetAddress.getLocalHost();
	String host = ia.getHostName();	
	if(jVueServerURL == null || jVueServerURL.isEmpty())	//[xlv]: simplified condition.
	{
		jVueServerURL = path;
	}

	if(jVueServerURL.endsWith("/"))
	{ 
		jVueServerURL = jVueServerURL.substring(0, jVueServerURL.length() -1);
	}
	
	System.out.println("[C3D:Join RTC]: JVUEServerURL: " + jVueServerURL);

	String remoteVuelink = pageContext.getServletContext().getInitParameter("RemoteVuelink");
		
	if(remoteVuelink != null && remoteVuelink.length() > 0){
		String remoteJvueServer = pageContext.getServletContext().getInitParameter("RemotejVueServer");
		if(remoteJvueServer != null && remoteJvueServer.length() > 0){
			host = remoteJvueServer;
		}
		
		String remoteVueservlet = pageContext.getServletContext().getInitParameter("RemoteVueServlet");
	
		if(remoteVueservlet != null && remoteVueservlet.length() > 0){
			c3dservlet = remoteVueservlet;
	
		}
	}
	
	// >>> embedded option, by default true , (if false Applet will popup in separate window)
	String sEmbedded = request.getParameter("embedded");
	boolean embedded = true;  
	if (sEmbedded != null && sEmbedded.length() > 0 && sEmbedded.equalsIgnoreCase("0")) {
		embedded = false;
	}
	// <<<

	// >>> goback instead of closing window
	String sGoBack = request.getParameter("goBack");
	boolean bGoBack = false;
	if (sGoBack != null && sGoBack.length() > 0 && sGoBack.equalsIgnoreCase("1")) {
		bGoBack = true;
	}

	//RTC
	String clbSession = "CSI_ClbDMS=" + c3dservlet + ";" + "CSI_ClbSessionData=" + sMeetingID + ";" ;
	String guiFile = request.getParameter("guiFile");

	/*
	String DocID = null;
	if((assetID != null && assetID.length() > 0)||(workflowID != null && workflowID.length() > 0)){
		DocID = "oevf://dID=" + docID+ "&aID=" + assetID + "&wID=" + workflowID;
	}
	*/
	String EditMode = request.getParameter("EditMode");
		
	// if aID is given without wID, decide on guiFile of view or edit based on EditMode
	if ( (assetID != null && assetID.length()>0 )
		&& (workflowID == null || workflowID.length()<1) ) { 
		if ("1".equalsIgnoreCase(EditMode)) {  
			guiFile="assetEdit.gui";
		} else {
			guiFile="assetView.gui";
		}
	}	
	/*	
	// we still going to pass EditMode for ReadOnly option in markup list
	if(EditMode != null && EditMode.length() > 0){
		DocID +="&EditMode=" + EditMode; 
	}
	*/
	sMeetingID = ESAPI.encoder().encodeForHTML(sMeetingID);
	clbSession = ESAPI.encoder().encodeForHTML(clbSession);
	C3DResourceBundle c3dResBundle = new C3DResourceBundle(context, acceptLanguage);
	String jnlpJoinRTCPage  = c3dResBundle.getString("c3dIntegration.JNLP.C3DJoinRTCAppletFreePage");	

%>

<html>

<head>
  <title>Join Real-Time Collaboration</title>

<script type="text/javascript" src="../integrations/c3d/scripts/autovue.js"></script>
<script>
<!-- //Hide script from old browsers

// Client ports to try for communication between browser and AV Client.
var AV_ports = null;
var LOCALE	 = '<%=localeLanguage%>';
var GUIFILE = '<%=guiFile%>';
var JNLP_HOST = '<%=path%>' + "/VueJNLPServlet";
var CODEBASE_HOST = '<%=path%>' + '/WebClient';
var RDV_host = "<%=path%>" + "/VueRDVServlet";
var CLBSESSION	= '<%=clbSession%>';
var session = CLBSESSION;
var SESSIONID = "<%=sMeetingID%>";

// AV Client parameters
var INIT_PARAMS = {};

INIT_PARAMS["JVUESERVER"] = '<%=jVueServerURL%>'+"/VueServlet";
INIT_PARAMS["RDVSERVLET"] = RDV_host;
INIT_PARAMS["DMS"] = "<%=c3dservlet%>";
INIT_PARAMS["USERNAME"] = "<%=username%>";
INIT_PARAMS["CSI_MEETING_ID"] = "<%=sMeetingID%>";
INIT_PARAMS["DMS_PRESERVE_COOKIES"] = "TRUE";
INIT_PARAMS["DMSARGS"] = "USERNAME;DMS_PRESERVE_COOKIES;CSI_MEETING_ID";
INIT_PARAMS["COLLABORATION"] = session;
INIT_PARAMS["LOCALE"] = LOCALE;
 
if (GUIFILE != 'null') {
	  INIT_PARAMS["GUIFILE"] = GUIFILE;
}

// Function to call when AutoVue starts and deploys its scripting API.
var ONINIT = onAvStartup;

// Function and error message to use in case AutoVue fails to start
var ONINITERROR = closePopupDlg;
var ERRORMESSAGE = 'AutoVue Client failed to load.';

/**
 * Called when AutoVue started and scripting service deployed.
 * Ready to run now!
 */
function onAvStartup() {
  closePopupDlg();
  window.status = 'AutoVue started.';
  myAvApp.collaborationJoin('CSI_ClbSessionID='+ SESSIONID +';CSI_ClbSessionType=public;');
  //myAvApp.collaborationJoin(session);
}

window.popupDlg = window.open('', 'popupDlg', 'height=50,width=200,\n\
    resizeable=1,titlebar=0,scrollbars=0,status=0,menubar=0,toolbar=0');

window.msgConnecting =
    '<html><title>Loading AutoVue<' + '/title>' +
    '<body bgcolor="#cccccc" style="padding:0;margin:0;"><center><br/>\n\
     <span style="font-family:Arial,Helvetica,sans-serif;font-size:10pt;">\n\
     Connecting to server...</span><' + '/center><' + '/body><' + '/html>';

/* Open the popup window */
function openPopupDlg() {
  if (window.popupDlg != null) {
    window.popupDlg.document.open();
    window.popupDlg.document.write(window.msgConnecting);
    window.popupDlg.document.close();
    window.status = 'Connecting to server...';
    setTimeout('closePopupDlg()', 50000);
  }
}

/* Close the popup window */
function closePopupDlg() {
  if (window.popupDlg != null && !window.popupDlg.closed) {
    window.popupDlg.close();
  }
  window.status = '';
}

var myAvApp = new AutoVue(JNLP_HOST, CODEBASE_HOST, AV_ports, INIT_PARAMS, false);	

/*** Display Helper Functions ***/

/* The function to call on body loading */
function onBodyLoad() {
  openPopupDlg();
  myAvApp.start(ONINIT, ONINITERROR);
}

/* The function to call before unloading */
function onBeforeBodyUnload() {
  myAvApp.closeAutoVue();
}


//JWR: End of new stuff...

/*
** Sets a file (URL) in the Applet
*/
function setFile(fileURL)
{
    if (myAvApp != null) {
        myAvApp.setFile(fileURL);
    }
}

function validatePopups()
{
    var tinyWindow = null;
    try {
        tinyWindow = window.open("popup.html", "PopupTest", "width=10, height=10, left=2000, top=2000 ");
    }
    catch (e) {
        return false;
    }

    window.focus();
    if ( tinyWindow ) {
        try {
            tinyWindow.close();
        }
        catch (e){;}
        return true;
    }
    return false;
}

//-->
</script>
</head>

<body bgcolor="#f8f8f8" text="#005685" onload="onBodyLoad();" onBeforeUnLoad="onBeforeBodyUnload();" onUnload="closePopupDlg();">
<p><%=jnlpJoinRTCPage %></p>
</body>
</html>


