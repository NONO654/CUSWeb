<%--  emxCompInboxDialog.jsp   -  This page loads the mails of logged in user.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@ include file="emxNavigatorInclude.inc" %>
<html>
<head>
  <title></title>

<%@include file = "../emxPaginationInclude.inc" %>

  
<%!
  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
  static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>

<%
  // format to be used for the date columns
  String DateFrm                    = (new Integer(java.text.DateFormat.MEDIUM)).toString();
  String sbrowser                   = request.getHeader("USER-AGENT");
  String jsTreeID                   = emxGetParameter(request,"jsTreeID");
  String suiteKey                   = emxGetParameter(request,"suiteKey");
  String sReadMails                 = emxGetParameter(request, "chkbxReadmails");
  String sUnreadMails               = emxGetParameter(request, "chkbxUnreadmails");
  String sSubjectFilter             = emxGetParameter(request, "txtSubjectFilter");
  String sFilterKey                 = emxGetParameter(request, "Key");
  String sPreviousKey               = emxGetParameter(request, "PreviousKey");
  String sNextSortOrder             = emxGetParameter(request, "sort");
  String sFilter                    = emxGetParameter(request, "filter");
  String sSortImage                 = emxGetParameter(request, "sortImage");
  String sMailstatus                = emxGetParameter(request,"mx.page.filter");
  String languageStr                = request.getHeader("Accept-Language");
  String sPrinterFriendly           = emxGetParameter(request, "PrinterFriendly");
  String showPaginationMinimized    = emxGetParameter(request, "showPaginationMinimized");
  String pageNumber                 = emxGetParameter(request, "pageNumber");
  Locale locale                     = new Locale(languageStr);

  String canSend                    = "";
  String sRowColor                  = "even";
  String sSubject                   = "";
  String sMailId                    = "";
  String sFrom                      = "";
  String sDate                      = "";
  String treeUrl                    = "";
  String target                     = "";
  String popTreeUrl                 = "";
  boolean bShowReadMails            = false;
  boolean bShowUnreadMails          = false;
  boolean bMailListed               = false;
  boolean bShowAttachCol            = true;
  StringBuffer encodeUrl            = new StringBuffer(150);

  if(sMailstatus == null || "".equals(sMailstatus))
    sMailstatus = "all";

  String showPFPage                 = emxGetParameter(request,"PrinterFriendly");
  String isDialogPage               = emxGetParameter(request,"contentPageIsDialog");
%>
  <%@include file = "emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxUICoreMenu.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxUIActionbar.js"></script>
<script>
<%
  if ("true".equals(showPFPage)){
%>
    addStyleSheet("emxUIDefaultPF");
    addStyleSheet("emxUIListPF");
    addStyleSheet("emxUIMenu");
<%
    if (!"true".equalsIgnoreCase(isDialogPage)){
%>
    addStyleSheet("emxUIPropertiesPF");
<%
    }
%>
    addStyleSheet("emxUIPF");
<%
  } else {
%>
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIMenu");
<%
    if (!"true".equalsIgnoreCase(isDialogPage)){
%>
        addStyleSheet("emxUIProperties");
<%
    }
  }
%>
</script>

