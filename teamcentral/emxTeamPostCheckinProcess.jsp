<%--  emxTeamPostCheckinProcess.jsp -- To upload a file to folder / route .
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTeamPostCheckinProcess.jsp.rca 1.16 Wed Oct 22 16:06:11 2008 przemek Experimental przemek $";
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<html>
<body>
<%
  String parentId  = null;
  String folderId  = null;
  String customSortColumns = null;
  String customSortDirections = null;
  String uiType = null;
  String table = null;
  String timeStamp = null;
  String objectId  = emxGetParameter(request,"objectId");
  String fromPage  = emxGetParameter(request,"fromPage"); 

  Map requestMap = (HashMap)request.getAttribute("requestMap");
  if(requestMap == null) requestMap = (Map) session.getAttribute("emxCommonDocumentCheckinData");
 
  String refreshTable = (String) emxGetParameter(request, "refreshTableContent");
  if(UIUtil.isNullOrEmpty(refreshTable)){
   refreshTable = (String)requestMap.get("refreshTableContent");
  }  
  boolean refreshTableContent = "true".equalsIgnoreCase(refreshTable);
  
  String updateTreeLabel = (String) emxGetParameter(request, "updateTreeLabel");
  if(UIUtil.isNullOrEmpty(updateTreeLabel)){
	  updateTreeLabel = (String)requestMap.get("updateTreeLabel");
  }  

  boolean treeNotToBeUpdated = "false".equalsIgnoreCase(updateTreeLabel);
  
  if(UIUtil.isNullOrEmpty(fromPage)){
  fromPage = (String) requestMap.get("fromPage");
  }
  

  if (requestMap != null)
  {     
    parentId = (String)requestMap.get("parentId");
    folderId = (String)requestMap.get("folderId");
    //Added for Bug #371651 starts
    customSortColumns = (String)requestMap.get("customSortColumns");
    customSortDirections = (String)requestMap.get("customSortDirections");
    uiType = (String)requestMap.get("uiType");
    table = (String)requestMap.get("table");
    timeStamp = (String)requestMap.get("timeStamp");
    //Added for Bug #371651 ends
  }
  
  if ("multi".equals(fromPage))
  {
    // folderId is present by name parentId in 'multi' object 
    // returned by the servlet during multiple file checkin
    folderId = (String)requestMap.get("parentId");
  } 

  if ((parentId != null) && (parentId.equals("RouteWizard")))
  {

    Hashtable hashRouteWizFirst = (Hashtable)session.getValue("hashRouteWizFirst");
    if(hashRouteWizFirst == null)
    {
      hashRouteWizFirst = new Hashtable();
    }

    MapList DocList     = new MapList();
    if (hashRouteWizFirst.get("uploadedDocIDs") != null)
    {
      DocList     = (MapList)hashRouteWizFirst.get("uploadedDocIDs");
    }

    if (DocList == null)
    {
      DocList = new MapList();
    }

    String sAddedDocIds = (String)hashRouteWizFirst.get("documentID");
    if (sAddedDocIds == null)
    {
      sAddedDocIds = "";
    }

    HashMap tempHash = new HashMap();
    tempHash.put("docID",    objectId);
    tempHash.put("folderId", folderId);
    DocList.add((Map)tempHash);

    String sTilde = "~";
    StringBuffer docIds = new StringBuffer(sAddedDocIds.length() + 30);
    docIds.append(sAddedDocIds);
    docIds.append(sTilde);
    docIds.append(objectId);
    docIds.append(sTilde);
    
    hashRouteWizFirst.put("documentID", docIds.toString());    
    hashRouteWizFirst.put("uploadedDocIDs", DocList);
    session.putValue("hashRouteWizFirst",  hashRouteWizFirst);
  }

  MapList folderMapList  =  new MapList();
  String treeLabel       = "";
  StringBuffer temptreeLabel   = new StringBuffer(64);
  String labelDelimiter = "<**>";
  boolean isLinkedFolder = false;
   
  if (((objectId != null) && (!objectId.equals(""))) || 
      ("multi".equals(fromPage)))
  {
     if (((folderId == null) || ("null".equals(folderId))) &&
         ("multi".equals(fromPage)))
     {
       // when folderId is null (happens when file uploaded directly 
       // from contentsummary and not through RouteWizard,
       // get folderId from checked-in document through Vaulted Object rel
       DomainObject vaultObject      = DomainObject.newInstance(context);  
       vaultObject.setId(objectId);
       vaultObject.open(context);
       StringBuffer vaultSelect = new StringBuffer(32);
       vaultSelect.append("to[");
       vaultSelect.append(DomainObject.RELATIONSHIP_VAULTED_OBJECTS);
       vaultSelect.append("].from.id");
       folderId = vaultObject.getInfo(context, vaultSelect.toString());
     }

     if (folderId != null && !folderId.equals(""))
     {
       folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context, folderId);
       isLinkedFolder = WorkspaceVault.isLinkedWorkspaceVault(context, folderId);
       treeLabel = UITreeUtil.getUpdatedTreeLabel(application, session, request, context, folderId,
                                       (String)null, appDirectory, sLanguage);
       if(treeLabel != null && !"".equals(treeLabel))
       {
          temptreeLabel.append(folderId);
          temptreeLabel.append(labelDelimiter);
          temptreeLabel.append(treeLabel);
          temptreeLabel.append(labelDelimiter);
       }
     }

     if (folderMapList != null && folderMapList.size() > 0 )
     {
       Iterator folderMapListItr = folderMapList.iterator();
       while (folderMapListItr.hasNext())
       {
         Map folderMap = (Map)folderMapListItr.next();
         String foldId = (String)folderMap.get(DomainObject.SELECT_ID);
         treeLabel = UITreeUtil.getUpdatedTreeLabel(application, session, request, context, foldId,
                                         (String)null, appDirectory, sLanguage);
         if (treeLabel != null && !"".equals(treeLabel))
         {
           temptreeLabel.append(foldId); // modified for bug 281597
           temptreeLabel.append(labelDelimiter);
           temptreeLabel.append(treeLabel);
           temptreeLabel.append(labelDelimiter);
         }
       }
     }
   }

   String errCheckinStr = (String)session.getValue("error.message");
   boolean boolNoError = true;   
   if ((errCheckinStr != null) && 
       (!"".equals(errCheckinStr)) &&
       (!"null".equals(errCheckinStr)))
   {
     boolNoError = false;
   }
   
  %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="Javascript">  
  //Structure tree object
  var refreshTableContent = "<xss:encodeForJavaScript><%=refreshTableContent%></xss:encodeForJavaScript>";
  var frameContent = openerFindFrame(getTopWindow(),"detailsDisplay");
  frameContent = frameContent == null ? openerFindFrame(getTopWindow(), "content") : frameContent;
    //Context tree object
    //XSSOK
   if(<%=boolNoError%> && !<%=treeNotToBeUpdated%>) {	   
	  var labelArray	="<%=temptreeLabel.toString()%>".split('<**>');
	  labelArray.splice(-1,1);
	 for(var j=0;j<labelArray.length;j=j+2) {
		 getTopWindow().getWindowOpener().getTopWindow().changeObjectLabelInTree(labelArray[j], labelArray[j+1]);
    }
	if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
              getTopWindow().opener.getTopWindow().RefreshHeader();
       }else if(getTopWindow().RefreshHeader){
              getTopWindow().RefreshHeader();
  	 }
     if(<%=isLinkedFolder%>){
		 getTopWindow().getWindowOpener().getTopWindow().refreshTrees();
	 }
    }
