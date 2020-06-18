<%--  emxColumnDropProcess.jsp - to drop a document file
--%>

<%@page import="com.matrixone.apps.common.VaultHolder"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.common.WorkspaceVault"%>
<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import = "matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.SetUtil"%>
<%@page import = "matrix.util.ErrorMessage"%>
<%@page import = "matrix.db.JPO"%>

<html>
	<body>
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>	
		<script language="javascript" src="../common/scripts/jquery-latest.js"></script>	
		<script language="javascript" type="text/javaScript">
		
			var contentFrame = findFrame(top, "content");			
			var leftPane = findFrame(top, "emxUIStructureTree");
				
<%	
	String sLanguage		= request.getHeader("Accept-Language");
	String sOIDDrag 		= emxGetParameter(request, "idDrag");
	String sOIDTarget 		= emxGetParameter(request, "idTarget");
	String sRIDDrag 		= emxGetParameter(request, "relDrag");
	String sLevelDrag		= emxGetParameter(request, "levelDrag");
	String sLevelTarget		= emxGetParameter(request, "levelTarget");
	String sParentDrag		= emxGetParameter(request, "parentDrag");
	String parentDrop		= emxGetParameter(request, "parentDrop");
	String sTypeDrag		= emxGetParameter(request, "typeDrag");
	String sKindDrag		= emxGetParameter(request, "kindDrag");
	String sTypeDrop		= emxGetParameter(request, "typeDrop");
	String sRelType			= emxGetParameter(request, "relType");
	String sRelAttribute	= emxGetParameter(request, "relAttribute");
	String sTypes			= emxGetParameter(request, "types");
	String sRelationships	= emxGetParameter(request, "relationships");
	String sAttributes		= emxGetParameter(request, "attributes");
	String sDirections		= emxGetParameter(request, "directions");
	String sRefresh			= emxGetParameter(request, "refresh");
	String sCtrlKey			= emxGetParameter(request, "ctrlKey");
	String sTypesStructure	= emxGetParameter(request, "typesStructure");
	Boolean bTo				= false;
	Boolean bFrom			= true;
	
	String sConnectedAlready = i18nNow.getI18nString("emxFramework.String.ThisItemIsConnectedAlready", "emxFrameworkStringResource", sLanguage);

	try{
		
	if(!sOIDDrag.equals(sOIDTarget)) {
			
		StringList slBusSelects = new StringList();
		StringList slRelSelects = new StringList();
		slBusSelects.add(DomainConstants.SELECT_ID);	
		slRelSelects.add(DomainConstants.SELECT_RELATIONSHIP_ID);	
		
		if(UIUtil.isNullOrEmpty(sTypes)) {
			sRelType = sRelationships;
			if(UIUtil.isNotNullAndNotEmpty(sDirections)) { 
				if(sDirections.equalsIgnoreCase("TO")) {
					bTo = true;
					bFrom = false;				
				}
			}
		} else {
			String aTypes[] 		= sTypes.split(",");
			String aRelationships[] = sRelationships.split(",");
			String aAttributes[] 	= new String[aRelationships.length];
			
			if(null != sAttributes) { 
				if(sAttributes.length() > aRelationships.length) {
					aAttributes    = sAttributes.split(","); 
				}
			}
			
			for(int i = 0; i < aTypes.length; i++) {
				if(aTypes[i].equals(sTypeDrag) || aTypes[i].equals(sKindDrag)) {
					sRelType = aRelationships[i];
					sRelAttribute = aAttributes[i];
					slRelSelects.add("attribute[" + sRelAttribute + "]");	
					break;
				}
			}
		}
		
		if(null == sRelAttribute) { sRelAttribute = DomainObject.EMPTY_STRING; }		

		DomainObject draggedObject  = DomainObject.newInstance(context, sOIDDrag);
		DomainObject doTarget 	= new DomainObject(sOIDTarget);
		RelationshipType rType 	= new RelationshipType(sRelType);
		
		MapList mlRelatedItems	= doTarget.getRelatedObjects(context, sRelType, DomainObject.QUERY_WILDCARD, slBusSelects, slRelSelects, bTo, bFrom, (short) 1, DomainObject.EMPTY_STRING, DomainObject.EMPTY_STRING, 0);	
		String sRelatedItems 	= mlRelatedItems.toString();	

		if(!sRelatedItems.contains(sOIDDrag) || 
				(sCtrlKey.equalsIgnoreCase("true")&& !draggedObject.isKindOf(context, CommonDocument.TYPE_DOCUMENTS))) {
			DomainRelationship dRel = new DomainRelationship();
			
			String SELECT_IS_PROJECT_SPACE 			= "type.kindof["+DomainConstants.TYPE_PROJECT_SPACE+"]";
			String SELECT_IS_PROJECT_CONCEPT 		= "type.kindof["+DomainConstants.TYPE_PROJECT_CONCEPT+"]";
			String SELECT_IS_WORKSPACE_VAULT  		= "type.kindof["+DomainConstants.TYPE_WORKSPACE_VAULT+"]";
		    String SELECT_IS_DOCUMENTS  			= "type.kindof["+CommonDocument.TYPE_DOCUMENTS+"]";
		    String SELECT_IS_CONTROLLED_FOLDER  	= "type.kindof["+DomainConstants.TYPE_CONTROLLED_FOLDER+"]";
		    String SELECT_ATTRIBUTE_FOLDER_TITLE 	= "attribute[" + PropertyUtil.getSchemaProperty(context, "attribute_Title") + "]";
		    String SELECT_RELATIONSHIP_SUB_VAULTS_ID = "to["+DomainObject.RELATIONSHIP_SUB_VAULTS+"].id";
		    String SELECT_RELATIONSHIP_DATA_VAULTS_ID = "to[Data Vaults].id";
			
			
			StringList selectable = new StringList(9);
			selectable.addElement(SELECT_IS_PROJECT_SPACE);
			selectable.addElement(SELECT_IS_PROJECT_CONCEPT);
			selectable.addElement(SELECT_IS_DOCUMENTS);
			selectable.addElement(SELECT_IS_WORKSPACE_VAULT);
			selectable.addElement(SELECT_IS_CONTROLLED_FOLDER);
			selectable.addElement(SELECT_ATTRIBUTE_FOLDER_TITLE);
			selectable.addElement(DomainConstants.SELECT_NAME);
			selectable.addElement(DomainConstants.SELECT_TYPE);
			selectable.addElement(DomainConstants.SELECT_REVISION);
			
			Map draggedObjectInfoMap 	= draggedObject.getInfo(context, selectable);
			String isDocument 			= (String)draggedObjectInfoMap.get(SELECT_IS_DOCUMENTS);
			String isWorkspaceVault 	= (String)draggedObjectInfoMap.get(SELECT_IS_WORKSPACE_VAULT);
			
			Map targetObjectMapInfo 	= doTarget.getInfo(context, selectable);
			String isProjectSpace 		= (String)targetObjectMapInfo.get(SELECT_IS_PROJECT_SPACE);
			String isProjectConcept 	=(String)targetObjectMapInfo.get(SELECT_IS_PROJECT_CONCEPT);
			String isTOWorkspaceVault 	= (String)targetObjectMapInfo.get(SELECT_IS_WORKSPACE_VAULT);
			
			if(UIUtil.isNotNullAndNotEmpty(sParentDrag)&&
					sParentDrag.equals(parentDrop) && !sCtrlKey.equalsIgnoreCase("true")) {
				
				String sOIDParentOld = DomainObject.EMPTY_STRING;
				DomainRelationship dRelOld = new DomainRelationship(sRIDDrag);
				dRelOld.open(context);
				if(bFrom) {
					BusinessObject boParentOld = dRelOld.getFrom();
					sOIDParentOld = boParentOld.getObjectId();
				} else {
					BusinessObject boParentOld = dRelOld.getTo();
					sOIDParentOld = boParentOld.getObjectId();
				}
				dRelOld.close(context);
				
				// Move an object's revision along with the current revision
				if("true".equalsIgnoreCase(isDocument)){
					dRel = doTarget.addRelatedObject(context, rType, bTo, sOIDDrag);
					DomainRelationship.disconnect(context, sRIDDrag);
				}else if("true".equalsIgnoreCase(isWorkspaceVault)){
					try{
						ContextUtil.startTransaction(context, true);
						DomainRelationship.disconnect(context, sRIDDrag);
						try{
							ContextUtil.pushContext(context);
							dRel = doTarget.addRelatedObject(context, rType, bTo, sOIDDrag);
						}
						finally{
							ContextUtil.popContext(context);
						}
						ContextUtil.commitTransaction(context);
					}
					catch(Exception e){
						ContextUtil.abortTransaction(context);
						throw e;
					}
				}else{
					dRel = doTarget.addRelatedObject(context, rType, bTo, sOIDDrag);
					DomainRelationship.disconnect(context, sRIDDrag);
				}
				
				if(!sRefresh.contains(".refreshRow")) {
	
					String sXMLRemove = "<mxRoot>";
					sXMLRemove += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
					sXMLRemove += "<item id=\"" + sLevelDrag + "\" />";
					sXMLRemove += "<message><![CDATA[]]></message>";
					sXMLRemove += "</mxRoot>";
%>			 	
					parent.removedeletedRows('<%=sXMLRemove%>');			
	
<%					if(sTypesStructure.contains(sKindDrag)) { %>
						if(leftPane) {			
							contentFrame.deleteObjectFromTrees("<%=sOIDDrag%>",false); 			
							contentFrame.refreshStructureTree();
						}			

<%					} %>
<%				}
			}else{ //Drag with ctrl key
				String copyOf = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.String.CopyOf", context.getLocale());

				String isControlledFolder 		= (String)draggedObjectInfoMap.get(SELECT_IS_CONTROLLED_FOLDER);
				String draggedObjectTitle 		= (String)draggedObjectInfoMap.get(SELECT_ATTRIBUTE_FOLDER_TITLE);
				String draggedObjectName 		= (String)draggedObjectInfoMap.get(DomainConstants.SELECT_NAME);
				
				if("true".equalsIgnoreCase(isDocument)){
					dRel = doTarget.addRelatedObject(context, rType, bTo, sOIDDrag);
				}else if("true".equalsIgnoreCase(isWorkspaceVault)){
					draggedObjectName = copyOf+" "+draggedObjectName;
					WorkspaceVault sourceObject = new WorkspaceVault(sOIDDrag);
					WorkspaceVault targetObject = new WorkspaceVault(sOIDTarget);
					//Clonning
					WorkspaceVault clone = new WorkspaceVault();
					if("true".equalsIgnoreCase(isProjectSpace) || "true".equalsIgnoreCase(isProjectConcept)){
						DomainObject project = DomainObject.newInstance(context,
								DomainObject.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
						project.setId(sOIDTarget);
						
						clone = sourceObject.clone(context,draggedObjectName,(VaultHolder) project);
					}else{
						clone = sourceObject.clone(context,draggedObjectName,targetObject);
					}
					
					//change for controlled folder
					 if("true".equalsIgnoreCase(isControlledFolder)){
						draggedObjectTitle = copyOf+" "+draggedObjectTitle;
						String controlledFolderName = clone.getUniqueName(context);
						String revision = "1";
						String sCommandStatement = " modify bus $1 name $2 revision $3";
						MqlUtil.mqlCommand(context, sCommandStatement,clone.getObjectId(context), controlledFolderName,revision);
						clone.setAttributeValue(context,DomainConstants.ATTRIBUTE_TITLE,draggedObjectTitle);
					}
					
					StringList objectSelects = new StringList(2);
					objectSelects.add(SELECT_RELATIONSHIP_SUB_VAULTS_ID);
					objectSelects.add(SELECT_RELATIONSHIP_DATA_VAULTS_ID);
					
					Map cloneObjectMap		= clone.getInfo(context, objectSelects);
					String cloneSVRelId 	= (String)cloneObjectMap.get(SELECT_RELATIONSHIP_SUB_VAULTS_ID);
					String cloneDVRelId 	= (String)cloneObjectMap.get(SELECT_RELATIONSHIP_DATA_VAULTS_ID);
					
					if(UIUtil.isNotNullAndNotEmpty(cloneDVRelId) && !("true".equalsIgnoreCase(isProjectSpace) || "true".equalsIgnoreCase(isProjectConcept))){
						DomainRelationship.disconnect(context, cloneDVRelId);
					}
					
					if(UIUtil.isNotNullAndNotEmpty(cloneSVRelId) && ("true".equalsIgnoreCase(isProjectSpace) || "true".equalsIgnoreCase(isProjectConcept))){
						DomainRelationship.disconnect(context, cloneSVRelId);
					}
					
					if("true".equalsIgnoreCase(isProjectSpace) || "true".equalsIgnoreCase(isProjectConcept)){
						dRel = new DomainRelationship(cloneDVRelId);
					}else{
		           		dRel = new DomainRelationship(cloneSVRelId);
					}
					sOIDDrag = clone.getObjectId(context);
				}else{
					dRel = doTarget.addRelatedObject(context, rType, bTo, sOIDDrag);
				}
			}

			if(!sRefresh.equals("header")) {

				if(UIUtil.isNotNullAndNotEmpty(sRelAttribute)) {			
					int iCount = mlRelatedItems.size() ;
					iCount++;			
					dRel.setAttributeValue(context, sRelAttribute, String.valueOf(mlRelatedItems.size() + 1));
				}
			
				Map mResults 			= dRel.getRelationshipData(context, slRelSelects);
				StringList slTemp 		= (StringList) mResults.get(DomainConstants.SELECT_RELATIONSHIP_ID);
				String sRID 			= (String) slTemp.get(0);

				String sXMLAdd = "<mxRoot><action><![CDATA[add]]></action>";
				sXMLAdd += "<data status=\"committed\" fromRMB=\"true\">";
				sXMLAdd += "<item oid=\"" + sOIDDrag + "\" relId=\"" + sRID + "\" pid=\"" + sOIDTarget + "\" direction=\"\" pasteBelowToRow=\"" + sLevelTarget + "\" />" ;
				sXMLAdd += "</data></mxRoot>"; 	
				
				if(sRefresh.contains(".refreshRow")) { %>
					parent.emxEditableTable.refreshRowByRowId('<%=sLevelTarget%>');
<%				} else { 
					if(sTypesStructure.contains(sKindDrag)) { %>
						if(leftPane) {
							var leftTree = getTopWindow().objStructureTree;
							if(leftTree && contentFrame) {   
								var nodeId = leftTree.findNodeByObjectID("<%=sOIDTarget%>");				
								contentFrame.addStructureTreeNode("<%=sOIDDrag%>", "<%=sOIDTarget%>", nodeId, "programcentral","","",false);		
							}
						}
<%					} %>
					parent.emxEditableTable.addToSelected('<%=sXMLAdd%>');
<%				}
			} else { 
			
				String initargs[]	= {};
				HashMap params 		= new HashMap();

				params.put("objectId"	, sOIDTarget	);		
				params.put("language"	, sLanguage		);		
				params.put("content"	, "documents"	);		
	
				String[] aData	= (String[])JPO.invoke(context, "emxExtendedHeader", initargs, "genHeaderFromJSP", JPO.packArgs (params), String[].class); 	%>

				var divHeader = parent.document.getElementById("divExtendedHeaderDocuments");
				divHeader.innerHTML = "<%=aData[0]%>";
<%			}
		}  else {			
	
			slBusSelects.add(DomainConstants.SELECT_TYPE);
			slBusSelects.add(DomainConstants.SELECT_NAME);
			
			DomainObject doError 	= new DomainObject(sOIDDrag); 
			Map mError 				= doError.getInfo(context, slBusSelects);
			StringBuilder sbMessage = new StringBuilder();

			sbMessage.append(sConnectedAlready).append(":\\n");
			sbMessage.append((String)mError.get(DomainConstants.SELECT_TYPE)).append("\\n");
			sbMessage.append((String)mError.get(DomainConstants.SELECT_NAME));
			
%>				
			//XSSOK
			parent.emxEditableTable.refreshRowByRowId('<%=sLevelTarget%>');
			//XSSOK
			alert("<%=sbMessage.toString()%>");
<%			
		}
	}
	}
	catch(Exception ex){
		String message = ex.toString(); 
		int i = message.indexOf("System Error");
		if (i != -1) {
			message = message.substring(i+24, message.length()).trim();
		}
		%>
		alert("<%=XSSUtil.encodeForJavaScript(context, message)%>");
		parent.emxEditableTable.refreshRowByRowId('<%=sLevelTarget%>');
		<%
	}
	%>
		</script>
	</body>
</html>
