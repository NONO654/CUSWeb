<%--  ProductConfigurationConfiguratorHeader.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ProductConfigurationConfiguratorHeader.jsp 1.4.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>
<%@ page import="com.matrixone.apps.domain.DomainConstants" %>
<%@ page import="com.matrixone.apps.domain.DomainObject" %>
<%@ page import="matrix.util.StringList" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@ page import="com.matrixone.apps.configuration.ProductConfiguration" %>
<%@ page import="com.matrixone.apps.domain.util.i18nNow" %>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
<%@ page import="com.matrixone.fcs.common.ImageRequestData" %>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>

<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<script type="text/javascript">

  addStyleSheet("emxUIDefault");

</script>

  <link rel="stylesheet" href="emxUIProductCentral.css" type="text/css" />

  <SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
  <SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
</head>
<body>
<form name ="header" method="post">
<input type="hidden" name="validationDone" value="false" />
<%
  ProductConfiguration productConfiguration = (ProductConfiguration)session.getAttribute("productconfiguration");

  String strProductId = emxGetParameter (request, "productId" );
  String productConfigurationId = emxGetParameter (request, "productConfigurationId" );
  String strLocale = context.getSession().getLanguage();
  // Begin of Add  by Enovia MatrixOne for Bug# 318008 on Apr 06,2006
  String suiteKey = emxGetParameter(request, "suiteKey");
  String isPopup = emxGetParameter(request, "isPopup");
  String header = emxGetParameter(request, "header");
  String strMarketingName = null;
  DomainObject domPC = null;
  StringList slProductInfo = new StringList(3);
  // End of Add by Enovia MatrixOne for Bug# 318008 on Apr 06,2006
  if((strProductId == null) || ("".equals(strProductId)) || "null".equals(strProductId))
  {
  
      if(productConfiguration != null)
      {
  strProductId = productConfiguration.getContextId();
      }
      else
      {
          domPC = new DomainObject(productConfigurationId);
          slProductInfo.addElement("to["+ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.id");
          slProductInfo.addElement("attribute["+ConfigurationConstants.ATTRIBUTE_MARKETING_NAME+"]");
          Map mpPCInfo = domPC.getInfo(context,slProductInfo);
          strProductId = (String)mpPCInfo.get("to["+ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.id");
          strMarketingName = (String)mpPCInfo.get("attribute["+ConfigurationConstants.ATTRIBUTE_MARKETING_NAME+"]");
      }
  }
  DomainObject Product=DomainObject.newInstance(context,strProductId);
  String[] strPrimaryImageInfo = ProductConfiguration.getPrimaryImage(context, strProductId);
  boolean hasImagesAttached = ProductConfiguration.hasImagesAttached(context, strProductId);
  String txtPrdConfigProduct = emxGetParameter(request, "text_ProductConfigurationProduct");
  if (txtPrdConfigProduct == null || "null".equals(txtPrdConfigProduct))
  {
            txtPrdConfigProduct = "";
    }
%>

  <table border="0" cellpadding="3" width="100%" cellspacing="2">
    <tr>
      <td class="heading1">
      <%if(productConfiguration != null)
          {%>
        <SPAN class="heading1"><%=XSSUtil.encodeForHTML(context,( i18nNow.getTypeI18NString(Product.getInfo(context,DomainConstants.SELECT_TYPE), strLocale) + " :  " + UINavigatorUtil.htmlEncode(Product.getInfo(context,DomainConstants.SELECT_NAME)) + " " + UINavigatorUtil.htmlEncode(Product.getInfo(context,DomainConstants.SELECT_REVISION)) + "<br/>" )) %></SPAN>
        
        <%}
      else
      {%>
       <SPAN class="heading1"><%=XSSUtil.encodeForHTML(context,( i18nNow.getTypeI18NString(Product.getInfo(context,DomainConstants.SELECT_TYPE), strLocale) + " :  " + strMarketingName )) %></SPAN>          
      <%}
      %>
      </td>
      <td width="1%">
        &nbsp;
      </td>
    </tr>
    <tr>
     <td>
     <!--   <SPAN>&nbsp;<%=XSSUtil.encodeForHTML(context,productConfiguration.getMarketingName())%></SPAN> -->
      </td>
      <td width="1%">
        &nbsp;
      </td>
    </tr>
  </table>
  <%=XSSUtil.encodeForHTML(context,txtPrdConfigProduct)%>
  <table border="0" cellpadding="3" width="100%" cellspacing="2">
    <tr>
      <%
        if ( strPrimaryImageInfo != null ) {
          // Commented to change the approach of bringing the Image
          /*StringBuffer sBuffer = new StringBuffer();
          sBuffer.append(FileCheckoutServlet.getURL(null));
          sBuffer.append("/");
          sBuffer.append(strPrimaryImageInfo[0]);
          sBuffer.append("/");
          sBuffer.append(strPrimaryImageInfo[1]);
          sBuffer.append("?format=");
          sBuffer.append(strPrimaryImageInfo[2]);
          sBuffer.append("&attachment=");
          sBuffer.append("true");
          sBuffer.append("&file=");
          sBuffer.append(strPrimaryImageInfo[1]);
          String url = sBuffer.toString();

          url = url.substring(url.indexOf("/")+1, url.length());
          url = url.substring(url.indexOf("/")+1, url.length());
          url = "../" + url;*/

          // Modified by Enovia MatrixOne for Bug # 316685 Date- March 20, 2006
          String strSymbolicFormat = EnoviaResourceBundle.getProperty(context,"emxProduct.Image.ProdConf.Format");
          String strFormat = PropertyUtil.getSchemaProperty(context, strSymbolicFormat);

          HashMap imageData = UINavigatorUtil.getImageData(context, pageContext);
          ArrayList arraylist = new ArrayList();

          DomainObject domPrimaryImage = new DomainObject(strPrimaryImageInfo[0]);
          // Getting the file name according to the format specified in the String Resource file
          String strImageFileName =  domPrimaryImage.getInfo(context, "format[" + strFormat + "].file.name");

          // Getting the URL source for the image
          BusinessObjectProxy businessobjectproxy = new BusinessObjectProxy(strPrimaryImageInfo[0], strFormat, strImageFileName, false, false);
          arraylist.add(businessobjectproxy);
          String strImageURLs[] = ImageRequestData.getImageURLS(context, arraylist, imageData);

          // Forming the "img" tag for Image display
          String strImageURL = strImageURLs[0];
          strImageURL = "<img border='0' align='absmiddle' src='"+strImageURL+"' />";
          // Modified strImageViewerURL by Enovia MatrixOne for Bug# 318008 on Apr 06,2006
          // Forming the source for Image display
          String strImageViewerURL = "../components/emxImageManager.jsp?HelpMarker=emxhelpimagesview&objectId=" + XSSUtil.encodeForURL(context,strProductId)+"&suiteKey="+ XSSUtil.encodeForURL(context,suiteKey) +"&isPopup="+XSSUtil.encodeForURL(context,isPopup)+"&header="+XSSUtil.encodeForURL(context,header);
          // Forming the final URL, combining the "a" tag, using the "img" tag
          String strImageDisplayURL = "<a href='javascript:showModalDialog(\"" + strImageViewerURL + "\",850,650)'>" + strImageURL + "</a>";

      %>
      <td ALIGN="left"><%=XSSUtil.encodeForHTML(context,strImageDisplayURL)%></td>
      <%
        }
      %>

          <%
            if (hasImagesAttached) {
          %>
       <td><script language="javascript" type="text/javaScript">

               function showSlideshow() {
                 var formName=document.forms[0];
                 formName.target="pagehidden";
                 formName.action='../productline/ImageUtil.jsp?mode=SlideShow&objectId=<%=XSSUtil.encodeForURL(context,strProductId)%>';
                 formName.submit();
                }
       </script>
       </td>
          <%
            } else {
          %>
       <td><script language="javascript" type="text/javaScript">
             function showSlideshow() {
             }
       </script>
       </td>     <%}%>
    </tr>
    <tr>
       <td>
         <%StringBuffer sbMarText = new StringBuffer();
         if(productConfiguration != null)
         {
            sbMarText.append(FrameworkUtil.findAndReplace(UINavigatorUtil.htmlEncode(productConfiguration.getMarketingText()), "\n", "<br />"));
         }
         else
         {
             sbMarText.append(FrameworkUtil.findAndReplace(UINavigatorUtil.htmlEncode(strMarketingName), "\n", "<br />"));
         }
            sbMarText.append("&nbsp;");
         %>
         <%=XSSUtil.encodeForHTML(context,sbMarText.toString())%>
       </td>
    </tr>
  </table>
  <!--  <table border="0" cellpadding="3" width="100%" cellspacing="2">
    <tr>
    <td ALIGN="left"><%= XSSUtil.encodeForHTML(context,(i18nNow.getBasicI18NString(Product.getInfo(context,DomainConstants.SELECT_DESCRIPTION), strLocale)))%></td>
    </tr>
  </table>-->
  </form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
