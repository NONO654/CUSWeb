<%--  emxCommonDocumentCreateDialog.jsp
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description : Document Create Wizard, Step 1

    static const char RCSID[] = "$Id: emxCommonDocumentConversionDialog.jsp.rca 1.10.1.3.2.5 Wed Oct 22 16:18:05 2008 przemek Experimental przemek $";
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  // This is added because adding emxUICommonHeaderEndInclude.inc add
  request.setAttribute("warn", "false");
  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
  String objectId        = (String) emxCommonDocumentCheckinData.get("objectId");
  DomainObject dom       = new DomainObject(objectId);
  String documentType    = dom.getInfo(context,DomainConstants.SELECT_TYPE);
  String documentPolicy  = dom.getInfo(context,DomainConstants.SELECT_POLICY);
  String objectAction    = (String) emxCommonDocumentCheckinData.get("objectAction");
  String actionURL = (String)emxCommonDocumentCheckinData.get("actionURL");
  if (actionURL == null )
  {
      actionURL = "emxCommonDocumentCheckinDialogFS.jsp";
  }
  String emxFilePathBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFile.PathBadChars");
  String emxFolderPathBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFolder.PathBadChars");
  String emxSelectorBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFileFolder.SelectorBadChars");

%>

<script language="javascript">

  // function to close the window and refresh the parent window.
  function closeWindow()
  {
    window.location.href = "emxCommonDocumentCancelCreateProcess.jsp";
  }

  // function to truncate the blank values.
  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

  function submitForm()
  {
    var j = 0;
    for ( var i = 0; i < document.frmMain.elements.length; i++ ) {
        j = document.frmMain.elements[i].name.length;
        k = j - 6;
        if (document.frmMain.elements[i].type == "hidden" && document.frmMain.elements[i].name.substring(k,j) == "Number"  ){

            j = i;
            j--;
            if ( !isNumeric(document.frmMain.elements[j].value) )
            {
                alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PleaseTypeNumbers</emxUtil:i18nScript>" + document.frmMain.elements[j].name);
                document.frmMain.elements[j].focus();
                return;
            }
        }
        if ((document.frmMain.elements[i].type == "radio") && (document.frmMain.elements[i].name=="vcDocumentTmp") && (document.frmMain.elements[i].checked)){
          if(document.frmMain.elements[i].value == "Folder"){
            var path = document.frmMain.path.value;
            path = path.substring(path.length-1, path.length);
            if (path == ";")
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.FolderPathError</emxUtil:i18nScript>");
                return;
            }
          }
     <%
    if (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER)){
%>
        if(document.frmMain.elements[i].value == "File") {
            var path = document.frmMain.path.value;
            path = path.substring(path.length-1, path.length);
            if (path == "/")
            {
               alert("<emxUtil:i18n localize = "i18nId">emxComponents.CommonDocument.FilePathError</emxUtil:i18n>");
               return;
            }
        }
  <% } %>
  }
<%
    if (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER))
    {
     %>
       var path = document.frmMain.path.value;
       if(path.length <= 0)
       {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.PathEmpty</emxUtil:i18nScript>");
          return;
       }

       if(document.frmMain.elements[i].name== "path"){
         var FILE_CHARS = "<%= emxFilePathBadChars.trim() %>";
         var FOLDER_CHARS = "<%= emxFolderPathBadChars.trim() %>";
         var STR_PATH_BAD_CHARS = "";
         if(document.frmMain.vcDocumentTmp[1].checked){
           STR_PATH_BAD_CHARS = FOLDER_CHARS;
         }
         else{
           STR_PATH_BAD_CHARS = FILE_CHARS;
         }
         var ARR_PATH_BAD_CHARS = "";
         if (STR_PATH_BAD_CHARS != "") 
         {    
          ARR_PATH_BAD_CHARS = STR_PATH_BAD_CHARS.split(" ");
         }
         var strResult = checkFieldForChars(document.frmMain.path,ARR_PATH_BAD_CHARS,false);
         if (strResult.length > 0) {
           var msg = "<%=XSSUtil.encodeForJavaScript(context, i18nNow.getI18nString("emxComponents.Alert.InvalidChars","emxComponentsStringResource",request.getHeader("Accept-Language")))%>";
           msg += STR_PATH_BAD_CHARS;
           msg += "<%=XSSUtil.encodeForJavaScript(context, i18nNow.getI18nString("emxComponents.Alert.RemoveInvalidChars", "emxComponentsStringResource",request.getHeader("Accept-Language")))%> ";
           msg += document.frmMain.path.name;
           alert(msg);
           document.frmMain.path.focus();
           return;
         } 
       }
       if(document.frmMain.elements[i].name== "selector"){
         var selector = document.frmMain.selector.value;
         if(selector.length <= 0)
         {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.SelectorEmpty</emxUtil:i18nScript>");
            return;        
         }
         var STR_SELECTOR_BAD_CHARS = "<%= emxSelectorBadChars.trim() %>";
         var ARR_SELECTOR_BAD_CHARS = "";
         if (STR_SELECTOR_BAD_CHARS != "") 
         {
           ARR_SELECTOR_BAD_CHARS = STR_SELECTOR_BAD_CHARS.split(" ");   
         }
         var strSelectorResult = checkFieldForChars(document.frmMain.selector,ARR_SELECTOR_BAD_CHARS,false);
         if (strSelectorResult.length > 0) {
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.InvalidChars</emxUtil:i18nScript>\n"
                 + STR_SELECTOR_BAD_CHARS + "\n<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>\n"
                 +document.frmMain.selector.name);
          document.frmMain.selector.focus();
          return;
        }
      }
