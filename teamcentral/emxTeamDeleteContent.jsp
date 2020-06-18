<%--  emxTeamDeleteContent.jsp - This page deletes or disconnects the Document object from Folder/Route

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamDeleteContent.jsp.rca 1.40.2.6.22.1.7.3 Fri Sep  4 09:41:02 2009 ds-kpawar Experimental $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<html>
<body>
<form name="deleteContent" id="deleteContent" method="post" ></form>
</body>
</html>

<%
  com.matrixone.apps.common.Person Person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);

  // read the Member list passed in
  String documentID          =   emxGetParameter(request,"rowIds");
  StringList documentIdList =    FrameworkUtil.split(documentID, ",");
   
  String sRemove             = emxGetParameter(request,"RemoveOption");
  String prevURL             = emxGetParameter(request,"prevURL");
  String folderId            = prevURL.substring(prevURL.indexOf("objectId=")+9, prevURL.indexOf("&", prevURL.indexOf("objectId=")));
  String targetLocation      = emxGetParameter(request,"targetLocation");
  String fromFolderManagement      = emxGetParameter(request,"fromFolderManagement");
  Workspace workspace                = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
  WorkspaceVault WorkspaceVault      = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
  
  String relDocumentStructure = Framework.getPropertyValue(session, "relationship_DocumentStructure");
  
  DomainObject deleteDocument   = DomainObject.newInstance(context);
  Iterator documentIdListItr = null;

  boolean hasRemoveAccess = true;
  int connectionListSize=0;
  StringList sRetainedObjectsRestoreList = new StringList();
  StringList sRetainedObjectsDeleteList = new StringList();
  String sRetainedObjectsRestore="";
  String sRetainedObjectsDelete="";
  
  String sOwnerObjects   = "";
  String sMsg            = "";
  String sMsg1           = "";
  String sName           = "";
  String sRev            = "";  
  String treeLabel       = "";
  
  
  StringBuffer itemList = new StringBuffer();
  itemList.append("<mxRoot><action>remove</action>");
  
  
  HashMap hmDocDetailsMap = new HashMap();
  if(fromFolderManagement!=null && !"".equals(fromFolderManagement)&& !"null".equals(fromFolderManagement)){
	  	String emxTableRowId = emxGetParameter(request,"emxTableRowId");
	  	String[] sSelectedRowIds = emxTableRowId.split("~");
	  	String parentFolderId = "";
		String sRowDetails = "";
		String sDocID = "";
		String sSelectedDocIds = "";
		String existingDocId = "";
		String rowId = "";
		
				
		for(int i=0;i<sSelectedRowIds.length;i++){
			sRowDetails = sSelectedRowIds[i];
			StringList emxTableIDs = FrameworkUtil.split(sRowDetails, "|");
			if(emxTableIDs.size()==4){
			sDocID = (String) emxTableIDs.get(1);
				parentFolderId = (String) emxTableIDs.get(2);
				rowId = (String) emxTableIDs.get(3);
			}
			if(emxTableIDs.size()==3){
				sDocID = (String) emxTableIDs.get(0);
				parentFolderId = (String) emxTableIDs.get(1);
				rowId = (String) emxTableIDs.get(2);
			}
			
			existingDocId = (String)hmDocDetailsMap.get(parentFolderId);
			sSelectedDocIds = ","+sDocID;
			hmDocDetailsMap.put(parentFolderId, existingDocId == null ? sDocID : existingDocId + sSelectedDocIds);	
			itemList.append("<item id='"+rowId+"'/>");
		}
		itemList.append("</mxRoot>");
		
		Iterator entries = hmDocDetailsMap.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry entry = (Map.Entry) entries.next();
            folderId = (String)entry.getKey();
            break;
        }
  }
  else if(documentID != null)
  {
	  if(folderId==null || "".equals(fromFolderManagement) && "null".equals(fromFolderManagement))
	  {
	  String emxTableID = emxGetParameter(request,"emxTableRowId");
	  StringList emxTableIDs = FrameworkUtil.splitString(emxTableID, "|");
	  folderId = (String) emxTableIDs.get(2);
	  }
       	  hmDocDetailsMap.put(folderId, documentID);
  }
  
  StringList sSubmittedObjectsDeleteList = new StringList();
  String sSubmittedObjectsDelete = "";
  
  StringList sSubmittedNamesDeleteList = new StringList();
  String sSubmittedNamesDelete = "";
