<%-- emxFormViewHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormEditHeader.jsp.rca 1.22 Wed Oct 22 15:48:47 2008 przemek Experimental przemek $
--%>
<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxFormConstantsInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%
try
{
    String objectId = emxGetParameter(request, "objectId");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String form = emxGetParameter(request, "form");
    String title_prefix = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.WindowTitle.Header", request.getLocale());
 	String title = title_prefix + XSSUtil.encodeForHTML(context, form);

    String relId = emxGetParameter(request, "relId");
    String originalHeader =emxGetParameter(request, "originalHeader");
    String header = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, request.getHeader("Accept-Language"));
   String languageStr = request.getHeader("Accept-Language");
    String findMxLink = emxGetParameter(request, "findMxLink");
    String toolbar = emxGetParameter(request, "toolbar");
    

    String timeStamp = emxGetParameter(request, "timestamp");
    String HelpMarker = emxGetParameter(request, "HelpMarker");

    if ( (HelpMarker == null) || (HelpMarker.equalsIgnoreCase("null")) || (HelpMarker.trim().length() == 0) )
        HelpMarker = "";

    String suiteDir = "";
    String registeredSuite = suiteKey;
    String stringResFileId = "emxFrameworkStringResource";

    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
    {
        registeredSuite = suiteKey.substring(13);
    }

    if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
    {
         suiteDir = UINavigatorUtil.getRegisteredDirectory(context, registeredSuite);

    }

    String strLanguage = request.getHeader("Accept-Language");
	String subHeader = emxGetParameter(request, "subHeader");
	if ( (subHeader != null) && (subHeader.trim().length() > 0) ) {
		subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, strLanguage);
	}
%>


<head>
<!-- //XSSOK -->
<title><%=title%></title>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>

<script type="text/javascript">
        addStyleSheet("emxUIToolbar");
        addStyleSheet("emxUIMenu");
</script>
<script type="text/javascript">
	window.onscroll = function(){document.body.scrollTop = 0};
</script>
<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
<script language="javascript" src="scripts/emxNavigatorHelp.js"></script>
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>


</head>
<body>
<table border="0" cellspacing="2" cellpadding="0" width="100%">
<tr>
<td width="99%">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
		<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
	</tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
	<td width="1%" nowrap><span class="pageHeader" nowrap>&nbsp;<%=header%></span>
<%
        if (subHeader != null && subHeader.length() > 0 )
        {
            %><br/><span class="pageSubTitle">&nbsp;<xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></span><%
        }
%>
</td>
<%
         String progressImage = "../common/images/utilProgressBlue.gif";
         String processingText = UINavigatorUtil.getProcessingText(context, languageStr);  
 %> 
 <!-- //XSSOK -->
 <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>
	<td width="1%"><img src="images/utilSpacer.gif" width="1" height="25" alt="" vspace="6" /></td>
</tr>
</table>

</td></tr></table>
<!-- //XSSOK -->
<jsp:include page = "emxToolbar.jsp" flush="true"> <jsp:param name="toolbar" value="<%=toolbar%>"/> <jsp:param name="objectId" value="<%=objectId%>"/> <jsp:param name="relId" value="<%=relId%>"/> <jsp:param name="parentOID" value="<%=objectId%>"/> <jsp:param name="timeStamp" value="<%=timeStamp%>"/> <jsp:param name="editLink" value="false"/> <jsp:param name="header" value="<%=header%>"/> <jsp:param name="PrinterFriendly" value="false"/> <jsp:param name="export" value="false"/> <jsp:param name="uiType" value="form"/> <jsp:param name="form" value="<%=form%>"/> <jsp:param name="helpMarker" value="<%=HelpMarker%>"/> <jsp:param name="suiteKey" value="<%=registeredSuite%>"/> <jsp:param name="findMxLink" value="<%=findMxLink%>"/>
</jsp:include>

</body>
<%
} catch (Exception ex) {
	if(ex.toString()!=null && (ex.toString().trim()).length()>0)
		emxNavErrorObject.addMessage("emxFormEditHeader:" + ex.toString().trim());
}
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
