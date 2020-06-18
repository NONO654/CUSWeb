<%--  emxCompMailDetails.jsp   -  Display the Details of the mail to be read
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCompMailDetails.jsp.rca 1.31 Wed Oct 22 15:48:14 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@ include file="../emxUICommonAppInclude.inc" %>
<%@include file = "emxCompCommonUtilAppInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxTreeUtilInclude.inc"%>
<jsp:useBean id="emxMenuObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>



<%
  String languageStr            = request.getHeader("Accept-Language");
  String sMailId                = emxGetParameter(request, "objId");
  String CanSend                = (String)session.getAttribute("canIconMailSendMail");
  String sBrowser               = request.getHeader("USER-AGENT");
  String sBrowserType           = "netscape";
  String convertTNR             = "";
  boolean convertTypeNameRev    = false;
  String sPrinterFriendly       = emxGetParameter(request, "PrinterFriendly");
  Locale locale                 = new Locale(languageStr);
%>

<!-- content begins here -->
<script language="JavaScript">


  //Submit the page to navigate to next page
  function writeMail(varPageHeading) {
    document.Read.PageHeading.value = varPageHeading;
    callPage("emxCompWriteMailDialog.jsp");
  }

  //Submits to the passed page
  var varTargetPage;
  function callPage(varTargetPage) {
    document.Read.action = varTargetPage;
    document.Read.submit();
  }

  function openMessageURL(URL) {
	if(URL.indexOf("emxNavigator.jsp?")){
		URL = URL.replace("emxNavigator", "emxTree");
	}
	URL = URL + "&isPopup=true";		  
  	getTopWindow().showModalDialog(URL, '800', '650');
  }

  function showEditDialogPopup(pageName) {
    var link= pageName;
    emxShowModalDialog('emxCompWriteMailDialogFS.jsp?mailId=<%=XSSUtil.encodeForURL(context, sMailId)%>&pageName='+link,575,575);

  }

  function reloadparent()
  {
    var pageContentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "pagecontent");
    pageContentFrame.reloadparent();
    //parent.parent.parent.getWindowOpener().reloadparent();
  }

  function deleteMail() {
  if(confirm("<emxUtil:i18nScript localize='i18nId'>emxFramework.IconMail.Common.DeleteMsg</emxUtil:i18nScript>")) {
    document.Read.action = 'emxCompDeleteMail.jsp?mailId='+<%=XSSUtil.encodeForURL(context, sMailId)%>;
    document.Read.submit();
   }
  }

</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
   if(EnoviaBrowserUtility.is(request,Browsers.IE)) {
    sBrowserType = "ie";
  }

  if (sMailId == null) {
    sMailId = "";
  }
