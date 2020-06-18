<%--  ProductConfigurationFS.jsp  -   FS page for Product Configuration feature select page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or
  intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ProductConfigurationViewFS.jsp 1.5.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>
<%@include file = "../emxUICommonAppInclude.inc"%>  

<%@page import = "com.matrixone.apps.configuration.*"%>

<%
    String fromAction = emxGetParameter(request, "functionality");
    String strpcName = emxGetParameter(request, "pcName");
    String strpcType = emxGetParameter(request, "pcType");
    String strFunctionality=ConfigurationConstants.EMPTY_STRING;
	if(fromAction.equals("ProductConfigurationMarketingRuleValidationReportFSInstance")){
		strFunctionality = fromAction;
	}else {
		strFunctionality = "ProductConfigurationView";
	}	
    String strHelpMarker = "emxhelpproductconfigurationoptionspage";
    String strHeaderURL = "ProductConfigurationHeader.jsp?functionality="+strFunctionality+"&HelpMarker="+strHelpMarker+"&pcType="+strpcType+"&pcName="+strpcName;
    String strFooterURL = "ProductConfigurationFooter.jsp?PRCFSParam2=view";
    String strBodyURL = "ProductConfigurationContentFSDialog.jsp?functionality=view";
	
%>  

  
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><frameset rows="85,*,65,0" framespacing="0" frameborder="no" border="0">
       <frame id="pageheader" name="pageheader" src="<%=XSSUtil.encodeForHTMLAttribute(context,strHeaderURL)%>" noresize="noresize" marginheight="10" marginwidth="10" border="0" frameborder="no" scrolling="no" framespacing="5"/>
       <frame name="pagecontent" src="<%=XSSUtil.encodeForHTMLAttribute(context,strBodyURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"  framespacing="5"/>
       <frame name="pagesignature" src="<%=XSSUtil.encodeForHTMLAttribute(context,strFooterURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
       <frame name="pagehidden" src="" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
  </frameset>
	    
  
