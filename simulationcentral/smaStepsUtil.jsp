<%--
  Process various Steps commands on Steps Home page.
--%>

<%@page import="com.dassault_systemes.smaslm.matrix.server.StepsXMLDefinition"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.StepsTableUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>

<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>

<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%--
  load scripts here :
--%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../simulationcentral/smaSimulationCentralFormValidation.js"></script>
<script language="javascript" src="../simulationcentral/smaStructureNavigator.js"></script>

<%
            //What is it that we want to do?
            // Possible objectAction values:
                //addAbove
                // addBelow
                //delete
                //cut
                //paste
               //executionOption
    final String SPLIT_CHAR = "\\";
    Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
            
    StringBuilder contentURL = new StringBuilder(175);
    String objectAction      = emxGetParameter(request, "objectAction");
    String urlstring         = emxGetParameter(request, "prevURL");
    String rowid             = emxGetParameter(request, "rowId");
    String parentOID         = emxGetParameter(request, "parentOID");

    String oid               = "";
    if(urlstring == null)
        oid = emxGetParameter(request, "objectId");
    else
        oid = getoid(urlstring);
    // add sim id
    requestMap.put("objectId", oid);

    
    
    //What is it that we want to do for refresh?
    // Possible loadAction values:
    // loadAction   0  : refresh table
	// loadAction   2  : refresh table
    
    
    String loadAction        = "0";
   // String locale = context.getSession().getLanguage();
    String missingExporter =
        getAlertMsg(context,"Error.ImportExport.MissingExporter");
    String checkoutVPMNotAllwd =
        getAlertMsg(context,"Error.ImportExport.VPMCheckoutNotAllowed");
    String titleNotBlank =
        getAlertMsg(context,"Error.ImportExport.DocTitleNotBlank" );
    String titleNotSpecified =
        getAlertMsg(context,"Error.ImportExport.DocTitleNotSpecified" );
    
    
    
    if ("addAbove".equals(objectAction) || "addBelow".equals(objectAction))  //////////////
    {
        HashMap programMap = new HashMap();
        String[] values = request.getParameterValues("StepsExeOptAdvance");
        StringList sl = new StringList(); 
        if (values != null && values.length > 0)
        {
            sl = new StringList(values);    
        }        
        requestMap.put("StepsExeOptAdvance", sl);
        MapList tableList = StepsTableUtil.getColumnTitleSteps
            (context,JPO.packArgs(requestMap));
        //put the request map as is
        programMap.put("requestMap", requestMap);
        // put the steps map
        programMap.put("objectList", tableList);
        // put the descriptor as a stream
        programMap.put("stream", getExtensionName((String)requestMap.get("stepType")));
        
        String[] args = JPO.packArgs(programMap);
       Boolean result =(Boolean)JPO.invoke( context, 
            "jpo.simulation.Steps", null, 
            "stepAddFunction", args, Boolean.class);
        loadAction = "2";
%>
		<script>
		getTopWindow().closeSlideInDialog();
		steps = findFrame(getTopWindow(),"SMAHome_ListSteps");
		steps.location.href =steps.location.href;			
		</script>
		<%
    }   
    if ("delete".equals(objectAction))  //////////////
    {
        String sRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        requestMap.put("emxTableRowId", sRowIds);
        HashMap programMap = new HashMap();
        MapList tableList = StepsTableUtil.getColumnTitleSteps
            (context,JPO.packArgs(requestMap));
        //put the request map as is
        programMap.put("requestMap", requestMap);
        // put the steps map
        programMap.put("objectList", tableList);
        // put the descriptor as a stream
        programMap.put("stream", getExtensionName((String)requestMap.get("stepType")));
        String[] args = JPO.packArgs(programMap);
       Boolean result =(Boolean)JPO.invoke( context, 
            "jpo.simulation.Steps", null, 
            "stepDeleteFunction", args, Boolean.class);
        loadAction = "0";

    }
	
	if ("runStep".equals(objectAction))  //////////////
    {
	
		HashMap programMap = new HashMap();
        String sRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        //put the request map as is
        // assuming you have only one step selection
        String stepUUID = "";
        if (sRowIds != null) 
            stepUUID = sRowIds[0];
        else
            stepUUID = parentOID;
        
        String ids[] = null;
        if (stepUUID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = stepUUID.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);    
        } else if (stepUUID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = stepUUID.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        
        String stepFuntionId = ids[2];
		StringBuffer runURL = new StringBuffer(275);
                runURL.append("../simulationcentral/smaRunExePreProcessing.jsp");
                runURL.append("?objectId=").append(oid);
				runURL.append("&stepId=").append(stepFuntionId);
        loadAction = "1";
		%>
                <script>
                var executeURL = "<%=runURL.toString()%>";
                hiddenFrame = findFrame(
                        getTopWindow(),
                        "hiddenFrame");
                hiddenFrame.location.href = executeURL;
                </script>
<%
    }
	
    if("SaveExecutionOption".equals(objectAction)){
        HashMap programMap = new HashMap();
        MapList tableList = StepsTableUtil.getColumnTitleSteps
        (context,JPO.packArgs(requestMap));
        programMap.put("requestMap", requestMap);
        programMap.put("objectList", tableList);
        programMap.put("stream",
        		SimulationConstants.EXT_NAME_EXEC_OPTION);
        String[] args = JPO.packArgs(programMap);
        JPO.invoke( context, 
            "jpo.simulation.Steps", null, 
            "SaveValuesForSteps", args, Boolean.class);
        loadAction = "0";
    }
    if("showExecutionOption".equals(objectAction)){
        
        String header =  SimulationUtil.getI18NString
            (context, "smaSimulationCentral.SCE.Compose.Steps.ExecutionOption");
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMAExecutionOptionStep")
        .append("&formHeader=").append(header)
        .append("&objectBased=false")
        .append("&selectedStep=")
        .append((String)session.getAttribute("selectedStep"))
        .append("&HelpMarker=SMASteps_ExecutionOptions")
        .append("&postProcessURL=../simulationcentral/smaStepsUtil.jsp?")
        .append("SaveExecutionOption")
        .append("&rowId=")
        .append(rowid)
        .append("&objectId=")
        .append(oid)
        .append("&parentOID=")
        .append(parentOID);
        %>
        <script>
           getTopWindow().showSlideInDialog("<%=buf.toString()%>");
        </script>
        <%
        
        loadAction = "1";

    }
    
    if ( objectAction.equals("cut") )  //////////////
    {
        
        
        loadAction = "0";

    }
    if ( objectAction.equals("paste") )  //////////////
    {
        
        
        loadAction = "0";

    }
    if ( objectAction.equals("OSCommandDetails") )  //////////////
    {
        
        HashMap programMap = new HashMap();
        requestMap.put("objectId", oid);
        requestMap.put("rowId", parentOID);
        programMap.put("requestMap", requestMap);
        String[] args = JPO.packArgs(programMap);
        String type = "";
        StringBuffer buf = new StringBuffer();
        
        try
        {
            type = StepsTableUtil.getOSCommandType(context, args);
        }
        catch(Exception showBlankPage)
        {
            // ignore; will pick up blank page later in the flow!
        }
        
        if(SimulationConstants.
                   XML_PREDEFINED_PROPERTY_VALUE_INTPNAME.equals(type))
        {
            String connId = StepsTableUtil.getConnectorIdFromLinkID
                                                (context, oid, parentOID);
            if(connId!=null && !"".equals(connId))
            {
                buf.append("../common/emxForm.jsp?")
                .append("form=SMAConnector_ViewEdit")
                .append("&toolbar=SMAConnector_PropsToolbar")
                .append("&objectId=")
                .append(connId);   
            }
            else
            {
                buf.append("../common/emxBlank.jsp?"); 
            }
                
            
            
        }
        else
        {
            buf.append("../common/emxBlank.jsp?");
        }
        
        %>
        <script>
		   var detailsDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
           var contentFrame = getTopWindow().openerFindFrame(getTopWindow(),"content");
           var tempListDisplayFrame;
          
           	if(detailsDisplayFrame){
           		tempListDisplayFrame = getTopWindow().findFrame(detailsDisplayFrame,"SMAOSCommand_Details");
           	 }else if (contentFrame) {
           		tempListDisplayFrame = getTopWindow().findFrame(contentFrame,"SMAOSCommand_Details");
           	 }else{
           		tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"SMAOSCommand_Details");
           	 }
           	
           	tempListDisplayFrame.location.href = "<%=buf.toString()%>";
        </script>
        <%
        loadAction = "1";

    }
    if ( objectAction.equals("OSCommandOptions") )  //////////////
    {
        //String selectedStep = (String) requestMap.get("xmlTableTag");
		parentOID = (String) requestMap.get("parentOID");
		String ids[] = null;
		if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
		{	
			ids = parentOID.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);

		} else if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string


		{
			ids = parentOID.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
		}
		//parentOID = ids[3];
		//String selectedStep = ids[4];
		String selectedStepId = ids[2];
        
        String header =  SimulationUtil.getI18NString
            (context, "smaSimulationCentral.ConnectorOptions.Name");
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxTable.jsp?")
            .append("table=SMAConnectorOption_ResultsValues")
            .append("&customize=false")
            .append("&header=").append(header)
            .append("&toolbar=SMAConnectorOptionValues_ListToolbar")
            .append("&selection=multiple")
            .append("&Export=false")
            .append("&PrinterFriendly=false")
            .append("&program=jpo.simulation.ConnectorOption:getConnUseTable")
            .append("&objectBased=false")
            .append("&pagination=0")
            .append("&massUpdate=false")
            .append("&objectId=").append(oid)
            .append("&suiteKey=SimulationCentral")
            .append("&SuiteDirectory=simulationcentral")
            .append("&selectedStep=").append(selectedStepId)
            .append("&rowId=").append(parentOID)
            .append("&parentOID=").append(parentOID);
        %>
        <script>
           var detailsDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
           var contentFrame = getTopWindow().openerFindFrame(getTopWindow(),"content");
           var tempListDisplayFrame;
          
           	if(detailsDisplayFrame){
           		tempListDisplayFrame = getTopWindow().findFrame(detailsDisplayFrame,"SMAOSCommand_ConnectorOptions");
           	 }else if (contentFrame) {
           		tempListDisplayFrame = getTopWindow().findFrame(contentFrame,"SMAOSCommand_ConnectorOptions");
           	 }else{
           		tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"SMAOSCommand_ConnectorOptions");
           	 }
           	
           	tempListDisplayFrame.location.href = "<%=buf.toString()%>";
        </script>
        <%
        
        loadAction = "1";

    }
    if ( objectAction.equals("OSCommandAddOptions") ) //////////////
	{
		//String selectedStep = (String) requestMap.get("xmlTableTag");
		parentOID = (String) requestMap.get("parentOID");
		String ids[] = null;
		if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
		{
			ids = parentOID.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);

		} else if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string


		{
			ids = parentOID.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
		}
		//parentOID = ids[3];
		//String selectedStep = ids[4];
		String selectedStepId = ids[2];

		String header = SimulationUtil.getI18NString
		(context, "smaSimulationCentral.ConnectorOptions.Name");

		StringBuffer buf = new StringBuffer();
		buf.append("../common/emxTableEdit.jsp?")
			.append("table=SMAConnectorOption_ResultsSelected")
			.append("&showRMB=false")
			.append("&Submit=true")
			.append("&program=jpo.simulation.ConnectorOption:getSelectOptionsTable")
            .append("&objectBased=false")
			.append("&postProcessJPO=jpo.simulation.ConnectorOption:postSelectOptionsTable")
			.append("&header=smaSimulationCentral.Connector.SelectConnectorOptions")
			.append("&selection=multiple")
			.append("&CancelButton=true")
			.append("&SubmitURL=${SUITE_DIR}/smaSelectTaskArgs.jsp")
			.append("&378 SubmitLabel=Select")
			.append("&submitAction=refreshCaller")
			.append("&HelpMarker=SMAConnectorOptionValues_ListSelectOptions")
			.append("&targetLocation=popup")
			.append("&selectedStep=")
			.append(selectedStepId)
			.append("&objectId=")
			.append(oid)
			.append("&rowId=")
			.append(parentOID);
		%>
		<script language="javascript">
			handleDialog("<%=buf.toString()%>");
		</script>
		<%
			loadAction = "1";
	}
    
    if ( objectAction.equals("loadOSCommandEditor") )  //////////////
    {
        
        String header =  SimulationUtil.getI18NString
            (context, "smaSimulationCentral.ConnectorOptions.Name");
            		
        String mode      = emxGetParameter(request, "mode");
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMAOSCommand_Editor")
        .append("&header=").append(header)      
        .append("&objectId=")
        .append(oid);
        
        
        if("edit".equals(mode))
        {
            buf.append("&mode=edit")
            .append("&suiteKey=SimulationCentral")
            .append("&preProcessJavaScript=preProcessJavaScriptOSCommandEditor");
            
	        %>
	        <script>
	          // NEED to revisit sessionstorage
	          var row= sessionStorage.getItem("osCommandEditorRow");
	          var osUrl = "<%=buf.toString()%>";
	          osUrl = osUrl+"&rowId="+row;
	          getTopWindow().showSlideInDialog(osUrl);
	        </script>
	        <%
        }
        else
        {
            buf.append("&toolbar=")
               .append("SMAOSCommandEditor_toolbar")
               .append("&rowId=").append(parentOID);
            %>
            <script>
               // NEED to revisit sessionstorage
           sessionStorage.setItem("osCommandEditorRow", "<%=parentOID%>");
           var detailsDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
           var contentFrame = getTopWindow().openerFindFrame(getTopWindow(),"content");
           var tempListDisplayFrame;
          
           	if(detailsDisplayFrame){
           		tempListDisplayFrame = getTopWindow().findFrame(detailsDisplayFrame,"SMAOSCommand_Editor");
           	 }else if (contentFrame) {
           		tempListDisplayFrame = getTopWindow().findFrame(contentFrame,"SMAOSCommand_Editor");
           	 }else{
           		tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"SMAOSCommand_Editor");
           	 }
           	
           	tempListDisplayFrame.location.href = "<%=buf.toString()%>";
            </script>
            <%  
        }
        
        
        loadAction = "1";

    }
    if ( objectAction.equals("loadUploadStepEditor") )  //////////////
    {
        
        String header =  SimulationUtil.getI18NString
            (context, "smaSimulationCentral.ExecutionOptions.InteractiveImport");
        String mode      = emxGetParameter(request, "mode");
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMAImportExport_TabImportDetailsForm")
        .append("&header=").append(header)      
        .append("&objectId=")
        .append(oid);
        
        if("edit".equals(mode))
        {
            buf.append("&mode=edit")
            .append("&suiteKey=SimulationCentral");
            %>
            <script>
              // NEED to revisit sessionstorage
              var row= sessionStorage.getItem("interactiveImportEditorRow");
              var osUrl = "<%=buf.toString()%>";
              osUrl = osUrl+"&rowId="+row;
              getTopWindow().showSlideInDialog(osUrl);
            </script>
            <%
        }
        else
        {
            buf.append("&toolbar=")
               .append("SMAInteractiveImportEditor_toolbar")
               .append("&rowId=").append(parentOID);
            %>
            <script>
               // NEED to revisit sessionstorage
               sessionStorage.setItem("interactiveImportEditorRow", 
            		   "<%=parentOID%>");
               var channel = findFrame(getTopWindow(),
            		   "SMAImportExport_TabImportDetailsCommand");
               channel.location.href = "<%=buf.toString()%>";
            </script>
            <%  
        }
        
        
        loadAction = "1";

    }
    
    
    if ( objectAction.equals("createDeleteRule") )  //////////////
    {
        parentOID = (String) requestMap.get("parentOID");
        String ids[] = null;
        if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = parentOID.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);    
        } else if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = parentOID.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        parentOID = ids[3];
        //String selectedStep = ids[4];
        String selectedStepId = ids[2];
        
        String header =  SimulationUtil.getI18NString
            (context, "smaSimulationCentral.CreateDeleteRule.Form");
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMADeleteRule_Create")
        .append("&formHeader=").append(header)
        .append("&postProcessJPO=jpo.simulation.ImportExport:createDeleteRule")
        .append("&mode=edit")
        .append("&objectBased=false")
        .append("&selectedStep=")
        .append(selectedStepId)
        .append("&xmlAttribute=attribute_Definition")
        .append("&xmlTableTag=DeleteRules")
        .append("&xmlRowTag=Rule")
        .append("&HelpMarker=SMADeleteRule_ListCreate")
        .append("&submitAction=refreshCaller")  
        .append("&openerFrame=").append("SMAImportExport_TabDeleteRule")
        .append("&objectId=")
        .append(oid);
        %>
        <script>
           getTopWindow().showSlideInDialog("<%=buf.toString()%>");
        </script>
        <%
        
        loadAction = "1";

    }
    if ( objectAction.equals("createDownloadRule") )  //////////////
    {
        parentOID = (String) requestMap.get("parentOID");
        String ids[] = null;
        if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = parentOID.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);    
        } else if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = parentOID.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        parentOID = ids[3];
        //String selectedStep = ids[4];
        String selectedStepId = ids[2];
        
        String header =  SimulationUtil.getI18NString
            (context, "smaSimulationCentral.CreateExportRule.Form");
		if(header != null)
				header = "\"+encodeURI('"+ header +"')+\"";
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMAExportRule_Create")
        .append("&formHeader=").append(header)
        .append("&postProcessJPO=jpo.simulation.ImportExport:createRule")
        .append("&mode=edit")
        .append("&objectBased=false")
        .append("&selectedStep=")
        .append(selectedStepId)
        .append("&xmlAttribute=attribute_Definition")
        .append("&xmlTableTag=ExportRules")
        .append("&suiteKey=SimulationCentral")
        .append("&xmlRootTag=Simulation")
        .append("&xmlRowTag=Rule")
        .append("&HelpMarker=SMAExportRule_ListCreate")
        .append("&submitAction=refreshCaller")  
        .append("&openerFrame=").append("SMAImportExport_TabExportRule")
        .append("&objectId=")
        .append(oid);
        %>
        <script>
           getTopWindow().showSlideInDialog("<%=buf.toString()%>");
        </script>
        <%
        
        loadAction = "1";

    }
    if ( objectAction.equals("createUploadRule") )  //////////////
    {
        parentOID = (String) requestMap.get("parentOID");
        String ids[] = null;
        if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR))
        {
            ids = parentOID.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);    
        } else if (parentOID.contains(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE)) // "%7E" is unicode string for ~
        {
            ids = parentOID.split(SimulationConstants.XML_TABLE_EXPAND_SEPERATOR_UNICODE);
        }
        parentOID = ids[3];
        //String selectedStep = ids[4];
        String selectedStepId = ids[2];
        
        String header =  SimulationUtil.getI18NString
            (context, "smaSimulationCentral.CreateImportRule.Form");
		if(header != null)
				header = "\"+encodeURI('"+ header +"')+\"";
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMAImportRule_Create")
        .append("&formHeader=").append(header)
        .append("&postProcessJPO=jpo.simulation.ImportExport:createRule")
        .append("&mode=edit")
        .append("&objectBased=false")
        .append("&selectedStep=")
        .append(selectedStepId)
        .append("&xmlAttribute=attribute_Definition")
        .append("&xmlTableTag=ImportRules")
        .append("&suiteKey=SimulationCentral")
        .append("&xmlRootTag=Simulation")
        .append("&xmlRowTag=Rule")
        .append("&HelpMarker=SMAImportRule_ListCreate")
        .append("&submitAction=refreshCaller")  
        .append("&openerFrame=").append("SMAImportExport_TabImportRule")
        .append("&objectId=")
        .append(oid);
        %>
        <script>
           getTopWindow().showSlideInDialog("<%=buf.toString()%>");
        </script>
        <%
        
        loadAction = "1";

    }
    if ( objectAction.equals("editDeleteRule") )  //////////////
    {
        String ids[] = rowid.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
        rowid = ids[0];
        String selectedStep = ids[1];
        String header =  SimulationUtil.getI18NString
            (context, "Rules.Delete.ViewEdit.PageHeading");
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMADeleteRule_ViewEdit")
        .append("&formHeader=").append(header)
        .append("&postProcessJPO=jpo.simulation.ImportExport:editRule")
        .append("&mode=edit")
        .append("&objectBased=false")
        .append("&selectedStep=")
        .append(selectedStep)
        .append("&xmlAttribute=attribute_Definition")
        .append("&xmlTableTag=DeleteRules")
        .append("&xmlRootTag=Simulation")
        .append("&xmlRowTag=Rule")
        .append("&HelpMarker=SMADeleteRule_Results")
        .append("&rowId=")
        .append(rowid)
        .append("&objectId=")
        .append(parentOID)
        .append("&parentOID=")
        .append(parentOID)
        .append("&targetLocation=").append("slidein")
        .append("&submitAction=").append("refreshCaller")
        .append("&openerFrame=").append("SMAImportExport_TabDeleteRule");
        %>
        <script>
           getTopWindow().showSlideInDialog("<%=buf.toString()%>");
        </script>
        <%
        
        loadAction = "1";

    }
    if ( objectAction.equals("viewDeleteRule") )  //////////////
    {
        
        String header =  SimulationUtil.getI18NString
            (context, "Rules.Delete.ViewEdit.PageHeading");
        
        StringBuffer buf = new StringBuffer();
        buf.append("../common/emxForm.jsp?")
        .append("form=SMADeleteRule_ViewEdit")
        .append("&formHeader=").append(header)
        .append("&objectBased=false")
        .append("&selectedStep=")
        .append((String)session.getAttribute("selectedStep"))
        .append("&xmlAttribute=attribute_Definition")
        .append("&xmlTableTag=DeleteRules")
        .append("&xmlRootTag=Simulation")
        .append("&xmlRowTag=Rule")
        .append("&HelpMarker=SMADeleteRule_Results")     
        .append("&rowId=")
        .append(rowid)
        .append("&objectId=")
        .append(parentOID)
        .append("&parentOID=")
        .append(parentOID);
        %>
        <script>
           getTopWindow().showSlideInDialog("<%=buf.toString()%>");
        </script>
        <%
        
        loadAction = "1";

    }
    if ( objectAction.equals("refreshStepsList") )  //////////////
    {
        loadAction = "0";
    }
    if("0".equals(loadAction))
    {
        %>
        <script>
        getTopWindow(). refreshTablePage(); 
		getTopWindow().closeSlideInPanel();
        </script>
        <%
    }
	else if("2".equals(loadAction))
	{
        %>
        <script>
        getTopWindow(). refreshTablePage(); 
		getTopWindow().closeSlideInPanel();
        </script>
        <%
    }  
%>

<%!
    private static String getoid(String url)
    {
        String temp = url.substring(url.indexOf("&objectId=")+10, url.length());
        return (String)temp.substring(0, temp.indexOf("&"));
    }

	private static String getExtensionName(String type)
	{
	        String extensionName = 
	            SimulationConstants.EXT_NAME_UPLOAD;
	        if("download".equalsIgnoreCase(type))
	            extensionName = 
	            SimulationConstants.EXT_NAME_DOWNLOAD;
	        if("delete".equalsIgnoreCase(type))
	            extensionName = 
	            SimulationConstants.EXT_NAME_DELETE;
	        if("oscommand".equalsIgnoreCase(type))
	            extensionName = 
	            SimulationConstants.EXT_NAME_OSCOMMAND;
	        
	        return extensionName;
	}

    private String getAlertMsg(Context context,String msgKey)
    {
        String msg = SimulationUtil.getI18NString(context,  msgKey);
        msg = msg.replaceAll("\n", "\\n");
        return msg;
    }

%>
