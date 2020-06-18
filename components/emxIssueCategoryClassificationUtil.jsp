<%--
  emxIssueCategoryClassificationUtil.jsp

  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%@ page
	import="matrix.db.*,
                   matrix.util.*"
	errorPage="emxComponentsError.jsp"%>

<%@ page import="com.matrixone.apps.common.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>

<%@include file="../emxRequestWrapperMethods.inc"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
	matrix.db.Context context = Framework.getFrameContext(session);
	String strMode = emxGetParameter(request, "mode");
	String categoryId = emxGetParameter(request, "objectId");
	String classificationId = emxGetParameter(request, "newObjectId");
	String relId = "";
	String commandHRef = "";
	String errorMessage = "";
	String noSelectionMessage = "";
	String[] arrTableRowIds = new String[0];
	String[] arrTableRelIds = new String[0];	
	String lang = request.getHeader("Accept-Language");	

	DomainRelationship addRelatedObject =  new DomainRelationship();
	String emxTableRowId = emxGetParameter(request,"emxTableRowId");
	String[] arrTableRowIdsRefresh = emxGetParameterValues(request, "emxTableRowId");
	//String relName = PropertyUtil.getSchemaProperty(DomainConstants.RELATIONSHIP_ISSUECATEGORYCLASSIFICATION);	
	
	if("CategoryCreateCommand".equals(strMode)){	
		if(emxTableRowId != null && !emxTableRowId.equals("")){
	        StringTokenizer strtk1 = new StringTokenizer(emxTableRowId,"|");
	        int totalObjects = strtk1.countTokens();
	        if(totalObjects < 3){
	        	errorMessage = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.IssueCategory.CreateCategoryWarningAlert", lang);
			}
		}		
		commandHRef = "../common/emxCreate.jsp?type=type_IssueCategory&header=emxComponents.Header.CreateIssueCategory&StringResourceFileId=emxComponentsStringResource&suiteKey=Components&submitAction=none&form=type_IssueCategoryForm&showApply=true&postProcessURL=../components/emxIssueCategoryClassificationUtil.jsp?mode=CategoryCompleteAction";	
		
	}else if("ClassificationCreateCommand".equals(strMode)){		
		if(emxTableRowId != null && !emxTableRowId.equals("")){
	        StringTokenizer strtk1 = new StringTokenizer(emxTableRowId,"|");
	        int totalObjects = strtk1.countTokens();
	        if(totalObjects >= 3){
	        	errorMessage = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.IssueClassification.AddExistingErrorAlert", lang);
			}
	        emxTableRowId = strtk1.nextToken();
		}
		commandHRef = "../common/emxCreate.jsp?type=type_IssueClassification&showApply1=true&header=emxComponents.Header.CreateIssueClassification&StringResourceFileId=emxComponentsStringResource&form=type_IssueClassificationForm&suiteKey=Components&HelpMarker=emxhelpclassificationcreate&submitAction=none&postProcessURL=../components/emxIssueCategoryClassificationUtil.jsp?mode=ClassificationCompleteAction&objectId="+XSSUtil.encodeForURL(context,emxTableRowId);	
		
	}else if("AddExistingClassification".equals(strMode)){		
		if(emxTableRowId != null && !emxTableRowId.equals("")){
	        StringTokenizer strtk1 = new StringTokenizer(emxTableRowId,"|");
	        int totalObjects = strtk1.countTokens();
	        if(totalObjects >= 3){	        	
				errorMessage = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.IssueClassification.AddExistingErrorAlert", lang);
			}	        
		}		
		//commandHRef = "../common/emxFullSearch.jsp?table=IssueClassificationSearchTable&showInitialResults=true&excludeOIDprogram=emxCommonIssue:getExcludeIssueClassificationList&field=TYPES=type_IssueClassification&emxTableRowId="+emxTableRowId+"&selection=multiple&submitURL=../components/emxIssueCategoryClassificationUtil.jsp&mode=AddExistingClassificationAction";
		commandHRef = "../common/emxIndentedTable.jsp?table=IssueClassificationSearchTable&program=emxCommonIssue:getExcludeIssueClassificationList&header=emxComponents.Common.SelectCategory&suiteKey=Components&selection=multiple&expandLevelFilterMenu=false&customize=false&Export=false&multiColumnSort=false&emxTableRowId="+XSSUtil.encodeForURL(context,emxTableRowId)+"&PrinterFriendly=false&showPageURLIcon=false&showRMB=false&showClipboard=false&objectCompare=false&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel&cancelButton=true&displayView=details&submitURL=../components/emxIssueCategoryClassificationUtil.jsp&mode=AddExistingClassificationAction";		
	}else if("DeleteCategoryClassification".equals(strMode)){		
		
      	String[] selectedRowElements = emxGetParameterValues(request, "emxTableRowId");						

      	arrTableRowIds = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
      	//get the object ids of the tablerow ids passed
      	String strObjectIds[] = strObjectIds = Issue.getObjectIds(arrTableRowIds);
      	// check to see if user has "delete" access on the object
      	boolean isPushed = false;
      	try{
    	  	Map javaScriptHelperObjects = new HashMap(10);          	
          	StringList selects = new StringList();
          	selects.add(DomainObject.SELECT_ID);
          	selects.add(DomainObject.SELECT_TYPE);
          	selects.add(DomainObject.SELECT_NAME);          	
          	
          	Issue issueBean = new Issue();
          	MapList issueCategoryAccessInfo = DomainObject.getInfo(context, strObjectIds, selects);
          	Map noDeleteAccessObjectList = new HashMap();
          	Map hasDeleteAccessObjectList = new HashMap();          	
		
          	
          	//to delete selected Classifications, MOre than one reference then disconnect otherwise delete the classification.          	
          	       	
          	for (int i = 0; i < issueCategoryAccessInfo.size(); i++) {
          		Map issueDelAccess = (Map)issueCategoryAccessInfo.get(i);
              	String classId = (String)issueDelAccess.get(DomainObject.SELECT_ID);
              	String objectType = (String)issueDelAccess.get(DomainObject.SELECT_TYPE);
              	
              	if(DomainConstants.TYPE_ISSUECLASSIFICATION.equals(objectType)){            		
              		Map classificationMap = issueBean.getClassificationWithScope(context, classId, selects);                  	
              		String canDelete = (String)classificationMap.get("CanDelete");
                  	if("true".equalsIgnoreCase(canDelete)){
                  		hasDeleteAccessObjectList.put(classificationMap.get(DomainObject.SELECT_ID),"true");                  		
                  	}else{
                  		String OBJ = (String)classificationMap.get(DomainConstants.SELECT_ID);
                  		for(int k = 0;k < selectedRowElements.length; k++){
                  			String rowData = selectedRowElements[k];              			
                  			if(rowData.contains(OBJ)){
                  				OBJ = FrameworkUtil.getTableRowRelId(rowData);
                  				if(!noDeleteAccessObjectList.containsKey(OBJ)){
                  					noDeleteAccessObjectList.put(OBJ, "disconnected");
                  					DomainRelationship.disconnect(context, OBJ);   
                  					break;
                  				}
                  			}                  		
                      	}                  		
                  		               		
                  	}
                }
          	}
          	if(hasDeleteAccessObjectList.size() > 0) {
              	ContextUtil.pushContext(context);
              	isPushed = true;
              	String[] deletedIssues = (String []) hasDeleteAccessObjectList.keySet().toArray(new String[]{});
          	   	issueBean.deleteObjects(context, deletedIssues, false);		
          	}
          	
          	
          	//First delete categories and classifications in that category(if there is are no refrences to those categories).    
          	hasDeleteAccessObjectList = new HashMap();   
          	for (int i = 0; i < issueCategoryAccessInfo.size(); i++) {
          		Map issueDelAccess = (Map)issueCategoryAccessInfo.get(i);
              	String catId = (String)issueDelAccess.get(DomainObject.SELECT_ID);
              	String objectType = (String)issueDelAccess.get(DomainObject.SELECT_TYPE);     	
              	MapList classificationList = new MapList();
              	if(DomainConstants.TYPE_ISSUECATEGORY.equals(objectType)){
              		hasDeleteAccessObjectList.put(catId,"true");
              		classificationList = issueBean.getClassificationsWithScope(context, catId, selects);
                  	
                  	for (int j = 0; j < classificationList.size(); j++) {
                  		Map tempClassificationMap = (Map)classificationList.get(j);
                  		String canDelete = (String)tempClassificationMap.get("CanDelete");
                  		if("true".equalsIgnoreCase(canDelete)){
                  			hasDeleteAccessObjectList.put(tempClassificationMap.get(DomainObject.SELECT_ID),"true");
                  		}                  		
                  	}              		
              	}
          	}
          	
          	if (hasDeleteAccessObjectList.size() > 0) {
              	ContextUtil.pushContext(context);
              	isPushed = true;
              	String[] deletedIssues = (String []) hasDeleteAccessObjectList.keySet().toArray(new String[]{});
          	   	issueBean.deleteObjects(context, deletedIssues, false);
				
          	}        	
          	          	

      	} catch(Exception ex){
         	throw ex;   	       
     	} finally {
      	    if(isPushed) {
       	    	ContextUtil.popContext(context);
      	 	}
       }	
	}else if("AddExistingClassificationAction".equals(strMode)){		
		categoryId = emxGetParameter(request, "emxParentIds");
		arrTableRowIds = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
		if(arrTableRowIds.length == 0){
			noSelectionMessage = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.Common.PleaseMakeASelection", lang);
		}else{
		arrTableRelIds = new String[arrTableRowIds.length];
		Object obj = new Object();
      	Hashtable relIdTable = new Hashtable();
      	StringList selects = new StringList();
      	selects.add(DomainConstants.SELECT_ID);
      	      	
      	if(categoryId != null && !categoryId.equals("")){
	        StringTokenizer strtk1 = new StringTokenizer(categoryId,"|");	        
	        categoryId = strtk1.nextToken();				        
		}
      	
      	DomainObject parentObj = new DomainObject();      	
      	parentObj.setId(categoryId);     	
      	
      	for(int i = 0; i<arrTableRowIds.length;i++){
      		addRelatedObject =parentObj.connect(context, DomainConstants.RELATIONSHIP_ISSUECATEGORYCLASSIFICATION, new DomainObject(arrTableRowIds[i]),false);
      		addRelatedObject.setAttributeValue(context, DomainConstants.ATTRIBUTE_ISSUEOWNEDBY , context.getUser());
      		relIdTable =  FrameworkUtil.getSelectData(context, addRelatedObject.getName(), selects, true);
      		obj = relIdTable.get(DomainConstants.SELECT_ID);
      		if(obj instanceof String){
      			arrTableRelIds[i] = (String)obj;
      		}else{
      			arrTableRelIds[i] = (String)((StringList)obj).get(0);
      		}      		
        }
		}
	}else if("ClassificationCompleteAction".equals(strMode)){
		matrix.db.Context updateContext = (matrix.db.Context)request.getAttribute("context");
		String issueOwnedBy = emxGetParameter(request, "IssueOwnedBy");
		StringList selects = new StringList();
      	selects.add(DomainConstants.SELECT_ID);
      	
		DomainObject doTarget 	= new DomainObject(categoryId);		
		addRelatedObject = doTarget.connect(updateContext, DomainConstants.RELATIONSHIP_ISSUECATEGORYCLASSIFICATION, new DomainObject(classificationId),false);
		addRelatedObject.setAttributeValue(updateContext, DomainConstants.ATTRIBUTE_ISSUEOWNEDBY, issueOwnedBy);
		Hashtable relIdTable =  FrameworkUtil.getSelectData(updateContext, addRelatedObject.getName(), selects, true);
  		Object obj = relIdTable.get(DomainConstants.SELECT_ID);
  		if(obj instanceof String){
  			relId = (String)obj;
  		}else{
  			relId = (String)((StringList)obj).get(0);
  		}		
	}
	%>
