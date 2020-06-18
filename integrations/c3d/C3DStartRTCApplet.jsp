<%-- 
   C3DStartRTCApplet.jsp
   This JSP file will take care of launching AV Applet in RTC Mode.
   
   Copyright Dassault Systemes, 1992-2013. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   Modifications History:
--------------------------------------------------------------------------------------------------
	Sr. 	Date				By				Description
--------------------------------------------------------------------------------------------------
	0. 		???			XLV		Creation: JSP to launch AV applet in RTC.
	1. 		25 July 2013		XLV		Updated code for format registration check before starting RTC.
	2.		05 Sept 2013		XLV		Updated code to check for document without any files in it.
	3. 		05 Sept 2013		XLV		Updated code to promote Meeting to InProgress only when its about to start in AV Applet.
	4.		11 Sept 2013		XLV		Updated code to close collaboration when user directly closes Applet.
	5.		23 June 2016		MAL3		Checked in Files not getting opened as the file exists in major version and not in the active version.
--------------------------------------------------------------------------------------------------
--%>

<%@ page contentType="text/html; charset=UTF-8" import="java.net.InetAddress,org.owasp.esapi.*"%>
<%@ page errorPage="error.jsp" %>

<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>

<%@page import="com.ds.enovia.c3d.controller.C3DResourceBundle"%>
<%@ page import="com.ds.enovia.cif.intrf.ENOCIFUtil"%>
<%@ page import="com.ds.enovia.vif.util.ENOVIFUtil"%>
<%@ page import="com.ds.enovia.vif.util.ENOVIFStringUtil"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.lang.*,matrix.db.*, matrix.util.* ,com.matrixone.servlet.*,java.util.*,com.matrixone.apps.domain.util.*" %>

<%
	
	String acceptLanguage = request.getHeader("Accept-Language");
	String username		= "Test Everything";
	String enoID 		= request.getParameter("id");
	String mID 			= request.getParameter("mid");
	String enoFormat 	= request.getParameter("format");
	String enoFileName 	= request.getParameter("filename");
	String jVueServer	= request.getParameter("jVueServer");
	
	String sMeetingID	= request.getParameter("CSI_ClbSessionID");

	System.out.println("[C3D:StartRTC]: Meeting ID: " + sMeetingID);
	
	matrix.db.Context context = Framework.getFrameContext(session);
	
	C3DResourceBundle c3dResBundle = new C3DResourceBundle(context, acceptLanguage);

	//New code:
	if(enoID !=null && (enoFormat == null || enoFileName== null))
	{
		System.out.println("[C3D:StartRTC]: Opening Bus ID: " + enoID);
		
		StringList objectSelects = new StringList();
		String SELECT_ACTIVE_VERSION_ID = "from[Active Version].to.id";
		String SELECT_ACTIVE_VERSION_FILENAME = "from[Active Version].to.format.file.name";	//[5]
		String SELECT_ACTIVE_VERSION_FILESIZE = "from[Active Version].to.format.file.size";	//[5]
		
		String attachedFileObjectId = enoID;
		DomainObject meetingFileObject = DomainObject.newInstance(context, attachedFileObjectId);
		objectSelects = new StringList();
		objectSelects.add(CommonDocument.SELECT_MOVE_FILES_TO_VERSION);
		objectSelects.add(SELECT_ACTIVE_VERSION_ID);
		objectSelects.add(SELECT_ACTIVE_VERSION_FILENAME);					//[5]
		objectSelects.add(SELECT_ACTIVE_VERSION_FILESIZE);					//[5]
		Map attrMap = meetingFileObject.getInfo(context, objectSelects);
		
		boolean moveFilesToVersion = Boolean.parseBoolean((String) attrMap.get(CommonDocument.SELECT_MOVE_FILES_TO_VERSION));

		if (moveFilesToVersion)
		{
			System.out.println("[C3D:StartRTC]: Move Files to Version flag is true.");
			System.out.println("[C3D:StartRTC]: AttributeMap: " + attrMap.get(SELECT_ACTIVE_VERSION_ID));
			System.out.println("[C3D:StartRTC]: AttributeMap: " + attrMap.get(SELECT_ACTIVE_VERSION_FILENAME));		//[5]
			System.out.println("[C3D:StartRTC]: AttributeMap: " + attrMap.get(SELECT_ACTIVE_VERSION_FILESIZE));		//[5]
						
			StringList tmpList = (StringList)attrMap.get(SELECT_ACTIVE_VERSION_ID);
			attachedFileObjectId = (String) tmpList.elementAt(0);
			System.out.println("[C3D:StartRTC]: Bus ID of doc to be opened: " + attachedFileObjectId);
			//[5]: START
			String minorFileName  = (String)attrMap.get(SELECT_ACTIVE_VERSION_FILENAME);									
			if(minorFileName != null && !minorFileName.isEmpty())	
				enoID = attachedFileObjectId;
			else
				System.out.println("[C3D:StartRTC]: File Not present in Minor");
			//[5]: END
		}
		else
		{
			System.out.println("[C3D:StartRTC]: Move Files to Version flag is false. Using BusID: " + enoID);
		}

		BusinessObject attachedObject = new BusinessObject(enoID);
		attachedObject.open(context);		
		
		FormatList formats = attachedObject.getFormats(context);
		
		System.out.println("[C3D:StartRTC]: Formatlist size: " + formats.size());
		
		for (int i= 0; i< formats.size(); i++)
		{
			String format = ((matrix.db.Format)formats.get(i)).getName();
			
			//System.out.println("Format: " + format);

			FileList list = attachedObject.getFiles(context,format);
			
			System.out.println("Filelist size: " + list.size());

			for (int j = 0; j < list.size(); j++)
			{
			   matrix.db.File file = (matrix.db.File)list.get(j);
			   enoFormat = format;
			   enoFileName= file.getName();
			   i = formats.size();
			   break;
			}
		}
		attachedObject.close(context);
		System.out.println("[C3D:StartRTC]: Attachment ID: "+ enoID + " FileName: " + enoFileName + " Format: " + enoFormat);
//[2]:START
		//IR-253365V6R2014x: Check if filename or format is null
		if(enoID == null || enoFileName == null || enoFormat == null)
		{
			System.out.println("[C3D:StartRTC]: Either BusID/FileName/Format is/are null. Can not continue...");		
			String nullCheck  = c3dResBundle.getString("c3dIntegration.RTC.NullFileNameOrFormatError");		
	%>
			<script language="JavaScript">
			window.alert("<%=nullCheck%>");
			window.close();
			</script>
	<%
			return;
		}
//[2]:END		
	}
	
