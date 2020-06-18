<%--  emxCompWriteMailDialog.jsp   -  This page allows the user to write mails to other users of matrix.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
      static const char RCSID[] = $Id: emxCompWriteMailDialog.jsp.rca 1.22 Wed Oct 22 15:48:46 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@ include file="../emxUICommonAppInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<%@include file = "emxCompCommonUtilAppInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxUIConstantsInclude.inc" %>
<%
  StringBuffer sMessages    = new StringBuffer("");
  String sToAddress         = "";
  String errMsg             = "";
  String sCcAddress         = "";
  String sSubject           = "";
  String sMessage           = "";
  String sMailId            = "";
  String sAttachments       = "";
  String sFromAddress       = "";
  String sPageHeading       = "";
  String sHeader            = "";
  String sFromDetails       = "";
  String sSent              = "";
  String sBusIdList         = "";
  String sRemoved           = "removed";
  String languageStr        = request.getHeader("Accept-Language");
  Locale locale             = new Locale(languageStr);  
  String CanSend            = (String)session.getAttribute("canIconMailSendMail");
  String sBrowserType       = "netscape";

  boolean bNewPage          = false;
  boolean bDisplayed        = false;
  boolean bGetFields        = true;

  Framework.setPropertyValue(session,"backPage","emxCompWriteMailDialog.jsp");
  Framework.setPropertyValue(session,"returnPage","emxCompWriteMailDialog.jsp");
  if(EnoviaBrowserUtility.is(request,Browsers.IE)) {
    sBrowserType = "ie";
  }

  sFromDetails = emxGetParameter(request, "fromDetails");
  sSent        = emxGetParameter(request, "Sent");
  sToAddress   = emxGetParameter(request, "txtToAddress");
  sCcAddress   = emxGetParameter(request, "txtCcAddress");
  sSubject     = emxGetParameter(request, "txtSubject");
  sMessage     = emxGetParameter(request, "Message");
  errMsg       = emxGetParameter(request, "errMsg");
  sMailId      = emxGetParameter(request, "mailId");
  sAttachments = emxGetParameter(request, "attachments");
  sFromAddress = emxGetParameter(request, "FromAddress");
  sPageHeading = emxGetParameter(request, "page");
  sHeader      = emxGetParameter(request, "Header");
  if(sSubject != null) {
  sSubject     = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject);
  }

%>


<!-- content begins here -->
<script language="JavaScript">
  // This Function Checks for the length of the Data that has
  // been entered and trims the leading and trailing spaces.
  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }
  //Function to remove the attachments
  function removeAttachments() {
    var varFlag = false;
    if (document.mailDialog.chkbxRemoveAttachment.length > 1) {
      for (var index=0; index < document.mailDialog.chkbxRemoveAttachment.length; index++) {
        if (document.mailDialog.chkbxRemoveAttachment[index].checked == true) {
          for (var i=0; i < document.mailDialog.busId.length; i++) {
            if (document.mailDialog.busId[i].value == document.mailDialog.chkbxRemoveAttachment[index].value) {
              document.mailDialog.busId[i].value = "removed";
              varFlag = true;
              break;
            }
          }
        }
      }
    } else if(document.mailDialog.chkbxRemoveAttachment.checked == true) {
      document.mailDialog.busId.value = "removed";
      varFlag = true;
    }

    if (varFlag) {
      document.mailDialog.action = "emxCompMailProcess.jsp?page=WriteMail";
      document.mailDialog.submit();
      return;
    } else {
      alert("<emxUtil:i18nScript localize="i18nId" >emxFramework.IconMail.Find.AlertMsg1</emxUtil:i18nScript>");
      return;
    }
  }

  //Validates To & Cc address and submits the page to SendMail
  function submitform() {
    if (trim(document.mailDialog.txtToAddress.value) == "") {
      alert("<emxUtil:i18nScript localize="i18nId" >emxFramework.IconMail.Write.AlertMsg2</emxUtil:i18nScript>");
    }else if (trim(document.mailDialog.txtSubject.value).indexOf(">")>-1 || trim(document.mailDialog.txtSubject.value).indexOf("<") >-1){
      alert("<emxUtil:i18nScript localize="i18nId" >emxFramework.IconMail.Write.AlertSubjectMessage</emxUtil:i18nScript>: < >");

    }else {
      document.mailDialog.txtToAddress.value = trim(document.mailDialog.txtToAddress.value);
      document.mailDialog.txtCcAddress.value = trim(document.mailDialog.txtCcAddress.value);
      document.mailDialog.txtSubject.value = trim(document.mailDialog.txtSubject.value);
      document.mailDialog.action = "emxCompSendMail.jsp";
      var iconMailHiddenFrame = findFrame(getTopWindow(), "iconMailHidden").name;
      document.mailDialog.target= iconMailHiddenFrame; 
      document.mailDialog.submit();
    }
    return;
  }

  //Submits to the passed page
  var varTargetPage;
  function callPage(varTargetPage) {
    document.mailDialog.action = varTargetPage;
    document.mailDialog.submit();
  }

  function closeWindow() {
      parent.window.closeWindow();
      return;
  }

  function selectPeople(val) {
  var toPeople = document.mailDialog.txtToAddress.value;
   var ccPeople = document.mailDialog.txtCcAddress.value;
    emxShowModalDialog('emxCompMailSelectPeopleDialogFS.jsp?mailId=<%=XSSUtil.encodeForURL(context, sMailId)%>&toAddress=<%=XSSUtil.encodeForURL(context, sToAddress)%>&ccAddress=<%=XSSUtil.encodeForURL(context, sCcAddress)%>&toPeople='+toPeople+'&ccPeople='+ccPeople+'&page='+val, 575, 575);
  }

