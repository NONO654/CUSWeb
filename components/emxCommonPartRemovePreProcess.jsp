<%--  emxCommonPartRemovePreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonPartRemovePreProcess.jsp.rca 1.7 Wed Oct 22 16:18:45 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
 
  <script language="javascript" >

    function findFrame(objWindow, strName) {
      var objFrame = objWindow.frames[strName];
      if (!objFrame) {
      for (var i=0; i < objWindow.frames.length && !objFrame; i++)
        objFrame = findFrame(objWindow.frames[i], strName);
      }
      return objFrame;
    }

  </script>
</head>

<body>
<form name="formForward" method="post" action="emxCommonPartRemoveProcess.jsp">

<%
  final String COM_STRING_RESOURCE = "emxComponentsStringResource";
  String strStandardConfirmMessage = EnoviaResourceBundle.getProperty(context, COM_STRING_RESOURCE, context.getLocale(), "emxComponents.Remove.ConfirmMsg");
  String parentId = emxGetParameter(request, "objectId");
  String childIds[] = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
  String childId = "";
  for(int i=0; i<childIds.length;i++ )
  {
    childId += childIds[i]+",";
  }

  String removeMode = emxGetParameter(request, "removeMode");
%>
<script language="javascript">
     var isToBeContinued = true;
       isToBeContinued = window.confirm("<%=strStandardConfirmMessage%>");
     var listHiddenFrame = findFrame(getTopWindow(),"listHidden");
       if (isToBeContinued)
       {
           var url = "emxCommonPartRemoveProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context, parentId)%>&childIds=<%=XSSUtil.encodeForURL(context, childId)%>&fromPreProcess=true&removeMode=<%=XSSUtil.encodeForURL(context, removeMode)%>";
           submitWithCSRF(url,listHiddenFrame);
        
       }
</script>

  </form>
</body>
</html>
