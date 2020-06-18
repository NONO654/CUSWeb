

<%--  emxProgramChooserIntermediate.jsp  -

   Intermediate JSP used to update the information in the relevent fields.
   
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/emxProgramChooserIntermediate.jsp 1.3.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";
--%>

<%@include file = "../emxUITopInclude.inc"%>

<script language= "javascript">
  function Update()
    {

	  //top.getWindowOpener().document.forms[0] 
      getTopWindow().getWindowOpener().document.forms[0].<%= XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"hdnFieldName"))%>.value="<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request,"hdnProgramName"))%>";
      getTopWindow().getWindowOpener().document.forms[0].Program.value="<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"hdnProgramName"))%>";
      
      getTopWindow().closeWindow();
    }
</script> 

<html>
  <body onload = Update()>
  </body>
</html>
