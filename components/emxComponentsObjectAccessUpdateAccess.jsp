<%--  emxComponentsObjectAccessUpdateAccess.jsp   -  page to update the access information in the session
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsObjectAccessUpdateAccess.jsp.rca 1.2.7.5 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<script language="javascript" src="../emxUIPageUtility.js">
</script>
<script language="javascript" src="../common/scripts/emxUICore.js">
</script>
<jsp:useBean id="accessFormBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
    String strAction = request.getParameter("action");

    if ("cancel".equals(strAction))
    {
        try
        {
            session.removeAttribute("accessFormBean");
        }
        catch(Exception e)
        {
        }
    }
    else
    {
        String strName = request.getParameter("name");
        MapList existingUserMapList = null;

        // Get the information from the session
        try
        {
            existingUserMapList =(MapList)accessFormBean.getElementValue("accessUsersMapList");
            if(existingUserMapList == null || existingUserMapList.equals("null") || existingUserMapList.equals(""))
            {
                existingUserMapList = new MapList();
            }
        }
        catch (Exception e)
        {
            existingUserMapList = new MapList();
        }

        // Update the information in the session
        for (int j=0; j < existingUserMapList.size(); j++)
        {
            HashMap existingUserMap = (HashMap)existingUserMapList.get(j);
            String existingUserName = (String)existingUserMap.get("name");
            String existingUserType = (String)existingUserMap.get("type");
            if(existingUserName.equals(strName))
            {
                existingUserMap.put("access", request.getParameter("access"));
                break;
            }
        }
    }
%>

<script language ="javascript">
    if ("cancel"=="<%=XSSUtil.encodeForJavaScript(context, strAction)%>")
    {
        getTopWindow().closeWindow();
    }
</script>

