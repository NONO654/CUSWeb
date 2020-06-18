<%--  emxNavigatorContentLoad.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="emxMenuObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>

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
String ContentPage = emxGetParameter(request, "ContentPage");
String isFromIFWE=emxGetParameter(request, "fromIFWE");
String strSwitchContext=emxGetParameter(request, "switchContext");
boolean isSwitchContext = false;
if(UIUtil.isNotNullAndNotEmpty(strSwitchContext) && "true".equalsIgnoreCase(strSwitchContext)){
	isSwitchContext = true;
}

String ContentURL = (String)session.getAttribute("ContentURL");
if(ContentURL != null && !"".equals(ContentURL)){
	ContentURL = Framework.getClientSideURL(response, ContentURL);
}
if ( session.getAttribute("ContentURL") != null ){
	session.removeAttribute("ContentURL");
}

String MenuName = emxGetParameter(request, "MenuName");
String CommandName = emxGetParameter(request, "CommandName");
String treeMenu = emxGetParameter(request, "treeMenu");
String treeLabel = emxGetParameter(request, "treeLabel");
String DefaultCategory = emxGetParameter(request, "DefaultCategory");
String TargetLocation = emxGetParameter(request, "TargetLocation");
String mxTree = emxGetParameter(request, "mxTree");
String applicationName = emxGetParameter(request, "appName");
String prefApp = "";
String prefAppName = "";

String fromGTB = emxGetParameter(request, "fromGTB");
if("true".equalsIgnoreCase(fromGTB)){
%>
		<script>
			parent.launchHomePage();
		</script>
<%	
}

