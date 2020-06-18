<%--  emxPageHistoryBodyContent.jsp.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

 <head>
<title>
</title>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleListInclude.inc"%>


<%!
public static String decodeHref(HttpServletRequest request, String strParam)
{
    if(strParam != null )
    {
        strParam=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(strParam);
    }else{
        strParam="";
    }

    String userAgent = request.getHeader("User-Agent");
    if ( userAgent == null ){
        userAgent = "";
    }

    if ( EnoviaBrowserUtility.is(request,Browsers.IE) ){
         strParam=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(strParam);
    } else {
        if ( userAgent.indexOf( "Mozilla/4" ) == -1){
            strParam=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(strParam);
        }
    }

    return strParam;
}

%>
<script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js" type="text/javascript"></script>
<script>
function openwindow(url,targetlocation,strWidth,strHeight)
{
    //Clear the Tree before opening the link
    if(getTopWindow().getWindowOpener().getTopWindow().tempTree)
    {
        getTopWindow().getWindowOpener().getTopWindow().tempTree.clear();
    }

    //Set default window width and height
    if(strWidth=="" || strWidth=="undefined")
    {
        strWidth="600";
    }

    if(strHeight=="" || strHeight=="undefined")
    {
        strHeight="600";
    }

    var frameTop = getTopWindow().getWindowOpener().getTopWindow();
    var objFrame
    var childWindow=null;

    //Use the topmost frame to open any new window in case the popup need to refresh the parent page
    if(targetlocation=="popup")
    {
        objFrame = findFrame(frameTop, "hiddenFrame");
        if(objFrame){
            var strFeatures = "width=" + strWidth + ",height=" + strHeight;
            childWindow=objFrame.window.open(url,"popupwindow",strFeatures);
            childWindow.focus();
        }
    } else if(targetlocation=="_top") {

        if(frameTop.bPageHistory == false) {
            frameTop.bPageHistory = true;
        }

        var childs = frameTop.childWindows;

        frameTop.document.location.href = url;

       // alert(childs);
        try  {
            setTimeout(function(){
                frameTop.childWindows  = childs;
            }, 1500);
        }catch(ex) {
        }

        frameTop.focus();
    }else{
        objFrame = findFrame(frameTop, "content");
        if(objFrame)
        {
            objFrame.document.location.href = url;
            objFrame.focus();
        }
    }
}
</script>
</head>


<%
int iOddEven = 1;
String sRowClass = "odd";
MapList pageHistoryList = new MapList();

String CommandTitle = "";
String DisplayName = "";
String DisplayCommand = "";
String DisplayUrl = "";
StringBuffer DisplayUrlBuffer = null;
String DisplayTargetLocation = "";
String DisplayMenu = "";
String DisplayLinkType = "";
String DisplayNameOther= "";
HashMap pageHistoryItem = new HashMap();
String DisplayWidth = "";
String DisplayHeight= "";
String objectId = "";
boolean isTree=false;
%>
<body>
<form>
<table class="list" width="100%">
<tr>
  <th> <emxUtil:i18n localize="i18nId">emxFramework.PageHistory.LinkName</emxUtil:i18n></th>
  <th> <emxUtil:i18n localize="i18nId">emxFramework.PageHistory.SuiteCategory</emxUtil:i18n></th>
  <th> <emxUtil:i18n localize="i18nId">emxFramework.PageHistory.URLAddress</emxUtil:i18n></th>
</tr>
 <%