</script>


<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<% StringBuffer busIdList = new StringBuffer(100);
  if(sMailId == null)
  sMailId="";

  if (!(sMailId.equals(""))) {

    try {

      IconMail iconMailMessageObj = null;
      //boolean bDisplayed      = false;
      String sColor           = "even";
      String sObjectStatus    = "";

      //Get the IconMail object for the passed Icon mail number
      IconMailItr iconMailItrGeneric = new IconMailItr(IconMail.getMail(context));
      while (iconMailItrGeneric.next()) {
        long lMailNo = iconMailItrGeneric.obj().getNumber();
        if (lMailNo == Long.parseLong(sMailId)) {
          iconMailMessageObj = iconMailItrGeneric.obj();
          break;
        }
      }


      //Get the message details
      if (iconMailMessageObj != null ) {
        iconMailMessageObj.open(context, null);

        sSubject        = iconMailMessageObj.getSubject();
        sSubject        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject); 
        sMessage        = iconMailMessageObj.getMessage();
        sSent           = iconMailMessageObj.getDate();
        sFromAddress    = iconMailMessageObj.getFrom();

        //*********************Get BusinessObject List

    BusinessObjectList boListMailObjects    = iconMailMessageObj.getObjects();
    BusinessObjectItr boTempItrMailObjects  = new BusinessObjectItr(boListMailObjects);
    BusinessObject boProj                   = new BusinessObject();

    int busCount=0;
    //Check the no of objects attached
    if (boListMailObjects.size()>0) {
      while (boTempItrMailObjects.next()) {
        boProj = boTempItrMailObjects.obj();
        boProj.open(context);
        String sBusItemId = boProj.getObjectId();
        boProj.close(context);

        if(busCount==0)
            busIdList.append(sBusItemId);
        else {
            busIdList.append(",");
            busIdList.append(sBusItemId);
        }
        busCount++;
      }

     }

        //********************End of Get BusinessObject List



        //Get the 'To' list
        StringList sListTo = iconMailMessageObj.getToList();
        StringBuffer sToList = new StringBuffer(100);
        if (sListTo.size() != 0) {
          int iIndex = 0;
          for (; iIndex < (sListTo.size() - 1); iIndex++) {
            sToList.append(sListTo.elementAt(iIndex));
            sToList.append(";");
          }
          if (iIndex >= 0) {
            sToList.append(sListTo.elementAt(iIndex));
          }
        }
        sToAddress =sToList.toString();

        //Get the 'Cc' list
        StringList sListCc = iconMailMessageObj.getCcList();
        StringBuffer sCcList = new StringBuffer(100);
        if (sListCc.size() != 0) {
          int iIndex = 0;
          for (; iIndex < (sListCc.size() - 1); iIndex++) {
            sCcList.append(sListCc.elementAt(iIndex));
            sCcList.append(";");
          }
          if (iIndex >= 0) {
            sCcList.append(sListCc.elementAt(iIndex));
          }
        }

        sCcAddress = sCcList.toString();
        String mlerror = (String)request.getAttribute("mailerror");
        if (mlerror != null && Boolean.parseBoolean(mlerror.toString())) {
          bGetFields = false;
        }

       } else {
               //session.putValue("error.message", FrameworkUtil.i18nStringNow("emxFramework.IconMail.Read.Msg2",languageStr) +  sMailId + " message");
             }
    } catch (MatrixException exception) {
       session.setAttribute("error.message", exception.getMessage() + "");
    }
  }


  if ((sPageHeading != null) && !(sPageHeading.equals("New"))) {
    //Displays the message header of the original message
    sMessages = new StringBuffer(" \n");

    sMessages.append(" ----------");
    sMessages.append(EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.OriginalMessage", new Locale(languageStr)));    
    sMessages.append(" ---------" + "\n"+""+EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Common.FromColon", new Locale(languageStr)));    
    sMessages.append("    " + sFromAddress + "\n" +"");
    sMessages.append(EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Common.SentOn", new Locale(languageStr)));    
    sMessages.append(" " + sSent + "\n");

    if ((sToAddress != null) && !(sToAddress.equals(""))) {
       sMessages.append(""+EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Common.ToColon", new Locale(languageStr)));       
       sMessages.append("      " + sToAddress + "\n");
    }
    if ((sCcAddress != null) && !(sCcAddress.equals(""))) {
        sMessages.append(""+EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Common.CCColon", new Locale(languageStr)));        
        sMessages.append("      " + sCcAddress + "\n");
    }
    sMessages.append(EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Common.SubjectColon", new Locale(languageStr)));    
    sMessages.append(sSubject + "\n"+"\n"+sMessage);
  }

  if ((sPageHeading != null ) && (sPageHeading.equals("New"))) {
    bNewPage   = true;
    sHeader    = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.IconMailNew", new Locale(languageStr));    
    sMailId    = "";

  } else if ((sPageHeading != null ) && (sPageHeading.equals("Reply"))  && (bGetFields)) {
    sToAddress = sFromAddress;
    sSubject   = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.Re", new Locale(languageStr)) + sSubject;    
    bNewPage   = false;
    sCcAddress = "";
    sHeader    = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.IconMailReply", new Locale(languageStr));  

  } else if ((sPageHeading != null ) &&(sPageHeading.equals("ReplyAll")) && (bGetFields)) {

    StringTokenizer sTokToAdd   = new StringTokenizer(sToAddress, ";");
    sToAddress                  = sFromAddress;
    String sNextToken           = null;
    String sContextUser         = context.getUser();
    
    while (sTokToAdd.hasMoreElements()) {
      sNextToken = sTokToAdd.nextToken();
      if (!(sNextToken.equals(sContextUser))) {
        sToAddress += ";" + sNextToken ;
      }
    }
    if (sCcAddress == null) {
      sCcAddress = "";
    }
    sSubject = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.Re", new Locale(languageStr)) + sSubject;    
    sHeader  = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.IconMailReplyAll", new Locale(languageStr));    
    bNewPage = false;

  } else if((sPageHeading != null ) && (sPageHeading.equals("Forward")) && (bGetFields) ) {

    sSubject    = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.Fw", new Locale(languageStr)) + sSubject;    
    sToAddress  = "";
    sCcAddress  = "";
    bNewPage    = false;
    sHeader     = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Write.IconMailForward", new Locale(languageStr));
  }

if(sToAddress == null || sToAddress.equalsIgnoreCase("null") || sToAddress.equals(""))
    sToAddress="";
if(sCcAddress == null || sCcAddress.equalsIgnoreCase("null") || sCcAddress.equals(""))
    sCcAddress="";
if(sSubject == null || sSubject.equalsIgnoreCase("null") || sSubject.equals(""))
    sSubject="";


%>
  <form name="mailDialog" method="post" onSubmit="submitform(); return false">
  <input type="hidden" name="mailId" value="<xss:encodeForHTMLAttribute><%=sMailId%></xss:encodeForHTMLAttribute>" />
    <!-- //XSSOK -->
    <input type="hidden" name="busId" value="<%=busIdList.toString()%>" />
     <table border="0" cellpadding="5" cellspacing="2" width="530">
      <tr>
          <td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.To</emxUtil:i18n></label></td>
          <td class="Field"><input type="Text" name="txtToAddress" value="<xss:encodeForHTMLAttribute><%=sToAddress%></xss:encodeForHTMLAttribute>" size="40" /><input type="button" value="..." name="btn" id="btn" onclick="javascript:selectPeople('To')" />&nbsp;<a  href="#" onclick="document.mailDialog.txtToAddress.value=''"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Clear</emxUtil:i18n></a></td>
      </tr>
      <tr>
          <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.CC</emxUtil:i18n></label></td>
          <td class="Field"><input type="Text" name="txtCcAddress" value="<xss:encodeForHTMLAttribute><%=sCcAddress%></xss:encodeForHTMLAttribute>" size="40" /><input type="button" value="..." name="btn" id="btn" onclick="javascript:selectPeople('CC')" />&nbsp;<a  href="#" onclick="document.mailDialog.txtCcAddress.value=''"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Clear</emxUtil:i18n></a></label></td>
      </tr>
      <tr>
        <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId" >emxFramework.IconMail.Common.Subject</emxUtil:i18n></label></td>
        <td class="Field"><input type="Text" name="txtSubject" value="<xss:encodeForHTMLAttribute><%=sSubject%></xss:encodeForHTMLAttribute>" size="40" maxlength="200" /></td>
      </tr>
     <%if (errMsg!=null && errMsg.equalsIgnoreCase("true") && sMailId!=null && sMailId.trim().length()==0){%>
      <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId" >emxFramework.IconMail.Inbox.Message</emxUtil:i18n></label></td>
        <td class="Field"><textarea name="Message" cols="45" rows="15" wrap><xss:encodeForHTMLAttribute><%=sMessage%></xss:encodeForHTMLAttribute></textarea></td>
      </tr>
      <%}else{%>
      <tr>
      <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId" >emxFramework.IconMail.Inbox.Message</emxUtil:i18n></label></td>
        <td class="Field"><textarea name="Message" cols="45" rows="15" wrap><xss:encodeForHTMLAttribute><%=sMessages%></xss:encodeForHTMLAttribute></textarea></td>
      </tr>
      <%}%>
    </table>
    </form>
<%
 // ------------------------ Page content above here  ---------------------
%>

<iframe src="emxBlank.jsp" name="iconMailHidden" id="iconMailHidden" height="1" width="1" style="position:absolute; left: -100px;" border="0" frameborder="0"></iframe>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
