<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxLibraryCentralmportAG.jsp.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</script>


<%
	String targetPage="emxLibraryCentralValidateProcess.jsp";
	String resourceBundle           = "emxLibraryCentralStringResource";
	String language                = request.getHeader("Accept-Language");
	String AG_ALREADY_EXISTS        = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxMultipleClassification.AttributeGroup.AttributeGroupAlreadyExists");
	String NO_AG_ERROR				= EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxMultipleClassification.ImportFile.NoErrorMessage");
	String isAGImport=emxGetParameter(request,"isAGImport");
	String isbkgProcess=emxGetParameter(request,"bkgprocess");
	session.setAttribute("bkgprocess",isbkgProcess);

%>
 
    <body class="slide-in-panel editable">
<form name="importAG" method="post" enctype="multipart/form-data" action="<xss:encodeForHTML><%=targetPage%></xss:encodeForHTML>">
      <table width="100%">
	    		<tr>
                    <td width ="150" class="label"><b><emxUtil:i18n localize="i18nId">emxMultipleClassification.ImportFile</emxUtil:i18n></b></td>
                    <tr>
                    <td class="inputField">
                      <input type="file" name="file" accept="application/xml">
                      </td>
                      </tr>
                      <tr>
                      <td width="150" class="label"><b><emxUtil:i18n localize="i18nId">emxMultipleClassification.Command.CheckboxAG</emxUtil:i18n></b></td>
                      </tr>
                      <tr>
                      <td class="inputField">
                      <input type="checkbox" name="override">
                      </td>
                      </tr>
                <tr width="100%">
                      <td class="label" align="top"><b><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Message</emxUtil:i18n></b></td>
                      <tr>
                    <td class="inputField">
                      <textarea name="Validatetxtarea" id="ValidatetxtareaId" value="" rows="10" cols="10"></textarea>
                     </td>
    	    </tr>
    	    <input type="hidden" name="isAGImport" value="<xss:encodeForHTMLAttribute><%=isAGImport%></xss:encodeForHTMLAttribute>"/>
	</table>
    </form>
    </body>

<script language="javascript">

function formSubmit(){
	validateAGXML(false);
}
function validateAGXML(validate){
	var isValidate=validate;
	function trim (textBox) {
      while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) ==	"\n" )
        textBox=textBox.substring(0,textBox.length- 1);
      while (textBox.charAt(0) == ' ' || textBox.charAt(0) =="\r" || textBox.charAt(0) =="\n")
        textBox=textBox.substring(1,textBox.length);
         return	textBox;
    }

    if(trim(document.importAG.file.value)!="") {
          	var	fileName=document.importAG.file.value;
			if(fileName.substring(fileName.length-3,fileName.length)!="xml"){
          		alert("<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.ImportFile.SelectInvalidFileMessage</emxUtil:i18nScript>");
            }
			else{
				document.importAG.target="hiddenFrame";
				document.importAG.action="emxLibraryCentralValidateProcess.jsp?validate="+isValidate;
    			document.importAG.submit();
			}
    } else {
      alert("<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.ImportFile.SelectFileMessage</emxUtil:i18nScript>");
      return;
    }
}

 </script>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>

