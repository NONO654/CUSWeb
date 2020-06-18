<%--  emxUIGenericSearchHeaderPage.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUIGenericSearchHeaderPage.jsp.rca 1.35 Wed Oct 22 16:09:50 2008 przemek Experimental przemek $
--%>

<%@ page import = "com.matrixone.apps.framework.ui.*" %>

<%@include file = "../emxUITopInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" >
var DIR_STYLES = "../common/styles/";
</script>

<html>
<head>
<%
  String userAgent = request.getHeader("User-Agent");
  boolean isUnix = false;
  String spacerTopHeight = "10";
  //display differently for Unix
  if (( userAgent.toLowerCase().indexOf("sunos") > -1 || userAgent.toLowerCase().indexOf("x11") > -1 )){
    isUnix = true;
    spacerTopHeight = "3";
  }
%>

<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleListInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>

<script language="javascript" src="../emxUIFilterUtility.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript" >

  function callProgressTimer(){
      setTimeout("swapImage()",1000);      
  }
  function swapImage(){
    //document.progress.src = "common/images/utilSpacer.gif";
    turnOffProgress();
  }
</script>
</head>
<body onLoad="callProgressTimer()">
 
<%
  String HelpMarker = emxGetParameter(request,"help");
   if( HelpMarker == null || "".equals(HelpMarker) || "null".equals(HelpMarker) )
  {
      HelpMarker = emxGetParameter(request,"HelpMarker");
  } 
  
  String PageHeading            = emxGetParameter(request,"phead");
  if( PageHeading == null || "".equals(PageHeading) || "null".equals(PageHeading) )
  {
      PageHeading = emxGetParameter(request,"PageHeading");
  }
  
  String objectIdParam          = emxGetParameter(request,"oidp");
  if( objectIdParam == null || "".equals(objectIdParam) || "null".equals(objectIdParam) )
  {
      objectIdParam = emxGetParameter(request,"objectIdParam");
  }

  String stringResourceFile     = emxGetParameter(request,"strfile");
  if( stringResourceFile == null || "".equals(stringResourceFile) || "null".equals(stringResourceFile) )
  {
      stringResourceFile = emxGetParameter(request,"stringResourceFile");
  }

  String Directory              = emxGetParameter(request,"dir");
  if( Directory == null || "".equals(Directory) || "null".equals(Directory) )
  {
      Directory = emxGetParameter(request,"Directory");
  }



  String sLanguage = request.getHeader("Accept-Language");
  boolean doTranslate = true;
  if ((stringResourceFile == null) || ("".equals(stringResourceFile))){
    doTranslate  = false;
  }

  if (doTranslate){
    PageHeading = i18nNow.getI18nString(PageHeading,stringResourceFile,sLanguage);
    if ((objectIdParam != null) && (!"".equals(objectIdParam))){
      PageHeading = com.matrixone.apps.framework.ui.UINavigatorUtil.parseStringMacro(context,session,PageHeading,objectIdParam);
    }
  }

  String helptip = i18nNow.getI18nString("emxFramework.Common.Tooltip.Help","emxFrameworkStringResource",sLanguage);
  
  String directoryStr = Directory;
  
  String langStr = request.getHeader("Accept-Language");
  String lStr = i18nNow.getI18nString("emxFramework.HelpDirectory","emxFrameworkStringResource", langStr);
  if(lStr == null || "".equals(lStr)){
    lStr = "en";
  }


%>


<form name="mx_header_form">
<!-- //XSSOK -->
<img src="../common/images/utilSpacer.gif" width="1" height="<%=spacerTopHeight%>"/>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
    <td class="pageBorder" ><img src="../common/images/utilSpacer.gif" width="1" height="1"/></td>
  </tr>
</table>

<!-- page header and pagination -->
<table border="0" width="100%" cellpadding="2">
  <tr>
    <td class="pageHeader" width="1%" nowrap><xss:encodeForHTML><%= PageHeading%></xss:encodeForHTML></td>
                  <%       
                      String progressImage = "../common/images/utilProgressBlue.gif";
                      String processingText = UINavigatorUtil.getProcessingText(context, langStr);    
                  %>
                  <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>     
    
  </tr>
</table>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
    <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1"/></td>
  </tr>
</table>

<table border="0" cellpadding="0" cellspacing="0"  align="right" width="1%">
  <tr>
	<!-- //XSSOK -->
    <td align="right" nowrap ><img src="../common/images/utilSpacer.gif" width=1 height="<%=spacerTopHeight%>" /><br/><a href='javascript:openHelp("<%=XSSUtil.encodeForJavaScript(context, HelpMarker)%>","<%=XSSUtil.encodeForJavaScript(context, directoryStr)%>","<%=XSSUtil.encodeForJavaScript(context, lStr)%>",true)'><img src="../common/images/buttonContextHelp.gif" width="16" height="16" border="0" title="<%=helptip%>" /></a></td>
       
  </tr>
</table>
</form>

</body>
</html>





