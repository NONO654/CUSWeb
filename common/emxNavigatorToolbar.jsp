<%-- emxNavigatorToolbar.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorToolbar.jsp.rca 1.14.2.1 Fri Nov  7 09:40:04 2008 ds-kvenkanna Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<% request.setAttribute("useScriptTags", "false"); %>
<%@include file = "emxToolbarInclude.inc"%>

<%
out.clear();
response.setContentType("text/javascript;");
String FULL_SEARCH_ERROR = UINavigatorUtil.getI18nString("emxNavigator.UIMenuBar.FullSearchError", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
String BAD_CHAR_SET = EnoviaResourceBundle.getProperty(context, "emxNavigator.UIMenuBar.FullSearchBadCharList");
String BADCHAR_ENTERED = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.BadChars", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
String strLicenseError = UINavigatorUtil.getI18nString("emxFramework.Login.LicenseError", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
%>
//XSSOK
var FULL_SEARCH_ERROR = "<%=FULL_SEARCH_ERROR%>";
var objMainToolbar = null;
var objContextToolbar = null;
objMainToolbar = emxUINavigator.toolbar;
//objMainToolbar.setWidth(0.8);
objMainToolbar.setMaxLabelChars(<%=defaultLength%>);
var objOrigMenu;
var objMenu;
var objStack = new Array;
/*
*Validate bad characters entered for search in full text widget in Global toolbar
*/
//XSSOK
var BADCHAR_ENTERED = "<%=BADCHAR_ENTERED %>";
var BAD_CHAR = '<%=BAD_CHAR_SET %>';
var BAD_CHAR_ARRAY = BAD_CHAR.split(" ");
function validateBarChar(iValue){
	var iLeng = iValue.length;
   	for (index = 0; index < iLeng; index++){
        var charVar = iValue.charAt(index);
        for(var k=0; k < BAD_CHAR_ARRAY.length; k++){
        	if(charVar == BAD_CHAR_ARRAY[k]){
        		return false;
        	}
        }
    }
    return true;
}

<%
Vector userRoleList = PersonUtil.getAssignments(context);
String stToolbar = emxGetParameter(request, "toolbar");
String language = request.getHeader("Accept-Language");
String parentOID = emxGetParameter(request, "parentOID");
String isPopup = emxGetParameter(request, "isPopup");
String relId = emxGetParameter(request, "relId");
String suiteKey = emxGetParameter(request, "suiteKey");

String suiteDir = "";
String suiteDirParam = "";
if ((suiteKey != null) && (suiteKey.trim().length() > 0))
{
    suiteDir = UINavigatorUtil.getRegisteredDirectory(context,suiteKey);
}

if (suiteDir == null || "".equals(suiteDir))
{
    suiteDir = suiteDirParam;
}

HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
String AEFMyDeskSuiteDir = (String)session.getAttribute("AEFMyDeskSuiteDir");
if (paramMap == null)
{
    paramMap=new HashMap(2);
    paramMap.put("AEFMyDeskSuiteDir", AEFMyDeskSuiteDir);
}
else
{
    paramMap.put("AEFMyDeskSuiteDir", AEFMyDeskSuiteDir);
}

paramMap.put("emxAEFAppSuiteDir",suiteDir);

//String resource IDs
String errorLabel = UINavigatorUtil.getI18nString("emxFramework.Toolbar.ConfigurationError",
                                                  "emxFrameworkStringResource", language);

    try
    {
        ContextUtil.startTransaction(context, false);

        String objectId = "";
        if (PersonUtil.isPersonObjectSchemaExist(context))
        {
            // Get the person objectId for checking the access on navigator toolbar command
            objectId =PersonUtil.getPersonObjectID(context);
        }

		// If there is any objectId passed into the main page, rempve from the map.
		// It is not required for the Navigator toolbar
		if (paramMap != null && paramMap.containsKey("objectId")) {
			paramMap.remove("objectId");
		}

        HashMap toolbar = new HashMap();

        if (stToolbar != null)
        {
            toolbar = UIToolbar.getToolbar(context,
                                          stToolbar,
                                          userRoleList,
                                          objectId,
                                          paramMap,
                                          language);
        }
        String javascriptInclude="";
        if (toolbar != null)
        {
            javascriptInclude = UINavigatorUtil.parseHREF(context,UIToolbar.getSetting(toolbar,"Javascript Include"),UIToolbar.getSetting(toolbar,"Registered Suite"));
            if(javascriptInclude!=null && !"".equals(javascriptInclude))
            {
%>
                 <!-- //XSSOK -->
                <jsp:include page = "<%=javascriptInclude%>" flush="true" />
<%
                javascriptInclude="";
            }
            MapList children = UIToolbar.getChildren(toolbar);

            if (children != null)
            {
                for (int i = 0; i < children.size(); i++)
                {
                    HashMap child = (HashMap) children.get(i);

                    //if the first item to display is a separator, skip it
                    if (i == 0 && UIToolbar.isSeparator(child))
                    {
                        continue;
                    }

                    //if the menu does not have any commands to display, don't display it
                    /*if (UIToolbar.isMenu(child))
                    {
                        if (isDisplayItem(child) == false)
                        {
                            continue;
                        }
                    }*/
                  /*Below code is added for Share icon, which will behave as Menu or Command depends upon children under Share menu, 
                   	if any apps will add any custom command under share menu, then it will appear as menu,
                   	otherwise it will appear as normal command on global toolbar, because number of commands 
                   	under Share menu will be 1 in that case
                   */
                   if(UIToolbar.getChildren(child) != null  && "true".equalsIgnoreCase(isPopup)){
                		if("AEFPersonMenu".equals(child.get("name"))){
                			UIComponent.modifySetting(child,"GrayOut","true");
                		}
                		if("AEFMyHome".equals(child.get("name"))){                			
                			MapList homeMenuChildren = UIToolbar.getChildren(child);                			               			
                			Iterator itr = homeMenuChildren.iterator();
                			while(itr.hasNext()){
                				HashMap childCommand = (HashMap)itr.next();
                				if(!"AEFHomeToolbar".equals(childCommand.get("name"))){
                                	itr.remove();
                                }                				
                			}                			
                		}
                   }


                    //Added for Toolbar enhancements - Begin
                    //Below code is added to get the Javascript Include setting and include the file on the toolbar
                    javascriptInclude=   UINavigatorUtil.parseHREF(context,UIToolbar.getSetting(child,"Javascript Include"),UIToolbar.getSetting(child,"Registered Suite"));

                    String commandFormat = UIToolbar.getSetting(child,"format");
                    if(javascriptInclude!=null && !"".equals(javascriptInclude))
                    {
%>
                         <!-- //XSSOK -->
                        <jsp:include page = "<%=javascriptInclude%>" flush="true" />
<%
                        javascriptInclude="";
                    }
                    //Added for Toolbar enhancements - End
            %>
<!-- //XSSOK -->
<%=loadToolbar(context, child, paramMap, 0, errorLabel, true)%>
            <%
                }
            }
        }
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if(ex.toString() != null)
        {
        	//Added for the Bug 376256
        	if ((ex.getMessage().trim()).indexOf("CPF")!=-1){
%>
                    <!-- //XSSOK -->
                    alert("<%=strLicenseError + " " + ex.getMessage().trim()%>");
                    getTopWindow().location.href = "../emxLogout.jsp";

<%
            }
        	else if ((ex.getMessage().trim()).length()>0){
        		emxNavErrorObject.addMessage("emxNavigatorToolbar:" + ex.getMessage().trim());
        	}
        	//End for the Bug 376256
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
