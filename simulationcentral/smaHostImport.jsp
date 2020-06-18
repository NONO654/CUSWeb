<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  smaHostImport.jsp Process import command found on the Home page to 
  import host from a config file.  Puts up radio button to control
  import processing and will use the applet to choose the file if
  the user wants to pick the host config file
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants" %>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.net.URL"%>
<%@page import="matrix.util.StringList"%>
<%@ page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<html>
<%
    Locale loc = context.getLocale();
    final String locale = context.getSession().getLanguage();
    String header = SimulationUtil.getI18NString(context,
        "smaSimulationCentral.ImportHosts.Header" );

%>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css"type="text/css">
<title><%=header %></title>
</head>

 <%
     // get buttom labels and headers from resources
     String objId = "";
     String lang = context.getSession().getLanguage();
     
     String overwriteDup =  SimulationUtil.getI18NString(context,
         "smaSimulationCentral.Host.OverwriteDup");
     String skipDup =  SimulationUtil.getI18NString(context,
         "smaSimulationCentral.Host.SkipDup");
     String languageStr = request.getHeader("Accept-Language");
     String lStr = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",loc,"emxFramework.HelpDirectory");
     String helpString=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.FormComponent.Help");
     String doneLabel =  EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Button.Next"); 
     String cancelLabel =  EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Button.Cancel");      
         
     String pageHeader = SimulationUtil.getI18NString(context,
         "smaSimulationCentral.ImportHosts.Header");

     
     // build header html sting 
     StringBuilder paramHTML = new StringBuilder(100);
     StringBuilder headerHTML = new StringBuilder(100);
     headerHTML.append("<div id=\"pageHeadDiv\"> ");
     headerHTML.append("<TABLE> <TR> <TD class=\"page-title\"> <h2>");
     headerHTML.append(pageHeader).append("</h2></TD> </TR>");
     headerHTML.append(" </TABLE></div> "); 
     
     // build help button html this will be placed in the toolbar
     StringBuilder helpHTML = new StringBuilder(100);
     helpHTML.append("<TD><a href=\"javascript:openHelp('");
     helpHTML.append("SMAHost_HomeImport"); // help marker
     helpHTML.append("', '");
     helpHTML.append("SimulationCentral" ); // suite
     helpHTML.append("', '");
     helpHTML.append(lStr); //language
     helpHTML.append("')\"><img  src=\"../common/images/iconActionHelp.gif\" alt=\" " );
     helpHTML.append(helpString);
     helpHTML.append("\" style=\"{border: 0; vertical-align: middle; margin-left: 5;}\" ></a></TD>");
     
     // build toolbar html which will contain help button
     StringBuilder toolBarHTML = new StringBuilder(100);
     toolBarHTML.append("<TABLE bgcolor=\"#E0E0E0\" ");
     toolBarHTML.append("border=\"1px\"  ");
     toolBarHTML.append("width=\"100%\" ");
     toolBarHTML.append("cellspacing=\"0\" cellpadding=\"0\">");
     toolBarHTML.append("<TR> <TD><TABLE ><TR valign=\"bottom\">");
     String endToolBarHTML = "</TR></TABLE></TD></TR> </TABLE>";
     
     paramHTML.append(headerHTML.toString());
     paramHTML.append(toolBarHTML.toString());
     paramHTML.append(helpHTML.toString());
     paramHTML.append(endToolBarHTML);
     
 %>

<body style ="margin: 0px; padding: 0px;" >
<script language="JavaScript">
<!--
// This will resize the window when it is opened or
// refresh/reload is clicked to a width and height of 450 x 200
if(navigator.appName == "Microsoft Internet Explorer")
{
   window.resizeTo(450,200)
} else 
{
   window.resizeTo(450,250)
}
-->
</script>
<script language="javascript">
function doSubmit()
{
    objForm = document.forms["paramInputForm"];
    objForm.submit();
}
</script>

<%=paramHTML.toString()%>
<form name="paramInputForm" action="smaImportFileUtil.jsp" method="get">
<div style= "margin: 5px; padding: 5px;">
<INPUT TYPE=hidden NAME=objectId VALUE=<%=objId%>>
<INPUT TYPE=hidden NAME=objectAction VALUE="hostImport">
<input name="overwriteDuplicates" type="radio" VALUE="overwriteDuplicates" checked > <%=overwriteDup%><br>
<input name="overwriteDuplicates" type="radio" VALUE="skipDuplicates"  > <%=skipDup%>
</div>
<br>
<br>
<div id="divPageFoot">
<table >
<tr>
<td class="functions"></td>
<td class="buttons">
    <table>
<tr>
<td><a href="javascript:;" onClick="javascript:doSubmit()"><img src="../common/images/buttonDialogDone.gif"" border="0" alt="<%=doneLabel%>"></a></td>
<td><a href="javascript:;" onClick="javascript:doSubmit()" class="button"><%=doneLabel%></a></td>
<td><a href="javascript:getTopWindow().closeWindow();"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="<%=cancelLabel%>"></a></td>
<td><a href="javascript:getTopWindow().closeWindow();" class="button"><%=cancelLabel%></a></td>
</tr>
</table>
</td>
</tr>
</table>
</div>
</form> 
</body>
</html>



