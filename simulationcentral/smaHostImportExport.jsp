<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  smaHostImportExport.jsp- get the host import choices and pass them
  To the applet. The applet will post a file chooser if the user wishes
  to pick the config file and then create a controller to parse the
  config file and use web service to register the hosts from the file.
  
--%>



<%@page import="com.dassault_systemes.smaslm.common.util.XMLUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringValidator"%>
<%@page import="com.dassault_systemes.smaslm.common.util.XmlValidator"%>
<%@page import="com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>

<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@page import="matrix.db.Context" %>
<%@page import="matrix.util.MatrixException"%>
<%@page import = "matrix.util.StringResource"%>
<%@page import = "com.matrixone.jdom.Document"%>
<%@page import = "com.matrixone.jdom.input.SAXBuilder"%>
<%@page import = "javax.xml.transform.stream.StreamSource"%>

<%@page import = "com.matrixone.jdom.output.XMLOutputter"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="JavaScript">


<!--
// This will resize the window when it is opened or
// refresh/reload is clicked to a width and height of 450 x 200
window.resizeTo(450,200)
window.moveTo(-5000,-5000)
-->
</script>

<%
    String objectAction = emxGetParameter(request, "objectAction");
    String ErrorStr =  "";

    // applet parameters
    String objId = emxGetParameter(request, "objectId");
    String rowId = emxGetParameter(request, "emxTableRowId");
    String hostName = "localhost";
    String userName = StringValidator.validate(context.getUser());
    String userPass = StringValidator.validate(context.getPassword());

    // since we are running locally, startCommand used to pass 
    // labels for the file chooser on host import
    String startCommand ="";
    
    // additional applet parameters for import
    String overwrite = "no";
    String useDefaultConfig = "no";
    String title = "";
    String btnLabel = "";
    String tooltip = "";
    String confirmMsg = "";
    String confirmTitle = "";

    String locale = context.getSession().getLanguage();
    if ("hostImport".equals(objectAction))
    {
        String overwriteDup =
    emxGetParameter(request,"overwriteDuplicates");
        String fileLoc =
    emxGetParameter(request,"fileLoc");
        
        if ("overwriteDuplicates".equalsIgnoreCase(overwriteDup))
    overwrite = "yes";
        if ("defaultLoc".equalsIgnoreCase(fileLoc))
        {
    try
    {
        // need to parse the file in the jsp since the jsp is
        // run on the server where the default file is located
        String refreshFrame = 
            emxGetParameter(request, "refreshFrame");
        if (refreshFrame == null)
            refreshFrame = "smaHomeTOCContent";
        // get config file from default location and parse 
        InputStream inStream =
            getServletConfig().getServletContext().getResourceAsStream(
            "/simulationcentral/config/hostConfigInfo.xml");
        if (inStream == null)
        {
            String errMsg = "";
            String lang = request.getHeader("Accept-Language");
            errMsg = SimulationUtil.getI18NString(context,
                    "smaSimulation.RegisterHost.ConfigNotFound");
            throw new Exception(errMsg);
        }
        
        InputStream inStreamXsd =
            getServletConfig().getServletContext().getResourceAsStream(
            "/simulationcentral/config/hostConfigInfo.xsd");
        javax.xml.transform.stream.StreamSource streamSource =
            new javax.xml.transform.stream.StreamSource(
                inStreamXsd);
        boolean validation = false;
        String result = "";
        try
        {
	                validation = 
	                    XmlValidator.validate(inStream, streamSource);
        }
        catch (Exception ex ) 
        {                    
            validation = false; 
            result = ex.getMessage();       
        } 


        if (validation)
        {
            InputStream inStream2 =
                getServletConfig().getServletContext().getResourceAsStream(
                "/simulationcentral/config/hostConfigInfo.xml");
	                SAXBuilder xmlBuilder = XMLUtil.createInstanceOfSecuredSaxBuilder();//wu4-XXE Security Vulnerability
	                Document  xmlDoc= xmlBuilder.build(inStream2 );
	                XMLOutputter xmlOutputter = new XMLOutputter();
	                String xmlOutput = xmlOutputter.outputString(xmlDoc);
	
	                HashMap paramMap = new HashMap();
	                paramMap.put("configFile",xmlOutput);
	                paramMap.put("parentID",objId);
	                paramMap.put("overWrite",overwrite);
	
	                // invoke the host jpo register method
	                String[] methodargs = JPO.packArgs(paramMap);
	                result = (String)JPO.invoke(
	                    context,"jpo.simulation.SimulationHost",
	                    null,"register",
	                    methodargs, String.class);
        }
        
        // host import returns a string that can be split by 
        // "::::" it will return new host relation info and 
        // possibly modified host info for removing hosts from 
        // old folders the new and modified string are separated 
        // by "!!!!" each host in the new or modified info is 
        // separated by "::::" for each host it contains the 
        // host id "|" host-folder relation id if the "::::" 
        // separator is not found then this is an error message
        // that should be displayed
        if (result.length() == 0 )
        {
            // there were no errors and no new relations
            // just close the window and return
%>
<script language = javascript>
closeWindow();
</script>
<%
                    return;
                }
                else if (result.length() > 0 )
                {
                    // if the host separator not there
                    // then this is an error message
                    if (result.indexOf("::::") == -1 &&
                        result.indexOf("!!!!") == -1)
                    {
                        ErrorStr  = 
                            MessageServices.massageMessage(result);
                        emxNavErrorObject.addMessage(ErrorStr ); 
                    }
                    else
                    {
                        // split the result that contains new host info
                        // and possibly modified host info that needs
                        // to be removed
                        String [] hostInfo = result.split("!!!!");
                        if (hostInfo.length == 0)
                            result = "";
                        else
                            result = hostInfo[0];
                        String modInfo = "";
                        String sXML = "";
                        if (hostInfo.length > 1)
                        {
                            modInfo = hostInfo[1];
                            // remove trailing separator
                            modInfo = modInfo.substring(
                                0, modInfo.length() - 4);
                        }
                        // no modified data.  add new hosts into folder
                        if (modInfo.length()== 0 && result.length() > 0)
                        {
                            // remove trailing separator
                            result = 
                                result.substring(0, result.length()- 4);
                            // split the string using jpo host separator
                            // each split string will contain the new
                            // host id and folder relation id 
                            String [] relList = result.split("::::");
                            StringList contentData = 
                                new StringList(relList.length);
                            for (int j = 0; j < relList.length; j++)
                            {
                                contentData.add(relList[j]);
                            }
                            // build returning xml java string so new
                            // hosts show up under the folder
                            String action = "add";
                            String message = "";
                            sXML = 
                                StructureBrowserUtil.convertToXMLString(
                                context, action, message, rowId, 
                                contentData, refreshFrame, false );
                        }
%>
<script language = javascript>
    removeStr = '<%=modInfo %>';
    if (removeStr.length > 0)
    {
        // If we are moving hosts to new folder need to reload the page 
        // since don't know how to remove the hosts from the old folder 
        // in the toc.  By refreshing the page it will reload
        var frameTOCContent = 
            sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"smaHomeTOCContent");
        if ( frameTOCContent )
        {
            frameTOCContent.location.href = 
                frameTOCContent.location.href;
        }
        
    }
    
</script>
<%= sXML %>
<script language = javascript>
closeWindow();
</script>
<%
                        return;
                    }
                }
            }
            catch ( Exception e )
            {
                String errMsg = "";
                String lang = request.getHeader("Accept-Language");
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaSimulation.RegisterHost.RegisterError");
                
                ErrorStr  = StringResource.format(
                    errMsg, "P1", ErrorUtil.getMessage(e));
                emxNavErrorObject.addMessage(ErrorStr);  
            }            
        }
        else
        {
            // Get file chooser labels and pass them in the
            // start command to the applet which will post
            // a file chooser and create a controller
            // to parse the file and call a web service to process
            title = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostImport.DialogTitle");
                
            btnLabel = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostImport.ButtonLabel");
                
            tooltip = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostImport.ButtonTooltip");
                
        }
    }
    else if ("hostExport".equals(objectAction))
    {
        try
        {
            startCommand = rowId;
            title = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostExport.DialogTitle");
                
            btnLabel = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostExport.ButtonLabel");
                
            tooltip = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostExport.ButtonTooltip");
                
            confirmMsg = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostExport.ConfirmMsg");
                
            confirmTitle = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.HostExport.ConfirmTitle");
                
        }
        catch (Exception ex)
        {
            ErrorStr  = ErrorUtil.getMessage(ex);
            emxNavErrorObject.addMessage(ErrorStr);
        }
    }
    // not a valid action
    else  
    {
        String errorMsg = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Host.InvalidAction");
        ErrorStr  = StringResource.format(
            errorMsg, "P1", objectAction);
        emxNavErrorObject.addMessage(ErrorStr);
    }


