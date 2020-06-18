<%-- emxEngrBOMIntermediateProcess.jsp --
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%--
 * @quickreview gh4 qwm 2016-06-08 _IR-444360: MBOMConsolidated View Changes
  * @quickreview gh4 2015-09-16 _IR-399342: No fixes, changes to just correct the indentation
  * @quickreview gh4 2015-09-16 _IR-399342: Undo-command not seen, fixed by adding showRMBInlineCommands=true to the URL
--%>

<%@page import="com.matrixone.apps.common.Plant"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	String[] objectid = emxGetParameterValues(request, "objectId");
	String sCreateMode = emxGetParameter(request, "createMode");
	String sBOMViewMode = emxGetParameter(request, "BOMViewMode");
	String relId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "relId"));
	String strPartId = objectid[0];
	strPartId=  EngineeringUtil.getTopLevelPartForProduct(context,strPartId);
	String suiteKey = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "suiteKey"));
	//if(com.matrixone.apps.engineering.EngineeringUtil.isENGSMBInstalled(context)) { //Commented for IR-213006
		//suiteKey = "TeamBOMEditor";
		//replacing the physical id passed in the URL to ObjectId in the session, if web session is opened from "Open in Web" command
		com.matrixone.apps.domain.DomainObject partObj = new com.matrixone.apps.domain.DomainObject(strPartId);
		strPartId =  partObj.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_ID);
		String sType=partObj.getInfo(context,DomainConstants.SELECT_TYPE);
		String policy = partObj.getInfo(context,DomainConstants.SELECT_POLICY);
		String configuredPolicy = PropertyUtil.getSchemaProperty(context, "policy_ConfiguredPart");
		String configuredPart = "false";
		if ( policy.equals(configuredPolicy) ) {
			configuredPart = "true";
		}
	//}
	String[] sENCBillOfMaterialsViewCustomFilter = emxGetParameterValues(request, "ENCBillOfMaterialsViewCustomFilter");
	String sBOMFilter = (sENCBillOfMaterialsViewCustomFilter != null) ? XSSUtil.encodeForJavaScript(context,sENCBillOfMaterialsViewCustomFilter[0]):"";
	String sRevisionFilterVal = emxGetParameter(request, "ENCBOMRevisionCustomFilter");
	
	String strUnAssinged = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Unassigned");
	String str3dPlayEnabled =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.Toggle.3DViewer");
	boolean isPartFromVPLMSync = new com.matrixone.apps.engineering.Part(strPartId).isPartFromVPLMSync(context);
	StringList slPlantName  = new StringList();
	StringList slPlantID  = new StringList();
	String sPlantObjId = "";
	String sSubHeader = "";
	if(EngineeringUtil.isMBOMInstalled(context) && (sBOMFilter.equalsIgnoreCase("plantspecificConsolidated") || sBOMFilter.equalsIgnoreCase("plantspecific") || sBOMFilter.equalsIgnoreCase("common"))){
		
			//START - get user prefernace plant
			String strPlantObjId = "";			
			String strPlantName	= "";
			 HashMap paramMap  = new HashMap();
			 HashMap requestMap = new HashMap();
			 requestMap.put("objectId", strPartId);
			 paramMap.put("requestMap",requestMap);
			 String[] args = JPO.packArgs(paramMap);
			 
			 HashMap plantMap=(HashMap)JPO.invoke(context, "emxManufacturingUtil",new String[]{}, "getPlantOptions", args, HashMap.class);
			 
			 StringList fieldChoicesbk=(StringList)plantMap.get("field_choices");
			 StringList fieldDisplayChoices=(StringList)plantMap.get("field_display_choices");
			 
			 strPlantObjId=(String)fieldChoicesbk.get(0);
			 strPlantName=(String)fieldDisplayChoices.get(0);
			 
			if(UIUtil.isNotNullAndNotEmpty(strPlantObjId) && UIUtil.isNotNullAndNotEmpty(strPlantName))
			{
					sSubHeader=strPlantName;
					sPlantObjId=strPlantObjId;		
		}
		
			//END - get user prefernace plant
		}
		if(strUnAssinged.equalsIgnoreCase(sSubHeader))
		{
			sSubHeader = "";
		}
		else
		{
			if(sSubHeader != null && !sSubHeader.equals(strUnAssinged) && !sSubHeader.equals("null") && !sSubHeader.equals("")) {
				if(UIUtil.isNotNullAndNotEmpty(sPlantObjId)) {
					sSubHeader = sSubHeader;
				}
			}
			if(sBOMFilter.equalsIgnoreCase("common")){
				String[] tokens = sSubHeader.split(":");
				sSubHeader=tokens[0];
				
		}
	}
	
	HashMap programMap = new HashMap();
	programMap.put("objectId", strPartId);
	
	// Code changes for X-BOM Cost Analytics-START
	boolean isCamInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMCostAnalytics",false,null,null);
	
	Boolean  blnIsApplyAllowed; 
	
	if(isCamInstalled)
	{
	  blnIsApplyAllowed = (Boolean)JPO.invoke(context,"CAENCActionLinkAccessBase",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);
	} else {
	  blnIsApplyAllowed = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);
	}
	//Code changes for X-BOM Cost Analytics-END
	
	if("plantspecificConsolidated".equalsIgnoreCase(sBOMFilter) || "plantspecific".equalsIgnoreCase(sBOMFilter))
	{
		blnIsApplyAllowed = (Boolean)JPO.invoke(context,"emxMBOMUIUtil",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);
	}
	boolean blnApply = blnIsApplyAllowed.booleanValue();
	
	String findNumber = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_FindNumber");
