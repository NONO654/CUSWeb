<%--  emxInfoCustomTableHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<html>

<%@include file = "MCADTopInclude.inc"%>
<%@include file = "MCADTopErrorInclude.inc"%>
<%@include file = "emxInfoCustomTableInclude.inc" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

    String header = emxGetParameter(request, "custHeader");	
    String sHelpMarker = emxGetParameter(request, "HelpMarker");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String programList = emxGetParameter(request, "custProgram");
    String sActionBarName = emxGetParameter(request, "custTopActionbar");
    String tipPage = emxGetParameter(request, "TipPage");
    String printerFriendly = emxGetParameter(request, "PrinterFriendly");
    String objectId = emxGetParameter(request, "objectId");
    String sTarget = emxGetParameter(request, "custTargetLocation");
       
    if (header != null)
		header = integSessionData.getStringResource(header);
	else
		header = "";
    
    if(objectId!=null && !objectId.trim().equals(""))
	{
	    BusinessObject bus = new BusinessObject(objectId);
        bus.open(context);
        header = bus.getName() + "  " + bus.getRevision() + " " + header;
        bus.close(context);
	} 
	
    String suiteDir			= "";
    String registeredSuite	= "";

    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
    {
        registeredSuite = suiteKey.substring(13);

        if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
            suiteDir = UINavigatorUtil.getRegisteredDirectory(application, registeredSuite);
    }

%>

<head>
	<title>Table Header</title>
<% 
    
    if(sTarget != null && !sTarget.equals(""))
    {
       if(sTarget.equals("content") &&  !sTarget.equals(""))	
       {
       	
%>
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />
		
	
<%       	
       }
       else
       {
%>
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUISearch.css" />
	       
<%	
       }
    	
    	
    }
    else
    {
%>    	
  		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />
		
<%    	
    }
    
   
%>	

	<script language="javascript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
	<script language="javascript" type="text/javascript" src="../common/scripts/emxUIActionbar.js"></script>
	<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>

</head>

<body marginheight="4"  topmargin="0" vspace="0" >
<form name="tableHeaderForm" method="post">
<table border="0" cellspacing="2" cellpadding="0" width="100%">
<tr>
<td width="99%">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" alt=""></td>
</tr>
</table>

<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
<td class="pageHeader" width="99%"><%=header%></td>
<td width="1%"><img src="../common/images/utilSpacer.gif" width="1" height="28" alt=""></td>
</tr>
</table>
<%
String tipPageHTML = "";
String printFrHTML = "";
String helpHTML = "";
String help=i18nNow.getI18nString("mcadIntegration.Common.Help",null,lStr);
String print=i18nNow.getI18nString("mcadIntegration.Common.Print",null,lStr);
String tip=i18nNow.getI18nString("mcadIntegration.Common.Tip",null,lStr);
String appDirectory = "ief";
if (tipPage != null && tipPage.length() > 0)
	tipPageHTML = "<a href=\"javascript:openWindow('" + tipPage + "')\"><img src=\"../common/images/buttonContextTip.gif\" alt=\""+tip+"\" border=\"0\"></a>";

if (printerFriendly == null || printerFriendly.trim().length() == 0 || printerFriendly.equalsIgnoreCase("true") )
	printFrHTML = "<a href=\"javascript:openCustomTablePrinterFriendlyPage()\"><img src=\"../common/images/buttonContextPrint.gif\" alt=\""+print+"\" border=\"0\"></a>";

helpHTML = "<a href=\"javascript:openHelp('" + sHelpMarker + "', '" + appDirectory + "', '" + langStr + "')\"><img src=\"images/buttonContextHelp.gif\" alt=\""+help+"\" border=\"0\"></a>";

%>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="0" alt=""></td>
</tr>
</table>

<table border="0"width="100%" cellspacing="0" cellpadding="0">
<tr>
  <td><img src="../common/images/utilSpacer.gif" border="0" width="5" height="20" alt=""></td>
  <!--XSSOK-->
  <td align="right"><%=printFrHTML%><%=tipPageHTML%><%=helpHTML%></td>
</tr>
</table>

</td>

<td><img src="../common/images/utilSpacer.gif" alt="" height="1" width="4"></td>

</tr>
</table>


<script language="JavaScript">
// This variable positions the action item list from the top os the frame
var actionItemTopPos = 55;
var actionItemLeftPos = 10;
var visibleLinks = 4;
</script>

<%

  if ( !(sActionBarName == null) && !(sActionBarName.equals("")) && !(sActionBarName.equalsIgnoreCase("null")) )
  {
%>
<jsp:include page= "emxInfoActionBar.jsp" flush="true">
    <jsp:param name="actionBarName" value="<%=XSSUtil.encodeForHTML(context,sActionBarName)%>"/>
     <jsp:param name="parentOID" value="<%=XSSUtil.encodeForHTML(context,objectId)%>"/>
 </jsp:include>
<%
  }
%>
</form>
<%@include file = "MCADBottomErrorInclude.inc"%>
</body>
</html>
