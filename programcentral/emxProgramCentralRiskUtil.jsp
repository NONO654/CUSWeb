

<%-- Common Includes --%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="java.lang.reflect.Method"%>
<%@page import="com.matrixone.apps.program.Currency"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@page import="com.matrixone.apps.program.fiscal.Helper"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="java.util.Set"%>

<%@ page import="java.util.HashMap,java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.matrixone.apps.domain.util.MessageUtil"%>

<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.common.Company,matrix.util.StringList" %>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.common.ProjectManagement"%>

<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.program.FTE"%>
<%@page import="com.matrixone.apps.program.ResourceRequest"%>
<%@page import="com.matrixone.apps.program.Question"%>

<%@page import="com.matrixone.apps.program.fiscal.CalendarType"%>
<%@page import="com.matrixone.apps.program.fiscal.Interval"%>
<%@page import="com.matrixone.apps.program.fiscal.Helper"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script src="../programcentral/emxProgramCentralUIFormValidation.js" type="text/javascript"></script>

<%
     String projectType = DomainConstants.TYPE_PROJECT_SPACE;
     String sLanguage = request.getHeader("Accept-Language");
     String strMode = emxGetParameter(request, "mode");
     strMode = XSSUtil.encodeURLForServer(context, strMode);
     String objId = emxGetParameter(request, "objectId");
     objId = XSSUtil.encodeURLForServer(context, objId);
     String contentURL = DomainObject.EMPTY_STRING;
     String RELATIONSHIP_SHADOW_GATE = PropertyUtil.getSchemaProperty("relationship_ShadowGate");
     String SELECT_SHADOW_GATE_ID = "from["+RELATIONSHIP_SHADOW_GATE+"].id";
     boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);

     if("refreshStructure".equals(strMode)) {
            %>
            <script language="javascript">
               var detailsDisplay = findFrame(getTopWindow(), "PMCProjectRisk");
               if(null==detailsDisplay){
                    detailsDisplay=findFrame(getTopWindow().parent.window, "detailsDisplay");
                    detailsDisplay.location.href = detailsDisplay.location.href;
                }else{
                    detailsDisplay.refreshSBTable();
                }
             </script>
            <%

     }else if("refreshStructureForOpportunity".equals(strMode)) {
         %>
         <script language="javascript">
            var detailsDisplay = findFrame(getTopWindow(), "PMCProjectOpportunity");
            if(null==detailsDisplay){
                 detailsDisplay=findFrame(getTopWindow().parent.window, "detailsDisplay");
                 detailsDisplay.location.href = detailsDisplay.location.href;
             }else{
                 detailsDisplay.refreshSBTable();
             }
          </script>
         <%

  }else if("quickCreateOpportunity".equalsIgnoreCase(strMode)){
			String[] selectedIds = request.getParameterValues("emxTableRowId");
        	String projectId = emxGetParameter( request, "parentOID");
        	String objectId = emxGetParameter( request, "objectId");
        	String errorMessage = ProgramCentralConstants.EMPTY_STRING;
        	String xmlMessage = ProgramCentralConstants.EMPTY_STRING;
        	
        	if(!ProgramCentralUtil.isNullString(objectId)){
        		if(ProgramCentralUtil.isNullString(projectId) || objectId != projectId){
        			projectId = objectId;
        		}
        	}
        	
        	if (selectedIds != null && selectedIds.length != 0) {
	   			if (selectedIds.length >= 1) {
		   				String selectedId =  ProgramCentralUtil.parseTableRowId(context,selectedIds)[0];
	   					boolean isOfOpportunityType =  ProgramCentralUtil.isOfGivenTypeObject(context,RiskManagement.TYPE_OPPORTUNITY,selectedId);
	   					boolean isOfRPNType =   ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_RPN,selectedId);
	   					if ((isOfOpportunityType || isOfRPNType)) {
						
	   						errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Project.SelectProject",sLanguage);
			 	   			  %>
			 	   			  	<script language="javascript" type="text/javaScript">
		        					alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Risk.SelectNodeForCreateRisk</emxUtil:i18nScript>");
		        					getTopWindow().closeSlideInDialog();
		        				</script>
			 	   			  <% 
			 	   			 return; 
	   					}
	   			   }
	   		}
        	
        	boolean isOfProjectType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_PROJECT_SPACE,projectId);
        	Opportunity opportunity = new Opportunity();
        	String name = new DomainObject().getUniqueName("OPP-");
        	opportunity.create(context, name, opportunity.POLICY_PROJECT_RISK);
        	String opportunityId = opportunity.getId(context);
			String timezone = (String)session.getValue("timeZone");
			String rValue = "1";

        	int eDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
   			java.text.DateFormat format = DateFormat.getDateTimeInstance(eDateFormat, eDateFormat, Locale.US);
        	Date  currentDate =  new Date();
        	String eDate=format.format(currentDate); 
			double clientTZOffset = new Double(timeZone).doubleValue(); 

        	Map paramMap = new HashMap();
        	paramMap.put("objectId", opportunityId);
        	paramMap.put("languageStr", sLanguage);
        	
        	Map requestMap = new HashMap();
        	requestMap.put("mode", "quickCreateOpportunity");
        	requestMap.put("Probability",rValue);
        	requestMap.put("Impact",rValue);
        	requestMap.put("RPN", rValue);
        	requestMap.put("timeZone",timezone);
        	requestMap.put("EffectiveDate", eDate);
        	requestMap.put("timeZone",timezone);
        	requestMap.put("EstimatedEndDate", eDate);
        	requestMap.put("EstimatedStartDate", eDate);
        	requestMap.put("localeObj", Locale.US);
        	requestMap.put("parentOID", projectId);
        	
        	
        	Map ProgramMap = new HashMap();
        	ProgramMap.put("paramMap",paramMap);
        	ProgramMap.put("requestMap",requestMap);
        	Opportunity opportunityObject = new Opportunity();
        	
        	opportunityObject = opportunity.createOpportunity(context, ProgramMap);
        	String rpnOpportunityRelId = opportunityObject.getInfo(context,"to[Risk].id");
        	
	       	xmlMessage = "<mxRoot><action><![CDATA[add]]></action>";
	       		   	xmlMessage +="<data status=\"committed\" fromRMB=\"" + false + "\">";
	       		   	xmlMessage +="<item oid=\"" + opportunityId + "\" relId=\"" + rpnOpportunityRelId + "\" pid=\"" + projectId + "\"/>"; 
	       			xmlMessage +="</data></mxRoot>";
 	    	%>
 		 	<script language="javascript" type="text/javaScript">
 		 	if(<%=isOfProjectType%> == true){
 		 	var topFrame = findFrame(getTopWindow(),"PMCProjectOpportunity");
 		 	if(null == topFrame)
    	  		topFrame = findFrame(getTopWindow(), "frameDashboard");
 		 	}else{
 		 		var topFrame = findFrame(getTopWindow(),"detailsDisplay");
     }
	            topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,xmlMessage)%>');
	            topFrame.location.href = topFrame.location.href;
 		 	</script>
 		  <%

	 }else if ("isOpportunitySelected".equalsIgnoreCase(strMode)){
         String sErrMsg  = "";
         String[] selectedids = request.getParameterValues("emxTableRowId");
         String projectId = emxGetParameter( request, "parentOID");
         String errorMessage = null;
         String riskCreationURL = null;
         StringList requestIdList = new StringList();
         boolean isInvalidRequest = false;

         if (selectedids != null && selectedids.length != 0) {
                if (selectedids.length == 1) {
                     String riskId =  ProgramCentralUtil.parseTableRowId(context,selectedids)[0];
                     boolean isOfRiskType = ProgramCentralUtil.isOfGivenTypeObject(context,RiskManagement.TYPE_OPPORTUNITY,riskId);
                     if (isOfRiskType) {
                         projectId = XSSUtil.encodeURLForServer(context,projectId);
                         riskId = XSSUtil.encodeURLForServer(context,riskId);
                         String submitLabel = ProgramCentralUtil.getPMCI18nString(context,"emxCommonButton.OK",sLanguage);
                         riskCreationURL =
                                 "../common/emxForm.jsp?mode=edit&form=CreateNewOPN&portalMode=false&suiteKey=ProgramCentral&targetLocation=slidein&formHeader=emxProgramCentral.Opportunity.CreateOPN&PrinterFriendly=false&HelpMarker=emxhelprpncreatedialog&postProcessJPO=emxRPNBase:createNewOPN&findMxLink=false"+
                                         "&objectId="+riskId+"&postProcessURL=../programcentral/emxProgramCentralRiskUtil.jsp?mode=createOpportunityRPN&submitAction=doNothing&submitLabel="+submitLabel;

                     } else {
                      errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.PleaseSelectOneOpportunity",sLanguage);
                   %>
                     <script language="javascript" type="text/javaScript">
                         alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseSelectOneOpportunity</emxUtil:i18nScript>");
                     </script>
                   <%
                  return;
                     }
                }
             }

             if (ProgramCentralUtil.isNullString(errorMessage)) {
                 %>
                 <script language="javascript" type="text/javaScript">
                     var riskCreationURL = "<%=XSSUtil.encodeForJavaScript(context,riskCreationURL)%>";
                     getTopWindow().showSlideInDialog(riskCreationURL,true);
                 </script>
                 <%
             }
    }
