<%--  emx3DLiveExamineLaunchCheck.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.plmprovider.*"%>
<%@ page import = "javax.xml.namespace.QName"%>
 <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />

<%!
    static Boolean launch3DLiveExamine      = false;
    static String configuredTypes   = "";
    
    public boolean isTypeConfigureFor3DLive(Context context, String objectId) throws Exception {
        String strTypeName = null;
        String symbolicTypeName = null;
            
        if (configuredTypes != null && !"".equals(configuredTypes)) {
            DomainObject doObj = new DomainObject(objectId);
            strTypeName      = doObj.getInfo(context, "type");
            symbolicTypeName = FrameworkUtil.getAliasForAdmin(context,"type", strTypeName, true);
            
            return (configuredTypes.indexOf(symbolicTypeName)!= -1);
        }
        
        return false;
    }
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script>
<%
	String fromChannel      = (String)emxGetParameter(request, "fromENG3dLiveCmd");
    String sExtAuth     = EnoviaResourceBundle.getProperty(context, "emxFramework.External.Authentication");
    if (sExtAuth == null || "null".equalsIgnoreCase(sExtAuth) || sExtAuth.length() == 0) {
        sExtAuth = "false";
    }
    
    if ("true".equalsIgnoreCase(sExtAuth)) {
        launch3DLiveExamine = true;
    }
    
    if(launch3DLiveExamine == null || ! launch3DLiveExamine.booleanValue()) {
        //check whether 3DVIA is installed in server or not
        ServletContext servletContext  = getServletConfig().getServletContext();
        InputStream x86Plugin          = servletContext.getResourceAsStream("/components/x86/msi/ENOVIA3DLiveExaminePlugin.msi");
        InputStream x64Plugin          = servletContext.getResourceAsStream("/components/x64/msi/ENOVIA3DLiveExaminePlugin.msi");

        if (x86Plugin == null || x64Plugin == null) {
            launch3DLiveExamine = false;
%>

	if(<%=fromChannel%>!=null &&"true" == "<%=XSSUtil.encodeForJavaScript(context, fromChannel)%>" ){
	
	$(document).ready(function() {
		
		var div = document.createElement("div");
		document.body.setAttribute("style","background-color:#c2d1e0");
		div.setAttribute("style","position:absolute;top:50%;left:50%;transform:translateX(-50%) translateY(-50%);");
		
		var h5 = document.createElement("h5");

		var textnode = document.createTextNode("<emxUtil:i18nScript localize="i18nId">emxComponents.3DLiveExamine.NotInstalled</emxUtil:i18nScript>");
		h5.setAttribute("style","color: #ab2121;");
		h5.appendChild(textnode);
		div.appendChild(h5);
		document.body.appendChild(div);
		
	});
        }else {

            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.3DLiveExamine.NotInstalled</emxUtil:i18nScript>");
        }
<%
        } else {
          launch3DLiveExamine = true;
        }
    }

    if(launch3DLiveExamine != null && launch3DLiveExamine.booleanValue()) {
        // The following code is to check whether a given object type
        // is properly configured in emxSystem.properties or not
        Boolean isTypeConfigured= false;
        String strObjectId      = (String)emxGetParameter(request, "objectId");

        String timeStamp        = (String)emxGetParameter(request,"timeStamp");

        //3DLive Examine for the selected part
        //Changed for X-BOM "3DLive Examine Command in Part Management" highlight
        //If none of the objects are selected in the table, context object id will be considered.
        String uiType    = emxGetParameter(request, "uiType");

        String tableRowId = emxGetParameter(request,"emxTableRowId");
        if (tableRowId!= null) {
            if(uiType.equals("structureBrowser")) {
                StringList slList = FrameworkUtil.split(" "+ tableRowId, "|");
                strObjectId = ((String)slList.get(1)).trim();
            } else {
                strObjectId = tableRowId;
            }
        }

        //Cross Highlight Changes
        String expandRelationship = (String)emxGetParameter(request, "expandRelationship");
        String expandDirection = (String)emxGetParameter(request, "expandDirection");
        if(expandRelationship != null && !"".equals(expandRelationship) 
                && expandDirection != null && !"".equals(expandDirection)) {
            expandRelationship = PropertyUtil.getSchemaProperty(context, expandRelationship);
            if(expandRelationship != null && !"".equals(expandRelationship)) {
                String selectable = "from".equalsIgnoreCase(expandDirection) 
                        ? "from["+expandRelationship+"].to.id"
                                : "to["+expandRelationship+"].from.id";
                strObjectId = new DomainObject(strObjectId).getInfo(context, selectable);
            }
        }
        
        
        
        if(UIUtil.isNotNullAndNotEmpty(strObjectId)){
            DomainObject domObj = new DomainObject(strObjectId);
            String originalObjectId = domObj.getInfo(context,"relationship[VersionOf].to.id");
            
            if(UIUtil.isNotNullAndNotEmpty(originalObjectId)){
                strObjectId = originalObjectId;
            }
        }

        if (configuredTypes == null || "".equals(configuredTypes)) {
            // get Configured Types
            String strProgram       = "jpo.plmprovider.MetaDataBase";
            String strFunction      = "getConfiguredTypes";
            HashMap map             = new HashMap();
            map.put("language", request.getHeader("Accept-Language"));

            configuredTypes     = (String)JPO.invoke(context, strProgram, null, strFunction, JPO.packArgs(map), String.class);
        }
        
        //Cross Highlight Changes Start: Added for Compare channel
        String objectId1 = emxGetParameter(request, "objectId1");
        String objectId2 = emxGetParameter(request, "objectId2");
        String compare3D = emxGetParameter(request, "3DCompare");
        //Cross Highlight Changes Start: Added for Compare channel
      
        if (configuredTypes != null && !"".equals(configuredTypes)) {
            if(!"true".equalsIgnoreCase(compare3D)) {
                isTypeConfigured = isTypeConfigureFor3DLive(context, strObjectId);
            } else {
                isTypeConfigured = isTypeConfigureFor3DLive(context, objectId1);
                if(isTypeConfigured) {
                    isTypeConfigureFor3DLive(context, objectId2);
                }
            }
        }
        
        if(isTypeConfigured.booleanValue()) {

            StringBuffer contentURL = new StringBuffer("emxLaunch3DLiveExamine.jsp?");
            //Cross Highlight Changes Start: Added for Compare channel
            if(emxGetParameter(request, "3DCompare") != null) {
                contentURL = new StringBuffer("emxLaunchCompare3DLiveExamine.jsp?");
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
        } else {
%>
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.3DLiveExamine.TypeNotConfigured</emxUtil:i18nScript>");
<%
        }
    }
%>
</script>
</html>
