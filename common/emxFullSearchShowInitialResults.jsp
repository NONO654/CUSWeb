<%--  emxFullSearchShowInitialResults.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFullSearchShowInitialResults.jsp.rca 1.3.2.2.1.1 Wed Oct 22 15:48:20 2008 przemek Experimental przemek $

--%>
<%@include file="emxNavigatorInclude.inc"%>
<html>
<head>

<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxUIConstantsInclude.inc"%>
<%String displayMessage = "Please select the criteria to begin search";
            String searchMode = emxGetParameter(request, "viewFormBased");
            String queryType = emxGetParameter(request, "queryType");
            String strLanguage =request.getHeader("Accept-Language");

            if ("Real Time".equalsIgnoreCase(queryType)) {
                displayMessage = UINavigatorUtil
                		.getI18nString(
                        "emxFramework.FullTextSearch.SelectCriteriaMessage.RealTime",
                        "emxFrameworkStringResource", strLanguage);
            }else if ("true".equalsIgnoreCase(searchMode)) {
                displayMessage = UINavigatorUtil
                        .getI18nString(
                                "emxFramework.FullTextSearch.SelectCriteriaMessage.FormBasedView",
                                "emxFrameworkStringResource", strLanguage);
            } else {
                displayMessage = UINavigatorUtil
                        .getI18nString(
                                "emxFramework.FullTextSearch.SelectCriteriaMessage.NavigationView",
                                "emxFrameworkStringResource", strLanguage);
            }
            StringBuffer qStringBuff = new StringBuffer();
            Enumeration eNumParameters = emxGetParameterNames(request);
            while( eNumParameters.hasMoreElements() ) {
                String parmName = (String)eNumParameters.nextElement();
                String parmValue = (String)emxGetParameter(request,parmName);
                if("columnMap".equals(parmName)|| "fieldValues".equals(parmName)|| "field".equals(parmName)|| "field_actual".equals(parmName)){
                	continue;
                }
                qStringBuff.append(XSSUtil.encodeForURL(context, parmName));
                qStringBuff.append("=");
                qStringBuff.append(XSSUtil.encodeForURL(context, parmValue));
                if(eNumParameters.hasMoreElements()){
                    qStringBuff.append("&");
                }
            }
            
            String strHelpMarker = emxGetParameter(request, "HelpMarker");
            if (UIUtil.isNullOrEmpty(strHelpMarker)) {
                strHelpMarker = "emxhelpfullsearch";
            }
%>
<script type="text/javascript" language="javascript">
function doOnLoad(){
	if(getTopWindow().FullSearch){
		getTopWindow().FullSearch.setResultsCount(getTopWindow().FullSearch.getNoCountsThreshold()+1);
	} else if(parent.FullSearch) {
		parent.FullSearch.setResultsCount(parent.FullSearch.getNoCountsThreshold()+1);
	}
}
function resetCount(){
	if(getTopWindow().FullSearch){
		getTopWindow().FullSearch.setResultsCount(null);
	} else if(parent.FullSearch) {
		parent.FullSearch.setResultsCount(null);
	}
}
</script>
<title>Untitled</title>
<link rel="stylesheet" href="styles/emxUIDefault.css"></link>
<link rel="stylesheet" href="styles/emxUIToolbar.css"></link>
<link rel="stylesheet" href="styles/emxUIMenu.css"></link>
<link rel="stylesheet" href="styles/emxUIFullSearch.css"></link>
<script src="scripts/emxUIConstants.js" type="text/javascript"></script>
<script src="emxFormConstantsJavascriptInclude.jsp" type="text/javascript"></script>
<script src="emxJSValidation.jsp" type="text/javascript"></script>
<script src="scripts/emxJSValidationUtil.js" type="text/javascript"></script>
<script src="scripts/emxUIModal.js" type="text/javascript"></script>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<script src="scripts/emxUICoreMenu.js" type="text/javascript"></script>
<script src="scripts/emxUIToolbar.js" type="text/javascript"></script>
<script src="scripts/emxNavigatorHelp.js" type="text/javascript"></script>
<script src="scripts/emxUIPopups.js" type="text/javascript"></script>
<script src="scripts/emxUICreate.js" type="text/javascript"></script>
<script src="scripts/emxUICalendar.js" type="text/javascript"></script>
<script src="scripts/emxUIFormUtil.js" type="text/javascript"></script>
<script src="scripts/emxTypeAhead.js" type="text/javascript" ></script>
<script src="scripts/emxUITableUtil.js" type="text/javascript" ></script>
<!-- //XSSOK -->
<script language="JavaScript" src="../common/emxToolbarJavaScript.jsp?printerFriendly=false&objectCompare=false&export=false&timeZone=-5.5&HelpMarker=<%=XSSUtil.encodeForURL(context, strHelpMarker)%>&<%=qStringBuff.toString()%>" type="text/javascript"></script>
</head>
<body onload="doOnLoad()" onunload="resetCount();" class="root">
<div id="divToolbarContainer" class="toolbar-container">
	<div id="divToolbar" class="toolbar-frame"></div>
</div>
<div id="splashTopGradient">&nbsp;</div>
<div id="splashWrapper">
	<div id="splashArea"><%=displayMessage%></div>
</div>
</body>
</html>

