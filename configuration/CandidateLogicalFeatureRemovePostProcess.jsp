<%--
  LogicalFeatureDeleteProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.Model"%>
<%@page import = "matrix.util.StringList"%>

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
    StringList strObjectIdList = new StringList();
    try
    { 
      String strObjectID = "";
      StringTokenizer strTokenizer = null;
      
      for(int i=0;i<arrTableRowIds.length;i++)
      {
          if(arrTableRowIds[i].indexOf("|") > 0){
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                strTokenizer.nextToken();                                                       
                strObjectID = strTokenizer.nextToken() ;                            
                strObjectIdList.add(strObjectID);
            }
            else{
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                strObjectID = strTokenizer.nextToken() ;
                strObjectIdList.add(strObjectID);                           
            }
      }
      // call the API to remove the Candidate Logical Features from Model Context
      Model mdl = new Model(strParentID);
      mdl.removeCandidateLogicalFeatures(context, strObjectIdList);                    
      }catch(Exception e)
      {
          bIsError=true;
          session.putValue("error.message", e.getMessage());
      }
     %>
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
     
     <%
     if(!bIsError){
         action = "remove";
         }
     else{
         msg = (String)session.getValue("error.message");
      }      
      out.clear();
      response.setContentType("text/xml");
    %>
    <mxRoot>
        <!-- XSSOK -->   
        <action><![CDATA[<%= action %>]]></action>
        <!-- XSSOK -->   
        <message><![CDATA[    <%= msg %>    ]]></message>    
    </mxRoot>
  