boolean showErrorPage=false;
String prefNoAccessPage = "";
boolean showNoAccessMessage=false;
boolean isAppInstalled = true;
boolean mobilesupport = true;
boolean hasAccess = true;
String displayContentPage = "";
String strUserHomePage = "";
String appHomePageCommand = "";
HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
boolean isTree=false;
String cmdLabel = "";
try{
    ContextUtil.startTransaction(context, false);

    if(mxTree !=null && mxTree.equalsIgnoreCase("true")) {
        isTree=true;
    }

    Vector userRoleList = PersonUtil.getAssignments(context);

        displayContentPage = "emxNavigatorDefaultContentPage.jsp";

    // If ContentPage is provided, show the content page
    // else check for the command name to display the content
    // else check for "objectId" to display tree as content
    // else display blank page
    
    //for: Negative use case. If any random appName is passed, we check if an entry is made in emxSystem. If not, make it null. 
	try{
		if(!UIUtil.isNullOrEmpty(applicationName)){
			appHomePageCommand = EnoviaResourceBundle.getProperty(context, "emxFramework."+applicationName+".HomePage");
		}

	}catch(Exception ex){
		appHomePageCommand = EnoviaResourceBundle.getProperty(context, "emxFramework.ENOBUPS_AP.HomePage");
	}
	if(!UIUtil.isNullOrEmpty(applicationName) && ( (objectId != null && objectId.trim().length() > 0) || (treeMenu != null && treeMenu.trim().length() > 0) )){
		String mappedTreeName = UITreeUtil.getCategoryTreeName(application, session, context, objectId, null, treeMenu);
		String regsuite = UIComponent.getSetting(UIMenu.getMenu(context, mappedTreeName), "Registered Suite");
		StringList appList = PersonUtil.getLicenseProductsBySuiteKey(regsuite);

		if(!appList.contains(applicationName)){
			objectId = null;
			treeMenu = null;
		}else{
			String productName = MqlUtil.mqlCommand(context, "print product $1 select $2 dump", applicationName, "title");
			String sSelectedAppMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.AppHomePage.Message");
			sSelectedAppMsg = FrameworkUtil.findAndReplace(sSelectedAppMsg, "{0}", productName);
			if(!isSwitchContext){
                     %>
                     <script src="scripts/emxUIModal.js" type="text/javascript"></script>
                     <script src="scripts/emxUICore.js" type="text/javascript"></script>
                     <script type="text/javascript">
				     	getTopWindow().showTransientMessage("<%=sSelectedAppMsg%>", 'warning', 'alert-left','8000');
                     </script>
                     <%
				}
              }
	}

	
    if(UIUtil.isNotNullAndNotEmpty(ContentURL)){
    	 displayContentPage = ContentURL;
	}else if(ContentPage == null || ContentPage.trim().length() == 0 ){
        if (MenuName != null && CommandName != null  )
        {
            String commandHRef = "";
            String commandSuite = "";

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
                                    showErrorPage=true;
                                    break;
                                }

                                commandHRef = emxMenuObject.getHRef(commandItem);
                                commandSuite = emxMenuObject.getSetting(commandItem, "Registered Suite");
                            }
                        }
                    }
                }
            }

            String sHREF = "";
            if ( (commandHRef != null) && (commandSuite != null) && commandHRef.trim().length()>0  )
            {
                if ( commandHRef.indexOf("?") > 0 ) {
                    commandHRef = commandHRef.trim() + "&suiteKey=" + commandSuite;
                } else {
                    commandHRef = commandHRef.trim() + "?suiteKey=" + commandSuite;
                }

                sHREF = UINavigatorUtil.parseHREF(context, commandHRef, commandSuite);
            }else{
               showErrorPage=true;
               sHREF=displayContentPage;
            }

            if (sHREF != null && sHREF.length() > 0 ) {
              sHREF	= com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(sHREF);
              displayContentPage = UINavigatorUtil.encodeURL(sHREF);
            }

        } else if ( (objectId != null && objectId.trim().length() > 0) || (treeMenu != null && treeMenu.trim().length() > 0) ) {
            displayContentPage = "emxTree.jsp?";           
        	if(!UIUtil.isNullOrEmpty(applicationName)){
        		displayContentPage += "fromhomepage=true&";
            }
           displayContentPage += XSSUtil.encodeURLwithParsing(context, request.getQueryString());
           // Modified for Portlet Collections
           if(objectId != null && objectId.trim().length() > 0 )
            {
                displayContentPage=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(displayContentPage);
                displayContentPage = UINavigatorUtil.encodeURL(displayContentPage);
            }

        } else if(!UIUtil.isNullOrEmpty(applicationName)){
    		appHomePageCommand = appHomePageCommand.trim();
        	HashMap cmdMap = null;
        		cmdMap = UICache.getCommand(context, appHomePageCommand);       	
        	if (cmdMap == null || cmdMap.isEmpty()){
        		isAppInstalled = false;
        	} else {
        	boolean access = UICache.checkAccess(context,cmdMap,PersonUtil.getAssignments(context));
        	if(!access){
        		hasAccess = false;
	        	}else {
        	BusinessObject personBusObj = PersonUtil.getPersonObject(context);
            personBusObj.open(context);
            HashMap allSettings=emxMenuObject.getSettings(cmdMap);
        	
						String prefContentPage = "";
			            // Get the content page based on the property setting on the Admin Person
			            HashMap prefContentPageMap = new HashMap();
			            HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
			            prefContentPageMap = (HashMap)PersonUtil.getHomePageURL(context, requestMap);
			            if(prefContentPageMap!=null)
			            {
			                prefContentPage=(String)prefContentPageMap.get("homepage");
			                prefNoAccessPage=(String)prefContentPageMap.get("errorMessage");
			                prefAppName =(String)prefContentPageMap.get("appName");
			                if(prefNoAccessPage != null && prefNoAccessPage.length()>0)
			                {
			                    showNoAccessMessage=true;
			                }
			            }

			            if (prefContentPage != null && prefContentPage.length() > 0 ) {
			            	prefContentPage = UINavigatorUtil.parseHREF(context,prefContentPage, null);
			                displayContentPage = UINavigatorUtil.encodeURL(prefContentPage);
			            }
					if(UINavigatorUtil.checkAccessForSettings(context, personBusObj, request, allSettings)){
    	    	String appPageCommandSuite = UIComponent.getSetting(cmdMap, "Registered Suite");    	
    	    	String appPageCommandHref = cmdMap.get("href").toString();
    	    	if(!UIUtil.isNullOrEmpty(appPageCommandSuite)){
    	    		if(appPageCommandHref.indexOf("?") > 0) { 
    	    		 appPageCommandHref += "&suiteKey="+appPageCommandSuite;
        } else {
    	    			appPageCommandHref += "?suiteKey="+appPageCommandSuite;
    	    		}
    	    		appPageCommandHref += "&StringResourceFileId="+UINavigatorUtil.getStringResourceFileId(context, appPageCommandSuite)+ "&SuiteDirectory=" + UINavigatorUtil.getRegisteredDirectory(context, appPageCommandSuite);
    	    	}
    	    	appPageCommandHref = UINavigatorUtil.parseHREF(context, appPageCommandHref.trim(), appPageCommandSuite);
    	    	cmdLabel = EnoviaResourceBundle.getProperty(context, UINavigatorUtil.getStringResourceFileId(context, appPageCommandSuite), context.getLocale(), UIComponent.getLabel(cmdMap));
    	    	displayContentPage = appPageCommandHref;  	
        	}  	
	        	}
        	}
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
                prefAppName =(String)prefContentPageMap.get("appName");
                if(prefNoAccessPage != null && prefNoAccessPage.length()>0)
                {
                    showNoAccessMessage=true;
                }
            }

            if (prefContentPage != null && prefContentPage.length() > 0 ) {
            	prefContentPage = UINavigatorUtil.parseHREF(context,prefContentPage, null);
                displayContentPage = UINavigatorUtil.encodeURL(prefContentPage);
            }
        }
    } else {
      displayContentPage = ContentPage;
    }