pageHistoryList = (MapList)session.getAttribute("AEF.PageHistory");
if (pageHistoryList != null)
{
    for (int desc=pageHistoryList.size()-1;desc>=0;desc--)
    {
		DisplayUrlBuffer = new StringBuffer(100);
        if ((iOddEven%2) == 0)
        {
            sRowClass = "even";
        } else {
            sRowClass = "odd";
        }
        DisplayTargetLocation="";
        isTree=false;
        pageHistoryItem = (HashMap)pageHistoryList.get(desc);
        DisplayName = (String) pageHistoryItem.get("DisplayName");

        DisplayNameOther=DisplayName;
        DisplayCommand = (String) pageHistoryItem.get("CommandName");
        DisplayMenu = (String) pageHistoryItem.get("MenuName");
        DisplayUrl = (String) pageHistoryItem.get("URL");
        DisplayLinkType = (String) pageHistoryItem.get("LinkType");
        DisplayTargetLocation = (String) pageHistoryItem.get("TargetLocation");
        CommandTitle = (String) pageHistoryItem.get("CommandTitle");
        DisplayWidth = (String) pageHistoryItem.get("width");
        DisplayHeight = (String) pageHistoryItem.get("height");
        objectId = (String) pageHistoryItem.get("objectId");

        iOddEven++;
        String rootPah= Framework.getPagePathURL("");

        if(rootPah==null || rootPah.equals("")){
            rootPah="/ematrix/";
        }
        String clientUrl = Framework.getFullClientSideURL(request,response,"")+"/";
        String baseUrlNotify =UINavigatorUtil.notificationURL(context, request, null, null, false);
        int PositionOfURI=baseUrlNotify.indexOf(rootPah);
        String thebaseCurrent = baseUrlNotify.substring(PositionOfURI+rootPah.length(),baseUrlNotify.length());

        String Baseurl = clientUrl + thebaseCurrent;
        String sqTring="";
        String DisplayUrlSideDoor = "";

        if(DisplayLinkType == null  || DisplayLinkType.trim().length()==0)
        {
            DisplayLinkType ="";
        }

        if(DisplayLinkType != null && DisplayLinkType.equalsIgnoreCase("tree"))
        {
            if(DisplayUrl.indexOf("?") > 0)
            {
                int pos=DisplayUrl.indexOf("?");
                sqTring=DisplayUrl.substring(pos+1,DisplayUrl.length());
            }

            isTree=true;
            DisplayName=CommandTitle;
            CommandTitle=DisplayNameOther;
            if("".equals(DisplayCommand) || DisplayCommand == null || DisplayCommand.equalsIgnoreCase("undefined"))
            {
                DisplayUrlBuffer.append(Baseurl);
                DisplayUrlBuffer.append("?");
                DisplayUrlBuffer.append(sqTring);
                DisplayUrlBuffer.append("&emxTree=true");
            } else {
                DisplayUrlBuffer.append(Baseurl);
                DisplayUrlBuffer.append("?");
                DisplayUrlBuffer.append("DefaultCategory=");
                DisplayUrlBuffer.append(DisplayCommand);
                DisplayUrlBuffer.append("&");
                DisplayUrlBuffer.append(sqTring);
                DisplayUrlBuffer.append("&emxTree=true");
            }

            DisplayTargetLocation = "_top";

        } else if (DisplayLinkType.equalsIgnoreCase("menu")){
            DisplayUrlBuffer.append(Baseurl);
            DisplayUrlBuffer.append("?MenuName=");
            DisplayUrlBuffer.append(DisplayMenu);
            DisplayUrlBuffer.append("&CommandName=");
            DisplayUrlBuffer.append(DisplayCommand);
            DisplayUrlBuffer.append("&TargetLocation=");
            DisplayUrlBuffer.append(DisplayTargetLocation);
            DisplayUrlBuffer.append("&width=");
            DisplayUrlBuffer.append(DisplayWidth);
            DisplayUrlBuffer.append("&height=");
            DisplayUrlBuffer.append(DisplayHeight);
            DisplayTargetLocation = "_top";
        } else if (DisplayLinkType.equalsIgnoreCase("toolbar")){
            DisplayUrlBuffer.append(Baseurl);
            DisplayUrlBuffer.append("?MenuName=AEFGlobalToolbar&CommandName=");
            DisplayUrlBuffer.append(DisplayCommand);
            DisplayUrlBuffer.append("&TargetLocation=");
            DisplayUrlBuffer.append(DisplayTargetLocation);
            DisplayUrlBuffer.append("&width=");
            DisplayUrlBuffer.append(DisplayWidth);
            DisplayUrlBuffer.append("&height=");
            DisplayUrlBuffer.append(DisplayHeight);
            if (DisplayTargetLocation != null && !DisplayTargetLocation.equalsIgnoreCase("popup"))
            {
                DisplayTargetLocation = "_top";
            }
        }

        DisplayUrlSideDoor = DisplayUrlBuffer.toString() + "&isNavigator=true";

        if(isTree){
%>
<!-- //XSSOK -->
<tr class="<%=sRowClass%>">
<%
            if(CommandTitle != null && CommandTitle.equalsIgnoreCase("rootnode"))
            {
%>
<!-- //XSSOK -->
<td><a href="<%=DisplayUrlSideDoor%>" onClick="openwindow('<%=DisplayUrlBuffer.toString()%>','<%=DisplayTargetLocation%>','<%=DisplayWidth%>','<%=DisplayHeight%>');return false"><%=DisplayName%></a></td>
<td>&nbsp;</td>
<%
            } else {
%>
<!-- //XSSOK -->
<td><a href="<%=DisplayUrlSideDoor%>" onClick="openwindow('<%=DisplayUrlBuffer.toString()%>','<%=DisplayTargetLocation%>');return false"><%=CommandTitle%></a></td>
<!-- //XSSOK -->
<td><%=DisplayName%></td>
<%
            }
%>
<td><input type="text" name="hrefinput" value="<%=DisplayUrlSideDoor%>"/></td>
</tr>
<%
        } else {


%>
<!-- //XSSOK -->
<tr class="<%=sRowClass%>">

<!-- //XSSOK -->
<td><a href="<%=DisplayUrlSideDoor%>" onClick="openwindow('<%=DisplayUrlBuffer.toString()%>','<%=DisplayTargetLocation%>','<%=DisplayWidth%>','<%=DisplayHeight%>');return false"><%=CommandTitle%></a></td>
<!-- //XSSOK -->
<td><%=DisplayName%></td>
<td><input type="text" name="hrefinput" value="<%=DisplayUrlSideDoor%>"/></td>
</tr>
<%
        }
    }

}else{  //if there are no entries
%>
<tr><td><emxUtil:i18n localize="i18nId">emxFramework.PageHistory.NoResultsFound</emxUtil:i18n></td></tr>
<%
}
%>
</table>
</form>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
