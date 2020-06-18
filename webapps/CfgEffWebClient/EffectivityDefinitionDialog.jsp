<%-- EffectivityIntermediate.jsp --

    Copyright (c) 1992-2018 Enovia Dassault Systemes.All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only and does not evidence any actual
    or intended publication of such program

    static const char RCSID[] =$Id: EffectivityIntermediate.jsp.rca 1.6.3.2 Wed Oct 22 15:52:02 2008 przemek Experimental przemek przemek $
--%>
<%-- Common Includes --%>

<%@page import = "com.matrixone.apps.domain.util.i18nNow" %>

<%@include file = "../../emxI18NMethods.inc"%>
<%@include file = "../../emxUICommonAppInclude.inc"%>
<%@include file = "../../common/emxUIConstantsInclude.inc"%>

<%
String acceptLanguage = request.getHeader("Accept-Language");
//Code to be inserted for the bundle to be read from prop file.
String bundle = "EffectivityStringResource";
%>
<framework:localize id="i18nId" bundle="EffectivityStringResource" locale='<%=acceptLanguage%>'/>

<%
  out.clear();
  String urlStr = "";
  boolean bIsError = false;
  try
  {
      String objectId = emxGetParameter(request,"objectId");
      String relId = emxGetParameter(request,"relId");
      String rootObjectId = emxGetParameter(request,"rootObjectId");   
      
      String fieldNameActual = emxGetParameter(request,"fieldNameActual");
      String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
      
      if (rootObjectId == null)	rootObjectId = "";
      
      if(!rootObjectId.equalsIgnoreCase(objectId))
      {   
    	  urlStr = "EffectivityDefinitionDialog.html?id="+relId + "&rootid="+rootObjectId +"&fieldNameActual="+fieldNameActual+"&fieldNameDisplay="+fieldNameDisplay+"&calledFrom=web";
      }
      else
      {
          %>
          <script>
         rootNode =true;
          </script>
          <%
      }
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>
<html>
<head>

<script>
var rootNode;
function generateURL()
 {
     if(rootNode)
     {
         getTopWindow().window.alert("<%=i18nStringNowUtil("Effectivity.Root.StructureEffectivity", bundle,acceptLanguage)%>");
         getTopWindow().window.close();
     }
     else
     {   
          var url = '<%=urlStr%>';
          var frame = document.getElementById("EffectivityDD");
          alert("url: " + url);
          frame.setAttribute("src",url);
     }
 }
          
</script>
</head>
<body onLoad = "generateURL();">
<iframe id="EffectivityDD"  style="overflow:hidden;width:100%;height:100%;border:0"></iframe>
</body>
</html>  
