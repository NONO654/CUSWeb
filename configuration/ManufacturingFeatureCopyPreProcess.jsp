<%--
  ManufacturingFeatureCopyPreProcess.jsp
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
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.Enumeration" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
boolean bIsError = false;
String action = "";
String msg = "";

  try
  {   
      String strLanguage = context.getSession().getLanguage();
      String strObjIdContext = emxGetParameter(request, "objectId");
      String strFunctionality = emxGetParameter(request, "functionality");
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String isFromPropertyPage = emxGetParameter(request, "isFromPropertyPage");
      
      String strObjectID = null;
      String parentId = null;      
      StringBuffer emxTableRowIds = new StringBuffer();
      
      if(isFromPropertyPage != null && isFromPropertyPage.equals("true")){
          strTableRowIds = new String[]{"-1|"+strObjIdContext+"|-1|-1"};
      }
      
      for(int i=0;i<strTableRowIds.length;i++)
      {           
          emxTableRowIds = emxTableRowIds.append("&emxTableRowId="+strTableRowIds[i]);
      }
      if(strTableRowIds[0].indexOf("|") > 0){
             StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|");              
             String temp = strTokenizer.nextToken() ;
             strObjectID = strTokenizer.nextToken() ;
             if(strTokenizer.hasMoreTokens()){
                 parentId = strTokenizer.nextToken();                        
             }
      }
      else{
          strObjectID = strObjIdContext;
      }
     
      DomainObject parentObj =  new DomainObject(strObjectID);
      StringList objectSelectList = new StringList();
      objectSelectList.addElement(DomainConstants.SELECT_TYPE);
      Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
      String strParentType = (String)parentInfoTable.get("type");      
       
          if(strFunctionality != null && strFunctionality.equals("ManufacturingFeatureCopyFrom")){         
             
                  %>  
                    
                  <body>   
                  <form name="FTRManufacturingFeatureFullSearch" method="post">
                  <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=emxTableRowIds%></xss:encodeForHTMLAttribute>" />         
                  <script language="Javascript">        
                      showModalDialog('../components/emxCommonFS.jsp?functionality=ManufacturingFeatureCopyFrom&suiteKey=Configuration&HelpMarker=emxhelpfeaturecopyfrom&featureType=Configuration&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>',850,630);                  
                  </script>     
                  </form>
                  </body>                      
                  <%                  
      
          } 
          else if(strFunctionality != null && strFunctionality.equals("ManufacturingFeatureCopyTo")){
              if(strTableRowIds[0].endsWith("|0")){
                    %>
                       <script language="javascript" type="text/javaScript">
                             alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");      
                             parent.closeWindow();
                       </script>
                    <%
              } 
              else{
                  %>
                    
                  <body>   
                  <form name="FTRManufacturingFeatureFullSearch" method="post">
                    
                  <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=emxTableRowIds%></xss:encodeForHTMLAttribute>" /> 
                  <script language="Javascript">
                  //window.open('about:blank','newWin','height=575,width=575');
                  //document.FTRManufacturingFeatureFullSearch.target="newWin";
                  //document.FTRManufacturingFeatureFullSearch.action="../components/emxCommonFS.jsp?functionality=ManufacturingFeatureCopyTo&suiteKey=Configuration&HelpMarker=emxhelpfeaturecopyto&featureType=Manufacturing&multipleTableRowId=true&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>";
                  //document.FTRManufacturingFeatureFullSearch.submit();  
                                          
                  var strURL = "../components/emxCommonFS.jsp?functionality=ManufacturingFeatureCopyTo&suiteKey=Configuration&HelpMarker=emxhelpfeaturecopyto&featureType=Manufacturing&multipleTableRowId=true&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjIdContext)%><%=emxTableRowIds.toString()%>";
                  showModalDialog(strURL, 575, 575,true,'Medium');                   
                  </script>  
                  </form>
                  </body>            
                  <%       
              }              
          }
         
  }catch(Exception e)
     {
            bIsError=true;
            session.putValue("error.message", e.getMessage());
     }
     %>                     
                   
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
