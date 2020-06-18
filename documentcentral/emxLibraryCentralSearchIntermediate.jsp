<%--  emxLibraryCentralSearchIntermediate.jsp  -
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>
<jsp:useBean id="LibraryCentralBean" class="com.matrixone.apps.library.Libraries" scope="session"/>
<html>
<body>
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<%
    try
    {
	   StringBuffer searchURL           = new StringBuffer("../common/emxFullSearch.jsp?");//qbq
       StringBuffer submitURL           = new StringBuffer("../documentcentral/");
       String useMode                   = emxGetParameter(request,"useMode");
	 
       String languageStr               = request.getHeader("Accept-Language");
       String emxTableRowIds[]          = getTableRowIDsArray(emxGetParameterValues(request,"emxTableRowId"));
       String strAllowedSearchItems     = "";
       String parentOId                 = emxGetParameter(request, "objectId");
       String sSymbolicParentType       = "";
       String sType                     = "";
       if(!UIUtil.isNullOrEmpty(parentOId)){
            DomainObject doObj          = new DomainObject(parentOId);
            String strParentType        = doObj.getInfo(context,DomainConstants.SELECT_TYPE);
            sSymbolicParentType         = FrameworkUtil.getAliasForAdmin(context,"type", strParentType,true);
       }
       HashMap allowedClassesMap        = (HashMap)LibraryCentralCommon.getAllowedClassesMap(context);
       HashMap allowedParentsMap        = (HashMap)LibraryCentralCommon.getAllowedParentsMap(context);
       HashMap allowedEndItemsMap       = (HashMap)LibraryCentralCommon.getAllowedEndItemsMap(context);
       useMode                          = UIUtil.isNullOrEmpty(useMode)?"":useMode;
       StringBuffer sbField             = new StringBuffer("TYPES=");
       String sFormInclusionList        = "";
       String selection                 = "multiple";
       String excludeOIDprogram         = "emxLibraryCentralFindObjects:getAddExisitingExcludeOIDs";
       String includeOIDprogram			= "";
       String table                     = "AEFGeneralSearchResults";
       String helpMarker                = "emxhelpfullsearch";
       String formInclusionList         = "";
       String header                    = "emxLibraryCentral.Search.Results";
       String suiteKey                  = emxGetParameter(request,"suiteKey");
       boolean bAddparameters           = false;
       boolean addToFolder              = false;
           if("moveClass".equalsIgnoreCase(useMode)){
           String strObjectId           = "";
           emxTableRowIds               = (String[]) getTableRowIDsArray(emxTableRowIds);
           if(emxTableRowIds != null && emxTableRowIds.length > 0) {
               strObjectId              = emxTableRowIds[0];
           }
           table="LCClassificationList";
           DomainObject doObj           = new DomainObject(strObjectId);
           DomainObject parentDomObj	= new DomainObject(parentOId);
           String parentTypeStr = FrameworkUtil.getAliasForAdmin(context,"type", parentDomObj.getInfo(context,DomainConstants.SELECT_TYPE),true);
           //check whether class is General class & it contains Port
           String classificationType=doObj.getInfo(context,DomainConstants.SELECT_TYPE);
           StringList busSelects=new StringList();
           if(classificationType.equalsIgnoreCase(LibraryCentralConstants.TYPE_GENERAL_CLASS) &&
        		   doObj.getRelatedObjects(context,LibraryCentralConstants.RELATIONSHIP_CLASSIFIED_ITEM,
	                LibraryCentralConstants.TYPE_LIBRARY_FEATURE_PORT,
	                busSelects,
	                null,
	                false,//boolean getTo,
	                true,//boolean getFrom,
	                (short)1,
	                null,
	                null,
	                0).size() >= 1){
        	   %>
               <script>
	               alert("<emxUtil:i18nScript localize="i18nId">emxLibraryCentral.Move.Message</emxUtil:i18nScript>");
	               getTopWindow().closeWindow();
    	       </script>
<%
           }
           //Code added for R216 release
           //To enable population of appropriate Libraries, appropriate Types are appended to the field.
           else{
           busSelects.add(LibraryCentralConstants.SELECT_ID);
           String typeStr = FrameworkUtil.getAliasForAdmin(context,"type", doObj.getInfo(context,DomainConstants.SELECT_TYPE),true);
           sbField.append(LibraryCentralConstants.TYPE_GENERAL_LIBRARY+",");
           if (doObj.isKindOf(context,DomainConstants.TYPE_PART_FAMILY))
           {
        	   sbField.append(LibraryCentralConstants.TYPE_PART_LIBRARY+",");
           }
           else if(doObj.isKindOf(context,LibraryCentralConstants.TYPE_DOCUMENT_FAMILY))
           {
        	   sbField.append(LibraryCentralConstants.TYPE_DOCUMENT_LIBRARY+",");
           }
           sbField.append(typeStr);
           selection                    = "single";
           excludeOIDprogram            = "emxLibraryCentralFindObjects:getMoveExcludeOIDs";
           formInclusionList            = "COUNT";
           submitURL.append("emxMultipleClassificationRemoveClassPreProcess.jsp?Mode=Move");
           }
		   //qbq
		   searchURL.append("suiteKey=");
		   searchURL.append(suiteKey);
		   searchURL.append("&objectId=");
		   searchURL.append(strObjectId);
		   searchURL.append("&oldParentObjectId=");
		   searchURL.append(parentOId);
		   //qbq
       } else if("addClass".equalsIgnoreCase(useMode)){
           sbField.append((String)allowedClassesMap.get(sSymbolicParentType));
           formInclusionList = "COUNT";
           bAddparameters    = true;
           table="LBCGeneralSearchResults";
           //REMOVE BY YUF 
		   submitURL.append("emxLibraryCentralAddExistingProcess.jsp?useMode=");
		   //submitURL.append("CSSCLibraryCentralAddExistingProcess.jsp?useMode=");
           submitURL.append(useMode);
		  
		  
       } else if("addClassificationEndItem".equalsIgnoreCase(useMode)){
		    System.out.println("--------------------------------------------------------11111111111111111111111>>>");
		   sbField.append((String)allowedEndItemsMap.get(sSymbolicParentType));
           //Fix for 283268V6R2014x. IS_VERSION_OBJECT is required only for Real Time.
           String isIndexedMode=EnoviaResourceBundle.getProperty(context,"emxFramework.FullTextSearch.QueryType");		   
           if(!("Indexed".equals(isIndexedMode))){
          		sbField.append(":CURRENT!=policy_Version.state_Exists:CURRENT!=policy_VersionedDesignPolicy.state_Exists");
           }
           //sbField.append(":current.access[toconnect]=true");//qbq managed in jsp
           bAddparameters   = true;
           //submitURL.append("emxLibraryCentralObjectAddEndItems.jsp?useMode=");
		   submitURL.append("csscSelectionShipScopeSubmit.jsp?useMode=");
           submitURL.append(useMode);
           table            = "LBCClassifiedItemSearchResults";
       } else if("addRetainedDocuments".equalsIgnoreCase(useMode)){
           sbField.append((String)JSPUtil.getCentralProperty(application,session,"emxLibraryCentral","Record.SupportedTypes"));
           
           String isIndexedMode=EnoviaResourceBundle.getProperty(context,"emxFramework.FullTextSearch.QueryType");
           if(!("Indexed".equals(isIndexedMode))){
          		sbField.append(":CURRENT!=policy_Version.state_Exists:CURRENT!=policy_VersionedDesignPolicy.state_Exists");
           }           
           
           bAddparameters   = true;
           submitURL.append("emxLibraryCentralRetainedDocumentAddContentsProcess.jsp?useMode=");
           submitURL.append(useMode);
      } else if("addToFolders".equalsIgnoreCase(useMode)  || "addToFoldersFromListPage".equalsIgnoreCase(useMode) ){
           addToFolder      = true;
           includeOIDprogram            = "emxLibraryCentralFindObjects:getFolderIncludeOIDs";
           LibraryCentralBean.setObjectRowID(emxTableRowIds);
           sbField.append("type_ProjectVault");
           table            = "LBCFoldersSearchResults";
           header           = "emxDocumentCentral.Shortcut.SelectFolder";
           submitURL.append("emxDocumentCentralFolderSelectProcess.jsp?useMode=");
           submitURL.append(useMode);
			searchURL.append("&includeOIDprogram=");//qbq
		   searchURL.append(includeOIDprogram);//qbq
      } else if("searchIn".equalsIgnoreCase(useMode)){
          bAddparameters = true;
          DomainObject doObj    = new DomainObject(parentOId);
          table="LBCGeneralSearchResults";
          String parentType     = FrameworkUtil.getAliasForAdmin(context,"type", doObj.getInfo(context,DomainConstants.SELECT_TYPE),true);
          if ("type_ProjectVault".equals(parentType)) {
              sbField.append("type_Libraries,type_Classification,type_Part,type_DOCUMENTS:REL_HAS_VAULTED_DOCUMENTS_REV2_FROM_ID=");
          }
          sbField.append(parentOId);
          formInclusionList="CreatedOn,Approver,DESCRIPTION";
		   searchURL.append("&toolbar=");//qbq
		   searchURL.append("LBCSearchResultToolBar");//qbq
         }

		 //qbq
		 // Changes added by PSA11 start(IR-532768-3DEXPERIENCER2018x).
        DomainObject doObj          = new DomainObject(parentOId);
        String strParentType        = doObj.getInfo(context,DomainConstants.SELECT_TYPE);		 
        if(UINavigatorUtil.isCloud(context) && strParentType.equalsIgnoreCase("General Class")){
			//changes done by ssi17 start(IR-548983-3DEXPERIENCER2018x)
		    searchURL.append("showInitialResults=false&addPreCondParam=false");    
				// End ssi17
        } else {
		    searchURL.append("&field=");
		    searchURL.append(sbField.toString()); 
            if (!addToFolder) {
	            searchURL.append("&excludeOIDprogram=");//qbq
	            searchURL.append(excludeOIDprogram);//qbq
            }               
        }		 
		 // Changes added by PSA11 end.
		 //searchURL.append("&field=");
		 //searchURL.append(sbField.toString());
		 searchURL.append("&table=");
		 searchURL.append(table);
		 searchURL.append("&selection=");
		 searchURL.append(selection);
		 searchURL.append("&HelpMarker=");
		 searchURL.append(helpMarker);
		 searchURL.append("&useMode=");
		 searchURL.append(useMode);
		 searchURL.append("&header=");
		 searchURL.append(header);
		 searchURL.append("&hideHeader=true");
		 //qbq
if(!"../documentcentral/".equalsIgnoreCase((submitURL.toString()))) {
	searchURL.append("&submitURL=");//qbq
	searchURL.append(submitURL.toString());//qbq
}
if(!"".equals(formInclusionList)) {
	searchURL.append("&formInclusionList=");//qbq
	searchURL.append(formInclusionList);//qbq
}
//if (!addToFolder) {
//	searchURL.append("&excludeOIDprogram=");//qbq
//	searchURL.append(excludeOIDprogram);//qbq
//}
    // Append the parameter to the content page
    if(bAddparameters) {
        for (Enumeration e = emxGetParameterNames(request); e.hasMoreElements();) {
            String strParamName  = (String)e.nextElement();
            String strParamValue = (String)emxGetParameter(request, strParamName);
			searchURL.append("&"+ strParamName +"=");//qbq
		    searchURL.append(strParamValue);//qbq
        }
    }
	
	 System.out.println("searchURL-----------------"+searchURL);
%>
  <script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
  <script type="text/javascript">
  getTopWindow().showModalDialog('<%=searchURL%>');//qbq
  </script>
<%
    }
    catch (Exception ex)
    {
        ex.printStackTrace();
    }
%>
</body>
</html>
