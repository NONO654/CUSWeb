<%--  emxLaunch3DPlayCheck.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

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
		boolean isLaunch3dPlay =true;
        String strObjectId      = (String)emxGetParameter(request, "objectId");   
		String timeStamp        = (String)emxGetParameter(request,"timeStamp");
        //Cross Highlight Changes Start: Added for Compare channel
        String objectId1 = emxGetParameter(request, "objectId1");
        String objectId2 = emxGetParameter(request, "objectId2");
        String compare3D = emxGetParameter(request, "3DCompare");
        //Cross Highlight Changes Start: Added for Compare channel
        String uiType    = emxGetParameter(request, "uiType");

        String tableRowId = emxGetParameter(request,"emxTableRowId");
        if (tableRowId!= null) {
        if(UIUtil.isNotNullAndNotEmpty(uiType) && uiType.equals("structureBrowser")) {
             StringList slList = FrameworkUtil.split(" "+ tableRowId, "|");
              strObjectId = ((String)slList.get(1)).trim();
         } else {
             strObjectId = tableRowId;
                }
        }
        if(isLaunch3dPlay) {

            StringBuffer contentURL = new StringBuffer("emxLaunch3DPlay.jsp?");
            //Cross Highlight Changes Start: Added for Compare channel
            if(emxGetParameter(request, "3DCompare") != null) {
                contentURL = new StringBuffer("emxLaunchCompare3DPlay.jsp?");
                contentURL.append("objectId1=").append(XSSUtil.encodeForURL(context, objectId1)).append("&objectId2=").append(XSSUtil.encodeForURL(context, objectId2)).append("&");
            }
            //Cross Highlight Changes End: Added for Compare channel
            
            contentURL.append("timeStamp=");
            contentURL.append(XSSUtil.encodeForURL(context, timeStamp));
            contentURL.append("&");
            contentURL.append("objectId=");
            contentURL.append(XSSUtil.encodeForURL(context, strObjectId));
            contentURL.append("&");
            contentURL.append(XSSUtil.encodeURLwithParsing(context, request.getQueryString()));
            
            //Cross Highlight Changes Start: Added for Powerview Channel and Compare channel            
            String crossHighlight = (String)emxGetParameter(request, "crossHighlight");            
            if("true".equalsIgnoreCase(crossHighlight) || "true".equalsIgnoreCase(compare3D)) {
%>
				//XSSOK
                document.location.href = "<%= contentURL.toString()%>";
<%
            } else {
%>              //To support regular functionality of popup
                showModalDialog("<%=contentURL.toString()%>", 600, 600, true);
<%
            }
        }
    
%>
</script>
</html>
