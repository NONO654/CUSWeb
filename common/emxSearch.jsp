<%-- emxSearch.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearch.jsp.rca 1.22.2.1 Fri Nov  7 09:40:42 2008 ds-kvenkanna Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%!
//Method to get default search
public static Map getDefaultSearchMap(String searchName, MapList toolbarItems){
    Map defaultSearchMap = null;
    boolean getFirstCommand = (searchName == null || searchName.trim().length() == 0);
    try{
        for (int i = 0; i < toolbarItems.size(); i++){

            HashMap child = (HashMap) toolbarItems.get(i);
            if (UIToolbar.isSeparator(child)){
                continue;
            } else if (UIToolbar.isMenu(child)){
                MapList children = UIToolbar.getChildren(child);
                defaultSearchMap = getDefaultSearchMap(searchName, children);
                if(defaultSearchMap != null){
                    break;
                }
            } else {
                if (UIToolbar.isCommand(child)){
                    if (getFirstCommand || searchName.equals(UIToolbar.getName(child))){
                        defaultSearchMap = child;
                        break;
                    }
                }
            }
        }
    }catch(Exception e){
        return null;
    }

    return defaultSearchMap;
}
%>

<%
//Get requestParameters for searchContent
StringBuffer queryString = new StringBuffer("");
//Added for the bug 316152,309490
StringBuffer queryStringForURL = new StringBuffer("");
//Till here added for the bug 316152,309490


String containedInFlag=emxGetParameter(request, "containedInFlag");
if(containedInFlag==null|| "".equals(containedInFlag))
{
    containedInFlag="true";
}


    Enumeration eNumParameters = emxGetParameterNames(request);
    int paramCounter = 0;
    while( eNumParameters.hasMoreElements() ) {
        String strParamName = (String)eNumParameters.nextElement();
        String strParamValue = emxGetParameter(request, strParamName);
        //do not pass url on
        if(!"url".equals(strParamName) && !"showAdvanced".equals(strParamName)){
            if(paramCounter > 0){
                queryString.append("&");
	//Added for the bug 316152,309490
			 if(queryStringForURL.length() > 0){
			     queryStringForURL.append("&");
			 }			 
	//Till here Added for the bug 316152,309490
            }
            paramCounter++;
			queryString.append(XSSUtil.encodeForURL(context,strParamName));
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, strParamValue));
//Added for the bug 316152,309490
			if(!strParamName.equalsIgnoreCase("toolbar"))
			{
            queryStringForURL.append(XSSUtil.encodeForURL(context, strParamName));
            queryStringForURL.append("=");
            queryStringForURL.append(XSSUtil.encodeForURL(context, strParamValue));
			}
//Till here Added for the bug 316152,309490
        }
    }


String url = "";
String title = "";
String helpMarker = "";
String helpMarkerSuiteDir = "";
String suiteKey = "";
String showAdvanced = emxGetParameter(request, "showAdvanced");
String defaultSearch = emxGetParameter(request, "defaultSearch");
String searchToolbar = emxGetParameter(request, "toolbar");
String strCollectionName = emxGetParameter(request, "CollectionName");
helpMarker = emxGetParameter(request, "helpMarker");

if (searchToolbar == null || searchToolbar.trim().length() == 0)
{
    searchToolbar = PropertyUtil.getSchemaProperty(context, "menu_AEFGlobalSearch");
}

String errMsg = UINavigatorUtil.getI18nString("emxFramework.GlobalSearch.ErrorMsg.NoDefaultSearch",
                                                  "emxFrameworkStringResource", request.getHeader("Accept-Language"));


String showToolbar = "true";

if("false".equalsIgnoreCase(emxGetParameter(request, "showToolbar")))
{
	showToolbar = "false";
}

