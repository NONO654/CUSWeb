<%--  emxAddToPortfolioProcess.jsp  

      Copyright (c) 1999-2018 Dassault Systemes.
     
      All Rights Reserved.
      This program contains proprietary and trade secret information
      of MatrixOne, Inc.  Copyright notice is precautionary only and
      does not evidence any actual or intended publication of such program
    --%>
    
<%-- Include JSP for error handling --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>

<%@page import = "com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "matrix.db.Context"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>

<script>
    bRefreshFlag = false;
</script>
<%  
boolean bFlag=false;

try
{
       boolean bIsPresent                  = false;
       //extract Table Row ids of the checkboxes selected.
       String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");

       StringList strSelectedPortFolioList = new StringList();
       String tempRelID = "";
       String strObjectID = "";
       StringTokenizer strTokenizer = null;
       
       for(int i=0;i<arrTableRowIds.length;i++)
       {
           strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
           if(arrTableRowIds[i].indexOf("|") > 0){
                 tempRelID = strTokenizer.nextToken();
                 strObjectID = strTokenizer.nextToken() ;                                 
                 strSelectedPortFolioList.add(strObjectID);
             }
             else{
                 strObjectID = strTokenizer.nextToken() ;
                 strSelectedPortFolioList.add(strObjectID);                           
             }
       }
       
       // iterate through each selected portfolio in the search results and make connections
       StringList objectSelects = new StringList(DomainObject.SELECT_ID);
       StringList relSelects = new StringList(DomainRelationship.SELECT_ID);
       short sRecursionLevel = 1;
       String strRelName = ProductLineConstants.RELATIONSHIP_PORTFOLIO;

       //Get the symbolic relationship name from the requestmap
       String strSrcDestRelNameSymb = emxGetParameter(request, "srcDestRelName");
       String strSrcDestRelName = "";

       //Get the actual relationship name
       if (strSrcDestRelNameSymb != null)
       {
             strSrcDestRelName = PropertyUtil.getSchemaProperty(context,strSrcDestRelNameSymb);
       }
       
       // convert the contextId string to string array for connections
       String strContentId = emxGetParameter(request,"contentId");
       String[] arrContextIds=strContentId.split(",");       
       
       for(int i=0; i<strSelectedPortFolioList.size();i++){
    	   if(!bIsPresent){
  	           DomainObject domPortFolio = DomainObject.newInstance(context,strSelectedPortFolioList.get(i).toString());
   	           MapList relBusObjPageList = new MapList();
   	           relBusObjPageList = domPortFolio.getRelatedObjects(context, strRelName, "*", objectSelects, relSelects, false, true, sRecursionLevel, "","");
   	           
   	           //The checking for the Contents 
   	           for (int j = 0;j < relBusObjPageList.size() ; j++)
   	           {
   	               //The state is retreived from the MapList obtained.
   	               String strObjId = (String)((Hashtable)relBusObjPageList.get(j)).get(DomainObject.SELECT_ID);
   	               //Check whether the any of the models selected is already connected to the chosen Portfolio
   	               if(strContentId.contains(strObjId)){
   	                   bIsPresent=true;
   	                   break;
   	               }
   	            }
    	   }
        }
       if(!bIsPresent)
       {
             //start the transaction
             ContextUtil.startTransaction(context, true);
             for(int i=0; i<strSelectedPortFolioList.size();i++){
                 DomainObject domPortFolio = DomainObject.newInstance(context,strSelectedPortFolioList.get(i).toString());
                 //connect the portfolio to the model/products
                 DomainRelationship.connect(context, domPortFolio, strSrcDestRelName,true,arrContextIds);
             }
             //End the transaction
             ContextUtil.commitTransaction(context);
             %>
             <script language="javascript" type="text/javaScript">
               msg = "<%=i18nStringNowUtil("emxProduct.Alert.AddedToPortfolio",bundle,acceptLanguage)%>";
               alert(msg);
               bRefreshFlag = false;
               window.parent.parent.window.closeWindow();
             </script>
            <%  
        }
        else if(bIsPresent)
        {
          %>
             <script language="javascript" type="text/javaScript">
               msg = "<%=i18nStringNowUtil("emxProduct.Alert.AlreadyExistsInPortfolio",bundle,acceptLanguage)%>";
               alert(msg);
               window.parent.parent.window.closeWindow();
               bRefreshFlag = true;
             </script>
          <%
        }
 }
 catch (Exception e)
 {
       ContextUtil.abortTransaction(context);
       String strAlertString = "emxProduct.Alert." + e.getMessage();
       String i18nErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);
       
       if(i18nErrorMessage.equals(DomainConstants.EMPTY_STRING)){
         bFlag=true;
         session.putValue("error.message", e.getMessage());
       }else{
         session.putValue("error.message", i18nErrorMessage);
       }
 }
    %>

    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    <%
        if (bFlag)
        {
    %>
        <!--Javascript to bring back to the previous page-->
        <script language="javascript" type="text/javaScript">
          history.back();
        </script>
    <%
        }
    %>
<!--Javascript to refresh the footer frame-->
<script>
        if(bRefreshFlag)
        {
            footerFrame = findFrame(parent,"listFoot");
            if(footerFrame != null)
            {
                footerFrame.location.reload();
                bRefreshFlag = false;
            }
        }
</script>
