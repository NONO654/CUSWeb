
<%--  emxEngrMEPUsage.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<script language="JavaScript" type="text/javascript" src="../common/emxUIConstantsJavaScriptInclude.jsp"></script>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>
<%@page import="matrix.db.Context"%>


<%
  	HashMap paramMap = new HashMap();

	String objectSelected = "true";
	String strMEPId = emxGetParameter(request,"objectId");
	String strAction = emxGetParameter(request, "MEPActions");
	String strParentOID = emxGetParameter(request, "parentOID");
  	String[] sColumnId = emxGetParameterValues(request,"emxTableRowId");
  	String languageStr = request.getHeader("Accept-Language");
  	String strSelectAnItem = null;
  	
  	if ( ("RemoveSubstitute".equals(strAction) || "DefineSubstitute".equals(strAction) ) && ( sColumnId == null || sColumnId.length < 1) ) {
  		strSelectAnItem = i18nStringNowUtil("emxFramework.Common.PleaseSelectitem", "emxFrameworkStringResource", languageStr);
  		objectSelected = "false";
  	}
  	
  	else {
		try {
			
	    	paramMap.put("parentId", sColumnId);
	 		paramMap.put("objectId", strMEPId);
	 		paramMap.put("action", strAction);
	 		paramMap.put("parentOID", strParentOID);
	 	
	 		boolean isMBOMInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMManufacturing",false,null,null);
	 		if(isMBOMInstalled)
	 			JPO.invoke(context, "emxMBOMPart", null, "modifyUsageForMEP", JPO.packArgs(paramMap));
	 		else
	         	JPO.invoke(context, "emxMEPAltSubExtention", null, "modifyUsageForMEP", JPO.packArgs(paramMap));
		}
		catch(Exception e) {
			  session.putValue("error.message",e.toString());
		}	
  	}

%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript">
    <%--XSSOK--%>
    if ( "<%= objectSelected %>" == "true" ) {
    		if("DefineAlternate" == "<xss:encodeForJavaScript><%=strAction%></xss:encodeForJavaScript>" || "DefineSubstitute" == "<xss:encodeForJavaScript><%=strAction%></xss:encodeForJavaScript>" || "ModifyUsage" == "<xss:encodeForJavaScript><%=strAction%></xss:encodeForJavaScript>" || "RemoveSubstitute" == "<xss:encodeForJavaScript><%=strAction%></xss:encodeForJavaScript>"){
			
			getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
			getTopWindow().closeWindow();
		}
		else{
			parent.location.href = parent.location.href;
		}
    }
    
    else {
    	//XSSOK
    	alert ("<%= strSelectAnItem %>");
    	
    	var fullSearchReference = findFrame(getTopWindow(), "content");
    	
    	if (fullSearchReference != null) { fullSearchReference.setSubmitURLRequestCompleted(); }
    }
 			
</script>


