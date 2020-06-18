<%--  emxProgramCentralAutonomySearchResult.jsp

  Applies the results of the member search to the task.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
--%>
<%@ include file="emxProgramGlobals2.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<jsp:useBean id="formBean" scope="session"
	class="com.matrixone.apps.common.util.FormBean" />

<%
	String appDir           =   (String)emxGetParameter(request, "appDir");
	String appProcessPage   =   (String)emxGetParameter(request, "appProcessPage");
	String actionMode       =   (String)emxGetParameter(request, "actionMode");
	String relName       =   (String)emxGetParameter(request, "relName");
	
    com.matrixone.apps.common.WorkspaceVault workspaceVault =
    (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);

    com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);

   String formKey = emxGetParameter(request, "formKey");
   formBean.processForm(session,request,"formKey");

   //the DocumentHolder objectId
   String currentObjectId   = emxGetParameter(request, "currentVaultId");
   if ((currentObjectId == null) || "null".equals(currentObjectId) || "".equals(currentObjectId))
   {
      currentObjectId   = emxGetParameter(request, "myParentId"); 
   }

   String topParentHolderId   = emxGetParameter(request, "topParentHolderId");
   if ((topParentHolderId == null) || "null".equals(topParentHolderId) || "".equals(topParentHolderId))
   {
      topParentHolderId = emxGetParameter(request, "projectID");
   }

   java.util.List taskTypeList = null;
   if(topParentHolderId!=null && !"".equals(topParentHolderId)){
     project.setId(topParentHolderId );
     taskTypeList = getTaskManagementTypes(context);
   }

   //get all selected objectIds
   StringList idsList = new StringList();
   //Iterate through all values on the form bean
   Iterator elementNameIterator = (Iterator) formBean.getElementNames();

   while (elementNameIterator.hasNext())
   {
      //Get the elementName and value
      String elementName = (String) elementNameIterator.next();

      //the documentId is after selectedFile on the elementName string
      if (elementName.startsWith("selectedFile"))
      {
         String docId = elementName.substring(12);
         idsList.add(docId);
      }
   }

   //proceed further if some objectId selected
   int idsCount = idsList.size();
  
   // if we didnt get any ids see if we came from indented structure browser
   if(idsCount == 0)
   {
      String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
      tableRowIdList = ProgramCentralUtil.parseTableRowId(context, tableRowIdList);
      if(tableRowIdList != null )
      {
         for(int i=0;i<tableRowIdList.length;i++){
            idsList.add(tableRowIdList[i]);
         }
      }
   }   
  
   // see if we have any ids now
   idsCount = idsList.size();
   if(idsCount > 0)
   {
      StringBuffer noAccessObjects = new StringBuffer();
      try
      {
          
         //start transaction
         ContextUtil.startTransaction(context, true);

         //use workspaceVault object as a DocumentHolder object for other types as well
         workspaceVault.setId(currentObjectId);
         
         DomainObject dmObj = DomainObject.newInstance(context, currentObjectId);
         
         String objectType = dmObj.getInfo(context, dmObj.SELECT_TYPE);
         //set default relationship between DocumentHolder and Document objects
         String defaultRelWDoc = workspaceVault.RELATIONSHIP_REFERENCE_DOCUMENT;
		 
         //Added:22-Apr-09:NZF:R207:PRG:Bug:374021
         String strMQL = "print type \"" + DomainConstants.TYPE_CONTROLLED_FOLDER +"\" select derivative dump |";//PRG:RG6:R213:Mql Injection:Static Mql:14-Oct-2011
         String strResult = MqlUtil.mqlCommand(context, strMQL, true);
         StringList slControlledFolderTypeHierarchy = FrameworkUtil.split(strResult, "|");

		 //Dont forget to add Controlled Folder type itself into this listing
         slControlledFolderTypeHierarchy.add(DomainConstants.TYPE_CONTROLLED_FOLDER);
		 //End:R207:PRG:Bug:374021
		 
         //Modified:22-Apr-09:NZF:R207:PRG:Bug:374021
         if((workspaceVault.TYPE_WORKSPACE_VAULT).equals(objectType) || slControlledFolderTypeHierarchy.contains(objectType))
         {//End:R207:PRG:Bug:374021
            defaultRelWDoc = workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2;
         }
         //else if((workspaceVault.TYPE_TASK).equals(objectType))
         else if(taskTypeList != null &&taskTypeList.contains(objectType))
         {
			 	 if(workspaceVault.RELATIONSHIP_REFERENCE_DOCUMENT.equalsIgnoreCase(relName)){
        		 defaultRelWDoc = workspaceVault.RELATIONSHIP_REFERENCE_DOCUMENT;
        	 }else{
            defaultRelWDoc = workspaceVault.RELATIONSHIP_TASK_DELIVERABLE;
         }
		 }

         //set relationship to Document object according to the DocumentHolder object type
         workspaceVault.setContentRelationshipType(defaultRelWDoc);

         //get items added
         StringList busSelects = new StringList();
         busSelects.add(dmObj.SELECT_ID);
         busSelects.add("current.access[toconnect]");
         MapList documentList = null;
         documentList = workspaceVault.getItems(context, busSelects, null, null, null);
         //copy all of objectIds - docIds- into a string arrary to be processed further
         //the ids aren't already connected to the folder, bug 260072
         StringList slNewDocIds = new StringList();

         for(int j=0; j < idsCount; j++){
           boolean hasId = false;

           for(int i = 0; i < documentList.size(); i++){
             Map map = (Map) documentList.get(i);
             String docId = (String) map.get(dmObj.SELECT_ID);
             if(docId.equals((String)idsList.get(j))){
               hasId = true;
               break;
             }//ends if
           }//ends for

           //only adds item if it is not added
           if(!hasId){
			 slNewDocIds.add(idsList.get(j));
           }//ends if
         }//ends for
         request.setAttribute("newDocListForAddExisting",slNewDocIds);
         //only add Items if there are items to add
         if(slNewDocIds.size() > 0){
           //connect DocumentHolder object to Document objects given objectIds
           busSelects = new StringList();
           busSelects.add(dmObj.SELECT_ID);
           busSelects.add(dmObj.SELECT_TYPE);
           busSelects.add(dmObj.SELECT_NAME);
           busSelects.add(dmObj.SELECT_CURRENT);
           busSelects.add(dmObj.SELECT_REVISION);
           busSelects.add("current.access[toconnect]");
           //busSelects.add("current.access[changeowner]");
           busSelects.add(dmObj.SELECT_POLICY);
           
           StringList contentList = new StringList();
		   String[] docIdsArr = (String[])slNewDocIds.toArray(new String[slNewDocIds.size()]);
           MapList infoList = DomainObject.getInfo(context, docIdsArr, busSelects);
           Iterator itr = infoList.iterator();
           while(itr.hasNext())
           {
             Map infoMap = (Map) itr.next();

             String strDocumentCurrState = (String)infoMap.get(ProgramCentralConstants.SELECT_CURRENT);
             String strPolicy  = (String)infoMap.get(ProgramCentralConstants.SELECT_POLICY);
                     
             if("OBSOLETE".equalsIgnoreCase(strDocumentCurrState)) {
            	   
                    String errorMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                 			  "emxProgramCentral.Common.AddReleasedDocument", request.getHeader("Accept-Language")) + noAccessObjects.toString();
                    %>
            		 <script language="JavaScript" type="text/javascript">
                        		alert("<%=errorMsg%>");
                        		getTopWindow().window.closeWindow();
                        </script>
                	<%
                	return;
                               
               } else if(!"true".equalsIgnoreCase((String) infoMap.get("current.access[toconnect]"))) {
            	   
                   noAccessObjects.append("\\n");
	               noAccessObjects.append((String) infoMap.get(dmObj.SELECT_TYPE));
	               noAccessObjects.append(" ");
	               noAccessObjects.append((String) infoMap.get(dmObj.SELECT_NAME));
	               noAccessObjects.append(" ");
	               noAccessObjects.append((String) infoMap.get(dmObj.SELECT_REVISION));
              } else if("Version".equalsIgnoreCase(strPolicy)) {
            	  String errorMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
             			  "emxProgramCentral.Folders.AddToSelect.selectOnlyDocument", request.getHeader("Accept-Language")) + noAccessObjects.toString();
                %>
        		 <script language="JavaScript" type="text/javascript">
                    		alert("<%=errorMsg%>");
                    		getTopWindow().window.closeWindow();
                    </script>
            	<%
            	return;
            	  
              } else {
               contentList.addElement((String) infoMap.get(dmObj.SELECT_ID));
              }
           }
           
           int contentListsize = contentList.size();
		   Map connectionMap = new HashMap(contentListsize);
           if(contentListsize > 0)
           {
              String[] contentidsArray = new String[contentListsize];
              for (int cnt =0; cnt < contentListsize; cnt ++ )
              {
                contentidsArray[cnt] = (String) contentList.elementAt(cnt);
              }
             
              //ProgramCentralUtil.pushUserContext(context);
              connectionMap = DomainRelationship.connect(context,
                      workspaceVault,
                      defaultRelWDoc,
                      true,        // from this object
                      contentidsArray);
    		  //ProgramCentralUtil.popUserContext(context);
           }
		   session.setAttribute("connectionMap", connectionMap);
         }
         //commit transaction
         ContextUtil.commitTransaction(context);
         
         if(noAccessObjects.length() > 0)
         {
           String errorMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
     			  "emxProgramCentral.Content.ConnectErrorMessage", request.getHeader("Accept-Language")) + noAccessObjects.toString();
           %>
			 <script language="JavaScript" type="text/javascript">
            		alert("<%=errorMsg%>");
            		window.closeWindow();
             </script>
    	   <%
          // session.setAttribute("error.message", errorMsg);          
         }
      }
      catch (Exception e)
      {
         //abort transaction
         ContextUtil.abortTransaction(context);
         //   session.setAttribute("error.message", e.getMessage());         
         //throw e;
      }
   }// end if
   session.removeAttribute("error.message");
