
<%--
  PortfolioViewTimeline.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
--%>
<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>


<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>


<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<%
    try
    {
        //Get the mode and selected table row ids
        String strMode = emxGetParameter(request, "mode");
        String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");

        //Form the URL to call the Roadmap JSP
        StringBuffer sbHref = new StringBuffer("../common/emxTimeline.jsp?");
        sbHref.append("&program=emxPLCTimeline:getRoadmap");
        sbHref.append("&filterCommand=PLCFilterTimelineCommand");
        sbHref.append("&header=emxProduct.Header.ProductTimeline");
        sbHref.append("&suiteKey=ProductLine");

        
        
        StringList strObjectIdList = new StringList();
        String tempRelID = "";
        String strObjectID = "";
        StringTokenizer strTokenizer = null;
        
        for(int i=0;i<arrTableRowIds.length;i++)
        {
            strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
            if(arrTableRowIds[i].indexOf("|") > 0){
                  tempRelID = strTokenizer.nextToken();
                  strObjectID = strTokenizer.nextToken() ;                                 
                  strObjectIdList.add(strObjectID);
              }
              else{
                  strObjectID = strTokenizer.nextToken() ;
                  strObjectIdList.add(strObjectID);                           
              }
        }
        String strSelectedModels = "";
        String[] arrObjectIds= new String[strObjectIdList.size()];
        
        for(int i=0; i<strObjectIdList.size();i++){
            arrObjectIds[i] = (String)strObjectIdList.get(i);
        }        
        
        
        //Determine the method to be called depending upon the mode
        String strMethodName = "";
        if (strMode.equalsIgnoreCase("List")){
            strMethodName = "getPortfolioProductIds";
        }else if(strMode.equalsIgnoreCase("Contents")){
            strMethodName = "getPortfolioContentProductIds";
        }
            
        String strProgName = "emxPortfolio";
        String[] initArgs = new String[0];

        //Call the JPO method to get the list of object ids for which
        //timeline is to be obtained.
        java.util.List lstProdList = (MapList) JPO.invoke(context,
                                                                     strProgName, 
                                                                     initArgs,
                                                                     strMethodName, 
                                                                     arrObjectIds, 
                                                                     java.util.List.class);
        //Add the object ids to the URL
        if(lstProdList!=null&&!lstProdList.isEmpty()){
            for(int i=0;i<lstProdList.size();i++){
                sbHref.append("&emxTableRowId=");
                sbHref.append((String)((Map)lstProdList.get(i)).get(DomainConstants.SELECT_ID));
            }
        }
%>
    <script language="javascript" type="text/javaScript">
    //<![CDATA[
		//showNonModalDialog("<%=XSSUtil.encodeForJavaScript(context,sbHref.toString())%>" ,"true","Large");
		showModalDialog("<%=XSSUtil.encodeForJavaScript(context,sbHref.toString())%>" ,"true","Large");
    //]]>
  </script>
<%
    }catch(Exception e){
        String strAlertString = "emxProduct.Alert." + e.getMessage();
        String i18nErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);
        if(i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
        {
            session.putValue("error.message", e.getMessage());
        }else{
            session.putValue("error.message", i18nErrorMessage);
        }
    }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>