else if("deleteOpportunity".equalsIgnoreCase(strMode)){
		   Opportunity opportunity = (Opportunity) DomainObject.newInstance(context,RiskManagement.TYPE_OPPORTUNITY,"PROGRAM");
			String[] opportunities = emxGetParameterValues(request,"emxTableRowId");
			opportunities = ProgramCentralUtil.parseTableRowId(context,opportunities);

			if(opportunities != null && opportunities.length > 0){
			  for(int i=0;i<opportunities.length;i++){
				  String opportunityObjectId = opportunities[i];
				  opportunity.setId(opportunityObjectId);
				  if(opportunity.getInfo(context, DomainConstants.SELECT_TYPE).equalsIgnoreCase(RiskManagement.TYPE_OPPORTUNITY)){
							StringList objectSelects = new StringList();
					    	objectSelects.add(ProgramCentralConstants.SELECT_ID);
					    	StringList relationshipSelects = new StringList();
					    	MapList rpnList = opportunity.getRelatedObjects(context,
									RiskManagement.RELATIONSHIP_OPPORTUNITY_RPN,
									ProgramCentralConstants.TYPE_RPN,
									objectSelects,
									relationshipSelects,
									false,
									true,
									(short) 0,
									DomainConstants.EMPTY_STRING,
									DomainConstants.EMPTY_STRING,
									0);
					    	String[] strObjectIDArr    = new String[2];
								  Map RPNMap =(Map) rpnList.get(0);
								  String RPNId = (String)RPNMap.get(DomainConstants.SELECT_ID);
								  strObjectIDArr[0] = opportunityObjectId;
								  strObjectIDArr[1] = RPNId;
								  DomainObject.deleteObjects(context,strObjectIDArr);
				  }
			  }
			}
				 %>
			<script language="javascript" type="text/javaScript">
				var topFrame = findFrame(getTopWindow(), "PMCProjectOpportunity");
				if (topFrame != null) {
					topFrame.location.href = topFrame.location.href;
			   }else{
			   	parent.location.href = parent.location.href;
			   }
			</script>
<%}
    else if ("PMCProjectOpportunity".equalsIgnoreCase(strMode)) {

           String strURL = "../common/emxIndentedTable.jsp?table=PMCOpportunitySummary&selection=multiple&Export=true&sortColumnName=Title&sortDirection=ascending&toolbar=PMCOpportunitySummaryToolBar&header=emxProgramCentral.ProgramTop.OpportunityProject&HelpMarker=emxhelprisksummary&freezePane=Name&postProcessJPO=emxTask:postProcessRefresh&hideLaunchButton=true&expandProgramMenu=PMCOpportunityListMenu&showPageURLIcon=false";
           String objectId = emxGetParameter(request, "objectId");

           Map paramMap = new HashMap(1);
           paramMap.put("parentOID",objectId);

           String[] methodArgs = JPO.packArgs(paramMap);
           boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxRisk", null, "checkEditAccess", methodArgs, Boolean.class);

           Enumeration requestParams = emxGetParameterNames(request);
           StringBuilder url = new StringBuilder();

           if(requestParams != null){
                 while(requestParams.hasMoreElements()){
                      String param = (String)requestParams.nextElement();
                      String value = emxGetParameter(request,param);
                      url.append("&"+param);
                      url.append("="+XSSUtil.encodeForURL(context, value));
                 }
                 strURL = strURL + url.toString();
           }

           if(hasModifyAccess){
               strURL = strURL + "&editLink=true";
           }
        %>
            <script language="javascript">
                     var strUrl = "<%=strURL%>";
                     document.location.href = strUrl;
            </script>
       <%
    }

    else if ("PMCProgramOpportunity".equalsIgnoreCase(strMode)) {

           String strURL = "../common/emxIndentedTable.jsp?table=PMCOpportunitySummary&selection=multiple&Export=true&sortColumnName=Title&sortDirection=ascending&header=emxProgramCentral.ProgramTop.OpportunityProject&HelpMarker=emxhelprisksummary&freezePane=Name&postProcessJPO=emxTask:postProcessRefresh&hideLaunchButton=true&expandProgramMenu=PMCOpportunityListMenu&showPageURLIcon=false&expandLevelFilter=false&autoFilter=false&showClipboard=false&cellwrap=false&rowGrouping=false&customize=false&multiColumnSort=false&newTab=true&displayView=details&invokedFrom=statusReport";
           String objectId = emxGetParameter(request, "objectId");

           Map paramMap = new HashMap(1);
           paramMap.put("parentOID",objectId);

           Enumeration requestParams = emxGetParameterNames(request);
           StringBuilder url = new StringBuilder();

           if(requestParams != null){
                 while(requestParams.hasMoreElements()){
                      String param = (String)requestParams.nextElement();
                      String value = emxGetParameter(request,param);
                      url.append("&"+param);
                      url.append("="+XSSUtil.encodeForURL(context, value));
                 }
                 strURL = strURL + url.toString();
           }
        %>
            <script language="javascript">
                     var strUrl = "<%=strURL%>";
                     document.location.href = strUrl;
            </script>
       <%
    }



    else if ("isPortalMode".equalsIgnoreCase(strMode))  {

        boolean isModifyOp = false;
        String selectedTaskid = DomainObject.EMPTY_STRING;
        sLanguage = request.getHeader("Accept-Language");
        projectType = DomainConstants.TYPE_PROJECT_SPACE;
        String projectTemplateType = DomainConstants.TYPE_PROJECT_TEMPLATE;
        String projectConceptType= DomainConstants.TYPE_PROJECT_CONCEPT;

        String selectedids[] = request.getParameterValues("emxTableRowId");
        StringList slIds = com.matrixone.apps.domain.util.FrameworkUtil.split(selectedids[0], "|");

        Map <String,String>selectedRowIdMap = ProgramCentralUtil.parseTableRowId(context,selectedids[0]);
        selectedTaskid = selectedRowIdMap.get("objectId");
        String strRowLevel = selectedRowIdMap.get("rowId");

        if(selectedTaskid == "" || selectedTaskid == null){
            selectedTaskid = (String) slIds.get(0);
            isModifyOp = true;
        }


        DomainObject selectedObj = new DomainObject(selectedTaskid);

        String selectedTaskStates = selectedObj.getCurrentState(context).getName();
        String taskPolicy = selectedObj.getDefaultPolicy(context,projectType);
        String completeState     = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Complete");
        String reviewState       = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Review");
        String activeState       = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Active");

        StringList slSelectable = new StringList();
        slSelectable.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_SPACE);
        slSelectable.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
        slSelectable.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_CONCEPT);
        slSelectable.add(SELECT_SHADOW_GATE_ID);

        Map <String,String>objectInfoMap = selectedObj.getInfo(context,slSelectable);
        String isProjectSpace = objectInfoMap.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_SPACE);
        String isProjectTemplate = objectInfoMap.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
        String isProjectConcept = objectInfoMap.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_CONCEPT);
        String strShadowGateId = objectInfoMap.get(SELECT_SHADOW_GATE_ID);

        if(strShadowGateId != null && !strShadowGateId.equals("")){
             %>
             <script language="javascript" type="text/javaScript">
             alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DeliverablePlanning.CannnotAddDependency</framework:i18nScript>");
             </script>
             <%
             return;
        }

        if(strRowLevel.equals("0") && ("TRUE".equalsIgnoreCase(isProjectSpace) || "TRUE".equalsIgnoreCase(isProjectTemplate) || "TRUE".equalsIgnoreCase(isProjectConcept))){
                 %>
                 <script language="javascript" type="text/javaScript">
                     alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Alert.CannotPerform</framework:i18nScript>");
                 </script>
                 <%
                 return;
        }

        if(selectedTaskStates.equals(completeState) || selectedTaskStates.equals(reviewState) ){
            %>
                   <script language="javascript" type="text/javaScript">
                    var msg = "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.ParentInState1</framework:i18nScript>" +
                     " <%=i18nNow.getStateI18NString(taskPolicy,activeState,sLanguage)%> " +
                     "<framework:i18nScript localize="i18nId">emxProgramCentral.Project.TaskInState2</framework:i18nScript>";
                    alert ( msg );
                    </script>
                     <%
                 return;
                }

         if(selectedObj.hasRelatedObjects(context,DomainConstants.RELATIONSHIP_DELETED_SUBTASK,false)){
             %>
               <script language="javascript" type="text/javaScript">
               alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskHasBeenMarkedForDeletion</framework:i18nScript>");
               </script>
               <%
               return;
          }

        String strURL = "../common/emxPortal.jsp?portal=PMCWBSTaskDependencyPortal&showPageHeader=false";

        if (ProgramCentralUtil.isNotNullString(objId) && !isModifyOp){
            DomainObject task = DomainObject.newInstance(context,selectedTaskid);
            if(strRowLevel.equals("0") && task.isKindOf(context,DomainObject.TYPE_TASK_MANAGEMENT)){
                String projectId = task.getInfo(context, ProgramCentralConstants.SELECT_TASK_PROJECT_ID);
                strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context, projectId);
            }else{
                strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context, objId);
            }
        } else {
            DomainObject task = DomainObject.newInstance(context,selectedTaskid);
            String projectId = task.getInfo(context, ProgramCentralConstants.SELECT_TASK_PROJECT_ID);

            strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context, projectId);
        }

        strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context, selectedTaskid);

