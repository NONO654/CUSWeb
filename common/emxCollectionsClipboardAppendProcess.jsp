<%--  emxCollectionsClipboardAppendProcess.jsp   -  This page used to append the selected items to the system generated collection.

   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsClipboardAppendProcess.jsp.rca 1.2.5.2 Wed Oct 22 15:47:51 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<!-- Import the java packages -->
<%@ page import="com.matrixone.apps.domain.util.SetUtil,matrix.db.Context,com.matrixone.apps.framework.ui.UINavigatorUtil,matrix.util.StringList" %>
<jsp:useBean id="shortcutInfo" class="com.matrixone.apps.framework.ui.UIShortcut" scope="session" />
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
String jsTreeID = emxGetParameter(request,"jsTreeID");
String suiteKey = emxGetParameter(request,"suiteKey");
String objectId = emxGetParameter(request,"objectId");
String shortcutKey = emxGetParameter(request,"shortcutKey");
String addFrom3DSearch = emxGetParameter(request,"addFrom3DSearch");

if(UIUtil.isNullOrEmpty(shortcutKey)){
	  shortcutKey = "Shortcut_Content";
}


/* 
*	This page will be called when the user clicks the menu icon or Add to clipboard command to add the selected items to the system generated collection.
*	It will get the objectid of the selected items to be added to the system generated collection.
*/

String[] strSelectedCollectionItems = (String [])session.getAttribute("emx.memberIds");
String strTemp = "";
StringList strMemberIDs = new StringList();
//Modified for Bug 342586
String strSystemGeneratedCollection = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");

for(int itemp =0;itemp<strSelectedCollectionItems.length;itemp++)
{
    strTemp = strSelectedCollectionItems[itemp];

	if(strTemp.indexOf("|")!=-1)
	{
		StringList strlmememberList=FrameworkUtil.split(strTemp,"|");
	    if (strlmememberList.size() == 3)
	    {
	        strMemberIDs.addElement(strlmememberList.get(0));
	    }
	    else
	    {
	        strMemberIDs.addElement(strlmememberList.get(1));
	    }
	 }
	else if (!strTemp.equals("-1"))
	{
	     strMemberIDs.addElement(strTemp);
	}
}


// Check for RelId's if any and truncate them

	String strAttName = "";
	boolean bchk = false;
	StringList strlmemberTempIds = new StringList();

	for (int iIndex = 0; iIndex < strMemberIDs.size(); iIndex ++)
	{
    	strAttName = (String) strMemberIDs.elementAt(iIndex);
		if(strAttName.lastIndexOf("|")>0) 
		{
	    	strAttName = strAttName.substring(strAttName.lastIndexOf("|")+1);
	    	bchk = true;
		}
		strlmemberTempIds.addElement(strAttName);
	}

	if(bchk)  
	{

		// remove all relids
		strMemberIDs.removeAllElements();
		// add the busIds back to list.
		strMemberIDs.addAll(strlmemberTempIds);
	}

	SetUtil.append(context,strSystemGeneratedCollection,strMemberIDs);

%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
	debugger;
	var addFrom3DSearch = "<xss:encodeForJavaScript><%=addFrom3DSearch%></xss:encodeForJavaScript>";
	if("true" === addFrom3DSearch){
		getTopWindow().refreshShortcut();
		getTopWindow().showTransientMessage("<emxUtil:i18n localize="i18nId">emxFramework.Collections.AddedToCollection</emxUtil:i18n>", 'success', 'alert-right-search','4000');
	}else{
	if(getTopWindow().$.inArray("facet1", getTopWindow().shortcut) == -1){
		console.log("When SC is closed");
		getTopWindow().shortcut.push("facet1");
	} 
	<%String slideInBehaviour = EnoviaResourceBundle.getProperty(context, "emxFramework.addToClipborad.shortcutSlidein.behaviour");
    if("false".equalsIgnoreCase(slideInBehaviour)){%>
        getTopWindow().showTransientMessage("<emxUtil:i18n localize="i18nId">emxFramework.Collections.AddedToCollection</emxUtil:i18n>", 'success', 'alert-right-search','4000');
    <%}else{%>
        getTopWindow().showShortcutDialog();
    <%}%>

	}
</script>
