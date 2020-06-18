<%-- emxHistoryHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxHistoryHeader.jsp.rca 1.22 Wed Oct 22 15:47:50 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<head>
<%
  String sFilter                  = emxGetParameter(request, "txtFilter");
  String HistoryMode              = emxGetParameter(request, "HistoryMode");
  String aFilter                  = emxGetParameter(request, "hiddenActionFilter");
  String sBusId                   = emxGetParameter(request, "objectId");
  String Header                   = emxGetParameter(request, "Header");
  String subHeader                = emxGetParameter(request, "subHeader");
  String preFilter                = emxGetParameter(request,"preFilter");
  String showFilterAction         = emxGetParameter(request,"showFilterAction");
  String showFilterTextBox        = emxGetParameter(request,"showFilterTextBox");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String headerdisplay  ="";
  String strFrom="";
  String strTo="";
  String strRefresh="";
  String sHeader="";
  boolean isPreFilter =true;

  strFrom=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.From" , request.getLocale());
  strTo=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.To" , request.getLocale());
  strRefresh=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Refresh" , request.getLocale());

    if(preFilter == null  || preFilter.equals("")){
       preFilter="*";
       isPreFilter=false;
    }


  if(HistoryMode==null)
   HistoryMode="CurrentRevision";

  String resourceFile = ( suiteKey != null && suiteKey.length() > 0 ) ?
      UINavigatorUtil.getStringResourceFileId(context, suiteKey) :
      "emxFrameworkStringResource";


  String sSubHeader = subHeader;
  if(subHeader!=null)
      subHeader= EnoviaResourceBundle.getProperty(context,resourceFile , request.getLocale() ,subHeader);

  // If key is not found in resource file, try the framework file
  if ( subHeader != null && subHeader.equals(sSubHeader) )
      subHeader=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, subHeader , request.getLocale());


  if(Header.indexOf("$<")>=0)
    sHeader=UIExpression.substituteValues(context, pageContext, Header, sBusId);
  else{
      sHeader=EnoviaResourceBundle.getProperty(context,resourceFile , request.getLocale() , Header);

             // If key is not found in resource file, try the framework file
               if ( Header != null && Header.equals(sHeader) )
                    sHeader=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, Header , request.getLocale());

             if(sHeader.indexOf("$<")>=0)
       sHeader=UIExpression.substituteValues(context, pageContext, sHeader, sBusId);

  }
%>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<title><emxUtil:i18n localize="i18nId">emxFramework.Common.History</emxUtil:i18n></title>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<script type="text/javascript">
    addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
</script>
        <script language="JavaScript" src="scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="scripts/emxUICore.js"></script>
        <script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>

    <script src="scripts/emxNavigatorHelp.js" type="text/javascript"></script>
    <script language="JavaScript">
  // This Function Checks For The Length Of The Data That Has
  // Been Entered And Trims the Extra Spaces In The Front And Back.
  function trim(varTextBox) {
    while (varTextBox.charAt(varTextBox.length-1) == ' ' || varTextBox.charAt(varTextBox.length-1) == "\r" || varTextBox.charAt(varTextBox.length-1) == "\n" )
      varTextBox = varTextBox.substring(0,varTextBox.length - 1);
    while (varTextBox.charAt(0) == ' ' || varTextBox.charAt(0) == "\r" || varTextBox.charAt(0) == "\n")
      varTextBox = varTextBox.substring(1,varTextBox.length);
      return varTextBox;
  }

  //Trims the filter criteria and submits the form
  function Validate() {

    if (!parent.frames[1].document.objectHistory)
    {
      return;
    }

  <%if(showFilterTextBox.equalsIgnoreCase("true")){%>
    parent.frames[1].document.objectHistory.txtFilter.value = document.objectHistoryHeader.txtFilter.value;
  <%}%>
    <%if(HistoryMode.equalsIgnoreCase("AllRevisions")){%>
      parent.frames[1].document.objectHistory.fromlist.value = document.objectHistoryHeader.fromlist.options[document.objectHistoryHeader.fromlist.selectedIndex].value;
      parent.frames[1].document.objectHistory.tolist.value = document.objectHistoryHeader.tolist.options[document.objectHistoryHeader.tolist.selectedIndex].value;
      parent.frames[1].document.objectHistory.revisionlist.value = document.objectHistoryHeader.revisionlist.value;

    <%}%>
    parent.frames[1].document.objectHistory.hiddenActionFilter.value = document.objectHistoryHeader.actionFilter.value;

    <%if(isPreFilter){
       if(showFilterAction.equalsIgnoreCase("true")){
    %>
      parent.frames[1].document.objectHistory.preFilter.value = document.objectHistoryHeader.actionFilter.value;

     <%}else{%>
         parent.frames[1].document.objectHistory.preFilter.value = "<xss:encodeForJavaScript><%=preFilter%></xss:encodeForJavaScript>";

     <%}%>

    <%}%>
    parent.frames[1].document.objectHistory.submit();
  }

  //Trims the filter criteria and submits the form
  function ActionFilter() {
    if (!parent.frames[1].document.objectHistory)
    {
      return;
    }
    var actionFil= trim(parent.frames[1].document.objectHistory.hiddenActions.value);
    var objId=document.objectHistoryHeader.objectId.value;
    var previouactionfilter=document.objectHistoryHeader.actionFilter.value;
    var windowParams = "700,700,false";
    //var linkHref="showActionSelections.jsp";
    var linkHref="emxShowHistoryActions.jsp?hiddenActions="+escape(actionFil)+"&actionfilter="+escape(previouactionfilter)+"&objectId="+objId;
    showModalDialog(linkHref,'300','400');
    //window.open(linkHref, "Action Selection",'','toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=yes,resizable=1,copyhistory=1,dependent=0');
  }


   function callPrinterPage(heading){
    var randomnumber=Math.floor(Math.random()*123456789101112);
    strURL = "";
    var strFilterit="";
    var filteringValue="";
    currentURL = parent.frames[1].document.location.href;


    if (currentURL.indexOf("?") == -1){
      strURL = currentURL + "?PrinterFriendly=true&mx.rnd=" + randomnumber + "&pfheading=" + heading;
    }else{
      strURL = currentURL + "&PrinterFriendly=true&mx.rnd=" + randomnumber + "&pfheading=" + heading;
    }
    iWidth = "700";
    iHeight = "600";
    bScrollbars = true;

      //make sure that there isn't a window already open
    if (!printDialog || printDialog.closed) {

      //build up features string
      var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=yes";

      //calculate center of the screen
      var winleft = parseInt((screen.width - iWidth) / 2);
      var wintop = parseInt((screen.height - iHeight) / 2);

      if (isIE)
        strFeatures += ",left=" + winleft + ",top=" + wintop;
      else
        strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;

      strFeatures +=  ",toolbar=yes";

      //are there scrollbars?
      if (bScrollbars) strFeatures += ",scrollbars=yes";

      //open the window
      printDialog = window.open(strURL, "printDialog" + (new Date()).getTime(), strFeatures);

      //set focus to the dialog
      printDialog.focus();

    } else {
          //if there is already a window open, just bring it to the forefront (NCZ, 6/4/01)
      if (printDialog) printDialog.focus();
    }
  }


