<%--  emxPageHistoryShowPopup.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

--%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="emxMenuObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="page"/>

<%!
//Method to get default search
public static Map getGlobalToolbarCommand(Context context, String commandName, MapList toolbarItems)
{
    Map commandMap = null;
    try{
        for (int i = 0; i < toolbarItems.size(); i++)
        {
            HashMap child = (HashMap) toolbarItems.get(i);

            if (UIToolbar.isSeparator(child)){
                continue;
            } else if (UIToolbar.isMenu(child)){
                if (commandName.equals(UIToolbar.getName(child))){
                    commandMap = child;
                    break;
                }
                MapList children = UIToolbar.getChildren(child);
                commandMap = getGlobalToolbarCommand(context, commandName, children);
                if(commandMap != null){
                    break;
                }
            } else {
                if (UIToolbar.isCommand(child)){
                    if (commandName.equals(UIToolbar.getName(child))){
                        commandMap = child;
                        break;
                    }
                }
            }
        }
    }catch(Exception e){
        return null;
    }

    return commandMap;
}
%>

<%
String objectId = emxGetParameter(request, "objectId");
String PageQueryString =emxGetParameter(request, "pageURL");
String ContentPage = emxGetParameter(request, "ContentPage");
String MenuName = emxGetParameter(request, "MenuName");
String CommandName = emxGetParameter(request, "CommandName");
String treeMenu = emxGetParameter(request, "treeMenu");
String treeLabel = emxGetParameter(request, "treeLabel");
String DefaultCategory = emxGetParameter(request, "DefaultCategory"); //(JBB 12/5/2002)
String TargetLocation = emxGetParameter(request, "TargetLocation"); //(JBB 12/5/2002)
Vector userRoleList = PersonUtil.getAssignments(context);
boolean isDisplayMsgWindow = false;
String prefNoAccessPage = "";
boolean showNoAccessMessage=false;
HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);

if(PageQueryString==null)
{
    PageQueryString="";
}

String displayContentPage = "emxNavigatorDefaultContentPage.jsp";

// If ContentPage is provided, show the content page
// else check for the command name to display the content
// else check for "objectId" to display tree as content
// else display blank page
if (ContentPage == null || ContentPage.trim().length() == 0 )
{
    if (MenuName != null && CommandName != null  )
    {
        String commandHRef = "";
        String commandSuite = "";
        String sHREF = "";

        if (MenuName.equals("AEFGlobalToolbar"))
        {
            HashMap toolbar = UIToolbar.getToolbar( context,
                                                    "AEFGlobalToolbar",
                                                    userRoleList,
                                                    null,
                                                    paramMap,
                                                    lStr);
            if (toolbar != null)
            {
                MapList children = UIToolbar.getChildren(toolbar);
                Map commandMap = getGlobalToolbarCommand(context, CommandName, children);

                if (commandMap != null)
                {
                    commandHRef = UIToolbar.getHRef(context,commandMap, paramMap);
                    commandSuite = UIToolbar.getSetting(commandMap,"Registered Suite");
                }
            }

        } else {

            MapList commandList = emxMenuObject.getMenu(context, MenuName, userRoleList);

            if (commandList != null)
            {
                for (int i=0; i < commandList.size(); i++)
                {
                    HashMap commandItem = (HashMap)commandList.get(i);
                    // Check if the item is command
                    if ( emxMenuObject.isCommand(commandItem) )
                    {
                        // Get the command name
                        String sCmdItemName = emxMenuObject.getName(commandItem);
                        if (sCmdItemName != null && sCmdItemName.equals(CommandName) )
                        {
                            BusinessObject personBusObj = PersonUtil.getPersonObject(context);
                            personBusObj.open(context);
                            HashMap allSettings=emxMenuObject.getSettings(commandItem);

                            if(!UINavigatorUtil.checkAccessForSettings(context, personBusObj, request, allSettings))
                            {
                                isDisplayMsgWindow=true;
                                break;
                            }

                            commandHRef = emxMenuObject.getHRef(commandItem);
                            commandSuite = emxMenuObject.getSetting(commandItem, "Registered Suite");
                        }
                    }
                }
            }
        }

        if ( (commandHRef != null) && (commandSuite != null) && commandHRef.trim().length()>0 )
        {
            if ( commandHRef.indexOf("?") > 0 )
            {
                commandHRef = commandHRef.trim() + "&suiteKey=" + commandSuite;
            } else {
                commandHRef = commandHRef.trim() + "?suiteKey=" + commandSuite;
            }

            sHREF = UINavigatorUtil.parseHREF(context, commandHRef, commandSuite);
        }else{
            isDisplayMsgWindow=true;
            sHREF=displayContentPage;
        }

        if (sHREF != null && sHREF.length() > 0 )
        {
        	sHREF = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(sHREF);
            displayContentPage = UINavigatorUtil.encodeURL(sHREF);
        }

    } else if ( (objectId != null && objectId.trim().length() > 0) || (treeMenu != null && treeMenu.trim().length() > 0) ) {
        displayContentPage = "emxTree.jsp?"+com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(PageQueryString);
        displayContentPage = UINavigatorUtil.encodeURL(displayContentPage);
    } else {

        String prefContentPage = "";
        // Get the content page based on the property setting on the Admin Person
        HashMap prefContentPageMap = new HashMap();
        HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
        prefContentPageMap = (HashMap)PersonUtil.getHomePageURL(context, requestMap);
        if(prefContentPageMap!=null)
        {
            prefContentPage=(String)prefContentPageMap.get("homepage");
            prefNoAccessPage=(String)prefContentPageMap.get("errorMessage");
            if(prefNoAccessPage != null && prefNoAccessPage.length()>0)
            {
                showNoAccessMessage=true;
            }
        }

        if (prefContentPage != null && prefContentPage.length() > 0 )
        {
            displayContentPage = UINavigatorUtil.encodeURL(prefContentPage);
        }
    }
} else {
  displayContentPage = ContentPage;
}
%>
<head>
<title></title>
  <%@include file = "emxUIConstantsInclude.inc"%>
</head>

<body>
<%if(isDisplayMsgWindow){%>
<SCRIPT language="JavaScript">
    alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NoMenuDisplayMsg</emxUtil:i18nScript>");
    getTopWindow().closeWindow();
</SCRIPT>
<%}else{%>
<SCRIPT language="JavaScript">
    document.location.href="<%=displayContentPage%>";//XSSOK
</SCRIPT>
<%}%>
</body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>

