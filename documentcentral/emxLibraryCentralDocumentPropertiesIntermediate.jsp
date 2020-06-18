<%-- emxLibraryCentralDocumentPropertiesIntermediate.jsp -- Intermediate page to display Document properties.
  Copyright (c) 2002-2016 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<%

    StringBuffer sbProperties   = new StringBuffer("../common/emxForm.jsp?");
    try
    {
        String objectId             = emxGetParameter(request,"objectId");
        String form                 = "type_GenericDocument";
        String toolbar              = "LBCGenericDocumentToolBar";
        DomainObject domainObj      = DomainObject.newInstance(context,objectId);
        String isVersionObject      = domainObj.getAttributeValue(context, Framework.getPropertyValue( session, "attribute_IsVersionObject"));
        boolean versionObject       = "true".equalsIgnoreCase(isVersionObject);
        if(versionObject) {
            form       = "type_DOCUMENTS";
            toolbar    = "APPDocumentToolBar";
        } else {
        	DomainObject doObj     = DomainObject.newInstance(context,objectId);
        	String objType         = (String)doObj.getInfo(context,DomainObject.SELECT_TYPE);
        	if (objType.equals(LibraryCentralConstants.TYPE_DOCUMENT_SHEET)) {
                form       = "type_DocumentSheet";
                toolbar    = "LBCDocumentSheetToolBar";
        	}
        }
        
        sbProperties.append("form=").append(form);
        sbProperties.append("&objectId=").append(objectId);
        sbProperties.append("&toolbar=").append(toolbar);
        sbProperties.append("&HelpMarker=emxhelpdocumentproperties");
        sbProperties.append("&formHeader=emxDocumentCentral.Common.Properties");
        sbProperties.append("&Export=False&findMxLink=false");
        sbProperties.append("&displayCDMFileSummary=true&");
        sbProperties.append(request.getQueryString());
    }catch(Exception e) {
    }
%>
    
<%@page import="com.matrixone.apps.library.LibraryCentralConstants"%><script language="Javascript">
      document.location.href = "<%=XSSUtil.encodeForJavaScript(context,sbProperties.toString())%>";
    </script>

<%@include file="../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