try{
        ContextUtil.startTransaction(context, false);


        Vector userRoleList = PersonUtil.getAssignments(context);
        HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
        HashMap toolbar = UIToolbar.getToolbar(context,
                                              searchToolbar,
                                              userRoleList,
                                              null,
                                              paramMap,
                                              lStr);

        if (toolbar != null){
                MapList children = UIToolbar.getChildren(toolbar);
                Map searchMap = getDefaultSearchMap(defaultSearch, children);
                //searchMap == null?
                if (searchMap == null){
                        if(defaultSearch != null && !"".equals(defaultSearch))
                        {
							searchMap = UIMenu.getCommand(context, defaultSearch);
							MapList components = new MapList();
							components.add(searchMap);
							UIComponent.translateAndEncode(context, components, null, null, lStr);
							showToolbar = "false";
						}
						else
						{
							//throw error
							emxNavErrorObject.addMessage("emxSearch: " + errMsg);
							searchMap = getDefaultSearchMap(null, children);
						}
                }
                if (searchMap != null){
                        url = UIToolbar.getHRef(context,searchMap,paramMap);
                        title = UIToolbar.getLabel(searchMap);
                        if(helpMarker == null || "".equals(helpMarker)){
                        helpMarker = UIToolbar.getSetting(searchMap, "Help Marker");
                        }
                        String regSuite = UIToolbar.getSetting(searchMap, "Registered Suite");
                        suiteKey = regSuite;
                        if (regSuite != null)
                        {
                            helpMarkerSuiteDir = UINavigatorUtil.getRegisteredDirectory(context,regSuite);
                        }
                }
                //url == null?
                if (url == null || url.trim().length() == 0){
                    //throw error
                    emxNavErrorObject.addMessage("emxSearch: " + errMsg);
                    url = "emxBlank.jsp";
                }
        }
//modified for the bug 316152,309490
    if(url != null && queryStringForURL.length() > 1){
      url += (url.indexOf("?") == -1 ? "?" : "&") + queryStringForURL.toString();
  }
  //modified for the bug 316152,309490

        if(showAdvanced == null || "".equals(showAdvanced)||"null".equals(showAdvanced)){
                showAdvanced = "false";
        }
        if(title == null || "".equals(title)||"null".equals(title)){
                title = "";
        }
        if(helpMarker == null || "".equals(helpMarker)||"null".equals(helpMarker)){
                helpMarker = "";
        }
        if(helpMarkerSuiteDir == null || "".equals(helpMarkerSuiteDir)||"null".equals(helpMarkerSuiteDir)){
                helpMarkerSuiteDir = "common";
        }

}catch (Exception ex){
        ContextUtil.abortTransaction(context);

        if(ex.toString() != null && (ex.toString().trim()).length()>0){
                emxNavErrorObject.addMessage("emxSearch:" + ex.toString().trim());
        }
}
finally{
        ContextUtil.commitTransaction(context);
}

String searchViewURL = "emxSearchView.jsp";

if(queryString != null && queryString.length() > 1){
   searchViewURL += "?" + queryString.toString();
   searchViewURL += "&showToolbar=" + showToolbar;
}
else
{
   searchViewURL += "?showToolbar=" + showToolbar;
}
searchViewURL += "&suiteKey=" + suiteKey;

url+="&containedInFlag="+XSSUtil.encodeForURL(context, containedInFlag);

%>
<html>
    <head>
        <title>Search</title>
        <%@include file = "emxUIConstantsInclude.inc"%>
        <script language="javascript" src="scripts/emxUICore.js"></script>
        <script language="javascript" src="scripts/emxUIModal.js"></script>
        <script language="javascript" src="scripts/emxUIPopups.js"></script>
        <script language="javascript" src="scripts/emxNavigatorHelp.js"></script>
        <script language="javascript" src="scripts/emxJSValidationUtil.js"></script>
        <%@ include file="emxSearchConstantsInclude.inc"%>
        <script language="JavaScript" src="scripts/emxUISearch.js"></script>
        <!-- //XSSOK -->
        <script language="JavaScript">
	        //XSSOK
	        pageControl.setSearchContentURL("<%= url %>");
            //XSSOK
            pageControl.setBaseQueryString("<%=queryString.toString()%>");
            pageControl.setHelpMarker("<xss:encodeForJavaScript><%= helpMarker %></xss:encodeForJavaScript>");
            pageControl.setShowingAdvanced("<xss:encodeForJavaScript><%= showAdvanced %></xss:encodeForJavaScript>");
            pageControl.setTitle("<xss:encodeForJavaScript><%= title %></xss:encodeForJavaScript>");
            //XSSOK
            pageControl.setHelpMarkerSuiteDir("<%= helpMarkerSuiteDir %>");
        </script>

		<script language="javascript">
		<!--
			//
			// Set the boolean flag if the character encoding is UTF8 accordingly. This flag is
			// used to decide optional usage of encodeURI() function while forming the URLs in various places.
			//
			//
			// Find out server side character encoding, from request object.
			//-->
			//XSSOK
			isCharacterEncodingUTF8 = <%="UTF8".equalsIgnoreCase (XSSUtil.encodeForJavaScript(context, request.getCharacterEncoding()))%>;




		
		</script>

        <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    </head>
    <frameset rows="*,0" framespacing="0" frameborder="no" border="0">
        <frame src="<%=searchViewURL%>" name="searchView" noresize scrolling="no" marginwidth="10" marginheight="10" frameborder="no" />
        <frameset rows="*" framespacing="0" frameborder="no" border="0">
          <frame src="emxBlank.jsp" name="searchHidden" id="searchHidden" frameborder="0" scrolling="no" />
        </frameset>
    </frameset>
    <noframes></noframes>
</html>
