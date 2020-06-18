<%--  emxCollectionsCreateProcess.jsp  - To create Collections
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsCreateProcess.jsp.rca 1.9.2.1 Fri Nov  7 09:35:42 2008 ds-kvenkanna Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>
<!-- Import the java packages -->

<%
          String newSetName                         = emxGetParameter(request, "collectionName");
          String newSetDescription                  = emxGetParameter(request, "collectionDescription");
          String strSystemGeneratedCollectionLabel  = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.NameLabel");
          String jsTreeID                           = emxGetParameter(request,"jsTreeID");
          String suiteKey                           = emxGetParameter(request,"suiteKey");
          String reloadURL                          = "";

           try 
           {
                 boolean setExists = SetUtil.exists(context, newSetName);

                 // validating for Clipboard Collections also not to be created
                  if (setExists || newSetName.equals(strSystemGeneratedCollectionLabel))
                  {
                   %>
                      <script language="Javascript">
                             var alertMsg = "<emxUtil:i18n localize="i18nId">emxFramework.Collections.CollectionError</emxUtil:i18n>";
                             alertMsg += " ";
                             alertMsg += "<%=XSSUtil.encodeForJavaScript(context, newSetName)%>";
                             alertMsg += " ";
                             alertMsg += "<emxUtil:i18n localize="i18nId">emxFramework.Collections.AlreadyExists</emxUtil:i18n>";
                             alert(alertMsg);
                            //To retain the dialog page with description    
                            //parent.location.reload();
                             window.history.back();
                     </script>
<%
               }else
                {
                     String output = MqlUtil.mqlCommand(context, "add set $1 property description value $2",newSetName,newSetDescription);
                }
                // Modified for Bug 345123
             if(!setExists)
             {
%>
                <script language="Javascript">
                var hrefTemp = parent.window.getWindowOpener().document.location.href.replace("&persist=true","");
                parent.window.getWindowOpener().document.location.href = hrefTemp;
                parent.window.closeWindow();
                getTopWindow().getWindowOpener().getTopWindow().refreshShortcut();
                </script>
<%
             }
        }
        catch(Exception e)
        {
            throw e;
        }

%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
