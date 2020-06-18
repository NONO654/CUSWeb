<%-- emxFormViewHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormViewHeader.jsp.rca 1.35 Wed Oct 22 15:47:58 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
String form = emxGetParameter(request, "form");
String title_prefix = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.WindowTitle.Header", request.getLocale());
String title = title_prefix + form;
%>

<head>

<title><xss:encodeForHTML><%=title%></xss:encodeForHTML></title>

<%@include file = "emxFormConstantsInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStylePropertiesInclude.inc"%>

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
<script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>

</head>

<%
try {

    ContextUtil.startTransaction(context, false);
    String actionBar = emxGetParameter(request, "actionBarName");
    String toolbar = emxGetParameter(request, "toolbar");
    String editLink = emxGetParameter(request, "editLink");
    String objectId = emxGetParameter(request, "objectId");
    String treeUpdate = emxGetParameter(request, "treeUpdate");
    String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");

    String relId = emxGetParameter(request, "relId");
    String mode = emxGetParameter(request, "mode");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String originalHeader = emxGetParameter(request, "originalHeader");
    
    String header = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, request.getHeader("Accept-Language"));
    String subHeader = emxGetParameter(request, "subHeader");

    String timeStamp = emxGetParameter(request, "timeStamp");

    String HelpMarker = emxGetParameter(request, "HelpMarker");
    String tipPage = emxGetParameter(request, "TipPage");
    String printerFriendly = emxGetParameter(request, "PrinterFriendly");
    String export = emxGetParameter(request, "Export");
    String findMxLink = emxGetParameter(request, "findMxLink");

    if ( (HelpMarker == null) || (HelpMarker.equalsIgnoreCase("null")) || (HelpMarker.trim().length() == 0) )
    {
        HelpMarker = "";
    }

    String languageStr = request.getHeader("Accept-Language");
    if ( (subHeader != null) && (subHeader.trim().length() > 0) ) {
            subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, languageStr);
    }

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
%>
<body class="head">
<form method="post">
<div id="pageHeadDiv">
   <table>
     <tr>
      <td class="page-title">
        <h2><xss:encodeForHTML><%=header%></xss:encodeForHTML></h2>
<%
        if(subHeader != null && !"".equals(subHeader)) {
%>
            <h3><xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></h3>
<%
        } 
%>
      </td>
                <%
                    String progressImage = "../common/images/utilProgressBlue.gif";
                    String processingText = UINavigatorUtil.getProcessingText(context, languageStr);    
                %>                
        <td class="functions">
            <table><tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
            </tr></table>
        </td>
        </tr>
        </table>                
<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
    <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
    <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
    <jsp:param name="editLink" value="<%=XSSUtil.encodeForURL(context, editLink)%>"/>
    <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/>
    <jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, printerFriendly)%>"/>
    <jsp:param name="export" value="<%=XSSUtil.encodeForURL(context, export)%>"/>
    <jsp:param name="uiType" value="form"/>
    <jsp:param name="form" value="<%=XSSUtil.encodeForURL(context, form)%>"/>
    <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, HelpMarker)%>"/>
    <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/>
    <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, registeredSuite)%>"/>
    <jsp:param name="topActionbar" value="<%=XSSUtil.encodeForURL(context, actionBar)%>"/>
     <jsp:param name="findMxLink" value="<%=XSSUtil.encodeForURL(context, findMxLink)%>"/>

</jsp:include>
</div>
<%
    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            emxNavErrorObject.addMessage("emxFormViewHeader:" + ex.toString().trim());

    } finally {
        ContextUtil.commitTransaction(context);
    }
%>
</form>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>

</html>

