<%--
  ProductLineAddExistingPreProcess.jsp
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

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
boolean bIsError = false;

  try
  {	  
	  String strLanguage = context.getSession().getLanguage();
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String strObjectID = "";
      String parentId = "";      
      
      StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|");    
      if(strTableRowIds[0].indexOf("|") > 0){                        
        String temp = strTokenizer.nextToken();
        strObjectID = strTokenizer.nextToken();
        if(strTokenizer.hasMoreTokens()){
          parentId = strTokenizer.nextToken();                        
        }
      }
      else{
              strObjectID = strTokenizer.nextToken();
      }
      String strWrongParentType = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBeProductLine", strLanguage);
      DomainObject parentObj =  new DomainObject(strObjectID);
      StringList objectSelectList = new StringList();
      StringBuilder typeKind = new StringBuilder(50);
	  typeKind.append("type.kindof[");
	  typeKind.append(ProductLineConstants.TYPE_PRODUCT_LINE);
	  typeKind.append("]");
	  objectSelectList.addElement(typeKind.toString());          
      Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
      String type = (String) parentInfoTable.get(typeKind.toString());
      if(!Boolean.valueOf(type)){
      %>
      <script language="javascript" type="text/javaScript">
            alert("<xss:encodeForJavaScript><%=strWrongParentType%></xss:encodeForJavaScript>");
      </script>
     <%
            return;
  		}
       %>
%>
              <body>   
              <form name="PLCProductLineFullSearch" method="post">
              <script language="Javascript">
              var url="../common/emxFullSearch.jsp?field=TYPES=type_ProductLine&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&excludeOIDprogram=emxPLCCommon:excludeAvailableProductLine&table=PLCSearchProductLinesTable&selection=multiple&hideHeader=true&relationship=relationship_SubProductLines&submitAction=refreshCaller&HelpMarker=emxhelpfullsearch&submitURL=../productline/ProductLineAddExistingPostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline";
              showModalDialog(url,575,575,"true","Large");
              </script>
              </form>
              </body>
              <%     
  }catch(Exception e){
 	    bIsError=true;
 	    session.putValue("error.message", e.getMessage());
  }
  %>
  
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
