<%--  emxCollectionAddToProcess.jsp   -  The process page for Add items to an existing one.

   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsAddToProcess.jsp.rca 1.11 Wed Oct 22 15:48:35 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
    String selectedCollectionName   = "";
    HashMap requestMap              = new HashMap();
    HashMap tableData               = new HashMap();
    String strMode                  = emxGetParameter(request,"mode");
    String timeStamp                = emxGetParameter(request,"timeStamp");
    String sCharSet                 = Framework.getCharacterEncoding(request);

    if(timeStamp != null){
      tableData = tableBean.getTableData(timeStamp);

    if(tableData != null   ){
        requestMap = tableBean.getRequestMap(tableData);
      }
    }
    String collectionId = emxGetParameter(request,"CollectionId");
    if(UIUtil.isNotNullAndNotEmpty(collectionId)){
        selectedCollectionName  = SetUtil.getCollectionName(context,collectionId);
    }

    if(UIUtil.isNotNullAndNotEmpty(selectedCollectionName)){
	String[] strSelectedRowDetails = emxGetParameterValues(request,"emxTableRowId");
	if(strSelectedRowDetails != null && strSelectedRowDetails.length > 0)
	  {
		// Added to check the label is clipboard collections or not. If yes then modify with system generated collection name
    	//Modified for Bug 342586
    	String strSystemGeneratedCollection 		= EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
    	String strSystemGeneratedCollectionLabel 	= EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.NameLabel");
   		if(selectedCollectionName.equals(strSystemGeneratedCollectionLabel))
    	{
     	   selectedCollectionName = strSystemGeneratedCollection;
    	}
  	    // Set up the member Id list.
   		StringList memberIds = new StringList();


   		String[] emxTableRowIds = new String[strSelectedRowDetails.length];
	    for(int iTemp=0;iTemp<strSelectedRowDetails.length;iTemp++)
	    {
	        StringList strlObjectIdList = FrameworkUtil.split( ((String)strSelectedRowDetails[iTemp]),"|");
	        emxTableRowIds[iTemp] = (String) strlObjectIdList.get(0);
	    }

	    int sRowIdsCount = emxTableRowIds.length;

	    if (sRowIdsCount > 0) {
	        for(int count=0; count < sRowIdsCount; count++){
	            memberIds.addElement(emxTableRowIds[count]);
	        }
    	}

    SetUtil.append(context, selectedCollectionName, memberIds);
    session.removeAttribute("emx.memberIds");

%>
<script language="Javascript">
    
	getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
	getTopWindow().closeWindow();

</script>
<%
	  }
	  else
	  {
%>
			<script language="Javascript">
				var alertMsg = "<emxUtil:i18n localize="i18nId">emxFramework.Collections.PleaseSelectItem</emxUtil:i18n>";
				alert(alertMsg);
			</script>
<%
	  }
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<%

    if(UIUtil.isNullOrEmpty(selectedCollectionName)){

          String initSource = emxGetParameter(request,"initSource");
          if (initSource == null){
            initSource = "";
          }

          String jsTreeID = emxGetParameter(request,"jsTreeID");
          String suiteKey = emxGetParameter(request,"suiteKey");
          String objectId = emxGetParameter(request,"objectId");
    	  String addFrom3DSearch = emxGetParameter(request,"addFrom3DSearch");

          // ----------------- Do Not Edit Above ------------------------------

          String memberIds[] = emxGetParameterValues(request,"emxTableRowId");
          if (memberIds != null)
            session.setAttribute("emx.memberIds",memberIds);
          else
          {
              memberIds = new String[1];
              memberIds[0] = objectId;
              session.setAttribute("emx.memberIds",memberIds);
          }

          // Specify URL to come in middle of frameset
          //StringBuffer contentURL = new StringBuffer("emxCollectionsSelectCreateDialogFS.jsp");
          StringBuffer contentURL = new StringBuffer();

		  // Modified for Clipboard Collection
		  // Validating this page is called from ClipboardMenu or ClipboardCollectionsCommand. If yes then directly add the selected items to system generated collection using emxCollectionsClipboardAppendProcess.jsp page. Else show the Collections list dialog page.

          if(strMode!=null && strMode.equals("Clipboard"))
          {
          	contentURL = new StringBuffer("emxCollectionsClipboardAppendProcess.jsp");
          }
          else
          {
              contentURL = new StringBuffer("emxCollectionsSelectCreateDialogFS.jsp");
          }
		  //Ended

          // add these parameters to each content URL, and any others the App needs
          contentURL.append("?suiteKey=");
          contentURL.append(XSSUtil.encodeForURL(context, suiteKey));
          contentURL.append("&initSource=");
          contentURL.append(XSSUtil.encodeForURL(context, initSource));
          contentURL.append("&jsTreeID=");
          contentURL.append(XSSUtil.encodeForURL(context, jsTreeID));
          contentURL.append("&objectId=");
          contentURL.append(XSSUtil.encodeForURL(context, objectId));
	      contentURL.append("&addFrom3DSearch=");
	      contentURL.append(XSSUtil.encodeForURL(context, addFrom3DSearch));
          contentURL.append("&shortcutKey=");
%>
<html>
<head>
	<title></title>
        <script language="Javascript">
	/* Modified for Clipboard Collection
	Validating whether the page is called from Add to Collections menu or command. If it is menu then submit this page so that the selected items are added to the System Generated collection without any window pop up else popup window should display and user should select one or more collections to add */
            function launchModalWin(){
            var tempVar1 = "Clipboard";
            var tempVar2 = "<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>";
            	if(tempVar2==tempVar1){
            		//XSSOK
            		submitWithCSRF("<%=contentURL%>"+getTopWindow().window.name, this);
		        }else{
	                //XSSOK
	                showNonModalDialog('<%=contentURL%>',750,600,true,true);
			    }
    /* Ended */
            }
        </script>
</head>

<body onload="launchModalWin()">
<form name="Temp" action="<%=contentURL%>">
</form>
</body>
</html>
<%
    }
%>


