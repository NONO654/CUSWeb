<%--  emxComponentsObjectAccessSetAccessProcess.jsp  - To set the User Accesses on the object
   Copyright (c) 2006-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsObjectAccessSetAccessProcess.jsp.rca 1.4.7.5 Wed Oct 22 16:17:46 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<jsp:useBean id="accessFormBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
    String action = emxGetParameter(request, "action");
    if (action == null || "null".equals(action) || "".equals(action.trim()))
    {
        action = "";
    }

    String strCharSet = request.getCharacterEncoding();
    if(strCharSet == null || strCharSet.trim().equals(""))
    {
        strCharSet = "UTF8";
    }

    String languageStr = request.getHeader("Accept-Language");
    String contextUser = context.getUser();

    HashMap dataMap = new HashMap();
    String accessGrantor = "";
    String objectId = "";
    String showAllProgram = "";
    String showAllFunction = "";

    if ("remove".equalsIgnoreCase(action))
    {
        // For grant revoke, get the objects
        String[] revokeObjNames = emxGetParameterValues(request, "emxTableRowId");
        objectId = emxGetParameter(request, "objectId");
        accessGrantor = emxGetParameter(request, "pushGrantor");
        showAllProgram = emxGetParameter(request, "showAllProgram");
        showAllFunction = emxGetParameter(request, "showAllFunction");
        if(revokeObjNames != null )
        {
            int namesLength = revokeObjNames.length;
            for(int i=0; i < namesLength; i++)
            {
                dataMap.put(revokeObjNames[i], com.matrixone.apps.domain.util.AccessUtil.NONE);
            }
        }
    }
    else
    {
        // Get all the request parameters as HashMap with Key / Value pairs.
        HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
        objectId = (String) requestMap.get("objectId");
        accessGrantor = (String)requestMap.get("pushGrantor");
        showAllProgram = (String)requestMap.get("showAllProgram");
        showAllFunction = (String)requestMap.get("showAllFunction");
        int count = 0;
        String userName = "";
        String strNewAccess = "";
        String strOldAccess = "";

        while ((String) requestMap.get("User" + count) != null && !"".equals((String) requestMap.get("User" + count)) && !"null".equalsIgnoreCase((String) requestMap.get("User" + count)))
        {
            userName = (String) requestMap.get("User" + count);
            strNewAccess = (String) requestMap.get("Access" + count);

            if("add".equalsIgnoreCase(action))
            {
                dataMap.put(userName, strNewAccess);
            }
            else
            {
                strOldAccess = (String) requestMap.get("OldAccess" + count);
                if (!strOldAccess.equalsIgnoreCase(strNewAccess) && !contextUser.equalsIgnoreCase(FrameworkUtil.decodeURL(userName, strCharSet)))
                {
                    dataMap.put(userName, strNewAccess);
                }
            }
            count++;
        }

        // If add / grant action, clear the session
        if("add".equalsIgnoreCase(action))
        {
            accessFormBean.clear();
        }
    }

    boolean showAll = false;
    if(showAllProgram != null && !"null".equals(showAllProgram) && !"".equals(showAllProgram) && showAllFunction != null && !"null".equals(showAllFunction) && !"".equals(showAllFunction))
    {
		HashMap argsMap = new HashMap(1);
		argsMap.put("objectId",objectId);
		String [] arguments = JPO.packArgs(argsMap);
        FrameworkUtil.validateMethodBeforeInvoke(context, showAllProgram, showAllFunction, "Program");
        Boolean showAllValue = (Boolean)JPO.invoke(context, showAllProgram, null, showAllFunction, arguments, Boolean.class);
        showAll = showAllValue.booleanValue();
    }

    if (accessGrantor == null || "null".equals(accessGrantor) || "".equals(accessGrantor.trim()))
    {
        accessGrantor = PropertyUtil.getSchemaProperty(context, "person_CommonAccessGrantor");
    }

    if (showAll)
    {
        // Call the JPO method to actually set the grants.
        HashMap argsMap = new HashMap();
        BusinessObjectList list = new BusinessObjectList(1);
        list.addElement(new BusinessObject(objectId));
        argsMap.put("boList", list);
        argsMap.put("accessGrantor", accessGrantor);
        argsMap.put("charSet", strCharSet);
        argsMap.put("dataMap", dataMap);
        argsMap.put("action", action);
        argsMap.put("languageStr", languageStr);

        String [] arguments = JPO.packArgs(argsMap);

        // Call the actual program to set the granted accesses
        JPO.invoke(context, "emxObjectAccess", null, "setUserAccesses", arguments);
    }

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language ="javascript">
    //XSSOK
	if ("true"=="<%=showAll%>")
    {
        try
        {
            getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
            if ("remove"!="<%=XSSUtil.encodeForJavaScript(context, action)%>")
            {
                window.closeWindow();
            }
        }
        catch(e)
        {
            getTopWindow().refreshTablePage();
            if ("remove"!="<%=XSSUtil.encodeForJavaScript(context, action)%>")
            {
                getTopWindow().closeWindow();
            }
        }
    }
    else
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ObjectAccess.NoAccessToAddRemove</emxUtil:i18nScript>");
        if ("remove"!="<%=XSSUtil.encodeForJavaScript(context, action)%>")
        {
            getTopWindow().closeWindow();
        }
    }
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
