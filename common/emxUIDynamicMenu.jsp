<%-- emxUIDynamicMenu.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxToolbarInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/> 

<%
try
{
%>
var objMainToolbar = null;
var objStack = new Array;
var objMenu = new emxUIToolbarMenu();
<%
response.setHeader("Cache-Control", "no-cache");
boolean noMenuAccess    = true;
boolean noMItemAccess   = true;
boolean noMenuItems     = true;
String language		= request.getHeader("Accept-Language");
String strName		=	emxGetParameter(request,"strName");
String strJPO		=	emxGetParameter(request,"strJPO");
String strMethod	=	emxGetParameter(request,"strMethod");
String strRMBMenu	=	"";
String strRMBID		=	"";
String strObjID		=	emxGetParameter(request,"objectId");
String strIsRMB		=	emxGetParameter(request,"frmRMB");
String currentRMBColumnName		=	emxGetParameter(request,"currentRMBColumnName");
HashMap paramMap	=	UINavigatorUtil.getRequestParameterMap(request);
Vector userRoleList	=	PersonUtil.getAssignments(context);
String errorLabel	=	UINavigatorUtil.getI18nString("emxFramework.Toolbar.ConfigurationError",
      					  "emxFrameworkStringResource", language);
HashMap toolbar		=	new HashMap();
HashMap hmpStatCmd	=	null ;
HashMap hmpDynMenu	=	null;
MapList statCmdList	=	null;
MapList children	=	null;
MapList dynamicCmdOnMenu = null;
boolean isMenu	=	false;
boolean bolRMB	= 	false;
String result	=	"";
MQLCommand mql	=	new MQLCommand();
HashMap hmpJPOInput = new HashMap();
HashMap commandMap = new HashMap();
String timeStamp	= emxGetParameter(request,"timeStamp");
String uiType	= emxGetParameter(request,"uiType");

//added for bug : 342600
String dynamicRMB	= emxGetParameter(request,"dynamicRMB");
if("true".equalsIgnoreCase(dynamicRMB)) {
    paramMap.put("isRMB","true");
}

paramMap.put("currentRMBColumnName",currentRMBColumnName);

HashMap requestMap = new HashMap();
String strId = "";
BusinessObject personBusObj = null;
personBusObj = PersonUtil.getPersonObject(context);
String IsStructureCompare = (String) emxGetParameter(request,"IsStructureCompare");
if(timeStamp != null && !"undefined".equalsIgnoreCase(timeStamp))
{
	if ("true".equalsIgnoreCase(IsStructureCompare))
	{
		requestMap = structureCompareBean.getRequestMap(timeStamp);
	}	
	else if ("table".equalsIgnoreCase(uiType))
	{
	    requestMap = tableBean.getRequestMap(timeStamp);
	}
	else if("structureBrowser".equalsIgnoreCase(uiType))
	{
	    requestMap = indentedTableBean.getRequestMap(timeStamp);
	}
 }

requestMap.put("currentRMBColumnName",currentRMBColumnName);

if (strIsRMB != null && "true".equals(strIsRMB))
{
    bolRMB = true;
    paramMap.put("isRMB","true");
    strRMBMenu	=	 emxGetParameter(request,"RMBMenu");
    String strRMBTableID	=	 emxGetParameter(request,"rmbTableRowId");
    StringList sList = FrameworkUtil.split(strRMBTableID,"|");
    if(sList.size() == 3){
        strRMBID = (String)sList.get(0);
    }else if(sList.size() == 4){
        strRMBID = (String)sList.get(1);
    }else if(sList.size() == 2){ //For bug 370990
        strRMBID = (String)sList.get(1);
    }else{
        strRMBID = strRMBTableID;
    }
	if(strRMBID == null || "undefined".equalsIgnoreCase(strRMBID)){
	    strRMBID = "";
	}
	if (strRMBID != null && !"".equals(strRMBID))
    {
	    requestMap.put("RMBID",strRMBID);
    }
    //If column Level RMB is defined
    if (strRMBMenu != null &&
            !"".equals(strRMBMenu))
    {
        strName = strRMBMenu;
    }
    //If Column Level is not defined get the RMB Menu from ID
    else if (strRMBID != null && !"".equals(strRMBID))
    {
      	strName = UIMenu.getRMBMenu(context,strRMBID);
    }
}
if (strObjID == null  || "".equals(strObjID)
        || "undefined".equalsIgnoreCase(strObjID))
{
    paramMap.put("objectId",(String) requestMap.get("RMBID"));
}

strId = (String) requestMap.get("RMBID");

//To Check whether the Dynamic setting is added to a menu or command
if (!bolRMB && strName != null && !"".equals(strName))
{
    isMenu = UIMenu.isMenu(context, strName);
}
//If the Dynamic  Command is on toolbar,invoke the JPO
if (!isMenu && !bolRMB)
{
	hmpJPOInput.put("paramMap",paramMap);
    hmpJPOInput.put("commandMap",commandMap);
    hmpJPOInput.put("requestMap",requestMap);
	FrameworkUtil.validateMethodBeforeInvoke(context, strJPO, strMethod, "Program");
    toolbar	=	(HashMap)JPO.invoke(context, strJPO, null, strMethod,
        JPO.packArgs(hmpJPOInput), HashMap.class);
}
else
{
    //Dynamic Menu or from RMB
    String rmbTableRowId = (String) paramMap.get("rmbTableRowId");
    String accessId = "";
    StringList sList = FrameworkUtil.split(rmbTableRowId,"|");
    if(sList.size() == 3){
        accessId = (String)sList.get(0);
    }else if(sList.size() == 4){
        accessId = (String)sList.get(1);
    }else if(sList.size() == 2){ //For bug 370990
        accessId = (String)sList.get(1);
    }else{
        accessId = rmbTableRowId;
    }
	if(accessId == null || "undefined".equalsIgnoreCase(accessId)){
	    accessId = "";
	}
	requestMap.putAll(paramMap);
	hmpStatCmd	=	UIToolbar.getToolbar(context, strName,
       					 		userRoleList,accessId,requestMap,language);
 	statCmdList	=	new MapList();
  	if (hmpStatCmd != null)
	{
 	   if ((String)paramMap.get("objectId") != null
                 && !"undefined".equalsIgnoreCase((String)paramMap.get("objectId")))
       {
           // strId   = (String)paramMap.get("objectId");
           if(PersonUtil.isPersonObjectSchemaExist(context))
           {
               personBusObj = new BusinessObject(strId);
           }
       }
 	   boolean hasAccess   = UIComponent.hasAccess(context,personBusObj, paramMap, hmpStatCmd);
	   boolean checkAccess = UICache.checkAccess(hmpStatCmd,userRoleList);
	   noMenuAccess = !(hasAccess && checkAccess);
	   if ( hasAccess && checkAccess )
		{
		    String strJPOParentMenu	=	UIToolbar.getSetting(hmpStatCmd,"Dynamic Command Program");
		    String strParentMethod	=	UIToolbar.getSetting(hmpStatCmd,"Dynamic Command Function");
		    String strIsExpanded = UIToolbar.getSetting(hmpStatCmd,"Expanded");
		    paramMap.put("Expanded", strIsExpanded);
		    requestMap.put("Expanded", strIsExpanded);
		    //if the Menu has a setting Dynamic Command .Invoke the JPO
		    if (strJPOParentMenu != null && !"".equals(strJPOParentMenu))
	        {
		        commandMap = (HashMap)hmpStatCmd.clone();
		        hmpJPOInput.put("paramMap",paramMap);
		        hmpJPOInput.put("commandMap",commandMap);
		        hmpJPOInput.put("requestMap",requestMap);
				FrameworkUtil.validateMethodBeforeInvoke(context, strJPOParentMenu, strParentMethod, "Program");
		       	hmpDynMenu = (HashMap)JPO.invoke(context, strJPOParentMenu, null, strParentMethod,
	                    JPO.packArgs(hmpJPOInput), HashMap.class);
		        dynamicCmdOnMenu = UIToolbar.getChildren(hmpDynMenu);
	            if (dynamicCmdOnMenu != null)
	            {
	                for (int j = 0; j < dynamicCmdOnMenu.size(); j++)
	                {

	           		 	statCmdList.add((HashMap) dynamicCmdOnMenu.get(j));
	                }
	            }
	            dynamicCmdOnMenu = null;
		      }
		    MapList statChildren = UIToolbar.getChildren(hmpStatCmd);
		    //Added for IR-222587V6R2014 as per Bill's request. RMB menu should be combination of Apps RMB menu and BPS default RMB menu.
			if(UIUtil.isNotNullAndNotEmpty(strName) && !"AEFDefaultAppRMB".equalsIgnoreCase(strName) && "true".equalsIgnoreCase(strIsRMB)){
						HashMap rmbDefaultCmd = UIToolbar.getToolbar(context, "AEFDefaultAppRMB",
						 		userRoleList,accessId,paramMap,language);
						//Adding child of BPS default RMB menu in child of Apps RMB menu
						statChildren.addAll(UIToolbar
								.getChildren(rmbDefaultCmd));
			}
			//till here for IR-222587V6R2014
		    String strJPOName	=	"";
		    String strMethodName	=	"";
		    HashMap child	=	null;
		    //Checking the items in the menu for the Dynamic Setting
		    if (statChildren != null)
		    {
			    for (int i = 0; i < statChildren.size(); i++)
			    {
			        child	=	(HashMap) statChildren.get(i);
			        if(statCmdList.contains(child) && !"AEFSeparator".equals(child.get("name"))){
				        continue;
			        }
			        strJPOName	=	UIToolbar.getSetting(child,"Dynamic Command Program");
			        strMethodName	=	UIToolbar.getSetting(child,"Dynamic Command Function");
			        //If there is no Dynamic Setting,or incase Item is a Menu
			        //add it to the MapList
			        if (strJPOName == null || "".equals(strJPOName) || UIToolbar.isMenu(child))
			        {
			            statCmdList.add(child);
			        }
			        //If the item is a command with  a dynamic Setting,invoke the JPO
			        else
			        {
			            commandMap = (HashMap)child.clone();
				        hmpJPOInput.put("paramMap",paramMap);
				        hmpJPOInput.put("commandMap",commandMap);
				        hmpJPOInput.put("requestMap",requestMap);
						FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName, "Program");
				        hmpDynMenu = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName,
			                    JPO.packArgs(hmpJPOInput), HashMap.class);
				        dynamicCmdOnMenu = UIToolbar.getChildren(hmpDynMenu);
			            if (dynamicCmdOnMenu != null)
			            {
			                for (int j = 0; j < dynamicCmdOnMenu.size(); j++)
			                {
			                	child = (HashMap) dynamicCmdOnMenu.get(j);
						        if(statCmdList.contains(child) && !"AEFSeparator".equals(child.get("name"))){
							        continue;
						        }
			           		 	statCmdList.add(child);
			                }
			            }

			        }
			    }

			    noMenuItems = statCmdList.isEmpty();
			 // Value of requestMap.get("expandFilter") will be false when "expandLevelFilter=false" is passed in the URL to emxIndentedTable.jsp. By default, this will be equal to "true".
				String expandFilter = (String)requestMap.get("expandFilter");
				//String displayView = (String)requestMap.get("displayView");
				
                if(requestMap.containsKey("relationship") && UITableIndented.isIndentedView(context, requestMap) && !noMenuItems && (strIsRMB != null && "true".equals(strIsRMB)) && "true".equalsIgnoreCase(expandFilter))
                {
					String expandMenuName = (String) requestMap.get("expandLevelFilterMenu");
					if(expandMenuName == null){
						expandMenuName = "AEFFreezePaneExpandLevelFilter";
					}
					
			    	
					HashMap expMap = (HashMap)UIToolbar.getToolbar(context, expandMenuName, userRoleList,accessId,requestMap,language);

						String expLbl = (String)expMap.get("label"); 
				    	expLbl =	UINavigatorUtil.getI18nString(expLbl,"emxFrameworkStringResource", language);
				    	expMap.put("label",expLbl);
				    	boolean sContainsExpAll=false;
				    	Iterator itr = statCmdList.iterator();
				    	while(itr.hasNext()){
				    		HashMap statCmdMap = (HashMap) itr.next();
				    		sContainsExpAll = statCmdMap.containsValue(expLbl);	
				    		if(sContainsExpAll){
				    			break;
				    		}
				    	}
				    	if(!sContainsExpAll){
				    	statCmdList.add(expMap);
					}
					}
				
			    toolbar.put("Children",statCmdList);
			    
		}
	}
	}
}
if (toolbar != null)
{
    children = UIToolbar.getChildren(toolbar);
    if (children != null)
    {
       for (int i = 0; i < children.size(); i++)
        {
        	HashMap child = (HashMap) children.get(i);
            if ((String)paramMap.get("objectId") != null
                      && !"undefined".equalsIgnoreCase((String)paramMap.get("objectId")))
            {
                //strId   = (String)paramMap.get("objectId");
                if(PersonUtil.isPersonObjectSchemaExist(context))
                {
                    personBusObj = new BusinessObject(strId);
                }
            }
            else
            {
                personBusObj = PersonUtil.getPersonObject(context);
            }

			//check the access settings for the menus/commands in the toolbar
			//If has Access construct the Javascript string corresponding to menus/commands
        	if ((UIComponent.hasAccess(context,personBusObj, requestMap, child))
			        && (UICache.checkAccess(child,userRoleList)))
			{
        	    noMItemAccess = false;
%>
 //XSSOK
				<%=loadToolbar(context, child, paramMap, 1, errorLabel, false, null, true)%>
<%
			}
		}
    }
}

boolean showAccess = false;
showAccess = noMenuAccess | noMenuItems | noMItemAccess;
if(showAccess && bolRMB ){
    String noActionsAvailable =	UINavigatorUtil.getI18nString("emxFramework.RMBMenu.NoActionsAvailable","emxFrameworkStringResource", language);
    StringBuffer noActions = new StringBuffer();
    noActions.append("\n  var currentToolbarObj = eval(objMainToolbar);");
    noActions.append("\n  var AEFAccessRMBmxcommandcode = eval();\n");
    noActions.append("tempMenuItem = new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY,").append("\"\",").append("\""+noActionsAvailable+"\",").append("\"javascript:;\",\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", false,\"\",\"\",\"AEFAccessRMB\");tempMenuItem.setMode(\"\");tempMenuItem.setRMB(\"true\");objMenu.setRMB(\"true\");objMenu.addItem(tempMenuItem,false);");
    out.print(noActions.toString());
}

}catch (Exception e)
{
    e.printStackTrace();
%>
     alert(emxUIConstants.STR_JS_AnErrorOWCDMR);
 <%
}

%>

