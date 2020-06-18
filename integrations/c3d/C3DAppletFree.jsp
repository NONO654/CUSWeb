<%-- C3DAppletFree.jsp

   Copyright Dassault Systemes, 1992-2011. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page errorPage="error.jsp" %>

<%@ page import="com.ds.enovia.c3d.controller.C3DResourceBundle"%>
<%@ page import="com.ds.enovia.vif.util.ENOVIFUtil"%>
<%@ page import="com.ds.enovia.vif.util.ENOVIFStringUtil"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.lang.*,matrix.db.*, matrix.util.* ,com.matrixone.servlet.*,java.util.*,com.matrixone.apps.domain.util.*" %>

<%


	String username		= "Test Everything";
	String enoID 		= request.getParameter("id");
	String mID 		= request.getParameter("mid");
	String enoFormat 	= request.getParameter("format");
	String enoFileName 	= request.getParameter("filename");
	String jVueServer	= request.getParameter("jVueServer");
	String localeLanguage = "en";

	if(enoFileName == null || enoFileName.length() == 0)
	{		
		 enoFileName 	= request.getParameter("fileName");
	}
	matrix.db.Context context = Framework.getFrameContext(session);
	username				  = context.getUser();
	localeLanguage			  = context.getLocale().getLanguage();
	request.getSession().setAttribute("markupId",mID);
//[xlv:15Jan15]:START
	String docID =  null; //enoID + "~" + enoFormat + "~" + enoFileName;
	if(mID != null && !mID.isEmpty())
	{		
		try
		{
			docID = (String)ENOVIFUtil.getDocumentIdFromMarkupId(context,mID);
			//Parse obtained doc id here.
			java.util.List <String> docIdTokens = ENOVIFStringUtil.parseDocIdString(docID);
			if(docIdTokens !=null && !docIdTokens.isEmpty() && docIdTokens.size()==3)
			{
				enoID =  (String) docIdTokens.get(0);
				enoFormat = (String) docIdTokens.get(1);
				enoFileName = (String) docIdTokens.get(2);
			}
		}
		catch(Exception exp)
		{
			System.out.println("[C3DApplet.jsp] Exception occured: " + exp.getMessage());
		}
	}
	else
	{
		docID 		= enoID + "~" + enoFormat + "~" + enoFileName;
	}
	//No need of tokenizing docID unnecessary when mid is null.
	/*StringTokenizer st = new StringTokenizer(docID, "~");
	if(st.hasMoreTokens())
	{
		enoID = st.nextToken();
		if(st.hasMoreTokens())
		 {
		    enoFormat = st.nextToken();
  		    if(st.hasMoreTokens())
				enoFileName = st.nextToken();
		  }
	}*/
