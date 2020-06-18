<%--
  ProductLineDeleteProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.util.StringList"%>

<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLine"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
boolean bIsError = false;
String action = "";
String msg = "";

    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String strParentID = emxGetParameter(request,"objectId"); 
    String strLanguage = context.getSession().getLanguage();
    StringList strObjectIdList = new StringList();
    boolean bInvalidState = false;
    
    if(arrTableRowIds[0].endsWith("|0")){
        %>
           <script language="javascript" type="text/javaScript">
                 alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
           </script>
        <%
    }
    else{       
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
       
    
        
            try{    
                               
                
            	 ProductLine.delete(context, strObjectIdList); 
                action = "removeandrefresh";
            }
            catch(Exception e){
                    bIsError=true;
                    action = "error";
                    msg = e.toString();                                      
            }
               
             out.clear();
             response.setContentType("text/xml");
           %>
           <mxRoot>
               <!-- XSSOK -->
               <action><![CDATA[<%= action %>]]></action>
               <!-- XSSOK -->
               <message><![CDATA[<%= msg %>]]></message>    
           </mxRoot>
           <% 
      
     }
    %>
 
