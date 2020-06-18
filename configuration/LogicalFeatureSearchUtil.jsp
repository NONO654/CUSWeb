<%--
  LogicalFeatureSearchUtil.jsp
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

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.util.StringTokenizer"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%
  boolean bIsError = false;
// Modified for IR IR-030496V6R2011WIM
String action = "";
String msg = "";
String strMode = emxGetParameter(request,"mode");
  try
  {
     String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
   
     if(strContextObjectId==null)
         {   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}
 
     else
         {  
                
        if (strMode.equalsIgnoreCase("Chooser"))
             {
             String strSearchMode = emxGetParameter(request, "chooserType");
                 if (strSearchMode.equals("CustomChooser") || strSearchMode.equals("FormChooser"))
                  {   
                      
                      String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                      String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                      
                      StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
                      
                      DomainObject objContext = new DomainObject(strObjectId);
                      String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
                      %>
                      <script language="javascript" type="text/javaScript">
                      
                          var vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          var vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                         
                          vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                         
                        
                          //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                          getTopWindow().closeWindow();
                      
                        </script>
                   <%
                  } else if (strSearchMode.equals("PersonChooser"))
                  {
                      String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                      String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

                      StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ;

                      DomainObject objContext = new DomainObject(strObjectId);
                      String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);

                    %>
                      <script language="javascript" type="text/javaScript">

                          var vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          var vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                          vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                          getTopWindow().closeWindow();

                        </script>
                    <%
                    }
                  else if (strSearchMode.equals("SlideInFormChooser"))
                 {   
                      
                      String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                      String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                      
                      StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
                      
                      DomainObject objContext = new DomainObject(strObjectId);
                      String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
                      %>
                      <script language="javascript" type="text/javaScript">

                      var openerObj = getTopWindow().getWindowOpener();
                      if(openerObj != null){
                          var vfieldNameActual = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          var vfieldNameDisplay = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");

                          vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;

                          //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                          getTopWindow().closeWindow();
                      }
                      else{
                          var vfieldNameActual = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          var vfieldNameDisplay = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");

                          vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                      }
                        </script>
                   <%
                  }
             }
         
        
     
     }     
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
    //emxNavErrorObject.addMessage(e.toString().trim());
  }// End of main Try-catck block
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
// Modified for IR IR-030496V6R2011WIM
//IR-037276V6R2011- IF there is no exception in above delete opearation then refresh Page.      
if(!bIsError && strMode.equalsIgnoreCase("searchDelete"))
    {       
      action = "remove";
      msg = "";
      out.clear();
      response.setContentType("text/xml");
    %>
    <mxRoot>
        <!-- XSSOK -->   
        <action><![CDATA[<%= action %>]]></action>
        <!-- XSSOK -->   
        <message><![CDATA[    <%= msg %>    ]]></message>    
    </mxRoot>
    <%
    }
 %>
