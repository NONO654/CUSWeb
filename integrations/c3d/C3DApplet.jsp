<%-- C3DApplet.jsp

   Copyright Dassault Systemes, 1992-2011. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page errorPage="error.jsp" %>

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
var DOCUMENT_ID = '<%=docID%>';
var GUIFILE = '<%=guiFile%>';
var EMBEDDED = '<%=embedded%>';
var USERNAME = '<%=username%>';
var LOCALE	 = '<%=localeLanguage%>';

function onAppletInit()
{
 	window.jVueLoaded = true;
 	window.status = 'Applet Loaded.';
}

/*
** Sets a file (URL) in the Applet
*/
function setFile(fileURL)
{

    var appletWnd = self;   // embedded
 	if (EMBEDDED != 'true') {  // not embedded
 		appletWnd = window.open("", USERNAME,"");
 	}
	if (appletWnd.jVueLoaded) {
		// Load file on a seperate thread.
		appletWnd.document.applets["JVue"].setFileThreaded(fileURL);
		appletWnd.focus();
	} else {
		if(EMBEDDED == 'true'){
			alert('Please wait for the Applet to finish loading.');
		}else{
			var doc = appletWnd.document;
			var japplet = doc.applets["JVue"];
				
			if(japplet == null){
				appletWnd.close();
				alert("Please reload the page and don't close the applet");
			}else{
				alert('Please wait for the Applet to finish loading.');
			}
	
		}
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
} // end validatePopups()

// -->
</script>
</head>

<body >

<script language="JavaScript">
<!-- //hide script from old browsers
    
	
    var JVUESERVER = '<%=jVueServerURL%>'+"/VueServlet";  //socket is not recommended	
  	var DMS = '<%=c3dservlet%>';
    var CODEBASE  = '.';

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

         if (DOCUMENT_ID != 'null') {
             jvapp +=  '\n<PARAM NAME="FILENAME" VALUE="' + DOCUMENT_ID + '">';
 		 }      

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
             '\n<PARAM NAME="DMSARGS" VALUE="USERNAME;DMS_PRESERVE_COOKIES;">'+
             '\n<PARAM NAME="DMS_PRESERVE_COOKIES" VALUE="TRUE">'+
             '\n</APPLET></BODY></HTML>';
         
    
    // If doean't provide the docID in URL or embedded mode
    if (EMBEDDED == 'true' ) {
        CreateApplet();
    } else {
    	if ( validatePopups() == true) {
			//[xlv:29/05/2013] Commented below call. Reusing applet causing issue in case of 
			//meeting support. If user joins meeting and then views some other design separately 
			//then AV applet in RTC is getting opened!
       		//CreateReusableApplet();
			CreateApplet();
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
        var appletWnd = self;
        if (EMBEDDED != 'true') {  // not embedded  (using username as applet window name)
	 	appletWnd = window.open("", USERNAME, 'resizable=1,width=770,height=630,location=0,toolbar=0,menubar=0,status=0,left=400,top=150');
        }
	 	
        if (appletWnd != null) {
            appletWnd.focus();
            var doc = appletWnd.document;

            //because DMSArgs need to be updated we can't reuse the applet object 
            var japplet = doc.applets["JVue"];

            if (japplet != null) {
	    		
	    		if (GUIFILE != 'null') {
	    			japplet.setGUI(GUIFILE);
	    		}else {
	    			japplet.setGUI("default.gui");
	    		}
	            japplet.setFileThreaded(DOCUMENT_ID);

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