<script>
	var frameHandle = emxUICore.findFrame(getTopWindow(),'content');
	<% if(UIUtil.isNotNullAndNotEmpty(errorMessage) && "AddExistingClassification".equals(strMode)){%>		
		alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
	 	getTopWindow().close();	
	<%} else if(UIUtil.isNotNullAndNotEmpty(noSelectionMessage)){%>
		alert("<%=XSSUtil.encodeForJavaScript(context,noSelectionMessage)%>");
		if(top.SUBMIT_URL_PREV_REQ_IN_PROCESS){
			top.SUBMIT_URL_PREV_REQ_IN_PROCESS = false;
		}
	<%} else if(UIUtil.isNotNullAndNotEmpty(errorMessage)){%>
		alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
	<%}else if("ClassificationCreateCommand".equals(strMode) || "CategoryCreateCommand".equals(strMode)){%>
		getTopWindow().showSlideInDialog("<%=commandHRef%>",true);
	<%}else if("AddExistingClassification".equals(strMode)){%>
		getTopWindow().location.href = "<%=commandHRef%>";
	<%}else if("ClassificationCompleteAction".equals(strMode) && UIUtil.isNotNullAndNotEmpty(relId) && UIUtil.isNotNullAndNotEmpty(classificationId) && UIUtil.isNotNullAndNotEmpty(categoryId)){%>
		var oXM = emxUICore.findFrame(getTopWindow(),'content').sbPage.oXML;
		var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '<%=categoryId%>']");
		if(rowID){
			var selectSBrows = [];
			selectSBrows.push(rowID.getAttribute('id'));			
			var strXml="<mxRoot><action>add</action><data status='committed'><item oid= '<%=classificationId%>' relId='<%=relId%>' pid='<%=categoryId%>'/></data></mxRoot>";
			frameHandle.emxEditableTable.addToSelected(strXml,selectSBrows);	
		}
	<%}else if("CategoryCompleteAction".equals(strMode)) {%>

		var oXM = emxUICore.findFrame(getTopWindow(),'content').sbPage.oXML;
		var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o]");
		if(rowID){
        	var  xmlOut = "<mxRoot><action>add</action><data status='committed'><item oid='<%=classificationId%>' relId='<%=relId%>' pid='<%=categoryId%>'/></data></mxRoot>";
			frameHandle.emxEditableTable.addToSelectedMultiRoot(xmlOut);
		}else{
			frameHandle.location.href =frameHandle.location.href;				
		}		
	<%}else if("DeleteCategoryClassification".equals(strMode)) {%>	
		var rowsSelected = "<%=XSSUtil.encodeForJavaScript(context, ComponentsUIUtil.arrayToString(arrTableRowIdsRefresh, "~"))%>";
		parent.emxEditableTable.removeRowsSelected(rowsSelected.split("~"));
	<%}else if("AddExistingClassificationAction".equals(strMode)) {%>	
		frameHandle = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),'content');
		var oXM = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),'content').sbPage.oXML;
	
		var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '<%=categoryId%>']");
		if(rowID){
			var selectSBrows = [];
			selectSBrows.push(rowID.getAttribute('id'));		
			<%for(int i = 0; i<arrTableRowIds.length;i++){%>
				var  strXml = "<mxRoot><action>add</action><data status='committed'><item oid='<%=arrTableRowIds[i]%>' relId='<%=arrTableRelIds[i]%>' pid='<%=categoryId%>'/></data></mxRoot>";
				frameHandle.emxEditableTable.addToSelected(strXml,selectSBrows);	
			<%}%>
		}
		getTopWindow().close();
	<%}%>	
</script>