%>
      <script language="javascript">
    <%-- XSSOK--%>
       var strUrl = "<%=strURL%>";
       showModalDialog(strUrl,1000,1000);
       </script>
 <%
    }
    else if ("clearAll".equalsIgnoreCase(strMode))  {
%>
        <script language="javascript">
        parent.document.location.href = parent.document.location.href;
        </script>
<%
    }
    else if ("getBadChars".equalsIgnoreCase(strMode)) {
            String sInvalidChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.NameBadChars");
            sInvalidChars = sInvalidChars.trim();
            JsonObject jsonObject = Json.createObjectBuilder()
                                    .add("badChars", sInvalidChars)
                                    .build();
            out.clear();
            out.write(jsonObject.toString());
            return;
    }
    else if("isRiskSelected".equalsIgnoreCase(strMode)){
             String sErrMsg  = "";
             String[] selectedids = request.getParameterValues("emxTableRowId");
             String projectId = emxGetParameter( request, "parentOID");
             String errorMessage = null;
             String riskCreationURL = null;
            StringList requestIdList = new StringList();
            boolean isInvalidRequest = false;

            if (selectedids != null && selectedids.length != 0) {
                   if (selectedids.length == 1) {
                        String riskId =  ProgramCentralUtil.parseTableRowId(context,selectedids)[0];
                        boolean isOfRiskType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_RISK,riskId);
                        if (isOfRiskType) {
                            projectId = XSSUtil.encodeURLForServer(context,projectId);
                            riskId = XSSUtil.encodeURLForServer(context,riskId);
                            riskCreationURL =
                                    "../common/emxForm.jsp?mode=edit&form=CreateNewRPN&portalMode=false&suiteKey=ProgramCentral&targetLocation=slidein&formHeader=emxProgramCentral.Risk.CreateRPN&PrinterFriendly=false&HelpMarker=emxhelprpncreatedialog&postProcessJPO=emxRPNBase:createNewRPN&findMxLink=false"+
                                            "&objectId="+riskId+"&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=createRiskRPN&submitAction=doNothing";

                        } else {
                         errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Common.PleaseSelectOneOpportunity",sLanguage);
                      %>
                        <script language="javascript" type="text/javaScript">
                            alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseSelectOneOpportunity</emxUtil:i18nScript>");
                        </script>
                      <%
                     return;
                        }
                   }
                }

                if (ProgramCentralUtil.isNullString(errorMessage)) {
                    %>
                    <script language="javascript" type="text/javaScript">
                        var riskCreationURL = "<%=XSSUtil.encodeForJavaScript(context,riskCreationURL)%>";
                        getTopWindow().showSlideInDialog(riskCreationURL,true);
                    </script>
                    <%
                }
    }
    else if("quickCreateRisk".equalsIgnoreCase(strMode)){
                String[] selectedIds = request.getParameterValues("emxTableRowId");
                String projectId = emxGetParameter( request, "parentOID");
                String objectId = emxGetParameter( request, "objectId");
                String errorMessage = ProgramCentralConstants.EMPTY_STRING;
                String xmlMessage = ProgramCentralConstants.EMPTY_STRING;

                if(!ProgramCentralUtil.isNullString(objectId)){
                    if(ProgramCentralUtil.isNullString(projectId) || objectId != projectId){
                        projectId = objectId;
                    }
                }

                if (selectedIds != null && selectedIds.length != 0) {
                    if (selectedIds.length >= 1) {
                            String selectedId =  ProgramCentralUtil.parseTableRowId(context,selectedIds)[0];
                            boolean isOfRiskType =  ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_RISK,selectedId);
                            boolean isOfRPNType =   ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_RPN,selectedId);
                            if ((isOfRiskType || isOfRPNType)) {

                                errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Project.SelectProject",sLanguage);
                                  %>
                                    <script language="javascript" type="text/javaScript">
                                        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Risk.SelectNodeForCreateRisk</emxUtil:i18nScript>");
                                        getTopWindow().closeSlideInDialog();
                                    </script>
                                  <%
                                 return;
                            }
                       }
                }

                boolean isOfProjectType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_PROJECT_SPACE,projectId);
                Risk risk = new Risk();
                String name = new DomainObject().getUniqueName("R-");
                risk.create(context, name,risk.POLICY_PROJECT_RISK);
                String riskId = risk.getId(context);
                String timezone = (String)session.getValue("timeZone");
                String rValue = "1";

                int eDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
                java.text.DateFormat format = DateFormat.getDateTimeInstance(eDateFormat, eDateFormat, Locale.US);
                Date  currentDate =  new Date();
                String eDate=format.format(currentDate);
                double clientTZOffset = new Double(timeZone).doubleValue();

                Map paramMap = new HashMap();
                paramMap.put("objectId", riskId);
                paramMap.put("languageStr", sLanguage);

                Map requestMap = new HashMap();
                requestMap.put("mode", "quickCreateRisk");
                requestMap.put("Probability",rValue);
                requestMap.put("Impact",rValue);
                requestMap.put("RPN", rValue);
                requestMap.put("timeZone",timezone);
                requestMap.put("EffectiveDate", eDate);
                requestMap.put("timeZone",timezone);
                requestMap.put("EstimatedEndDate", eDate);
                requestMap.put("EstimatedStartDate", eDate);
                requestMap.put("localeObj", Locale.US);
                requestMap.put("parentOID", projectId);


                Map ProgramMap = new HashMap();
                ProgramMap.put("paramMap",paramMap);
                ProgramMap.put("requestMap",requestMap);
                Risk riskObject = new Risk();

                riskObject = risk.createRisk(context, ProgramMap);
                String rpnRiskRelId = riskObject.getInfo(context,"to[Risk].id");

                xmlMessage = "<mxRoot><action><![CDATA[add]]></action>";
                        xmlMessage +="<data status=\"committed\" fromRMB=\"" + false + "\">";
                        xmlMessage +="<item oid=\"" + riskId + "\" relId=\"" + rpnRiskRelId + "\" pid=\"" + projectId + "\"/>";
                        xmlMessage +="</data></mxRoot>";
                %>
                <script language="javascript" type="text/javaScript">
                if(<%=isOfProjectType%> == true){
                var topFrame = findFrame(getTopWindow(),"PMCProjectRisk");
                if(null == topFrame)
                    topFrame = findFrame(getTopWindow(), "frameDashboard");
                }else{
                    var topFrame = findFrame(getTopWindow(),"detailsDisplay");
                }
                    topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,xmlMessage)%>');
                    topFrame.refreshStructureWithOutSort();
                </script>
              <%

    }
    else if("translateErrorMsg".equalsIgnoreCase(strMode)){
        String key = request.getParameter("key");
        String errorMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", key, context.getSession().getLanguage());
        JsonObject jsonObject = Json.createObjectBuilder()
                                .add("Error",errorMsg)
                                .build();

        out.clear();
        out.write(jsonObject.toString());
        return;
    }
    else if("copyRisk".equalsIgnoreCase(strMode)) {
        String parentId = emxGetParameter(request,"objectId");
        boolean isOfProjectType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_PROJECT_SPACE,parentId);
        String[] selectedRiskRowId = emxGetParameterValues(request,"emxTableRowId");
        selectedRiskRowId = ProgramCentralUtil.parseTableRowId(context, selectedRiskRowId);
        try{
            ContextUtil.startTransaction(context, true);
            boolean copyFile = true;
            for(int i=0;i<selectedRiskRowId.length;i++){
               String selectedRiskId = selectedRiskRowId[i];
               Risk risk = new Risk(selectedRiskId);
               risk.copyRisk(context, parentId, copyFile);
            }
            ContextUtil.commitTransaction(context);
        } catch (Exception e){
            ContextUtil.abortTransaction(context);
        }
        %>
            <script language="javascript" type="text/javaScript">
            if(<%=isOfProjectType%> == true){
              var riskFrame = findFrame(getTopWindow().window.getWindowOpener().parent,"PMCProjectRisk");
            }else{
                var riskFrame = findFrame(getTopWindow().window.getWindowOpener().parent,"detailsDisplay");
            }
            riskFrame.location.href = riskFrame.location.href;
            parent.window.closeWindow();
            </script>
              <%
    }
    else if("postRefresh".equalsIgnoreCase(strMode)) {
        String portalCommandName = (String)emxGetParameter(request, "portalCmdName");
    %>
        <script language="javascript" type="text/javaScript">
           var frame = "<%=portalCommandName%>";
           var topFrame = findFrame(getTopWindow(), frame);
           if(null == topFrame)
              topFrame = findFrame(getTopWindow(), "detailsDisplay");

           topFrame.emxEditableTable.refreshStructureWithOutSort();
        </script>
    <%
    }

    else if ("PMCProgramRisk".equalsIgnoreCase(strMode)) {

         String strURL = "../common/emxIndentedTable.jsp?table=PMCRisksSummary&selection=multiple&Export=true&sortColumnName=Title&sortDirection=ascending&header=emxProgramCentral.ProgramTop.RisksProject&HelpMarker=emxhelprisksummary&freezePane=Name&postProcessJPO=emxTask:postProcessRefresh&hideLaunchButton=true&expandProgramMenu=PMCRiskListMenu&showPageURLIcon=false&expandLevelFilter=false&autoFilter=false&showClipboard=false&cellwrap=false&rowGrouping=false&customize=false&multiColumnSort=false&newTab=true&displayView=details&invokedFrom=statusReport";
         String objectId = emxGetParameter(request, "objectId");

         Map paramMap = new HashMap(1);
         paramMap.put("parentOID",objectId);


         Enumeration requestParams = emxGetParameterNames(request);
         StringBuilder url = new StringBuilder();

         if(requestParams != null){
               while(requestParams.hasMoreElements()){
                   String param = (String)requestParams.nextElement();
                   String value = emxGetParameter(request,param);
                   url.append("&"+param);
                   url.append("="+XSSUtil.encodeForURL(context, value));
               }
               strURL = strURL + url.toString();
         }

        %>
            <script language="javascript">
                     var strUrl = "<%=strURL%>";
                     document.location.href = strUrl;
            </script>
       <%
    }


    else if ("PMCProjectRisk".equalsIgnoreCase(strMode)) {

         String strURL = "../common/emxIndentedTable.jsp?table=PMCRisksSummary&selection=multiple&Export=true&sortColumnName=Title&sortDirection=ascending&toolbar=PMCRisksSummaryToolBar&header=emxProgramCentral.ProgramTop.RisksProject&HelpMarker=emxhelprisksummary&freezePane=Name&postProcessJPO=emxTask:postProcessRefresh&hideLaunchButton=true&expandProgramMenu=PMCRiskListMenu&showPageURLIcon=false";
         String objectId = emxGetParameter(request, "objectId");

         Map paramMap = new HashMap(1);
         paramMap.put("parentOID",objectId);

         String[] methodArgs = JPO.packArgs(paramMap);
         boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxRisk", null, "checkEditAccess", methodArgs, Boolean.class);

         Enumeration requestParams = emxGetParameterNames(request);
         StringBuilder url = new StringBuilder();

         if(requestParams != null){
               while(requestParams.hasMoreElements()){
                   String param = (String)requestParams.nextElement();
                   String value = emxGetParameter(request,param);
                   url.append("&"+param);
                   url.append("="+XSSUtil.encodeForURL(context, value));
               }
               strURL = strURL + url.toString();
         }

          if(hasModifyAccess){
              strURL = strURL + "&editLink=true";
          }
        %>
            <script language="javascript">
                     var strUrl = "<%=strURL%>";
                     document.location.href = strUrl;
            </script>
       <%
    }
    else if("createOpportunityRPN".equalsIgnoreCase(strMode)) {
            String riskId = emxGetParameter(request, "objectId");
        %>
            <script language="javascript" type="text/javaScript">
                var topFrame = findFrame(getTopWindow(), "PMCProjectOpportunity");
                if(! topFrame){
                    topFrame = findFrame(getTopWindow(),"detailsDisplay");
                }
                var xmlRef = topFrame.oXML;
                var riskId = '<%=riskId%>';
                var nParent = emxUICore.selectSingleNode(xmlRef, "/mxRoot/rows//r[@o = '" + riskId + "']");
                var rowid = nParent.getAttribute("id");
                topFrame.emxEditableTable.expand([rowid], "1");
                topFrame.location.href = topFrame.location.href;
            </script>
        <%
    }
    else if("createRiskRPN".equalsIgnoreCase(strMode)) {
            String riskId = emxGetParameter(request, "objectId");
        %>
            <script language="javascript" type="text/javaScript">
                var topFrame = findFrame(getTopWindow(), "PMCProjectRisk");
                if(! topFrame){
                    topFrame = findFrame(getTopWindow(),"detailsDisplay");
                }
                var xmlRef = topFrame.oXML;
                var riskId = '<%=riskId%>';
                var nParent = emxUICore.selectSingleNode(xmlRef, "/mxRoot/rows//r[@o = '" + riskId + "']");
                var rowid = nParent.getAttribute("id");
                topFrame.emxEditableTable.expand([rowid], "1");
                topFrame.refreshStructureWithOutSort();
            </script>
        <%
    }
    else if("createRisk".equalsIgnoreCase(strMode)){
             String[] selectedIds = request.getParameterValues("emxTableRowId");
             String projectId = emxGetParameter( request, "parentOID");
             String objectId = emxGetParameter( request, "objectId");
             String currentFrame = XSSUtil.encodeURLForServer(context, emxGetParameter(request, "portalCmdName"));
             String errorMessage = ProgramCentralConstants.EMPTY_STRING;
             String riskCreationURL = ProgramCentralConstants.EMPTY_STRING;

             if (selectedIds != null && selectedIds.length != 0) {
                if (selectedIds.length == 1) {
                     String selectedId =  ProgramCentralUtil.parseTableRowId(context,selectedIds)[0];
                     boolean isOfRiskType =  ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_RISK,selectedId);
                     boolean isOfRPNType =   ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_RPN,selectedId);
                     if (!(isOfRiskType || isOfRPNType)) {
                         riskCreationURL =
                                 "../common/emxCreate.jsp?type=type_Risk&typeChooser=true&policy=policy_ProjectRisk&form=PMCCreateRiskForm&formHeader=emxProgramCentral.Risk.CreateRisk&HelpMarker=emxhelpriskcreatedialog&findMxLink=false&nameField=autoName&showApply=true&createJPO=emxRisk:createAndConnectRisk&postProcessJPO=emxRiskBase:createRisk&postProcessURL=../programcentral/emxProgramCentralUtil.jsp?mode=addNewObjectThroughXML&submitAction=doNothing&relName="+DomainRelationship.RELATIONSHIP_RISK;
                         Enumeration requestParams = emxGetParameterNames(request);
                         StringBuilder url = new StringBuilder();
                         if(requestParams != null){
                           while(requestParams.hasMoreElements()){
                               String param = (String)requestParams.nextElement();
                               String value = emxGetParameter(request,param);
                               // NX5 - Turn off the toolbars
                               if ("hideToolbar".equalsIgnoreCase(param)) value = "true";
                               if ("hideHeader".equalsIgnoreCase(param)) value = "true";
                               if ("toolbar".equalsIgnoreCase(param)) value ="";
                               if ("editLink".equalsIgnoreCase(param)) value = "false";
                               if ("Export".equalsIgnoreCase(param)) value ="false";
                               url.append("&"+param);
                               url.append("="+XSSUtil.encodeForURL(context, value));
                           }
                           riskCreationURL = riskCreationURL + url.toString();
                     }

                     }else{
                          errorMessage = ProgramCentralUtil.getPMCI18nString(context,"emxProgramCentral.Project.SelectProject",sLanguage);
                           %>
                             <script language="javascript" type="text/javaScript">
                                 alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Risk.SelectNodeForCreateRisk</emxUtil:i18nScript>");
                                 getTopWindow().closeSlideInDialog();
                             </script>
                           <%
                          return;


                     }
                }
             }
             if (ProgramCentralUtil.isNullString(errorMessage)) {
                 %>
                 <script language="javascript" type="text/javaScript">
                     var riskCreationURL = "<%=XSSUtil.encodeForJavaScript(context,riskCreationURL)%>";
                     getTopWindow().showSlideInDialog(riskCreationURL,true);
                 </script>
                 <%
             }
    }
    else if ("addNewObjectThroughXML".equalsIgnoreCase(strMode))  {
            Context contextDB = (matrix.db.Context)request.getAttribute("context");
            String portalCommandName = (String)emxGetParameter(request, "portalCmdName");
            String newTaskId = emxGetParameter(request, "newObjectId");
            newTaskId = XSSUtil.encodeURLForServer(context, newTaskId);
            String objectId = emxGetParameter(request, "objectId");
            objectId = XSSUtil.encodeURLForServer(context, objectId);
            String relationship = (String)emxGetParameter(request, "relName");

            DomainObject newObject = DomainObject.newInstance(contextDB, newTaskId);
            String relId =  newObject.getInfo(contextDB,"to[" + relationship + "].id");
            relId = XSSUtil.encodeURLForServer(context, relId);

            boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
              StringBuffer sBuff = new StringBuffer();
                sBuff.append("<mxRoot>");
                sBuff.append("<action><![CDATA[add]]></action>");

                if (isFromRMB) {
                    sBuff.append("<data fromRMB=\"true\" status=\"committed\">");
                } else {
                    sBuff.append("<data status=\"committed\">");
                }

                sBuff.append("<item oid=\""+newTaskId+"\" relId=\""+relId+"\" pid=\""+objectId+"\"/>");
                sBuff.append("</data>");
                sBuff.append("</mxRoot>");
          %>
          <script language="javascript">
            var frame = "<%=portalCommandName%>";
            var topFrame = findFrame(getTopWindow(), frame);

            if(null == topFrame){
              topFrame = findFrame(getTopWindow(), "PMCProjectRisk");
              if(null == topFrame)
                topFrame = findFrame(getTopWindow(), "frameDashboard");
              if(null == topFrame)
                topFrame = findFrame(getTopWindow(), "detailsDisplay");
            }
            topFrame.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,sBuff.toString())%>');
            topFrame.refreshStructureWithOutSort();
         </script>
     <%
        }
     %>


<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
