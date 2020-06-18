<%--  emxProjectManagementUtil.jsp

   Copyright (c) Dassault Systemes, 1992-2018 .All rights reserved

--%>
<%@page import="java.util.Set"%>
<%@page import="com.matrixone.apps.common.TaskDateRollup"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonObject"%> 
<%@page import="java.lang.reflect.Method"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.common.TaskDateRollup"%>

<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>


<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.common.Company,matrix.util.StringList" %>

<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>


<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script src="../programcentral/emxProgramCentralUIFormValidation.js" type="text/javascript"></script>

<%


	 String strMode = emxGetParameter(request, "mode");
	 strMode = XSSUtil.encodeURLForServer(context, strMode);


    if("PMCDeliverableURL".equalsIgnoreCase(strMode)) {
                String strGridActive = "false";
                try {
			strGridActive = EnoviaResourceBundle.getProperty(context, "emxFramework.Activate.GridView");
		} catch (FrameworkException e) {
			strGridActive = "false";
		}
	String strURL = "../common/emxIndentedTable.jsp?program=emxTask:getURLDeliverables&table=PMCBookmarkSummary&toolbar=PMCDeliverablesBookmarkToolBar&selection=multiple&Export=false&sortColumnName=Name&sortDirection=ascending&header=emxProgramCentral.Common.Bookmarks&HelpMarker=emxhelpdeliverables&hideLaunchButton=true&showRMB=false&postProcessJPO=emxProgramCentralUtil:postProcessPortalCmdSBRefresh&customize=false&displayView=details&autoFilter=false&showPageURLIcon=false&rowGrouping=false&findMxLink=false&multiColumnSort=false&objectCompare=false&showClipboard=false";
		//HondaGrid-FUN087459
		// replace common/emxIndentedTable.jsp with webapps/ENXSBGridConnectorClient/ENXSBGridConnectorClient.html 
		if ("true".equalsIgnoreCase(strGridActive)) {
			strURL = "../webapps/ENXSBGridConnector/ENXSBGridConnectorClient.html?program=emxTask:getURLDeliverables&table=PMCBookmarkSummary&toolbar=PMCDeliverablesBookmarkToolBar&selection=multiple&Export=false&sortColumnName=Name&sortDirection=ascending&header=emxProgramCentral.Common.Bookmarks&HelpMarker=emxhelpdeliverables&hideLaunchButton=true&showRMB=false&postProcessJPO=emxProgramCentralUtil:postProcessPortalCmdSBRefresh&customize=false&displayView=details&autoFilter=false&showPageURLIcon=false&rowGrouping=false&findMxLink=false&multiColumnSort=false&objectCompare=false&showClipboard=false";

		}
		String objectId = emxGetParameter(request, "objectId");

		DomainObject dom = DomainObject.newInstance(context, objectId);
		StringList slBookmarkSelect = new StringList();
		slBookmarkSelect.add(DomainConstants.SELECT_CURRENT);
		//slBookmarkSelect.add(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
		Map bookmarkInfoMap = dom.getInfo(context, slBookmarkSelect);

		String strCurrentState = (String) bookmarkInfoMap.get(DomainConstants.SELECT_CURRENT);
		boolean editFlag = true;
		if (ProgramCentralConstants.STATE_PROJECT_TASK_REVIEW.equalsIgnoreCase(strCurrentState)
				|| ProgramCentralConstants.STATE_PROJECT_TASK_COMPLETE.equalsIgnoreCase(strCurrentState)) {
			editFlag = false;
		}
		if (editFlag) {
			strURL += "&editLink=true";
		}

		Enumeration requestParams = emxGetParameterNames(request);
		StringBuilder url = new StringBuilder();

		if (requestParams != null) {
			while (requestParams.hasMoreElements()) {
				String param = (String) requestParams.nextElement();
				String value = emxGetParameter(request, param);
				url.append("&" + param);
				url.append("=" + XSSUtil.encodeForURL(context, value));
			}
			strURL += url.toString();
		}
%>
<script language="javascript">
 var strUrl = "<%=strURL%>";
 document.location.href = strUrl;
</script>
<%
	} else if ("PMCReferenceDocumentURL".equalsIgnoreCase(strMode)) {
		String strURL = "../common/emxIndentedTable.jsp?program=emxTask:getURLReferenceDocuments&table=PMCBookmarkSummary&toolbar=PMCReferenceDocumentsBookmarkToolBar&selection=multiple&Export=false&sortColumnName=Name&sortDirection=ascending&header=emxProgramCentral.Common.Bookmarks&HelpMarker=emxhelpdeliverables&hideLaunchButton=true&showRMB=false&postProcessJPO=emxProgramCentralUtil:postProcessPortalCmdSBRefresh&customize=false&displayView=details&autoFilter=false&showPageURLIcon=false&rowGrouping=false&findMxLink=false&multiColumnSort=false&objectCompare=false&showClipboard=false";
		String objectId = emxGetParameter(request, "objectId");

		DomainObject dom = DomainObject.newInstance(context, objectId);
		StringList slBookmarkSelect = new StringList();
		slBookmarkSelect.add(DomainConstants.SELECT_CURRENT);
		//slBookmarkSelect.add(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
		Map bookmarkInfoMap = dom.getInfo(context, slBookmarkSelect);

		String strCurrentState = (String) bookmarkInfoMap.get(DomainConstants.SELECT_CURRENT);
		boolean editFlag = true;
		if (ProgramCentralConstants.STATE_PROJECT_TASK_REVIEW.equalsIgnoreCase(strCurrentState)
				|| ProgramCentralConstants.STATE_PROJECT_TASK_COMPLETE.equalsIgnoreCase(strCurrentState)) {
			editFlag = false;
		}
		if (editFlag) {
			strURL += "&editLink=true";
		}

		Enumeration requestParams = emxGetParameterNames(request);
		StringBuilder url = new StringBuilder();

		if (requestParams != null) {
			while (requestParams.hasMoreElements()) {
				String param = (String) requestParams.nextElement();
				String value = emxGetParameter(request, param);
				url.append("&" + param);
				url.append("=" + XSSUtil.encodeForURL(context, value));
			}
			strURL += url.toString();
		}
%>
<script language="javascript">
 var strUrl = "<%=strURL%>";
 document.location.href = strUrl;
</script>
<%

}else if("searchResolvesRIO".equalsIgnoreCase(strMode)) {
    String objId   = emxGetParameter(request, "objectId");
    objId          = XSSUtil.encodeURLForServer(context, objId);

    String strURL = "../common/emxIndentedTable.jsp?program=emxProjectSpace:getRIOItems&table=PMCResolvesRIOTable&selection=multiple&header=emxProgramCentral.AddResolvesRIO&sortColumnName=Name&sortDirection=ascending&Export=false&freezePane=Name&showClipboard=false&showPageURLIcon=false&triggerValidation=false&massPromoteDemote=false&displayView=details&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&submitURL=../programcentral/emxProjectManagementUtil.jsp?mode=connectRIOItems&&hideLaunchButton=true&hideToolbar=false";
    strURL +="&objectId="+objId;
       %>
       <script language="javascript">
       var strUrl = "<%=strURL%>";
  	   //document.location.href = strUrl;	
  	   showModalDialog(strUrl, "812", "700", "true", "popup");
       </script>
       <%


} else if("searchResolves".equalsIgnoreCase(strMode)) {
    String objId   = emxGetParameter(request, "objectId");
    objId          = XSSUtil.encodeURLForServer(context, objId);

    String strURL = "../common/emxIndentedTable.jsp?program=emxRisk:getResolvingProjectList&table=PMCProjectSummaryForProjects&selection=multiple&header=emxProgramCentral.AddResolvedBy&sortColumnName=Name&sortDirection=ascending&Export=false&freezePane=Name&showClipboard=false&showPageURLIcon=false&triggerValidation=false&massPromoteDemote=false&displayView=details&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&submitURL=../programcentral/emxProjectManagementUtil.jsp?mode=connectResolves&&hideLaunchButton=true&hideToolbar=false";
    strURL +="&objectId="+objId;
       %>
       <script language="javascript">
       var strUrl = "<%=strURL%>";
  	   //document.location.href = strUrl;	
  	   showModalDialog(strUrl, "812", "700", "true", "popup");
       </script>
       <%


} else if("disconnectResolves".equalsIgnoreCase(strMode)) {

    String[] selectedRowArray = emxGetParameterValues (request, "emxTableRowId");
    ArrayList<String> resolvesIdList = new ArrayList<String>();

    // Get the RelID from the | delimited
    for (int i=0; i<selectedRowArray.length; i++) {
        String selectedRowString = selectedRowArray[i];
        StringList idList = FrameworkUtil.split(selectedRowArray[i], "|");
        resolvesIdList.add((String)idList.get(0));
    }

    if(resolvesIdList != null && resolvesIdList.size() > 0) {

        for (int i=0;i<resolvesIdList.size();i++) {
            String errorMessage ="";

            try {
                String relID = (String) resolvesIdList.get(i);
                DomainRelationship.disconnect (context,relID);
            } catch (Exception exp) {
                //TODO - Fix the Message
                errorMessage = exp.getMessage();
            %>
            <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
            </script>
            <%
            }
        }
    %>
    <script language="javascript">
        var topFrame = findFrame(getTopWindow(), "PMCResolvesItems");
        if (topFrame != null) {
			topFrame.location.href = topFrame.location.href;                        
		}else{
			topFrame = findFrame(getTopWindow(), "detailsDisplay");
			if (topFrame != null) {
				topFrame.location.href = topFrame.location.href;  
			}
		}	
     </script>
    <%
 }

    }
    else if("disconnectResolvesRIO".equalsIgnoreCase(strMode)) {

        ArrayList<String> resolvesIdList = new ArrayList<String>();

		String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
		String[] emxRelIds = new String[emxTableRowIds.length];
		for (int i = 0; i < emxTableRowIds.length; i++) {
			String relId = (String) ((Map) ProgramCentralUtil.parseTableRowId(context, emxTableRowIds[i]))
					.get("relId");
			emxRelIds[i] = relId;
		}
		String errorMessage = "";
		try {
			
			if (null != emxRelIds) {
				DomainRelationship.disconnect(context, emxRelIds);
			}
        
    				} catch (Exception exp) {
    					//TODO - Fix the Message
    					errorMessage = exp.getMessage();
    %>
            <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
            </script>
            <%
            }
    %>
    <script language="javascript">
        var topFrame = findFrame(getTopWindow(), "PMCResolvesItems");
        if (topFrame != null) {
			topFrame.location.href = topFrame.location.href;                        
		}else{
			topFrame = findFrame(getTopWindow(), "detailsDisplay");
			if (topFrame != null) {
				topFrame.location.href = topFrame.location.href;  
			}
		}	
     </script>
    <%
	} else if ("connectResolves".equalsIgnoreCase(strMode)) {

     String[] selectedRowArray = emxGetParameterValues(request, "emxTableRowId");
     String[] parentId          = emxGetParameterValues(request, "objectId");

	 DomainObject domObj=DomainObject.newInstance (context,parentId[0]);// as only one risk or opportunity is avaible at a given time
     ArrayList<String> selectedIdList = new ArrayList<String>();

     for (int i=0;i<selectedRowArray.length;i++) {
         StringList idList = FrameworkUtil.split(selectedRowArray[i], "|");
         selectedIdList.add(idList.get(0));
     }
     //String errMsg = "";
     DomainObject projectObj = DomainObject.newInstance (context);
     for (int i=0;i<selectedIdList.size();i++) {
         String errorMessage ="";

     try {
             String projectID = (String) selectedIdList.get(i);
             projectObj.setId(projectID);
				DomainRelationship.connect(context, domObj, RiskManagement.RELATIONSHIP_RESOLUTION_PROJECT,
						projectObj);
         } catch (Exception exp) {
             //TODO - Fix the Message
             errorMessage = exp.getMessage();
 %>
         <script language="javascript" type="text/javaScript">
             alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
</script>
<%
      }
     }     
%>
<script language="javascript">
			var topFrame = findFrame(getTopWindow().window.getWindowOpener().getTopWindow().parent, "PMCResolvesItems");
			if (topFrame != null) {
					topFrame.location.href = topFrame.location.href;                        
				}else{
					topFrame = findFrame(getTopWindow().window.getWindowOpener().getTopWindow().parent, "detailsDisplay");
					if (topFrame != null) {
						topFrame.location.href = topFrame.location.href;  
					}
				}				 
			parent.window.closeWindow();
			
</script>
<%


	}else if("PMCWBS".equalsIgnoreCase(strMode)){
		//Modified for performance improvement of WBS
		String portalCmd = (String) emxGetParameter(request, "portalCmdName");
		String objectId = XSSUtil.encodeURLForServer(context,emxGetParameter(request, "objectId"));
		Map paramMap = new HashMap(1);
		paramMap.put("objectId", objectId);

		String[] methodArgs = JPO.packArgs(paramMap);
		boolean hasModifyAccess = (boolean) JPO.invoke(context, "emxTask", null, "hasModifyAccess", methodArgs,
				Boolean.class);

		DomainObject dmoObject = DomainObject.newInstance(context, objectId);
		String projectPolicy = dmoObject.getInfo(context, ProgramCentralConstants.SELECT_POLICY);

                String strGridActive = "false";
                try {
			strGridActive = EnoviaResourceBundle.getProperty(context, "emxFramework.Activate.GridView");
		} catch (FrameworkException e) {
			strGridActive = "false";
		}
		StringBuilder urlBuilder = new StringBuilder();
		//HondaGrid-FUN087459
		// replace common/emxIndentedTable.jsp with webapps/ENXSBGridConnectorClient/ENXSBGridConnectorClient.html 
		if (!"true".equalsIgnoreCase(strGridActive)) {
			urlBuilder.append("../common/emxIndentedTable.jsp?tableMenu=PMCWBSTableMenu");
		}
		else
		{
			urlBuilder.append("../webapps/ENXSBGridConnector/ENXSBGridConnectorClient.html?tableMenu=PMCWBSTableMenuENXSBGrid");
			//urlBuilder.append("&showTouchStyle=true");
		}
		urlBuilder.append("&expandProgramMenu=PMCWBSListMenu");
		urlBuilder.append("&freezePane=Name");
		urlBuilder.append("&selection=multiple");
		urlBuilder.append("&HelpMarker=emxhelpwbstasklist");
		urlBuilder.append("&header=emxProgramCentral.Common.WorkBreakdownStructureSB");
		urlBuilder.append("&sortColumnName=ID");
		urlBuilder.append("&findMxLink=false");
		urlBuilder.append("&editRelationship=relationship_Subtask");
		urlBuilder.append("&suiteKey=ProgramCentral");
		urlBuilder.append("&SuiteDirectory=programcentral");
		urlBuilder.append("&resequenceRelationship=relationship_Subtask");
		urlBuilder.append("&connectionProgram=emxTask:cutPasteTasksInWBS");
		urlBuilder.append("&postProcessJPO=emxTask:updateScheduleChanges");
		urlBuilder.append("&hideLaunchButton=true");
		urlBuilder.append("&parallelLoading=true");
		urlBuilder.append("&objectId=" + objectId);
		urlBuilder.append("&showPageURLIcon=false");
		urlBuilder.append("&cacheEditAccessProgram=true");

		if (!ProgramCentralConstants.POLICY_PROJECT_SPACE_HOLD_CANCEL.equalsIgnoreCase(projectPolicy)) {
			urlBuilder.append("&toolbar=PMCWBSToolBar");
		}

		if (hasModifyAccess && !ProgramCentralConstants.POLICY_PROJECT_SPACE_HOLD_CANCEL.equalsIgnoreCase(projectPolicy)) {
			urlBuilder.append("&editLink=true");
			urlBuilder.append("&massPromoteDemote=true");
		}else {
			urlBuilder.append("&massPromoteDemote=false");
			urlBuilder.append("&rowGrouping=false");
			urlBuilder.append("&objectCompare=false");
			urlBuilder.append("&showClipboard=false");
			urlBuilder.append("&showPageURLIcon=false");
			urlBuilder.append("&triggerValidation=false");
			urlBuilder.append("&displayView=details");
			urlBuilder.append("&multiColumnSort=false");
			urlBuilder.append("&showRMB=false");
		}

		Enumeration requestParams = emxGetParameterNames(request);
	  	if(requestParams != null){
   		  while(requestParams.hasMoreElements()){
       		  String param = (String)requestParams.nextElement();
       		  String value = emxGetParameter(request,param);
       		  urlBuilder.append("&"+param);
       		  urlBuilder.append("="+XSSUtil.encodeForURL(context,value));
   		  }
	  	}

	  	boolean isAnDInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionAerospaceProgramManagementAccelerator",false,null,null);
		if(isAnDInstalled){
			boolean isLocked  = Task.isParentProjectLocked(context, objectId);
			if(isLocked){
				urlBuilder.append("&hideRootSelection=true");
				urlBuilder.append("&editRootNode=false");
				urlBuilder.append("&preProcessJPO=emxTask:preProcessCheckForLock");
			}
		}

		//Added by di7
		//Plz do not remove below lines of code. We are cacheing subTypelist of passed type to improve performance of WBS
		String[] typeArray = new String[]{DomainObject.TYPE_PROJECT_SPACE,
				DomainObject.TYPE_PROJECT_CONCEPT,
				DomainObject.TYPE_PROJECT_TEMPLATE,
				DomainObject.TYPE_TASK_MANAGEMENT,
				ProgramCentralConstants.TYPE_MILESTONE,
				ProgramCentralConstants.TYPE_TASK,
				ProgramCentralConstants.TYPE_PHASE,
				ProgramCentralConstants.TYPE_GATE};

		long start = System.currentTimeMillis();
		ProgramCentralUtil.getDerivativeType(context, typeArray);
		DebugUtil.debug("Time taken by getDerivativeType(ms)::"+(System.currentTimeMillis()-start));
		%>
        <script language="javascript">
	      	var strUrl = "<%=urlBuilder.toString()%>";
	  		strUrl = strUrl + "&maxCellsToDraw=2000&scrollPageSize=50";
	        var portalName = "<%=portalCmd%>";
        		var displaytopFrame = findFrame(getTopWindow(), "detailsDisplay");
        		var topFrame;
        		if(displaytopFrame){
    			 	topFrame = findFrame(displaytopFrame, portalName);
        		}else{
        			topFrame = findFrame(getTopWindow(), portalName);
        		}
	        if(topFrame == null){
		     	topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
		     	if(null == topFrame){
		     		topFrame = findFrame(getTopWindow(), "detailsDisplay");
		     	}
	  		}
	        topFrame.location.href = strUrl;
        </script>
       <%
	}else if("PMCProjectTemplateWBS".equalsIgnoreCase(strMode) || "type_ProjectTemplate".equalsIgnoreCase(strMode)){
		String objectId = emxGetParameter(request, "objectId");
 		Map paramMap = new HashMap(1);
   	    paramMap.put("objectId",objectId);

       String[] methodArgs = JPO.packArgs(paramMap);
        boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxProjectTemplate", null, "hasAccessToTemplateWBSActionMenu", methodArgs, Boolean.class);

                String strGridActive = "false";
                try {
			strGridActive = EnoviaResourceBundle.getProperty(context, "emxFramework.Activate.GridView");
		} catch (FrameworkException e) {
			strGridActive = "false";
		}
		StringBuilder urlBuilder = new StringBuilder();
		//HondaGrid-FUN087459
		// replace common/emxIndentedTable.jsp with webapps/ENXSBGridConnectorClient/ENXSBGridConnectorClient.html 
		if (!"true".equalsIgnoreCase(strGridActive)) {
			urlBuilder.append("../common/emxIndentedTable.jsp?expandProgram=emxTask:getWBSProjectTemplateSubtasks");
			urlBuilder.append("&table=PMCWBSProjectTemplateViewTable");
		}
		else
		{
			urlBuilder.append("../webapps/ENXSBGridConnector/ENXSBGridConnectorClient.html?expandProgram=emxTask:getWBSProjectTemplateSubtasks");
			urlBuilder.append("&table=PMCWBSProjectTemplateViewTableENXSBGrid");
			//urlBuilder.append("&showTouchStyle=true");
		}
		urlBuilder.append("&toolbar=PMCWBSProjectTemplateToolBar");
		urlBuilder.append("&freezePane=Name&selection=multiple");
		urlBuilder.append("&HelpMarker=emxhelpprojecttemplatewbs");
		urlBuilder.append("&header=emxProgramCentral.Common.WorkBreakdownStructureSB");
		urlBuilder.append("&sortColumnName=ID");
		urlBuilder.append("&findMxLink=false");
		urlBuilder.append("&postProcessJPO=emxTask:updateScheduleChanges");
		urlBuilder.append("&editRelationship=relationship_Subtask");
		urlBuilder.append("&resequenceRelationship=relationship_Subtask");
		urlBuilder.append("&suiteKey=ProgramCentral");
		urlBuilder.append("&SuiteDirectory=programcentral");
		urlBuilder.append("&connectionProgram=emxTask:cutPasteTasksInWBS");
		urlBuilder.append("&hideLaunchButton=true");
		urlBuilder.append("&displayView=details");
		urlBuilder.append("&cellwrap=false");
		urlBuilder.append("&showClipboard=false");
		urlBuilder.append("&parallelLoading=true");

        Enumeration requestParams = emxGetParameterNames(request);

		if(requestParams != null){
			while(requestParams.hasMoreElements()){
				String param = (String)requestParams.nextElement();
				String value = emxGetParameter(request,param);
				urlBuilder.append("&"+param);
				urlBuilder.append("="+XSSUtil.encodeForURL(context, value));
			}
		}

 		if(hasModifyAccess){
			urlBuilder.append("&editLink=true");
 		}

 		%>
        <script language="javascript">
	   		 var strUrl = "<%=urlBuilder.toString()%>";
	   		 document.location.href = strUrl;
        </script>
        <%
	}else if("Rollup".equalsIgnoreCase(strMode)){
    	String portalCmd 	= emxGetParameter(request,"portalCmdName");
		String objectId 	= emxGetParameter(request, "objectId");
    	String strUrl = "../programcentral/emxProjectManagementUtil.jsp?mode=postRollup&portalCmdName="+portalCmd+"&objectId="+objectId;

 		%>
 			<script language="javascript">
 				var portalName = "<%=portalCmd%>";
 				var topFrame = findFrame(getTopWindow(), portalName);

 				if(topFrame == null){
 					topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
 					if(null == topFrame){
     				    topFrame = findFrame(getTopWindow(), "detailsDisplay");
 					}

 					if(null == topFrame){
 						topFrame = findFrame(getTopWindow(), "PMCWBS");
 					}
 				}
				setTimeout(function() {
 					topFrame.toggleProgress('visible');
 				    document.location.href = "<%=strUrl%>";
			    },25);

 			</script>
 			<%
    }else if("postRollup".equalsIgnoreCase(strMode)){
        String portalCmd 	= emxGetParameter(request,"portalCmdName");
		String objectId 	= emxGetParameter(request, "objectId");
		long start 			= System.currentTimeMillis();

		Map rollupMap = null;
		try{
			PropertyUtil.setGlobalRPEValue(context,"PERCENTAGE_COMPLETE", "true");
			rollupMap = TaskDateRollup.rolloutProject(
				context,
				new StringList(objectId),
				true,
				true);
		}catch(FrameworkException fe){
			fe.printStackTrace();
		}finally{
			PropertyUtil.setGlobalRPEValue(context,"PERCENTAGE_COMPLETE", "false");
		}

		List impactedObjList = (List)rollupMap.get("impactedObjectIds");
		Map updatedTaskMap = (Map)rollupMap.get("common.Task_updatedDates");
		DebugUtil.debug("Manual Rollup time:"+(System.currentTimeMillis()-start));

		String rollupMessage 	= DomainObject.EMPTY_STRING;
		String isWholePageRefreshRequierd=(String)CacheUtil.getCacheObject(context, "isWholePageRefreshRequierd");
		CacheUtil.removeCacheObject(context, "isWholePageRefreshRequierd");
		%>
          <script language="javascript">
        		var portalName = "<%=portalCmd%>";
        		var rollupMsg = "<%=rollupMessage%>";
				var isWholePageRefreshRequierd = "<%=isWholePageRefreshRequierd%>";

        		var topFrame = findFrame(getTopWindow(), portalName);
          		if(topFrame == null){
     				topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
     				if(null == topFrame){
     				    topFrame = findFrame(getTopWindow(), "detailsDisplay");
     				}
     			}

    	      setTimeout(function() {
     	        	toggleRollupIcon(topFrame,"iconActionUpdateDatesActive","iconActionUpdateDates");
	    	    	  if("yes"==isWholePageRefreshRequierd)
     	        		{
     	        		topFrame.location.href=topFrame.location.href;
     	        		}else{
	    	    	  topFrame.emxEditableTable.refreshStructureWithOutSort();
     	        		}
    	      	  topFrame.toggleProgress('hidden');
		 		  },25);

          </script>
        <%

    }else if("validateKindOf".equalsIgnoreCase(strMode)){
		JsonObjectBuilder jsonObjectBuilder = Json.createObjectBuilder();
    	String objectType 		= emxGetParameter(request,"objectType");
    	Map<String,StringList> derivativeMap = ProgramCentralUtil.getDerivativeTypeListFromUtilCache(context, objectType);

    	if(derivativeMap.isEmpty()){
    		derivativeMap 	= ProgramCentralUtil.getDerivativeType(context, objectType);
    	}

    	StringList passTypeList = derivativeMap.get(objectType);
    	jsonObjectBuilder.add("isMilestone",passTypeList.contains(ProgramCentralConstants.TYPE_MILESTONE));
    	jsonObjectBuilder.add("isGate",passTypeList.contains(ProgramCentralConstants.TYPE_GATE));

    	out.clear();
   		out.write(jsonObjectBuilder.build().toString());

   		return;
    }else if("getDueTasks".equalsIgnoreCase(strMode)) {
		StringList finalObjectList = new StringList();
		String sMethodName = request.getParameter("method"); 
		StatusReport report = (StatusReport)session.getAttribute("store");
		Method method = null;
		try{
			method = report.getClass().getMethod(sMethodName);
		}catch(Exception e) {
			e.printStackTrace();
		}
		MapList mlObjects = (MapList)method.invoke(report);
		int mlObjectSize = mlObjects.size();
		String objIdListStr = "";
		DomainObject dobj = new DomainObject();
		for(int i = 0; i<mlObjectSize; i++){
			Map objectMap = (Map)mlObjects.get(i);
			String taskobjId = (String)objectMap.get(ProgramCentralConstants.SELECT_ID);
			if(!(finalObjectList.contains(taskobjId))){
				finalObjectList.add(taskobjId);
			}
		}
		//=======================================================================
		String[] taskIdArr = new String[finalObjectList.size()];
		
		for(int i = 0; i<finalObjectList.size(); i++){
			taskIdArr[i] = finalObjectList.get(i);
		}
				MapList phyObjects  = DomainObject.getInfo(context, taskIdArr, new StringList(ProgramCentralConstants.SELECT_PHYSICALID));
				for(int i = 0; i<phyObjects.size(); i++){
					Map objectMap = (Map)phyObjects.get(i);
					String taskPhyId = (String)objectMap.get(ProgramCentralConstants.SELECT_PHYSICALID);
					objIdListStr +=","+taskPhyId; 
				}
				//=======================================================================
		out.clear();
		out.write(objIdListStr);
		return;
    }else if ("ChangePolicy".equalsIgnoreCase(strMode)) {
		String selectedType = emxGetParameter(request, "SelectedType");
        String selectedPolicy = emxGetParameter(request, "selectedPolicy");
		JsonObjectBuilder jsonObjectBuilder = Json.createObjectBuilder();
		String policyName=ProgramCentralConstants.EMPTY_STRING;
		String policyDisplayValue=ProgramCentralConstants.EMPTY_STRING;
		if (ProgramCentralUtil.isNotNullString(selectedType)) {
			Map<String, StringList> derivativeMap = ProgramCentralUtil
					.getDerivativeTypeListFromUtilCache(context, selectedType);

			if (derivativeMap.isEmpty()) {
				derivativeMap = ProgramCentralUtil.getDerivativeType(context, selectedType);
			}

			StringList passTypeList = derivativeMap.get(selectedType);

			MapList policyList = mxType.getPolicies(context, selectedType, true);
			if (policyList != null && policyList.size() > 0) {

			if(ProgramCentralUtil.isNotNullString(selectedPolicy)){
				selectedPolicy =  PropertyUtil.getSchemaProperty(context, selectedPolicy);
			Iterator itr = policyList.iterator();
			while (itr.hasNext())
			{
				Map policyMap = (Map) itr.next();
				policyName=(String)policyMap.get("name");
				
				if(policyName.equalsIgnoreCase(selectedPolicy)){
					policyName = (String) policyMap.get("name");
					policyDisplayValue = EnoviaResourceBundle.getAdminI18NString(context, "Policy",policyName, context.getSession().getLanguage());
					break;
				}
			}
			}
				else{
					policyList.sort("name", ProgramCentralConstants.ASCENDING_SORT,
				ProgramCentralConstants.SORTTYPE_STRING);
			policyList.sort("name", ProgramCentralConstants.ASCENDING_SORT,
			ProgramCentralConstants.SORTTYPE_STRING);
			Map policyMap = (Map) policyList.get(0);
			policyName = (String) policyMap.get("name");
			
			policyDisplayValue = EnoviaResourceBundle.getAdminI18NString(context, "Policy",
					policyName, context.getSession().getLanguage());

			}	
				if (passTypeList != null && (passTypeList.contains(ProgramCentralConstants.TYPE_MILESTONE)
						|| passTypeList.contains(ProgramCentralConstants.TYPE_GATE))) {
					jsonObjectBuilder.add("Duration", "0");
					jsonObjectBuilder.add("Policy", policyDisplayValue);
					jsonObjectBuilder.add("isMilestone",
							passTypeList.contains(ProgramCentralConstants.TYPE_MILESTONE));
					jsonObjectBuilder.add("isGate", passTypeList.contains(ProgramCentralConstants.TYPE_GATE));
				} else {
					jsonObjectBuilder.add("Duration", "1");
					jsonObjectBuilder.add("Policy", policyDisplayValue);
				}
			}
		}

		out.clear();
		out.write(jsonObjectBuilder.build().toString());
		return;
  }	else if ("EffortEstimatedEndDate".equalsIgnoreCase(strMode)) {
		%>
	 	<script language="javascript" type="text/javaScript">
			var topFrame = findFrame(getTopWindow(), "PMCWBS");
	    	  topFrame.emxEditableTable.refreshStructureWithOutSort();
	    	  getTopWindow().closeSlideInDialog();
	 	</script>
<%
}  else if("addGovernedItems".equals(strMode)) {
		String governingId = emxGetParameter( request, "objectId" );
        	DomainObject governing = DomainObject.newInstance(context, governingId);

        	String sTableRowId[] = emxGetParameterValues( request, "emxTableRowId" );
        	StringList slObjIDToConnect = new StringList();
        	DomainObject toBeGoverned = DomainObject.newInstance(context);
			for(int i=0; i<sTableRowId.length; i++){
				String sTempObj = sTableRowId[i];
				Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
				String toBeGovernedId = (String)mParsedObject.get("objectId");
				toBeGoverned.setId(toBeGovernedId);
				try {
					DomainRelationship.connect(context, toBeGoverned, ProgramCentralConstants.RELATIONSHIP_GOVERNING_PROJECT, governing);
		        	DomainRelationship.connect(context, toBeGoverned, ProgramCentralConstants.RELATIONSHIP_RELATED_PROJECT, governing);
				} catch (Exception e) {
					e.printStackTrace();
					throw new MatrixException(e);
				}
			}
			%>
			<script language="javascript" type="text/javaScript">				
				 getTopWindow().window.getWindowOpener().location.href=getTopWindow().window.getWindowOpener().location.href;
				 getTopWindow().window.closeWindow();										
			</script>
			<%
	} else if("removeGovernedItems".equals(strMode)) {
			String sTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		String[] objArrayIds = new String[sTableRowId.length];
		StringList relIds = new StringList();

		for (int i = 0,len=sTableRowId.length; i <len ; i++) {
			Map<String,String> mParsedObject = ProgramCentralUtil.parseTableRowId(context, sTableRowId[i]);
			objArrayIds[i] = mParsedObject.get("objectId");
			relIds.addElement(mParsedObject.get("relId"));
		}

		String SELECT_RELATED_PROJECT_REL_ID = "from[" + ProgramCentralConstants.RELATIONSHIP_RELATED_PROJECT+ "].id";
		
		StringList objectSelects = new StringList(1);
		objectSelects.addElement(SELECT_RELATED_PROJECT_REL_ID);

		BusinessObjectWithSelectList bwsl = 
				ProgramCentralUtil.getObjectWithSelectList(context, objArrayIds, objectSelects, false);
		for(int i=0,len = objArrayIds.length;i<len;i++){
			BusinessObjectWithSelect bws = bwsl.getElement(i);
			relIds.addElement(bws.getSelectData(SELECT_RELATED_PROJECT_REL_ID));
		}

		String[] objRelIds = new String[relIds.size()];
		relIds.toArray(objRelIds);
		try {
			DomainRelationship.disconnect(context, objRelIds);
		} catch (Exception e) {
			e.printStackTrace();
			throw new MatrixException(e);
		}
		
		%>
		<script language="javascript" type="text/javaScript">
						parent.location.href = parent.location.href										
					</script>
		<%
	}else if("PMCtype_ProjectVault".equalsIgnoreCase(strMode)) {
	
		String strURL = "../common/emxIndentedTable.jsp?tableMenu=PMCFolderTableMenu&toolbar=PMCFolderSummaryToolBar&header=emxProgramCentral.Common.Folders&"+
	 					 "HelpMarker=emxhelpfoldersummary&Export=true&selection=multiple&expandProgram=emxProjectFolder:getTableExpandProjectVaultData"+
						"&freezePane=Name&sortColumnName=Name&preProcessJPO=emxProjectFolder:preProcessCheckForEdit&connectionProgram=emxProjectFolder:cutPasteObjectsInFolderStructureBrowser"
						+"&editRelationship=relationship_SubVaults,relationship_VaultedDocumentsRev2"
						+"&resequenceRelationship=relationship_ProjectVaults,relationship_SubVaults,relationship_VaultedDocumentsRev2&massPromoteDemote=false&postProcessJPO=emxTask:postProcessRefresh";
		
		String objectId = emxGetParameter(request, "objectId");
		Map paramMap = new HashMap(1);
		paramMap.put("objectId",objectId);              
		String[] methodArgs = JPO.packArgs(paramMap);
		boolean editFlag  = (boolean) JPO.invoke(context,"emxProjectFolder", null, "hasAccessForFolderAndDocumentActions", methodArgs, Boolean.class);

		if(editFlag){
			strURL += "&editLink=true";
		}

		Enumeration requestParams = emxGetParameterNames(request);
		StringBuilder url = new StringBuilder();

		if(requestParams != null){
			while (requestParams.hasMoreElements()) {
				String param = (String) requestParams.nextElement();
				String value = emxGetParameter(request, param);
				url.append("&" + param);
				url.append("=" + XSSUtil.encodeForURL(context, value));
			}
			strURL += url.toString();
		}
%>
<script language="javascript">
	var strUrl = "<%=strURL%>";
	document.location.href = strUrl;
</script>
<%
}else if("addExistingRisk".equalsIgnoreCase(strMode)){
		String addExistingRiskURL = "../common/emxIndentedTable.jsp?table=PMCExistingRisksSummary&selection=multiple&Export=false&sortColumnName=Title&sortDirection=ascending&header=emxProgramCentral.Common.AddExisting&hideLaunchButton=true&program=emxRisk:getRiskForAddExisting&submitURL=../programcentral/emxProjectManagementUtil.jsp?mode=addExistingRiskToTask&Export=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&massPromoteDemote=false&displayView=details&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&freezePane=Name&hideToolbar=false";
		Enumeration requestParams = emxGetParameterNames(request);
	  	StringBuilder urlParameters = new StringBuilder();
	  	if(requestParams != null){
	  	  String objectId = emxGetParameter(request,"objectId");	
		  urlParameters.append("&objectId="+objectId);
		  addExistingRiskURL = addExistingRiskURL + urlParameters.toString(); 
 	  	}
%>
	<script language="javascript" type="text/javaScript">
	 var strUrl = "<%=addExistingRiskURL%>";
	 //document.location.href = strUrl;	
	 showModalDialog(strUrl, "812", "700", "true", "popup");	
	</script>
<%
	}else if("addExistingRiskToTask".equalsIgnoreCase(strMode)){
		 String errorMsg = ProgramCentralConstants.EMPTY_STRING;
		 String parentObjId = emxGetParameter(request, "objectId");
		 RiskHolder parentObj = new ProjectSpace(parentObjId);
		 boolean isOfProjectType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_PROJECT_SPACE,parentObjId);
		    String[] ids = emxGetParameterValues(request, "emxTableRowId");
		    if(null==ids)
		    {
		    	errorMsg = EnoviaResourceBundle.getProperty(context,"emxProgramCentralStringResource",context.getLocale(), "emxProgramCentral.Common.SelectItem"); 
			}
			else
			{

			   try{
				   for(int i =0, len = ids.length; i<len;i++){
				    	StringList riskIdList = StringUtil.split(ids[i], "|");
				    	
				    	if( riskIdList.size() >= 1 ){
				    		String riskId = (String)riskIdList.get(1);
				    		 Risk risk    = new Risk(riskId);
				    		 // start a write transaction
				             ContextUtil.startTransaction(context, true);
				    		 DomainRelationship.connect(context, (DomainObject) parentObj, Risk.RELATIONSHIP_RISK, risk);
				    		 DomainRelationship.connect(context, risk, Risk.RELATIONSHIP_RISK_ITEM, (DomainObject) parentObj);
				    		 // commit work
				             ContextUtil.commitTransaction(context);
				    	}
				    }
			   }catch(Exception e){
				   e.printStackTrace();
	 	}
		}
		%>
		 	<script language="javascript" type="text/javaScript">
			var errorMsg = "<%=XSSUtil.encodeForJavaScript(context,errorMsg)%>";
		 	if(errorMsg != null && errorMsg!=""){
				alert(errorMsg);
				getTopWindow().location.href=getTopWindow().location.href;
			}
			else{
				var topFrame = findFrame(getTopWindow().window.getWindowOpener().getTopWindow().parent, "PMCProjectRisk");
				if (topFrame != null) {
						topFrame.location.href = topFrame.location.href;                        
					}else{
						topFrame = findFrame(getTopWindow().window.getWindowOpener().getTopWindow().parent, "detailsDisplay");
						if (topFrame != null) {
							topFrame.location.href = topFrame.location.href;  
						}
					}				 
				parent.window.closeWindow();
				}
		 	</script>
			  <%
	} else if("DocumentPushSubscription".equalsIgnoreCase(strMode) || "BookmarkPushSubscription".equalsIgnoreCase(strMode)){
			
			StringBuilder errorMsg = new StringBuilder();
			
			String strURL = "../components/emxPushSubscriptionDialog.jsp?multiColumnSort=false&showClipboard=false&editLink=false&expandLevelFilter=false&objectBased=false&categoryTreeName=null";
			String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
			tableRowIdList = ProgramCentralUtil.parseTableRowId(context, tableRowIdList);
			String objectId = tableRowIdList[0]; // only single selection is allowed from UI
			String language	= context.getSession().getLanguage();
			
			if(ProgramCentralUtil.isNotNullString(objectId)){
				DomainObject dmoObject = DomainObject.newInstance(context, objectId);
				String SELECT_IS_TYPE_DOCUMENT = "type.kindof["+DomainConstants.TYPE_DOCUMENT+"]";
				String SELECT_IS_WORKSPACE_VAULT = "type.kindof["+DomainConstants.TYPE_WORKSPACE_VAULT+"]";
				StringList slSelects = new StringList();
				slSelects.add(SELECT_IS_TYPE_DOCUMENT);
				slSelects.add(SELECT_IS_WORKSPACE_VAULT);
				Map mapInfo = dmoObject.getInfo(context,slSelects);
				String sIsDocumentType = (String) mapInfo.get(SELECT_IS_TYPE_DOCUMENT);
				String sIsWorkspaceVaultType = (String) mapInfo.get(SELECT_IS_WORKSPACE_VAULT);
				
				if("FALSE".equalsIgnoreCase(sIsWorkspaceVaultType.trim()) && "FALSE".equalsIgnoreCase(sIsDocumentType.trim())){
					errorMsg.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
							"emxProgramCentral.FolderSubscription.SubscriptionMessage", language));
				}else{
					Enumeration requestParams = emxGetParameterNames(request);
					StringBuilder url = new StringBuilder();

					if (requestParams != null) {
						while (requestParams.hasMoreElements()) {
							String param = (String) requestParams.nextElement();
							String value = emxGetParameter(request, param);
							url.append("&" + param);
							url.append("=" + XSSUtil.encodeForURL(context, value));
						}
						strURL += url.toString();
					}
				}
			} 
			
		%>
			<script language="javascript">
				var errorMsg = "<%=XSSUtil.encodeForJavaScript(context,errorMsg.toString())%>";
				if(errorMsg == null || errorMsg ==""){
					 var strUrl =  "<%=XSSUtil.encodeForJavaScript(context,strURL)%>";
					showModalDialog(strUrl, '800', '575')
				}else{
					alert(errorMsg);
					
				}
			 </script>	
		<%
	}else if("FlatView".equalsIgnoreCase(strMode)){
		
		String portal 		= (String) emxGetParameter(request,"portal");
		String portalCmd 	= (String) emxGetParameter(request, "portalCmdName");
		String objectId = emxGetParameter(request, "objectId");
		
		if("PMCWhatIfPortal".equalsIgnoreCase(portal)){
			session.setAttribute("isGanttChartloaded","TRUE");
			objectId 	= (String)session.getAttribute("ExperimentObjectId");
			if(objectId == null || objectId.isEmpty()){
				objectId = emxGetParameter(request, "objectId");		
			}
		}
		
		String mqlCmd = "print bus $1 select $2 $3 $4 dump $5";
		String objectInfo = MqlUtil.mqlCommand(context, 
				false, 
				false, 
				mqlCmd, 
				false,
				objectId,
				"policy",
				"current.access[modify]",
				"type.kindof[Project Template]",
				"|");
		StringList objectInfoList = FrameworkUtil.split(objectInfo, "|");
		String projectPolicy 	= (String)objectInfoList.get(0);
		String hasModifyAccess 	= (String)objectInfoList.get(1);
		String isKindOfTemplate = (String)objectInfoList.get(2);
		
		StringBuilder url = new StringBuilder();
		//HondaGrid-FUN087459
		// replace common/emxIndentedTable.jsp with webapps/ENXSBGridConnectorClient/ENXSBGridConnectorClient.html 
		url.append("../common/emxIndentedTable.jsp?table=");
		
		if("True".equalsIgnoreCase(isKindOfTemplate)){
			url.append("PMCTemplateWBSFlatViewTable");
		}else{
			url.append("PMCWBSFlatViewTable");
		}
				
		url.append("&program=emxTask:getFlattenedWBS");
		url.append("&freezePane=Name");
		url.append("&selection=multiple");
		url.append("&HelpMarker=emxhelpwbstasklist");
		url.append("&header=emxProgramCentral.Common.WorkBreakdownStructureSB");
		url.append("&sortColumnName=ID");
		url.append("&findMxLink=false");
		url.append("&suiteKey=ProgramCentral");
		url.append("&SuiteDirectory=programcentral");
		url.append("&postProcessJPO=emxTask:updateScheduleChanges");
		url.append("&hideLaunchButton=true");
//TODO confirm with Dhruv - this parameter parallelLoading=true was not included in latest file, but was in FD03 file. 
		url.append("&parallelLoading=true");
		url.append("&pageSize=50");
		url.append("&maxCellsToDraw=2000");
		url.append("&scrollPageSize=50");
		url.append("&objectId=").append(objectId);
		url.append("&showPageURLIcon=false");
		url.append("&expandLevelFilter=false");
		url.append("&showRMB=false");

		if (!ProgramCentralConstants.POLICY_PROJECT_SPACE_HOLD_CANCEL.equalsIgnoreCase(projectPolicy) && "true".equalsIgnoreCase(hasModifyAccess)) {
			url.append("&toolbar=PMCWBSFlatViewToolbar");
			url.append("&editLink=true");
			url.append("&massPromoteDemote=true");
		} else {
			url.append("&massPromoteDemote=false");
			url.append("&rowGrouping=false");
			url.append("&objectCompare=false");
			url.append("&showClipboard=false");
			url.append("&showPageURLIcon=false");
			url.append("&triggerValidation=false");
			url.append("&displayView=details");
			url.append("&multiColumnSort=false");			
		}

		Enumeration requestParams = emxGetParameterNames(request);
		StringBuilder hiddenUrlParameter = new StringBuilder();

		if (requestParams != null) {
			while (requestParams.hasMoreElements()) {
				String param = (String) requestParams.nextElement();
				if(!param.equalsIgnoreCase("objectId")){
					
					if(param.equalsIgnoreCase("parentOID") && "PMCWhatIfPortal".equalsIgnoreCase(portal)){
						hiddenUrlParameter.append("&" + param);
						hiddenUrlParameter.append("=" + objectId);	
					}else{
					String value = emxGetParameter(request, param);
					hiddenUrlParameter.append("&" + param);
					hiddenUrlParameter.append("=" + value);	
				}
			}
			}
			url.append(hiddenUrlParameter.toString());
		}

		//Added by di7
		//Plz do not remove below lines of code. We are cacheing subTypelist of passed type to improve performance of WBS
		String[] typeArray = new String[]{DomainObject.TYPE_PROJECT_SPACE, DomainObject.TYPE_PROJECT_CONCEPT,
				DomainObject.TYPE_PROJECT_TEMPLATE, DomainObject.TYPE_TASK_MANAGEMENT,
				ProgramCentralConstants.TYPE_MILESTONE, ProgramCentralConstants.TYPE_TASK,
				ProgramCentralConstants.TYPE_PHASE, ProgramCentralConstants.TYPE_GATE};

		long start = System.currentTimeMillis();
		ProgramCentralUtil.getDerivativeType(context, typeArray);
		DebugUtil.debug("Time taken by getDerivativeType(ms)::" + (System.currentTimeMillis() - start));
%>
<script language="javascript">
	var strUrl = "<%=url.toString()%>";
	var portalName = "<%=portalCmd%>";
	var topFrame = findFrame(getTopWindow(), portalName);
	if (topFrame == null) {
		topFrame = findFrame(getTopWindow(), "detailsDisplay");
	}
	document.location.href = strUrl;
</script>
<%
	} else if ("FlatViewDelete".equalsIgnoreCase(strMode)) {
		String portalCmd 				= (String) emxGetParameter(request, "portalCmdName");
		String projectId = (String) emxGetParameter(request, "parentOID");
		
		session.setAttribute("emxTableRowId", emxGetParameterValues(request, "emxTableRowId"));
		session.setAttribute("emxTableRowIdForRefresh", emxGetParameterValues(request, "emxTableRowId"));

		StringBuilder url = new StringBuilder();
		url.append("../programcentral/emxProjectManagementUtil.jsp?mode=FlatViewDeleteCnf");
		url.append("&portalCmdName=").append(portalCmd);
		url.append("&projectId=").append(projectId);

		//String strUrl = "../programcentral/emxProjectManagementUtil.jsp?mode=FlatViewDeleteCnf&portalCmdName="+ portalCmd;
%>
<script language="javascript">
		
	var displaytopFrame = findFrame(getTopWindow(), "detailsDisplay");
	var topFrame = findFrame(displaytopFrame, "<%=portalCmd%>");
	if(topFrame == null){
		topFrame = findFrame(getTopWindow(), "<%=portalCmd%>");	
	}
	
	var result = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ConfirmTaskDelete</framework:i18nScript>");
	if(result){
		setTimeout(function() {
			topFrame.toggleProgress('visible');
			document.location.href = "<%=url.toString()%>";
		}, 10);
	}
</script>
<%
	} else if ("FlatViewDeleteCnf".equalsIgnoreCase(strMode)) {
		long start = System.currentTimeMillis();
		String projectId = (String) emxGetParameter(request, "projectId");
		String portalCmd = (String) emxGetParameter(request, "portalCmdName");
		String[] emxTableRowIds = (String[]) session.getAttribute("emxTableRowId");
		String[] refreshRowIds = (String[]) session.getAttribute("emxTableRowIdForRefresh");
		
		session.removeAttribute("emxTableRowIdForRefresh");
		session.removeAttribute("emxTableRowId");
		
		String[] objectIds = ProgramCentralUtil.parseTableRowId(context, emxTableRowIds);
		
		StringList tobeDeletedTaskIdList = new StringList();
		for(int i=0,len =objectIds.length;i<len;i++ ){
			String objId = objectIds[i];
			tobeDeletedTaskIdList.add(objId);
		}
		
		Map<String, StringList> returnMap = Task.checkForMandatoryAndEffort(context, tobeDeletedTaskIdList);
		
		StringList tobeDeletedIdList 	= returnMap.get("FinalIdsList");
		StringList taskStateAndIdList 	= returnMap.get("TaskStateAndIdList");
		
		StringList finalToBeDeletedIdList 	= new StringList();
		List<String> finalDeletedIdList 	= new ArrayList<>();
		
		for(int i=0,len=taskStateAndIdList.size();i<len;i++ ){
			String taskNameIdState =  (String)taskStateAndIdList.get(i);
		
			for(int j=0;j<tobeDeletedIdList.size();j++){
				String tobeDeletedId =  (String)tobeDeletedIdList.get(j);
				
				if(taskNameIdState != null && taskNameIdState.contains(tobeDeletedId)){
					finalToBeDeletedIdList.add(taskNameIdState);
				}
			}
		}
		
		StringBuilder notToBeDeletedTaskNameList = new StringBuilder();
		
		for(int j=0;j<finalToBeDeletedIdList.size();j++){
			String taskNameIdState =  (String)finalToBeDeletedIdList.get(j);
			//Name|objId|State
			StringList nameIdStateList = FrameworkUtil.split(taskNameIdState, "|");
			String currentState =  (String)nameIdStateList.get(2);
			
			if(!("Create".equalsIgnoreCase(currentState)||
					"Assign".equalsIgnoreCase(currentState))){
				if(notToBeDeletedTaskNameList.length()==0){
					notToBeDeletedTaskNameList.append((String)nameIdStateList.get(0));
				}else{
					notToBeDeletedTaskNameList.append(", "+(String)nameIdStateList.get(0));
				}
			}else{
				finalDeletedIdList.add((String)nameIdStateList.get(1));
			}
		}
		String notToBeDeletedTaskName = notToBeDeletedTaskNameList.toString();
		StringList slMandExcludeTaskNames	= returnMap.get("MandExcludeTaskNames"); 
		StringList slTaskWithEfforts 		= returnMap.get("TasksWithEffort");
		 
		boolean blMandatoryFlag = (slMandExcludeTaskNames.size()>0) ? true: false;
		boolean blTaskWithEffortsFlag = (slTaskWithEfforts.size()>0) ? true: false;
		DebugUtil.debug("Total time pre-process of delete operation::"+(System.currentTimeMillis()-start));

		boolean isSuccessfullyDeleted = true;
		String projectSchedule = ProgramCentralConstants.PROJECT_SCHEDULE_AUTO;
		int tobeDeletedObjSize = finalDeletedIdList.size();
		List<String> deletedObjList 	= new ArrayList<>();
		List<String> deletedObjIdList 	= new ArrayList<>();
		
		if(tobeDeletedObjSize > 0){
			try {
				ProjectSpace project = new ProjectSpace(projectId);
				projectSchedule 	 = project.getSchedule(context);
				boolean doRollup 	 = ProgramCentralConstants.PROJECT_SCHEDULE_AUTO.equalsIgnoreCase(projectSchedule);
				
				Map<String, Object> refreshMap = Task.deleteTasks(context, finalDeletedIdList, doRollup);
				deletedObjList = (List<String>)refreshMap.get("deletedObjectIdList");
				
			} catch (MatrixException me) {
				isSuccessfullyDeleted = false;
				me.printStackTrace();
				throw me;
			}
		}
		
%>
<script language="javascript">
		<%
		if(blMandatoryFlag){%> 
			alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CannotDeleteMandatoryTask</framework:i18nScript>" +"<%= slMandExcludeTaskNames.toString()%>");         
		<%}
		if(blTaskWithEffortsFlag){%>   
			alert("<framework:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheet.DeleteTask.TaskWithEffortCannotBeDeleted</framework:i18nScript>" +"<%= slTaskWithEfforts.toString()%>");         
		<%}
		if(!notToBeDeletedTaskName.isEmpty()){%>   
			alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.UnableToDeleteTasks</framework:i18nScript>\n\n" +"<%= notToBeDeletedTaskName%>");         
		<%}%>
		
   		var tobeDeletedObjectSize = "<%=tobeDeletedObjSize%>";
   		var successfullyDeleted = "<%=isSuccessfullyDeleted%>";
   		
   		var displaytopFrame = findFrame(getTopWindow(), "detailsDisplay");
   		var topFrame = findFrame(displaytopFrame, "<%=portalCmd%>");
   		if(topFrame == null){
   			topFrame = findFrame(getTopWindow(), "<%=portalCmd%>");	
   		}
   		
   		if(parseInt(tobeDeletedObjectSize) > 0 && successfullyDeleted){
   			
   			var refreshRows=[];
   	   		<%
		      	for(int i=0,size=deletedObjList.size();i<size;i++){
		   	      		%>
		      		refreshRows.push("<%=deletedObjList.get(i)%>");
	   					<%
	   	      		}
	      	%>
	      	var impObjRowIdArr = new Array();
	      	var count = 0;
	      	var reloadPage = false;
	      	for(var i=0,len=refreshRows.length;i<len;i++){
	      		var nRow = emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows//r[@o= '"+ refreshRows[i] +"']");
	      		if(nRow != null){
	      			impObjRowIdArr[count] = "|||"+nRow.getAttribute("id");
	      			count++;
	      		}else{
	      			reloadPage =true;
	      			break;
	   	      	}
   	      	}
   	   		
   	   		var projectScheduleValue = "<%=projectSchedule%>";
   	   		
   	   		setTimeout(function() {
   	   			if(reloadPage){
   	   				topFrame.location.reload();
   	   			}else{
	   	   			topFrame.emxEditableTable.removeRowsSelected(impObjRowIdArr);
   				var rowsNode 	= emxUICore.selectSingleNode(topFrame.oXML, "/mxRoot/rows");
   	  			var totalRows 	= rowsNode.getAttribute("totalRows");
   	  			
   	  			if(parseInt(totalRows) == 0){
   	  				topFrame.location.reload();
   	  			}else{
   	  				if("Manual" == projectScheduleValue){
   	  	   				top.jQuery('button.refresh', '.field.button').toggleClass('refresh').toggleClass('refresh-with-cache');
   	  	   				toggleRollupIcon(topFrame,"iconActionUpdateDates","iconActionUpdateDatesActive");
   	  	   			}
   	  				topFrame.toggleProgress('hidden');
   	  			}
   	   			}
   				
   			},10);
   		}else{
   			topFrame.toggleProgress('hidden');
   		}
     		
</script>
<%
	}else if("FlatViewAddAboveTask".equalsIgnoreCase(strMode)){
		String currentframe = XSSUtil.encodeForJavaScript(context,
				(String) emxGetParameter(request, "portalCmdName"));
		String manyTasksToAdd = (String) emxGetParameter(request, "PMCWBSQuickTasksToAddBelow"); //XSSOK 
		String taskTypeToAdd = (String) emxGetParameter(request, "PMCWBSQuickTaskTypeToAddBelow");
		//String emxTableRowId = emxGetParameter(request, "emxTableRowId");
		
		session.setAttribute("emxTableRowId", emxGetParameter(request, "emxTableRowId"));
		
		String objectId = emxGetParameter(request, "objectId");

		StringBuilder url = new StringBuilder();
		url.append("../programcentral/emxProjectManagementUtil.jsp?mode=FlatViewAddAboveTaskCnf");
		url.append("&portalCmdName=").append(currentframe);
		url.append("&PMCWBSQuickTasksToAddBelow=").append(manyTasksToAdd);
		url.append("&PMCWBSQuickTaskTypeToAddBelow=").append(taskTypeToAdd);
		//url.append("&emxTableRowId=").append(emxTableRowId);
		url.append("&objectId=").append(objectId);
%>
<script language="javascript">

	var displaytopFrame = findFrame(getTopWindow(), "detailsDisplay");
	var topFrame = findFrame(displaytopFrame, "<%=currentframe%>");
	if(topFrame == null){
		topFrame = findFrame(getTopWindow(), "<%=currentframe%>");	
	}
	setTimeout(function() {
		topFrame.toggleProgress('visible');
	    document.location.href = "<%=url.toString()%>";
	}, 10);
</script>
<%
	} else if ("FlatViewAddAboveTaskCnf".equalsIgnoreCase(strMode)) {

		String currentframe = XSSUtil.encodeForJavaScript(context,
				(String) emxGetParameter(request, "portalCmdName"));
		String urlTaskType = (String) emxGetParameter(request, "taskType");
		String manyTasksToAdd = (String) emxGetParameter(request, "PMCWBSQuickTasksToAddBelow"); //XSSOK 
		String taskTypeToAdd = (String) emxGetParameter(request, "PMCWBSQuickTaskTypeToAddBelow");
		
		String emxTableRowId = (String) session.getAttribute("emxTableRowId");
		session.removeAttribute("emxTableRowId");
		
		String objectId 	= null;
		String pid 			= null;
		String rowId 		= null;
		boolean addAbove 	= true;
		
		if(emxTableRowId != null){
			Map<String, String> taskIdMap = ProgramCentralUtil.parseTableRowId(context, emxTableRowId);
			objectId = taskIdMap.get("objectId");
			pid = taskIdMap.get("parentOId"); //Added for refresh
			rowId = taskIdMap.get("rowId"); //Added for refresh
		}else{
			objectId = emxGetParameter(request, "objectId");
			pid = objectId;
			rowId = "0,0"; //Added for refresh
			addAbove = false;
		}

		Task task = new Task(objectId);
		String parentId = task.getInfo(context, "to[Subtask].from.id");
		if(parentId == null){
			parentId = objectId;
		}
		
		int howMany = Integer.parseInt(manyTasksToAdd);

		//Task Creation
		String message = ProgramCentralConstants.EMPTY_STRING;
		MapList newTasks = new MapList();
		String projectSchedule = ProgramCentralConstants.PROJECT_SCHEDULE_AUTO;
		try {

			ContextUtil.startTransaction(context, true);
			com.matrixone.apps.program.Task newTask = (com.matrixone.apps.program.Task) DomainObject
					.newInstance(context, ProgramCentralConstants.TYPE_TASK, ProgramCentralConstants.PROGRAM);
			newTasks = newTask.create(context, taskTypeToAdd, howMany, objectId, addAbove);
			ContextUtil.commitTransaction(context);

			Map<String, String> projectScheduleMap = ProgramCentralUtil.getProjectSchedule(context, parentId);
			projectSchedule = projectScheduleMap.get(parentId);
			
			if (ProgramCentralUtil.isNullString(projectSchedule)
					|| ProgramCentralConstants.PROJECT_SCHEDULE_AUTO.equalsIgnoreCase(projectSchedule)) {
				TaskDateRollup.rolloutProject(context, new StringList(parentId), true);
			}

		} catch (FrameworkException e) {
			message = e.getMessage();
			ContextUtil.abortTransaction(context);
		} catch (Exception e) {
			ContextUtil.abortTransaction(context);
		}

		if (UIUtil.isNullOrEmpty(message)) {
			StringBuffer sBuff = new StringBuffer();
			String xmlMessage = DomainConstants.EMPTY_STRING;
			sBuff.append("<mxRoot>");
			Iterator itrNewTask = newTasks.iterator();
			ArrayList taskIds = new ArrayList();
			while (itrNewTask.hasNext()) {
				Map taskInfo = (Map) itrNewTask.next();
				String toId = (String) taskInfo.get(ProgramCentralConstants.SELECT_ID);
				taskIds.add(toId);
				String fromId = (String) taskInfo.get("to[Subtask].from.id");
				String relId = (String) taskInfo.get("to[Subtask].id");
				sBuff.append("<action><![CDATA[add]]></action>");

				sBuff.append("<data status=\"committed\" pasteBelowOrAbove=\""+addAbove+"\" >");
				sBuff.append("<item oid=\"" + toId + "\" relId=\"" + relId + "\" pid=\"" + pid + "\" id=\"" + rowId
						+ "\" pasteAboveToRow=\"" + rowId + "\" />");
				sBuff.append("</data>");
			}
			sBuff.append("</mxRoot>");
			
	%><script language="javascript" type="text/javaScript">
			var displaytopFrame = findFrame(getTopWindow(), "detailsDisplay");
			var topFrame = findFrame(displaytopFrame, "<%=currentframe%>");
			if(topFrame== null){
				topFrame = findFrame(getTopWindow(), "<%=currentframe%>");	
			}
			topFrame.emxEditableTable.addToSelectedMultiRoot('<%=XSSUtil.encodeForJavaScript(context, sBuff.toString())%>');
			var projectScheduleValue = "<%=projectSchedule%>";
			var refreshPage = "<%=addAbove%>";
			
			if("false" == refreshPage){ //When zero object present in flaten schedule view
				topFrame.location.reload();
			}else{
				//Added by DI7
				setTimeout(function() {
					if("Manual" == projectScheduleValue){
						top.jQuery('button.refresh', '.field.button').toggleClass('refresh').toggleClass('refresh-with-cache');
						toggleRollupIcon(topFrame,"iconActionUpdateDates","iconActionUpdateDatesActive");
					}
					topFrame.toggleProgress('hidden');
				}, 25);
			}
			
	    </script>
<%
	} else {
%>      <script language="javascript" type="text/javaScript">
		alert('<%=message%>')
		</script>
<%
	}
}else if("QuickWBS".equalsIgnoreCase(strMode)) {
		String currentframe = XSSUtil.encodeForJavaScript(context,
				(String) emxGetParameter(request, "portalCmdName"));
		String urlTaskType = (String) emxGetParameter(request, "taskType");
		String strTasksToAdd = (String) emxGetParameter(request, "PMCWBSQuickTasksToAddBelow"); //XSSOK
		String strTasksTypeToAdd = (String) emxGetParameter(request, "PMCWBSQuickTaskTypeToAddBelow");

		String calledMethod = emxGetParameter(request, "calledMethod");
		String projectId = emxGetParameter(request, "parentOID");
		String rowIds = emxGetParameter(request, "emxTableRowId");
		StringList slIds = FrameworkUtil.splitString(rowIds, "|");
		String parentId = (String) slIds.get(1);
		String taskLevel = (String) slIds.get(3);
		boolean addTaskAbove = false;
		if ("submitInsertTask".equalsIgnoreCase(calledMethod)) {
			addTaskAbove = true;
		}

		StringList busSelects = new StringList();
		busSelects.add(ProgramCentralConstants.SELECT_IS_MILESTONE);
		busSelects.add(ProgramCentralConstants.SELECT_IS_GATE);

		MapList parentMapList = ProgramCentralUtil.getObjectDetails(context, 
				new String[]{parentId}, 
				busSelects,
				true);
		Map<String, String> parentMap = (Map) parentMapList.get(0);
		String isMilestone = parentMap.get(ProgramCentralConstants.SELECT_IS_MILESTONE);
		String isGate = parentMap.get(ProgramCentralConstants.SELECT_IS_GATE);

		if (("true".equalsIgnoreCase(isGate) || "true".equalsIgnoreCase(isMilestone)) && !addTaskAbove) {
			%>
			<script language="javascript" type="text/javaScript">
				 alert("<framework:i18nScript localize="i18nId">emxProgramcentral.Milestone.SubtaskCreationAlert</framework:i18nScript>");
			</script>
			<%
			return;
		}

		int howMany = Integer.parseInt(strTasksToAdd);

		//Task Creation
		String message = ProgramCentralConstants.EMPTY_STRING;
		MapList newTasks = new MapList();
		String projectSchedule = ProgramCentralConstants.PROJECT_SCHEDULE_AUTO;
		try {
			ContextUtil.startTransaction(context, true);
			com.matrixone.apps.program.Task newTask = (com.matrixone.apps.program.Task) DomainObject
					.newInstance(context, ProgramCentralConstants.TYPE_TASK, ProgramCentralConstants.PROGRAM);
			newTasks = newTask.create(context, strTasksTypeToAdd, howMany, parentId, addTaskAbove);
			ContextUtil.commitTransaction(context);

			Map<String, String> projectScheduleMap = ProgramCentralUtil.getProjectSchedule(context, projectId);
			projectSchedule = projectScheduleMap.get(projectId);

			if (ProgramCentralUtil.isNullString(projectSchedule)
					|| ProgramCentralConstants.PROJECT_SCHEDULE_AUTO.equalsIgnoreCase(projectSchedule)) {
				Task project = new Task(projectId);
				project.rollupAndSave(context);
			}

		} catch (FrameworkException e) {
			message = e.getMessage();
			ContextUtil.abortTransaction(context);
		} catch (Exception e) {
			ContextUtil.abortTransaction(context);
		}

		if (UIUtil.isNullOrEmpty(message)) {
			StringBuffer sBuff = new StringBuffer();
			String xmlMessage = DomainConstants.EMPTY_STRING;
			sBuff.append("<mxRoot>");
			Iterator itrNewTask = newTasks.iterator();
			ArrayList taskIds = new ArrayList();
			while (itrNewTask.hasNext()) {
				Map taskInfo = (Map) itrNewTask.next();
				String toId = (String) taskInfo.get(ProgramCentralConstants.SELECT_ID);
				taskIds.add(toId);
				String fromId = (String) taskInfo.get("to[Subtask].from.id");
				String relId = (String) taskInfo.get("to[Subtask].id");
				sBuff.append("<action><![CDATA[add]]></action>");

				if (addTaskAbove) {
					sBuff.append("<data status=\"noMarkupRows\" pasteBelowOrAbove=\"true\" >");
					sBuff.append("<item oid=\"" + toId + "\" relId=\"" + relId + "\" pid=\"" + fromId
							+ "\" pasteAboveToRow=\"" + slIds.get(3) + "\" direction=\"" + "from" + "\" />");
					sBuff.append("</data>");
				} else {
					sBuff.append("<data status=\"noMarkupRows\">");
					sBuff.append("<item oid=\"" + toId + "\" relId=\"" + relId + "\" pid=\"" + fromId
							+ "\"  direction=\"" + "from" + "\" />");
					sBuff.append("</data>");
				}
			}
			sBuff.append("</mxRoot>");
			%><script language="javascript" type="text/javaScript">
	    	var topFrame = findFrame(getTopWindow(), "<%=currentframe%>");
			if(null == topFrame){
				topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
				if(null == topFrame){
					topFrame = findFrame(getTopWindow(), "detailsDisplay");
				}
			}
			topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context, sBuff.toString())%>');


			var taskObjectId = [<%int size = taskIds.size();
			for (int i = 0; i < size; i++) {%>"<%=taskIds.get(i)%>"<%=i + 1 < size ? "," : ""%><%}%>];

            var xmlRef 	= topFrame.oXML;
		  	var taskRowID =[];
		  	var taskObjectIdLength = taskObjectId.length;
		  	for (var j = 0; j < taskObjectIdLength; j++) {
			  	var tempObjectId = taskObjectId[j];
	    	  	var nParent = emxUICore.selectSingleNode(xmlRef, "/mxRoot/rows//r[@o = '" + tempObjectId + "']");
   	  			nParent.setAttribute("display","block");
		  	}
			  //Added by DI7
			var projectScheduleValue = "<%=projectSchedule%>";
			if("Manual" == projectScheduleValue){
				top.jQuery('button.refresh', '.field.button').toggleClass('refresh').toggleClass('refresh-with-cache');
				toggleRollupIcon(topFrame,"iconActionUpdateDates","iconActionUpdateDatesActive");
			}else{
				topFrame.emxEditableTable.refreshStructureWithOutSort();
			}
			topFrame.toggleProgress('hidden');
	  
	    </script>
<%
	} else {
		%><script language="javascript" type="text/javaScript">alert('<%=message%>')</script><%
	}
}else if("createNewRiskOpportunity".equalsIgnoreCase(strMode))
{
	String[] selectedIds = request.getParameterValues("emxTableRowId");
		String sLanguage = request.getHeader("Accept-Language");
		String projectId = emxGetParameter(request, "parentOID");
		String objectId = emxGetParameter(request, "objectId");
		String tableName = emxGetParameter(request, "table");
		String errorMessage = ProgramCentralConstants.EMPTY_STRING;
		String xmlMessage = ProgramCentralConstants.EMPTY_STRING;

		if (!ProgramCentralUtil.isNullString(objectId)) {
			if (ProgramCentralUtil.isNullString(projectId) || objectId != projectId) {
				projectId = objectId;
			}
		}

		boolean isOfRiskType = false;
		boolean isOfOpportunityType = false;
		if (selectedIds != null && selectedIds.length != 0) {
			if (selectedIds.length >= 1) {
				String selectedId = ProgramCentralUtil.parseTableRowId(context, selectedIds)[0];
				isOfRiskType = ProgramCentralUtil.isOfGivenTypeObject(context, DomainConstants.TYPE_RISK,
						selectedId);
				isOfOpportunityType = ProgramCentralUtil.isOfGivenTypeObject(context,
						RiskManagement.TYPE_OPPORTUNITY, selectedId);
			}
		}
		if ((isOfRiskType || isOfOpportunityType)) {

			errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Project.SelectProject", sLanguage);
            %>
             <script language="javascript" type="text/javaScript">
	 	   		alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Risk.SelectNodeForCreateRisk</emxUtil:i18nScript>");
        	</script>
        	<%
            return;
		} else {
			if ("PMCRisksSummary".equalsIgnoreCase(tableName)) {
			%>
			<script language="javascript" type="text/javaScript">
			       getTopWindow().showSlideInDialog("../common/emxCreate.jsp?type=type_Risk&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&typeChooser=true&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&targetLocation=slidein&policy=policy_ProjectRisk&form=PMCCreateRiskForm&formHeader=emxProgramCentral.Risk.CreateRisk&HelpMarker=emxhelpriskcreatedialog&findMxLink=false&nameField=autoName&postProcessJPO=emxRiskBase:createRisk&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralRiskUtil.jsp?mode=refreshStructure");
			       </script>
			<%
		} else if ("PMCOpportunitySummary".equalsIgnoreCase(tableName)) {
			%>
			<script language="javascript" type="text/javaScript">
				    getTopWindow().showSlideInDialog("../common/emxCreate.jsp?type=type_Opportunity&parentOID=<%=XSSUtil.encodeForURL(context, projectId)%>&typeChooser=true&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&targetLocation=slidein&policy=policy_ProjectRisk&form=PMCCreateOpportunityForm&formHeader=emxProgramCentral.Risk.CreateOpportunity&HelpMarker=emxhelpriskcreatedialog&findMxLink=false&nameField=autoName&showApply=true&createJPO=emxRisk:createAndConnectRisk&submitAction=doNothing&postProcessJPO=emxRiskBase:createOpportunity&postProcessURL=../programcentral/emxProgramCentralRiskUtil.jsp?mode=refreshStructureForOpportunity");
				   </script>
			<%
			}
		}
	}