<script language="JavaScript">
function fnEncode(str)
{
  var dest="";
  var len=str.length;
  var index=0;
  var code=null;
  for(var i=0;i<len; i++){
    var ch=str.charAt(i);
    if(ch==" "){
      code="%20";
    }
    if(code!=null){
      dest+=str.substring(index,i)+code;
      index=i+1;
      code=null;
    }
  }
  if(index<len){
    dest+=str.substring(index,len);
    return dest;
  }
}


  // For filtering the mails based on selected option and entered text.
  function filterMessages() {

    document.formInbox.filter.value = "true";
    //document.formInbox.sort.value = "descending";
    var sFilterKeyValue=document.formInbox.filterKey.value;
    var filterSortDirection=document.formInbox.sort.value;
    var filterSortImage;
    if( filterSortDirection=="descending")
      filterSortImage="images/utilSortArrowDown.png";
    else
      filterSortImage="images/utilSortArrowUp.png";

    sFilterKeyValue=fnEncode(sFilterKeyValue);
    filterSortDirection=fnEncode(filterSortDirection);
    document.formInbox.sortImage.value = "images/utilSortArrowDown.png";
    document.formInbox.action = "emxCompInboxDialog.jsp?Key="+sFilterKeyValue+"&sort="+filterSortDirection+"&sortImage="+filterSortDirection+"&beanName=emxCompInboxDialogFS";
    document.formInbox.submit();
    parent.loadfooterFrame(parent.pgfooterurl, parent.pgheaderurl);
    //parent.frames[2].document.location.reload();
    //parent.frames[2].document.forms[0].submit();
    //return;

  }

  function showEditDialogPopup(pageName) {
    var link= pageName;
    //XSSOK
    getTopWindow().showModalDialog('emxCompWriteMailDialogFS.jsp?mailId=<%=XSSUtil.encodeForURL(context, sMailId)%>&pageName='+link,575,575);
  }

    function reloadparent()
  {

    document.reload.filter.value = "true";
    //document.reload.sort.value = "descending";
    var sFilterKeyValue=document.reload.filterKey.value;
    var filterSortDirection=document.reload.sort.value;
    var filterSortImage;
    if( filterSortDirection=="descending")
      filterSortImage="images/utilSortArrowDown.png";
    else
      filterSortImage="images/utilSortArrowUp.png";

    sFilterKeyValue=fnEncode(sFilterKeyValue);
    filterSortDirection=fnEncode(filterSortDirection);
    mxpagefilter=document.formInbox.mxpagefilter.value;

    //var filterSortImage=fnEncode(document.formInbox.sortImage.value);
    document.reload.sortImage.value = "images/utilSortArrowDown.png";
    document.reload.action = "emxCompInboxDialog.jsp?Key="+sFilterKeyValue+"&sort="+filterSortDirection+"&sortImage="+filterSortDirection+"&beanName=emxCompInboxDialogFS&mx.page.filter="+mxpagefilter;
    document.reload.submit();

    //window.location.reload();
  }

  function doCheck() {
    var objForm = document.formInbox;
    var chkList = objForm.chkList;
    var reChkName = /chkbxMailId/gi;
    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkbxMailId') > -1)
        objForm.elements[i].checked = chkList.checked;
  }

   function updateCheck() {
    var objForm = document.formInbox;
    var chkList = objForm.chkList;
    chkList.checked = false;
  }

    // Will help in deleting the selected mail from the user Inbox.
      function deleteMail() {
        if (selectionCheck()) {
          if(confirm("<emxUtil:i18nScript localize='i18nId'>emxFramework.IconMail.Common.DeleteMsg</emxUtil:i18nScript>")) {
            mxpagefilter=document.formInbox.mxpagefilter.value;
            Pag=document.formInbox.showPaginationMinimized.value;
            var selectObject="";
            var passedParam="";
            if(parent.frames[2].document.bottomCommonForm !=null){
               selectObject = parent.frames[2].document.bottomCommonForm.mxpagenumber;
               if(selectObject !=null){
                  passedParam = selectObject.options[selectObject.selectedIndex].value;
                  passedParam = parseInt(passedParam,10);
               }else{
                  passedParam=1;
               }
            }
            document.formInbox.action = "emxCompDeleteMail.jsp?mx.page.filter="+mxpagefilter+"&pageNum="+passedParam+"&showPaginationMinimized="+Pag;
            document.formInbox.submit();
          }
        } else {
          alert("<emxUtil:i18nScript localize="i18nId">emxFramework.IconMail.Inbox.AlertMsg1</emxUtil:i18nScript>");
        }
        return;
      }

      // Is used for checking which mail is checked for deleting, reading and replying.
      function selectionCheck() {
        var checkedFlag = "false";
        // check to see if atleast one checkbox is checked
        for( var selectedIndex = 0; selectedIndex < document.formInbox.elements.length; selectedIndex++ ) {
          if (document.formInbox.elements[selectedIndex].type == "checkbox" &&
            document.formInbox.elements[selectedIndex].name == "chkbxMailId" &&
            document.formInbox.elements[selectedIndex].checked ){
            checkedFlag = "true";
            break;
          }
        }
        if (checkedFlag == "false") {
          return false;
        } else {
          return true;
        }
  }

    function windowPopup(url)
    {
        var windowObject;
        var swidth="760";
        var sheight="600";
            windowObject = showModalDialog(url, swidth, sheight);
    }

</script>

