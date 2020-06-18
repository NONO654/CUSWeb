<%--
  FTRRefreshTreePostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<html>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreTree.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
</head>
<%
  try
  {
	  String parentId = emxGetParameter(request, "objectId");
	  String newObjectId = emxGetParameter(request, "newObjectId");
	  %>
      <script language="javascript" type="text/javaScript">
      var parentId = "<%=XSSUtil.encodeForJavaScript(context,parentId)%>"
      var objectId = "<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>"

   // Below code is used to Add node to Tree
      var contentFrame = findFrame(getTopWindow(), "content");
      if(contentFrame !== null && contentFrame !== undefined){
         if(typeof contentFrame.addMultipleStructureNodes !== 'undefined' && 
       		typeof contentFrame.addMultipleStructureNodes === 'function')
       	{		
   		  contentFrame.addMultipleStructureNodes(objectId, parentId, '', '', false);
        }            
      }   
       </script>
       <%
  }catch(Exception e)
  {     
        %>
        <script language="javascript" type="text/javaScript">
         alert("<%=XSSUtil.encodeForJavaScript(context,e.getMessage())%>");                 
        </script>
        <%    
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
