<%-- FilterChooserIntermediate.jsp --
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.unresolvedebom.CFFUtil"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUtil"%>

<%
String objectId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "objectId"));
String cmdName = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"cmdName"));

Locale Local = context.getLocale();
String sMultiplefilterselectedError  = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.Confirm.MultipleFilterSelectedMessage");
String sPCfilterselectedError  = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.Confirm.PCFilterSelectedMessage");

%>
<script language="Javascript">

var changeEffectivity = getTopWindow().document.getElementById("PUEUEBOMECOFilter");
var changeEffectivityValue=(changeEffectivity != null && changeEffectivity != undefined && changeEffectivity != "") ? changeEffectivity.value:"";
var pcEffectivity = getTopWindow().document.getElementById("PUEUEBOMProductConfigurationFilter");
var pcEffectivityValue=(pcEffectivity != null && pcEffectivity != undefined && pcEffectivity != "") ? pcEffectivity.value:"";
var filterEffectivity = getTopWindow().document.getElementById("CFFExpressionFilterInput");
var filterEffectivityValue=(filterEffectivity != null && filterEffectivity != undefined && filterEffectivity != "") ? filterEffectivity.value:"";
var cmdName="";
var sURL="";

<%
	if ( "PUEUEBOMECOFilter".equalsIgnoreCase(cmdName) ) {
%>
        cmdName="<%=cmdName%>";
    	sURL ="../common/emxFullSearch.jsp?field=TYPES=type_ChangeAction&txtPolicy=policy_ChangeAction&includeOIDprogram=enoConfiguredBOM:getProposedChangeActionIds&table=PUEECOSearchTable&showInitialResults=false&selection=multiple&toolbar=ENCFullSearchToolbar&submitAction=refreshCaller&submitURL=../unresolvedebom/SearchUtil.jsp&fieldNameActual=PUEUEBOMECOFilter_actualValue&fieldNameDisplay=PUEUEBOMECOFilter&mode=Chooser&chooserType=ECOChooser&sortColumnName=Name&portalMode=false&expandProgram=false&isIndentedView=false&expandLevelFilter=false&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
    	if(pcEffectivityValue!= ""){
    		<%-- alert("<%=sPCfilterselectedError%>"); --%>
    		if(confirm("<%=sPCfilterselectedError%>")){
    			pcEffectivity.value="";
    		}
    		else
    			sURL="";
    	}	
<%
	}

	else if ( "ChangeAction".equalsIgnoreCase(cmdName) ) {
%>
		sURL="../common/emxFullSearch.jsp?field=TYPES=type_ChangeAction:CURRENT=policy_ChangeAction.state_InWork&txtPolicy=policy_ChangeAction&table=PUEUEContextChangeSearchTable&showInitialResults=false&includeOIDprogram=enoConfiguredBOM:getProposedChangeActionIds&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&selection=single&submitAction=refreshCaller&submitURL=../unresolvedebom/SearchUtil.jsp&fieldNameActual=PUEUEBOMContextChangeFilter_actualValue&fieldNameDisplay=PUEUEBOMContextChangeFilter&mode=Chooser&chooserType=CustomChooser&sortColumnName=Name&portalMode=false&expandProgram=false&isIndentedView=false&showSavedQuery=True&searchCollectionEnabled=True";
<%
	}

	else if ( "PUEUEBOMProductConfigurationFilter".equalsIgnoreCase(cmdName) ) {
		String fromPartWhereUsed = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "partWhereUsed"));
		String whereUsedappepURL = ("true".equals(fromPartWhereUsed)) ? "" : "&includeOIDprogram=emxUnresolvedPart:getConfigurationContextPCIds";
%>
        cmdName="<%=cmdName%>";
		sURL ="../common/emxFullSearch.jsp?field=TYPES=type_ProductConfiguration:CURRENT=policy_ProductConfiguration.state_Preliminary,policy_ProductConfiguration.state_Active&txtPolicy=policy_ProductConfiguration&table=PUEECOSearchTable&showInitialResults=false&selection=single&toolbar=ENCFullSearchToolbar&submitAction=refreshCaller&submitURL=../unresolvedebom/SearchUtil.jsp&fieldNameActual=PUEUEBOMProductConfigurationFilter_actualValue&fieldNameDisplay=PUEUEBOMProductConfigurationFilter&mode=Chooser&chooserType=ECOChooser&sortColumnName=Name&portalMode=false&expandProgram=false&isIndentedView=false&expandLevelFilter=false&objectId=<%=objectId%>&<%=whereUsedappepURL%>";
		if(changeEffectivityValue != "" ||  filterEffectivityValue != ""){
			//getTopWindow().close();
			<%-- alert("<%=sMultiplefilterselectedError%>"); --%>
			if(confirm("<%=sMultiplefilterselectedError%>")){
				changeEffectivity.value="";
				filterEffectivity.value="";
				getTopWindow().document.getElementById('CFFExpressionFilterInput_actualValue').value = "";
			}
			else
				sURL="";
		}

<%
	}

	if ( "AddExistingConfigurationContext".equals(cmdName) ) {
		String selectedRowIds[] = emxGetParameterValues(request, "emxTableRowId");
		
		StringList selectObjectIds = BOMMgtUtil.getListFromSelectedTableRowIds(selectedRowIds, 1);
		
		String selectedObjectId = (String) selectObjectIds.get(0);
		
		String searchTypes = CFFUtil.getConfigurationContextSearchTypes(context, selectedObjectId);
%>
		//XSSOK
		sURL = "../common/emxFullSearch.jsp?field=TYPES=<%=searchTypes%>&excludeOIDprogram=emxEffectivityFramework:excludeConnectedConfigCtxObjects&objectId=<xss:encodeForJavaScript><%=selectedObjectId%></xss:encodeForJavaScript>&table=CFFConfigurationContext&selection=multiple&showInitialResults=false&submitURL=../unresolvedebom/SearchUtil.jsp?mode=ConfigurationContext";		
<%
	}
%>
    //window.location.href = sURL;
     if(sURL !="")
    showModalDialog(sURL,"570","570","true"); 
</script>