<%
  canSend = (String)session.getAttribute("canIconMailSendMail");

  String currentSortImage=(String)session.getAttribute("currentsortimage");
  if(currentSortImage!=null && sSortImage==null){
    sSortImage=currentSortImage;
     if(currentSortImage.indexOf("Down")>0)
       sNextSortOrder="descending";
     else
       sNextSortOrder="ascending";
   }

  if (sSortImage == null)
    sSortImage = "images/iconSortDown.gif";
    else{
     if(sNextSortOrder!=null){
      if(sNextSortOrder.equals("descending"))
        sSortImage = "images/utilSortArrowDown.png";
      else
        sSortImage = "images/utilSortArrowUp.png";
     }
    }

   session.setAttribute("currentsortimage",sSortImage);


  if (sFilter == null)
    sFilter = "false";

  if (sNextSortOrder == null) {
    sNextSortOrder = "descending";
  }

  String currentFilter=(String)session.getAttribute("currentfilter");

  if(currentFilter!=null && sFilterKey==null)
    sFilterKey=currentFilter;

  if (sFilterKey == null || sFilterKey.equals("")) {
    sFilterKey = "Received Date";
  }
  session.setAttribute("currentfilter",sFilterKey);

  if (sPreviousKey == null)
    sPreviousKey = "";

  if(sMailstatus == null) {
   bShowReadMails   = true;
   bShowUnreadMails = true;
  } else {

    if(sMailstatus.equals("all")) {
      bShowReadMails   = true;
      bShowUnreadMails = true;
    } else if(sMailstatus.equals("unread")) {
      bShowUnreadMails       = true;
    } else if(sMailstatus.equals("read")) {
      bShowReadMails   = true;
    }
  }

  String currentSubjectFilter=(String)session.getAttribute("currentsubjectfilter");

  if(currentSubjectFilter!=null && sSubjectFilter==null)
    sSubjectFilter=currentSubjectFilter;

  if (sSubjectFilter == null) {
    sSubjectFilter         = "";
  } else
    sSubjectFilter = sSubjectFilter.trim();

  if (sSubjectFilter.equals("")) {
    sSubjectFilter         = "*";
  }

  session.setAttribute("currentsubjectfilter",sSubjectFilter);

  // Filter pattern for the Subject for the mails.
  Pattern patternSubject   = new Pattern(sSubjectFilter.trim());

  // read the user icon mails
  IconMailList iconMailList = IconMail.getMail(context);
  IconMailItr iconMailItr      = new IconMailItr(iconMailList);
  IconMail iconMailObj     = null;
/****************************Sorting Starts *********************/
  Vector vectorSort = null;
  TreeMap tMap = new TreeMap();
  String sKey = "";
  while (iconMailItr.next()) {
    iconMailObj = iconMailItr.obj();
    if (sFilterKey.equals("Received Date")) {
      sKey = Integer.toString(iconMailObj.getDateValue());
    } else if (sFilterKey.equals("From")) {
      sKey = com.matrixone.apps.domain.util.PersonUtil.getFullName(context, iconMailObj.getFrom());
    } else if (sFilterKey.equals("Subject")) {
      sKey = iconMailObj.getSubject();
    } else if (sFilterKey.equals("Attach")) {
      sKey = Boolean.valueOf(iconMailObj.hasObjects()).toString();
    }
    sKey = sKey.toLowerCase();
    if (tMap.containsKey(sKey)) {
      vectorSort = (Vector) tMap.get(sKey);
      vectorSort.addElement(iconMailObj);
    } else {
       vectorSort = new Vector();
       vectorSort.addElement(iconMailObj);
       tMap.put(sKey, vectorSort);
    }
  }
  ArrayList aList = new ArrayList(tMap.values());
  IconMailList imList = new IconMailList();
  for (int index = 0; index<aList.size(); index++) {
    Vector vectSort = (Vector) aList.get(index);
    for (int vecCount = 0; vecCount< vectSort.size(); vecCount++ ) {
      iconMailObj = (IconMail)vectSort.elementAt(vecCount);
      if (sNextSortOrder.equals("descending")) {
        imList.insertElementAt(iconMailObj,0);
      } else {
        imList.addElement(iconMailObj);
      }
    }
  }
  /****************************Sorting Ends *********************/

    MapList Maplistobject = new MapList(imList.size());
    IconMailItr iconItr      = new IconMailItr(imList);
   while (iconItr.next()) {
      IconMail iconMailObjItem  = iconItr.obj();
      sSubject = iconMailObjItem.getSubject();
      sMailId  = String.valueOf(iconMailObjItem.getNumber());
      sFrom    = iconMailObjItem.getFrom();
      sDate    = iconMailObjItem.getDate();
    if (patternSubject.match(sSubject)) {
      Hashtable eachIconMail = new Hashtable();
      eachIconMail.put("IconMailObject", iconMailObjItem);
        if ((bShowUnreadMails) && (iconMailObjItem.isNew() || iconMailObjItem.isUnRead())) {
            Maplistobject.add(eachIconMail);
       }else if ((bShowReadMails) && (iconMailObjItem.isRead())) {
            Maplistobject.add(eachIconMail);
       }else if (iconMailObjItem.isTaskMail()){
            Maplistobject.add(eachIconMail);
       }
     }
   }

      emxPage.getTable().setObjects(Maplistobject);

    //if (emxPage.isNewQuery()) {
  // pass the resultList to the following method
     // emxPage.getTable().setObjects(Maplistobject);
  //}

  Maplistobject = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());


   // get the current suite properties.
 /* String sPropertiesFileName = (String)session.getAttribute("centralPropertyName");

  Properties propCentralProperties = (Properties)application.getAttribute(sPropertiesFileName);

  //GUI Constants
  String sShowAttachements = propCentralProperties.getProperty("emxComp.ShowAttachements");
  boolean bShowAttachCol = false;
  if ( (sShowAttachements != null) && (sShowAttachements.equals("TRUE")) ) {
    bShowAttachCol = true;
  }*/

  iconMailItr      = new IconMailItr(imList);
