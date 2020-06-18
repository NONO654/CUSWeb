<%--
  ProductCreatePostProcess.jsp

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

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%
    boolean bIsError = false;
    String strModelId= emxGetParameter(request,"objectId");
    com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
    formBean.processForm(session,request);
    String strProductId = (String)formBean.getElementValue("newObjectId");
    String strJsTreeID = (String)formBean.getElementValue("jsTreeID");
     %>
    <script language="javascript" type="text/javaScript">
   
       var contentFrameObj = findFrame(parent.getTopWindow(),"content");
       if(contentFrameObj.addStructureTreeNode)  
       contentFrameObj.addStructureTreeNode("<%=XSSUtil.encodeForJavaScript(context,strProductId)%>","<%=XSSUtil.encodeForJavaScript(context,strModelId)%>","<%=XSSUtil.encodeForJavaScript(context,strJsTreeID)%>","Model");
       try
       {        
          var topFrameObj = findFrame(parent.getTopWindow(),"_top");
          topFrameObj.window.focus();
          contentFrameObj.editableTable.loadData();
          contentFrameObj.rebuildView();
       }catch(e){
           alert(e);      
       }        
       </script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
