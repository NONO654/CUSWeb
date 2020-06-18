<%-- emxBOMFilterProcess.jsp --
   Copyright (c) 1992-2012 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<html>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<script language="Javascript">

	var defaultValue= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Command.BRFilterDefaultValue","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
	var objectID = window.parent.document.getElementById('objectId').value;
	var suiteKey = window.parent.document.getElementById('suiteKey').value;
	var sSupplierValue=defaultValue;
	var sPlugValue = defaultValue;
	var sSuppliedMaterialValue = defaultValue;
	var sStartDate = "";
	var sEndDate = "";
	var sMin1Value = "";
	var sMin2Value = "";
	var sMax1Value = "";
	var sMax2Value = "";
	try{
		
			if(window.parent.document.getElementById('DELBT_BRSuppliersFilter'))
			{
				sSupplierValue = window.parent.document.getElementById('DELBT_BRSuppliersFilter').value;
			}
			
			if(window.parent.document.getElementById('DELBT_BRPlugsFilter'))
			{
				sPlugValue = window.parent.document.getElementById('DELBT_BRPlugsFilter').value;
			}
			
			if(window.parent.document.getElementById('DELBT_BRSuppliedMaterialsFilter'))
			{
				sSuppliedMaterialValue = window.parent.document.getElementById('DELBT_BRSuppliedMaterialsFilter').value;
			}
			if(window.parent.document.getElementById('DELBT_BRStartDateFilter'))
			{
				sStartDate = window.parent.document.getElementById('DELBT_BRStartDateFilter').value;
			}
			if(window.parent.document.getElementById('DELBT_BREndDateFilter'))
			{
				sEndDate = window.parent.document.getElementById('DELBT_BREndDateFilter').value;
			}
			
			if(window.parent.document.getElementById('DELBT_BRMin1TextBox'))
			{
				sMin1Value = window.parent.document.getElementById('DELBT_BRMin1TextBox').value;
			}
			
			if(window.parent.document.getElementById('DELBT_BRMin2TextBox'))
			{
				sMin2Value = window.parent.document.getElementById('DELBT_BRMin2TextBox').value;
			}
			
			if(window.parent.document.getElementById('DELBT_BRMax1TextBox'))
			{
				sMax1Value = window.parent.document.getElementById('DELBT_BRMax1TextBox').value;
			}
			
			if(window.parent.document.getElementById('DELBT_BRMax2TextBox'))
			{
				sMax2Value = window.parent.document.getElementById('DELBT_BRMax2TextBox').value;
			}
		}catch(e){
			alert(e.toLocaleString());
	}
	if( (sMin1Value != '' && isNaN(sMin1Value)) || (sMin2Value != '' && isNaN(sMin2Value)) || ( sMax1Value != '' && isNaN(sMax1Value)) || sMax2Value != '' && isNaN(sMax2Value))
	{
		var errorMsg = "<%=i18nNow.getI18nString("emxBlendingTableCentral.Msg.EnterOnlyNumericValues","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
		alert(errorMsg);
		sMin1Value='';
		throw "stop execution";
	}
	sURL = "../common/emxIndentedTable.jsp?jsTreeID=null&toolbar=DELBT_BlendingRulesMenuToolbar,DELBT_BlendingRuleFilterToolbar,DELBT_BRDateFilterToolbar&portal=DELBT_Portal&table=DELBT_ViewBlendingRules&header=emxBlendingTableCentral.Msg.BTPropertesHeader&editLink=true&selection=multiple&portalMode=true&editLabel=Edit&DELBT_BRSuppliersFilter="+sSupplierValue+"&DELBT_BRPlugsFilter="+sPlugValue+"&DELBT_BRSuppliedMaterialsFilter="+sSuppliedMaterialValue+"&DELBT_BRStartDateFilter="+sStartDate+"&DELBT_BREndDateFilter="+sEndDate+"&DELBT_BRMin1TextBox="+ sMin1Value +"&DELBT_BRMin2TextBox="+ sMin2Value +"&DELBT_BRMax1TextBox="+ sMax1Value +"&DELBT_BRMax2TextBox="+ sMax2Value +"&subHeader=emxBlendingTableCentral.Msg.BTPropertesSubHeader&emxSuiteDirectory=blendingtablesuite&program=emxBTSearchAllBlendingRules:getAllBlendingRulesForSuppliers&objectId="+objectID+"&suiteKey=BlendingTable&SuiteDirectory=blendingtablesuite&StringResourceFileId=emxBlendingTableSuiteStringResource&portalCmdName=DELBT_SearchBlendingRules&postProcessJPO=emxBTSearchAllBlendingRules:reloadSuppAllocationForProd&startDateRangeFilter="+sStartDate+"&endDateRangeFilter="+sEndDate;
	window.parent.frames.location.href=sURL;
</script>
</html>