%>
<script language="JavaScript">

 //For Sorting the Messages based on the option(Subject, From, Received Date,Attachments) clicked
  function sortMessages(keys , filterKey) {
    if (keys == filterKey) {
<%
      if (sNextSortOrder.equals("ascending")) {
%>
        document.formInbox.sort.value = "descending"
        document.formInbox.sortImage.value = "images/utilSortArrowUp.png"
<%
      }
      else if(sNextSortOrder.equals("descending")) {
%>
      document.formInbox.sort.value = "ascending"
      document.formInbox.sortImage.value = "images/utilSortArrowDown.png"
<%
      }
%>
    }

    var selectObject="";
    var passedParam="";
    if(parent.document.bottomCommonForm !=null){
       selectObject = parent.document.bottomCommonForm.mxpagenumber;
          if(selectObject !=null){
             passedParam = selectObject.options[selectObject.selectedIndex].value;
             passedParam = parseInt(passedParam,10);
           }else{
             passedParam=1;
           }
         //parent.frames[2].document.location.href=parent.frames[2].document.location.href;
    }

    document.formInbox.PreviousKey.value = filterKey;
    document.formInbox.Key.value = keys;
    mxpagefilter=document.formInbox.mxpagefilter.value;
    document.formInbox.action = "emxCompInboxDialog.jsp?beanName=emxCompInboxDialogFS&mx.page.filter="+mxpagefilter+"&pageNumber="+passedParam;
    document.formInbox.submit();
    return;
  }

  </script>
</head>

<body>
 <form name="reload" method="post">
   <input type="hidden" name="filterKey" value="<xss:encodeForHTMLAttribute><%=sFilterKey%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="filter" value="false"/>
   <input type="hidden" name="sort" value="<xss:encodeForHTMLAttribute><%=sNextSortOrder%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="sortImage" value="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="mx.page.filter" value="<xss:encodeForHTMLAttribute><%=sMailstatus%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="showPaginationMinimized" value="<xss:encodeForHTMLAttribute><%=showPaginationMinimized%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="pageNumber" value="<xss:encodeForHTMLAttribute><%=pageNumber%></xss:encodeForHTMLAttribute>"/>
 </form>

<form name="formInbox" method="post" onSubmit="filterMessages(); return false">
  <input type="hidden" name="mailIds" value=""/>
  <input type="hidden" name="Key" value="" />
  <input type="hidden" name="sort" value="<xss:encodeForHTMLAttribute><%=sNextSortOrder%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="filter" value="false"/>
  <input type="hidden" name="sortImage" value="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="PreviousKey" value=""/>
  <input type="hidden" name="filterKey" value="<xss:encodeForHTMLAttribute><%=sFilterKey%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="mx.page.filter" value="<xss:encodeForHTMLAttribute><%=sMailstatus%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="mxpagefilter" value="<xss:encodeForHTMLAttribute><%=sMailstatus%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="showPaginationMinimized" value="<xss:encodeForHTMLAttribute><%=showPaginationMinimized%></xss:encodeForHTMLAttribute>"/>

  <table border="0" cellpadding="3" cellspacing="2" width="100%">

    <tr>
          <%if(sPrinterFriendly==null){%>
      <td align="right"><label for="Name"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Subject</emxUtil:i18n></label>

      <input type="text" name="txtSubjectFilter" value="<xss:encodeForHTMLAttribute><%=sSubjectFilter%></xss:encodeForHTMLAttribute>" size="10">
      <input type="button" name="btnFilter" value="<emxUtil:i18n localize="i18nId">emxFramework.History.Filter</emxUtil:i18n>" onclick="javascript:filterMessages()" /></td>
      <%}else{%>
      <td>&nbsp;
      </td>
      <%}%>
    </tr>

  </table>
  <table <%if(sPrinterFriendly==null){%>class="list"<%}%>>
    <tr>
        <%if(sPrinterFriendly==null){%>
      <th width="5%" style="text-align:center">
        <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
      </th>
       <%}else{%>
       <th width="5%" style="text-align:center">
        &nbsp;
      </th>
       <%}%>
      <th width="4%" style="text-align:center"><img src="images/iconUnReadMail.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTUnReadMessage</emxUtil:i18n>" /></th>

