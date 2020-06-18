<%--  emxComponentsCurrencyExchangeRateUtil.jsp   -  The page for adding parts to RTS
   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOSourcingCentral/CNext/webroot/components/emxComponentsCurrencyExchangeRateUtil.jsp 1.1.2.2.1.1 Wed Oct 29 22:23:58 2008 GMT przemek Experimental$
--%>

<%@  include file = "../emxUICommonAppInclude.inc"%>
<%@include file="emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
<jsp:useBean id="utilBean" scope="page" class="com.matrixone.apps.common.util.JSPUtil"/>
 <script language="JavaScript" src="../common/scripts/emxUIConstants.js"type="text/javascript"> </script>
<jsp:useBean id="currencyConversionBean" class="com.matrixone.apps.domain.CurrencyConversion" scope="page" />

<%
  String strMode             = emxGetParameter(request, "mode");
  
  if("create".equalsIgnoreCase(strMode)) //Add new currency conversion object
  {
	  String objectId       = emxGetParameter(request,"objectId");
	  String sFromCurrency  = "";
	  String sToCurrency    = "";
	  String sRate          = "";
	  String sEffectiveDate = "";
      String sDecimalSymbol = EnoviaResourceBundle.getProperty(context, "emxFramework.DecimalSymbol");
	  
	  if (emxGetParameter(request,"FromCurrency") != null) {
	    sFromCurrency = emxGetParameter(request,"FromCurrency").trim();
	  }
	  if (emxGetParameter(request,"ToCurrency") != null) {
	    sToCurrency = emxGetParameter(request,"ToCurrency").trim();
	  }
	  if (emxGetParameter(request,"Rate") != null) {
	    sRate = emxGetParameter(request,"Rate").trim();
	  }
	  if (emxGetParameter(request,"EffectiveDate") != null) {
	    sEffectiveDate = emxGetParameter(request,"EffectiveDate").trim();
	  }
 	  if(sRate.contains(sDecimalSymbol)){
		  sRate=sRate.replace(sDecimalSymbol,".");
	  }     
	  double rate    = (new Double(sRate)).doubleValue();
	  double tz      = (new Double((String)session.getValue("timeZone"))).doubleValue();
	  sEffectiveDate = eMatrixDateFormat.getFormattedInputDateTime(context,sEffectiveDate,"12:00:00 AM",tz, request.getLocale());
	  currencyConversionBean.createRatePeriod(context, sFromCurrency, sToCurrency, rate, sEffectiveDate,objectId);
  }
  else if("delete".equalsIgnoreCase(strMode)) //Delete currency conversion object
  {
	  String ratePeriodConnectionIds[] = emxGetParameterValues(request, "emxTableRowId");
	  
	  currencyConversionBean.deleteRatePeriod(context, ratePeriodConnectionIds);
  }
   
%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
<% if ("delete".equalsIgnoreCase(strMode)){ %>
      getTopWindow().refreshTablePage();
<% } %>

</script>