<%          
    }
 %>
    }

    // Make sure user doesnt double clicks on create document
    if (jsDblClick())
    {
      document.frmMain.submit();
      return;
    }
  }
  // this function is called by type chooser, everytime a type is selected
  // this reloads the page, and populates the policy chooser correctly
  function reload() {
      document.frmMain.target="";
      document.frmMain.action="../components/emxCommonDocumentCreateDialog.jsp?reloadPage=true&contentPageIsDialog=true";
      document.frmMain.submit();
  }

  //function  to move the focus from AutoName to Name, when AutoName checkBox is Unchecked.
  function txtNameFocus()
  {
    if(!document.frmMain.AutoName.checked )
    {
      document.frmMain.AutoName.value = "";
      document.frmMain.name.focus();
    }
    else
    {
      autoNameValue();
    }
    return;
  }

  <%
  if ( objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) )
    {
%>
  function onFileFolderSelect(folderObject){
    if(folderObject.value == "Folder"){
       document.frmMain.format.disabled= true;
       document.frmMain.vcDocumentType.value = "Folder";
    }
    else {
       document.frmMain.format.disabled= false;
       document.frmMain.vcDocumentType.value = "File";
    }
  }
<% } %>
  </script>
<form name="frmMain" method="post" action="<%=XSSUtil.encodeForHTML(context, actionURL)%>" target="_parent" onsubmit="submitForm(); return false">
  <table border="0" cellpadding="5" cellspacing="2" width="100%">

<%

  String path = (String)emxCommonDocumentCheckinData.get("path");
  String vcDocumentType = (String)emxCommonDocumentCheckinData.get("vcDocumentType");
  String selector = (String)emxCommonDocumentCheckinData.get("selector");
  String server = (String)emxCommonDocumentCheckinData.get("server");
  String defaultFormat = (String)emxCommonDocumentCheckinData.get("format");
  String showFormat = (String) emxCommonDocumentCheckinData.get("showFormat");
   String suiteKey = (String) emxCommonDocumentCheckinData.get("suiteKey");

  String fromAction = (String)emxCommonDocumentCheckinData.get("fromAction");
  if("previous".equals(fromAction)) {
      showFormat = (String) emxCommonDocumentCheckinData.get("showFormatBkp");
    }else {
      if(showFormat == null){
        showFormat = "true";
      }
     emxCommonDocumentCheckinData.put("showFormatBkp", showFormat);
    }
  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) )
    {
        emxCommonDocumentCheckinData.put("noOfFiles", "1");
        emxCommonDocumentCheckinData.put("isVcDoc", "true");
%>
    <!-- //XSSOK -->
    <jsp:include page="../components/emxCommonDocumentVCInformation.jsp"><jsp:param name="path" value="<%=path%>"/><jsp:param name="vcDocumentType" value="<%=vcDocumentType%>"/><jsp:param name="selector" value="<%=selector%>"/><jsp:param name="server" value="<%=server%>"/><jsp:param name="format" value="<%=defaultFormat%>"/><jsp:param name="showFormat" value="<%=showFormat%>"/><jsp:param name="objectAction" value="<%=objectAction%>"/><jsp:param name="defaultDocumentPolicyName" value="<%=documentPolicy%>"/><jsp:param name="suiteKey" value="<%=suiteKey%>"/></jsp:include>
<%
    }
%>

    <tr>
      <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
      <td width="90%">&nbsp;
              <input type="hidden" name="realType" value="Document" />

    </td>
    </tr>

  </table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