%>

<html>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<script>
<%
if (!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(appProcessPage))
{
    appProcessPage = "../" + appDir + "/" + appProcessPage;
	  String isrefDoc = "false";
    if(workspaceVault.RELATIONSHIP_REFERENCE_DOCUMENT.equalsIgnoreCase(relName)){
    	isrefDoc = "true";
    }
%>//XSSOK
    <jsp:forward page="<%=appProcessPage%>" >
    <jsp:param name ="parentOID" value ="<%=XSSUtil.encodeForURL(context,currentObjectId)%>" />
    <jsp:param name ="actionMode" value ="<%=XSSUtil.encodeForURL(context,actionMode)%>" />
    <jsp:param name ="isReferenceDocument" value ="<%=XSSUtil.encodeForURL(context,isrefDoc)%>" />
    </jsp:forward>
<%
} else if (idsCount == 0) {
	String strErrorMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			  "emxProgramCentral.Common.SelectItem", request.getHeader("Accept-Language"));
	%>
    alert("<%=strErrorMsg%>");
<%}
else
{
%> 	    
             //Added by viru R2012
 	    // getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;//S2E  IR-069452V6R2011x  
 	    getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
 	    //End by viru R2012
	    getTopWindow().window.closeWindow();
     //closePopupWindow(getTopWindow());  
<%
}
%>  
  </script>
</html>

<%!
public ArrayList getTaskManagementTypes(Context context){
        ArrayList taskList = new ArrayList();
        try{
          //Get all subtypes of Task Management
          String types1 = MqlUtil.mqlCommand(context, "print type \"" + DomainConstants.TYPE_TASK_MANAGEMENT +
              "\" select derivative dump |"); //PRG:RG6:R213:Mql Injection:Static Mql:14-Oct-2011
          StringTokenizer tokens1 = new StringTokenizer(types1, "|");
 
          while (tokens1.hasMoreElements()) {
              taskList.add( tokens1.nextElement().toString() );
          }
        }catch(Exception e){
          //do nothing
        }
        return taskList;
}
%>
