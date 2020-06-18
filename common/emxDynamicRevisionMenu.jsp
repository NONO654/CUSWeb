<%-- emxDynamicRevisionMenu.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxToolbarInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
try
{ 
%>
var objMainToolbar = "";
var objMenu = new emxUIToolbarMenu();
<%
//added for bug : 345385
response.addHeader("Cache-Control", "no-cache");

//Tree Menu Revision Filter
String language		=	emxGetParameter(request , "Accept-Language");
String strObjID		=	emxGetParameter(request,"objectId");
String isforRoot    = 	emxGetParameter(request,"isforRoot");
HashMap hmpParamMap	=	UINavigatorUtil.getRequestParameterMap(request);
String errorLabel	=	EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Toolbar.ConfigurationError",
      					  new Locale(language));
String revId = ""; 
StringList strlObjectSelList = new StringList();
strlObjectSelList.add("id");
strlObjectSelList.add("name");
strlObjectSelList.add("revision");
DomainObject doObject = new DomainObject(strObjID);
MapList mplObjectRev = doObject.getRevisions(context,strlObjectSelList,false);
int revSize = mplObjectRev.size();
for(int m=0;m<revSize;m++)
{
    Map tempMap = (Map)mplObjectRev.get(m);
    HashMap hmpCmds  = new HashMap();
    revId = (String)tempMap.get("id");
    hmpCmds.put("type","command");
    HashMap settingMap = new HashMap();
    settingMap.put("Registered Suite","Framework");
    String target = "popup";
    if("true".equalsIgnoreCase(isforRoot)){
        target = "content";
    }
    settingMap.put("Target Location",target);
    hmpCmds.put("settings",settingMap);
    hmpCmds.put("label",(String) tempMap.get("revision"));
    hmpCmds.put("name","RevisionCommands");
    hmpCmds.put("href","../common/emxTree.jsp?objectId="+revId);
    
    if(revSize>1)
    {
 %>
    <!-- //XSSOK -->
    <%=loadToolbar(context, hmpCmds, hmpParamMap, 1, errorLabel, false, null, true)%>    
 <%
    }
}

}catch (Exception e)
{
    e.printStackTrace();
 %>
   alert(emxUIConstants.STR_JS_AnErrorOICM);
<%
}

%>

