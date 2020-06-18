<%--  emxLaunch3DPlayCheck.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil" %>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script>
<%
        String strObjectId      = (String)emxGetParameter(request, "objectId");
		strObjectId=  EngineeringUtil.getTopLevelPartForProduct(context,strObjectId);		
		String timeStamp        = (String)emxGetParameter(request,"timeStamp");
        String objectId1 = emxGetParameter(request, "objectId1");
        String objectId2 = emxGetParameter(request, "objectId2");
        String compare3D = emxGetParameter(request, "3DCompare");
        String uiType    = emxGetParameter(request, "uiType");

        String tableRowId = emxGetParameter(request,"emxTableRowId");
        String crossHighlight = (String)emxGetParameter(request, "crossHighlight");            

            StringBuffer contentURL = new StringBuffer("emxLaunch3DPlayCheck.jsp?crossHighlight=true");
            contentURL.append("&");
            contentURL.append("objectId=");
            contentURL.append(XSSUtil.encodeForURL(context, strObjectId));
            contentURL.append("&");
            contentURL.append("timeStamp=");
            contentURL.append(XSSUtil.encodeForURL(context, timeStamp));
            contentURL.append("&");
            contentURL.append("objectId1=");
            contentURL.append(XSSUtil.encodeForURL(context,objectId1));
            contentURL.append("&");
            contentURL.append("objectId2=");
            contentURL.append(XSSUtil.encodeForURL(context,objectId2));
            contentURL.append("&");
            contentURL.append("compare3D=");
            contentURL.append(XSSUtil.encodeForURL(context,compare3D));
            contentURL.append("&");
            contentURL.append("uiType=");
            contentURL.append(XSSUtil.encodeForURL(context,uiType));
            contentURL.append("&");
            contentURL.append("tableRowId=");
            contentURL.append(XSSUtil.encodeForURL(context,tableRowId));
            contentURL.append("&");
            contentURL.append("crossHighlight=");
            contentURL.append(XSSUtil.encodeForURL(context,crossHighlight));
            
%>
    //XSSOK
                document.location.href = "<%=contentURL%>";
<%
    
%>
</script>
</html>
