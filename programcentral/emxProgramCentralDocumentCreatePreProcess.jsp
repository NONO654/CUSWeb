<%--
<%--
  emxProgramCentralDocumentCreatePreProcess.jsp
  This JSP gathers the object Id, and parent relation name of the  folder for the processing
  of Create new Document from the RMB.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  static const char RCSID[] = $Id: emxProgramCentralDocumentCreatePreProcess.jsp.rca 1.3.1.1.3.4 Thus 3 15:49:37 2010 przemek Experimental przemek $
  Name: emxProgramCentralDocumentCreatePreProcess.jsp
--%>
<%@page import="com.matrixone.apps.common.UserTask"%>
<%@include file="emxProgramGlobals2.inc" %>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%

  String objectId    = emxGetParameter(request,"objectId");
  String mode = emxGetParameter(request, "mode");
  String sDocumentAction = emxGetParameter(request,"documentAction"); // action to execute
  String strLanguage = request.getHeader("Accept-Language");
  	StringBuffer contentURL = new StringBuffer();
	String isWrongAction = "false"; // if object type and action mis-match
	String isProjectTemplate = "false";
	String isTaskType = "false";
	String isParentKindOFProjectTemplate = "false";
	boolean isTaskOperation = "referenceDocument".equalsIgnoreCase(mode)||"taskDeliverable".equalsIgnoreCase(mode);

	if (isTaskOperation) {
		 DomainObject dmObj = DomainObject.newInstance(context,objectId);
         StringList list = new StringList();
         list.add(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
         list.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
         list.add("to[Project Access Key].from.from[Project Access List].to.type.kindof[" + DomainObject.TYPE_PROJECT_TEMPLATE+ "]");
         
         Map<String,String> objectInfo = dmObj.getInfo(context,list);
          isTaskType = objectInfo.get(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
          isProjectTemplate = objectInfo.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
          isParentKindOFProjectTemplate = objectInfo.get("to[Project Access Key].from.from[Project Access List].to.type.kindof[" + DomainObject.TYPE_PROJECT_TEMPLATE+ "]");
        
	}
	
	
	if ("workspaceVault".equalsIgnoreCase(mode)||(ProgramCentralUtil.isNotNullString(sDocumentAction)&&!isTaskOperation)) {

  String[] strFolders = emxGetParameterValues(request,"emxTableRowId");
    //String isFromRMB=emxGetParameter(request,"isFromRMB");  // check if request is from RMB
    String sUIType=emxGetParameter(request,"uiType");
  StringList slFolderTokens = new StringList();
  String strFolderId = null;   // actual folder id
  	String parentFolderId = null;
  String strFolderRelId = null;
  
	if(strFolders !=null){  //Modified 16-June-2010:rg6:PRG:IR-058080V6R2011x
        for (int i = 0; i < strFolders.length; i++)
        {
         //Added:PRG:RG6:R212:6-May-2011 : // document creation validation was getting failed modified by changing split method to split string
		 	//============
				Map rowIDList = ProgramCentralUtil.parseTableRowId(context, strFolders[i]);
				
				String parentOId = (String) rowIDList.get("parentOId");
				if (ProgramCentralUtil.isNullString(parentOId)) {
					parentOId = (String) rowIDList.get("objectId");
					parentFolderId = parentOId;
				}else{
					parentFolderId = parentOId;
				}

				DomainObject projObject = DomainObject.newInstance(context, parentFolderId);
				//==================
        	slFolderTokens = FrameworkUtil.splitString(strFolders[i], "|"); 
            strFolderId = (String) slFolderTokens .get(1);
         //End Added:PRG:RG6:R212:6-May-2011 : // document creation validation was getting failed modified by changing split method to split string
        }
			}else{
			String parentOId = objectId;
			DomainObject projObject = DomainObject.newInstance(context, parentOId);
			if (projObject.isKindOf(context, DomainConstants.TYPE_WORKSPACE_VAULT)) {
			parentFolderId = UserTask.getProjectId(context, parentOId);
			}else{
				parentFolderId = objectId;
			}
    }
	
	//Added 6-July-2010:rg6:IR-058924
    Map map =request.getParameterMap();
    String [] selctedObjList = (String [])map.get("emxTableRowId");
    
		//Added 15-July-2010:rg6:IR-063840V6R2011x
		// As content page for folder click is changed from flat table to structure browser modified
		// for passing the object id.
		DomainObject dObjParent = DomainObject.newInstance(context);
		if (strFolders == null && objectId != null && !"".equalsIgnoreCase(objectId)) {
			dObjParent.setId(objectId);
			if (dObjParent.isKindOf(context, DomainConstants.TYPE_WORKSPACE_VAULT)) {
				strFolderId = objectId;
			}
		}
		//End 15-July-2010:rg6:IR-063840V6R2011x

		if (selctedObjList != null || strFolderId != null) {
			if (selctedObjList != null && selctedObjList.length > 1) {
            String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
      			  "emxProgramCentral.Common.CannotPerformAction", strLanguage);
               %>
                         
         
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%><script language="JavaScript" type="text/javascript">
                                               alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
             if(getTopWindow().closeSlideInDialog)
             {
          	   getTopWindow().closeSlideInDialog();//Added:PRG:RG6:R212:10 May 2011:IR-098164V6R2012x
             }
             else
             {
                                               window.closeWindow();
             }
                                           </script>
               <%return;     
       }
//Added:PRG:I16:22-Aug-2011:R212:IR-090418V6R2012x Start           
 else{    	   
			String folderId = "";

				if (selctedObjList != null) {
    	   Map mpTableRow = ProgramCentralUtil.parseTableRowId(context, selctedObjList[0]);          
           folderId = (String)mpTableRow.get("objectId");
		   	} else {
					folderId = strFolderId;
				}
           DomainObject dObj = DomainObject.newInstance(context, folderId);
           if(dObj.isKindOf(context, DomainConstants.TYPE_WORKSPACE_VAULT))//Added:PRG:I16:R213:14-Dec-2011:IR-141928V6R2013 Check added if only workspace vault object
           {
           String sErrConMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
     			  "emxProgramCentral.Folder.NoFromConnectAccess", strLanguage);          
           String strUserName = context.getUser();
           boolean bAddStatus = true;
           boolean bAddRemoveStatus = true;
           boolean hasFromConnectAccess = dObj.checkAccess(context, (short)AccessConstants.cFromConnect);
           bAddStatus = PMCWorkspaceVault.hasAccessOnWorkspaceVault(context, folderId, ProgramCentralConstants.VAULT_ACCESS_ADD, strUserName);
           if(!bAddStatus)               
                 bAddRemoveStatus = PMCWorkspaceVault.hasAccessOnWorkspaceVault(context, folderId, ProgramCentralConstants.VAULT_ACCESS_ADD_REMOVE, strUserName);           
           if(!(bAddStatus || bAddRemoveStatus) || (("create".equalsIgnoreCase(sDocumentAction)||"upload".equalsIgnoreCase(sDocumentAction)) && !hasFromConnectAccess)){
           %>
                       <script language="JavaScript" type="text/javascript">
                          alert("<%=XSSUtil.encodeForJavaScript(context,sErrConMsg)%>");
                          try{
                          getTopWindow().closeSlideInDialog(); //Added:PRG:I16:R213:14-Dec-2011:IR-141928V6R2013 if Bookmark
                          }catch(e){
                          window.closeWindow();
                          }
                          
                        </script> 
       <% return; 
          }
        }
       }
      //Added:PRG:I16:22-Aug-2011:R212:IR-090418V6R2012x End
    }
  //End 6-July-2010:rg6:IR-058924
//Modified:nr2:PRG:R212:7-Apr-2011:IR-097451V6R2012:Start
    if(ProgramCentralUtil.isNotNullString(strFolderId)){
    	
        objectId=strFolderId;
			DomainObject parentDomainObject = DomainObject.newInstance(context, parentFolderId);
			StringList list = new StringList();
			list.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);

			Map<String, String> objectInfo = parentDomainObject.getInfo(context, list);
			 isProjectTemplate = objectInfo.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);

        DomainObject domainObject = DomainObject.newInstance(context,objectId);
        if (domainObject.isKindOf(context,DomainConstants.TYPE_WORKSPACE_VAULT)||domainObject.isKindOf(context,DomainConstants.TYPE_CONTROLLED_FOLDER))
        {
          if(sDocumentAction !=null && "create".equalsIgnoreCase(sDocumentAction)){
           //PRG:RG6:R212:22-July-2011:IR-105542V6R2012x::Start
        	  //contentURL.append("../components/emxCommonDocumentPreCheckin.jsp?objectAction=create&showAccessType=true&appDir=programcentral&appProcessPage=emxProgramCentraFolderUtil.jsp&actionMode=createDocument");
           		contentURL.append("../components/emxCommonDocumentPreCheckin.jsp?objectAction=create&appDir=programcentral&appProcessPage=emxProgramCentraFolderUtil.jsp&actionMode=createDocument");
        	//PRG:RG6:R212:22-July-2011:IR-105542V6R2012x::End
           //Added 29-June-2010:rg6:IR-054295
           if(objectId!=null && !"".equalsIgnoreCase(objectId)){
               // if controlled folder is in release state can't perform create new subfolder 
               // or delete the subfolder inside the controlled folder or parent folder itself  
               if(domainObject.isKindOf(context, DomainConstants.TYPE_CONTROLLED_FOLDER)){
                  String strControlledFolderCurrState = domainObject.getInfo(context,DomainConstants.SELECT_CURRENT);
                  if("release".equalsIgnoreCase(strControlledFolderCurrState)){
                      //display error message if operation is create 
                     String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
               			  "emxProgramCentral.Common.InvalidOperation", strLanguage);
     %>
                     <script language="JavaScript" type="text/javascript">
                          alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                        //Added:PRG:RG6:R212:11-May-2011:Folders
                          if(getTopWindow().closeSlideInDialog)
                          {
                              getTopWindow().closeSlideInDialog();
                          }
                          else
                          {
                              window.closeWindow();
                          }
                          //End Added:PRG:RG6:R212:11-May-2011:Folders
                     </script>
      <%
                      return;     
                      }
                  }
               }
           //End 29-June-2010:rg6:IR-054295
          }else{
        	  if(sDocumentAction !=null && "upload".equalsIgnoreCase(sDocumentAction)){
        		  contentURL.append("../components/emxCommonDocumentPreCheckin.jsp?objectAction=createMasterPerFile&appDir=programcentral&appProcessPage=emxProgramCentraFolderUtil.jsp&actionMode=uploadFiles");
        	  }else if(sDocumentAction !=null && "Bookmark".equalsIgnoreCase(sDocumentAction)){  //Added 12-Aug-2010:rg6:IR-054478V6R2011x
        		  //IR-064799V6R2013x Begin
        		  if(domainObject.isKindOf(context, DomainConstants.TYPE_CONTROLLED_FOLDER)){
                      String strControlledFolderCurrState = domainObject.getInfo(context,DomainConstants.SELECT_CURRENT);
                      if(!"create".equalsIgnoreCase(strControlledFolderCurrState)){
                          //display error message if operation is create 
                         String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                   			  "emxProgramCentral.Common.InvalidOperation", strLanguage);
         %>
                         <script language="JavaScript" type="text/javascript">
                              alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                            //Added:PRG:RG6:R212:11-May-2011:Folders
                              if(getTopWindow().closeSlideInDialog)
                              {
                                  getTopWindow().closeSlideInDialog();
                              }
                              else
                              {
                                  window.closeWindow();
                              }
                              //End Added:PRG:RG6:R212:11-May-2011:Folders
                         </script>
          <%
                          return;     
                          }
                      else
                    	  contentURL.append("../common/emxCreate.jsp?type=type_URL&typeChooser=false&nameField=keyin&form=PMCBookMarkCreateForm&header=emxProgramCentral.Common.CreateBookmark&HelpMarker=emxhelpbookmarkcreatedialog&postProcessJPO=emxBookmark:connectBookmark&findMxLink=false&postProcessURL=../programcentral/emxProgramCentralDynamicInsertRow.jsp&targetLocation=slidein");
                      }else
                    	  contentURL.append("../common/emxCreate.jsp?type=type_URL&typeChooser=false&nameField=keyin&form=PMCBookMarkCreateForm&header=emxProgramCentral.Common.CreateBookmark&HelpMarker=emxhelpbookmarkcreatedialog&postProcessJPO=emxBookmark:connectBookmark&findMxLink=false&postProcessURL=../programcentral/emxProgramCentralDynamicInsertRow.jsp&targetLocation=slidein");
        		  	  //IR-064799V6R2013x end
        	  
        		  //[Added::Feb 21, 2011:MS9:2012:IR-054191::Start]
        		     //Modified PRG:RG6:R212:10-May-2011:IR-106845V6R2012x
        		  //contentURL.append("../common/emxCreate.jsp?type=type_URL&typeChooser=false&nameField=keyin&form=PMCBookMarkCreateForm&header=emxProgramCentral.Common.CreateBookmark&HelpMarker=emxhelpbookmarkcreatedialog&postProcessJPO=emxBookmark:connectBookmark&findMxLink=false&postProcessURL=../programcentral/emxProgramCentralDynamicInsertRow.jsp&targetLocation=slidein");
        		  //[Added::Feb 21, 2011:MS9:2012:IR-054191::End]
        	  }else{
        		  isWrongAction = "true";   //Added 29-June-2010:rg6:PRGRG6R210
        	  }
          }
        //Added 12-Aug-2010:rg6:IR-054478V6R2011x
          if(!"Bookmark".equalsIgnoreCase(sDocumentAction)){
           Enumeration enumParam = emxGetParameterNames(request);
           // Loop through the request elements and
           // stuff into contentURL
            while (enumParam.hasMoreElements())
           {
               String name  = (String) enumParam.nextElement();
               String value = emxGetParameter(request, name);
               if(name!=null && !("type".equalsIgnoreCase(name) || "objectId".equalsIgnoreCase(name)) )
            	    contentURL.append("&"+name+"="+value);
           }
           // append the parentRelName and  newly found object id
            contentURL.append("&parentRelName=relationship_VaultedDocumentsRev2");
            contentURL.append("&objectId="+XSSUtil.encodeForURL(context, objectId));
          }else{
        	  String strSuiteKey = emxGetParameter(request,"suiteKey"); // action to execute
        	  String strStringResource = emxGetParameter(request,"StringResourceFileId"); // action to execute
        	  String strSuiteDir = emxGetParameter(request,"SuiteDirectory"); // action to execute  
          
        	  contentURL.append("&suiteKey="+XSSUtil.encodeForURL(context, strSuiteKey));
              contentURL.append("&StringResourceFileId="+strStringResource);
              contentURL.append("&strSuiteDir="+strSuiteDir);
              contentURL.append("&parentRelName=relationship_LinkURL");
              contentURL.append("&objectId="+XSSUtil.encodeForURL(context, objectId));
          }
        //End 12-Aug-2010:rg6:IR-054478V6R2011x
		// response.sendRedirect(contentURL.toString());
       }
       else
       {
    	   //Added 16-June-2010:rg6:PRG:IR-058080V6R2011x
    	   String strIsversionObject = domainObject.getInfo(context, CommonDocument.SELECT_IS_VERSION_OBJECT);
    	   if (domainObject.isKindOf(context,CommonDocument.TYPE_DOCUMENTS) || "true".equalsIgnoreCase(strIsversionObject))
           {
    		   if(sDocumentAction !=null && "editDetails".equalsIgnoreCase(sDocumentAction)){
                   contentURL.append("../components/emxCommonDocumentEditDialogFS.jsp");
                   contentURL.append("?objectId="+XSSUtil.encodeForURL(context, objectId));
               }else{
            	   if(sDocumentAction !=null && "checkout".equalsIgnoreCase(sDocumentAction)){
            		   if("true".equalsIgnoreCase(strIsversionObject)){
            			   objectId = parentFolderId;
            		   }
            		   contentURL.append("../components/emxCommonDocumentPreCheckout.jsp?action=checkout&appDir=programcentral" +
            				   "&refresh=false&appProcessPage=emxProgramCentraFolderUtil.jsp&checkoutObjectId=" + XSSUtil.encodeForURL(context, objectId) +"&actionMode=checkout");
            	   }else{
						if(sDocumentAction !=null && "checkinFiles".equalsIgnoreCase(sDocumentAction)){
	            		   contentURL.append("../components/emxCommonDocumentPreCheckin.jsp?&showFormat=readonly&showComments=required" +
	            				   "&objectAction=update&allowFileNameChange=true&actionMode=checkin&refreshTableContent=true" +
	            		   			"&appDir=programcentral&appProcessPage=emxProgramCentraFolderUtil.jsp&actionMode=checkin");
	            	   	}else{
						    if(sDocumentAction !=null && "checkin".equalsIgnoreCase(sDocumentAction)){
						         contentURL.append("../components/emxCommonDocumentPreCheckin.jsp?objectAction=checkin&showComments=true&showFormat=true"+
		                                         "&objectAction=checkin&refreshTableContent=true"+
		                                         "&appDir=programcentral&appProcessPage=emxProgramCentraFolderUtil.jsp&actionMode=addNewFile");
							}else{
							    if(sDocumentAction !=null && "revision".equalsIgnoreCase(sDocumentAction)){
							    	contentURL.append("../common/emxTree.jsp?DefaultCategory=APPDocumentRevisions");
							     }else{
			                        if(sDocumentAction !=null && "fileVersions".equalsIgnoreCase(sDocumentAction)){
			                            contentURL.append("../common/emxTable.jsp?HelpMarker=emxhelpdocumentfileversions&program=emxProjectFolder:getVersionForFileRMB&table=APPFileVersions&sortColumnName=Version&sortDirection=descending&FilterFramePage=${COMPONENT_DIR}/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1");
			                         }else{
		                             	if(sDocumentAction !=null && "documentVersions".equalsIgnoreCase(sDocumentAction)){
		                                 	contentURL.append("../common/emxTable.jsp?program=emxProjectFolder:getVersionForFileRMB&table=APPFileVersions&disableSorting=true&HelpMarker=emxhelpdocumentfileversions&FilterFramePage=${COMPONENT_DIR}/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1");
		                              	}else{
		                            	  	isWrongAction = "true";  //Added 29-June-2010:rg6:PRGRG6R210
		                              }
			                        }
				                }
							}
	            		}
            	   }
            	   
                   Enumeration enumParam = emxGetParameterNames(request);
                   // Loop through the request elements and
                   // stuff into contentURL
                   while (enumParam.hasMoreElements())
                   {
                       String name  = (String) enumParam.nextElement();
                       String value = emxGetParameter(request, name);
                       if(name!=null && !("objectId".equalsIgnoreCase(name)) )
                       contentURL.append("&"+name+"="+value);
                   }
                 contentURL.append("&objectId="+XSSUtil.encodeForURL(context, objectId));
               }
  
          //      response.sendRedirect(contentURL.toString());
       //End 16-June-2010:rg6:PRG:IR-058080V6R2011x
           }else{
        	   isWrongAction = "true";   // [ADDED::PRG:RG6:Mar 11, 2011:IR-054476V6R2012 :R211:]
%>
        <script language="javascript">
		var errBegin = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.UIEnhancement.CreateDocument.UncommonObjs</emxUtil:i18nScript>"
		+ "\n";
alert(errBegin);
//Added:PRG:RG6:R212:11-May-2011:Folders
if (getTopWindow().closeSlideInDialog) {
	getTopWindow().closeSlideInDialog();
} else {
	window.closeWindow();
           	   }
//End Added:PRG:RG6:R212:11-May-2011:Folders
            </script> 
           	<%
	}
			}
    }else{
			isWrongAction = "true";
 %>
        <script language="javascript">

        var errBegin="<emxUtil:i18nScript localize="i18nId">emxProgramCentral.UIEnhancement.CreateDocument.UncommonObjs</emxUtil:i18nScript>"+"\n";
             alert(errBegin);
           //Added:PRG:RG6:R212:11-May-2011:Folders
             if(getTopWindow().closeSlideInDialog)
             {
                 getTopWindow().closeSlideInDialog();
             }
             else
             {
                 window.closeWindow();
             }
             //End Added:PRG:RG6:R212:11-May-2011:Folders
           </script>
<%
       }
	   	} else if ("referenceDocument".equalsIgnoreCase(mode)) {

		contentURL
				.append("../components/emxCommonDocumentPreCheckin.jsp?objectAction=create&fileRequired=false");
		Enumeration enumParam = emxGetParameterNames(request);
		// Loop through the request elements and
		// stuff into contentURL
		while (enumParam.hasMoreElements()) {
			String name = (String) enumParam.nextElement();
			String value = emxGetParameter(request, name);
			if (name != null && !("type".equalsIgnoreCase(name) || "objectId".equalsIgnoreCase(name)))
				contentURL.append("&" + name + "=" + value);
    	   }
		   	// append the parentRelName and  newly found object id
		contentURL.append("&parentRelName=relationship_ReferenceDocument");
		contentURL.append("&objectId=" + XSSUtil.encodeForURL(context, objectId));
		
		if("true".equalsIgnoreCase(isProjectTemplate) || "true".equalsIgnoreCase(isParentKindOFProjectTemplate)){
			contentURL.append("&defaultType=type_Document");
		}

	} else if ("taskDeliverable".equalsIgnoreCase(mode)) {
		contentURL
				.append("../components/emxCommonDocumentPreCheckin.jsp?objectAction=create&fileRequired=false");
		Enumeration enumParam = emxGetParameterNames(request);
		// Loop through the request elements and
		// stuff into contentURL
		while (enumParam.hasMoreElements()) {
			String name = (String) enumParam.nextElement();
			String value = emxGetParameter(request, name);
			if (name != null && !("type".equalsIgnoreCase(name) || "objectId".equalsIgnoreCase(name)))
				contentURL.append("&" + name + "=" + value);
		}
		// append the parentRelName and  newly found object id
		contentURL.append("&parentRelName=relationship_TaskDeliverable");
		contentURL.append("&objectId=" + XSSUtil.encodeForURL(context, objectId));

		if("true".equalsIgnoreCase(isProjectTemplate) || "true".equalsIgnoreCase(isParentKindOFProjectTemplate)){
						contentURL.append("&defaultType=type_Document");
					}
    }else{
 %>
        <script language="javascript">
        var errBegin="<emxUtil:i18nScript localize="i18nId">emxProgramCentral.UIEnhancement.CreateDocument.UncommonObjs</emxUtil:i18nScript>"+"\n";
        alert(errBegin);
		//Added:PRG:RG6:R212:11-May-2011:Folders
		if(getTopWindow().closeSlideInDialog)
		{
		    getTopWindow().closeSlideInDialog();
		}
		else
		{
		    window.closeWindow();
		}
		//End Added:PRG:RG6:R212:11-May-2011:Folders
        </script>
		       
<%  	
		return;
    }
      //Added 29-June-2010:rg6:PRGRG6R210   
      // if action and type of object selected get matched invoke the action
        if(!"true".equalsIgnoreCase(isWrongAction)){
        	//IR-133881V6R2013x Begin
        	//response.sendRedirect(contentURL.toString());
        	//IE8 accepts max URL length of 2048. contentURL.length > 2048. so sendRedirect fails. 
        	//When IE8 support removed in future release above line needs to comment out and following code need to remove. 
        	int index	=	contentURL.indexOf("?");
       		String stringURL	=	contentURL.substring(0, index);
           	String queryString	=	contentURL.substring(index+1,contentURL.length());
           	
           	String[] queryStringParameterValueArray	= queryString.split("&");
           	%>
           	<body onload="submitForm()">
	           	<form id="paramterForm" name="paramterForm" action="<%=stringURL%>">   <%-- XSSOK --%>
                <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>				
	           	<%
	           	for(int i= 0;i<queryStringParameterValueArray.length;i++) {
	           		String queryStringParameterValue	=	queryStringParameterValueArray[i];
	           		String[] paramNameValueArray		=	queryStringParameterValue.split("=");            		
	           		if (paramNameValueArray.length == 2) {
	           		%>
	           			<input type="hidden" name="<%=paramNameValueArray[0]%>" value="<%=paramNameValueArray[1]%>"/>
	           		<% } else {%>
	   	        		<input type="hidden" name="<%=paramNameValueArray[0]%>" value=""/>
	   	        	<%
	           		}           		
	           	}
	           	%>
	           	</form>
           	</body>
           	<script language="javascript">
           	   function submitForm() {
               	   document.paramterForm.submit();
           	   }
            </script> 
           	<%
		//IR-133881V6R2013x end    
    }else{
 %>
        <script language="javascript">
        var errBegin="<emxUtil:i18nScript localize="i18nId">emxProgramCentral.UIEnhancement.CreateDocument.UncommonObjs</emxUtil:i18nScript>"+"\n";
        alert(errBegin);
      //Added:PRG:RG6:R212:11-May-2011:Folders
        if(getTopWindow().closeSlideInDialog)
        {
            getTopWindow().closeSlideInDialog();
        }
        else
        {
            window.closeWindow();
        }
        //End Added:PRG:RG6:R212:11-May-2011:Folders
        </script>
<%
    }

%>

