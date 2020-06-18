<%--  emxLibraryCentralAttributeGroupCreateAddAttributesProcess.jsp
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>

<%
    final String PARAM_SELECTED_ATTRIBUTES  = "selectedAttributes";
    String selectedAttributes               = "";
    String selectedDisplayAttributes        = "";
    String strAttribute                     = "";
    String[] emxTableRowIds                 = null;

    try {
        emxTableRowIds = (String[]) emxGetParameterValues(request, "emxTableRowId");
    }
    catch (Exception ex) {
        String emxSingleRowId = emxGetParameter(request, "emxTableRowId");
        emxTableRowIds        = new String[1];
        emxTableRowIds[0]     = emxSingleRowId;
    }
    String strLanguageStr = emxGetParameter(request, "languageStr");
    if (emxTableRowIds != null && emxTableRowIds.length > 0){
        for (int cnt=0;cnt<emxTableRowIds.length;cnt++){
            strAttribute = emxTableRowIds[cnt];
            strAttribute = strAttribute.substring(1,strAttribute.length());
            strAttribute = strAttribute.substring(0,strAttribute.indexOf("|"));
            selectedAttributes = "".equalsIgnoreCase(selectedAttributes)? strAttribute : selectedAttributes+"|"+strAttribute;
            selectedDisplayAttributes = "".equalsIgnoreCase(selectedDisplayAttributes)? i18nNow.getAttributeI18NString(strAttribute, strLanguageStr) : selectedDisplayAttributes+"|"+i18nNow.getAttributeI18NString(strAttribute, strLanguageStr);
        }
   }
  %>
  <script language="Javascript">
      getTopWindow().getWindowOpener().document.forms["editDataForm"].Attributes.value = "<xss:encodeForJavaScript><%=selectedAttributes%></xss:encodeForJavaScript>";
      getTopWindow().getWindowOpener().document.forms["editDataForm"].AttributesDisplay.value = "<xss:encodeForJavaScript><%=selectedDisplayAttributes%></xss:encodeForJavaScript>";
      getTopWindow().getWindowOpener().document.forms["editDataForm"].AttributesOID.value = "<xss:encodeForJavaScript><%=selectedAttributes%></xss:encodeForJavaScript>";
      getTopWindow().closeWindow();
  </script>