String sTreeMenuName="";
String ObjectBusId="";
  //Check mail id for null
  if (!(sMailId.equals(""))){
   try {
      IconMail iconMailMessageObj   = null;
      boolean bDisplayed            = false;
      String sColor                 = "even";
      String sObjectStatus          = "";
      //Get the IconMail object for the passed Icon mail number
      IconMailItr iconMailItrGeneric = new IconMailItr(IconMail.getMail(context));
      while (iconMailItrGeneric.next()) {
        String sMailNo = new Long(iconMailItrGeneric.obj().getNumber()).toString();
        String sMailNo1 = FrameworkUtil.findAndReplace(sMailNo,"-","");
        if (sMailNo.equals(sMailId) || sMailNo1.equals(sMailId)) {
          iconMailMessageObj = iconMailItrGeneric.obj();
          break;
        }
      }

     String Baseurl     = Framework.getFullClientSideURL(request,response,"")+"/";
     String sStartPage  = UINavigatorUtil.getDirectoryProperty(context, "eServiceSuiteFramework.ApplicationStartPage");
     String sCommonPage = UINavigatorUtil.getDirectoryProperty(context, "eServiceSuiteFramework.CommonDirectory");
     String rootPah     = Framework.getPagePathURL("");

     if(sStartPage==null || sStartPage.equals(""))
      sStartPage="emxNavigator.jsp";
     if(sCommonPage==null || sCommonPage.equals(""))
      sCommonPage="common";
     if(rootPah==null || rootPah.equals(""))
      rootPah="/ematrix/";


     int PositionOfURI      = Baseurl.indexOf(rootPah);
     String thebaseCurrent  = Baseurl.substring(0,PositionOfURI);


      //Get the message details
      if (iconMailMessageObj != null ) {
        iconMailMessageObj.open(context, null);
        String sSubject     = iconMailMessageObj.getSubject();
        String sMailMessage = iconMailMessageObj.getMessage();
        String sDate        = iconMailMessageObj.getDate();
        String sFrom        = iconMailMessageObj.getFrom();
        String sDisplayFrom = PersonUtil.getFullName(context,sFrom);

        String strSpace     = " ";
        String sextra       = "";
        sMailMessage+=strSpace;
        StringBuffer stringMailMessage  = new StringBuffer(150);
        String sMailMessageLine         = "";
        StringBuffer NewMailString      = new StringBuffer(150);
        StringTokenizer stFirst         = new StringTokenizer(sMailMessage, "\n");
        
        while(stFirst.hasMoreTokens())
         {
            sMailMessageLine=stFirst.nextToken().trim();
            
           if(((sMailMessageLine.indexOf("http://") >= 0) || (sMailMessageLine.indexOf("https://") >= 0))&&
            ((sMailMessageLine.indexOf("emxNavigator.jsp") >=0) || (sMailMessageLine.indexOf("emxTree.jsp") >=0)) &&
            (sMailMessageLine.indexOf("objectId") >=0 ) ) {
            StringTokenizer st = new StringTokenizer(sMailMessageLine, " ");
             

            while(st.hasMoreTokens())
             {
               boolean bSpecialChar=false;
               String stValue=st.nextToken().trim();
               String stValueLC=stValue.toLowerCase();
               String newReplaceString="";
               String strLastChar="";
               if((stValueLC.indexOf("http://") >= 0) || (stValueLC.indexOf("https://") >= 0)) {

                //check to see if there are characters preceeding the http://
                //this would happen if user types url:http://, we strip the url: from the item
                int pos;
                if(stValueLC.indexOf("https://") >= 0)
                 pos=stValue.indexOf("https://");
                else
                 pos=stValue.indexOf("http://");

                if(pos==0)
                 sextra="";
                else
                 sextra=stValue.substring(0,pos);

                 stValue=stValue.substring(pos,stValue.length());
                 int intLength=stValue.length();
                 strLastChar=stValue.substring(intLength-1,intLength);
                      //IF THE LAST CHARACTER OF THE URL IS ,;:-. WHich is common to email writing
                      //then contruct the href without them, then append in the
                      //URL TEXT Only
                   if(strLastChar.equals(",") || strLastChar.equals(";") || strLastChar.equals("-") || strLastChar.equals(":") || strLastChar.equals(".") || strLastChar.equals("~") || strLastChar.equals("?"))
                    {
                     String newstValue = stValue.substring(0,stValue.length()-1);
                     stValue = newstValue;
                     bSpecialChar = true;
                    }
                  String strfullString = stValue.substring(0,stValue.length());

                  //GET THE PROTOCOL AND REMOVE IT AND GET THE REST OF THE STRING
                  String restOfWholeURL = "";
                  StringBuffer protoServer = new StringBuffer(100);
                  StringTokenizer wholeURL = new StringTokenizer(strfullString, "/", true);
                    for (int i=0; i<4 ;i++)
                        {
                           protoServer.append(wholeURL.nextToken());
                        }
                    String dirPath = Framework.getPagePathURL("");
                    String installDir="";

                    if(dirPath==null || dirPath.equals("") || dirPath.equals("null"))
                     dirPath="/ematrix/";


                    if (dirPath.startsWith("/")) {
                 installDir =  dirPath;
               }
             else {
                   installDir ="/"+ dirPath;
              }

            if (installDir.endsWith("/") == false) {
              installDir = installDir + "/";
              }

      int sspos=strfullString.indexOf(protoServer.toString());
                  restOfWholeURL=strfullString.substring(protoServer.toString().length(),strfullString.length());
                  int pathPos=restOfWholeURL.indexOf(installDir);
				  	
				  String restOfFinalUrl="";
				  
				  if(pathPos == -1){
					  restOfWholeURL=strfullString.substring(protoServer.toString().length()+1,strfullString.length()); 
					  int newstring = restOfWholeURL.indexOf("/");
					  restOfFinalUrl=restOfWholeURL.substring(newstring+1,restOfWholeURL.length());
				  }else{
					  restOfFinalUrl=restOfWholeURL.substring(pathPos + installDir.length(),restOfWholeURL.length());
				  }
				  
                  //get the protocol and replace with the current setup
                  strfullString=thebaseCurrent+installDir+restOfFinalUrl;
                  

                  //Need to get the objectid to get the type,name,rev of the object to display to the user
                  if(strfullString.indexOf("objectId")>0){
                    int objIdIndex=strfullString.indexOf("objectId");
                    String sQString=strfullString.substring(objIdIndex,strfullString.length());
                    if(sQString.indexOf("&")>=0){
                      sQString=sQString.substring(0,sQString.indexOf("&"));
                    }

                    if(sQString.indexOf("=")>=0) {
                      ObjectBusId=sQString.substring(sQString.indexOf("=")+1,sQString.length());
                    }
                    //If business Object is valid, try to get the name, type and revision
                    if(!ObjectBusId.equals(""))
                    {
                  BusinessObject busObj=new BusinessObject(ObjectBusId);
                  try
                     {
                        busObj.open(context);
                        String sBusName     = busObj.getName();
                        String sBusType     = busObj.getTypeName();
                        String sBusRev      = busObj.getRevision();
                        busObj.close(context);
                        convertTypeNameRev  = true;
                        String prefLang = PersonUtil.getLanguage(context);
                        sBusType = UINavigatorUtil.getAdminI18NString("Type", sBusType, prefLang);
                        convertTNR          = sBusType+" "+sBusName+" "+ sBusRev;
                     }catch(Exception e){
                        convertTypeNameRev=false;
                     }
                     }

                  }

                  String sTreeMenuString = "";

                  if(strfullString.indexOf("treeMenu")>0){
                    int objTreeMenuIndex=strfullString.indexOf("treeMenu");
                    sTreeMenuString=strfullString.substring(objTreeMenuIndex,strfullString.length());

                    if(sTreeMenuString.indexOf("&")>=0){
                      sTreeMenuString=sTreeMenuString.substring(0,sTreeMenuString.indexOf("&"));
                    }

                    if(sTreeMenuString.indexOf("=")>=0) {
                      sTreeMenuName=sTreeMenuString.substring(sTreeMenuString.indexOf("=")+1,sTreeMenuString.length());
                    }

                  }

                  //301244
                  //Should not do this work if sTreeMenuName is not aivalable
                  if(sTreeMenuName != null && sTreeMenuName.length() > 0)
                  {

                      String menuName=sTreeMenuName;
                      boolean useTypeNameRev=false;
                      String objectId=ObjectBusId;
                      String sMessageSelectFinal="";
                      String sMessageSel="";
                      boolean useDefault=true;

                      String sMessageSelect="";

                  try
                  {
                      HashMap menuinfo = new HashMap();
                      menuinfo = emxMenuObject.getMenu(context, menuName);
                      HashMap allSettings = emxMenuObject.getSettings(menuinfo);
                      HashMap treeMenuMap;
                         sMessageSelect=(String) allSettings.get("Message URL Label");
                         String sRegisteredSuite=(String) allSettings.get("Registered Suite");
                         if(sMessageSelect != null && sMessageSelect.trim().length() > 0)
                           useDefault=false;
                         if(useDefault)
                         {
                           String mappedTreeName = UITreeUtil.getTreeMenuName(application, session, context, objectId, sRegisteredSuite);
                           if( mappedTreeName != null && mappedTreeName.trim().length() > 0 )
                              {
                                  treeMenuMap = emxMenuObject.getMenu(context, mappedTreeName);
                                   if (treeMenuMap != null && emxMenuObject.isMenu(treeMenuMap));
                                   {
                                       allSettings = emxMenuObject.getSettings(treeMenuMap);
                                       sMessageSelect=(String) allSettings.get("Message URL Label");
                                       sRegisteredSuite=(String) allSettings.get("Registered Suite");
                                   }
                              }
                          }


                           if(sMessageSelect !=null && sMessageSelect.trim().length() > 0 )
                           {
                                useTypeNameRev=true;
                                String sRegisteredDir = "";
                                String stringResFileId = "";
                                if ( (sRegisteredSuite != null) && (sRegisteredSuite.trim().length() > 0 ) )
                                {
                                   sRegisteredDir = UINavigatorUtil.getRegisteredDirectory(context, sRegisteredSuite);
                                   stringResFileId = UINavigatorUtil.getStringResourceFileId(context, sRegisteredSuite);
                                }
                                if(sMessageSelect.indexOf("$<")>=0)
                                    sMessageSelectFinal=UIExpression.substituteValues(context, sMessageSelect, objectId);
                                else{
                                     sMessageSelectFinal = EnoviaResourceBundle.getProperty(context, stringResFileId, locale, sMessageSelect);
                                     if(sMessageSelectFinal.indexOf("$<")>=0)
                                         sMessageSelectFinal=UIExpression.substituteValues(context, sMessageSelectFinal, objectId);

                                    }
                           }

                  }catch(Exception e){
                  }

                   if(useTypeNameRev){
                     convertTNR=sMessageSelectFinal;
                   }
              }

                  StringBuffer sStartHref = new StringBuffer(100);
                  sStartHref.append(XSSUtil.encodeForHTML(context, sextra));
                  sStartHref.append("<a href=\"javascript:openMessageURL(\'");
                  sStartHref.append(XSSUtil.encodeForJavaScript(context, strfullString));
                  sStartHref.append("&mode=Tree\')\">");

                  String sEndHref = "</a>";
                  StringBuffer fReplacement = new StringBuffer(150);

                  if(convertTypeNameRev){
                     fReplacement.append(sStartHref.toString());
                     fReplacement.append(XSSUtil.encodeForHTML(context, convertTNR));

                  }else{
                     fReplacement.append(sStartHref.toString());
                     fReplacement.append(XSSUtil.encodeForHTML(context, strfullString));
                  }

                  if(bSpecialChar){
                    fReplacement.append(XSSUtil.encodeForHTML(context, strLastChar));
                    fReplacement.append(sEndHref);
                    fReplacement.append(strSpace);
                  }else{
                    fReplacement.append(sEndHref);
                    fReplacement.append(strSpace);
                  }
                  NewMailString.append(fReplacement.toString());
               }else{
               stValue += strSpace;
               NewMailString.append(stValue);
             }
           }
         } else if ((sMailMessageLine.indexOf("http://") >= 0) || (sMailMessageLine.indexOf("https://") >= 0)) {

            StringTokenizer st = new StringTokenizer(sMailMessageLine, " ");
            while(st.hasMoreTokens())
            {
                boolean bSpecialChar=false;
                String stValue=st.nextToken().trim();
                String stValueLC=stValue.toLowerCase();
                String newReplaceString="";
                String strLastChar="";
                if((stValueLC.indexOf("http://") >= 0) || (stValueLC.indexOf("https://") >= 0)) {

                 //check to see if there are characters preceeding the http://
                 //this would happen if user types url:http://, we strip the url: from the item
                 int pos;
                 if(stValueLC.indexOf("https://") >= 0)
                  pos=stValue.indexOf("https://");
                 else
                  pos=stValue.indexOf("http://");

                 if(pos==0)
                  sextra="";
                 else
                  sextra=stValue.substring(0,pos);
                  stValue=stValue.substring(pos,stValue.length());
                  int intLength=stValue.length();
                  strLastChar=stValue.substring(intLength-1,intLength);
                       //IF THE LAST CHARACTER OF THE URL IS ,;:-. WHich is common to email writing
                       //then contruct the href without them, then append in the
                       //URL TEXT Only
                    if(strLastChar.equals(",") || strLastChar.equals(";") || strLastChar.equals("-") || strLastChar.equals(":") || strLastChar.equals(".") || strLastChar.equals("~") || strLastChar.equals("?"))
                     {
                      String newstValue = stValue.substring(0,stValue.length()-1);
                      stValue = newstValue;
                      bSpecialChar = true;
                     }
                   String strfullString = stValue.substring(0,stValue.length());

                   NewMailString.append("<a href=\"");
                   NewMailString.append(XSSUtil.encodeForHTML (context, strfullString));
                   NewMailString.append("\" target=\"");
                   NewMailString.append(XSSUtil.encodeForHTMLAttribute(context, strfullString));
                   NewMailString.append("\">");
                   NewMailString.append(XSSUtil.encodeForHTML(context, strfullString));
                   NewMailString.append("</a>");
                   StringBuffer fReplacement = new StringBuffer(50);
                    if(bSpecialChar){
                      fReplacement.append(XSSUtil.encodeForHTML(context, strLastChar));
                      fReplacement.append(strSpace);
                    }else{
                      fReplacement.append(strSpace);
                    }
                   NewMailString.append(fReplacement.toString());
                  }else{
                  stValue += strSpace;
                  NewMailString.append(stValue);
                }
             }
         }else{
          NewMailString = new StringBuffer(100);
          NewMailString.append(XSSUtil.encodeForHTML(context,sMailMessageLine));
         }
   stringMailMessage.append(NewMailString.toString());
   stringMailMessage.append("<br/>");
   //added for fixing issue of iconmail. - begin
   NewMailString = new StringBuffer(100);
   // added for fixing issue of iconmail  -  end
  }
        //Get the 'To' list
        StringList sListTo = iconMailMessageObj.getToList();
        StringBuffer sToList = new StringBuffer(100);
        StringBuffer sDisplayToList = new StringBuffer(100);
        String sElt="";
        if (sListTo.size() != 0) {
          int iIndex = 0;
          for (; iIndex < (sListTo.size() - 1); iIndex++) {
            sElt = (String)sListTo.elementAt(iIndex);
            sToList.append(sElt);
            sElt = PersonUtil.getFullName(context,sElt);
            sDisplayToList.append(sElt);
            sToList.append(";");
            sDisplayToList.append(";");
          }
          if (iIndex >= 0) {
            sElt = (String)sListTo.elementAt(iIndex);
            sToList.append(sElt);
           //Added for the Bug No: 339357 3 25/01/2008 Begin 
            String aliasElt=null;
            String fullPersonElt=PersonUtil.getFullName(context,sElt);
            if(fullPersonElt.equals(sElt))
            {
               aliasElt=i18nNow.getAdminI18NString("Role",sElt,languageStr);
               if(aliasElt.equals(sElt))
               {
                 aliasElt=i18nNow.getAdminI18NString("Group",sElt,languageStr);
               }
               sElt=aliasElt;  
            }
            else
            {
                sElt=fullPersonElt;
            }
               //Added for the Bug No: 339357 3 25/01/2008 End 
            //sElt = PersonUtil.getFullName(context,sElt);
            sDisplayToList.append(sElt);
          }
        }

        //Get the 'Cc' list
        StringList sListCc = iconMailMessageObj.getCcList();
        StringBuffer sCcList = new StringBuffer(100);
        StringBuffer sDisplayCcList = new StringBuffer(100);
        if (sListCc.size() != 0) {
          int iIndex = 0;
          for (; iIndex < (sListCc.size() - 1); iIndex++) {
            sElt = (String)sListCc.elementAt(iIndex);
            sCcList.append(sElt);
            sElt = PersonUtil.getFullName(context,sElt);
            sDisplayCcList.append(sElt);
            sCcList.append(";");
            sDisplayCcList.append(";");
          }
          if (iIndex >= 0) {
            sElt = (String)sListCc.elementAt(iIndex);
            sCcList.append(sElt);
            sElt = PersonUtil.getFullName(context,sElt);
            sDisplayCcList.append(sElt);
          }
        }
%>


    <form name="Read" method="post" onSubmit="return false">
      <input type="hidden" name="txtToAddress"   value="<%=XSSUtil.encodeForHTMLAttribute(context, sToList.toString())%>" />
      <input type="hidden" name="FromAddress" value="<%=XSSUtil.encodeForHTMLAttribute(context, sFrom)%>" />
      <input type="hidden" name="txtCcAddress"   value="<%=XSSUtil.encodeForHTMLAttribute(context, sCcList.toString())%>" />
      <input type="hidden" name="txtSubject"     value="<%=XSSUtil.encodeForHTMLAttribute(context, sSubject)%>" />
      <input type="hidden" name="Message"     value="<%=XSSUtil.encodeForHTMLAttribute(context, sMailMessage)%>" />
      <input type="hidden" name="page" value="" />
      <input type="hidden" name="Sent"  value="<%=XSSUtil.encodeForHTMLAttribute(context, sDate)%>" />
      <input type="hidden" name="Currentpage" value="emxCompReadMailDialog.jsp" />

      <table border="0" cellpadding="5" cellspacing="2" width="530">
        <tr>
          <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.From</emxUtil:i18n></td>
          <td class="Field"><%=XSSUtil.encodeForHTML(context, sDisplayFrom)%>&nbsp;</td>
        </tr>

        <tr>
          <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.To</emxUtil:i18n></td>
          <td class="Field"><%=XSSUtil.encodeForHTML(context, sDisplayToList.toString())%>&nbsp;</td>
        </tr>
        <tr>
          <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.CC</emxUtil:i18n></td>
          <td class="Field"><%=XSSUtil.encodeForHTML(context, sDisplayCcList.toString())%>&nbsp;</td>
        </tr>
        <tr>
          <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Subject</emxUtil:i18n></td>
          <td class="Field"><%=XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, sSubject))%>&nbsp;</td>
        </tr>
        <tr>
          <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.Message</emxUtil:i18n></td>
          <!-- //XSSOK -->
          <td class="Field"><%=stringMailMessage.toString()%></td>
        </tr>
        <tr>
          <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Inbox.Received</emxUtil:i18n></td>
          <!-- //XSSOK -->
          <td class="Field"><emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getAttribute("timeZone")%>' format='<%=DateFrm %>' ><%=sDate %></emxUtil:lzDate>&nbsp;</td>
         </tr>
       </table>

       <%if(sPrinterFriendly==null) {%>
       <script language="Javascript">
         reloadparent();
       </script>
       <%}%>
<%
      } else {
        context.shutdown();

%>
        <jsp:forward page ="emxCompInboxDialog.jsp" />
<%
      }
    } catch (MatrixException exception) {
      session.setAttribute("error.message", exception.getMessage() + "");
        context.shutdown();
%>
      <jsp:forward page ="emxCompInboxDialog.jsp" />
<%
    }
  }
%>


<%
 // ------------------------ Page content above here  ---------------------
%>


<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
