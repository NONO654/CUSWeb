<%--  emxLibraryCentralAddAttributeGroupsFilterProcess.jsp -
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%
    try {
        String strDoFilter           = emxGetParameter(request, "filter");
        String strNameOrAttribute    = emxGetParameter(request, "LBCAttributeGroupNameOrAttribute");
        String strnameMatches        = emxGetParameter(request, "LBCAttributeGroupNameMatches");
        String strnameMatchesEncoded = emxGetParameter(request,"LBCAttributeGroupNameMatchesEncoded");
        strnameMatchesEncoded        = strnameMatchesEncoded.replaceAll("%26", "&");
        strnameMatchesEncoded        = strnameMatchesEncoded.replaceAll("%3D", "=");
        
        String strUnused            = emxGetParameter(request, "LBCUnusedAttributeGroup");
        String objectId             = emxGetParameter(request, "objectId"); 
        String sTableName           = emxGetParameter(request, "table");
        
        String resourceBundle       = "emxLibraryCentralStringResource";
        String language            = request.getHeader("Accept-Language");
        String INVALID_INPUT_MSG    = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxDocumentCentral.ErrorMsg.InvalidInputMsg");
        String INVALID_CHAR_MSG     = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxDocumentCentral.ErrorMsg.InvalidCharMsg");
		
		boolean objectBased = false;
%>
<html>
<head>
<script type="text/javascript" src="../common/emxJSValidation.jsp"></script>
<script type="text/javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script type="text/javascript" src="../documentcentral/emxDocumentUtilities.js"></script>
</head>
<body>
    <script language="JavaScript">
        var doFilter = checkForSpecialCharsInAGName("<%=XSSUtil.encodeForJavaScript(context,strnameMatchesEncoded)%>","<xss:encodeForJavaScript><%=INVALID_INPUT_MSG%></xss:encodeForJavaScript>","\n"+"<xss:encodeForJavaScript><%=INVALID_CHAR_MSG%></xss:encodeForJavaScript>",false,true);
        if(doFilter){
        parent.resetParameter("filter","<xss:encodeForJavaScript><%=strDoFilter%></xss:encodeForJavaScript>");
        parent.resetParameter("LBCAttributeGroupNameOrAttribute","<xss:encodeForJavaScript><%=strNameOrAttribute%></xss:encodeForJavaScript>");
        parent.resetParameter("LBCAttributeGroupNameMatches","<xss:encodeForJavaScript><%=XSSUtil.encodeForURL(context,strnameMatchesEncoded)%></xss:encodeForJavaScript>");
        parent.resetParameter("LBCUnusedAttributeGroup","<xss:encodeForJavaScript><%=strUnused%></xss:encodeForJavaScript>");
        parent.resetParameter("submitLabel","emxFramework.Common.Done");
        parent.resetParameter("cancelLabel","emxFramework.Common.Cancel");
		// Changes added by PSA11 start(IR-544954-3DEXPERIENCER2018x).
        parent.resetParameter("objectBased","<xss:encodeForJavaScript><%=objectBased%></xss:encodeForJavaScript>");
        // Changes added by PSA11 end.		
        parent.refreshSBTable("<xss:encodeForJavaScript><%=sTableName%></xss:encodeForJavaScript>","Name","ascending");
        }
    </script>
<%
    } catch (Exception ex) {
         if (ex.toString() != null && ex.toString().length() > 0){
            emxNavErrorObject.addMessage(ex.toString());
         }
         ex.printStackTrace();
    }
%>
</body>
</html>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