prefApp = applicationName !=null ? applicationName : prefAppName ;

strUserHomePage = displayContentPage;
if(isSwitchContext){
	String prefHomePage = "";
    HashMap prefHomePageMap = new HashMap();
    HashMap requestParamMap = UINavigatorUtil.getRequestParameterMap(request);
    prefHomePageMap = (HashMap)PersonUtil.getHomePageURL(context, requestParamMap);
    if(prefHomePageMap!=null)
    {
    	prefHomePage=(String)prefHomePageMap.get("homepage");
    	if (UIUtil.isNotNullAndNotEmpty(prefHomePage)) {
        	prefHomePage = UINavigatorUtil.parseHREF(context,prefHomePage, null);
        	strUserHomePage = UINavigatorUtil.encodeURL(prefHomePage);
        }
    }
}
}catch (Exception ex){
    ContextUtil.abortTransaction(context);

    if(ex.toString() != null && (ex.toString().trim()).length()>0){
        emxNavErrorObject.addMessage("emxNavigatorContentLoad:" + ex.toString().trim());
    }
}
finally{
    ContextUtil.commitTransaction(context);
}

%>
<head>
<title></title>
    <%@include file = "emxUIConstantsInclude.inc"%>
    <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    <link href="styles/emxUIDefault.css" rel="stylesheet">
</head>

<body>
<%if(!isAppInstalled){%>
<SCRIPT language="JavaScript">    
    alert("<emxUtil:i18nScript localize="i18nId">emxFramework.AppHomePage.AppNotInstalled</emxUtil:i18nScript>");
</SCRIPT>
<%}%>

<%if(!mobilesupport){%>
<SCRIPT language="JavaScript">    
    alert("<emxUtil:i18nScript localize="i18nId">emxFramework.AppHomePage.MobileNotInstalled</emxUtil:i18nScript>");
</SCRIPT>
<%}%>

<%if(!hasAccess){
	Map	appMap = UIMenu.getProductMenu(context, "My Desk", applicationName);
	String appName = (String) appMap.get(UIMenu.KEY_PRODUCT_NAME);
%>
<SCRIPT language="JavaScript">
alert("<emxUtil:i18nScript localize="i18nId">emxFramework.AppHomePage.NoAccessToHomePageCommand</emxUtil:i18nScript>"+"<%=XSSUtil.encodeForHTML(context, appName)%>");
</SCRIPT>
<%}%>

