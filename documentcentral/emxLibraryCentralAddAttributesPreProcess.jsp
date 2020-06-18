<%--  emxLibraryCentralAddAttributesPreProcess.jsp
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<jsp:useBean id="attributeBean" class="com.matrixone.apps.classification.AttributeGroup" scope="session"/>
<head>
<body>
<%
    final String PARAM_SELECTED_ATTRIBUTES  = "selectedAttributes";
    String[] emxTableRowIds                 = null;
    String parentId                         = emxGetParameter(request, "objectName");
    String strCharSet                       = Framework.getCharacterEncoding(request);
    String strAttribute                     = "";
    String strUrl                           = "";
    StringList slAttribute                  = new StringList();
    try {
        emxTableRowIds  = (String[]) emxGetParameterValues(request, "emxTableRowId");
    }
    catch (Exception ex) {
        String emxSingleRowId   = emxGetParameter(request, "emxTableRowId");
        emxTableRowIds          = new String[1];
        emxTableRowIds[0]       = emxSingleRowId;
    }
    if (emxTableRowIds != null && emxTableRowIds.length > 0) {
        for (int cnt=0;cnt<emxTableRowIds.length;cnt++){
          strAttribute = emxTableRowIds[cnt];
          strAttribute = strAttribute.substring(1,strAttribute.length());
          strAttribute = strAttribute.substring(0,strAttribute.indexOf("|"));
          slAttribute.addElement(strAttribute);
        }
   }
  %>
<form name="formSubmit" method="post" target = "listHidden" action="emxLibraryCentralAddAttributesProcess.jsp">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<input type="hidden" name="parentId" value="<xss:encodeForHTMLAttribute><%=parentId%></xss:encodeForHTMLAttribute>"/>

  <%
    //parentId = FrameworkUtil.encodeNonAlphaNumeric(parentId,strCharSet);
    try{
    strUrl = "emxLibraryCentralAddAttributesProcess.jsp?parentId="+XSSUtil.encodeForURL(context,parentId);
    AttributeGroup agObject    = new AttributeGroup();
    attributeBean.setAttributes(slAttribute);
    agObject.setName(parentId);
    int countClassifiedItems  = (int) agObject.getNumberOfEndItemsWhereUsed(context);
    if (countClassifiedItems >= 1) {
        StringBuffer sbErrMsg    = new StringBuffer();
        String message= MessageUtil.getMessage(context,
                null,
                "emxMultipleClassification.AddAttribute.Message",
                new String[]{Integer.toString(countClassifiedItems)},
                null,
                context.getLocale(),
        "emxLibraryCentralStringResource");
        sbErrMsg.append(message);
        //Display below alert message only if the default vault is other than All.
        if(!PersonUtil.SEARCH_ALL_VAULTS.equals(PersonUtil.getSearchDefaultSelection(context))){
            sbErrMsg.append("\n");
            sbErrMsg.append(EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxMultipleClassification.AddAttribute.Message5"));
        }
%>
        <script language="Javascript">
            if(confirm("<xss:encodeForJavaScript><%=sbErrMsg.toString()%></xss:encodeForJavaScript>")){
                <%-- document.location.href = "<xss:encodeForJavaScript><%=strUrl%></xss:encodeForJavaScript>"; --%>
                document.formSubmit.submit();
            }else{
                parent.closeWindow();
            }
      </script>
<%
    }else {
%>
        <script language="Javascript">
            <%-- document.location.href = "<xss:encodeForJavaScript><%=strUrl%></xss:encodeForJavaScript>"; --%>
            document.formSubmit.submit();
        </script>
<%
    }
    }catch(Exception err){
    	err.printStackTrace();
    }
%>
</form>
</body>
</head>
