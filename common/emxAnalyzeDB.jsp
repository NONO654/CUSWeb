<%--  emxAnalyzeDB.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxAnalyzeDB.jsp.rca 1.5.2.1 Fri Nov  7 09:35:07 2008 ds-kvenkanna Experimental $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>
<head>

<%@page import  ="com.matrixone.apps.domain.util.MqlUtil"%>

<title><emxUtil:i18n localize="i18nId">emxFramework.AdminTool.AnalyzeDB</emxUtil:i18n></title>

<script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
<%@include file = "emxUIConstantsInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
<%

String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

try
{
   boolean isPrinterFriendly = false;
   String printerFriendly = emxGetParameter(request, "PrinterFriendly");

   String lang = request.getHeader("Accept-Language");
   Hashtable analyzeData = FrameworkUtil.getAnalyzeDBData(context, lang);
   StringList filterKeys = (StringList)analyzeData.get("Keys");

   String systemFilter      = (String)filterKeys.get(0);
   String coreFilter        = (String)filterKeys.get(1);
   String aefFilter         = (String)filterKeys.get(2);
   String integrationFilter = (String)filterKeys.get(3);
%>
<script language="JavaScript">
   var printDialog = null;
   // Call printer friendly page
   function openPrinterFriendlyPage()
   {
    strURL = "";
    var strFilterit="";
    var filteringValue="";
    currentURL = document.location.href;

    if (currentURL.indexOf("?") == -1)
    {
      strURL = currentURL + "?PrinterFriendly=true";
    }
    else
    {
      strURL = currentURL + "&PrinterFriendly=true";
    }
    iWidth = "700";
    iHeight = "600";
    bScrollbars = true;

    //make sure that there isn't a window already open
    if (!printDialog || printDialog.closed)
    {
      //build up features string
      var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=yes";

      //calculate center of the screen
      var winleft = parseInt((screen.width - iWidth) / 2);
      var wintop = parseInt((screen.height - iHeight) / 2);

      if (isIE)
        strFeatures += ",left=" + winleft + ",top=" + wintop;
      else
        strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;

      strFeatures +=  ",toolbar=yes";

      //are there scrollbars?
      if (bScrollbars) strFeatures += ",scrollbars=yes";

      //open the window
      printDialog = window.open(strURL, "printDialog" + (new Date()).getTime(), strFeatures);

      //set focus to the dialog
      printDialog.focus();

    }
    else
    {
      if (printDialog)
      {
        printDialog.focus();
      }
    }
  }
<%
  if ((printerFriendly != null) &&
      (!"null".equals(printerFriendly)) &&
      (!"".equals(printerFriendly)))
  {
    isPrinterFriendly = "true".equals(printerFriendly);
%>
	addStyleSheet("emxUIDefaultPF");
    addStyleSheet("emxUIListPF");
    addStyleSheet("emxUIPropertiesPF");
	addStyleSheet("emxUIPF");
 <%
   } else {
 %>
	addStyleSheet("emxUIDefault");
  	addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIDOMLayout");
    addStyleSheet("emxUIMenu");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIForm");
    addStyleSheet("emxUIProperties");
<%
  }
%>
</script>

</head>
<body onload="turnOffProgress();" class="no-footer">
<%
if (!isPrinterFriendly)
{
%>
<div id="pageHeadDiv" >
<%
}
String progressImage = "images/utilProgressBlue.gif";
String languageStr = request.getHeader("Accept-Language");
String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
%>
      <table>
       <tr>
      <td class="page-title">
        <h2><emxUtil:i18n localize="i18nId">emxFramework.AdminTool.AnalyzeDBPage</emxUtil:i18n></h2>
      </td>
	    <td class="functions">
	        <table>
	            <tr>
	                <!-- //XSSOK -->
	                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
				</tr>
			</table>
		</td>
	</tr>
	</table>
<%
if (!isPrinterFriendly)
{
%>
  <jsp:include page = "emxToolbar.jsp" flush="true">
      <jsp:param name="export" value="false"/>
      <jsp:param name="helpMarker" value="emxhelpdbanalysis"/>
  </jsp:include>
<%
}
%>
<%
if (!isPrinterFriendly)
{
%>
</div>
<div id="divPageBody">
<%
}
%>
<table width="100%">
  <tr>
     <!-- //XSSOK -->
     <td class="heading1"><%=systemFilter%></td>
  </tr>
</table>

<table class="list">
  <tr>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.MatrixComponent</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.Detected</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.Comment</emxUtil:i18n></th>
  </tr>
  <tr class="odd">
    <td><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.LCD</emxUtil:i18n></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("LCDFound")%></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("LCD")%></td>
  </tr>
  <tr class="even">
    <td><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.Adaplet</emxUtil:i18n></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("AdapletFound")%></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("Adaplet")%></td>
  </tr>
  <tr class="odd">
    <td><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.FCS</emxUtil:i18n></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("FCSFound")%></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("FCS")%></td>
  </tr>
  <tr class="even">
    <td><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.Replication</emxUtil:i18n></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("ReplicationFound")%></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("Replication")%></td>
  </tr>
  <tr class="odd">
    <td><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.ADK</emxUtil:i18n></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("ADKFound")%></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("ADK")%></td>
  </tr>
</table>&nbsp;
<!-- End System Information Body -->

<!-- Begin Core Users Information Header -->
<table width="100%">
  <tr>
     <!-- //XSSOK -->
     <td class="heading1"><%=coreFilter%></td>
  </tr>
</table>
<table class="list">
  <tr>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.BusinessDefinitions</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.ActiveUsers</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.InactiveUsers</emxUtil:i18n></th>
  </tr>
  <tr class="odd">
    <td><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.UserDefinitions</emxUtil:i18n></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("CoreActiveUsers")%></td>
    <!-- //XSSOK -->
    <td><%=(String)analyzeData.get("CoreInactiveUsers")%></td>
  </tr>
</table>&nbsp;
<!-- End Core Users Information Body -->

<table width="100%">
  <tr>
     <!-- //XSSOK -->
     <td class="heading1"><%=aefFilter%></td>
  </tr>
</table>
<table class="list">
  <tr>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.ApplicationName</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.ActiveUsers</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.InactiveUsers</emxUtil:i18n></th>
  </tr>
<%
  String rowClass = "odd";
  MapList apps = (MapList)analyzeData.get("AppData");
  Iterator appsItr = apps.iterator();
  while (appsItr.hasNext())
  {
     HashMap appMap = (HashMap)appsItr.next();
     String appName = (String)appMap.get("name");
     String mxAppName = "";
     try{
         mxAppName = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout." + appName);
     }catch(Exception e){
         mxAppName = appName;
     }
     String appActive = (String)appMap.get("active");
     String appInactive = (String)appMap.get("inactive");
%>
  <!-- //XSSOK -->
  <tr class="<%=rowClass%>">
    <!-- //XSSOK -->
    <td><%=mxAppName%></td>
    <!-- //XSSOK -->
    <td><%=appActive%></td>
    <!-- //XSSOK -->
    <td><%=appInactive%></td>
  </tr>
<%
     if (rowClass.equals("odd"))
     {
       rowClass = "even";
     }
     else
     {
       rowClass = "odd";
     }
  }
%>
</table>&nbsp;
<!-- End AEF Registered Users Information Body -->

<!-- Begin Integrations Information Header -->
<table width="100%">
  <tr>
     <!-- //XSSOK -->
     <td class="heading1"><%=integrationFilter%></td>
  </tr>
</table>
<table class="list">
  <tr>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.TotalIntegrationUsers</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.ActiveUsers</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.InactiveUsers</emxUtil:i18n></th>
  </tr>
<%
  HashMap intUsers = (HashMap)analyzeData.get("IEF Users");
  String totalIEF = (String)intUsers.get("total");
  String activeIEF = (String)intUsers.get("active");
  String inactiveIEF = (String)intUsers.get("inactive");
  StringList installedInt = (StringList)analyzeData.get("Installed Integrations");
%>
  <tr class="odd">
    <td><%=XSSUtil.encodeForHTML(context, totalIEF)%></td>
    <td><%=XSSUtil.encodeForHTML(context, activeIEF)%></td>
    <td><%=XSSUtil.encodeForHTML(context, inactiveIEF)%></td>
  </tr>
</table>
<br/>
<table class="list">
  <tr>
    <th><emxUtil:i18n localize="i18nId">emxFramework.AnalyzeDB.InstalledIntegrations</emxUtil:i18n></th>
  </tr>
<%
  rowClass="odd";
  Iterator integItr = installedInt.iterator();
  while (integItr.hasNext())
  {
     String integName = (String)integItr.next();
%>
  <!-- //XSSOK -->
  <tr class="<%=rowClass%>">
    <td><%=XSSUtil.encodeForHTML(context, integName)%></td>
  </tr>
<%
     if (rowClass.equals("odd"))
     {
       rowClass = "even";
     }
     else
     {
       rowClass = "odd";
     }
  }
%>
</table>
<%
if (!isPrinterFriendly)
{
%>
</div>
<%
}
}
catch (Exception ex)
{
    if ((ex.toString()!= null) &&
        ((ex.toString().trim()).length()>0))
    {

    }
}

%>

</body>
</html>