<%if(showNoAccessMessage){%>
<SCRIPT language="JavaScript">
    alert("<%=XSSUtil.encodeForJavaScript(context, prefNoAccessPage)%>");
</SCRIPT>
<%}%>

<%if(showErrorPage){%>
<SCRIPT language="JavaScript">
    alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NoMenuDisplayMsg</emxUtil:i18nScript>");
</SCRIPT>
<%}%>

<%
if(displayContentPage != null && !"".equals(displayContentPage)) {
%>
<SCRIPT language="JavaScript">
<%
if(mobilesupport){
	if(UIUtil.isNullOrEmpty(prefApp)){
		prefApp = "ENOBUPS_AP";
		if (!FrameworkLicenseUtil.isCPFUser(context)) {
			prefApp = "ENO_AEF_TP";
		}
	}
%>
getTopWindow().currentApp = "<%=XSSUtil.encodeForJavaScript(context, prefApp)%>";
<%
		try {
			Map	appMap = UIMenu.getProductMenu(context, "My Desk", prefApp);
			String appName = (String) appMap.get(UIMenu.KEY_PRODUCT_NAME);
			String brandName = "";
			if(appName != null && !"".equals(appName)){
				try {			
				brandName = appName.substring(0, appName.indexOf(" "));
				appName = appName.substring(appName.indexOf(" ") + 1);
				} catch(Exception ex){
					brandName = "";
				}
			}
			ArrayList menuList = (ArrayList)appMap.get(UIMenu.KEY_PRODUCT_MENUS);
			if(menuList.size()>0){
%>
			var appsMenuList = new Array();
<%
			for(int i=0;i<menuList.size();i++){
%>
				appsMenuList[<%=i%>] = '<%=XSSUtil.encodeForJavaScript(context, (String)menuList.get(i))%>';
<%
			}
			}else{
%>
			getTopWindow().togglePanel();
<%				
			}
			if(hasAccess && isAppInstalled && menuList.size()>0 ){
				HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
				Vector userRoleList = PersonUtil.getAssignments(context);
				String language = request.getHeader("Accept-Language");
				HashMap mdMap = UITreeUtil.getToolbar(context,(String)menuList.get(0),userRoleList,objectId,requestMap,language);
				MapList chldList = (MapList)mdMap.get("Children");
				String contentPageURL = "";
				String preferenceCommand = PropertyUtil.getAdminProperty(context, "person", context.getUser(), PersonUtil.PREFERENCE_COMMAND);				
				if(UIUtil.isNullOrEmpty(ContentURL) && UIUtil.isNotNullAndNotEmpty(preferenceCommand) && UIUtil.isNullOrEmpty(objectId)){
				  if(chldList != null && chldList.get(0) != null){	
					contentPageURL = UINavigatorUtil.getPreferenceURL(context, requestMap, chldList);		
				   }
				}   
				for(int i=1;i<menuList.size();i++){
					HashMap tempMap = UITreeUtil.getToolbar(context,(String)menuList.get(i),userRoleList,objectId,requestMap,language);
					MapList cldtemplist = (MapList)tempMap.get("Children");
					if(cldtemplist != null && cldtemplist.get(0) != null) {
						if(UIUtil.isNullOrEmpty(ContentURL) && UIUtil.isNotNullAndNotEmpty(preferenceCommand) && UIUtil.isNullOrEmpty(contentPageURL) && UIUtil.isNullOrEmpty(objectId)){
							contentPageURL = UINavigatorUtil.getPreferenceURL(context, requestMap, cldtemplist);
						}
						if(chldList != null && chldList.get(0) != null){
					chldList.addAll(cldtemplist);
						} else {
							chldList = cldtemplist; 
						}
					}
				}
				if(UIUtil.isNullOrEmpty(ContentURL) && UIUtil.isNotNullAndNotEmpty(contentPageURL) && UIUtil.isNullOrEmpty(objectId)){
					displayContentPage = contentPageURL;
					strUserHomePage = contentPageURL;
				}
				//chldMap.put("children", mainChildrenMap);
				mdMap.put("Children", chldList);
				if(chldList!=null && chldList.isEmpty() ){
					%>
					getTopWindow().togglePanel();
					<%
				}
				
%>
				
				 if(!emxUIConstants.TOPFRAME_ENABLED){
					parent.appNameForHomeTitle='<%=brandName %>' +' '+ '<%=appName%>';	
				}else{
					parent.appNameForHomeTitle='<%=appName%>';
					parent.brandName='<%=brandName %>';
				}
				 var JSONObj = { "brandName" : "<%=brandName%>", 
							"appName" : "<%=appName%>",
							"appTrigram" : "<%=prefApp%>",
							"appMenuList" : appsMenuList,
							"licensedAppList"  : "<%=prefApp%>"
						};
				 getTopWindow().setApplicationProductInfo(JSONObj);
		
				//XSSOK
				getTopWindow().changeProduct('<%=brandName%>', '<%=XSSUtil.encodeForJavaScript(context, appName)%>', '<%=XSSUtil.encodeForJavaScript(context,prefApp)%>', appsMenuList, '<%=XSSUtil.encodeForJavaScript(context,prefApp)%>', <%=isFromIFWE%>);
<%
				if ( (objectId != null && objectId.trim().length() > 0) || (treeMenu != null && treeMenu.trim().length() > 0) ) {
				} else {
%>
			getTopWindow().emxUICategoryTab.destroy();
					
					if(getTopWindow().objStructureFancyTree){
						getTopWindow().objStructureFancyTree.destroy();
					 }
					getTopWindow().showMyDesk();
					if(!getTopWindow().isPanelOpen)
						getTopWindow().togglePanel(); 					
<%
					if(isSwitchContext){
%>
					//XSSOK
						getTopWindow().bclist.insert("MyDesk", "root", ":", "<%=cmdLabel%>","","<%=strUserHomePage%>",null,null,null,JSONObj);
<%
					}else{
%>						//XSSOK
					getTopWindow().bclist.insert("MyDesk", "root", ":", "<%=cmdLabel%>","","<%=displayContentPage%>",null,null,null,JSONObj);
<%
					}
				}
}
		} catch(Exception e){
		//App home page error message
		String appHomePageErrorMessage = com.matrixone.apps.domain.util.MessageUtil.getMessage(context,null,"emxFramework.AppHomePage.NotValidApplicationTrigram", new String[]{XSSUtil.encodeForJavaScript(context, prefApp)},null, request.getLocale(),"emxFrameworkStringResource");
%>
		getTopWindow().togglePanel();
			//XSSOK
			alert("<%=appHomePageErrorMessage%>");
<%
	}
	}
%>
    var openURLIdx = getTopWindow().name.indexOf("||");
	var openURL;
	if(openURLIdx >= 0){	    
		openURL = getTopWindow().name.substring(openURLIdx+2);
	
	}
    document.location.href = openURL ? openURL : "<%=XSSUtil.encodeForJavaScript(context, displayContentPage)%>";
	    var shortcutTooltip =getTopWindow().emxUIConstants.STR_SHORTCUTS;
    getTopWindow().jQuery('#navBar').empty();
		var appMenuDiv = getTopWindow().jQuery("<div id='' class='tab-bar button-bar'></div>");
		var appSortcutButton = getTopWindow().jQuery("<button id='shortcutAppMenu' onclick='showShortcutPanel();' class='btn shortcut' title='"+shortcutTooltip+"'></button>");
		var shortcutIcon =getTopWindow().jQuery("<span title='"+shortcutTooltip+"' class='fonticon fonticon-forward site-icon'></span>");
		appMenuDiv.append(appSortcutButton);
		appSortcutButton.append(shortcutIcon);
		var nav = getTopWindow().jQuery('#navBar');	//Getting navBar
		nav.append(appMenuDiv);		//Appending to navBar

</SCRIPT>
<%
}
%>

</body>
</html>