</script>
</head>

<%!
  //
  // returns true/false based on whether it is to be displayed or not
  //
  static public String getRevisionDrowdown(BusinessObjectList bObjList,String SelectlistName)
  {
    StringBuffer dropDownOptions = new StringBuffer(80);
    String revisionlist="$";
    StringBuffer dropDownSelect = new StringBuffer(80);
    dropDownSelect.append("<select name=\"");
    dropDownSelect.append(SelectlistName);
    dropDownSelect.append("\">\n");
    BusinessObject lastObj = null;

   for(int Rev=bObjList.size()-1;Rev>=0;Rev--){
          lastObj = bObjList.getElement(Rev);
        String sBusRev=lastObj.getRevision();
        revisionlist+=sBusRev+"$";
        if( dropDownOptions.toString().equals(""))
        {
               dropDownOptions.append("<option value=\"");
               dropDownOptions.append(sBusRev);
               dropDownOptions.append("\">");
               dropDownOptions.append(sBusRev);
               dropDownOptions.append("</option>\n");
        }
        else
        {
               dropDownOptions.append("<option value=\"");
               dropDownOptions.append(sBusRev);
               dropDownOptions.append("\">");
               dropDownOptions.append(sBusRev);
               dropDownOptions.append("</option>\n");
        }
    }
    dropDownOptions.insert(0,dropDownSelect.toString());
    dropDownOptions.append("</select>");

    return dropDownOptions.toString()+"|||"+revisionlist;

  }
%>

<%



  String sHelpMarker=emxGetParameter(request,"HelpMarker");
  String suiteDir="common";
  String dropDownPrefix="";

  if (sHelpMarker == null || sHelpMarker.trim().length() == 0)
    sHelpMarker = "emxhelphistory";

  //By default set the filter to "*"
  if (sFilter == null || sFilter.trim().equals("")) {
    sFilter = "*";
  }

  //By default set History filter to "CurrentRevision"
  if (HistoryMode == null || HistoryMode.trim().equals("")) {
    HistoryMode = "CurrentRevision";
  }

  if (subHeader == null || subHeader.trim().equals("")) {
    subHeader = "Revision";
  }

  String sVersion = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Version" , request.getLocale());

  if(subHeader.equalsIgnoreCase(sVersion)) {
      dropDownPrefix=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Version" , request.getLocale());
  } else {
    dropDownPrefix=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Revision" , request.getLocale());
  }

  //By default set the action filter to "*"
  if (aFilter == null || aFilter.trim().equals("")) {
    if(preFilter==null || preFilter.equalsIgnoreCase("null"))
      aFilter = "*";
    else
      aFilter=preFilter;
  }

 BusinessObjectList bObjList=new BusinessObjectList();
      BusinessObject passedObj = new BusinessObject(sBusId);
      passedObj.open(context);
      String fromDp="";
      String toDp="";
      String revisionlist="";
      if(HistoryMode.equalsIgnoreCase("AllRevisions"))
      {
             bObjList = passedObj.getRevisions(context);
             fromDp=getRevisionDrowdown(bObjList,"fromlist");
             StringTokenizer stFrom=new StringTokenizer(fromDp,"|||");
               fromDp=stFrom.nextToken();
               revisionlist=stFrom.nextToken();
             toDp=getRevisionDrowdown(bObjList,"tolist");
             StringTokenizer stTo=new StringTokenizer(toDp,"|||");
             toDp=stTo.nextToken();
      }

