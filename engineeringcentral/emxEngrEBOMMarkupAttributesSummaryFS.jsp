<%--  emxEngrEBOMMarkupAttributesSummaryFS.jsp   -  FramesetPage
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>

<%
  //framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

 // fs.setDirectory("common");

  // ----------------- Do Not Edit Above ------------------------------
  String objectId = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("../common/emxDynamicAttributes.jsp");
  
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&categoryTreeName=");
  contentURL.append(emxGetParameter(request, "categoryTreeName"));
  contentURL.append("&toolbar=");
  contentURL.append("ENCEBOMMarkupDetailsToolBar");
 contentURL.append("&helpmarker=");
  contentURL.append("emxhelptriggerparameterproperties");

%>
<script>
//XSSOK
    document.location.href='<%=XSSUtil.encodeForJavaScript(context,contentURL.toString())%>';
</script>







