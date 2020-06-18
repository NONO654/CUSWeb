<%-- ProductConfigurationUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/PartProductConfigurationUtil.jsp 1.3.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$: ProductConfigurationUtil.jsp";
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.*" %>
<%@page import="com.matrixone.apps.productline.*" %>
<%@page import = "com.matrixone.apps.configuration.*"%>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>

<%
  ProductConfiguration prodConf = (ProductConfiguration)DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCT_CONFIGURATION,"Configuration");
  String productConfigurationId = null;
  String strObjectId            = emxGetParameter(request, "objectId");
  String strFunctionality       = emxGetParameter(request, "functionality");
  String strPRCFSParam1         = emxGetParameter(request, "PRCFSParam1");
  String strResourceFileId      = emxGetParameter(request, "StringResourceFileId");
  String strSuiteDirectory      = emxGetParameter(request, "SuiteDirectory");
  String strSuiteKey            = emxGetParameter(request, "suiteKey");
  String strParentOID           = emxGetParameter(request, "parentOID");
  String strMode                = emxGetParameter(request, "mode");
  try {
    // Load the second page of the Flat view create process.
    String strPartId      = emxGetParameter(request, "hidPartId");

  /*
   * Remove the session object ProductConfiguration, if it exists.
   * this may occur if the user goes to the first page from the
   * Feature Select page.
   */

    String strName           = emxGetParameter(request, "txtProductConfigurationName");
    String strRevision       = emxGetParameter(request, "hidDefaultRevision");
    String strDescription    = emxGetParameter(request, "txtProductConfigurationDescription");
    String strPolicy         = emxGetParameter(request, "txtProductConfigurationPolicy");
    String strVault          = emxGetParameter(request, "txtProductConfigurationVault");
    String strOwner          = emxGetParameter(request, "txtProductConfigurationOwner");
    String strClassification = emxGetParameter(request, "radProductConfigurationPurposeValue");
    String strProductId      = emxGetParameter(request, "hidProductId");

    if(strProductId == null || "null".equals(strProductId))
    {
      strProductId = "";
    }

    HashMap map = new HashMap();
    map.put("name", strName);
    map.put("revision" , strRevision);
    map.put("description", strDescription);
    map.put("policy", strPolicy);
    map.put("vault", strVault);
    map.put("owner", strOwner);
    map.put("classification", strClassification);
    map.put("productId", strProductId);
    map.put("partId", strPartId);

    // create & connetc product Configuration
   productConfigurationId = prodConf.generateProductConfigurationFromPart(context,map);
%>

<HTML>
    <BODY class="white" onload=loadUtil("<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>","<%=XSSUtil.encodeForJavaScript(context,strMode)%>")>
    <FORM name="ProductConfigurationUtil" method="post" >
    </FORM>
    </BODY>

  <SCRIPT language="javascript" type="text/javaScript">
    function loadUtil(strObjectId,strMode) {
      if(strMode=="create")
      {
        var formName = document.ProductConfigurationUtil;
        formName.target= "_top";
        formName.action="ProductConfigurationFS.jsp?FSmode=featureSelect&PRCFSParam2=createNew&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationCreateFlatViewContentFSInstance&relId=&suiteKey=Configuration";
        formName.submit();
        getTopWindow().window.closeWindow();
      }
      else
      {
        document.location.href="../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,productConfigurationId)%>";
        getTopWindow().window.resizeTo(875,550)
      }
    }

  </SCRIPT>

</HTML>
<%
  } // End of the try block
  catch (Exception ex) {
    String strForwardURL="../components/emxCommonFS.jsp?functionality="+strFunctionality+"&PRCFSParam1="+strPRCFSParam1+"&Mode="+strMode+"&suiteKey="+strSuiteKey+"&StringResourceFileId="+strResourceFileId+"&SuiteDirectory="+strSuiteDirectory+"&objectId="+strObjectId+"&parentOID="+strParentOID;
    session.putValue("error.message", ex.getMessage());
    
%>
   <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   <script language="JavaScript">

     //window.location.href = "<%=strForwardURL%>";
     getTopWindow().closeWindow();
   </script>

 <%
  }// end of catch
%>