passedObj.close(context);

%>

<body>
<form name="objectHistoryHeader" method="post" action="emxHistorySummary.jsp" onsubmit="Validate(); return false">
<div id="pageHeadDiv">
   <table>
<tr>
    <td class="page-title">
      <h2><xss:encodeForHTML><%=sHeader%></xss:encodeForHTML></h2>
<%
      if(subHeader != null && !"".equals(subHeader)) {
%>
        <h3><xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></h3>
<%
        }
%>
    </td>
    <%
       String processingText = UINavigatorUtil.getProcessingText(context, request.getHeader("Accept-Language"));
    %>
        <td class="functions">
              <table>
<tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
<%
if(HistoryMode.equalsIgnoreCase("AllRevisions")){%>
<td nowrap align="right">
<%=strFrom%>&nbsp;<%=dropDownPrefix%>:<%=fromDp%> <%=strTo%>&nbsp;<%=dropDownPrefix%>:<%=toDp%>&nbsp;<input type="button" value="<%=strRefresh%>" onClick="Validate()"/>
    </td>
<%}%>
              </tr></table>
        </td>
</tr>
</table>
<div id="divToolbarContainer" class="toolbar-container">
    <div class="toolbar-frame" id="divToolbar">
        <div class="toolbar">
  <table cellspacing="0" cellpadding="0" border="0">
  <tr>
    <td>
          <%if(showFilterAction.equalsIgnoreCase("true")){%>
          <emxUtil:i18n localize="i18nId">emxFramework.History.ActionType</emxUtil:i18n>
          <%}%>
          </td>
          <td>
          <%if(showFilterAction.equalsIgnoreCase("true")){%>
          <input type="text"  size="20" name="actionFilterDisplay" value="<xss:encodeForHTMLAttribute><%=aFilter%></xss:encodeForHTMLAttribute>" onFocus="this.blur()" />&nbsp;
          <input type="hidden"  size="20" name="actionFilter" value="<xss:encodeForHTMLAttribute><%=aFilter%></xss:encodeForHTMLAttribute>" onFocus="this.blur()" />&nbsp;
          <%}else{%>
          <input type="hidden"  size="20" name="actionFilter" value="<xss:encodeForHTMLAttribute><%=preFilter%></xss:encodeForHTMLAttribute>" onFocus="this.blur()" />&nbsp;
          <%}%>
          <%if(showFilterAction.equalsIgnoreCase("true")){%>
          <input type="button" value="..." onClick="ActionFilter()" />&nbsp;
          <%}%>
          <%if(showFilterAction.equalsIgnoreCase("true") && showFilterTextBox.equalsIgnoreCase("true")){%>
          <emxUtil:i18n localize="i18nId">emxFramework.History.And</emxUtil:i18n>&nbsp;
          <%}%>
          <%if(showFilterTextBox.equalsIgnoreCase("true")){%>
          <input type="text" size="10" name="txtFilter" value="<xss:encodeForHTMLAttribute><%=sFilter%></xss:encodeForHTMLAttribute>" />&nbsp;
          <%}%>
          <%if(showFilterAction.equalsIgnoreCase("true") || showFilterTextBox.equalsIgnoreCase("true")){%>
          &nbsp;<input type="button" value="<emxUtil:i18n localize="i18nId">emxFramework.History.Filter</emxUtil:i18n>" onClick="Validate()" />&nbsp;&nbsp;
          <%}%>
          </td>
         </tr>
       </table>
</div>
<div class="toolbar">
<table>
<tr>
     <td class="icon-button">
     <a href="javascript:callPrinterPage('<xss:encodeForJavaScript><%=Header%></xss:encodeForJavaScript>')">
        <img src="../common/images/buttonContextPrint.gif" title="<emxUtil:i18n localize="i18nId">emxFramework.Common.Print</emxUtil:i18n>" border="0" />
     </a>
      </td>
     <td class="icon-button">
     <a href="javascript:openHelp('<xss:encodeForJavaScript><%=sHelpMarker%></xss:encodeForJavaScript>', '<%=suiteDir%>', '<xss:encodeForJavaScript><%=request.getHeader("Accept-Language")%></xss:encodeForJavaScript>')">
        <img src="images/buttonContextHelp.gif" title="<emxUtil:i18n localize="i18nId">emxFramework.Common.Help</emxUtil:i18n>" border="0" />
     </a>
    </td>
   </tr>
</table>
</div></div></div>
</div>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sBusId%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="revisionlist" value="<%=revisionlist%>" />
</form>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>

