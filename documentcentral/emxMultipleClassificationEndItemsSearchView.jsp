<%-- emxMultipleClassificationEndItemsSearchView.jsp
   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc. Copyright notice is precautionary only and does not
   evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxMultipleClassificationEndItemsSearchView.jsp.rca 1.2.3.2 Wed Oct 22 16:02:15 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.classification.*"%>

<html>
<head>
<title>Search</title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script type="text/javascript" language="javascript" src="../common/scripts/emxUICalendar.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIPopups.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICalendar.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxSearchGeneral.js"></script>
<script language = "javascript" type = "text/javascript" src = "../documentcentral/emxDocumentUtilities.js"></script>
</head>
<body onload="doLoad(), turnOffProgress(), getTopWindow().loadSearchFormFields()">
<form name="SearchForm" method="post" id="SearchForm" onSubmit="doSubmit(); return false">


<%@include file="../documentcentral/emxLibraryCentralClassifiedItemsSearchBasicAttributes.inc"%>
<%@include file="../documentcentral/emxLibraryCentralClassifiedItemsSearchTypeAtttributes.inc"%>

<% 
String RDO = emxGetParameter(request, "RDO");
%>
<table width="100%">
<tr>
<td>
<!--Type names selected by the user will be passed as selectedTypes param to the following include page.
    This attribute is used by the include page to decide whether to display "And" & "Or" radio buttons-->

<jsp:include page="../documentcentral/emxMultipleClassificationClassifiedItemsSearchAttributeGroups.jsp" flush="true">
<jsp:param name="derivedOrDerivative" value="true" />
<jsp:param name="selectedTypes" value="<%=childTypeName%>" />
<jsp:param name="selectedRDO" value="<%=RDO%>" />
</jsp:include>
</td>
</tr>
<tr>
<td>&nbsp;</td>
</tr>
<tr>
<td>
<img src="../common/images/utilSearchPlus.gif" width="15" height="15" align="texttop" border="0" id="imgChildMore"><a href="#" onclick="javascript:toggleChildMore();"><emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.More</emxUtil:i18n></a>
<div id="divChildMore" style="display:none"></div>
</td>
</tr>

</table>
<input type="hidden" name="timeZone" value="<xss:encodeForHTMLAttribute><%=session.getValue("timeZone")%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="reqLocaleLang" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getLanguage()%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="reqLocaleCty" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getCountry()%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="reqLocaleVar" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getVariant()%></xss:encodeForHTMLAttribute>" />
</form>

</body>
<script>
    var showingChildAttributeSearch = false;
    function getChildAttributeSearch(objDiv){

        if(!showingChildAttributeSearch){
            var url = "../documentcentral/emxMultipleClassificationClassifiedItemsSearchAttributeGroups.jsp?derivedOrDerivative=false&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&selectedTypes=<xss:encodeForJavaScript><%=childTypeName%></xss:encodeForJavaScript>&RDO=<xss:encodeForJavaScript><%=RDO%></xss:encodeForJavaScript>";
            //Following if block checks whether "And" & "Or" radio buttons are displayed or not, 
            //if not then it will append andOrFieldDisplayed=true parameter to notify above jsp page to diplay the radio buttons
            if(document.all.AdditionAttributes)
            {
                url = url + "&andOrFieldDisplayed=true";
            }

            var myXMLHTTPRequest = emxUICore.createHttpRequest();
            myXMLHTTPRequest.open("GET", url, false);
            myXMLHTTPRequest.send(null);
            objDiv.innerHTML = myXMLHTTPRequest.responseText;

            if(document.forms[0].noChildAttributes && document.forms[0].noChildAttributes.value=="true")
            {
                alert("<emxUtil:i18n localize="i18nId">emxLibraryCentral.SearchIn.NoAttributeGroups</emxUtil:i18n>");
                return false;
            }
        }
        return true;
    }
    function toggleChildMore() {
        var objDiv = document.getElementById("divChildMore");
        if(getChildAttributeSearch(objDiv)){
            var imgMore = document.getElementById("imgChildMore");
            var theForm = document.forms[0];

            objDiv.style.display = (objDiv.style.display == "none" ? "" : "none");
            imgMore.src = (objDiv.style.display == "none" ? "../common/images/utilSearchPlus.gif" : "../common/images/utilSearchMinus.gif");
            showingChildAttributeSearch = (objDiv.style.display == "none" ? false : true);
            //if div is closed clear it
            if(!showingChildAttributeSearch){
                objDiv.innerHTML = "";
            }
            updateRedundantFields();
        }
    }
</script>
</html>


