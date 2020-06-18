<%--
  ViewGBOMSummaryPreProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /web/configuration/PartUtil.jsp 1.42.2.2.1.1.1.3.1.1 Wed Jan 07 13:05:24 2009 GMT ds-shbehera Experimental$";

--%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>

<%@page import="java.util.StringTokenizer"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>

<%@page import="com.matrixone.apps.domain.util.mxType"%>
<html>
<head>
    <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
    <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
</head>
<body>
<%
try{
  String strMode = emxGetParameter(request, "mode");
  //Start Right Mouse Button for GBOM Part table
  if(strMode.equalsIgnoreCase("RMBGBOM"))
    {
        String objId = (String)emxGetParameter(request, "objectId");
        String prodId = (String)emxGetParameter(request, "productID");
        StringTokenizer st = new StringTokenizer(objId,",");
        String strObject = st.nextToken();
        DomainObject domObj = new DomainObject(strObject);
        String strType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
        if(mxType.isOfParentType(context,strType,ConfigurationConstants.TYPE_LOGICAL_STRUCTURES))
        {   
%>
      <script language="javascript" type="text/javaScript">          
        var url= "../common/emxPortal.jsp?portal=FTRProductContextViewGBOMPartTablePortal&header=emxProduct.GBOMPortal.ViewGBOMPartTableHeader&objectId=<%=XSSUtil.encodeForURL(context,objId)%>&mode=portal&suiteKey=Configuration&prodId=<%=XSSUtil.encodeForURL(context,prodId)%>&HelpMarker=emxhelpgbomparttableview";
        //showNonModalDialog(url,860,600,true, '', 'MediumTall');
          showModalDialog(url,860,600,true,'MediumTall');
      </script>
<%
        }else{
         String strAlertMessage = i18nNow.getI18nString("emxProduct.Alert.SelectLogicalFeature",bundle,acceptLanguage);
%>
              <Script>
              alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessage)%>");
              </Script>           
<%
            }   
    }else{//view GBOM summary called form toolbar

  //contextProduct id
  String strObjectId = emxGetParameter(request, "objectId");
  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
  String arrObjectIds[] = null;
  arrObjectIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
  StringTokenizer st = new StringTokenizer(arrObjectIds[0],"|");
  //Logical Feature Id
  String strObject = st.nextToken();
  DomainObject domObj = new DomainObject(strObject);
  String strType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
  if(mxType.isOfParentType(context,strType,ConfigurationConstants.TYPE_LOGICAL_STRUCTURES)){ 
%>
    <script language="javascript" type="text/javaScript">
      var url= "../common/emxPortal.jsp?portal=FTRProductContextViewGBOMPartTablePortal&header=emxProduct.GBOMPortal.ViewGBOMPartTableHeader&objectId=<%=XSSUtil.encodeForURL(context,strObject)%>&mode=portal&suiteKey=Configuration&prodId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&HelpMarker=emxhelpgbomparttableview";
      //showNonModalDialog(url,860,600,true, '', 'MediumTall');
        showModalDialog(url,860,600,true,'MediumTall');
    </script>
<%
   }else{     
      String strAlertMessage = i18nNow.getI18nString("emxProduct.Alert.SelectLogicalFeature",bundle,acceptLanguage);
%>
    <script language="javascript" type="text/javaScript">
            alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessage)%>");
    </script>           
<%
  }
    }
 }
catch(Exception e)
{
	throw new FrameworkException(e);
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
