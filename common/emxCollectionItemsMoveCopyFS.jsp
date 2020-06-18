<%--  emxCollectionItemsMoveCopyFS.jsp   -   FS Page for displaying the collections to Move / Copy items
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionItemsMoveCopyFS.jsp.rca 1.3.3.2 Wed Oct 22 15:49:00 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
	initSource = "";
  }

  String jsTreeID               = emxGetParameter(request,"jsTreeID");
  String suiteKey               = emxGetParameter(request,"suiteKey");
  String strMode                = emxGetParameter(request,"mode");
  String timeStamp              = emxGetParameter(request,"timeStamp");
  HashMap tableData             = indentedTableBean.getTableData(timeStamp);
  HashMap requestMap            = indentedTableBean.getRequestMap(tableData);
  String strCollectionName      = (String)requestMap.get("treeLabel"); 
  String strCharSet             = Framework.getCharacterEncoding(request);
  String strTempCollectionName  = XSSUtil.decodeFromURL(strCollectionName); 

  String strSystemGeneratedCollectionLabel  = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.NameLabel" );
  //Modified for Bug 342586
  String strSystemGeneratedCollection       = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");

  // Validating if the collection label is Clipboard Collection. If yes then change it to system generated collection
    if(strTempCollectionName.equals(strSystemGeneratedCollectionLabel))
    {
      strCollectionName = strSystemGeneratedCollection;
    }

  // ----------------- Do Not Edit Above ------------------------------
  
  String[]  strSelectedCollections = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
  StringBuffer strTemp = new StringBuffer();
    
  if(strSelectedCollections != null)
  {
    for(int i=0;i<strSelectedCollections.length;i++)
    {
        strTemp.append(strSelectedCollections[i]);
        strTemp.append("|");
    }
  }
  String strCollections = (strTemp.toString()).substring(0, strTemp.length() - 1);
  strTemp = new StringBuffer(50);
  strTemp.append(strCollections);

  // Add Parameters Below

  // Specify URL to come in middle of frameset
  StringBuffer contentURLBuf = new StringBuffer(80);
  contentURLBuf.append("emxCollectionItemsMoveCopy.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURLBuf.append("?suiteKey=");
  contentURLBuf.append(suiteKey);
  contentURLBuf.append("&initSource=");
  contentURLBuf.append(initSource);
  contentURLBuf.append("&jsTreeID=");
  contentURLBuf.append(jsTreeID);
  contentURLBuf.append("&selectedCollections=");
  contentURLBuf.append(strTemp.toString());
  contentURLBuf.append("&mode=");
  contentURLBuf.append(strMode);
  contentURLBuf.append("&fromCollectionName=");
  contentURLBuf.append(XSSUtil.encodeForURL(strCollectionName));
  
  //String contentURL=FrameworkUtil.encodeHref(request,contentURLBuf.toString());
  String finalURL = contentURLBuf.toString();

  // Page Heading - Internationalized
  String PageHeading = strMode+" Collection Items";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcollectioncreate";

  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  finalURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";
                    
  fs.createFooterLink("emxFramework.Common.Done",
                      "doneMethod()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

                      
  fs.createFooterLink("emxFramework.Button.Cancel",
                      "parent.window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
