<%--  ProductConfigurationContextualHelpDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ProductConfigurationContextualHelpDialog.jsp 1.4.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow" %>
<%@page import="com.matrixone.fcs.common.ImageRequestData" %>
<%@page import="matrix.db.BusinessObjectProxy"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
    String strFeatureIdentifier = emxGetParameter(request, "PRCFSParam1");

  ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
    /*
     * The method returs all the required attributes of the FeatureHolder in a Map.
     *
     */
   // Map mapFeatureAttributes = pConf.getFeatureInfo(strFeatureIdentifier);
    IProductConfigurationFeature feature = (IProductConfigurationFeature)pConf.getFeature(strFeatureIdentifier).get(0);

    // Returns null if there is no Primary Image attached.
    //String[] strPrimaryImageInfo = ProductConfiguration.getPrimaryImage(context, pConf.getContextId());
    String[] strPrimaryImageInfo = ProductConfiguration.getPrimaryImage(context, feature.getId());
    String strLocale = context.getSession().getLanguage();

%>


<HTML>
<HEAD>
  <META http-equiv="Content-Type"   content="text/html; charset=iso-8859-1" />
  <LINK rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css" />
  <LINK rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css" />
  <LINK rel="stylesheet" href="emxUIProductCentral.css" type="text/css" />
</HEAD>
<BODY>
    <TABLE border="0" cellpadding="3"      width="99%" cellspacing="2">
        <TR>
            <TD class="heading1"><%=XSSUtil.encodeForHTML(context,i18nNow.getTypeI18NString(feature.getType(), strLocale)
			)%>: <%=XSSUtil.encodeForHTML(context,feature.getDisplayName())%></td>
        </TR>
    </TABLE>
    <TABLE border="0" cellpadding="3"      width="99%" cellspacing="2">
        <TR class="odd">
<%
    if ( strPrimaryImageInfo!= null ) {
    	//Modified code to remove deprecated servlet code 
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

%>
      <TD> <img src="<xss:encodeForHTMLAttribute><%=strImageURL%></xss:encodeForHTMLAttribute>" width="180" height="150" />  </TD>
<%
    }
    String tempStrFeature = feature.getDisplayText();
    StringBuffer sbFeature = new StringBuffer();
    StringTokenizer stFeature = new StringTokenizer(tempStrFeature, "\n");
    while(stFeature.hasMoreTokens()) {
           sbFeature.append(stFeature.nextToken());
           sbFeature.append("<BR/>");
    }
%>
      <TD   valign="justify">
        <P/>
          <%=XSSUtil.encodeForHTML(context,sbFeature.toString())%>
        </P>
      </TD>
    </TR>
    </TABLE>
</BODY>

<SCRIPT language="javascript" type="text/javaScript">
    function closeWindow() {
        parent.window.closeWindow();
    }

</SCRIPT>
</HTML>