%>

<script language="Javascript">
	//XSSOK
	var sBOMFilterVal = "<%=sBOMFilter%>";
	var sCreateMode = "<xss:encodeForJavaScript><%=sCreateMode%></xss:encodeForJavaScript>";
        var s3dplay ="<%=str3dPlayEnabled%>";
        var isPartFromVPLMSync= "<%=isPartFromVPLMSync%>";
	if(sBOMFilterVal=="plantspecificConsolidated")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<xss:encodeForURL><%=sType%></xss:encodeForURL>&preProcessJPO=emxMBOMPart:hasMBOMEditSelected&expandProgram=enoMBOMConsolidated:getPlantSpecificConsolidatedView&table=MFGMBOMSummarySBConsolidated&toolbar=MFGMBOMToolBar,MFGMBOMCustomFilterMenu&header=emxMBOM.Command.BOMHeader&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&objectCompare=false&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&editRootNode=false&showApply=<%=blnApply%>&showTabHeader=true&subHeader=" +"<xss:encodeForURL><%=sSubHeader%></xss:encodeForURL>"+ "&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&connectionProgram=enoMBOMConsolidated:doMBOMActions&postProcessJPO=emxMBOMPart:validateStateForApply&showRMB=false&effectivityRelationship=relationship_MBOM,relationship_MBOMPending&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&expandLevelFilter=true";
	}
	else if(sBOMFilterVal=="plantspecific")
	{																																																																																																																																													
		//sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&preProcessJPO=emxMBOMPart:hasMBOMEditSelected&expandProgram=emxMBOMPart:getPlantSpecificViewMBOM&table=MFGMBOMSummarySB&toolbar=MFGMBOMToolBar,MFGMBOMCustomFilterMenu&header=emxMBOM.Command.BOMHeader&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&editRootNode=false&showApply=<%=blnApply%>&showTabHeader=true&subHeader=" +"<xss:encodeForURL><%=sSubHeader%></xss:encodeForURL>"+ "&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&connectionProgram=emxMBOMPart:visualQuesForManuParts&postProcessJPO=emxMBOMPart:validateStateForApply&lookupJPO=emxMBOMPart:lookupEntries&insertNewRow=true&addJPO=addJPO&showRMB=false&effectivityRelationship=relationship_MBOM,relationship_MBOMPending&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&showRMBInlineCommands=true";
		sURL = "../common/emxIndentedTable.jsp?type=<xss:encodeForURL><%=sType%></xss:encodeForURL>&preProcessJPO=emxMBOMPart:hasMBOMEditSelected&expandProgram=emxMBOMPart:getPlantSpecificViewMBOM&table=MFGMBOMSummarySB&toolbar=MFGMBOMToolBar,MFGMBOMCustomFilterMenu&header=emxMBOM.Command.BOMHeader&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&editRootNode=false&showApply=<%=blnApply%>&showTabHeader=true&subHeader=" +"<xss:encodeForURL><%=sSubHeader%></xss:encodeForURL>"+ "&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&connectionProgram=emxMBOMPart:visualQuesForManuParts&postProcessJPO=emxMBOMPart:applyChgForRevBasedPlantSpecView&lookupJPO=emxMBOMPart:lookupEntries&insertNewRow=true&addJPO=addJPO&showRMB=false&effectivityRelationship=relationship_MBOM,relationship_MBOMPending&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&showRMBInlineCommands=true";
	}
	else if(sBOMFilterVal=="planning")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<xss:encodeForURL><%=sType%></xss:encodeForURL>&expandProgram=emxPlanningMBOM:getPlanningMBOMForConsumption&table=MFGPlanningMBOMIndentedSummary&toolbar=MFGPlanningMBOMViewToolbar,MFGPlanningMBOMCustomToolBar,MFGPlanningMBOMChangeToolBar&header=emxMBOM.Command.BOMHeader&sortColumnName=Find Number,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplanningview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&editRootNode=false&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&showApply=<%=blnApply%>&connectionProgram=emxPlanningMBOM:connectPLBOMPendingMfgPart&postProcessJPO=emxMBOMPart:validateStateForApply&lookupJPO=emxMBOMPart:lookupEntries&addJPO=addJPO&showRMB=true&Initial=true&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
	}
	else if(sBOMFilterVal=="common")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<xss:encodeForURL><%=sType%></xss:encodeForURL>&expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&toolbar=MBOMCommonViewToolBar,MBOMCommonCustomFilterMenu&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelpbomcommonview&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&portalMode=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&showTabHeader=true&subHeader=" +"<xss:encodeForURL><%=sSubHeader%></xss:encodeForURL>"+ "&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&connectionProgram=emxMBOMPart:inlineCreateAndConnectPart&editRootNode=false&showApply=<%=blnApply%>&postProcessJPO=emxPart:validateStateForApply&lookupJPO=emxPart:lookupEntries&insertNewRow=true&addJPO=addJPO&relType=EBOM&editRelationship=relationship_EBOM&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&showRMBInlineCommands=true";
	}
	else
	{
		var sAppendURL = "&HelpMarker=emxhelppartbom&expandProgram=emxPart:getEBOMsWithRelSelectablesSB&appendURL=Revisions|EngineeringCentral&parallelLoading=true";
		
		if ( "<%= configuredPart %>" == "true" ) {
			sAppendURL = "&HelpMarker=emxhelpConfiguredBOM&hideImportBOM=true&expandProgram=enoConfiguredBOM:getBOM&appendURL=ChangeEffectivity|UnresolvedEBOM&parallelLoading=true&allowVariantEditParentPolicy=policy_ConfiguredPart";
		}
		
		sURL = "../common/emxIndentedTable.jsp?type=<xss:encodeForURL><%=sType%></xss:encodeForURL>&ContextPolicy=<xss:encodeForURL><%=policy%></xss:encodeForURL>&BOMViewMode=<xss:encodeForURL><%= sBOMViewMode %></xss:encodeForURL>&portalMode=true&toolbar=ENCBOMToolBar&insertNewRow=false&addJPO=addJPO&connectionProgram=enoUnifiedBOM:bomConnection&relType=EBOM&editRelationship=relationship_EBOM&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&table=ENCEBOMIndentedSummarySB&reportType=BOM&sortColumnName=none&PrinterFriendly=true&showRMBInlineCommands=true&objectId=<%=XSSUtil.encodeForJavaScript(context,strPartId)%>&suiteKey=EngineeringCentral&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply=<%=blnApply%>&postProcessJPO=enoUnifiedBOM:updateBOM&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&selection=multiple&BOMMode=ENG&isRMBForEBOM=true&displayView=tree,details,thumbnail&hideBPSMenu=true&freezePane=Name,V_Name1,V_Name,InstanceTitle,InstanceDescription,DesignName&ENCBOMRevisionCustomFilter=<xss:encodeForURL><%=sRevisionFilterVal%></xss:encodeForURL>" + sAppendURL;
		
	}
	
	//XSSOK
	if("<%=relId%>" != null){
	//XSSOK
			sURL += "&relId=<%=relId%>";
	}
	//X3 MBOM Code Ends

	if (s3dplay == "true" && isPartFromVPLMSync=="true"){
		sURL += "&selectHandler=crossHighlightENG3DPlay"; 
	}
	else if(s3dplay == "false"){
		sURL += "&selectHandler=crossHighlightENG";
	}
	
	if ("<xss:encodeForJavaScript><%= sBOMViewMode %></xss:encodeForJavaScript>" == "Instance" || "<xss:encodeForJavaScript><%= sBOMViewMode %></xss:encodeForJavaScript>" == "Rollup") {
		//XSSOK
		if("<%= sBOMViewMode %>" == "Rollup"){
			sURL = sURL+"&hideImportBOM=true&DisableVariantEdit=true";
		}
		var	 targetFrame = findFrame(getTopWindow(),"ENCBOM") ?  findFrame(getTopWindow(),"ENCBOM") :  findFrame(getTopWindow(),"content");
		targetFrame.document.location.href = sURL;	
	} else {
	 
		//sURL += "&crossHighlight=true";
		window.location.href = sURL;
		if(sCreateMode == "NewEBOM"){
			try{
				var winObject = findFrame(getTopWindow(), "slideInFrame");
				winObject.closeSlideinWindow();			
			}
			catch(e){}
		}
	}
</script>