if(hmDocDetailsMap.size() > 0){
  String sWorkspaceId = UserTask.getProjectId(context,folderId);
  workspace.setId(sWorkspaceId);

  WorkspaceVault.setId(folderId);

  BusinessObject   folderObj = new BusinessObject(folderId);
  BusinessObject documentObj  = null;

   
  boolean submitted=false;
  
  boolean sameRevisionSelected=false;
  
  if (documentID != null) {     
  	if (TeamUtil.hasRemoveAccess(context, documentIdList, workspace, sOwnerObjects,sRemove)) {   
      String sDocId = "";
      Iterator mapEntries = hmDocDetailsMap.entrySet().iterator();
       while (mapEntries.hasNext()) {
            Map.Entry entrySet = (Map.Entry) mapEntries.next();
            folderId = (String)entrySet.getKey();
            documentID = (String)entrySet.getValue();
            documentIdList =    FrameworkUtil.split(documentID, ",");
            WorkspaceVault.setId(folderId);
      documentIdListItr = documentIdList.iterator();
      String[] deleteArray=null;
      
      while (documentIdListItr.hasNext())
      {
        submitted=false;  
        
        sDocId = documentIdListItr.next().toString();
        deleteDocument.setId(sDocId);   
        

        sName = deleteDocument.getInfo(context,"attribute["+DomainConstants.ATTRIBUTE_TITLE+"]");
        sRev  =deleteDocument.getInfo(context,DomainObject.SELECT_REVISION);
        
        if ( "prior".equals(sRemove) )
        {
          try
          {
                BusinessObjectItr busItr = new BusinessObjectItr(deleteDocument.getRevisions(context));
			    BusinessObject bObj = deleteDocument.getPreviousRevision(context);
			    
			    boolean needDisconnect=WorkspaceVault.isContentExists(context,sDocId);
			    
			    if(needDisconnect){	
			        
			   	 String prevRevId = "";
			   	 boolean errorDocExist=false;
			   	 
			    	if(bObj != null)
			    	{
				    	DomainObject previousRevObj=new DomainObject(bObj);
				    	prevRevId = previousRevObj.getId();
				    	errorDocExist=WorkspaceVault.isContentExists(context,prevRevId);
				          				    	
			   	 	}
              	BusinessObject busDocRev = null;
              
              		while(busItr.next())
              		{
                	busDocRev = busItr.obj();
                	String revId=busDocRev.getObjectId();
                	if(revId.equals(sDocId))
                	 	{
                	     DomainObject domainObj   = DomainObject.newInstance(context,sDocId);
                         connectionListSize= checkConnections(context,session,sDocId);      
                       	 
                  		 if (connectionListSize > 1)
                             {  
                  		   WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));
                  		   sRetainedObjectsDeleteList.add(sName+" "+sRev); 
                             }       
                  		 
                  		if (connectionListSize <= 1 )
                        {
                  		 //DomainObject dmoLastRevision1 =  new DomainObject(deleteDocument.getLastRevision(context));
                      	 //String lastRev1  = dmoLastRevision1.getInfo(context,DomainObject.SELECT_REVISION);
                      	 if (!VaultedObjectsAccessUtil.isVaultedObjectLatestRevision(context,domainObj)){
                      	   WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));
                  		   sRetainedObjectsDeleteList.add(sName+" "+sRev); 
                      	 }
                      	 
                         else{
                         StringList jtFileList = domainObj.getInfoList(context, "to["+ relDocumentStructure +"].from.id");
                          if (jtFileList.size() < 1)
                          {
                             try
                             {  
                 	             ContextUtil.pushContext(context);
                 	             deleteArray = new  String[1];
                                 deleteArray[0]=sDocId;
                                 CommonDocument.deleteDocuments(context, deleteArray);
                                 ContextUtil.popContext(context);    
                                              
                             }
                             catch (Exception ex )
                             {
                                
                             }
                           }
                      	 }
                        }             	
                                           	
                      }
              		}
              		if(prevRevId!=null && !"".equals(prevRevId)&& !"null".equals(prevRevId) && !errorDocExist)
              		{
              		deleteDocument.setId(prevRevId);
              		Access access =  deleteDocument.getAccessMask(context);
              		
              		if (access.hasReadAccess() && access.hasShowAccess() && access.hasToConnectAccess()){
              		WorkspaceVault.connect(context, new RelationshipType("Vaulted Objects"),true,new Document(prevRevId));
              		  }
             	    }  
              		
			     }else{
			             sRetainedObjectsRestoreList.add(sName+" "+sRev);
			            			            
			    	  }			
          }
          catch (Exception ex )
          {
              session.putValue("error.message",ex);
          }
        }
        else if ( "leaveIn".equals(sRemove) )
        {
            WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));

        }
        else if ( "takeOut".equals(sRemove) )
        {
                                        
            
            boolean canRevDelete = true;
            boolean canDelete=false;
            
            
              try
              {  
                StringList deleteList = new StringList();                 
                deleteDocument.setId(sDocId);
                BusinessObjectItr busItr = new BusinessObjectItr(deleteDocument.getRevisions(context));
              	BusinessObject busDocRev = null;
              		while(busItr.next())
              		 {
                	 busDocRev = busItr.obj();
                	 DomainObject domainObj   = DomainObject.newInstance(context,busDocRev.getObjectId());
                	 connectionListSize=checkConnections(context,session,busDocRev.getObjectId()); 
                	 
           		 if (connectionListSize >= 1 && !sDocId.equals(busDocRev.getObjectId()) && documentID.indexOf(busDocRev.getObjectId())==-1)
                      {                       
                          canRevDelete = false;                                             
            
                      }     
           		 
           		if (connectionListSize == 1 && !sDocId.equals(busDocRev.getObjectId()) && documentID.indexOf(busDocRev.getObjectId())!=-1)
                {   
           		      canRevDelete=false;
           		 	  sameRevisionSelected = true;                                             
      
                } 
           		 
           		if (connectionListSize <= 1 && sDocId.equals(busDocRev.getObjectId()))
                {
                  StringList jtFileList = domainObj.getInfoList(context, "to["+ relDocumentStructure +"].from.id");
                  if (jtFileList.size() < 1)
                  {
                    canDelete = true;
                  }                        
                }             	
               }
              		
              	if (canRevDelete && canDelete){
              	    
              	 deleteDocument.setId(sDocId);
              	 DomainObject dmoLastRevision =  new DomainObject(deleteDocument.getLastRevision(context));
             	 String lastRev  = dmoLastRevision.getInfo(context,DomainObject.SELECT_REVISION);
             	 
             	 if (!lastRev.equals(sRev) && !sameRevisionSelected){
             	    submitted=true;
             	   sSubmittedObjectsDeleteList.add(sDocId);
             	   sSubmittedNamesDeleteList.add(sName+" "+sRev);
             	
            		} 
             	 
            	 else{
             	     
             	  BusinessObjectItr busItr2 = new BusinessObjectItr(deleteDocument.getRevisions(context));
             	  while(busItr2.next())
        		   {
             	    busDocRev = busItr2.obj();
             	   deleteList.addElement(busDocRev.getObjectId());
        		   }              	 
             	  deleteArray = (String[])deleteList.toArray(new String []{});
         		  CommonDocument.deleteDocuments(context, deleteArray);	
             	 }
              	} 
              	
              	
              	if (!canRevDelete && canDelete && !sameRevisionSelected){   
              	                   
              	  WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));
              	  sRetainedObjectsDeleteList.add(sName+" "+sRev);
              	} 
              	
              	if (canDelete && sameRevisionSelected){   
	                   
                	  WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));
                	  sameRevisionSelected=false;
                	  
                	} 
              	
              	if (!canRevDelete && !canDelete ){
              	  WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));
              	  sRetainedObjectsDeleteList.add(sName+" "+sRev);
              	}
              	
              	if (canRevDelete && !canDelete){ 
              	  WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));
              	  sRetainedObjectsDeleteList.add(sName+" "+sRev);
              	}               
              }
              catch (Exception ex )
              {
				 WorkspaceVault.disconnect(context, new RelationshipType("Vaulted Objects"),true,new Document(sDocId));
                 sRetainedObjectsDeleteList.add(sName+" "+sRev);
              }
        }
      }
  	}
      if (sRetainedObjectsDeleteList!=null && sRetainedObjectsDeleteList.size()>0){
          
          sRetainedObjectsDelete=FrameworkUtil.join(sRetainedObjectsDeleteList,",");
          
		    if(!sRetainedObjectsDelete.equals("")) {
	            sMsg = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", context.getLocale(),"emxTeamCentral.DeleteContent.DeleteMessage1");
	            sMsg = sMsg + "  " + sRetainedObjectsDelete  + "\n" + EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", context.getLocale(),"emxTeamCentral.DeleteContent.DeleteMessage2");
%>                      <script language="JavaScript"> 
	                	alert(" <%=XSSUtil.encodeForJavaScript(context, sMsg)%>");
	                    </script>
<% 			
		    }
      }
      
      if (sRetainedObjectsRestoreList!=null && sRetainedObjectsRestoreList.size()>0){
          
          sRetainedObjectsRestore=FrameworkUtil.join(sRetainedObjectsRestoreList,",");
          
		    if(!sRetainedObjectsRestore.equals("")) {
	            sMsg = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", context.getLocale(),"emxTeamCentral.DeleteContent.Restore1");
	            sMsg = sMsg + "  " + sRetainedObjectsRestore + "\n" + EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", context.getLocale(),"emxTeamCentral.DeleteContent.Restore2");
%>                      <script language="JavaScript"> 
	                	alert(" <%=XSSUtil.encodeForJavaScript(context, sMsg)%>");
	                    </script>
<% 			
		    }
      }
     
      %>     
          <script language="Javascript">
          <% if(submitted){
              sSubmittedObjectsDelete=FrameworkUtil.join(sSubmittedObjectsDeleteList,",");
              sSubmittedNamesDelete=FrameworkUtil.join(sSubmittedNamesDeleteList," , ");
              sMsg1=i18nNow.getI18nString("emxTeamCentral.DeleteContentHigherRevision.ConfirmMessage","emxTeamCentralStringResource",sLanguage);
              sMsg1 = sMsg1+ sSubmittedNamesDelete;
              %>
               //XSSOK
               var msg = '<%=sMsg1%>';               
               if(confirm(msg)){
            	   submitWithCSRF('../teamcentral/emxTeamDeleteContentAction.jsp?contentId=<%=XSSUtil.encodeForURL(context, sSubmittedObjectsDelete)%>&objectId=<%=XSSUtil.encodeForURL(context,  folderId)%>&confirm=true&targetLocation=<%=XSSUtil.encodeForURL(context,  targetLocation)%>', parent);
                }
                else{
                	submitWithCSRF('../teamcentral/emxTeamDeleteContentAction.jsp?contentId=<%=XSSUtil.encodeForURL(context, sDocId)%>&objectId=<%=XSSUtil.encodeForURL(context,  folderId)%>&confirm=false&targetLocation=<%=XSSUtil.encodeForURL(context,  targetLocation)%>', parent);
                }
                
                <% } else if(fromFolderManagement!=null && !"".equals(fromFolderManagement)&& !"null".equals(fromFolderManagement) && sRetainedObjectsRestoreList.size()<=0){
                %>
                	var frameToRefresh = findFrame(getTopWindow(), "WorkspaceContent");
          		  	var responseXML  = "<%=XSSUtil.encodeForJavaScript(context, itemList.toString())%>";
          		  	frameToRefresh.removedeletedRows(responseXML);
                <%
                }else {
                    %>
                    submitWithCSRF('../teamcentral/emxTeamDeleteContentAction.jsp?contentId=<%=XSSUtil.encodeForURL(context,  sDocId)%>&objectId=<%=XSSUtil.encodeForURL(context,  folderId)%>&confirm=false&targetLocation=<%=XSSUtil.encodeForURL(context,  targetLocation)%>', parent);
             <%   }
         
					MapList folderMapList =  new  MapList();
        folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,folderId);
     	if(folderMapList != null && folderMapList.size() > 0 ){
        Iterator folderMapListItr = folderMapList.iterator();
        while(folderMapListItr.hasNext()) {
          	Map folderMap = (Map)folderMapListItr.next();
          	String foldn  = (String)folderMap.get(WorkspaceVault.SELECT_NAME);
          	String foldId = (String)folderMap.get(WorkspaceVault.SELECT_ID);
          	treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,foldId,(String)null,appDirectory,sLanguage);
%>
			getTopWindow().changeObjectLabelInTree("<%=XSSUtil.encodeForURL(context, foldId)%>", "<%=treeLabel%>");
<%
       }