<%
 if(parentId != null && parentId.equals("RouteWizard")) {
%>
    frameContent.parent.location.reload();
        //Added for Bug #371651 starts
<%} else if(uiType != null && "Table".equalsIgnoreCase(uiType)){
%>
    //frameContent.document.location.reload();// This wont work in Net Scape 7.0
//window.close();
try{
    if(refreshTableContent == "true") {
	    getTopWindow().getWindowOpener().refreshTableContent();
    } else {
       //XSSOK
       getTopWindow().getWindowOpener().refreshTable("<%= XSSUtil.encodeForJavaScript(context, table)%>","<%=XSSUtil.encodeForJavaScript(context, customSortColumns)%>","<%=XSSUtil.encodeForJavaScript(context, customSortDirections)%>","<%=timeStamp%>","<%=XSSUtil.encodeForJavaScript(context, uiType)%>");    
    }
}catch(e){}

<%
}else{%>
    if(refreshTableContent == "true") {
    	var tableContentFrame = openerFindFrame(getTopWindow(),"listDisplay");
    	if(tableContentFrame) {
	    	tableContentFrame.refreshTableContent();
    	} else {
    		if(frameContent.document.location.href.indexOf("emxPortal.jsp")>-1 && getTopWindow().getWindowOpener().location.href.indexOf("emxIndentedTable.jsp")){
    			getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort();
    		}else{
			frameContent.document.location.href=frameContent.document.location.href;    	
    	}
    	}
    } else {
		var refreshURL = frameContent.document.location.href;
		refreshURL = refreshURL.replace("persist=true","persist=false");
		frameContent.document.location.href = refreshURL;
    }
    //Added for Bug #371651 Ends
<%
  }
%>

// In Case of safari, modal dialog property for closed in not being set, so setting modaldialog to undefined
  try{
  	if(isKHTML && getTopWindow().getWindowOpener().getTopWindow()){
  		getTopWindow().getWindowOpener().getTopWindow().modalDialog="undefined";
  	}
  }catch(e){}
  getTopWindow().closeWindow();
  
</script>
</body>
</html>
