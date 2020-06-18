<%-- PreciseBOM.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@page import="com.matrixone.apps.configuration.ProductConfiguration"%>

<%@page import="com.matrixone.apps.domain.util.MapList"%>

<%
String strMode = emxGetParameter(request, "mode");
MapList arrGenerateBOM         = new MapList();
boolean isSalable                = false;
if(strMode.equalsIgnoreCase("generatePBOM")) { // mode == generatePBOM
    String strPlace                  = emxGetParameter(request, "place");         // Check from where this is called
    String tableRowIds               = emxGetParameter(request, "emxTableRowId"); // Check if it comes from List pages
    String strObjectId               = emxGetParameter(request, "objectId");      // Check if it comes from Property pages
    String strProductConfigurationId = "";
    if (strObjectId!=null && !strObjectId.equals("") && strPlace.equals("listpage")) {
        strProductConfigurationId = strObjectId;
    } else if(tableRowIds!=null && !tableRowIds.equals("") && strPlace.equals("tablecontent")) {
        int iTableRowIdsLength = tableRowIds.length();
        int iCheckPoint = 0;
        for (int itemp = 0; itemp < iTableRowIdsLength; itemp++) {
           if (tableRowIds.charAt(itemp)=='|') {
              iCheckPoint = 1;
              strProductConfigurationId = tableRowIds.substring(itemp+1, iTableRowIdsLength).trim();
           }
        }
        if(iCheckPoint == 0) {
           strProductConfigurationId = tableRowIds;
        }
    }
     isSalable = ProductConfiguration.isSalableProductConfiguration(context,strProductConfigurationId);
     //check whether the product configuration is salable
     if(!isSalable)
     {
    	
    	 try{
       ProductConfiguration pcBean = new ProductConfiguration();
       arrGenerateBOM = pcBean.generatePreciseBOMForPC(context,strProductConfigurationId);
      
       
    	 }catch(Exception e){
   	    
   	    session.putValue("error.message", e.getMessage());
 		}
      }
      else
      {
        String sAlertMessage = i18nNow.getI18nString("emxProduct.Alert.SalableProductConfigurationPBOMGeneration",bundle,acceptLanguage);
%>
        <SCRIPT language="javascript" type="text/javaScript">
           var AlertMsg = "<%=XSSUtil.encodeForJavaScript(context,sAlertMessage)%>";
           alert(AlertMsg);
        </SCRIPT>
<%  }
  }
int iMessageCount = arrGenerateBOM.size();
if (iMessageCount > 0)
{
	String sPBOMMessage = i18nNow.getI18nString("emxProduct.Alert.PreciseBOMGenerated",bundle,acceptLanguage);
%>
<SCRIPT language="javascript" type="text/javaScript">
alert ("<%=XSSUtil.encodeForJavaScript(context,sPBOMMessage)%>");
</SCRIPT>
<%
}
else
{
%>
  alert ("<%=i18nNow.getI18nString("emxProduct.Alert.ReqFieldsAlert", bundle,acceptLanguage)%>");
<%
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

