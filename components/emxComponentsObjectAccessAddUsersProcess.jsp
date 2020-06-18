<%--  emxComponentsObjectAccessAddUsersProcess.jsp   -  Add users for graanting or revoking the access
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsObjectAccessAddUsersProcess.jsp.rca 1.2.7.5 Wed Oct 22 16:18:20 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>

<jsp:useBean id="accessFormBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
    String keyValue = emxGetParameter(request,"keyValue");
    String userType = emxGetParameter(request, "userType");
    String strUsers = emxGetParameter(request, "userList");
    String action = emxGetParameter(request, "action");
    if (action == null || action.equals("null"))
    {
        action = "";
    }

    MapList existingUserMapList = null;
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

    int strUsersLength = strUsers.length();
    if (strUsersLength == 1 && strUsers.indexOf("|") != -1)
    {
        strUsers = "";
    }
    else if (strUsersLength != 0 && strUsers.lastIndexOf("|") == (strUsersLength -1))
    {
        strUsers = strUsers.substring(0, (strUsersLength - 1));
    }

    StringList strListUsers = FrameworkUtil.split(strUsers, "|");

    MapList userList = new MapList();

    if (existingUserMapList.size() > 0 && strListUsers.size() > 0)
    {
        for (int j=0; j < existingUserMapList.size(); j++)
        {
            HashMap existingUserMap = (HashMap)existingUserMapList.get(j);
            String existingUserName = (String)existingUserMap.get("name");
            String existingUserType = (String)existingUserMap.get("type");
            if (action.equalsIgnoreCase("remove"))
            {
                if (!strListUsers.contains(existingUserName))
                {
                    userList.add(existingUserMap);
                }
            }
            else
            {
                if ("Person".equalsIgnoreCase(userType) && "Person".equalsIgnoreCase(existingUserType) && existingUserName != null && !"".equals(existingUserName) && !existingUserName.equals("null"))
                {
                    com.matrixone.apps.common.Person personObj = com.matrixone.apps.common.Person.getPerson(context, existingUserName);
                    existingUserName = personObj.getId();
                }
                if (userType.equalsIgnoreCase(existingUserType) && strListUsers.contains(existingUserName))
                {
                    strListUsers.removeElement(existingUserName);
                }
            }
        }
    }

    if (!action.equalsIgnoreCase("remove"))
    {
        int strListUsersSize = strListUsers.size();
        if (strListUsersSize > 0)
        {
            for (int i=0; i < strListUsersSize; i++)
            {
                HashMap tempUserMap = new HashMap();
                String userName = (String)strListUsers.get(i);
                String orgName = "";
                String displayName = userName;
                if ("Person".equalsIgnoreCase(userType) && userName != null && !"".equals(userName) && !userName.equals("null"))
                {
                    com.matrixone.apps.domain.DomainObject doObj = new com.matrixone.apps.domain.DomainObject(userName);
                    StringList objectSelects = new StringList(4);
                    objectSelects.addElement(DomainConstants.SELECT_NAME);
                    objectSelects.addElement("to[" + DomainConstants.RELATIONSHIP_EMPLOYEE + "].from.name");
                    objectSelects.addElement("attribute[" + DomainConstants.ATTRIBUTE_LAST_NAME + "]");
                    objectSelects.addElement("attribute[" + DomainConstants.ATTRIBUTE_FIRST_NAME + "]");

                    Map tempMap = doObj.getInfo(context, objectSelects);

                    userName = (String)tempMap.get(DomainConstants.SELECT_NAME);
                    orgName = (String)tempMap.get("to[" + DomainConstants.RELATIONSHIP_EMPLOYEE + "].from.name");
                    displayName = (String)tempMap.get("attribute[" + DomainConstants.ATTRIBUTE_LAST_NAME + "]") + ", " + (String)tempMap.get("attribute[" + DomainConstants.ATTRIBUTE_FIRST_NAME + "]");
                }
                tempUserMap.put("name", userName);
                tempUserMap.put("type", userType);
                tempUserMap.put("LastFirstName", displayName);
                tempUserMap.put("OrganizationName", orgName);
                tempUserMap.put("access", "Read WO Download");

                existingUserMapList.add(tempUserMap);
            }
        }
    }

    if(keyValue != null && !keyValue.equals("null") && !"null".equals(keyValue) && !keyValue.equals(""))
    {
        if (action.equalsIgnoreCase("remove"))
        {
            accessFormBean.setElementValue("accessUsersMapList", userList);
        }
        else
        {
            accessFormBean.setElementValue("accessUsersMapList", existingUserMapList);
        }
        accessFormBean.setFormValues(session);
    }

    String url = "emxComponentsObjectAccessUsersDialogFS.jsp?keyValue="+ XSSUtil.encodeForURL(context, keyValue);

%>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
    if ("remove"=="<%=XSSUtil.encodeForJavaScript(context, action)%>")
    {
		//XSSOK
        parent.location.href = '<%=url%>';
    }
    else
    {
		//XSSOK
        getTopWindow().getWindowOpener().parent.location.href = '<%=url%>';
        getTopWindow().closeWindow();
    }
</script>
