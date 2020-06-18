<%--  emxLibraryCentralObjectPreRemoveContentsProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxLibraryCentralObjectPreRemoveContentsProcess.jsp.rca 1.4 Wed Oct 22 16:02:21 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>
<html>
<head>
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
  <form name="formForward" method="post" target = "listHidden" action="emxLibraryCentralObjectRemoveContentsProcess.jsp">
  <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<%
  final String LC_STRING_RESOURCE = "emxLibraryCentralStringResource";
  String strStandardConfirmMessage = EnoviaResourceBundle.getProperty(context,LC_STRING_RESOURCE, new Locale(sLanguage),"emxLibraryCentral.Remove.ConfirmMsg");

    String parentId = emxGetParameter(request, "objectId");
    String childIds[]    = emxGetParameterValues(request,"emxTableRowId");
    String childId = "";
    for(int i=0; i<childIds.length;i++ )
    {
        childId += childIds[i]+",";
    }
%>
	<input type="hidden" name= "objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,parentId)%>" />
	<input type="hidden" name= "childIds" value="<%=XSSUtil.encodeForHTMLAttribute(context,childId)%>" />

<script language="javascript">
     var isToBeContinued = true;
       isToBeContinued = window.confirm("<xss:encodeForJavaScript><%=strStandardConfirmMessage%></xss:encodeForJavaScript>");

         var listHiddenFrame = findFrame(getTopWindow(),"listHidden");

       if (isToBeContinued)
       {
          <%-- listHiddenFrame.location.href = "emxLibraryCentralObjectRemoveContentsProcess.jsp?objectId=<xss:encodeForJavaScript><%=parentId%></xss:encodeForJavaScript>&childIds=<xss:encodeForJavaScript><%=childId%></xss:encodeForJavaScript>&ENO_CSRF_TOKEN=<xss:encodeForJavaScript><%=csrfTokenValue%></xss:encodeForJavaScript>"; --%>
			document.formForward.submit();
       }
</script>


  </form>
</body>
</html>


