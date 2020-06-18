<%--  emxProgramCentralContentRemove.jsp  -

   Copyright (c) 2007 Dassault Systemes, Inc.
   Copyright (c) 1992-2018 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxProgramCentralContentRemove.jsp.rca 1.12 Tue Oct 28 22:59:43 2008 przemek Experimental przemek $
--%>
<%--
Change History:
Date       Change By  Release   Bug/Functionality         Details
-----------------------------------------------------------------------------------------------------------------------------
29-Apr-09   nzf        V6R2010   373845                   Modified logic for removing and deleting document and its other type.
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.common.CommonDocument" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>


<%
  String[] oids = emxGetParameterValues(request, "emxTableRowId");
//Added:12-June-2010:ak4:R210 PRG:IR-057753V6R2011x
String objectId = (String)emxGetParameter(request, "objectId");
//End:12-June-2010:ak4:R210 PRG:IR-057753V6R2011x
String strUIType = emxGetParameter(request, "uiType");
DomainObject  domainObject = new DomainObject();
String strLanguage = request.getHeader("Accept-Language");   //PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x   

//Start
String objId = "";
  String taskId = "to[" + DomainConstants.RELATIONSHIP_TASK_DELIVERABLE + "].from.id";
  String folderId = "to[" + DomainConstants.RELATIONSHIP_VAULTED_OBJECTS_REV2 + "].from.id";
  String attachmentId = "to[" + DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT + "].from.id";
//Modified:26-Mar-2010:s2e:R209 PRG:IR-009975V6R2011
  StringList fId = new StringList();
  String valueFolderId = "";
//End:26-Mar-2010:s2e:R209 PRG:IR-009975V6R2011
  // Added:24-Apr-109:nzf:R207:PRG:Bug:373845
  String TYPE_DOCUMENTS = PropertyUtil.getSchemaProperty(context,"type_DOCUMENTS");
  //Addeded 20-Sep-2010:s2e:IR-069452V6R2011x
  String TYPE_PART = PropertyUtil.getSchemaProperty(context,"type_Part");             
  String TYPE_PRODUCTLINE = PropertyUtil.getSchemaProperty(context,"type_ProductLine");      
  String TYPE_CHANGE = PropertyUtil.getSchemaProperty(context,"type_Change");
  //End:R207:PRG:Bug:373845