%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%
    if (ErrorStr.length() > 0)
    {
%>
<script language="javascript">
    getTopWindow().closeWindow();
</script>
<%
        return;  
    }else{
        URLBuilder contentURL = new URLBuilder(request.getRequestURI().length(),request.getCharacterEncoding());
        contentURL.append("../simulationcentral/smaExecutionApplet.jsp?");
        contentURL.append("locale=").appendEncoded(context,locale);
%>
<form name="importHostForm" action="<%=contentURL.toString()%>" method="post">
   <input type="hidden" name="AppletWidth" value="10"/>
   <input type="hidden" name="AppletHeight" value="10"/>
   <input type="hidden" name="TNR" value="<%=objId%>"/>
   <input type="hidden" name="HOST" value="<%=hostName%>"/>
   <input type="hidden" name="USERNAME" value="<%=userName%>"/>
   <input type="hidden" name="USERPASS" value="<%=userPass%>"/>
   <input type="hidden" name="OPERATION" value="<%=objectAction%>"/>
   <input type="hidden" name="STARTCOMMAND" value="<%=startCommand%>"/>
   <input type="hidden" name="OVERWRITEDUPLICATES" value="<%=overwrite%>"/>
   <input type="hidden" name="USEDEFAULTCONFIG" value="<%=useDefaultConfig%>"/>
   <input type="hidden" name="SELECTEDROWID" value="<%=rowId%>"/>
   <input type="hidden" name="TITLE" value="<%=title%>"/>
   <input type="hidden" name="BTNLABEL" value="<%=btnLabel%>"/>
   <input type="hidden" name="TOOLTIP" value="<%=tooltip%>"/>
   <input type="hidden" name="CONFIRMMSG" value="<%=confirmMsg%>"/>
   <input type="hidden" name="CONFIRMTITLE" value="<%=confirmTitle%>"/>
   
</form>

<script language="javascript">
      document.forms["importHostForm"].submit();
</script>
<%  
    }    
%>



