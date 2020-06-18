<!-- 
    GBOMRuleExpressionDialog.jsp
    Copyright (c) 1993-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    Dassault Systemes.
    Copyright notice is precautionary only and does not evidence any actual
    or intended publication of such program
-->

<%-- Include JSP for error handling --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%

 try{
    i18nNow i18nNow  = new i18nNow();
    String strLocale = context.getSession().getLanguage();
	String strEffectivityExpression = i18nNow.GetString("emxConfigurationStringResource",strLocale,"emxProduct.Label.Table.PreviewEBOM.EffectivityExpression");
    String strPCId = emxGetParameter(request, "PCID");
    String strLFId = emxGetParameter(request, "LFId");
    String strPartRelId = emxGetParameter(request, "PartRelId");
    String strMode = emxGetParameter(request, "mode");
	String strExpressionDisplay = "";
    
    if("FromNonDecoupledEffectivity".equalsIgnoreCase(strMode)){
       if(strPartRelId!=null && !strPartRelId.equals("")){
    	    	strExpressionDisplay = ConfigurationUtil.getEffectivityExpression(context,strPartRelId,true,false,false,false);
       }else{// in case part is not set in preview BOM- refering selected options Effectivity will be displayed.
    	  		strExpressionDisplay =	ProductConfiguration.getEffectivityExpression(context,strPCId,strLFId,strPartRelId);
       }
    }else if ("FromDecoupledVEffectivity".equalsIgnoreCase(strMode)){
        if(strPartRelId!=null && !strPartRelId.equals("")){
	    	strExpressionDisplay = ConfigurationUtil.getEffectivityExpression(context,strPartRelId,false,true,false,false);
        }else{// in case part is not set in preview BOM- refering selected options Effectivity will be displayed.
	    	strExpressionDisplay =	ProductConfiguration.getEffectivityExpression(context,strPCId,strLFId,strPartRelId);
       }
    }else {
    	//TODO-IS IN EVOLUTION EFFECTIVITY CASE- will not required to show runtime Effectivity Expression
  		strExpressionDisplay = ConfigurationUtil.getEffectivityExpression(context,strPartRelId,false,false,true,false);
    }
    if(strExpressionDisplay != null && !("".equals(strExpressionDisplay))&& !("null".equals(strExpressionDisplay)))
	{
	%>
     
	<table border="0" cellspacing="2" cellpadding="5" width="100%">
	        <tr>
	        <td class="label">
	        <b>
	        <%=XSSUtil.encodeForHTML(context,strEffectivityExpression)%>
	        </b>
	        </td>
	        </tr>
	        <BR/>
	        <BR/>
	        <td class="inputField">
	        <%=XSSUtil.encodeForHTML(context,strExpressionDisplay)%>
	        </td>
	      </tr>
	</table>
	<%
	    }else
	    {//No Inclusion Rule exists for this object
	%>
	     <table border="0" cellspacing="2" cellpadding="0" width="100%">
	      <tr>
	         <td  class="label" width="100%">
	        <emxUtil:i18n localize="i18nId">
	            emxProduct.Message.EffectivityExpression
	         </emxUtil:i18n>
	        </td>
	      </tr>
	     
	    </table>
	  <%      
	 }
}
catch (Exception e)
    {
       String strAlertString = "emxProduct.Alert." + e.getMessage();
       String i18nErrorMessage = i18nNow.getI18nString(strAlertString,bundle,acceptLanguage);
       
       if(i18nErrorMessage.equals(DomainConstants.EMPTY_STRING)){
         session.putValue("error.message", e.getMessage());
       }
       else
       {
         session.putValue("error.message", i18nErrorMessage);
       }
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
