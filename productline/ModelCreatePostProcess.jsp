<%--
  ModelCreatePostProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript" src="emxUIMouseEvents.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITreeUtil.js"></script>

<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%
    boolean bIsError = false;
	String strProductLineId= emxGetParameter(request,"objectId");
    com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
    formBean.processForm(session,request);
    String strModelId = (String)formBean.getElementValue("newObjectId");
    String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String strJsTreeID = (String)formBean.getElementValue("jsTreeID");
    if(strTableRowIds != null){
    	StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|"); 
        if(strTableRowIds[0].indexOf("|") > 0){                       
            String temp = strTokenizer.nextToken() ;
            String strObjectID = strTokenizer.nextToken() ;
                    strProductLineId = strObjectID;
        }
    }
     %>
    <script language="javascript" type="text/javaScript">
       var contentFrameObj = findFrame(parent.getTopWindow(),"content");
       if(contentFrameObj.addStructureTreeNode)
       contentFrameObj.addStructureTreeNode("<%=XSSUtil.encodeForJavaScript(context,strModelId)%>","<%=XSSUtil.encodeForJavaScript(context,strProductLineId)%>","<%=XSSUtil.encodeForJavaScript(context,strJsTreeID)%>","Productline");
       try
       {        
          var topFrameObj = findFrame(parent.getTopWindow(),"_top");
          topFrameObj.window.focus();
       }catch(e){
           alert(e);      
       }        
       </script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
