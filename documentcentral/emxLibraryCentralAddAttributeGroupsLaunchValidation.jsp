<%--emxLibraryCentralAddAttributeGroupsLaunchValidation.jsp -
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc" %>
<%@include file = "emxMultipleClassificationUtils.inc" %>

<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%
     //----Getting parameter from request---------------------------
    String objectId             = emxGetParameter(request, "objectId");
    String language             = request.getHeader("Accept-Language");
    String suiteKey             = emxGetParameter(request, "suiteKey");
    String SuiteDirectory       = emxGetParameter(request, "SuiteDirectory");
    String StringResourceFileId = emxGetParameter(request, "StringResourceFileId");
    String confirmMsg           = "";
    String strUrl               = "";
	StringBuffer fwdUrl         = new StringBuffer();
    int endItemCount            = 0;

    fwdUrl.append("../common/emxIndentedTable.jsp?");
    fwdUrl.append("objectId="+objectId+"&suiteKey="+suiteKey+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId);
    fwdUrl.append("&program=emxMultipleClassificationAttributeGroup:getAttributeGroupList");
    fwdUrl.append("&table=LBCAttributeGroupsList&selection=multiple");
    fwdUrl.append("&header=emxMultipleClassification.AttributeGroupChooser.SelectAttributeGroup&HelpMarker=emxhelpselectattributegroups");
    fwdUrl.append("&sortColumnName=Name&sortDirection=ascending&objectCompare=false&Export=false");
    fwdUrl.append("&toolbar=LBCAttributeGroupAddExisting&expandLevelFilterMenu=false");
    fwdUrl.append("&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel&cancelButton=true&PrinterFriendly=false&showClipboard=false&showPageURLIcon=false");
    fwdUrl.append("&filter=false");
    fwdUrl.append("&displayView=details");
    fwdUrl.append("&submitURL=../documentcentral/emxLibraryCentralAddAttributeGroupsPreProcess.jsp");
    strUrl = fwdUrl.toString();
    com.matrixone.apps.classification.Classification clsObject = (com.matrixone.apps.classification.Classification)DomainObject.newInstance(context, objectId, "Classification");
    endItemCount = clsObject.getRecursiveEndItemCount(context);
    if(endItemCount > 0) {
        confirmMsg = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(language),"emxMultipleClassification.AttributeGroup.Message.AddExistingConfirmation1");
        confirmMsg += "\n" + EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(language),"emxMultipleClassification.AttributeGroup.Message.AddExistingConfirmation2");
        confirmMsg += "\n\n\n" + EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(language),"emxMultipleClassification.AttributeGroup.Message.AddExistingConfirmation3");
        confirmMsg += "\n\n" + endItemCount + " ";
        confirmMsg += EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(language),"emxMultipleClassification.AttributeGroup.Message.AddExistingConfirmation4");
%>
        <script language="javascript">
            if(confirm("<xss:encodeForJavaScript><%=confirmMsg%></xss:encodeForJavaScript>")) {
                showModalDialog("<xss:encodeForJavaScript><%=strUrl%></xss:encodeForJavaScript>");
            }
        </script>
<%
    } else {
%>
        <script language="javascript">
            showModalDialog("<xss:encodeForJavaScript><%=strUrl%></xss:encodeForJavaScript>");
        </script>
<%
    }
%>
