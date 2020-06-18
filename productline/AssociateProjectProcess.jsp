<%--  TaskChooserFS

  Frameset for Task Chooser Page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

--%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
 <%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%--Breaks without the useBean--%>
<%@page import="com.matrixone.apps.productline.*"%>
 <% try{
	 String objectId = emxGetParameter(request, "objectId");
	 Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");
	 String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
     String arrObjectIds[] = null;
     boolean bIsFromTree = false;
     if(arrTableRowIds == null ){
         %>
             <script language="javascript">
                 alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.PleaseSelectProject</emxUtil:i18n>");  
             </script>
         <%          
     }else{
     if (arrTableRowIds[0].indexOf("|") >= 0 )
     {
       arrObjectIds = com.matrixone.apps.productline.ProductLineUtil.getObjectIds(arrTableRowIds);
       bIsFromTree = true;
     }
     else{
       arrObjectIds   = arrTableRowIds;
     }
       productBean.setId(objectId);
       productBean.associateProjects(context,arrObjectIds);%>
       <script language="javascript" type="text/javaScript">
                getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
                getTopWindow().closeWindow();
       </script>    
     <%
     }
    }catch(Exception e){
    	%>
        <script language="javascript">
            alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CanNotConnectProject</emxUtil:i18n>");            
        </script>
   		<%                 
    }
           //Modified END : YOX : V6R2010 : Bug 369503
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
