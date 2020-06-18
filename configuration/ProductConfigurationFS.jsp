<%--  ProductConfigurationFS.jsp  -   FS page for Product Configuration feature select page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or
  intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ProductConfigurationFS.jsp 1.4.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>
<%@include file = "../emxUICommonAppInclude.inc"%>  

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIJson.js"></SCRIPT>
<%
    String appendParams = emxGetQueryString(request);
    String strPurpose   = XSSUtil.encodeForURL(context,emxGetParameter(request, "radProductConfigurationPurposeValue"));
    String strFromContext = XSSUtil.encodeForURL(context,emxGetParameter(request,"fromcontext"));
    String strFunctionality = XSSUtil.encodeForURL(context,emxGetParameter(request, "functionality"));
    String strAction = XSSUtil.encodeForURL(context,emxGetParameter(request, "PRCFSParam2"));
    String topLevelPart = XSSUtil.encodeForURL(context,emxGetParameter(request, "topLevelPart"));
    String topLevelPartDisplay = XSSUtil.encodeForURL(context,emxGetParameter(request, "topLevelPartDisplay"));
    
    String productConfigurationId = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
    String productConfigurationMode = XSSUtil.encodeForURL(context,emxGetParameter(request,"productConfigurationMode"));
    String startEffValue = XSSUtil.encodeForURL(context,emxGetParameter(request,"startEffDate"));
    String endEffValue = XSSUtil.encodeForURL(context,emxGetParameter(request,"endEffDate"));

    String strHelpMarker = "";
    if(strAction.equalsIgnoreCase("edit"))
    {
        strHelpMarker = "emxhelpproductconfigurationeditoptions";
    } else {
        strHelpMarker = "emxhelpproductconfigurationcreate";
    }

    String strHeaderURL = "ProductConfigurationHeader.jsp?toolbar=AEFProductConfigurationCreateActionBar&title=Product Configuration&HelpMarker="+strHelpMarker+"&functionality=" + strFunctionality;
    String strFooterURL = "ProductConfigurationFooter.jsp?" + appendParams;
    String strBodyURL = "ProductConfigurationContentFSDialog.jsp?fromcontext="+strFromContext+"&" + appendParams +"&radProductConfigurationPurposeValue="+strPurpose + "&productConfigurationId="+productConfigurationId+"&productConfigurationMode="+productConfigurationMode +"&topLevelPart=" + topLevelPart + "&topLevelPartDisplay=" + topLevelPartDisplay+ "&startEffValue=" + startEffValue+ "&endEffValue=" + endEffValue;
%>  

  <frameset rows="110,*,65,0" framespacing="0" frameborder="no" border="0">
       <frame id="pageheader" "name="pageheader" src="<%=XSSUtil.encodeForHTMLAttribute(context,strHeaderURL)%>" noresize="noresize" marginheight="10" marginwidth="10" border="0" frameborder="no" scrolling="no" framespacing="5"/>
       <frame name="pagecontent" src="<%=XSSUtil.encodeForHTMLAttribute(context,strBodyURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"  framespacing="5"/>
       <frame name="pagesignature" src="<%=XSSUtil.encodeForHTMLAttribute(context,strFooterURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
       <frame name="pagehidden" src="" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
  </frameset>
