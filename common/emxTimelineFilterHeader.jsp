<%-- emxTimelineFilterHeader.jsp
        
        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.
        This program contains proprietary and trade secret information of MatrixOne, 
        Inc.
        Copyright notice is precautionary only and does not evidence any actual or 
        intended publication of such program.

        static const char RCSID[] = $Id: emxTimelineFilterHeader.jsp.rca 1.6 Wed Oct 22 15:48:22 2008 przemek Experimental przemek $
 --%>

<html>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<head>
<title>
</title>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>

  <script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUICoreMenu.js"></script>

  <script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
  <script type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>

<script type="text/javascript">
  addStyleSheet("emxUIToolbar");
  addStyleSheet("emxUIMenu");
  //Begin of Add by Infosys for Bug 311760 on 12/1/2005
<%
  String suiteKey = emxGetParameter(request, "suiteKey");
  //Modified Help url for IR-045929V6R2011 STARTS
  String strHelpURL = "../doc/"+XSSUtil.encodeForURL(context, suiteKey.toLowerCase())+"/"+langStr+"/ENOHelp.htm?context="+XSSUtil.encodeForURL(context, suiteKey.toLowerCase())+"&topic=emxhelptimelinefilter";
  //Modified Help url for IR-045929V6R2011 ENDS
%>
  objToolbar = new emxUIToolbar(emxUIToolbar.MODE_FRAMES);
  //XSSOK
  objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", "<emxUtil:i18n localize="i18nId">emxFramework.Roadmap.Button.Help</emxUtil:i18n>","javascript:window.open(\"<%=strHelpURL%>\",'helpwin','location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes')"));
  //End of Add by Infosys for Bug 311760 on 12/1/2005
</script>

</head>

<%

String header = emxGetParameter(request, "header");
String sHelpMarker = "emxhelpfiltercolumns";
String commonDir = EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.CommonDirectory");
StringBuffer help = new StringBuffer();
String helpHTML = "";

try {
    help.append("<a href=\"javascript:openHelp('");
    help.append(sHelpMarker);
    help.append("', '");
    help.append(commonDir);
    help.append("', '");
    help.append(langStr);
    help.append("')\">");
    help.append("<img src=\"../common/images/buttonContextHelp.gif\" alt=\"Help\" border=\"0\" />");
    help.append("</a>");
    
    helpHTML = help.toString();

if(header == null || header.length() == 0){
    header = "emxFramework.Roadmap.Filter.Header";
}
}catch (Exception ex){
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}
%>
<body onload="toolbars.init('divToolbar')">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
    <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
</tr>
</table>
<table border="0" width="100%" cellspacing="2" cellpadding="2">
<tr>
    <td width="1%" nowrap><span class="pageHeader"><emxUtil:i18n localize="i18nId"><xss:encodeForHTML><%=header%></xss:encodeForHTML></emxUtil:i18n></span></td>
    <td><img src="../common/images/utilProgressBlue.gif" width="34" height="28" name="imgProgressDiv" id="imgProgressDiv" /></td>
    <td width="1%"><img src="images/utilSpacer.gif" width="1" height="32" alt="" /></td>
</tr>
</table>
<div class="toolbar-container"><div id="divToolbar" class="toolbar-frame"></div></div>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
