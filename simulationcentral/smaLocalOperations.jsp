<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process various import/export commands on the Simulation and Activity
  parameter page.  This will use an applet so processing occurs on the
  client machine.
--%>

<html>

<%@page import="com.dassault_systemes.smaslm.common.util.XMLUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.common.util.StringValidator"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.matrixone.jdom.Document" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>

<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@page import="matrix.db.Context" %>
<%@page import="matrix.util.MatrixException"%>
<%@page import = "matrix.util.StringResource"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import = "java.util.HashMap"%>
<%@page import="java.util.Iterator" %>
<%@page import="java.util.regex.Matcher" %>
<%@page import="java.util.regex.Pattern" %>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../simulationcentral/smaGeneral.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
	final String locale = context.getSession().getLanguage();
	String header = SimulationUtil.getI18NString(context,
	    "smaSimulationCentral.AppletJsp.Header" );
	String javaNotEnabled = SimulationUtil.getI18NString(context,
	    "Error.JobRun.JavaNotEnabled");

%>
<head>
<title><%=header%></title>
<script type="text/javascript">
function store(extCreds){
    var topWin = getTopWindow();
    
    if(getTopWindow().getWindowOpener() != null)
        topWin = getTopWindow().getWindowOpener().getTopWindow();
    
    if(topWin.externalStore != null)
        {
            topWin.externalStore(extCreds);
        }
    else{
        if(extCreds != "error")
            {
	topWin.sessionStorage.extCreds = extCreds;
                 
              var frameListHidden = findFrame(topWin, "listHidden");
              frameListHidden.location.href = 
                 "../simulationcentral/smaImportExportClose.jsp?" +
                 "results=OK&method=runAs";
            }
        else{
              alert("Error during credentials encryption");
              getTopWindow().closeWindow();
        }
    }
}
function storeAdviseCredentials(extCreds){
	console.log(extCreds);
	window.parent.setCredentials(extCreds);
}
</script>
</head>