//Added 13-July-2010:rg6:IR-061484V6R2011x
    String parentObjectId = (String)emxGetParameter(request, "parentOID");
    parentObjectId = XSSUtil.encodeURLForServer(context, parentObjectId);
 //End 13-July-2010:rg6:IR-061484V6R2011x
  boolean flag = true;
  String name = "";

	//End
    String partialXML = "";
	//Added:nr2:PRG:R212:26 Apr 2011:IR-106410V6R2012x     
      com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);
      
      DomainObject domObj = DomainObject.newInstance(context);
    //Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x   
    	  if(ProgramCentralUtil.isNotNullString(parentObjectId))
    	  {
    	    domObj.setId(parentObjectId);
    	  }
    	  else if(ProgramCentralUtil.isNotNullString(objectId))
    	  {
    		  domObj.setId(objectId);
    	  }
    //End Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
      if(domObj.isKindOf(context,DomainConstants.TYPE_TASK_MANAGEMENT)){
    	  workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_TASK_DELIVERABLE);
      }
      else{
    	  workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
      }
      
      StringList allDocTypes = new StringList();
      allDocTypes = workspaceVault.getContentBusinessTypes(context, true);
	 //End:nr2:PRG:R212:26 Apr 2011:IR-106410V6R2012x
    //Added 29-June-2010:rg6:IR-054295 ///Modified:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x   
	  for(int k=0;k<oids.length;k++)
   {
      //Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
    	Map mParsedRowId = ProgramCentralUtil.parseTableRowId(context,oids[k]);
    	String sTempObjectId = null;
    	String sTempParentId = null;
    	String sTempRowId = null;
    	String rowId = null;
    	if(null != mParsedRowId)
    	{
    		sTempObjectId = (String)mParsedRowId.get("objectId");
    		sTempParentId = (String)mParsedRowId.get("parentOId");
    		sTempRowId = (String)mParsedRowId.get("rowId");
    	}
       //Added 13-July-2010:rg6:IR-061484V6R2011x
       //when document(whcih is connected to more than one parent) is removed by going
        //inside the folder the emxtablerow id is coming with only
       // rel-id,object id and parent id is missing resulting in null pointer exception
         String strfolderId = null;
          if(ProgramCentralUtil.isNullString(sTempParentId))
         {
        	//Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
        	if(ProgramCentralUtil.isNotNullString(parentObjectId))
        	{
        	    strfolderId = parentObjectId;
        	}
         }
         else
         {
        	 strfolderId = sTempParentId; 
         }
         
        if(ProgramCentralUtil.isNotNullString(sTempObjectId))
        {
        	String docId = sTempObjectId;
        	DomainObject dmoObject = DomainObject.newInstance(context,docId);
        	StringList selectableList = new StringList(3);
        	selectableList.add(DomainConstants.SELECT_TYPE);
        	selectableList.add(DomainConstants.SELECT_CURRENT);

        	Map objectInfo = dmoObject.getInfo(context,selectableList);
        	String strType = (String)objectInfo.get(DomainConstants.SELECT_TYPE);
			
      //START:16/5/2013:Added for IR-225742V6R2014x 
         String documentId [] = ComponentsUIUtil.stringToArray(docId, ",");
          StringBuffer sbSelRtId   = new StringBuffer("from[");
           sbSelRtId.append(DomainObject.RELATIONSHIP_OBJECT_ROUTE);
           sbSelRtId.append("].to.id");
           StringList  selDocumentList   = new StringList();
           selDocumentList.add(sbSelRtId.toString());  
           DomainConstants.MULTI_VALUE_LIST.add(sbSelRtId.toString());  
           MapList accessMapList = DomainObject.getInfo(context,documentId,selDocumentList); 
           DomainConstants.MULTI_VALUE_LIST.remove(sbSelRtId.toString());  
           Iterator accessMapItr = accessMapList.iterator();
           while(accessMapItr.hasNext())
           {        
               Map accessMap          = (Map)accessMapItr.next();            
               StringList   docRouteIdList  = (StringList)accessMap.get(sbSelRtId.toString());
               if(docRouteIdList !=null){
               boolean returnValue = true;
               Map methodMap = new HashMap(1);
               methodMap.put("routeIdList",docRouteIdList);              
               String[] methodArgs = JPO.packArgs(methodMap);
               //JPO Invoke
               Boolean returnVal  = (Boolean) JPO.invoke(context,
                                                "emxProjectFolder", 
                                                null,
                                                "isContentWithRouteScope", 
                                                 methodArgs,
                                                 Boolean.class);
               if(returnVal.booleanValue()){                 
                   String strError = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.ContentSummary.AlertCannotRemoveContent",strLanguage);                                        
                   %>                   
                  <script language="javascript" type="text/javaScript">
                   alert("<%=XSSUtil.encodeForJavaScript(context,strError)%>");
                   window.closeWindow();
                   </script>
                   <%return;
               }
              }
           }
         //END:16/5/2013:Added for IR-225742V6R2014x 
      //Modified 20-Sep-2010:s2e:IR-069452V6R2011x
      //Modified:nr2:PRG:R212:26 Apr 2011:IR-106410V6R2012x 
       if(!allDocTypes.contains(strType))
      {
    	   String sErrMsg = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.Folders.AddToSelect.selectOnlyDocument",strLanguage);
          %>
             
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="matrix.db.JPO"%><script language="JavaScript" type="text/javascript">
                                          alert("<%=sErrMsg%>");
                                          window.closeWindow();
                                      </script>
          <%return;
      }
      //[Added::Feb 21, 2011:MS9:2012:IR-054191::Start]
      //Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
             rowId = sTempRowId;
    }
         
       //End 13-July-2010:rg6:IR-061484V6R2011x
         domainObject.setId(strfolderId);
        	if(ProgramCentralUtil.isNotNullString(strfolderId))
        	{
             // if controlled folder is in release state can't perform create new subfolder
             // or delete the subfolder inside the controlled folder or parent folder itself
             if(domainObject.isKindOf(context, DomainConstants.TYPE_CONTROLLED_FOLDER)){
                String strControlledFolderCurrState = domainObject.getInfo(context,DomainConstants.SELECT_CURRENT);
                if("release".equalsIgnoreCase(strControlledFolderCurrState)){
                    //display error message if operation is create
                   String sErrMsg = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.Common.InvalidOperation",strLanguage);
   %>
                     <script language="JavaScript" type="text/javascript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                        window.closeWindow();
                   </script>
    <%
                    return;
                    }
                }
             }

            if(ProgramCentralUtil.isNotNullString(rowId))
            {
            	 //Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:End
                partialXML += "<item id=\"" + rowId + "\" />";
                //[Added::Feb 21, 2011:MS9:2012:IR-054191::End
                //End 20-Sep-2010:s2e:IR-069452V6R2011x
            }
       }
    //End 29-June-2010:rg6:IR-054295
    boolean isOperationSuccessful = true;   //Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
  try
  {
	    //Added:PRG:RG6:R212:24-Jun-2011:IR-110390V6R2012x:save original oids(emxtablerowids) to an array
	    String[] sArEmxTableRowIds =  oids;
	  //Added:PRG:RG6:R212:24-Jun-2011:IR-110390V6R2012x:save original oids(emxtablerowids) to an array:End
    //get document Id
    Map objectMap = com.matrixone.apps.framework.ui.UIUtil.parseRelAndObjectIds(context, oids, false);
    oids = (String[])objectMap.get("objectIds");
    String[] relIds = (String[])objectMap.get("relIds");
//Start
	if(ProjectSpace.isEPMInstalled(context))
	{
			 DomainObject deliverableObj = DomainObject.newInstance(context);
    StringList relationshipIds = new StringList();
    int count = 0;
    for (int i=0;i<oids.length;i++)
    {
      objId = oids[i];
      deliverableObj.setId(objId);

      if(deliverableObj.isKindOf(context,DomainConstants.TYPE_IC_DOCUMENT) || deliverableObj.isKindOf(context,DomainConstants.TYPE_IC_FOLDER))
      {
        StringList objSelects = new StringList(3);
        DomainObject.MULTI_VALUE_LIST.add(taskId);
        objSelects.add(taskId);
        objSelects.add("current.access[delete]");
        objSelects.add("attribute["+DomainConstants.ATTRIBUTE_TITLE +"]");
        Map sMap = deliverableObj.getInfo(context,objSelects);
        StringList taskMap = (StringList)sMap.get(taskId);
        String access = (String)sMap.get("current.access[delete]");
        if(access != null && "TRUE".equalsIgnoreCase(access))
        {
          if(taskMap != null && taskMap.size() >1)
          {

             DomainRelationship.disconnect(context, relIds[i]);
          }
          else
          {
              deliverableObj.deleteObject(context, true);
          }
        }
        else
        {
            flag = false;
            name = name.concat(" ").concat((String)sMap.get("attribute["+DomainConstants.ATTRIBUTE_TITLE +"]"));
        }
      }
      else
      {
        relationshipIds.add(relIds[i]);
        count++;
      }
    }
     if(!flag)
    {
%>

<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%><script language="javascript" type="text/javaScript">//<![CDATA[
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.UnableToDeleteICObjects</framework:i18nScript>\n\n<%=name%>");
        // Stop hiding here -->//]]>
    </script>
<%
       }
    String[] relIdsArray = new String[count];
    relationshipIds.toArray(relIdsArray);

    //Delete the active document
    com.matrixone.apps.common.CommonDocument.removeDocuments(context, relIdsArray, true);
}
//End
	else
	{
		//Delete the active document
		//com.matrixone.apps.common.CommonDocument.removeDocuments(context, relIds, true);
		DomainObject delObj = DomainObject.newInstance(context);
		DomainObject dParentObject = DomainObject.newInstance(context);
		StringList deleteIds = new StringList();
		StringList disconnectIds = new StringList();
		final String SELECT_ATTRIBUTE_TITLE = "attribute["+com.matrixone.apps.common.CommonDocument.ATTRIBUTE_TITLE+"]";
		StringList slBusSelect = new StringList();
		slBusSelect.add (taskId);
		slBusSelect.add (folderId);
		slBusSelect.add (attachmentId);
		slBusSelect.add ("current.access[delete]");
		slBusSelect.add ("current.access[fromdisconnect]"); //Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
		slBusSelect.add (CommonDocument.SELECT_ACTIVE_FILE_LOCKED);
		// Added:24-Apr-109:nzf:R207:PRG:Bug:373845
		slBusSelect.add (DomainConstants.SELECT_TYPE);
		slBusSelect.add (DomainConstants.SELECT_NAME);   //Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
		// End:R207:PRG:Bug:373845

		// Added:15-DEC-2010:rg6:R211:PRG:IR-054060V6R2012
		slBusSelect.add (com.matrixone.apps.common.CommonDocument.SELECT_IS_VERSION_OBJECT);
		slBusSelect.add (SELECT_ATTRIBUTE_TITLE);
		//End Added:15-DEC-2010:rg6:R211:PRG:IR-054060V6R2012
		Map objectInfo = null;
		//Added:PRG:RG6:R212:24-Jun-2011:IR-110390V6R2012x:start
	    StringList slParentSelectables = new StringList();
	    String sSelectFromDisconnectAccess = "current.access[fromdisconnect]"; 
	    slParentSelectables.add(sSelectFromDisconnectAccess);
	  //Added:PRG:RG6:R212:24-Jun-2011:IR-110390V6R2012x:End
		int vplmCount = 0;
		String strObjectType = "";
	    StringList slDisconnectObjList = new StringList();  //Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
		for (int j=0;j<oids.length;j++)
		{
			objId = oids[j];
			delObj.setId(objId);
			//Modified:PRG:RG6:R212:24-Jun-2011:IR-110390V6R2012x:logic for checking that if parent(folder) has from disconnect access
		    String strDocObjId =  sArEmxTableRowIds[j];
		    Map mParsedObjIds = ProgramCentralUtil.parseTableRowId(context,strDocObjId);
		    String sParsedObjId = (String)mParsedObjIds.get("objectId");
		    String sParentObjId = (String)mParsedObjIds.get("parentOId");  //parent of the document object
            if(null == sParentObjId && "table".equalsIgnoreCase(strUIType)){
                sParentObjId = parentObjectId;
            }
            boolean hasFromDisConnectAccess = false;
		    if(objId.contains(sParsedObjId))
		    {
		    	if(ProgramCentralUtil.isNotNullString(sParentObjId))
		    	{
		    		dParentObject.setId(sParentObjId);
		    		Map mParentInfo = dParentObject.getInfo(context,slParentSelectables);
		    		String sFromDisConnectAccess = (String)mParentInfo.get(sSelectFromDisconnectAccess);
		    		hasFromDisConnectAccess = "true".equalsIgnoreCase(sFromDisConnectAccess);
		    	}
		    }
		  //Modified:PRG:RG6:R212:24-Jun-2011:IR-110390V6R2012x:End

			objectInfo = delObj.getInfo (context, slBusSelect);
			//Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
			boolean hasDeleteAccess = "true".equalsIgnoreCase((String)objectInfo.get("current.access[delete]"));
			String sObjName =  (String)objectInfo.get(DomainConstants.SELECT_NAME);

			if(!hasFromDisConnectAccess)
			{
				slDisconnectObjList.add(sObjName);
			}
			//End Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
			// Added:24-Apr-109:nzf:R207:PRG:Bug:373845
			boolean isItADocumentObject = false;
           //Added:14-Oct-2011:I16:R213:PRG:IR-133970V6R2013 Merge From 2012
            boolean isDocumentObject = false;
            isDocumentObject    =   delObj.isKindOf(context, DomainConstants.TYPE_DOCUMENT);
            //End:14-Oct-2011:I16:R213:PRG:IR-133970V6R2013 Merge From 2012
			strObjectType = (String)objectInfo.get(DomainConstants.SELECT_TYPE);

			isItADocumentObject = delObj.isKindOf(context,TYPE_DOCUMENTS);
			// End:R207:PRG:Bug:373845

			// Added:15-DEC-2010:rg6:R211:PRG:IR-054060V6R2012
			String isVersionObject = (String)objectInfo.get(com.matrixone.apps.common.CommonDocument.SELECT_IS_VERSION_OBJECT);
            if(isVersionObject != null && "true".equalsIgnoreCase(isVersionObject) && isDocumentObject){ //Modified:14-Oct-2011:I16:R213:PRG:IR-133970V6R2013 Merge From 2012
			      String strAttribTitle = (String)objectInfo.get(SELECT_ATTRIBUTE_TITLE);
			      strAttribTitle = (strAttribTitle == null )? "" : strAttribTitle;

			      String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
						  "emxProgramCentral.Common.CantRemoveSelectedObject", strLanguage);
			      sErrMsg = "( "+strAttribTitle+" ) " + sErrMsg;
		          %>
    		     <script language="JavaScript" type="text/javascript">
		                                          alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
		                                          window.closeWindow();
		                                      </script>
		          <%return;
			}
		      	 						
			
			StringList isfileLocked = (StringList)objectInfo.get("from[Active Version].to.locked");				
			if (isfileLocked!= null && isfileLocked.contains("TRUE")){
					
		         	String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
							  "emxProgramCentral.Folders.CantRemoveSelectedObjectWithLockedFile", strLanguage);
				    %>
	    		      <script language="JavaScript" type="text/javascript">
			                                          alert("<%=sErrMsg%>");
			                                          window.closeWindow();
			                                      </script>
			          <%return;
			}
			
			// End Added:15-DEC-2010:rg6:R211:PRG:IR-054060V6R2012

			//Check if there is indeed a RELATIONSHIP_TASK_DELIVERABLE connection to the object
			String parentTaskId = (String)objectInfo.get(taskId);
			if (parentTaskId == null)
			{
			    Object objValue = objectInfo.get(folderId);

				//Check if this is a folder or the object is an attachment
				boolean parentFolderPresent = false;
				if (objValue instanceof StringList) {
				    StringList slTemp = (StringList)objValue;
                  //Modified:26-Mar-2010:s2e:R209 PRG:IR-009975V6R2011
                    fId = slTemp;
                    for(int i=0; i<fId.size();i++){
                        valueFolderId = (String)fId.get(i);
                    }
                  //End:26-Mar-2010:s2e:R209 PRG:IR-009975V6R2011
				    if (slTemp.size() != 0)
				    {
				        parentFolderPresent = true;
				    }
				}
				else if (objValue instanceof String) {
				    parentFolderPresent = true;
				}

				boolean attachmentParentPresent = false;
				objValue = objectInfo.get(attachmentId);
				if (objValue instanceof StringList) {
				    StringList slTemp = (StringList)objValue;
				    if (slTemp.size() != 0)
				    {
				        attachmentParentPresent = true;
				    }
				}
				else if (objValue instanceof String) {
				    attachmentParentPresent = true;
				}
				 //Modified:12-June-2010:ak4:R210 PRG:IR-057753V6R2011x
				 //if (parentFolderPresent && attachmentParentPresent)
				 if (!parentFolderPresent && !attachmentParentPresent)
				 //End:12-June-2010:ak4:R210 PRG:IR-057753V6R2011x
				{
					vplmCount++;
				}
				else
			   {
				    // Modified:24-Apr-109:nzf:R207:PRG:Bug:373845
					if (hasDeleteAccess && isItADocumentObject)
					{// End:R207:PRG:Bug:373845
					    deleteIds.add(relIds[j]);
					}
					else
					{
					    disconnectIds.add(relIds[j]);
					}
				}
			}
			else
			{
				//  Modified:24-Apr-109:nzf:R207:PRG:Bug:373845
				if (hasDeleteAccess && isItADocumentObject)
				{// End:R207:PRG:Bug:373845
				    deleteIds.add(relIds[j]);
				}
				else
				{
				    disconnectIds.add(relIds[j]);
				}
			}
		}

		StringBuffer strDeleteNames = new StringBuffer();
		StringBuffer strRemoveNames = new StringBuffer();
		StringBuffer strDeleteRemoveMsg = new StringBuffer();

		// Disconnect real deliverables
		if (disconnectIds.size() > 0)
		{
		//Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x any one of the object do not have from fromdisconnect access then show error message
			if(slDisconnectObjList.size() > 0)
			{
				String sErrMsg = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.Folders.ContentRemove.NoFromDisconnectAccess", strLanguage);
				  %>
				  <script language="javascript" type="text/javaScript">
				  var sErrorMsg = '<%=sErrMsg+slDisconnectObjList.toString()%>' ;
                    alert(sErrorMsg);
                </script>
				  <%
				  return ;
			}
			//End Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
			String[] idsArray = new String[disconnectIds.size()];
			disconnectIds.toArray(idsArray);
			
            MapList nameList =  DomainRelationship.getInfo(context, idsArray,
                    new StringList(DomainConstants.SELECT_TO_NAME));

            int nameListSize = 0;
            if (nameList != null)
            {
                nameListSize = nameList.size();
            }

            Map objectNameMap = null;
            for (int i = 0; i < nameListSize; i++)
            {
                objectNameMap = (Map) nameList.get(i);
                String objectName = (String) objectNameMap.get(DomainConstants.SELECT_TO_NAME);
                strRemoveNames.append(objectName + "\\n");
            }            
            
    		com.matrixone.apps.common.CommonDocument.removeDocuments(context, idsArray, false);
    	}

		// Delete real deliverables

		if (deleteIds.size() > 0)
		{
			String[] idsArray = new String[deleteIds.size()];
    		deleteIds.toArray(idsArray);

            StringList selectList = new StringList(2);
            selectList.add(DomainConstants.SELECT_TO_NAME);
            selectList.add(DomainConstants.SELECT_TO_ID);
			selectList.add(DomainConstants.SELECT_ID);
			selectList.add("to.current");
            MapList mapList = DomainRelationship.getInfo(context, idsArray, selectList);
			StringList disconnectIDs = new StringList();

            ContextUtil.pushContext(context);

            try
            {
                Iterator itr = mapList.iterator();
                while (itr.hasNext())
                {
                    Map map = (Map) itr.next();
                    String id = (String) map.get(DomainConstants.SELECT_TO_ID);
			        String relID = (String) map.get(DomainConstants.SELECT_ID);
                    String objectName = (String) map.get(DomainConstants.SELECT_TO_NAME);
			        String strState = (String) map.get("to.current");
                    String output = "";

                    output = MqlUtil.mqlCommand(context, "expand bus $1 terse to limit $2 dump",id,"2");

                    if (output.indexOf("\n") != -1 || output.equals(""))
                    {
                        // contains references; add to disconnect list
                        strRemoveNames.append(objectName + "\\n");
                    }                        
                    else
                    {
		          if("Released".equalsIgnoreCase(strState) || "Frozen".equalsIgnoreCase(strState)){
			        	  strRemoveNames.append(objectName + "\\n");
			        	  deleteIds.remove(relID);
			        	  disconnectIDs.add(relID);
			          }else
                        // add to delete list
                        strDeleteNames.append(objectName + "\\n");
                    }
                }
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                ContextUtil.popContext(context);
            }

			if(disconnectIDs.size() > 0){
				String[] disconnectArray = new String[disconnectIDs.size()];
				disconnectIDs.toArray(disconnectArray);
				com.matrixone.apps.common.CommonDocument.removeDocuments(context, disconnectArray, false);
			}
		if(deleteIds.size() >0) {
			String[] finalIdlistToDelete = new String[deleteIds.size()];
			deleteIds.toArray(finalIdlistToDelete);
			com.matrixone.apps.common.CommonDocument.removeDocuments(context, finalIdlistToDelete, true);
		}
    	}

		String sErrMsg = "";
		if (strDeleteNames.length() > 0)
		{
			sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
					  "emxProgramCentral.Common.ObjectsDisconnectedFromFolder", strLanguage);
			strDeleteRemoveMsg.append(sErrMsg + "\\n" + strDeleteNames + "\\n");
		}
		
		if (strRemoveNames.length() > 0)
		{
			sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
					  "emxProgramCentral.Common.ObjectsDisconnectedFromFolder", strLanguage);
			strDeleteRemoveMsg.append(sErrMsg + "\\n" + strRemoveNames + "\\n");
		}
	
		if (strDeleteRemoveMsg.length() > 0)
		{
%>
	        <script language="JavaScript" type="text/javascript">
	        <%-- XSSOK--%>
                    alert("<%=strDeleteRemoveMsg%>");
                     var listDisplayFrame = getTopWindow().findFrame(getTopWindow(), "listDisplay");
                     if(listDisplayFrame != null)
		     			listDisplayFrame.getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort();
/*                      var frameContent1 = getTopWindow().findFrame(getTopWindow(),"detailsDisplay");
                     if(frameContent1 != null)
		     			frameContent1.refreshStructureWithOutSort();     */                         
            </script>
<%
		}

		if (vplmCount > 0)
		{
			//MqlUtil.mqlCommand(context, "notice \"" + "Deliverables from corresponding VPLM Action cannot be removed from PMC" + "\"");
%>
    			<script language="javascript" type="text/javaScript">//<![CDATA[
        			alert("<framework:i18nScript localize="i18nId">emxProgramCentral.VPLM.MSG_DelActionOutput</framework:i18nScript>\n\n<%=XSSUtil.encodeForJavaScript(context,name)%>");
        			// Stop hiding here -->//]]>
    			</script>
<%

		}
	 }
  }
  catch (Exception ex)
  {
	 //Start
	  if(ProjectSpace.isEPMInstalled(context))
	{
		String exceptionMessage = ex.toString();
    if(exceptionMessage!=null)
        {
            session.setAttribute("error.message" , EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
      			  "emxProgramCentral.Deliverable.DeleteObjectFailureNotice", request.getHeader("Accept-Language")));
        }
	}
	//End
	else
	  {
      session.setAttribute("error.message" , ex.toString());
	  }
	 
	  isOperationSuccessful = false;
  }