else if("deleteBudgetBenefitItem".equalsIgnoreCase(strMode))
{
	String errorMsg = ProgramCentralConstants.EMPTY_STRING;
	String[] budgetOrBenefitIds = emxGetParameterValues(request,"emxTableRowId");
	String sObjId = "";
	String[] sTempRowId =new String[budgetOrBenefitIds.length];
	String[] strObjectIDArr    = new String[budgetOrBenefitIds.length];
	StringBuffer sbFinalIds = new StringBuffer();
	StringBuffer sbFinalRowIds = new StringBuffer();
	String fullrefresh="RowRefresh";
	for(int i=0; i<budgetOrBenefitIds.length; i++)
	{
		String sTempObj = budgetOrBenefitIds[i];
		Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
		sObjId = (String)mParsedObject.get("objectId");
		strObjectIDArr[i] = sObjId;
		sTempRowId[i] = (String)mParsedObject.get("rowId");
	}
	StringList selectables = new StringList();
	selectables.add(DomainConstants.SELECT_TYPE);
	MapList selectedObjectInfoList = DomainObject.getInfo(context, strObjectIDArr, selectables);
	int index=0;
	int length=selectedObjectInfoList.size();
	java.util.Set<String> typeSet=new HashSet<String>();
	for(int i=0; i<length; i++)
	{
		Map typeMap=(Map)selectedObjectInfoList.get(i);
		if(typeMap.containsValue("Budget") ||typeMap.containsValue("Benefit"))
		{	fullrefresh="page";
			index=i;
		}
		typeSet.add(typeMap.toString());
		if(typeSet.size()>1)
		{
			if(typeMap.containsValue("Budget")||typeMap.containsValue("Cost Item"))
			{
				errorMsg =EnoviaResourceBundle.getProperty(context,"emxProgramCentralStringResource",context.getLocale(), "emxProgramCentral.Command.Budget.SelectItem");
			}
			else if(typeMap.containsValue("Benefit Item") || typeMap.containsValue("Benefit"))
			{
				errorMsg =EnoviaResourceBundle.getProperty(context,"emxProgramCentralStringResource",context.getLocale(), "emxProgramCentral.Command.Benefit.SelectItem");
			}
			sbFinalIds.append((String) strObjectIDArr[index]);
			sbFinalRowIds.append((String) sTempRowId[index]);
			break;
		}
	}
	if(typeSet.size()==1)
	{
		errorMsg =EnoviaResourceBundle.getProperty(context,"emxProgramCentralStringResource",context.getLocale(), "emxProgramCentral.Common.ConfirmDelete");
	  	for (int i = 0; i < strObjectIDArr.length; i++) {
		sbFinalIds.append((String) strObjectIDArr[i]);
		sbFinalRowIds.append((String) sTempRowId[i]);
		if (i != strObjectIDArr.length - 1) {
			sbFinalIds.append("|");
			sbFinalRowIds.append("|");
			}
		}
	}
	session.setAttribute("FinancialIdsToDelete",sbFinalIds.toString());
	session.setAttribute("RowIds",sbFinalRowIds.toString());
	String strURL = "../programcentral/emxProjectManagementUtil.jsp?&mode=deleteFinancialItemProcess&fullrefresh="+fullrefresh;
	
	%>
	 <script type="text/javascript" language="JavaScript">
	var result=confirm('<%=errorMsg%>');
	if (result)
	  {
		var strUrl = "<%=strURL%>";
		document.location.href = strUrl;
	  }
else{<%--XSSOK--%>
	 window.parent.location.href =  window.parent.location.href;
}
</script>
	 <%
	
}else if("deleteFinancialItemProcess".equalsIgnoreCase(strMode))
{
	String fullrefresh 	= emxGetParameter(request,"fullrefresh");
	
	String objectIds = (String)session.getAttribute("FinancialIdsToDelete");
	String rowIds = (String)session.getAttribute("RowIds");
	
	session.removeAttribute("FinancialIdsToDelete");
 	session.removeAttribute("RowIds");
 	
	StringList rowIdList = FrameworkUtil.split(rowIds, "|");
	StringList idList = FrameworkUtil.split(objectIds, "|");
	String[] taskIds = (String []) idList.toArray(new String[] {});
	String[] rowListIds = (String []) rowIdList.toArray(new String[] {});
 	
 	DomainObject.deleteObjects(context,taskIds);
 	
 	String partialXML="";
 	for (int i = 0; i < rowListIds.length; i++) {
 		String sTempRowId = rowListIds[i];
 		partialXML += "<item id=\"" + sTempRowId + "\" />";
	}
 	String xmlMessage = "<mxRoot>";
	String message = "";
	xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
	xmlMessage += partialXML;
	xmlMessage += "<message><![CDATA[" + message + "]]></message>";
	xmlMessage += "</mxRoot>";
 	%>
	 <script type="text/javascript" language="JavaScript">
	 var fullrefresh = "<%=fullrefresh%>";
	 if(fullrefresh=="RowRefresh")
		 {
		 window.parent.removedeletedRows('<%= xmlMessage %>');
		 }
	 else
		 {
		 window.parent.location.href =  window.parent.location.href;
		 }
</script>
	 <%
}else if("BookmarkFolderRefresh".equalsIgnoreCase(strMode)){
	
	String strParentOID      	= emxGetParameter(request, "parentOID");
	String strParentType		= DomainObject.EMPTY_STRING;
	String strTypeofContract 	= DomainObject.EMPTY_STRING;
	String emxTableRowId		= (String) emxGetParameter(request,"emxTableRowId");
	String pasteBelowToRow 		= DomainObject.EMPTY_STRING;
	 
	if(null != emxTableRowId){
       StringList slPasteBelowToRow = FrameworkUtil.split(emxTableRowId, "|");
       if(null != slPasteBelowToRow){
           pasteBelowToRow = slPasteBelowToRow.get(slPasteBelowToRow.size()-1).toString();
           if(slPasteBelowToRow.size() == 4){
        	   strParentOID = slPasteBelowToRow.get(1).toString();
           }
           else if(slPasteBelowToRow.size() == 3){
        	   strParentOID = slPasteBelowToRow.get(0).toString();
           }
       }
    }
	
  	if(null!=strParentOID && ""!=strParentOID)
	{
	   	DomainObject dobj=DomainObject.newInstance(context, strParentOID);
	   	strParentType=dobj.getInfo(context, DomainConstants.SELECT_TYPE);
	   	strTypeofContract = MqlUtil.mqlCommand(context, "print type $1 select $2 dump", true, strParentType, "kindof[Contract]");
	}
	
    //Reitrive newCreatedFolderIdList to refresh fancyTree for the contract and program the page 
  	StringList newCreatedFolderIdList = (StringList) CacheUtil.getCacheObject(context, "newCreatedFolderIdList");
	CacheUtil.removeCacheObject(context, "newCreatedFolderIdList");
	
  	//Reitrive PMCBookmarkFolderRefreshXML to refresh the page 
	String xmlMessage = (String) CacheUtil.getCacheObject(context, "PMCBookmarkFolderRefreshXML");
	CacheUtil.removeCacheObject(context, "PMCBookmarkFolderRefreshXML");
	
	%>
	<script language="javascript">
	
		var topFrame = findFrame(getTopWindow(), "PMCFolder");
		if(topFrame==null || topFrame =='undefined'){
			topFrame = findFrame(getTopWindow(), "detailsDisplay");
		}
		if('<%=strParentType%>'=="Submission")
    	{
    		topFrame = findFrame(getTopWindow(), "LRASubmissionLocalFolder"); 
    		if(topFrame==null)
    			topFrame = findFrame(getTopWindow(), "LRASubmissionLocalFolder"); 
    		var leaderFrame=findFrame(getTopWindow(), "LRASubmissionLeaderFolder");
    		if(null!=leaderFrame)
    		{
	    		leaderFrame.emxEditableTable.addToSelected('<%=xmlMessage%>');
    			leaderFrame.refreshStructureWithOutSort();
    		}
    	}
    	else if('<%=strParentType%>'=="Submission Master Record"){
    		topFrame = findFrame(getTopWindow(), "LRASubmissionMasterFolder");
    		
    	}else if('<%=strParentType%>'=="Contract Template" || '<%=strTypeofContract%>' == "TRUE"){
            var fancyTree = getTopWindow().objStructureFancyTree;
            if(fancyTree){
            	<%
            	for (int i=0;i<newCreatedFolderIdList.size();i++){
            	%>
            	 	fancyTree.addChild("<%=XSSUtil.encodeForJavaScript(context, strParentOID)%>", "<%=XSSUtil.encodeForJavaScript(context,newCreatedFolderIdList.get(i))%>");
				<%}%>
            } 
		}
		
		topFrame.emxEditableTable.addToSelected('<%=xmlMessage%>');
		topFrame.refreshStructureWithOutSort();
		
	</script>
	<%
}
else if ("refreshCopyPartialSchedule".equalsIgnoreCase(strMode)) {
	String portalCommandName = XSSUtil.encodeURLForServer(context, emxGetParameter(request, "portalCmdName"));
	String objectId = XSSUtil.encodeURLForServer(context,emxGetParameter(request,"objectId"));
	String sourceTasks = emxGetParameter(request,"SeachProjectOID");
	Map<String,String> projectScheduleMap = ProgramCentralUtil.getProjectSchedule(context, objectId);
	String projectSchedule = projectScheduleMap.get(objectId);
	String xmlMessage =DomainObject.EMPTY_STRING;
	Map paramMap = new HashMap(1);
	paramMap.put("objectId",objectId);
	paramMap.put("SeachProjectOID",sourceTasks);
	String[] methodArgs = JPO.packArgs(paramMap);
  	JPO.invoke(context,"emxProjectSpace", null, "copyPartialScheduleProcess", methodArgs, String[].class);
  	if("Manual".equalsIgnoreCase(projectSchedule)){
		 String isWholePageRefreshRequierd="yes";
		CacheUtil.setCacheObject(context, "isWholePageRefreshRequierd", isWholePageRefreshRequierd);
	}
  	
	%><script language="javascript" type="text/javaScript">
	
	 var frame = "<%=portalCommandName%>";
	  var schedule = "<%=projectSchedule%>";
	  var topFrame = findFrame(getTopWindow(), frame);

	  if(null == topFrame){
	  	topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
	      if(null == topFrame)
	  		topFrame = findFrame(getTopWindow(), "PMCWBS");
	   if(null == topFrame)
	  		topFrame = findFrame(getTopWindow(), "detailsDisplay");
	  }
	if("Manual" == schedule){
		
		top.jQuery('button.refresh', '.field.button').toggleClass('refresh').toggleClass('refresh-with-cache');
		toggleRollupIcon(topFrame,"iconActionUpdateDates","iconActionUpdateDatesActive");
  }else{
	  topFrame.location.href = topFrame.location.href;
  }
</script>
<%
}else if("calculateFloatAndCriticalPath".equalsIgnoreCase(strMode)){
    String portalCmd 	= emxGetParameter(request,"portalCmdName");
	String objectId 	= emxGetParameter(request, "objectId");
    Map rollupMap = null;
	try{
		
		rollupMap = TaskDateRollup.rolloutProject(
			context,
			new StringList(objectId),
			true,
			true);
	}catch(FrameworkException frameworkException){
		frameworkException.printStackTrace();
	}

	%>
      <script language="javascript">
    		var portalName = "<%=portalCmd%>";
    	
    		var topFrame = findFrame(getTopWindow(), portalName);
      		if(topFrame == null){
 				topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
 				if(null == topFrame){
 				    topFrame = findFrame(getTopWindow(), "detailsDisplay");
 				}
 			}
      		 topFrame.emxEditableTable.refreshStructureWithOutSort();
	    
      </script>
    <%
}else if("addMemberToBudget".equalsIgnoreCase(strMode)){
    String objectId = emxGetParameter(request, "objectId");
    String access = emxGetParameter(request, "access");
    String[] ids = emxGetParameterValues(request, "emxTableRowId");
    String owner = "";
    String ownerAccess = "";
    String defaultAccess = "";
    String OID = "";	
	
	   try{
		   for(int i =0, len = ids.length; i<len;i++){
		    	StringList idList = StringUtil.split(ids[i], "|");

		    		
		    		if( idList.size() >= 1 )
			    	{
			      		String busId = (idList.size() >2) ? (String)idList.get(1) : objectId;
			      		if(!busId.equals(OID))
			      		{
			      			OID = busId;
			      			owner =  new DomainObject(busId).getInfo(context, DomainObject.SELECT_OWNER);
			      			StringList accessNames = DomainAccess.getLogicalNames(context, busId);
			      			//System.out.println("ACCESSNAME ===== "+ accessNames);
			      			defaultAccess = (String)accessNames.get(0);
			      			ownerAccess = (String)accessNames.get(accessNames.size()-1);      			
			      		}

						String personId = (String)idList.get(0);
						String personName = new DomainObject(personId).getInfo(context, DomainObject.SELECT_NAME);
						if(personName.equals(owner))
						{
							DomainAccess.createObjectOwnership(context, busId, personId, ownerAccess, DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
						} else {
							DomainAccess.createObjectOwnership(context, busId, personId, defaultAccess, DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
						}
					
			    	}
		    }
	   }catch(Exception e){
		   e.printStackTrace();
	   }

	   	%>
		<script language="javascript">
		debugger;
		getTopWindow().parent.getWindowOpener().parent.location.href = getTopWindow().parent.getWindowOpener().parent.location.href;
			
        </script>
   		<%
}
else if ("connectRIOItems".equalsIgnoreCase(strMode))  {
	String portalCmd = (String) emxGetParameter(request, "portalCmdName");
	Set<String> ROIds = new HashSet<String>();
	Set<String> IssueIds =new HashSet<String>();
	final String TYPE_ISSUE = PropertyUtil.getSchemaProperty(context, "type_Issue");
	 final String RELATIONSHIP_RESOLUTION_PROJECT   = "Resolution Project";
	 final String RELATIONSHIP_RESOLVED_TO        = PropertyUtil.getSchemaProperty("relationship_ResolvedTo");
	 String projectId = emxGetParameter(request, "parentOID");
	 if(ProgramCentralUtil.isNullString(projectId)){
		   projectId = emxGetParameter(request, "objectId");   
	   }
	
	 DomainObject projectObject =DomainObject.newInstance(context,projectId);
	 
	 String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	 String[] emxobejctIds = new String[emxTableRowIds.length];
	 try{
						
			 StringList busSelectable = new StringList();
			 busSelectable.add(DomainConstants.SELECT_ID);
			 busSelectable.add(ProgramCentralConstants.SELECT_IS_OPPORTUNITY); 
			 busSelectable.add(ProgramCentralConstants.SELECT_IS_RISK); 
			  
			 for(int i=0;i <emxTableRowIds.length;i++){
				 String objectId = (String)((Map)ProgramCentralUtil.parseTableRowId(context, emxTableRowIds[i])).get("objectId");
				 emxobejctIds[i] = objectId;
			 }
			 
			 BusinessObjectWithSelectList bwsl =	ProgramCentralUtil.getObjectWithSelectList(context,emxobejctIds, busSelectable, true);
			 
			 for(BusinessObjectWithSelect bws : bwsl)
			 {
				 String id =bws.getSelectData(DomainConstants.SELECT_ID);
			 String isOfRiskType 		= bws.getSelectData(ProgramCentralConstants.SELECT_IS_RISK);
			 String isOfOpportunityType = bws.getSelectData(ProgramCentralConstants.SELECT_IS_OPPORTUNITY);
			 if("TRUE".equalsIgnoreCase(isOfRiskType) || "TRUE".equalsIgnoreCase(isOfOpportunityType))
			 {
				 ROIds.add(id); 
			 }
			 else{
				 IssueIds.add(id); 
			 }
			
		 }
			 Object[] riskOppIdsArray =ROIds.toArray(); //ROIds.stream().toArray(String[]::new);
			 Object[] issueIdsArray = IssueIds.toArray();
			 String[] RiskOpArrayString = Arrays.copyOf(riskOppIdsArray, riskOppIdsArray.length, String[].class);
			 String[] IssueArrayString = Arrays.copyOf(issueIdsArray, issueIdsArray.length, String[].class);
			
				DomainRelationship.connect(context,projectObject, RELATIONSHIP_RESOLUTION_PROJECT,false, RiskOpArrayString);
				DomainRelationship.connect(context,projectObject, RELATIONSHIP_RESOLVED_TO,false, IssueArrayString);
			 
			 }
	 catch(Exception e)
	 {
		 e.printStackTrace();
	 }
	 %>
		<script language="javascript">
			getTopWindow().closeWindow();
			getTopWindow().getWindowOpener().parent.location.reload();
     </script>
		<%
}
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>

