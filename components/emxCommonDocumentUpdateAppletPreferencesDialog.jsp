

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsAppletInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

  <head>
  
    
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="JavaScript" src="emxMetrics.js"></script>
    <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
    <script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
    <script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
    <script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
    <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
    <script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
    <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
    <link rel="stylesheet" type="text/css" href="../common/styles/emxUIMetricsDialog.css"/>
  
            

    <script type="text/javascript" >
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
      //addStyleSheet("emxUIList");
      
      
      function browseDirectories() {
            getApplet().browseDirectories();
      }

      function closeWindow() {
          window.closeWindow();
          return;
      }

      function jsParseSpChr(argString) {
          
          var parsedString = argString.replace(/[']/g,"\'");
          parsedString = argString.replace(/[\\]/g,"\/");
          return parsedString;
    }
      
          
     


      function activateBrowseButton() {
    	  document.updateAppletPreferences.BrowseBtn.disabled = false;
          
      }

      function deactivateDelAfterCheckInButton() {
    	  document.updateAppletPreferences.deleteFileOnCheckin.checked = false;
          
      }
      function activateDelAfterCheckInButton() {
    	  document.updateAppletPreferences.deleteFileOnCheckin.checked = true;
          
      }
      

      function deactivateBrowseButton() {
    	  document.updateAppletPreferences.BrowseBtn.disabled = true;
      }

      function checkDirectorySelected() {      
          
          var dirValue = getApplet().getDirectory();
          alert("dirValue is : "+ dirValue);
                  
          if (dirValue == ""){
              alert("FALSE");
          }
          
          return true;
      }
      
</script>
 </head>
 <%@page import="com.matrixone.apps.common.Download"%>
 <%
 String language  = request.getHeader("Accept-Language");
 Locale locale   = new Locale(language);
 
 String browseButtonLabel 		= EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.Button.Browse");
 String  checkInLabel   		= EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.UpdateAppletPreferences.CheckinLabel");
 String  fromDefaultLocation 	= EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.UpdateAppletPreferences.FromDefaultLocation");
 String  fromSpecificDirectory 	= EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.UpdateAppletPreferences.FromSpecificDirectory");
 String  deleteFileAfterCheckin	= EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.UpdateAppletPreferences.DeleteFileAfterCheckin");
 boolean checkoutDirectoryEmpty = UIUtil.isNullOrEmpty(Download.processDefaultCheckoutDirectory(context));
 HashMap props = new HashMap();
 props.put("debug", "true");
 String firstLang = language.split(",")[0];
 String appletLang = firstLang.split("-")[0];
 props.put("locale", appletLang);


%> 
<script>
      function submitForm() {
    	  var dirValue = getApplet().getDirectory();
          if (dirValue == "" && document.updateAppletPreferences.BrowseBtn.disabled == false){
        	  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.DirectoryChooserAppletPreferences.SelectFolder</emxUtil:i18nScript>");
          }else{
        	  dirValue = jsParseSpChr(dirValue);
        	  document.getElementById("checkinDirValue").value = dirValue;          
              var objForm = document.updateAppletPreferences;
          	  if("<%=checkoutDirectoryEmpty%>" =="true" && document.updateAppletPreferences.BrowseBtn.disabled){
          		alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.Applet.CheckoutDirectoryEmpty")%>");
          	  }else{
          		  objForm.submit();
          	  }          
          }         
      }
</script>
 <div id="divPageHead">
 
	 <table border="0" cellspacing="0" cellpadding="0" width="100%">
       
        <tr>
                <td class="label" colspan="100%" > 
                <%=XSSUtil.encodeForHTML(context, checkInLabel) %>
                </td>                 
        </tr>
  	</table>        
         
   <form name="updateAppletPreferences" method="post" action="emxCommonDocumentUpdateAppletDialogFS.jsp" >
      <table border="0" cellspacing="0" cellpadding="0" width="100%">
       
       
        
        <tr>
        
        <td class="inputField" colspan="100%">  
            <input type="radio" name="checkinFileFrom" value="default" checked onclick="deactivateBrowseButton();activateDelAfterCheckInButton();" /> <%=XSSUtil.encodeForHTML(context, fromDefaultLocation) %>
            
        </td>
    
      </tr>
      
      <tr>
        
        <td class="inputField" colspan="100%">  
             <input type="radio" name="checkinFileFrom" value="specific" onclick="activateBrowseButton();deactivateDelAfterCheckInButton();" /> <%=XSSUtil.encodeForHTML(context, fromSpecificDirectory) %>
        </td>
    
      </tr>
      
        <tr>
                <td class="inputField" >
                        <%addApplet(request, response, out, context, "com.matrixone.fcs.applet.DirectoryChooserApplet", 450, 20, props); %>                      
                       
                </td>   
                
                  
                 <td class="inputField" >
                        
                        <input type="button" value=<%=XSSUtil.encodeForHTMLAttribute(context, browseButtonLabel)%>  name="BrowseBtn" id="BrowseBtn"" onclick="browseDirectories();" disabled />  
                        <input type="hidden"  name="checkinDirValue" id="checkinDirValue" />                                               
                </td>        
            
        </tr>
        
        <tr>
                 <td class="inputField" colspan="100%">
       
                        <input type="checkbox" name="deleteFileOnCheckin" value="true" onClick="" checked /> <%=XSSUtil.encodeForHTML(context, deleteFileAfterCheckin) %>     

                </td>
        </tr>      
            
               
      </table>
    </form>
    
  </div> 
  
  <div id="divPageFoot">
  
  <form name="footerForm" method="post" onsubmit="javascript:submitForm(); return false;">
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>                  
                  <td align="right">
                    <table border="0" cellspacing="0" cellpadding="0">
                      <tr>
                        <td>&nbsp;&nbsp;</td>
                        <td><a href="javascript:submitForm();"><img border="0"  alt="<emxUtil:i18n localize="i18nId">emxComponents.Button.Done</emxUtil:i18n>" src="../common/images/buttonDialogDone.gif" /></a></td>
                        <td nowrap>&nbsp;<a href="javascript:submitForm();" class="button"><emxUtil:i18n localize="i18nId">emxComponents.Button.Done</emxUtil:i18n></a></td>
                        <td>&nbsp;&nbsp;</td>
                        <td><a href="javascript:closeWindow();"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxComponents.Button.Cancel</emxUtil:i18n>" src="../common/images/buttonDialogCancel.gif" /></a></td>
                        <td nowrap>&nbsp;<a class="button" href="javascript:closeWindow();"><emxUtil:i18n localize="i18nId">emxComponents.Button.Cancel</emxUtil:i18n></a></td>
                        <td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;</td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </form>
  
  </div>
          
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