<%
  if(sFilterKey.equals("Attach")) {
%>
      <th><a  href="javascript:sortMessages('Subject','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Subject</emxUtil:i18n></a></th>
      <th class="sortMenuItem">
       <table border="0" cellspacing="0" cellpadding="0">
        <tr>
          <th width="4%" style="text-align:center" class="sortMenuItem"><a class="header" href="javascript:sortMessages('Attach','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')">
        <img src="images/iconAttachment.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Attachments</emxUtil:i18n>" /></a>
        <img src="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>" border="0" /></th>
        </tr></table></th>
      <th><a  href="javascript:sortMessages('From','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.From</emxUtil:i18n></a></th>
      <th><a  href="javascript:sortMessages('Received Date','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.Received</emxUtil:i18n></a></th>
      <th width="6%">&nbsp;</th>
<%
  } else if(sFilterKey.equals("Subject")) {
%>
      <th class="sortMenuItem">
        <table border="0" cellspacing="0" cellpadding="0">
        <tr>
          <th class="sortMenuItem"><%if(sPrinterFriendly==null){%><a href="javascript:sortMessages('Subject','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Subject</emxUtil:i18n></a></th>
          <td><img src="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>" border="0" /></td>
        </tr></table></th>
      <th width="4%" style="text-align:center"><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Attach','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%>
       <img src="images/iconAttachment.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Attachments</emxUtil:i18n>" /></a></th>
      <th><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('From','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.From</emxUtil:i18n></a></th>
      <th><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Received Date','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.Received</emxUtil:i18n></a></th>
      <th width="6%">&nbsp;</th>
<%
  } else if (sFilterKey.equals("From")) {
%>

      <th><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Subject','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Subject</emxUtil:i18n></a></th>
       <th width="4%" style="text-align:center"><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Attach','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%>
       <img src="images/iconAttachment.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Attachments</emxUtil:i18n>" /></a></th>
      <th class="sortMenuItem">
          <table border="0" cellspacing="0" cellpadding="0">
            <tr><th class="sortMenuItem"><%if(sPrinterFriendly==null){%><a class="header" href="javascript:sortMessages('From','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.From</emxUtil:i18n></a></th>
            <td><img src="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>" border="0" /></td>
            </tr></table>
      </th>
      <th><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Received Date','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.Received</emxUtil:i18n></a></th>
      <th width="6%">&nbsp;</th>
<%
  } else {
 %>
      <th><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Subject','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Subject</emxUtil:i18n></a></th>
      <th width="4%" style="text-align:center"><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Attach','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><img src="images/iconAttachment.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTAttachedObject</emxUtil:i18n>"></a></th>
      <th><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('From','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.From</emxUtil:i18n></a></th>
      <th class="sortMenuItem">
      <table border="0" cellspacing="0" cellpadding="0">
      <tr >
      <th class="sortMenuItem"><%if(sPrinterFriendly==null){%><a  href="javascript:sortMessages('Received Date','<xss:encodeForJavaScript><%=sFilterKey%></xss:encodeForJavaScript>')"><%}%><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.Received</emxUtil:i18n></a></th>
        <td><img src="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>" border="0" /></td>
       </tr>
       </table>
      </th>
      <th width="6%">&nbsp;</th>
<%
  }
    String sParams        = "jsTreeID="+jsTreeID+"&suiteKey="+suiteKey+"&beanName=emxCompInboxDialogFS";
%>
  </tr>




<%

  //To check if there is any mails
  if (iconMailList.size() != 0) {%>
      <framework:mapListItr mapList="<%=Maplistobject%>" mapName="templateMap">

   <%
     encodeUrl              = new StringBuffer(150);
     treeUrl                = "";
     iconMailObj            = (IconMail)templateMap.get("IconMailObject");
     sSubject               = iconMailObj.getSubject();
     // To append // when subject contains single quotes
     String tempSubject     = sSubject;
     String strSub          = "";
     strSub                 = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, tempSubject);
     String tempStr         = "";
     StringBuffer strBuf    = new StringBuffer();
     StringBuffer strBufIE5 = new StringBuffer();
     
     if(sSubject.indexOf("'")>=0)
     {
       StringTokenizer st = new StringTokenizer(sSubject,"'",true);
        while (st.hasMoreTokens())
        {
            tempStr = st.nextToken();
            if(tempStr.indexOf("'")>=0){
                strBuf.append("\\").append(tempStr);
            }else {
                strBufIE5.append(tempStr);
                strBuf.append(tempStr);
            }
            tempSubject = strBuf.toString();
        }
    }
    //XSSOK
    
    String strObjectNameEncoded = sSubject;  // XSSUtil.encodeForURL(context, sSubject);
    
      sMailId   = String.valueOf(iconMailObj.getNumber());
      sFrom     = iconMailObj.getFrom();
      sFrom = PersonUtil.getFullName(context,sFrom);
      sDate     = iconMailObj.getDate();

      // Filter out mails as per entered filter criteria.
      if (patternSubject.match(sSubject)) {
        if (sRowColor.equals("odd")) {
          sRowColor = "even";
        } else {
          sRowColor = "odd";
        }

        Activity activityObj = null;
        String sActivityName= "";
        String sActivityId = "";
        // Check for the Task Mail
        if (iconMailObj.isTaskMail()) {
          bMailListed = true;
          // Check for the objects
%>
          <!-- //XSSOK -->
          <tr class="<%=sRowColor%>" >
          <%if(sPrinterFriendly==null){%>
             <td style="text-align:center"><input type="checkbox" name="chkbxMailId" value="<%=XSSUtil.encodeForHTMLAttribute(context, sMailId)%>" onClick="this.checked=this.defaultChecked" /></td>
          <%}else{%>
              <td width="5%" style="text-align:center">&nbsp;</td>
          <%}%>

            <td style="text-align:center"><img src="images/compiconTaskMail.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTTaskMail</emxUtil:i18n>" /></td>
<%
          iconMailObj.open(context, new Visuals());
          BusinessObjectList boActListObj = iconMailObj.getObjects();
          iconMailObj.close(context);
          BusinessObjectItr boActItrObj   = new BusinessObjectItr(boActListObj);
          BusinessObject boActivity       = null;

          // Itrate thru the list and create the Activity Object.
          boActItrObj.next();
          boActivity        = boActItrObj.obj();
          Activity actObj   = new Activity(boActivity);
          actObj.open(context);
          boolean bHasAttachments = actObj.hasAttachments();
          actObj.close(context);
          boolean bTempFalse = false;

          encodeUrl.append("emxTree.jsp?treeMenu=Icon Mail&treeLabel=");
          encodeUrl.append(strObjectNameEncoded);
          encodeUrl.append("&objectName=");
          encodeUrl.append(XSSUtil.encodeForURL(tempSubject));
          encodeUrl.append("&AppendParameters=True&objId=");
          encodeUrl.append(sMailId);
          encodeUrl.append("&treeNodeKey=node.Mail&suiteKey=");
          encodeUrl.append(suiteKey);
          encodeUrl.append("&objectUrl=emxCompMailDetailsFS.jsp?objId=");
          encodeUrl.append(sMailId);
          
          if (("".equals(jsTreeID)) || (jsTreeID == null)){
            target  = " target=\"_parent\"";
          } else{
            target  = "";
          }
           treeUrl = UINavigatorUtil.encodeURL(encodeUrl.toString());
         //if ( request.getHeader("User-Agent").indexOf("MSIE") != -1 )  //This is IE
           treeUrl = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(treeUrl);
          treeUrl = "../common/" + treeUrl;

          popTreeUrl = "javascript:showModalDialog(" + treeUrl + ",760,600)";

           if(bTempFalse) {
%>

            <td>
            <%if (sPrinterFriendly==null){%>
            <!-- //XSSOK -->
				<a href="<%=treeUrl%>" class="object" <%=target%>>
	            	<%=XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;
	            </a>
            <%}else{%>
            <%=XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;
            <%}%>
            </td>

<%

           }
%>
            <td>
            <%=XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;
            </td>

<%
          if(bShowAttachCol) {
            if (bHasAttachments) {
%>
              <td style="text-align:center"><img src="images/iconAttachment.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTAttachedObject</emxUtil:i18n>" /></td>
<%
            } else {
%>
              <td>&nbsp;</td>
<%
            }
          }
%>
            <td><%=XSSUtil.encodeForHTML(context, sFrom)%>&nbsp;</td>

            <!-- //XSSOK -->
            <td><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getAttribute("timeZone"))%>' format='<%=DateFrm %>' ><%=sDate %></emxUtil:lzDate>&nbsp;</td>
            <td style="text-align:center">
             <%if (sPrinterFriendly==null){%>
            <!-- //XSSOK -->
            <a href="javascript:windowPopup('<%=treeUrl%>')" class="object" ><img  border="0" src="images/iconNewWindow.gif" /></a>
            <%}%>
            </td>
          </tr>
<%
        } else if ((bShowUnreadMails) && (iconMailObj.isNew() || iconMailObj.isUnRead())) {  // Check the mail's status for unread mails

          //isNew() method is used to check for both Unread & New mails
          //A New Mail is treated like an Unread Mail
          bMailListed = true;

          //encodeUrl ="emxTree.jsp?treeMenu=Icon Mail&treeLabel="+strSub+"&objectName="+tempSubject+"&AppendParameters=True&objId="+sMailId+"&treeNodeKey=node.Mail&suiteKey="+suiteKey+"&objectUrl=emxCompMailDetailsFS.jsp?objId="+sMailId ;
          encodeUrl.append("emxTree.jsp?treeMenu=Icon Mail&treeLabel=");
          encodeUrl.append(strObjectNameEncoded);
          encodeUrl.append("&objectName=");
          encodeUrl.append(XSSUtil.encodeForURL(tempSubject));
          encodeUrl.append("&AppendParameters=True&objId=");
          encodeUrl.append(sMailId);
          encodeUrl.append("&treeNodeKey=node.Mail&suiteKey=");
          encodeUrl.append(suiteKey);
          encodeUrl.append("&objectUrl=emxCompMailDetailsFS.jsp?objId=");
          encodeUrl.append(sMailId);
          

          if (("".equals(jsTreeID)) || (jsTreeID == null)){
            target  = " target=\"_parent\"";
          } else{
            target  = "";
          }
          treeUrl = UINavigatorUtil.encodeURL(encodeUrl.toString());
         //if ( request.getHeader("User-Agent").indexOf("MSIE") != -1 )  //This is IE
           treeUrl = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(treeUrl);
          treeUrl = "../common/" + treeUrl;
          popTreeUrl = "javascript:showModalDialog('" + treeUrl + "',760,600)";
%>
          <!-- //XSSOK -->
          <tr class="<%=sRowColor%>" >
          <%if(sPrinterFriendly==null){%>
              <td style="text-align:center"><input type="checkbox" name="chkbxMailId" value="<%=XSSUtil.encodeForHTMLAttribute(context, sMailId)%>" /></td>
          <%}else{%>
              <td width="5%" style="text-align:center">&nbsp;</td>
          <%}%>

            <td style="text-align:center"><img src="images/iconUnReadMail.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTUnReadMessage</emxUtil:i18n>" /></td>

            <td>
            <%if (sPrinterFriendly==null){%>
              <!-- //XSSOK -->
			  <a href='javascript:windowPopup("<%=treeUrl%>")' class="object">
              <%=XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;
              </a>
            <%}else{%>
            <%=XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;
            <%}%>
          </td>
<%
          if(bShowAttachCol) {

            if (iconMailObj.hasObjects()) {
%>
              <td style="text-align:center"><img src="images/iconAttachment.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTAttachedObject</emxUtil:i18n>" /></td>
<%
            } else {
%>
              <td>&nbsp;</td>
<%
            }
         }
%>


            <td><%=XSSUtil.encodeForHTML(context, sFrom)%>&nbsp;</td>
            <!-- //XSSOK -->
            <td><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getAttribute("timeZone"))%>' format='<%=DateFrm %>' ><%=sDate %></emxUtil:lzDate>&nbsp;</td>
            <td style="text-align:center">
                         <%if (sPrinterFriendly==null){%>
            <!-- //XSSOK -->
            <a href='javascript:windowPopup("<%=treeUrl%>")' class="object" ><img  border="0" src="images/iconNewWindow.gif" /></a>
            <%}%>
            <!-- //XSSOK -->
			<%--<a href="<%=popTreeUrl%>" class="object" ><img  border="0" src="images/iconNewWindow.gif" /></a>--%>
            </td>
          </tr>
<%
        // Check the mail's status for read mails.
        } else if ((bShowReadMails) && (iconMailObj.isRead())) {

          bMailListed = true;
          //encodeUrl ="emxTree.jsp?treeMenu=Icon Mail&treeLabel="+strSub+"&objectName="+tempSubject+"&AppendParameters=True&objId="+sMailId+"&treeNodeKey=node.Mail&suiteKey="+suiteKey+"&objectUrl=emxCompMailDetailsFS.jsp?objId="+sMailId ;
          encodeUrl.append("emxTree.jsp?treeMenu=Icon Mail&treeLabel=");
          encodeUrl.append(strObjectNameEncoded);
          encodeUrl.append("&objectName=");
          encodeUrl.append(XSSUtil.encodeForURL(tempSubject));
          encodeUrl.append("&AppendParameters=True&objId=");
          encodeUrl.append(sMailId);
          encodeUrl.append("&treeNodeKey=node.Mail&suiteKey=");
          encodeUrl.append(suiteKey);
          encodeUrl.append("&objectUrl=emxCompMailDetailsFS.jsp?objId=");
          encodeUrl.append(sMailId);
          if (("".equals(jsTreeID)) || (jsTreeID == null)){
            target  = " target=\"_parent\"";
          } else{
            target  = "";
          }

         treeUrl = UINavigatorUtil.encodeURL(encodeUrl.toString());
         //if ( request.getHeader("User-Agent").indexOf("MSIE") != -1 )  //This is IE
           treeUrl = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(treeUrl);


          treeUrl = "../common/" + treeUrl;
          popTreeUrl = "javascript:showModalDialog('" + treeUrl + "',760,600)";
%>
          <!-- //XSSOK -->
          <tr class="<%=sRowColor%>">
          <%if(sPrinterFriendly==null){%>
              <td style="text-align:center"><input type="checkbox" name="chkbxMailId" value="<%=XSSUtil.encodeForHTMLAttribute(context, sMailId)%>" /></td>
          <%}else{%>
              <td width="5%" style="text-align:center">&nbsp;</td>
          <%}%>

            <td style="text-align:center"><img src="images/iconReadMail.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTReadMessage</emxUtil:i18n>" /></td>
            <td>
            <%if (sPrinterFriendly==null){%>
              <!-- //XSSOK -->
			  <a href='javascript:windowPopup("<%=treeUrl%>")' class="object">
              <%=XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;
              </a>
            <%}else{%>
            <%=XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;
            <%}%>

            </td>
<%
          if(bShowAttachCol) {
            if (iconMailObj.hasObjects()) {
%>
              <td style="text-align:center"><img src="images/iconAttachment.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.TTAttachedObject</emxUtil:i18n>" /></td>
<%
            } else {
%>
              <td>&nbsp;</td>
<%
            }
          }
%>

            <td><%=XSSUtil.encodeForHTML(context, sFrom)%>&nbsp;</td>
            <!-- //XSSOK -->
            <td><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getAttribute("timeZone"))%>' format='<%=DateFrm %>' ><%=sDate %></emxUtil:lzDate>&nbsp;</td>
            <td style="text-align:center">
            <%if (sPrinterFriendly==null){%>
            <!-- //XSSOK -->
            <a href='javascript:windowPopup("<%=treeUrl%>")' class="object" ><img  border="0" src="images/iconNewWindow.gif" /></a>
            <%}%>
            <!-- //XSSOK -->
            <%--<a href="<%=popTreeUrl%>" class="object" ><img  border="0" src="images/iconNewWindow.gif" /></a>--%>
            </td>
          </tr>
<%

        }
      }
    //}
  %>
    </framework:mapListItr>

  <%
  }
  if (!bMailListed) {
%>
    <!-- //XSSOK -->
    <tr class="<%=sRowColor%>" >
<%
   if(bShowAttachCol) {
%>
      <td colspan="7" align="center" class="errorMessage">
<%
   } else {
%>
      <td colspan="7" align="center" class="errorMessage">
<%
 }
%>
        <emxUtil:i18n localize="i18nId">emxFramework.IconMail.Read.Msg1</emxUtil:i18n>
      </td>
    </tr>
<%
  }
%>
  </table>
</form>
</body>
</html>
