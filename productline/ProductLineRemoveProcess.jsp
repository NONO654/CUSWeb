<%--
  ProductLineRemoveProcess.jsp
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

<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLine"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
boolean bIsError = false;

  try
  {   
      String strLanguage = context.getSession().getLanguage();     
      
      String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String strParentId = emxGetParameter(request, "parentOID");
               
      String strParentType = new DomainObject(strParentId).getType(context);
            
      if(arrTableRowIds!=null && arrTableRowIds[0].endsWith("|0")){
         %>
            <script language="javascript" type="text/javaScript">
                  alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
            </script>
         <%
      }
      else{
          StringList strObjectIdList = new StringList();
          StringList strParentIdList = new StringList();
          StringTokenizer strTokenizer = null;
          MapList mLstParentChildDetails = new MapList();
          
          for(int i=0;i<arrTableRowIds.length;i++)
          {
              Map parentChid = new HashMap();
              if(arrTableRowIds[i].indexOf("|") > 0){
                    strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");  
                    String strRelID = strTokenizer.nextToken();
                    String strObjId = strTokenizer.nextToken();
                    String strParentObjId = strTokenizer.nextToken();
                    strObjectIdList.add(strObjId);
                    strParentIdList.add(strParentObjId);
                    parentChid.put("ParentOID",strParentObjId);
                    parentChid.put("ChildOID",strObjId);
                    parentChid.put("RelId",strRelID);
                }
                else{
                    strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                    String strObjId = strTokenizer.nextToken();
                    String strParentObjId = strTokenizer.nextToken();
                    strObjectIdList.add(strObjId);
                    strParentIdList.add(strParentObjId);
                    parentChid.put("ParentOID",strParentObjId);
                    parentChid.put("ChildOID",strObjId);
                }
              mLstParentChildDetails.add(parentChid);
              
          }
          
        //  boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strParentIdList);
       //   boolean isCFDV = ConfigurationFeature.canRemoveDesignVariantFromProduct(context,mLstParentChildDetails);
          
       
            %>
            <script language="javascript" type="text/javaScript">            
                parent.editableTable.cut();
            </script>
            <% 
         
      }
  }
  catch(Exception e){
        bIsError=true;
        session.putValue("error.message", e.getMessage());
   }
   %>
   <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