//[1]:START
	//Check if file format is registered or not.
	if(false == ENOCIFUtil.isAutoVueRegistered(context, enoFormat))
	{
		System.out.println("[C3D:StartRTC]: This Format is not registered for Viewing with AutoVue: " + enoFormat);		
		String formatError  = c3dResBundle.getString("c3dIntegration.RTC.FormatRegistrationError");		
%>
		<script language="JavaScript">
		window.alert("<%=formatError%>");
		window.close();
		</script>
<%			
		return;
	}
//[1]:END

	String localeLanguage = "en";

	if(enoFileName == null || enoFileName.length() == 0)
	{		
		 enoFileName 	= request.getParameter("fileName");
	}

	username				  = context.getUser();
	localeLanguage			  = context.getLocale().getLanguage();

	// Get meeting attendees...

	String sMeetingTitle = ENOVIFUtil.getMeetingAttribValueFrmMeetingID(context, sMeetingID, "Title");

	String sCollabUsers	= "";
	StringList sCollabUsersArray = ENOVIFUtil.getMeetingAttendeesFromMeetingID(context, sMeetingID);

	if(sCollabUsersArray != null && !sCollabUsersArray.isEmpty())
	{
		for (int i = 0 ; i < sCollabUsersArray.size(); i++)
		{
			sCollabUsers  += (String) sCollabUsersArray.get(i) + ",";
		}

		if(sCollabUsers.endsWith(","))
			sCollabUsers = sCollabUsers.substring(0, sCollabUsers.lastIndexOf(','));

		System.out.println("[C3D:StartRTC]: Meeting Attendees: " + sCollabUsers);
	}

	String docID = null;
	String jVueServerURL = null;

	if( ((enoID == null || enoID.isEmpty()) || (enoFormat == null || enoFormat.isEmpty()) || (enoFileName == null || enoFileName.isEmpty())) && (mID == null || mID.isEmpty()) )
	{
		docID = null;
	}
	else
	{
//[xlv:15Jan15]:START
		//Commented line below and moved to else.
		//docID 		= enoID + "~" + enoFormat + "~" + enoFileName;
		if(mID != null && !mID.isEmpty())
		{		
			try
			{
				request.getSession().setAttribute("markupId",mID);
				docID = (String)ENOVIFUtil.getDocumentIdFromMarkupId(context,mID);
				//Parse obtained doc id here
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
				System.out.println("[C3DStartRTCApplet.jsp] Exception occured: " + exp.getMessage());
			}
		}
		else
		{
			docID 	= enoID + "~" + enoFormat + "~" + enoFileName;
		}

		/*
		//no need to tokenize docId when Mid is null bcoz we already have it separated in id, format and filename.	
		StringTokenizer st = new StringTokenizer(docID, "~");
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
		jVueServerURL = ENOVIFUtil.getJVueServer(context, request, enoID, enoFormat, enoFileName);
		System.out.println("[C3D:StartRTC]: JVUEServerURL: "+jVueServerURL);
	}

	String assetID		  = request.getParameter("aID");
	String workflowID	  = request.getParameter("wID");
	
	request.getSession().setAttribute("Accept-Language", acceptLanguage);
	
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
	

	if (docID != null && docID.equalsIgnoreCase("debug")) {  //debug info
		
		out.println("<BR>dID: " + docID);
		out.println("<BR>Asset ID: " +  assetID);
		out.println("<BR>Workflow ID: "+ workflowID);
		out.println("<BR>Embeded: "+ embedded);
		out.println("<BR>Remote JVue Server: "+ host);
		out.println("<BR>Remote Content Server VL: "+ remoteVuelink);
		return;	
	}
	
	//Create parameters for RTC.
	String clbSession = "CSI_ClbDMS=" + c3dservlet + ";" +
	"CSI_ClbSessionData=" + sMeetingID + ";" +
	"CSI_ClbSessionSubject=" + sMeetingTitle + ";" +
	"CSI_ClbSessionType=public;" +
	"CSI_ClbUsers=" + sCollabUsers + ";";

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

	//Encode parameters.
	sMeetingID = ESAPI.encoder().encodeForHTML(sMeetingID);
	clbSession = ESAPI.encoder().encodeForHTML(clbSession);
//[3]:START
	//IR-253689V6R2014x: Now finally change Meeting Status to InProgress.
	ENOVIFUtil.VerifyStateAndPromote(context, sMeetingID, "state_Scheduled");	
//[3]:END

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
		alert('Please wait for the Applet to finish loading.');
		/*if(EMBEDDED == 'true'){
			alert('Please wait for the Applet to finish loading.');
		}else{
			var doc = appletWnd.document;
			var japplet = doc.applets["JVue"];
				
			if(japplet == null)
			{
				appletWnd.close();
				alert("Please reload the page and don't close the applet");
			}
			else
			{
				alert('Please wait for the Applet to finish loading.');
			}
	
		}*/
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
 	
    var JVUESERVER	= '<%=jVueServerURL%>'+'/VueServlet';  //socket is not recommended	
  	var DMS			= '<%=c3dservlet%>';
    var CODEBASE	= '.';
	var CLBSESSION	= '<%=clbSession%>';
	var MEETINGID	= '<%=sMeetingID%>' ;

    var jvapp = '<HTML><HEAD><TITLE>Powered by AutoVue</TITLE>' +
         '<META http-equiv="Content-Type" content="text/html; charset=UTF-8">' +

         '\n<Script' +' language="JavaScript">' +
   			'\n <!-' + '- hide script from old browsers' +
   			'\n    function closeCollaboration() { ' +			
			'\n 	if(window.document.applets["JVue"].getActiveVueBean().getCollaborationBean().isInSession()) {' + 
			'\n     window.document.applets["JVue"].collaborationEnd(); }' +
			'\n     else { window.document.applets["JVue"].saveModifiedMarkups(); }' +
   			'\n     window.document.applets["JVue"].waitForLastMethod(); ' +
   			'\n    }' +
   			'\n //-' + '-> ' +
   			'\n function onAppletInit() { window.jVueLoaded = true; }'+
   			'\n</Script' + '>\n</HEAD>'+
         
      	 '<BODY marginheight="3" marginwidth="3" leftmargin="0" topmargin="0" scroll="no"  onBeforeUnLoad="closeCollaboration();">\n' +
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
		
		 jvapp +=  '\n<PARAM NAME="COLLABORATION" VALUE="INIT:' + CLBSESSION + '">';
		 jvapp +=  '\n<PARAM NAME="CSI_MEETING_ID" VALUE="' + MEETINGID + '">';
 		    
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
             '\n</APPLET></BODY></HTML>';
         
    
    // If doesn't provide the docID in URL or embedded mode
    if (EMBEDDED == 'true' ) {
        CreateApplet();
    } else {
    	if ( validatePopups() == true) {
       		CreateReusableApplet();
    	}
    	else {
        	window.alert("Please disable your pop-up blocker to allow launching AutoVue.");
    	}
    }
    

    // Function CreateApplet() - Creates the HTML code for the Applet
    function CreateApplet()
    {
        var appletWnd = self;
        var doc = appletWnd.document;

        doc.writeln(jvapp);
        doc.close();
	//window.alert("Inside CreateApplet function.");
    }

    
    function dummy() {}

    
    function CreateReusableApplet()
    {
    	//window.alert("Inside CreateReusableApplet function.");
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
				//japplet.setFileThreaded(DOCUMENT_ID);

				japplet.setFileThreaded(DOCUMENT_ID);
            	japplet.setValue("CSI_MEETING_ID", MEETINGID);
	            japplet.collaborationInit(CLBSESSION);
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


