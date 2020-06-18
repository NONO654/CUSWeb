<%--  emxengchgMetricsReportConfirm.jsp   - Confirmation page for Metrics Report of ECO/ECR
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

  <%@include file = "emxDesignTopInclude.inc"%>
  <%@include file = "emxEngrVisiblePageInclude.inc"%>
  
  <%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="JavaScript">
 function goBack()
  {
	 window.parent.location.href="emxengchgMetricsReportDialogFS.jsp";
  }
</script>
<%
  String sType            = emxGetParameter(request,"type");
  String sFilename        = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"filename"));
  String sPrinterFriendly = emxGetParameter(request,"PrinterFriendly");

  if(sType != null){
	  if (sType.startsWith("type_")) {
		  sType = PropertyUtil.getSchemaProperty(context, sType);  
	  }
	  
	  MqlUtil.mqlCommand(context, "print type $1 select $2 dump", sType, "name");
  }
  
  if (sFilename != null) {
	  if ( ! ( sFilename.endsWith(".txt") || sFilename.endsWith(".csv")) ) {
		  throw new Exception("File format is not supported : " + sFilename);
	  }
  }
  
  String sHasBeenCreated = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.HasBeenCreatedFor", request.getHeader("Accept-Language"));
  String sMetricsReport  = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.DesignTOP.MetricsReport", request.getHeader("Accept-Language"));
  String sRightClick     = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.RightClickToDownload", request.getHeader("Accept-Language"));
%>
  <!-- XSSOK -->
  <%=sMetricsReport%>&nbsp;
  <!-- XSSOK -->
  <%=sHasBeenCreated%>&nbsp;<%=i18nNow.getTypeI18NString(sType,request.getHeader("Accept-Language"))%>.
  <br/><br/>
<%
  if (sPrinterFriendly != null && "true".equals(sPrinterFriendly) ) {
%>
	<!-- XSSOK -->
    <%=sMetricsReport%>&nbsp;&nbsp;<%=sRightClick%>
<%
  } else {

    final String url =  com.matrixone.servlet.Framework.getTemporaryFilePath(response,session,sFilename,false);



%>
	<!-- XSSOK -->
    <a href="<%=url%>"><%=sMetricsReport%></a>&nbsp;&nbsp;<%=sRightClick%>
<%
  }
%>
  </body>
  <%@include file = "emxDesignBottomInclude.inc"%>
  </html>




