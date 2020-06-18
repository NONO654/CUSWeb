<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />
<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
	var compareResultsFrms = new Array();
	compareResultsFrms[0] = "AEFSCCompleteSummaryResults";
	compareResultsFrms[1] = "AEFSCDifferenceOnlyReport";
	compareResultsFrms[2] = "AEFSCCompareCommonComponents";
	compareResultsFrms[3] = "AEFSCBOM1UniqueComponentsReport";
	compareResultsFrms[4] = "AEFSCBOM2UniqueComponentsReport";
	
	function getCompareResultsFrameName() {
		for(var counter=0; counter < compareResultsFrms.length; counter++) {
			if(getTopWindow().findFrame(getTopWindow(), compareResultsFrms[counter]).frameElement.parentElement.style.display == "") {
				return compareResultsFrms[counter];
			}
		}
	}
	
	var sbReference = getTopWindow().findFrame(getTopWindow(), getCompareResultsFrameName());
	var oXML		= sbReference.oXML;
	
	if(typeof oXML != 'undefined' && oXML != null) {
		var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '0']");
	    
		var objectId1	= rowNode.getAttribute("o");
	    var objectId2	= rowNode.getAttribute("o2");
	    
		document.location.href = "../components/emxLaunch3DPlayCheck.jsp?3DCompare=true&objectId1="+objectId1+"&objectId2="+objectId2;
	} else {
		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.3DPlay.NoCompareResultsFound</emxUtil:i18nScript>");
	}
</script>
</head>

</html>
