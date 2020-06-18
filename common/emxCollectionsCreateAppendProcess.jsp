<%--  emxCollectionCreateAppendProcess.jsp   -  The process page for create a
      new collection or append to an existing one.

   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsCreateAppendProcess.jsp.rca 1.10.2.1 Fri Nov  7 09:35:29 2008 ds-kvenkanna Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<!-- Import the java packages -->

<%@ page import="com.matrixone.apps.domain.util.SetUtil,com.matrixone.apps.framework.ui.UINavigatorUtil" %>

<%
// Reading the system generated collection name and label name
String strSystemGeneratedCollectionLabel = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.NameLabel");

// Reading the selected collection names from dialog page
String[] strSelectedCollectionName = emxGetParameterValues(request, "setRadio");
String addFrom3DSearch = emxGetParameter(request,"addFrom3DSearch");

 // Set up the member Id list.
 StringList memberIds = new StringList();
 for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
 {
   String name = (String) names.nextElement();
   if (name.startsWith("member"))
   {
     String value = emxGetParameter(request, name);
     if(value.indexOf("|")!=-1){
        StringList mememberList=FrameworkUtil.split(value,"|");
        if (mememberList.size() == 3){
              memberIds.addElement(mememberList.get(0));
        }else{
              memberIds.addElement(mememberList.get(1));
        }
     }else if (!value.equals("-1")){
       memberIds.addElement(value);
     }
   }

   if (name.equals("IdList"))
   {
     String value                   = emxGetParameter(request, name);
     StringTokenizer memberToken    = new StringTokenizer(value,"|");
     int noOfTokens                 = memberToken.countTokens();
     for (int count = 0; count < noOfTokens;count++)
     {
        memberIds.addElement(memberToken.nextToken());
     }
   }
 }

 // Check for RelId's if any and truncate them

 String sAttName = "";
 boolean chk = false;
 StringList memberTempIds = new StringList();

 for (int iIndex = 0; iIndex < memberIds.size(); iIndex ++) {
   sAttName = (String) memberIds.elementAt(iIndex);
   if(sAttName.lastIndexOf("|")>0) {
     sAttName = sAttName.substring(sAttName.lastIndexOf("|")+1);
     chk = true;
   }
   memberTempIds.addElement(sAttName);
 }

 if(chk)  {

   // remove all relids
   memberIds.removeAllElements();

   // add the busIds back to list.
   memberIds.addAll(memberTempIds);
 }

 //Adding the given items to the selected collections
 //if new collection also given then create the new collection with the given items

 for(int iTemp=0; iTemp<strSelectedCollectionName.length;iTemp++)
 {
     // Create new Collection
     if(strSelectedCollectionName[iTemp].equals("") )
     {
       String strCollectionName = emxGetParameter(request, "setName");
       String strCollectionDescription = emxGetParameter(request,"setDescription");
       boolean setExists = SetUtil.exists(context, strCollectionName);
       if (setExists || strCollectionName.equals(strSystemGeneratedCollectionLabel)) // To validate for system generated clipboard collection name also
       {
%>
         <script language="Javascript">
         var alertMsg = "<emxUtil:i18n localize="i18nId">emxFramework.Collections.CollectionError</emxUtil:i18n>";
         alertMsg += " ";
         alertMsg += "<%=XSSUtil.encodeForJavaScript(context, strCollectionName)%>";
         alertMsg += " ";
         alertMsg += "<emxUtil:i18n localize="i18nId">emxFramework.Collections.AlreadyExists</emxUtil:i18n>";
         alert(alertMsg);
         parent.window.location.href = parent.window.location.href;
         //window.history.back();
         </script>
<%
        break;
   }
   else
       {
             SetUtil.create(context, strCollectionName, memberIds);
             String strOutput = MqlUtil.mqlCommand(context,"Modify set $1 property description value $2 ;",strCollectionName,strCollectionDescription); 
             session.removeAttribute("emx.memberIds");
       }
    }
    else  // Append to existing Collection
    {
             SetUtil.append(context, strSelectedCollectionName[iTemp], memberIds);
             session.removeAttribute("emx.memberIds");
    }
 }
%>
<script language="JavaScript" type="text/javascript" src="scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="javascript" src="scripts/emxUICore.js"></script>
<script language="Javascript">
//modified for the bug 324174
var displayFrame="";
  var addFrom3DSearch = "<xss:encodeForJavaScript><%=addFrom3DSearch%></xss:encodeForJavaScript>";

  if(getTopWindow().getWindowOpener()) {
    displayFrame = getTopWindow().getWindowOpener().getTopWindow();
      }
	if("true" === addFrom3DSearch){
            displayFrame.refreshShortcut();
		displayFrame.showTransientMessage("<emxUtil:i18nScript localize="i18nId">emxFramework.Collections.AddedToCollection</emxUtil:i18nScript>", 'success', 'alert-right-search','4000');	
	}else{
		displayFrame.showShortcutDialog();
        }
       getTopWindow().closeWindow();
	
</script>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