//[xlv:15Jan15]:END	
	String jVueServerURL = ENOVIFUtil.getJVueServer(context, request, enoID, enoFormat, enoFileName);
	String assetID		  = request.getParameter("aID");
	String workflowID	  = request.getParameter("wID");
	String acceptLanguage = request.getHeader("Accept-Language");

	System.out.println("jVueServerURL: "+jVueServerURL);
	
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
	
	String remoteVuelink = pageContext.getServletContext().getInitParameter("RemoteVuelink");
		
	if(remoteVuelink != null && remoteVuelink.length() > 0)
	{
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
	

	if (docID != null && docID.equalsIgnoreCase("debug")) {  //debug info
		
		out.println("<BR>dID: " + docID);
		out.println("<BR>Asset ID: " +  assetID);
		out.println("<BR>Workflow ID: "+ workflowID);
		out.println("<BR>Embeded: "+ embedded);
		out.println("<BR>Remote JVue Server: "+ host);
		out.println("<BR>Remote Content Server VL: "+ remoteVuelink);
		return;	
	}
	
	String guiFile = request.getParameter("guiFile");

	String DocID = null;
	if((assetID != null && assetID.length() > 0)||(workflowID != null && workflowID.length() > 0)){
		DocID = "oevf://dID=" + docID+ "&aID=" + assetID + "&wID=" + workflowID;
	}
	
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
		
	// we still going to pass EditMode for ReadOnly option in markup list
	if(EditMode != null && EditMode.length() > 0){
		DocID +="&EditMode=" + EditMode; 
	}
	
	C3DResourceBundle c3dResBundle = new C3DResourceBundle(context, acceptLanguage);
	String jnlpStartPage  = c3dResBundle.getString("c3dIntegration.JNLP.StartPage");	
%>

<html>

<head>
  <title>AutoVue Web Edition</title>

<script type="text/javascript" src="../integrations/c3d/scripts/autovue.js"></script>
<script>
<!-- //hide script from old browsers
    // ID of the document to open
	var DOCUMENT_ID = '<%=docID%>';
	var GUIFILE = '<%=guiFile%>';
		
	var USERNAME = '<%=username%>';
	var LOCALE	 = '<%=localeLanguage%>';
/*
** Sets a file (URL) in the AutoVue
*/
function setFile(fileURL)
{
    if (myAvApp != null) {
        myAvApp.setFile(fileURL);
    }
}
	var CODEBASE_HOST = '<%=path%>' + '/WebClient';
  	
	var JNLP_HOST = '<%=path%>' + "/VueJNLPServlet";

	var AV_ports = null;
	var VERBOSE='debug';
	var RDV_host = "<%=path%>" + "/VueRDVServlet";

	var INIT_PARAMS = {};
	INIT_PARAMS["JVUESERVER"] = '<%=jVueServerURL%>'+"/VueServlet";
	INIT_PARAMS["RDVSERVLET"] = RDV_host;
	INIT_PARAMS["USERNAME"] = "<%=username%>";
	INIT_PARAMS["DMS"] = "<%=c3dservlet%>";
	INIT_PARAMS["DMSARGS"] = "DMS_PRESERVE_COOKIES";
	INIT_PARAMS["DMS_PRESERVE_COOKIES"] = "TRUE";
	INIT_PARAMS["LOCALE"] = LOCALE;

	if (DOCUMENT_ID != 'null') {
	  INIT_PARAMS["FILENAME"] = DOCUMENT_ID;
	}
	if (GUIFILE != 'null') {
	  INIT_PARAMS["GUIFILE"] = GUIFILE;
	}

// Don't encrypt cookies under https protocol within the Rendez-Vous approach
//var ENCRYPT_COOKIES = RDV_host == null || document.location.protocol === 'http:';

// Function called when AutoVue started and scripting service deployed.
// Ready to run now!
function onAvStartup() {
  closePopupDlg();
  window.status = 'AutoVue started.';
}

// Function to call when AutoVue starts and deploys its scripting API
var ONINIT = onAvStartup;

// Function and error message to use in case AutoVue fails to start
var ONINITERROR = closePopupDlg;
var ERRORMESSAGE = 'AutoVue Client failed to load.';

window.popupDlg = window.open('', 'popupDlg', 'height=50,width=200,\n\
  resizeable=1,titlebar=0,scrollbars=0,status=0,menubar=0,toolbar=0');

window.msgConnecting =
  '<html><title>Loading AutoVue<' + '/title>' +
  '<body bgcolor="#cccccc" style="padding:0;margin:0;"><center><br/>\n\
   <span style="font-family:Arial,Helvetica,sans-serif;font-size:10pt;">\n\
   Connecting to server...</span><' + '/center><' + '/body><' + '/html>';

// Open the popup window
function openPopupDlg() {
  if (window.popupDlg != null) {
    window.popupDlg.document.open();
    window.popupDlg.document.write(window.msgConnecting);
    window.popupDlg.document.close();
    window.status = 'Connecting to server...';
    setTimeout('closePopupDlg()', 50000);
  }
}

// Close the popup window
function closePopupDlg() {
  if (window.popupDlg != null && !window.popupDlg.closed) {
    window.popupDlg.close();
  }
  window.status = '';
}
						  
var myAvApp = new AutoVue(JNLP_HOST, CODEBASE_HOST , AV_ports, INIT_PARAMS, false);	

// The function to call on body loading
function onBodyLoad() {
  openPopupDlg();
  myAvApp.start(ONINIT, ONINITERROR);
}

// The fuction to call before unloading
function onBeforeBodyUnload() {
  myAvApp.closeAutoVue();
}
</script>
</head>
<body bgcolor="#f8f8f8" text="#005685" onload="onBodyLoad();" onBeforeUnLoad="onBeforeBodyUnload();" onUnload="closePopupDlg();">
<p><%=jnlpStartPage %></p>
</body>
</html>


