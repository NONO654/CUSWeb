<%-- (c) Dassault Systemes, 2011, 2008 --%>
<%--
  Process Export Rules Name link.
  Created by RKP
--%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@include file="../simulationcentral/smaWebUtil.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
	final String SPLIT_CHAR = "\\";
    String objectId = emxGetParameter(request, "objectId");
    String parentId = emxGetParameter(request, "parentOID");
    String rowId = emxGetParameter(request, "rowId");
    String[] ids = rowId.split(SPLIT_CHAR+SimulationConstants.XML_TABLE_EXPAND_SEPERATOR);
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
            null,"getExporterData", methodargs, HashMap.class);
        String formName = "SMAExportRule_ViewEdit";
        String boid = (String)rowMap.get("BuSOID");
        if(boid!=null && !" ".equals(boid))
            formName = "SMAContentBOExportRule_Create";
	    String method = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_METHOD);
	   
	    if ("wsvault".equals(method))
	    {
	        formName = "SMAContentWorkSpaceFolderExportRule_Edit";
	        String folderTitle = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_FOLDER_TITLE);	        
	        String folderType = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_FOLDER_TYPE);
	        String expDocType = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_DWNLD_FILTER_DOC_TYPE);
	        String exportSource = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_DWNLD_FILTER_CAT);
	        String exportMethod = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_DWNLD_METHOD);
	        String expPath = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_DWNLD_PATH);
	        String docId = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_REFERENCE_UUID);
	        String fileName = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_FILTER_FILE_NAME);
	        String exportEmptyFolders = (String)rowMap.get(SimulationConstants.XML_ATTR_RULE_DWNLD_EMPTY_FOLDER);
	        contentURL.append("../common/emxForm.jsp")
	        .append("?form=").append(formName)
	        .append("&formHeader=").append("Rules.Export.ViewEdit.PageHeading")
	        .append("&objectBased=false")
	        .append("&mode=edit")
	        .append("&suiteKey=SimulationCentral")
	        .append("&postProcessJPO=").append("jpo.simulation.ImportExport:editRule")
	        .append("&xmlAttribute=attribute_Definition")
	        .append("&xmlRootTag=Simulation")
	        .append("&xmlTableTag=").append("ExportRules")
	        .append("&selectedStep=").append(step)
	        .append("&HelpMarker=").append("SMAExportRule_Results")
	        .append("&referenceId=").append(docId)
	        .append("&parentOID=").append(parentId)
	        .append("&titleSpec=").append("true")
	        .append("&folderTitle=").append(folderTitle)
	        .append("&exportDocType=").append(expDocType)
	        .append("&folderType=").append(folderType)
	        .append("&category=").append(exportSource)
	        .append("&exportMethod=").append(exportMethod)
	        .append("&exportPath=").append(expPath)
	        .append("&documentId=").append(docId)
	        .append("&fileName=").append(fileName)
	        .append("&exportEmptyFolders=").append(exportEmptyFolders)
	        .append("&submitAction=").append("refreshCaller")
	        .append("&openerFrame=").append("SMAImportExport_TabExportRule")
	        .append("&rowId=").append(rowId)
	        .append("&targetLocation=").append("slidein")
	        .append("&openerFrame=").append("StepsContent");
	
	    }
	    else {
	        contentURL
		        .append("../common/emxForm.jsp")
		        .append("?form=").append(formName)
		        .append("&formHeader=").append("Rules.Export.ViewEdit.PageHeading")
		        .append("&objectBased=false")
		        .append("&mode=edit")
		        .append("&suiteKey=SimulationCentral")
		        .append("&preProcessJavaScript=").append("smaRefCheckboxCallBack:smaExportDocTypeCallBack")//:smaEEFCheckboxCallBack")//EEF - HL - pt6 - New method added
		        .append("&postProcessJPO=").append("jpo.simulation.ImportExport:editRule")
		        .append("&xmlAttribute=attribute_Definition")
		        .append("&xmlTableTag=").append("ExportRules")
		        .append("&selectedStep=").append(step)
		        .append("&submitAction=").append("refreshCaller")
		        .append("&openerFrame=").append("SMAImportExport_TabExportRule")
                .append("&targetLocation=").append("slidein")
		        .append("&HelpMarker=").append("SMAExportRule_Results")
		        .append("&objectId=").append(objectId)
		        .append("&parentOID=").append(parentId)
		        .append("&rowId=").append(rowId)
		        .append("&openerFrame=").append("StepsContent");
	    }
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%
        // if we have an error or we don't have a process id
        // (only have id if using wrapper or lsf)
        // no need to continue since cannot do abort
        if (sError.length()>0 )
        {
%>
<script language=javascript>
closeWindow();
</script>
<%
            return;  
        }    
%>
<script language="javascript">

window.location.href = "<%=contentURL.toString()%>";
</script>

