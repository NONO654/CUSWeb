<%--  emxPageHistoryProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPageHistoryProcess.jsp.rca 1.18 Wed Oct 22 15:48:44 2008 przemek Experimental przemek $
--%>
<%
/*
 * added for IR-025019V6R2011
 * Attribute is read in emxNavigatorBaseInclude.inc
 */
request.setAttribute("fromPageHistoryProcessPage","TRUE");
%>
<%@include file = "emxNavigatorInclude.inc"%>
<%
String pageURL =emxGetParameter(request, "pageURL");
String emxAEFSuiteDir = emxGetParameter(request,"myDeskSuiteDir");
String xmlRpc = emxGetParameter(request, "xmlRpc");

if (emxAEFSuiteDir != null && !emxAEFSuiteDir.equals("") && !emxAEFSuiteDir.equals("null")) {
    session.setAttribute("AEFMyDeskSuiteDir", emxAEFSuiteDir);
    session.setAttribute("AEFMyDeskURL", pageURL);
}

// Added To set session time out for check in-out. If that setting is left not cleaned then here we are clening it up..
int interval = session.getMaxInactiveInterval();
int maxInterval = Integer.parseInt((String)EnoviaResourceBundle.getProperty(context, "emxFramework.ServerTimeOutInSec"));
if( interval == maxInterval )
{
    interval = ((Integer)session.getAttribute("InactiveInterval")).intValue();
    session.setMaxInactiveInterval(interval);
}

String AppName =emxGetParameter(request, "AppName");
String targetLocation =emxGetParameter(request, "targetLocation");
String MenuName =emxGetParameter(request, "menuName");
String CommandName =emxGetParameter(request, "commandName");

String CommandTitle =emxGetParameter(request, "CommandTitle");

// Bug 341676
CommandTitle = CommandTitle.replaceAll("<", "< ");

String reqString = request.getQueryString();
int cmdAppNameIndex = reqString.indexOf("AppName=");
String encodedAppNameStr = reqString.substring(cmdAppNameIndex + "AppName=".length());
int AppIndex = encodedAppNameStr.indexOf("&");
if(AppIndex > 0 )
{
  encodedAppNameStr = encodedAppNameStr.substring(0,AppIndex);
}

encodedAppNameStr = encodedAppNameStr.trim();
String commandAppName = FrameworkUtil.decodeURL(encodedAppNameStr, "UTF-8");
commandAppName = commandAppName.replaceAll("<", "< ");
AppName = commandAppName;

HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
String language = request.getHeader("Accept-Language");

String LinkType =emxGetParameter(request, "linkType");
String height =emxGetParameter(request, "height");
String width=emxGetParameter(request, "width");
String objectId=emxGetParameter(request, "objectId");
String pageHistoryLimit="";
int pageLimit = 50;
pageHistoryLimit = EnoviaResourceBundle.getProperty(context, "emxSystem.pageHistory.limit");

if(pageHistoryLimit != null && pageHistoryLimit.length() > 0)
{
    pageLimit=Integer.parseInt(pageHistoryLimit);
}

if(targetLocation == null || targetLocation.equalsIgnoreCase("null") || targetLocation.trim().length() == 0 )
{
    targetLocation="_top";
}

HashMap hp = new HashMap();
//Create new Entry for MAPLIST
hp.put("DisplayName",AppName);
hp.put("CommandName",CommandName);
hp.put("MenuName",MenuName);
hp.put("URL",pageURL);
hp.put("TargetLocation",targetLocation);
hp.put("CommandTitle",CommandTitle);
hp.put("LinkType",LinkType);
hp.put("height",height);
hp.put("width",width);
hp.put("objectId",objectId);

MapList pageHistoryList = new MapList();
MapList backHistoryList = null;

