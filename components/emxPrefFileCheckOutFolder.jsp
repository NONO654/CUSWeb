<%--  emxPrefFileCheckOutFolder.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@page import="com.matrixone.apps.common.Download"%><html>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsAppletInclude.inc"%>

 <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no">
    <meta http-equiv="pragma" content="no-cache">
    <SCRIPT language="JavaScript" src="../common/scripts/emxUICore.js"
        type="text/javascript"></SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
        type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>

    <script type="text/javascript" >
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
      function doLoad() {
          if (document.forms[0].elements.length > 0) {
            var objElement = document.forms[0].elements[0];
                                                                  
            if (objElement.focus) objElement.focus();
            if (objElement.select) objElement.select();
          }
        }

      function jsParseSpChr(argString) {
          
    	    var parsedString = argString.replace(/[']/g,"\'");
    	    parsedString = argString.replace(/[\\]/g,"\/");
    	    return parsedString;
      }
	  

      function browseDirectories() {
    	    getApplet().browseDirectories();
      }

      function resetDirectory() {
    	    getApplet().resetDirectory();
      }
      
      function validationRoutine() {      
          
          var dirValue = getApplet().getDirectory();        
          dirValue = jsParseSpChr(dirValue);         
          document.getElementById("defaultCheckoutFolder").value = dirValue;
          return true;
      }

    
    </script>
  </head>
<% 
        String language  = request.getHeader("Accept-Language");
        String  fileCheckoutFolderLabel   = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.DirectoryChooserAppletPreferences.FileCheckOutFolder"); 
        String browseButtonLabel = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Button.Browse");
        String clearButtonLabel = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.Clear");
        
        String userDefaultCheckoutFolder = Download.processDefaultCheckoutDirectory(context);
        
        HashMap props = new HashMap();
        props.put("initialDirectory", userDefaultCheckoutFolder);
        props.put("debug", "true");
       
    
 %> 
 
  <body onload="doLoad() ,turnOffProgress()">
    <form method="post" action="emxPrefFileCheckOutFolderProcess.jsp" >
      <table border="10" cellpadding="5" cellspacing="0" width="100%">
       
        <tr>
                <td class="label" colspan="100%" > 
                <%=XSSUtil.encodeForHTML(context, fileCheckoutFolderLabel)%>  
                </td>                 
        </tr>
        <tr>
                <td class="inputField" >
                        <%addApplet(request, response, out, context, "com.matrixone.fcs.applet.DirectoryChooserApplet", 450, 20, props); %>
                        
                       
                </td>   
                
                  
                 <td class="inputField" >
                        
                        <input type="button" value=<%=XSSUtil.encodeForHTMLAttribute(context, browseButtonLabel) %> name="BrowseBtn" onclick="browseDirectories();" />
                        <input type="button" value=<%=XSSUtil.encodeForHTMLAttribute(context, clearButtonLabel) %> name="ClearBtn" onclick="resetDirectory();" />
                        <input type="hidden"  name="defaultCheckoutFolder" id="defaultCheckoutFolder" />
                          
                </td>        
            
        </tr>
        
               
      </table>
    </form>
  </body>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
