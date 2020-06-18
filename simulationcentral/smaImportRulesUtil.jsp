<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process Import Rules Name link.
--%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.ConnectorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SlmUtil" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@page import = "java.util.HashMap"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SlmUtil"%>
<%@page import= "com.dassault_systemes.smaslm.common.util.StringUtil" %>


<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
	final String SPLIT_CHAR = "\\";
    String objectId = emxGetParameter(request, "objectId");
    String parentId = emxGetParameter(request, "parentOID");
    String rowId = emxGetParameter(request, "rowId");
    String[] ids = rowId.split(SPLIT_CHAR+"~");
    String objectAction = emxGetParameter(request, "objectAction");
    String locale = context.getSession().getLanguage();
    String sError = "";

    if ( (objectAction == null) || (objectAction.equals("")) )
    {
        sError = SimulationUtil.getI18NString(context,
            "Error.ContentUtil.NoAction");
        emxNavErrorObject.addMessage(sError);
        objectAction = "";
    }

    String step = ids[1];//(String)session.getAttribute("selectedStep");
    rowId = ids[0];
    HashMap paramMap = new HashMap();
    paramMap.put("objectId",objectId);
    paramMap.put("parentId",parentId);
    paramMap.put("selectedStep", step);
    paramMap.put("rowId",rowId);
    String[] methodargs = JPO.packArgs(paramMap);
   
    /////////////////
    // Contains URL for action
    URLBuilder contentURL = getURLBuilder(request);
    
    if ("showRule".equals(objectAction))
    {
        HashMap rowMap = (HashMap)JPO.invoke(
            context,"jpo.simulation.ImportExport",
            null,"getImporterData", methodargs, HashMap.class);
	    String formName = "SMAImportRule_ViewEdit";
	    String method = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_METHOD);
	    if ("importer".equals(method))
	    {
	        formName = "SMAContentImporterImportRule_CreateEdit";
	        String docTitle = (String)rowMap.get("titleUserDefined");
	        String docType = (String)rowMap.get("importDocType_C");
	        String docPolicy = (String)rowMap.get("importDocPolicy_C");
	        String category = (String)rowMap.get("importCategory");
	        String contentRel = (String)rowMap.get("contentRel_C");
	        String impactRel = (String)rowMap.get("impactRel_C");
	        String docId = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_REFERENCE_UUID);
	        String fileName = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_FILTER_FILE_NAME);
	        contentURL.append("../common/emxForm.jsp")
	        .append("?form=").append(formName)
	        .append("&formHeader=").append("Rules.Import.ViewEdit.PageHeading")
	        .append("&objectBased=false")
	        .append("&mode=edit")
	        .append("&suiteKey=SimulationCentral")
	        .append("&postProcessJPO=").append("jpo.simulation.ImportExport:editRule")
	        .append("&xmlAttribute=attribute_Definition")
	        .append("&xmlRootTag=Simulation")
	        .append("&xmlTableTag=").append("ImportRules")
	        .append("&selectedStep=").append(step)
	        .append("&HelpMarker=").append("SMAImportRule_Results")
	        .append("&objectId=").append(objectId)
	        .append("&parentOID=").append(parentId)
	        .append("&titleSpec=").append("true")
	        .append("&docTitle=").append(docTitle)
	        .append("&docType=").append(docType)
	        .append("&docPolicy=").append(docPolicy)
	        .append("&category=").append(category)
	        .append("&contentRel=").append(contentRel)
	        .append("&impactRel=").append(impactRel)
	        .append("&documentId=").append(docId)
	        .append("&fileName=").append(fileName)
	.append("&targetLocation=").append("slidein")
	        .append("&submitAction=").append("refreshCaller")
            .append("&openerFrame=").append("SMAImportExport_TabImportRule")
	        .append("&rowId=").append(rowId);
	
	    }
	    else if ("wsvault".equals(method))
	    {
	        formName = "SMAContentWorkSpaceFolderImportRule_CreateEdit";
	        String folderTitle = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_FOLDER_TITLE);
	        String docType = (String)rowMap.get("importDocType_C");
	        String docPolicy = (String)rowMap.get("importDocPolicy_C");
	        String category = (String)rowMap.get("importCategory");
	        String contentRel = (String)rowMap.get("contentRel_C");
	        String impactRel = (String)rowMap.get("impactRel_C");
	        String docId = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_REFERENCE_UUID);
	        String fileName = StringUtil.escapeJavaScript((String)rowMap.get(SimulationConstants.XML_ATTR_RULE_FILTER_FILE_NAME));
	        String impFolderName = (String)rowMap.get("importFolderType_C");
	        contentURL.append("../common/emxForm.jsp")
	        .append("?form=").append(formName)
	        .append("&formHeader=").append("Rules.Import.ViewEdit.PageHeading")
	        .append("&objectBased=false")
	        .append("&mode=edit")
	        .append("&suiteKey=SimulationCentral")
	        .append("&postProcessJPO=").append("jpo.simulation.ImportExport:editRule")
	        .append("&xmlAttribute=attribute_Definition")
	        .append("&xmlRootTag=Simulation")
	        .append("&xmlTableTag=").append("ImportRules")
	        .append("&selectedStep=").append(step)
	        .append("&HelpMarker=").append("SMAImportRule_Results")
	        .append("&referenceId=").append(docId)
	        .append("&objectId=").append(objectId)
	        .append("&parentOID=").append(parentId)
	        .append("&titleSpec=").append("true")
	        .append("&folderTitle=").append(folderTitle)
	        .append("&docType=").append(docType)
	        .append("&docPolicy=").append(docPolicy)
	        .append("&category=").append(category)
	        .append("&contentRel=").append(contentRel)
	        .append("&impactRel=").append(impactRel)
	        .append("&documentId=").append(docId)
	        .append("&fileName=").append(fileName)
	.append("&targetLocation=").append("slidein")
	        .append("&submitAction=").append("refreshCaller")
            .append("&openerFrame=").append("SMAImportExport_TabImportRule")
	        .append("&rowId=").append(rowId);
	    }
	
	    else
	    {
	        
		    contentURL
		        .append("../common/emxForm.jsp")
		        .append("?form=").append(formName)
		        .append("&formHeader=").append("Rules.Import.ViewEdit.PageHeading")
		        .append("&objectBased=false")
		        .append("&mode=edit")
		        .append("&suiteKey=SimulationCentral")
                .append("&preProcessJavaScript=").append("smaRefCheckboxCallBack:smaExportDocTypeCallBack")
		        .append("&postProcessJPO=").append("jpo.simulation.ImportExport:editRule")
		        .append("&xmlAttribute=attribute_Definition")
		        .append("&xmlTableTag=").append("ImportRules")
		        .append("&selectedStep=").append(step)
                .append("&submitAction=").append("refreshCaller")
                .append("&targetLocation=").append("slidein")
		        .append("&HelpMarker=").append("SMAImportRule_Results")
		        .append("&objectId=").append(objectId)
		        .append("&parentOID=").append(parentId)
		        .append("&rowId=").append(rowId)
		        .append("&openerFrame=").append("SMAImportExport_TabImportRule");
	    }
    }
    else if ("showImporter".equals(objectAction))
    {
        HashMap rowMap = (HashMap)JPO.invoke(
            context,"jpo.simulation.ImportExport",
            null,"getImporterData", methodargs, HashMap.class);
        String importer = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_CONNECTOR_UUID);
        if ( (importer == null) || (importer.equals("")) )
        {
            sError = SimulationUtil.getI18NString(context,
                "Error.ContentUtil.NoAction");
            emxNavErrorObject.addMessage(sError);
        }
        else
        {
            String importerId = ConnectorUtil.getConnectorIdFromUUID(context , parentId , importer);
	        contentURL
	            .append("../common/emxNavigator.jsp")
                .append("?objectId=").append(importerId)
                .append("&targetCategory=smaSimulationCentral.Properties")
                .append("&HelpMarker=").append("SMAImportRule_Results");
        }
        
    }
    else if ("showExporter".equals(objectAction))
    {
        HashMap rowMap1 = (HashMap)JPO.invoke(
            context,"jpo.simulation.ImportExport",
            null,"getExporterData", methodargs, HashMap.class);
        String exporter = (String)rowMap1.get(SimulationConstants.XML_ATTR_RULE_CONNECTOR_UUID);
        exporter = SlmUtil.getPLMObjectIDfromUUID(context, parentId, exporter, SimulationConstants.RELATIONSHIP_SIMULATION_CONNECTOR, "*", true);
        if ( (exporter == null) || (exporter.equals("")) )
        {
            sError = SimulationUtil.getI18NString(context,
                "Error.ContentUtil.NoAction");
            emxNavErrorObject.addMessage(sError);
        }
        else
        {
            //String exporterId = SlmUtil.getConnectorIDfromUUID(context , parentId , exporter);
            contentURL
                .append("../common/emxNavigator.jsp")
                .append("?objectId=").append(exporter)
                .append("&targetCategory=smaSimulationCentral.Properties")
                .append("&HelpMarker=").append("SMAExportRule_Results");
        }
        
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
        // if we have an error or we don't have a process id
        // (only have id if using wrapper or lsf)
        // no need to continue since cannot do abort
        if (sError.length()>0 )
        {
%>
<script language = javascript>
closeWindow();
</script>
<%
            return;  
        }    
%>
<script language="javascript">

window.location.href = "<%=contentURL.toString()%>";
</script>

