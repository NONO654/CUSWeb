<%-- 
   C3DJoinRTCApplet.jsp
   
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
%>

<html>

<head>
  <title>AutoVue Web Edition</title>

<script>

<!-- //Hide script from old browsers

/*
**  The javascript code listed here is optional.
**  It is only used to:
**   - connect the the applet frame with the file listing frame
**     in our demonstration HTML page.
**   - display a "please wait" window while the applet is loading.
*/


/*
** Called when the Applet has initalized. Ready to run now!
** Close the popup window.
*/

// ID of the document to open
var GUIFILE = '<%=guiFile%>';
var EMBEDDED = '<%=embedded%>';
var USERNAME = '<%=username%>';
var LOCALE	 = '<%=localeLanguage%>';

function onAppletInit()
{
 	window.jVueLoaded = true;
 	window.status = 'Applet Loaded.';
//	alert("Inside onAppletInit function.");
}


function validatePopups()
{
	//alert("Inside validatePopups function.");
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
} // end validatePopups()

// -->
</script>
</head>

<body >

<script language="JavaScript">
<!-- //hide script from old browsers
    
	
    var JVUESERVER	= '<%=jVueServerURL%>'+"/VueServlet";  //socket is not recommended	
  	var DMS			= '<%=c3dservlet%>';
    var CODEBASE	= '.';
	var CLBSESSION	= '<%=clbSession%>';
	var MEETINGID	= '<%=sMeetingID%>' ;

    var jvapp = '<HTML><HEAD><TITLE>Powered by AutoVue</TITLE>' +
         '<META http-equiv="Content-Type" content="text/html; charset=UTF-8">' +

         '\n<Script' +' language="JavaScript">' +
   			'\n <!-' + '- hide script from old browsers' +
   			'\n    function SaveMarkups() { ' +
   			'\n     window.document.applets["JVue"].saveModifiedMarkups(); ' +
   			'\n     window.document.applets["JVue"].waitForLastMethod(); ' +
   			'\n    }' +
   			'\n //-' + '-> ' +
   			'\n function onAppletInit() { window.jVueLoaded = true; }'+
   			'\n</Script' + '>\n</HEAD>'+
         
      	 '<BODY marginheight="3" marginwidth="3" leftmargin="0" topmargin="0" scroll="no"  onBeforeUnLoad="SaveMarkups();">\n' +
         '\n<APPLET NAME="JVue" CODE="com.cimmetry.jvue.JVue.class"' +
         ' ARCHIVE="../WebClient/jvue.jar,../WebClient/jogl.jar,../WebClient/gluegen-rt.jar"' +
         ' CODEBASE="' + CODEBASE + '"' + 
         ' HSPACE="0" VSPACE="0" WIDTH=100% HEIGHT=100% MAYSCRIPT>' +
         '\n<PARAM NAME="EMBEDDED" VALUE="TRUE">' +
         '\n<PARAM NAME="HEAVYWEIGHT" VALUE="FALSE">' +
         '\n<PARAM NAME="VERBOSE" VALUE="DEBUG">'+
		 '\n<PARAM NAME="LOCALE"     VALUE="'+LOCALE+'">';

		 if (GUIFILE != 'null') {
	          jvapp += "\n<PARAM NAME=\"GUIFILE\" VALUE=\"" + GUIFILE + "\">";
         } 
	 // example of Task Oriented UI added in AV 20 , it is not supported officially and it is not compatible with OEVF .
	 //jvapp += "\n<PARAM NAME=\"GUIFILE\" VALUE=\"com/cimmetry/vueframe/resources/tasks.gui\">"; 

         jvapp +=
             //<!-- Optional: To call a Javascript function after the applet has initialized -->
             '\n<PARAM NAME="ONINIT"       VALUE="onAppletInit();">' +
             '\n<PARAM NAME="JVUESERVER" VALUE="'+ JVUESERVER + '">' +
             '\n<PARAM NAME="DMS"     VALUE="' + DMS + '">' +
             '\n<PARAM NAME="DMSARGS" VALUE="USERNAME;DMS_PRESERVE_COOKIES;CSI_MEETING_ID">'+
             '\n<PARAM NAME="DMS_PRESERVE_COOKIES" VALUE="TRUE">'+
			 '\n<PARAM NAME="CSI_MEETING_ID" VALUE="' + MEETINGID + '">' +
			 '\n<PARAM NAME="COLLABORATION" VALUE="JOIN:' + CLBSESSION + '">' +
             '\n</APPLET></BODY></HTML>';
         
    
    // If doean't provide the docID in URL or embedded mode
    if (EMBEDDED == 'true' ) {
        CreateApplet();
    } else {
    	if ( validatePopups() == true) {
       		CreateReusableApplet();
    	}
    	else {
        	alert("Please disable your pop-up blocker to allow launching AutoVue.");
    	}
    }
    

    // Function CreateApplet() - Creates the HTML code for the Applet
    function CreateApplet()
    {
        var appletWnd = self;
        var doc = appletWnd.document;

        doc.writeln(jvapp);
        doc.close();
    }

    
    function dummy() {}

    
    function CreateReusableApplet()
    {
		//alert("Inside CreateReusableApplet function.");
        var appletWnd = self;
        if (EMBEDDED != 'true') {  // not embedded  (using username as applet window name)
	 	appletWnd = window.open("", USERNAME, 'resizable=1,width=770,height=630,location=0,toolbar=0,menubar=0,status=0,left=400,top=150');
        }
	 	
        if (appletWnd != null) {
            appletWnd.focus();
            var doc = appletWnd.document;

            //because DMSArgs need to be updated we can't reuse the applet object 
            var japplet = doc.applets["JVue"];

            if (japplet != null)
			{
				/*
	    		if (GUIFILE != 'null') {
	    			japplet.setGUI(GUIFILE);
	    		}else {
	    			japplet.setGUI("default.gui");
	    		}				
            	*/
				japplet.setValue("CSI_MEETING_ID", MEETINGID);
	            japplet.collaborationJoin(CLBSESSION);

            } else {
                // Fix for Java Plugin on IE only
                if (doc.readyState != null) {
                    // alert('Document not ready '+ doc.readyState);
                    var i = 0;
                    while ( i < 100 && doc.readyState != "complete" ) {
                        appletWnd.setTimeout('dummy()', 1000);
                        i++;
                    }
                }
        			                      
                if(!appletWnd.closed) {
                  doc.open();
                  doc.writeln(jvapp);
                  doc.close();
                }
            }
        	appletWnd.focus();
        }
        if ((EMBEDDED != 'true') && (<%=bGoBack%>)) {
		    	history.back();
	    }
    }

// end script hiding from old browsers -->
</script>

</body>
</html>


