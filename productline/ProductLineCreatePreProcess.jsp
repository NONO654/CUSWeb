<%--
  ProductLineCreatePreProcess.jsp
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
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


 <%@page import="java.util.HashMap"%>                
<%
boolean bIsError = false;

  try
  {   
      String strLanguage = context.getSession().getLanguage();      
      String strObjIdContext = emxGetParameter(request, "objectId");
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String strCreationType = emxGetParameter(request, "strCreationType");     
      String strHelpMarker = emxGetParameter(request, "HelpMarker");
      String strMode = emxGetParameter(request, "mode");
      String strUIContext = emxGetParameter(request, "UIContext");
      String strObjectID = null;      
      String heading = "emxProductLine.Form.Heading.ProductLineCreate";
      String formType = "type_CreateProductLine"; 
      HashMap paramMap = new HashMap(); 
      paramMap.put("objectId", strObjIdContext);  
                  
    
      String strEditModeNotSelected = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProdutLine.ProductLine.Create.EditModeNotSelected", strLanguage);
      String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProdutLine.RowSelect.Single", strLanguage);        
      String strWrongParentType = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBeProductLine", strLanguage);
      
      if(strTableRowIds != null && strTableRowIds.length > 1){
          %>
          <script language="javascript" type="text/javaScript">
                alert("<xss:encodeForJavaScript><%=strRowSelectSingle%></xss:encodeForJavaScript>");                
          </script>
         <%       
      } 
      else if((strUIContext!= null && strUIContext.equals("myDesk") && strTableRowIds != null && strTableRowIds.length!=0) || (strUIContext!= null && strUIContext.equals("context")) ){
    	  if((strUIContext.equals("myDesk") && strMode != null && strMode.equals("edit")) || strUIContext.equals("context")){          
       
              StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|"); 
              if(strTableRowIds[0].indexOf("|") > 0){                       
                  String temp = strTokenizer.nextToken() ;
                  strObjectID = strTokenizer.nextToken() ;
              }
              else{
                  strObjectID = strTokenizer.nextToken();
              }                   
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
                  <body>   
                  <form name="MyDeskProductLineCreate" method="post">
                  <script language="Javascript">
                      var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=false&showApply=true&autoNameChecked=false&nameField=both&submitAction=none&postProcessJPO=emxProductLine:connectSubProductLine&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=ProductLine&postProcessURL=../productline/ProductLineCreatePostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>";
                      getTopWindow().showSlideInDialog(submitURL, "true");
                  </script>
                  </form>
                  </body>
                  <%     
              
          }
          else{
              %>
              <script language="javascript" type="text/javaScript">
                    alert("<xss:encodeForJavaScript><%=strEditModeNotSelected%></xss:encodeForJavaScript>");                
              </script>
             <%
          }          
       
      }else{
          %>
          <body>   
          <form name="MyDeskProductLineCreate" method="post">
          <script language="Javascript">
              var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=false&showApply=true&autoNameChecked=false&nameField=both&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=ProductLine&postProcessJPO=emxProductLine:connectSubProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=ProductLine&submitAction=refreshCaller&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>";
              getTopWindow().showSlideInDialog(submitURL, "true");
          </script>
          </form>
          </body>
          <%                                               
      } 
  }
  catch(Exception e){
            bIsError=true;
            session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
