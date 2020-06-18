<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser
--%>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    // A structure browser (SB) expects to receive an XML string when 
    // commands on a SB page are completed.  This XML string contains 
    // an action such as "add", "refresh", "remove", etc. that tells 
    // the SB to add, refresh, remove, etc. rows in it.  This string
    // also contains the data that is added or a message string in case
    // of an error.
    //
    // This JSP supports the old way of sending this XML string back to 
    // the SB which is to load a JSP file containing the XML string
    // into the listHidden frame.  The SB gets notified when the 
    // listHidden frame onload event gets fired.
    //
    // This JSP works by being called recursively.  The first call to
    // this JSP retrieves the action and corresponding data from the
    // URL params and creates the XML string.  This JSP then loads
    // itself into the listHidden frame by calling "performDataAction".
    // This causes the JSP to be called a second time which is when 
    // the XML string is actually loaded into the listHidden frame.
    
    String sXML = emxGetParameter(request,"xml");
	matrix.db.Context context2 = 
    (matrix.db.Context)request.getAttribute("context");
	if (context2 != null)
	    context = context2;
    // No XML was passed in, this must be the first time.
    // Generate the XML and call this JSP a second time
    if ( sXML == null || sXML.length() == 0 )
    {
        String action       = emxGetParameter(request,"action");
        String message      = emxGetParameter(request,"message");
        String data         = emxGetParameter(request,"data");
        String closeWin     = emxGetParameter(request,"closeWindow");
        String refreshFrame = emxGetParameter(request,"refreshFrame");
        String currentWindowOp = emxGetParameter(request,"currentWindowOp");
        
        if ( action.indexOf(":") > -1 )
        {
            refreshFrame = action.replaceFirst(".*?:", "");
            action = action.replaceFirst(":.*", "");
        }
        
        if ( refreshFrame == null || refreshFrame.length() == 0 )
            refreshFrame = "detailsDisplay";
        
        if ( ! "false".equalsIgnoreCase(closeWin) ) closeWin = "true";
        
        // if the refresh call is "refreshBothFrames"
        // do an explicit refresh of both frames.
        // some how the code below to find firefox user
        // screws up some verions of IE
        //String user =request.getHeader("User-Agent");
        if("refreshBothFrames".equals(action))
        {
            action = "refresh";
%>
<script language="javascript">
         var frameDetails = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
         frameDetails.location.href = frameDetails.location.href;
</script>                  
<%            
        }

        
        //
        // This code is invoked from emxCommonDocumentCheckinProcess.jsp,
        // via the appProcessPage parameter. CheckinProcess, before
        // calling the appProcessPage, will catch an error exception
        // and put the exception message in the "error.message" 
        // session variable. Then it will call the appProcessPage
        // as if no error occurred.
        // So, look for the "error.session" error.
        //
        String errmessage = (String)session.getValue("error.message");
        if (errmessage != null && errmessage.length() > 0)
        {
            action = "error";
            message = MessageServices.massageMessage(errmessage);
            session.removeValue("error.message");
            
            // It appears that the current handling of this error
            // message does not like # symbols. So remove them.
            // -- in frame.performDataAction(), this message is passed
            // -- as a url parameter (...?<message>), and as such
            // -- the # is not handled correctly.
            message = message.replace("#", "");
        }

        //Instaed of forming xml response in first hit of jsp we formed it in 2nd hit(since we are facing issue with decoding of %3E i.e. encoded form of >)
           sXML= action+"~"+message+"~"+data;
          
        // The sXML gets passed as a URL parameter, so encode it. 
            sXML=XSSUtil.encodeForURL(context,sXML);
            
           
           if (message != null){
               message = message.replace("\n", "\\n");
               message = message.replace("\"", "\\\"");
   		}

        // Call performDataAction to load this URL into the listHidden
        // frame (which calls this JSP again)
%>
        <script language="javascript">
        
        var refreshFrame = "<%=refreshFrame %>";
        var currentWindowOp = "<%=currentWindowOp %>";

        var frame = null;
            
        if ( getTopWindow().getWindowOpener() )
        {
            if(currentWindowOp == null || currentWindowOp != 'true' ){
            frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),refreshFrame);
            }else{
            	frame = findFrame(getTopWindow(),refreshFrame);                
            }
        }
        else
            frame = findFrame(getTopWindow(),refreshFrame);

        if ( frame != null )
        {
            var URL="../simulationcentral/smaStructureBrowserUtil.jsp" +
                    "?xml=<%= sXML %>";

            // Load the URL into the listHidden frame for processing 
            // The URL calls this same jsp (yes the one you're in now)
            // but with parameters that make it go to the code below.
            if ( frame.performDataAction )
            {
                frame.performDataAction(URL);
            }
            else
            {
                var msg = "<%=message %>";
                if ( msg != null && msg != "null" )
                    alert(msg);
            }

            var contentFrame = findFrame(getTopWindow(), 'smaHomeTOCContent');

            if (contentFrame != null)
            {
                contentFrame.turnOffProgress();
            }

            // Close popup window if not already closed
<%
            if ( "true".equalsIgnoreCase(closeWin) )
            {
%>
                if ( getTopWindow().getWindowOpener() )
                    getTopWindow().closeWindow(); 
<%
            } 
%>
        }
                
        </script>
<%
    }

    // XML data passed in, load it into the frame
    else
    {   
    	// Create the XML response string
        String[] sXML_array = sXML.split("~");
        sXML = StructureBrowserUtil.setXMLStructureBrowserResponse(
                context, sXML_array[0],sXML_array[1],sXML_array[2]);
        out.clear();
        response.setContentType("text/xml; charset=UTF-8");
%>
        <%= sXML %>
<%
    }
%>

