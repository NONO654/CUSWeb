<%--  emxCollectionsDuplicateDialogProcess.jsp   - To create the Duplicate Collection.

   Copyright (c) 2004-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxCollectionsDuplicateDialogProcess.jsp.rca 1.3.3.2 Wed Oct 22 15:48:57 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%
  String newSetName             = emxGetParameter(request, "collectionName");
  String newSetDescription      = emxGetParameter(request, "collectionDescription");
  String languageStr            = request.getHeader("Accept-Language");
  String jsTreeID               = emxGetParameter(request,"jsTreeID");
  String suiteKey               = emxGetParameter(request,"suiteKey");
  String strSelectedCollections = emxGetParameter(request,"selectedCollections");
  String reloadURL              = "";
  
  String strSystemGeneratedCollectionLabel = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(languageStr), "emxFramework.ClipBoardCollection.NameLabel");
  
  try 
  {
        boolean setExists = SetUtil.exists(context, newSetName);

        // Validating the name for Clipboard Collection and checking if it already exists. If true then displaying alert message saying that it already exists
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
                    //parent.location.reload();
                    window.history.back();
            </script>
<%

        }
        else
        {
        	%>
        	<%@include file = "enoviaCSRFTokenValidation.inc"%>
        	<%
            String sCommand                 = "add set $1 property description value $2";
            String output                   = MqlUtil.mqlCommand(context, sCommand,newSetName,newSetDescription);
            StringList strlCollections      = FrameworkUtil.split(strSelectedCollections,"|");
            String strTempCollectionName    = "";
            String strTempCollectionId      = "";
            MapList mplMemberIds;
            StringList strlobjectIds        = new StringList();
         
            for(int i = 0; i < strlCollections.size(); i++)
            {
                strTempCollectionId   = (String)strlCollections.get(i);
                strTempCollectionName =  SetUtil.getCollectionName(context,strTempCollectionId);
                mplMemberIds = SetUtil.getMembers(context,strTempCollectionName,new StringList("id")); 
                if(mplMemberIds.size()>0)
                    {
                    Iterator itr = mplMemberIds.iterator();
                    while(itr.hasNext())
                    {
                         Map mTemp = (Map) itr.next();
                         strlobjectIds.add((String) mTemp.get("id"));
                    }
               }
             
            }
            if(strlobjectIds.size()>0)
                SetUtil.append(context,newSetName,strlobjectIds);
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