pageHistoryList = (MapList)session.getAttribute("AEF.PageHistory");
if (pageHistoryList == null  || pageHistoryList.size() == 0)
{
    MapList mp = new MapList();
    if ( pageLimit > 0 )
    {
        mp.add(hp);
    }
    session.setAttribute("AEF.PageHistory",mp);
} else {
    //Before adding check for duplicate
    if (pageHistoryList != null)
    {
        for (int i=0;i<pageHistoryList.size();i++)
        {
            HashMap pageHistoryItem = (HashMap)pageHistoryList.get(i);
            String DisplayUrl = (String) pageHistoryItem.get("URL");
            if(DisplayUrl != null && DisplayUrl.length()>0 && pageURL != null && pageURL.length()>0)
            {
                if(DisplayUrl.equalsIgnoreCase(pageURL)) {
                    pageHistoryList.remove(i);
                    break;
                }
            }
        }
    }

    if ( pageHistoryList.size() > pageLimit - 1 )
    {
        //remove the last item on the list before adding the new one
        pageHistoryList.remove(0);
        pageHistoryList.add(hp);
    }else{
        pageHistoryList.add(hp);
    }
}
/////////JS History Logic///////////////////////////////////////////////////////////////
if(LinkType != null && LinkType.equalsIgnoreCase("tree")){
    int pos = pageURL.indexOf("?");
    //Made toolbar empty for bug 341849
    pageURL = "../common/emxTree.jsp?toolbar=&" + pageURL.substring(pos+1,pageURL.length());
    if(!("".equals(CommandName) || CommandName == null || CommandName.equalsIgnoreCase("undefined"))){
        pageURL = FrameworkUtil.findAndReplace(pageURL,"DefaultCategory","DC");
        pageURL = pageURL + "&DefaultCategory="+CommandName;
    }

    String strID = "";
    int position = pageURL.indexOf("objectId=");
    String strTempUrl = pageURL.substring(position,pageURL.length());
    int lastPosition = strTempUrl.indexOf("&");
    strID = strTempUrl.substring(9,lastPosition);
    String strType = "";

    if(strID != null && !"".equals(strID) && !"null".equals(strID)){
        DomainObject boGeneric = DomainObject.newInstance(context);
        boGeneric.setId(strID);
        boGeneric.open(context);
        strType = boGeneric.getTypeName();
        if(strType != null && !"".equals(strType)){
            strType = i18nNow.getTypeI18NString(strType,language);
        }
    }
    if(AppName != null && !"".equals(AppName.trim()) && !"rootnode".equalsIgnoreCase(AppName) && LinkType.equalsIgnoreCase("tree")){
        if(strType != null && !"".equals(strType)){
            CommandTitle = strType + ">>" + AppName + ">>" + CommandTitle;
        }else{
            CommandTitle = AppName + ">>" + CommandTitle;
        }
    }else if(AppName != null && !"".equals(AppName.trim()) && "rootnode".equalsIgnoreCase(AppName)){
        if(strType != null && !"".equals(strType)){
            CommandTitle = strType + ">>" + CommandTitle;
        }
    }
}
if(!targetLocation.equalsIgnoreCase("popup")){
    HashMap toolbar = new HashMap();
    toolbar = UIToolbar.getToolbar(context, "AEFBackToolbarMenu", paramMap, language);
    MapList children = UIToolbar.getChildren(toolbar);

    backHistoryList = (MapList)session.getAttribute("AEF.backHistory");

    hp.put("backURL",pageURL);
    hp.put("backCommandTitle",CommandTitle);

    if (backHistoryList == null && children.size() > 0)
    {
        backHistoryList = new MapList();
        backHistoryList.add(hp);
        session.setAttribute("AEF.backHistory",backHistoryList);
    } else if(children.size() > 0){
            //Before adding check for duplicate
            for (int i=0;i<backHistoryList.size();i++)
            {
                HashMap backHistoryItem = (HashMap)backHistoryList.get(i);
                String backHistryUrl = (String) backHistoryItem.get("backURL");
                if(backHistryUrl != null && backHistryUrl.length()>0 && pageURL != null && pageURL.length()>0)
                {
                    if(backHistryUrl.equalsIgnoreCase(pageURL)) {
                        backHistoryList.remove(i);
                        break;
                    }
                }
            }

        if ( children.size() >= backHistoryList.size() ){
                backHistoryList.add(hp);
                session.setAttribute("AEF.backHistory",backHistoryList);
        } else {
            backHistoryList.remove(0);
            backHistoryList.add(hp);
        }
    }
      
      // encode param values in query string with XSS API
      pageURL = UINavigatorUtil.encodeURL(context, pageURL);
//    pageURL = com.matrixone.apps.domain.util.XSSUtil.encodeForJavaScript(context, pageURL );
//    width = com.matrixone.apps.domain.util.XSSUtil.encodeForJavaScript(context, width );
//    height = com.matrixone.apps.domain.util.XSSUtil.encodeForJavaScript(context, height );
//    CommandTitle = com.matrixone.apps.domain.util.XSSUtil.encodeForJavaScript(context, CommandTitle );
//    targetLocation = com.matrixone.apps.domain.util.XSSUtil.encodeForJavaScript(context, targetLocation );

    if(xmlRpc != null && "true".equals(xmlRpc)){
        out.clear();
        CommandTitle = FrameworkUtil.findAndReplace(CommandTitle, "\"", "\\\"");
%>{
    run:function(){
    if(getTopWindow().historyControl) {
    	var wTop = getTopWindow();
        wTop.historyControl.addBackItem(new wTop.emxUIHistoryItem('<%=pageURL%>','<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>','<%=XSSUtil.encodeForJavaScript(context, width)%>','<%=XSSUtil.encodeForJavaScript(context, height)%>',"<%=XSSUtil.encodeForJavaScript(context, CommandTitle)%>"));
    } else {
            var url = "emxPageHistorySessionProcess.jsp?mode=backHistory&action=removeLast";
            var oXMLHTTP = emxUICore.createHttpRequest();
            oXMLHTTP.open("post", url, false);
            oXMLHTTP.send("");
    }
    }
}
<%
    }else{
%>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<script type="text/javascript">
    if(getTopWindow().historyControl) {
        getTopWindow().historyControl.isForwardSelected = true;
        var wTop = getTopWindow();
        //XSSOK
        wTop.historyControl.addBackItem(new wTop.emxUIHistoryItem('<%=pageURL%>','<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>','<%=XSSUtil.encodeForJavaScript(context, width)%>','<%=XSSUtil.encodeForJavaScript(context, height)%>',"<%=XSSUtil.encodeForJavaScript(context, CommandTitle)%>"));
    } else {
            var url = "emxPageHistorySessionProcess.jsp?mode=backHistory&action=removeLast";
            var oXMLHTTP = emxUICore.createHttpRequest();
            oXMLHTTP.open("post", url, false);
            oXMLHTTP.send("");
    }
</script>
<%  }
} %>