//[Added::Feb 21, 2011:MS9:2012:IR-054191::Start]
String xmlMessage = "<mxRoot>";
String message = "";
xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
xmlMessage += partialXML;
xmlMessage += "<message><![CDATA[" + message + "]]></message>";
xmlMessage += "</mxRoot>";
//[Added::Feb 21, 2011:MS9:2012:IR-054191::End]
if(strUIType.equals("structureBrowser"))
{
	//Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
	if(isOperationSuccessful) // if any exception is thrown do not remove the items from the S.B.
	{
%>
         <script language="JavaScript">
         <%-- XSSOK--%>
                  window.parent.removedeletedRows('<%= xmlMessage %>');
                  window.parent.getTopWindow().RefreshHeader();
                  
	       </script>
<%
	}

//End Added:PRG:RG6:R212:1-Jun-2011:IR-111810V6R2012x
}
else if (strUIType.equals("table"))
{
	%>
	<script  language="JavaScript">
  var fIdvalue = "<%=XSSUtil.encodeForJavaScript(context,valueFolderId)%>";
  var url = "../common/emxTable.jsp?program=emxCommonDocumentUI%3AgetDocuments&table=APPDocumentSummary&selection=multiple&sortColumnName=Name&sortDirection=ascending&toolbar=PMCContentSummaryToolBar&header=emxProgramCentral.Common.ContentWithName&HelpMarker=emxhelpcontentsummary&parentRelName=relationship_VaultedDocumentsRev2&emxSuiteDirectory=programcentral&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&"+"objectId="+fIdvalue;
  //Added:21-July-2010:ak4:ECH:BUG:R210:056358
   window.parent.location.href = window.parent.location.href ;
  // frameContent.document.location.href = url;
  //End:21-July-2010:ak4:ECH:BUG:R210:056358
  <%
}
%>
//End:26-Mar-2010:s2e:R209 PRG:IR-009975V6R2011
</script>