<%
	String objectAction = emxGetParameter(request, "objectAction");
    String loginTicket = emxGetParameter(request, "loginTicket");
    String isPopUp = emxGetParameter(request, "isPopUp");
    String jSessionID = session.getId();
    
    if(isPopUp == null)
        isPopUp = "True";
    
    String ErrorStr =  "";

    // applet parameters
    String objId = emxGetParameter(request, "objectId");
    
    // get the ticket 
    String dataXML = "";
    String reqlocale = request.getLocale().toString();

    // get I18N string if had ticker error
    String ticketError = SimulationUtil.getI18NString(context,
        "smaSimulationCentral.Error.Ticket");

    
    //For HL Improved Job Object pt6
    if(objId == null){
        objId = emxGetParameter(request, "emxTableRowId");            
    }
    

    String publicKey = emxGetParameter(request, "pubkey");
    publicKey=publicKey==null?"":publicKey;

    // since we are running locally, startCommand used to pass file name
    // for import or the selected parameters for export
    String paramIds ="";
    
    // additional applet parameters for import
    String title = "";
    String btnLabel = "";
    String tooltip = "";
    String confirmMsg = "";
    String confirmTitle = "";
    String writeErr = "";
    String paramXml = "";
    String overwrite = "no";

    if ("parameterExport".equals(objectAction))
    {
        try
        {
            String sRowIds[] = 
                emxGetParameterValues(request, "emxTableRowId");
            int numRows = (sRowIds != null) ?  sRowIds.length: 0;
            StringBuilder rowStr = new StringBuilder();
            
            // create row id string as comma separated list
            for (int ii=0; ii<numRows; ii++ )
            {
                if (rowStr.length() > 0)
                    rowStr = rowStr.append(",");
                
                String ids[] = null;
                final String SPLIT_CHAR = "\\";
                if (sRowIds[ii].contains(
                    SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
                {
                    ids = sRowIds[ii].split(
                        SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
                } 
                else if (sRowIds[ii].contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
                {
                    ids = sRowIds[ii].split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
                }
                
                if (ids == null)
                    rowStr = rowStr.append(sRowIds[ii]);
                else
                    rowStr = rowStr.append(ids[0]);
            }
            paramIds = rowStr.toString();
            paramIds = paramIds.replaceAll("\\|", "");
            
            title = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.DialogTitle");
                
            btnLabel = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ButtonLabel");
                
            tooltip = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ButtonTooltip");
                
            confirmMsg = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ConfirmMsg");
                
            confirmTitle = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ConfirmTitle");
                
            
            confirmTitle = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ConfirmTitle");
                
            
            writeErr = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.WriteError");
                
            
            String [] methodargs = {objId,paramIds};

            //
            // - Get the status of the job
            // - If the job is running or paused throw an exception
            //
            paramXml = (String)JPO.invoke(
                context, "jpo.simulation.SimulationParameters", null,
                "getParameterXml", methodargs, String.class);

        }
        catch (Exception ex)
        {
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
        }
    }
    else if ("parameterImport".equals(objectAction))
    {
        String overwriteDup =
        emxGetParameter(request,"overwriteDuplicates");
    
        if ("overwriteDuplicates".equalsIgnoreCase(overwriteDup))
            overwrite = "yes";
    
        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.DialogTitle");
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.ButtonLabel");
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.ButtonTooltip");
    }
    else if ("attributeExport".equals(objectAction))
    {
        try
        {
            title = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.DialogTitle");
            btnLabel = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ButtonLabel");
            tooltip = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ButtonTooltip");
            confirmMsg = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ConfirmMsg");
            confirmTitle = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ConfirmTitle");
            
            // set attribute group oid as arg
            String [] methodargs = {objId};

            // -Get the attributes as an xml string
            paramXml = (String)JPO.invoke(
                context, "jpo.simulation.AttributeGroup", null,
                "getAttributeXml", methodargs, String.class);
        }
        catch (Exception ex)
        {
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
        }
    }
    else if ("attributeImport".equals(objectAction))
    {

        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.AttributeImport.DialogTitle");
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.AttributeImport.ButtonLabel");
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.AttributeImport.ButtonTooltip");
    }
    else if ("encryptCredentials".equals(objectAction)||"encryptCredentialsForAdvise".equals(objectAction)){

        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.DialogTitle");
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.ButtonLabel");
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.ButtonTooltip");
        
    }
    else if ("export".equals(objectAction)){

        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Util.Download");
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Util.Download");
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Util.Download");
        
        dataXML = emxGetParameter(request, "dataXML");
        
    }
    else if ("import".equals(objectAction)){

        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Range.Steps.upload");
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Range.Steps.upload");
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Range.Steps.upload");
        
        dataXML = emxGetParameter(request, "dataXML");
        
    }
    else if ("hostExport".equals(objectAction))
    {
        try
        {
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
			
			
	  		String[] methodargs = new String[] { objId,"true" };
	  		HashMap<String, String> stationDataMap = null;
			// get EED data and station info.  
			// this includes eed url and a ticket and the station xml
			stationDataMap = (HashMap<String, String>) JPO
				.invoke(context, "jpo.simulation.SimulationHostGroup",
				null, "getStationUpdateData", 
				methodargs, HashMap.class);
			// check if we had an error
			String errorStr = stationDataMap.get("exception");
			if (errorStr != null && errorStr.length() > 0)
			{
		  	        emxNavErrorObject.addMessage(errorStr);				
			}
			else
			{

	        	paramXml = stationDataMap.get("stationXml");
	        	
	        	// remove escapes since writing to file and not pushing to COS
	        	paramXml = paramXml.replace("\\\\", "\\");

	        	// get xml formatted for writing to file
	        	com.matrixone.jdom.Document doc = XMLUtil.parseXML(paramXml);
	        	paramXml = XMLUtil.toIndentedXML(doc, "  ");
			}
		} catch (Exception ex) {
			emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
		}
	}
    else if ("hostImport".equals(objectAction))
    {
        String overwriteDup =
        emxGetParameter(request,"overwriteDuplicates");
    
        if ("overwriteDuplicates".equalsIgnoreCase(overwriteDup))
            overwrite = "yes";
    
        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.HostImport.DialogTitle");
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.HostImport.ButtonLabel");
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.HostImport.ButtonTooltip");
    }
	// not a valid action
	else {
		String errorMsg = SimulationUtil.getI18NString(context,
				"smaSimulationCentral.Parameter.InvalidAction");
		ErrorStr = StringResource.format(errorMsg, "P1", objectAction);
		emxNavErrorObject.addMessage(ErrorStr);
	}
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<%
    if (ErrorStr.length() > 0)
    {
%>
<script language="javascript">
    getTopWindow().closeWindow();
</script>
<%
        return;  
    }    
    else
    {
        HashMap props = new HashMap();
        props.put("TNR", objId);
        props.put("OPERATION", objectAction);
        props.put("loginTicket", loginTicket);
        props.put("isPopUp", isPopUp);
        props.put("TITLE", title);
        props.put("BTNLABEL", btnLabel);
        props.put("TOOLTIP", tooltip);
        props.put("CONFIRMMSG", confirmMsg);
        props.put("CONFIRMTITLE", confirmTitle);
        props.put("REQLOCALE", reqlocale);
        props.put("WRITEERR", writeErr);
        props.put("PARAMXML",  XSSUtil.encodeForURL(context,paramXml));
        props.put("dataXML",  XSSUtil.encodeForURL(context,dataXML));
        props.put("OVERWRITEDUPLICATES", overwrite);
        props.put("PUBLICKEY", publicKey);
        props.put("JSESSIONID",jSessionID);
        addAppletOutput(request, response, out, context, 
            "com.dassault_systemes.smaslm.execution.util.LocalOperationsApplet.class", 
            10, 10, props);
    }
%>
<body >
        <script language="JavaScript">
        if (!navigator.javaEnabled())
        {
            "simulationcentral/smaImportExportClose.jsp?results="
            +resultLog+"&method=parameterExport";
        	
        	
            var url = 
                "./smaImportExportClose.jsp?results=<%=javaNotEnabled %>&method=parameterExport" ;
            window.location.href = url; 
        }
            
        </script>
</body>
</html>

<%!
 boolean isEmpty(String checkValue) {
     return checkValue == null || checkValue.equals("") || 
         "null".equals(checkValue); 
 }
 
 void addAppletOutput(
     HttpServletRequest request, HttpServletResponse response, 
     JspWriter out, matrix.db.Context context, 
     String appletClass, int width, int height, HashMap props)  
         throws Exception
 {
     String APPLET_DEFAULT_PLUG_IN = "1.6.0_14";
     String APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_UNIX = "http://java.sun.com/javase/downloads/index.jsp";
     String APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_WINDOWS = "http://java.sun.com/update/1.6.0/jinstall-6u14-windows-i586.cab";
     String APPLET_DEFAULT_CODEBASE_PLUG_IN_VER = "1,6,0,14";
     String userAgent = request.getHeader("User-Agent").toLowerCase();
     boolean unixClient = userAgent.indexOf("x11") != -1 || userAgent.indexOf("hp-ux") != -1 || userAgent.indexOf("sunos") != -1;
     String java_codebase = "../simulationcentral/";
     String name = "LocalOperationsApplet"; 
     String archive = "../WebClient/SMASLMApplet.jar";
     String jreVersion ="8AD9C840-044E-11D1-B3E9-00805F499D93";
     
     
         String jreVersionClsId =  FrameworkProperties.getProperty( 
             context,"emxFramework.Applet.JREVersion");
         if(jreVersionClsId!=null && isValidClsId(jreVersionClsId)){
             jreVersion = jreVersionClsId;
         }
     
     String codeBasePlugInVer = FrameworkProperties.getProperty(
         context,"emxFramework.Applet.CODEBASE_JavaPlugIn");
     String codeBasePlugInURL = null;
     
     boolean useDefaultPlugInInfo = isEmpty(codeBasePlugInVer);

     if(!useDefaultPlugInInfo) {
         if(unixClient)
         {
             codeBasePlugInURL =(String)FrameworkProperties.getProperty(
                 context,"emxFramework.Unix.JavaPlugInURL");
             useDefaultPlugInInfo = isEmpty(codeBasePlugInURL);
         } else {
             codeBasePlugInURL =(String)FrameworkProperties.getProperty(
                 context,"emxFramework.Windows.JavaPlugInURL");
             useDefaultPlugInInfo = isEmpty(codeBasePlugInURL);
         }
     }
     
     if(useDefaultPlugInInfo) {
         codeBasePlugInVer = APPLET_DEFAULT_CODEBASE_PLUG_IN_VER;
         codeBasePlugInURL = 
             unixClient ? 
                 APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_UNIX : 
                     APPLET_DEFAULT_CODEBASE_PLUG_IN_URL_WINDOWS;
     }
     

     out.println("<script src=../common/scripts/emxUIEmbeddedObjects.js type=\"text/javascript\"></script>");
     out.println("<script type=\"text/javascript\">");
     out.println("var objEmb = new ObjectEmbedder();");
     out.println("objEmb.setType(OBJECT_TAG);");
     out.println("objEmb.addAttribute(\"classid\",\"clsid:" + jreVersion + "\");");     
     out.println("objEmb.addAttribute(\"name\",\"" + name + "\");");
     String codebase = codeBasePlugInURL + "#Version=" + codeBasePlugInVer;
     out.println("objEmb.addAttribute(\"codebase\",\"" + codebase + "\");"); 
     out.println("objEmb.addAttribute(\"WIDTH\",\"" + width + "\");"); 
     out.println("objEmb.addAttribute(\"HEIGHT\",\"" + height + "\");");
     out.println("objEmb.addParameter(\"java_code\",\"" + appletClass + "\");");
     out.println("objEmb.addParameter(\"java_codebase\",\"" + java_codebase + "\");");
     out.println("objEmb.addParameter(\"java_archive\",\"" + archive + "\");");
     out.println("objEmb.addParameter(\"codebase_lookup\",\"false\");");
     String type = "application/x-java-applet";
     out.println("objEmb.addParameter(\"type\",\"" + type + "\");");
     out.println("objEmb.addParameter(\"scriptable\",\"true\");");

     String key;
     String value;
     Iterator iter = props.keySet().iterator();
     while (iter.hasNext())
     {
         key = (String)iter.next();
         value = (String)props.get(key);
         out.println("objEmb.addParameter(\"" + key + "\",\"" + value + "\");");
     }

     out.println("objEmb.addEmbedAttribute(\"type\",\"" + type + "\");");
     out.println("objEmb.addEmbedAttribute(\"code\",\"" + appletClass + "\");");
     out.println("objEmb.addEmbedAttribute(\"name\",\"" + name + "\");");
     out.println("objEmb.addEmbedAttribute(\"java_code\",\"" + appletClass + "\");");
     out.println("objEmb.addEmbedAttribute(\"java_codebase\",\"" + java_codebase + "\");");
     out.println("objEmb.addEmbedAttribute(\"java_archive\",\"" + archive + "\");");
     out.println("objEmb.addEmbedAttribute(\"width\",\"" + width + "\");"); 
     out.println("objEmb.addEmbedAttribute(\"height\",\"" + height + "\");");
     out.println("objEmb.addEmbedAttribute(\"scriptable\",\"true\");");

     iter = props.keySet().iterator();
     while (iter.hasNext())
     {
         key = (String)iter.next();
         value = (String)props.get(key);
         out.println("objEmb.addEmbedAttribute(\"" + key + "\",\"" + value + "\");");
     }
     out.println("objEmb.addEmbedAttribute(\"pluginspage\",\"" + codeBasePlugInURL + "\");");
     out.println("objEmb.draw();\n</script>");
 }
 private boolean isValidClsId(String jreVersion)
 {
     Pattern pattern = Pattern.compile("[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}");
     Matcher m = pattern.matcher(jreVersion);
     return m.matches();
}
%>


