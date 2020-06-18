<%--  emxLibraryCentralAttributeGroupRemoveConfirmation.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program
   --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../documentcentral/emxLibraryCentralUtils.inc"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>

<%
    String objectId     = emxGetParameter(request, "objectId");
    String action       = emxGetParameter(request, "action");
    String language     = request.getHeader("Accept-Language");
    String confirmMsg   = "";
    String fwdUrl       = "";
    String charEncoding = Framework.getCharacterEncoding(request);
    com.matrixone.apps.classification.Classification cls  = (com.matrixone.apps.classification.Classification)DomainObject.newInstance(context, objectId, "Classification");
    int endItemCount    = cls.getRecursiveEndItemCount(context);

    String rowids[]     = emxGetParameterValues(request,"emxTableRowId");
    StringBuffer sbObjectIds = new StringBuffer();
    if(rowids != null || rowids.length >0) {
        for(int i = 0;i < rowids.length;i++) {
            sbObjectIds.append(FrameworkUtil.encodeNonAlphaNumeric(rowids[i],charEncoding));
            sbObjectIds.append("|");
        }
    }
    String objectIdString = sbObjectIds.toString();
    confirmMsg  = EnoviaResourceBundle.getProperty(context, "emxLibraryCentralStringResource", new Locale(language),"emxMultipleClassification.AttributeGroup.Message.RemoveConfirmation1");
    confirmMsg += "\n\n" + endItemCount + " ";
    confirmMsg += EnoviaResourceBundle.getProperty(context, "emxLibraryCentralStringResource", new Locale(language),"emxMultipleClassification.AttributeGroup.Message.RemoveConfirmation2");
    fwdUrl = "emxMultipleClassificationRemoveAttributeGroupProcess.jsp?rowids="+UINavigatorUtil.encodeURL(objectIdString) +"&"+ emxGetQueryString(request);

%>
<form name="formForward" method="post" target = "listHidden" action="<%=XSSUtil.encodeForHTML(context,fwdUrl)%>">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<script language="javascript">
    var vEndItemCount = "<xss:encodeForJavaScript><%=endItemCount%></xss:encodeForJavaScript>";
    if (vEndItemCount > 0) {
        if(confirm("<xss:encodeForJavaScript><%=confirmMsg%></xss:encodeForJavaScript>")) {
        	<%-- document.location.href="<xss:encodeForJavaScript><%=fwdUrl%></xss:encodeForJavaScript>";--%>
            document.formForward.submit();
        }
    } else {
    	<%-- document.location.href="<xss:encodeForJavaScript><%=fwdUrl%></xss:encodeForJavaScript>";--%>
    	document.formForward.submit();
    }
</script>
</form>