%>
	   if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
           getTopWindow().opener.getTopWindow().RefreshHeader();
       }else if(getTopWindow().RefreshHeader){
         	 getTopWindow().RefreshHeader();
		}
        
<%
     }
         %> 
 
          </script> 
    <%   
    
    }
  
    else {

      sMsg = i18nNow.getI18nString("emxTeamCentral.DeleteContent.AlertMessage","emxTeamCentralStringResource",sLanguage);
      sMsg = sMsg + " "+sOwnerObjects+".";
      sMsg = sMsg + i18nNow.getI18nString("emxTeamCentral.DeleteContent.RemoveMessage","emxTeamCentralStringResource",sLanguage);
%>
     <script language="Javascript">
      alert("<%=XSSUtil.encodeForJavaScript(context, sMsg)%>");      
      parent.window.closeWindow();
    </script>
<%
  	}
  }
}
%>
   
  <%!
  public int checkConnections(matrix.db.Context context, HttpSession session, String objectId )throws Exception
  {
      String activeVersion=Framework.getPropertyValue(session, "relationship_ActiveVersion");
      String latestVersion=Framework.getPropertyValue(session, "relationship_LatestVersion");
      
      DomainObject domainObj   = DomainObject.newInstance(context,objectId);
      StringBuffer relWhere = new StringBuffer(256);
      relWhere.append(domainObj.SELECT_RELATIONSHIP_NAME);
      relWhere.append(" != \"");
      relWhere.append(activeVersion);
      relWhere.append("\" && ");
      relWhere.append(domainObj.SELECT_RELATIONSHIP_NAME);
      relWhere.append(" != \"");
      relWhere.append(latestVersion);
      relWhere.append("\" && ");
      relWhere.append(domainObj.SELECT_RELATIONSHIP_NAME);
      relWhere.append(" != \"");
      relWhere.append(domainObj.RELATIONSHIP_PUBLISH_SUBSCRIBE);
      relWhere.append("\"");     
		
      ContextUtil.pushContext(context);
      
      MapList docRelatedList = domainObj.getRelatedObjects(context,
                                          "*",              		//relationshipPattern,
                                          "*",              		//typePattern,
                                          new SelectList(), 		// objectSelects,
                                          new SelectList(), 		// relationshipSelects,
                                          true,             		// getTo,
                                          true,             		// getFrom,
                                          (short)1,         		// recurseToLevel,
                                          null,             		// objectWhere,
                                          relWhere.toString());     //relationshipWhere)
	  ContextUtil.popContext(context);  
	  
	  return docRelatedList.size();
  }   
%>
