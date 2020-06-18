<%--  emxLibraryCentralAttributeCreationPreProcess.jsp
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<head>
<body>
<%
    String objectName                         = emxGetParameter(request, "objectName");
    String StringResourceFileId               = emxGetParameter(request, "StringResourceFileId");
    StringBuffer strUrl                       = new StringBuffer();
    strUrl.append("../common/emxForm.jsp?form=LBCAttributeCreationForm&postProcessURL=../documentcentral/emxLibraryCentralAttributeCreationPostProcess.jsp");
    strUrl.append("&submitAction=doNothing&preProcessJavaScript=lbcAttributePreProcess&objectBased=false");
    
    Enumeration paramNames = emxGetParameterNames(request);
	while (paramNames.hasMoreElements()) {
		String paramName = (String) paramNames.nextElement();
		if(!paramName.equals("emxTableRowId")){
			strUrl.append("&"+paramName+"=");
			strUrl.append(emxGetParameter(request, paramName));
		}
	}

try{
    AttributeGroup agObject    = new AttributeGroup(); 
    agObject.setName(objectName);
    if (agObject.checkIfAGisAssociatedToClassifiedItems(context)) {
        StringBuffer sbErrMsg    = new StringBuffer();
        String message= EnoviaResourceBundle.getProperty(context, StringResourceFileId, request.getLocale(), "emxLibraryCentral.Attributes.CreateNewMessage");
        sbErrMsg.append(message);
        //Display below alert message only if the default vault is other than All.
        if(!PersonUtil.SEARCH_ALL_VAULTS.equals(PersonUtil.getSearchDefaultSelection(context))){
            sbErrMsg.append("\n");
            sbErrMsg.append(EnoviaResourceBundle.getProperty(context,StringResourceFileId,request.getLocale(),"emxMultipleClassification.AddAttribute.Message5"));
        }
%>
        <script language="Javascript">
            if(confirm("<xss:encodeForJavaScript><%=sbErrMsg.toString()%></xss:encodeForJavaScript>")){
                document.location.href = "<xss:encodeForJavaScript><%=strUrl.toString()%></xss:encodeForJavaScript>";
            }else{
                getTopWindow().closeSlideInDialog();
            }
      </script>
<%
    }else {
%>
        <script language="Javascript">
            document.location.href = "<xss:encodeForJavaScript><%=strUrl.toString()%></xss:encodeForJavaScript>";
        </script>
<%
    }
}catch(Exception err){
    err.printStackTrace();
}
%>
</body>
</head>
