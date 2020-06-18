<%-- CharacteristicMasterUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
static const char RCSID[] = "$Id: ENOCriteriaUtil.jsp.rca 1.60 Wed Apr  2 16:23:14 2008 przemek Experimental przemek $";
--%>

<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOICriteria"%>
<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOCriteriaFactory"%>
<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOICriteriaUtil"%>
<%@page import="com.dassault_systemes.enovia.criteria.util.CriteriaConstants"%>
<%@page import="com.dassault_systemes.enovia.criteria.util.CriteriaUtil"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.interfaces.ENOCharacteristicFactory"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.interfaces.ENOCharacteristicServices"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.interfaces.ENOICharacteristicMaster"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.util.CharacteristicMasterConstants"%>
<%@page import="com.matrixone.apps.common.util.ComponentsUIUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%
	String mode=(String)emxGetParameter(request, CriteriaConstants.MODE);
	String pageUI=(String)emxGetParameter(request, "pageUI");
	String[] strEmxTableRowIds = emxGetParameterValues(request, CriteriaConstants.EMX_TABLE_ROWID);
	String objectId  	= emxGetParameter(request, CriteriaConstants.OBJECT_ID);
	String rowIds[] = CriteriaUtil.parseTableRowId(strEmxTableRowIds, CriteriaConstants.OBJECT_ID);
	String relIds[];
	String strSelectedObjId=CharacteristicMasterConstants.EMPTY_STRING;
	String actionURL = CharacteristicMasterConstants.EMPTY_STRING;
	boolean exceptionThrown = false;
	try {
		if(CriteriaConstants.DELETE.equalsIgnoreCase(mode)) {
			for(int i = 0; i < rowIds.length; i++){
				strSelectedObjId = rowIds[i];
				ENOICharacteristicMaster charMasterObj = ENOCharacteristicFactory.getCharacteristicMasterById(context, strSelectedObjId);
				charMasterObj.deleteCharacteristicMaster(context);
			}
		} else if("disconnectTM".equalsIgnoreCase(mode)) {
			for(int i=0;i<rowIds.length;i++) {
				strSelectedObjId = rowIds[i];
				ENOICharacteristicMaster charMasterObj = ENOCharacteristicFactory.getCharacteristicMasterById(context, objectId);
				charMasterObj.disconnectTestMethod(context, strSelectedObjId);
			}
		} else if (CharacteristicMasterConstants.REVISE.equalsIgnoreCase(mode)) {
			String revisedObjId = CharacteristicMasterConstants.EMPTY_STRING;
			if ("myDesk".equals(pageUI)) {
				revisedObjId = ENOCharacteristicServices.reviseCharacteristicMaster(context, rowIds[0]);
			} else {
				revisedObjId = ENOCharacteristicServices.reviseCharacteristicMaster(context, objectId);
			}
			actionURL = "../common/emxTree.jsp?AppendParameters=true&objectId="
						+ XSSUtil.encodeForURL(context, revisedObjId) + "&mode=basic";

		} else if (CharacteristicMasterConstants.REMOVE_CM.equalsIgnoreCase(mode)) {
			relIds = CriteriaUtil.parseTableRowId(strEmxTableRowIds, CriteriaConstants.REL_ID);
			ENOICriteriaUtil iCritUtil = ENOCriteriaFactory.getCriteriaUtil(context);
			iCritUtil.disConnectCriteriaOutputRel(context, relIds);
		} else if (CharacteristicMasterConstants.ADD_EXISTING_OPTIONAL_CM.equalsIgnoreCase(mode)) {
			ENOICriteria iCriteria = ENOCriteriaFactory.getCriteriaById(context, objectId);
			iCriteria.addCriteriaOutput(context, CriteriaUtil.toStringList(rowIds), false);
			
		} else if (CharacteristicMasterConstants.ADD_EXISTING_MANDATORY_CM.equalsIgnoreCase(mode)) {
			ENOICriteria iCriteria = ENOCriteriaFactory.getCriteriaById(context, objectId);
			iCriteria.addCriteriaOutput(context, CriteriaUtil.toStringList(rowIds), true);
		}
		
	} catch (Exception ex) {
		ex.printStackTrace();
		exceptionThrown = true;
		emxNavErrorObject.addMessage(ex.getLocalizedMessage());
	} 
%>

<script type="text/javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<script type="text/javaScript">
	
	var action = "<%=XSSUtil.encodeForJavaScript(context,mode)%>";
	/* XSSOK */
	var actionURL = "<%=actionURL%>";
	if (action == "delete") {
		var tabFrame = findFrame(getTopWindow(), "content");
		if (tabFrame != 'undefined' && tabFrame != null) {
			tabFrame.location.href = "../common/emxIndentedTable.jsp?table=CharacteristicMastersSummary&program=ENOCharacteristicMasterUI:getMyDeskCharacteristicMasters&selection=multiple&Export=true&toolbar=MyDeskCharacteristicMasterToolbar&header=CharacteristicMaster.Command.CharacteristicMasterListPage&rowGroupingColumnNames=CharacteristicCategory&massPromoteDemote=true&showRMB=false&suiteKey=CharacteristicMaster&StringResourceFileId=enoCharacteristicMasterStringResource&SuiteDirectory=characteristicmaster";
		} else {
			refreshTablePage();
		}		
	}
	
	//XSSOK
	var errorMsg = "<%=exceptionThrown%>";
	
	if(errorMsg == 'false') {
		
		var pageUI = "<%=XSSUtil.encodeForJavaScript(context,pageUI)%>";
		if ("RemoveCM" == action) {
			var frameName = "CriteriaCharacteristicMasters";
			var tabFrame = findFrame(getTopWindow(), frameName);
			tabFrame.location.href = tabFrame.location.href;
			
		} else if (action == "revise") {
			var frameName = ("myDesk" == pageUI) ? 'content' : 'detailsDisplay';
			var detailsFrame = findFrame(getTopWindow(), frameName);
			detailsFrame.location.href = actionURL;

		} else if ("AddExistingOptionalCM" == action || "AddExistingMandatoryCM" == action) {
			var tabFrame  = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "CriteriaCharacteristicMasters");
			tabFrame.location.href = tabFrame.location.href;
			getTopWindow().closeWindow();
		}
	}
</script>

