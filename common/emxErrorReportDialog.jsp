<%-- emxErrorReportDialog.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
  static const char RCSID[] = $Id: emxErrorReportDialog.jsp.rca 1.8.3.2 Wed Oct 22 15:47:58 2008 przemek Experimental przemek $
--%>


<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<html>
<head>
<%@include file = "emxNavigatorTimerTop.inc"%>
<%
String strLanguage = request.getHeader("Accept-Language");
String strStatus =(String)emxGetParameter(request,"status");
String strErrorReportDialogTitle =  EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.Title.ErrorReportDialog", new Locale(strLanguage));
String strProgressImage = "images/utilProgressBlue.gif";
String strProcessingText = UINavigatorUtil.getProcessingText(context, strLanguage);
String strHelpCancel = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.Close", new Locale(strLanguage));
String strHelpMarker = "emxhelpmasspromotedemotereport";
StringBuffer strbuffParams = new StringBuffer();
String Count =(String)emxGetParameter(request,"totalCount");
strbuffParams.append("totalCount="+XSSUtil.encodeForURL(context, Count));
String timeStamp =(String)emxGetParameter(request,"timeStamp");
strbuffParams.append("&timeStamp=");
strbuffParams.append(XSSUtil.encodeForURL(context, timeStamp));
String strEvent =(String) emxGetParameter(request,"cmd");

strbuffParams.append("&strEvent=");

strbuffParams.append(XSSUtil.encodeForURL(context, strEvent));
String display  = "emxErrorReportBody.jsp?"+strbuffParams.toString();
if("Progress".equalsIgnoreCase(strStatus))
{
    display = "emxMassPromoteDemoteStatus.jsp";
}

%>
<title><emxUtil:i18n localize="i18nId">emxFramework.Common.PageHeading</emxUtil:i18n></title>

<script type="text/javascript" language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>



<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<script language="JavaScript" type="text/JavaScript">
addStyleSheet("emxUIDOMLayout");
addStyleSheet("emxUIToolbar");
</script>
        <script>
        //To enable  the printerfriendly page
        var printDialog = null;        
		function openPrinterFriendlyPage()
		{
		    //XSSOK
		    var strURL = "emxErrorReportBody.jsp?pf=true&"+"<%=strbuffParams.toString()%>";        
			//make sure that there isn't a window already open
		    if (!printDialog || printDialog.closed) {
		
		    var strFeatures = "scrollbars=yes,toolbar=yes,location=no,resizable=yes";
		    printDialog = window.open(strURL, "PF" + (new Date()).getTime(), strFeatures);
		
		     //set focus to the dialog
		     printDialog.focus();
		
		   } else {
		          //if there is already a window open, just bring it to the forefront (NCZ, 6/4/01)
		      if (printDialog) printDialog.focus();
		   }
		
		}

</script>

</head>
<title><emxUtil:i18n localize="i18nId">emxFramework.Common.MassPromoteDemotePageHeading</emxUtil:i18n></title>
<body  onload="turnOffProgress()" >
<div id="pageHeadDiv" >
<form name="ErrorReportDialog" action="">
<table  border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td width="1%" nowrap><span class="pageHeader">&nbsp;<emxUtil:i18n localize="i18nId">emxFramework.Commom.MassPromoteDemoteErrorReportHeading</emxUtil:i18n></span>
	<br/><span class="pageSubTitle">&nbsp;<%=strErrorReportDialogTitle%></span>
	</td>
	<td nowrap>
	<div id="imgProgressDiv">&nbsp;<img src="<%=strProgressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=strProcessingText%></i></div></td>
    <td width="1%"><img src="images/utilSpacer.gif" width="1" height="10" border="0" alt="" vspace="4" /></td>

</tr>
</table>

<jsp:include page="emxToolbar.jsp" flush="true">
	<jsp:param name="HelpMarker" value="<%=strHelpMarker%>" />
	<jsp:param name="header" value="" />
	<jsp:param name="suiteDir" value="" />
	<jsp:param name="portalMode" value="" />
    <jsp:param name="PrinterFriendly" value="true"/>
    <jsp:param name="expandLevelFilter" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="editLink" value="false"/>
    <jsp:param name="customize" value="false"/>
    <jsp:param name="multiColumnSort" value="false"/>
</jsp:include>   
</form>
</div>
  <div id="divPageBody" >
  <iframe name="MasspromoteDemoteErrorReport" id="ErrorReport" src='<%=display%>' width="100%" height="100%"  frameborder="0" border="0" ></iframe>
</div>
<div id="divPageFoot">
<form name="editFooter" method="post">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
    <td class="pagination"></td>
	<td class="buttons">
    <table>
          <tr>
			<td><a class="footericon" href="javascript:getTopWindow().closeWindow();"><img src="images/buttonDialogCancel.gif" alt="<%=strHelpCancel%>" /></a></td>
			<td><a onClick="javascript:getTopWindow().closeWindow();"><button class="btn-primary" type="button"><%=strHelpCancel%></button></a></td>
          </tr>
          </table>
          </td>
          </tr>
          </table>
</form>          
</div>
</body>
</html>
