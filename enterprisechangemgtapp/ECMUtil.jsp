<%--  ECMUtil.jsp

    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
    
    ECMUtil.jsp is used for processing background operations like resume\transfer ownership.
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@page import = "javax.json.Json"%>
<%@page import = "javax.json.JsonObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.changeaction.interfaces.IChangeActionServices"%>
<%@page import="com.dassault_systemes.enovia.changeaction.factory.ChangeActionFactory"%>

<jsp:useBean id="changeOrder" class="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeOrder" scope="session"/>
<jsp:useBean id="changeAction" class="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeAction" scope="session"/>
<jsp:useBean id="changeRequest" class="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeRequest" scope="session"/>
<jsp:useBean id="mChangeOrder" class="com.dassault_systemes.enovia.enterprisechange.modeler.ChangeOrder" scope="session"/>
<jsp:useBean id="mChangeRequest" class="com.dassault_systemes.enovia.enterprisechange.modeler.ChangeRequest" scope="session"/>
<jsp:useBean id="changeUXUtil" class="com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeUXUtil" scope="session"/>

<%
    String strTemp = "";
    boolean bIsError = false;
    i18nNow i18nnow = new i18nNow();
    String functionality = emxGetParameter(request,"functionality");
    String objectId = emxGetParameter(request, "objectId");
    String jsTreeID = emxGetParameter(request,"jsTreeID");
    String isFrom = emxGetParameter(request, "isFrom");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String targetFrame = emxGetParameter(request, "targetFrame");
    String openerFrame = emxGetParameter(request, "openerFrame"); 
    String strRelIds = emxGetParameter(request, "RelIDs");
    String strObjectIds = emxGetParameter(request, "ObjectIDs");
    String strContextCOId = emxGetParameter(request, "contextCOId");
    String strMode = emxGetParameter(request,"mode");
    String parentOID = emxGetParameter(request, "parentOID");
    String strPortalCommandName = emxGetParameter(request, "portalCmdName");
    
    String stringResFileId = "emxEnterpriseChangeMgtStringResource";
    String strRelImpactAnalysis = PropertyUtil.getSchemaProperty(context,"relationship_ImpactAnalysis");
    
    //getting table row ids from the list page
    String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    
    ChangeAssessment instance = new ChangeAssessment();
    
    // Getting All the Object Ids and Rel Ids
    Map map = (Map)changeUXUtil.getObjectIdsRelIdsMapFromTableRowID(strTableRowIds);
    StringList slRelIds = (StringList)map.get("RelId");
    StringList slObjectIds = (StringList)map.get("ObjId");
    String strCandidateItemsSuccessful = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.CandidateItemAddedSuccessful"); 
    String strAffectedItemsSuccessful = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.ProposedChangeAddedSuccessful");
    String strAlreadyAffected = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.AlreadyProposed");
    String strAlreadyCandidate = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.AlreadyCandidate");
    String strSomeCandidate  = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Confirm.SomeCandidateItemsProposed");
    String strSomeAffected  = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Confirm.SomeProposedChangesProposed");
    
    String strTemplatePromoteError = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.TemplatePromote");
    String strValidCOMsg =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.COActions");
    String strCODeleteErrorMsg =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.CODeleteError");
    String strValidCRMsg =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.CRActions");
    String strValidCAMsg =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.CAActions");
    String strInvalidTransferMsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.TransferOwnershipMsg");
    String strInvalidTransferMsgForCO = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.TransferOwnershipMsgForCO");
    String strInvalidTransferMsgForCR = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.TransferOwnershipMsgForCR");
    String strInvalidTransferMsgForCA = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.TransferOwnershipMsgForCA");
    String strInvalidAffectedItems = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.InvalidRelatedItem");
    String strInvalidMsgForCOHold = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.COHoldErrormsg");
    String strInvalidMsgForCRHold = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.CRHoldErrormsg");
    String strInvalidMsgForIADelete = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.IADeleteErrormsg");
    String strCOCancelMsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.COCancelErrormsg");
    String strCRCancelMsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.CRCancelErrormsg");
    String strInvalidUseOwnerChangeMsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.InvalidUseOwnerChange");
    String strInvalidStateOwnerChangerMsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.InvalidStateOwnerChangerMsg");
    String strInvalidStateCCChangerMsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.InvalidStateCCChangerMsg");
    String strInvalidPolicyCChangerMsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.InvalidPolicyCChangerMsg");
    String strCannotPerformOnRootMsg =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.CannotPerform");
    String strTransferAccessMsgForCA =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Warning.TransferOwnershipAccessMsgForCA");
    
    boolean requireAuthentication = "true".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxFramework.Routes.EnableFDA"));
    boolean showUserName = "true".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxFramework.Routes.ShowUserNameForFDA"));
    
    if((strMode != null && ("AddExistingIA".equalsIgnoreCase(strMode) || "disconnect".equalsIgnoreCase(strMode) || "delete".equalsIgnoreCase(strMode) || "AddRelatedAsCandidate".equalsIgnoreCase(strMode) || "AddRelatedAsAffected".equalsIgnoreCase(strMode) || "AddExisting".equalsIgnoreCase(strMode) || "MoveAsAffected".equalsIgnoreCase(strMode) || "Remove".equalsIgnoreCase(strMode) || "MoveToChange".equalsIgnoreCase(strMode) || "CopyToChange".equalsIgnoreCase(strMode))) || (functionality!=null && ( "deleteTemplate".equals(functionality) || "massCODelete".equals(functionality) || "massCRDelete".equals(functionality) || "promoteTemplate".equals(functionality) || "addAttributeGroup".equals(functionality) || "removeAttributeGroup".equals(functionality) || "AddAttributesToAttributeGroup".equals(functionality) || "RemoveAttributesFromAttributeGroup".equals(functionality) || "removeAttribute".equals(functionality))))
    {
        %>
        <script language="javascript">
        <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
        </script>
        <%
    }       
    
    try     
    {
            ContextUtil.startTransaction(context,true);
            if("CA3DLive".equalsIgnoreCase(functionality)){
                String strObjectId      = (String)emxGetParameter(request, "objectId");
                StringBuffer sfb = new StringBuffer();
                int paramind = 1;
                Enumeration enumParamNames = emxGetParameterNames(request);
                while(enumParamNames.hasMoreElements()) {
                    String paramNameStr = (String) enumParamNames.nextElement();
                    String paramName = XSSUtil.encodeForURL(context, paramNameStr);
                    String paramValue = XSSUtil.encodeForURL(context, emxGetParameter(request, paramNameStr));
                 // To avoid JS error when potal gets called from Full Text search
                    if(paramNameStr.equals("objectId")){
                        continue;
                    }
                    if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue) ) {
                            if(paramind > 1)
                                    sfb.append("&");

                            sfb.append(paramName);
                            sfb.append("=");
                            sfb.append(paramValue);
                            paramind++;
                    }
                }
                DomainObject domObj = new DomainObject(strObjectId);
                strObjectId = domObj.getInfo(context,"to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id");
                sfb.append("&objectId="+ XSSUtil.encodeForURL(context, strObjectId));
                String appendParams = "../components/emxLaunch3DLiveExamineCheck.jsp?"+sfb.toString();
                %>
                <script language="javascript">
                var CAFrame = findFrame(getTopWindow(),"ECM3DliveLaunchCA");
				//XSSOK
                CAFrame.document.location.href = "<%=appendParams%>"; 
                </script>
                <%
            }
            else if ("resumeChange".equalsIgnoreCase(functionality) || "resumeChangeAction".equalsIgnoreCase(functionality) || "resumeChangeforCR".equalsIgnoreCase(functionality)) 
            {
                if("resumeChange".equalsIgnoreCase(functionality)){
                    changeOrder.setId(objectId);
                    changeOrder.resumeCO(context);
                }
                else if("resumeChangeAction".equalsIgnoreCase(functionality)){
                	changeAction.setId(objectId);
                	changeAction.resumeCA(context);
                }
                else{
                    changeRequest.setId(objectId);
                    changeRequest.resumeCR(context);
                }
                
                %>
                <script language="javascript" type="text/javaScript">
                <%
                if(!ChangeUtil.isNullOrEmpty(targetFrame)) 
                {
                %>  
              		var targetFrame = findFrame(getTopWindow(),"<%=XSSUtil.encodeForJavaScript(context,targetFrame)%>");
                    if(targetFrame==null){
                    	targetFrame = findFrame(getTopWindow().getWindowOpener().parent.parent,"<%=XSSUtil.encodeForJavaScript(context,targetFrame)%>");
                    }
                    targetFrame.document.location.href = targetFrame.document.location.href;
                    
                    if(getTopWindow().RefreshHeader){
          					getTopWindow().RefreshHeader();            
          		 		}
                <%
                }
                %>
                </script>
                <%

            }
            else if ("transferBackToInitiator".equalsIgnoreCase(functionality)) 
            {
                changeOrder.setId(objectId);
                changeOrder.transferBackToInitiator(context);
            }
    			else if ("setChangeControlForm".equalsIgnoreCase(functionality)) {
            
            	List iPidObjectList = new ArrayList(); 
            	ChangeUtil changeUtil = new ChangeUtil();
			if (!changeUtil.isNullOrEmpty(objectId)) {
				DomainObject domObj = new DomainObject(objectId);
        			// get the physical id from object id
				String physicalId = domObj.getInfo(context, ChangeConstants.SELECT_PHYSICAL_ID);
        				iPidObjectList.add(physicalId);
        			//Calling modeler API to set Change control flag
        			IChangeActionServices iChangeActionServices = ChangeActionFactory.CreateChangeActionFactory();
        			iChangeActionServices.setChangeControlFromPidList(context,iPidObjectList);
            	}
            	%>
<script language="javascript">
            	 debugger;
            	 parent.location.href = parent.location.href;
            	 </script>
<%
	}
    			else if ("unsetChangeControlForm".equalsIgnoreCase(functionality)) {

			List iPidObjectList = new ArrayList();
			ChangeUtil changeUtil = new ChangeUtil();
			if (!changeUtil.isNullOrEmpty(objectId)) {
				DomainObject domObj = new DomainObject(objectId);
				// get the physical id from object id
				String physicalId = domObj.getInfo(context, ChangeConstants.SELECT_PHYSICAL_ID);
				iPidObjectList.add(physicalId);
				//Calling modeler API to set Change control flag
				IChangeActionServices iChangeActionServices = ChangeActionFactory.CreateChangeActionFactory();
    		        	iChangeActionServices.unsetChangeControlFromPidList(context,iPidObjectList);
            }
%>
<script language="javascript">
    	 debugger;
    	 parent.location.href = parent.location.href;
    	 </script>
<%
    		} 
            if ("pendingContextChange".equalsIgnoreCase(functionality)) {
                String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                String fieldNameOID = emxGetParameter(request, "fieldNameOID");
                
                StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0], "|");
                String strObjectId = strTokenizer.nextToken();                         
                DomainObject objContext = new DomainObject(strObjectId);
                String strContextObjectName = objContext.getInfo(context, DomainConstants.SELECT_NAME);
                
                %>
                    <script language="javascript" type="text/javaScript">
                  //XSSOK
                    var vfieldNameActual = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>");
                  //XSSOK
                    var vfieldNameDisplay = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>");
                  //XSSOK
                    var vfieldNameOID = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("<%=XSSUtil.encodeForJavaScript(context, fieldNameOID)%>");
                    
                  //XSSOK
                    vfieldNameDisplay.value ="<%=strContextObjectName%>" ;
                  //XSSOK
                    vfieldNameActual.value ="<%=strContextObjectName%>" ;
                  //XSSOK
                    vfieldNameOID.value ="<%=XSSUtil.encodeForJavaScript(context, strObjectId)%>" ;
                    
                    //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    getTopWindow().closeWindow();
                    </script>
                <%
            }
            // Copy Candidate to Change Functionality
            if(strMode != null && "CopyToChange".equalsIgnoreCase(strMode))
                {
                StringList slCODetails = FrameworkUtil.split(strTableRowIds[0], "|");
                StringList slConnectingObjects = FrameworkUtil.split(strObjectIds, "|");
                // Excluding the connected Candidate Item and Affected Item.
                HashMap hmHashMap = instance.excludingConnectedAIAndCI(context, (String)slCODetails.get(0), slConnectingObjects, strContextCOId);
                String strStatus = (String) hmHashMap.get("status");
                StringList slObjectConnect = (StringList) hmHashMap.get("ObjectIds");
                StringList slNotConnectedObjNames = (StringList) hmHashMap.get("NotConnectedObjNames");
                String[] ObjArr = (String[])slObjectConnect.toArray(new String[slObjectConnect.size()]);
                StringList objList = new StringList(ObjArr);
               
                if(strStatus != null && strStatus.equals("true") && !slObjectConnect.isEmpty())
                {
                %>
                
                <body>
                        <form name=confirmCopyCandidateToCO id=confirmCopyCandidateToCO method="post">                    
                            <input type="hidden" id="candidateItemList" name="candidateItemList" value="<xss:encodeForHTMLAttribute><%=objList%></xss:encodeForHTMLAttribute>" />                            
                        </form>
                        </body>
                        
                <script>
                //XSSOK
                    if(confirm("<%=strSomeCandidate%>"))
                    {
						
                    	document.confirmCopyCandidateToCO.action="ECMUtil.jsp?coId=<%=XSSUtil.encodeForJavaScript(context, (String)slCODetails.get(0))%>&functionality=confirmCopyCandidateToCO";
        				document.confirmCopyCandidateToCO.submit(); 
						
//getTopWindow().location.href = "../common/emxCloseWindow.jsp";						
                        //getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
                        
						var ECMCandidateItemsFrame1 = findFrame(getTopWindow() ,"ECMCandidateItems");
						
						if(ECMCandidateItemsFrame1){
							ECMCandidateItemsFrame1.location.href = ECMCandidateItemsFrame1.location.href;
						}
                        getTopWindow().closeWindow();
                    }
                    else
                    {
                        //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    	getTopWindow().closeWindow();
                    }
                </script>
                <%
                }
                else if(strStatus.equals("false") && !slObjectConnect.isEmpty())
                {
                    instance.addCandidateItem(context, (String)slCODetails.get(0), ObjArr);
                    %>
                    <script>
                    alert("<%=XSSUtil.encodeForJavaScript(context,strCandidateItemsSuccessful)%>");   
					var ECMCandidateItemsFrame1 = findFrame(getTopWindow() ,"ECMCandidateItems");
						if(ECMCandidateItemsFrame1){
							ECMCandidateItemsFrame1.location.href = ECMCandidateItemsFrame1.location.href;
						}					
                    //getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
                    //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    getTopWindow().closeWindow();
                    </script>
                    <%
                }
                else
                {
                    %>
                    <script>  
                    alert("<%=XSSUtil.encodeForJavaScript(context,strAlreadyCandidate)%>");
                    //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    getTopWindow().closeWindow();
                    </script>
                    <%
                }
            }
            else if("confirmCopyCandidateToCO".equals(functionality)){
            	String strCOId = emxGetParameter(request, "coId");
         		System.out.println("After Change order ID"+strCOId);
         		String strCandidateItems = emxGetParameter(request, "candidateItemList");
         		strCandidateItems = strCandidateItems.replace("[", "");
         		strCandidateItems = strCandidateItems.replace("]", "");
         		String[] arrCandidateItems = strCandidateItems.split(",");
         		instance.addCandidateItem(context, strCOId, arrCandidateItems);    
            }
            //Promote & Demote Change Template Object  
                    else if("promoteTemplate".equals(functionality)){
                        String changeTemplateId = "";
                        StringList sSelects = new StringList();
                        sSelects.add(DomainConstants.SELECT_ID);
                        sSelects.add(DomainConstants.SELECT_CURRENT);
                        HashSet sFinalSet = new HashSet();
                        MapList mlState = DomainObject.getInfo(context, (String[])slObjectIds.toArray(new String[slObjectIds.size()]), sSelects);
                        Iterator itr  = mlState.iterator();
                        while(itr.hasNext()){
                            Map tempMap = (Map)itr.next();
                            changeTemplateId = (String)tempMap.get("current");
                            sFinalSet.add(changeTemplateId);
                        }
                        if(sFinalSet.size()>1){%>
                            <script language=javascript>
                                alert("<%=XSSUtil.encodeForJavaScript(context,strTemplatePromoteError)%>");  
                            </script>
                         <%}
                        else{
                            try{
                                String alrtMsg = ChangeTemplate.promote(context, mlState);
                                if(null!= alrtMsg && "".equals(alrtMsg)){%>
                                        <script language=javascript>
                                        parent.location.href = parent.location.href;
                                        </script>
                                <%}
                                else{%>
                                <script language=javascript>
                                    alert("<%=XSSUtil.encodeForJavaScript(context,alrtMsg)%>");
                                    parent.location.href = parent.location.href;
                                    </script>
                                <%}
                                
                            }catch(Exception Ex){   
                                session.putValue("error.message", Ex.getMessage().toString());
                            }
                        }
                    }
                    //Mass Approval of CO/CA Task
                    else if("ChangeTaskMassApproval".equals(functionality)) {
                    boolean isSuccess = com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeTemplate.isChange(context, slObjectIds);
                    StringBuffer sb = new StringBuffer();
                    
                    for(int i= 0; i<slObjectIds.size(); i++)
                    {
                        String single = (String)slObjectIds.get(i);
                        sb.append(single);
                        if(i!=slObjectIds.size()-1)
                            sb.append(",");
                    }
                    String isMassApproval = emxGetParameter(request,"MassApproval");
                    String action  = "../common/emxTableEdit.jsp?program=enoECMChangeOrderBase:getChangeTasks&objectIdToApprove="+sb.toString()+"&table=AEFMyTaskMassApprovalSummary&selection=multiple&header=emxComponents.Common.TaskMassApproval&postProcessURL=emxLifecycleTasksMassApprovalProcess.jsp&HelpMarker=emxhelpmytaskmassapprove&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=component";
                    if(isSuccess)
                    {%>
                    <body>
                        <form name=TaskMassApproveForm id=TaskMassApproveForm method="post">
                        <%
                        if(requireAuthentication){
                            %>
                            <input type="hidden" id="pageAction" name="pageAction" value="<xss:encodeForHTMLAttribute><%=action%></xss:encodeForHTMLAttribute>" />
                            <input type="hidden" id="showUserName" name="showUserName" value="<xss:encodeForHTMLAttribute><%=showUserName%></xss:encodeForHTMLAttribute>" />
                            <script language="Javascript" >
                            var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
                            TaskMassApproveForm.action = "../common/emxRoutesFDAUserAuthenticationDialog.jsp";
                            window.resizeTo(400,400);
                            TaskMassApproveForm.submit();           
                        </script>   
                        <%  
                        }else{
                            %>
                            <script language="Javascript" >
                            var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
                            	TaskMassApproveForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                TaskMassApproveForm.submit();           
                            </script>
                            
                        <%  
                        }
                        %>
                        </form>
                        </body>
                    <%}
                    else{%>
                    <script language="javascript">          
                    	    alert("<%=XSSUtil.encodeForJavaScript(context,strValidCOMsg) %>");
                            getTopWindow().closeWindow();
                            </script>
                        
                    <%}
                    }
                    //Mass Task Approval from Change DashBoard
                    else if("MassTaskApproval".equals(functionality)) {
                        
                        String action = "../common/emxTableEdit.jsp?program=enoECMChangeOrder:getTasks&table=AEFMyTaskMassApprovalSummary&selection=multiple&header=emxComponents.Common.TaskMassApproval&postProcessURL=../common/emxLifecycleTasksMassApprovalProcess.jsp&HelpMarker=emxhelpmytaskmassapprove&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=component&objectId=" + objectId;
                        %>
                        <body>
                            <form name=TaskMassApproveForm id=TaskMassApproveForm method="post">
                            <%
                            if(requireAuthentication){
                                %>
                                <input type="hidden" id="pageAction" name="pageAction" value="<xss:encodeForHTMLAttribute><%=action%></xss:encodeForHTMLAttribute>" />
                                <input type="hidden" id="showUserName" name="showUserName" value="<xss:encodeForHTMLAttribute><%=showUserName%></xss:encodeForHTMLAttribute>" />
                                <script language="Javascript" >
                                var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
                                TaskMassApproveForm.action = "../common/emxRoutesFDAUserAuthenticationDialog.jsp";
                                window.resizeTo(400,400);
                                TaskMassApproveForm.submit();           
                            </script>   
                            <%  
                            }else{
                                %>
                                <script language="Javascript" >
                                var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
                                	TaskMassApproveForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                    TaskMassApproveForm.submit();           
                                </script>
                                
                            <%  
                            }
                            %>
                            </form>
                            </body>
                        <%}
                    //Mass Approval of CA Task
                    else if("CATaskMassApproval".equals(functionality)) {
                    boolean isSuccess = com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeTemplate.isChangeAction(context, slObjectIds);
                    StringBuffer sb = new StringBuffer();
                    
                    for(int i= 0; i<slObjectIds.size(); i++)
                    {
                        String single = (String)slObjectIds.get(i);
                        sb.append(single);
                        if(i!=slObjectIds.size()-1)
                            sb.append(",");
                    }
                    String isMassApproval = emxGetParameter(request,"MassApproval");
                    String action = action = "../common/emxTableEdit.jsp?program=enoECMChangeOrderBase:getChangeTasks&objectIdToApprove="+sb.toString()+"&table=AEFMyTaskMassApprovalSummary&selection=multiple&header=emxComponents.Common.TaskMassApproval&postProcessURL=emxLifecycleTasksMassApprovalProcess.jsp&HelpMarker=emxhelpmytaskmassapprove&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=component";
                    if(isSuccess)
                    {%>
                    <body>
                        <form name=TaskMassApproveForm id=TaskMassApproveForm method="post">
                        <%
                        if(requireAuthentication){
                            %>
                            <input type="hidden" id="pageAction" name="pageAction" value="<xss:encodeForHTMLAttribute><%=action%></xss:encodeForHTMLAttribute>" />
                            <input type="hidden" id="showUserName" name="showUserName" value="<xss:encodeForHTMLAttribute><%=showUserName%></xss:encodeForHTMLAttribute>" />
                            <script language="Javascript" >
                            var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
                            TaskMassApproveForm.action = "../common/emxRoutesFDAUserAuthenticationDialog.jsp";
                            window.resizeTo(400,400);
                            TaskMassApproveForm.submit();           
                        </script>   
                        <%  
                        }else{
                            %>
                            <script language="Javascript" >
                            var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
                            	TaskMassApproveForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                TaskMassApproveForm.submit();           
                            </script>
                            
                        <%  
                        }
                        %>
                        </form>
                        </body>
                    <%}
                    else{%>
                    <script language="javascript">          
                  			alert("<%=XSSUtil.encodeForJavaScript(context,strValidCAMsg) %>");
                            getTopWindow().closeWindow();
                            </script>
                        
                    <%}
                    }

                    //Mass Hold COs
                    else if(ChangeConstants.HOLDCO.equals(functionality) || ChangeConstants.HOLDCR.equals(functionality)){
                        boolean isSuccess;
                        if(ChangeConstants.HOLDCO.equals(functionality)){
                            isSuccess = ChangeTemplate.checkConnectedType(context, slObjectIds);
                        } else{
                            isSuccess = ChangeTemplate.checkConnectedTypeForCR(context, slObjectIds);
                        }
                        StringList objectListToHold = null;
                        System.out.println("Object::"+objectListToHold);
                        String isInValid = "";
                        if(isSuccess){
                        isInValid = ChangeTemplate.getInvalidObject(context,slObjectIds, functionality);
                        objectListToHold = ChangeTemplate.getObjectsToMassHold(context,slObjectIds);
                        }
                                                
                        String isMassHold = emxGetParameter(request, "MassHold");
                        StringBuffer sb = new StringBuffer();
                        if(objectListToHold!=null){
                        for(int i= 0; i<objectListToHold.size(); i++)
                        {
                            String single = (String)objectListToHold.get(i);
                            sb.append(single);
                            if(i!=objectListToHold.size()-1)
                                sb.append(",");
                        }
                        }
                        if(!isSuccess){
                            if(ChangeConstants.HOLDCO.equals(functionality)){
                            %>
                            <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCOMsg)%>");
                            getTopWindow().closeSlideInDialog();
                            </script>
                            <%} else{
                                %>  
                                <script language="javascript">          
                                alert("<%=XSSUtil.encodeForJavaScript(context,strValidCRMsg) %>");
                                getTopWindow().closeSlideInDialog();
                                </script>
                            <%} }
                        if(!UIUtil.isNullOrEmpty(isInValid)){
                            
                            if(ChangeConstants.HOLDCO.equals(functionality)){
                            isInValid+=strInvalidMsgForCOHold;
                            %>
                            <script language="javascript">      
                          //XSSOK
                            alert("<%=isInValid%>");
                            getTopWindow().closeSlideInDialog();
                            </script>
                            <%}else{
                            isInValid+=strInvalidMsgForCRHold;
                            %>
                            <script language="javascript">      
                          //XSSOK
                            alert("<%=isInValid%>");
                            getTopWindow().closeSlideInDialog();
                            </script>
                            <% }
                        }
                        if(objectListToHold!=null && !objectListToHold.isEmpty()){
                            String action = "../common/emxForm.jsp?objectsToHold="+sb.toString()+"&mode=edit&submitAction=refreshCaller&preProcessJavaScript=preProcessForCancelandHoldCO&targetLocation=slidein&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt&openerFrame="+ openerFrame +"";
                            if (ChangeConstants.HOLDCO.equals(functionality)){
                                action+= "&form=type_HoldCO&formHeader=EnterpriseChangeMgt.Heading.HoldCO&postProcessJPO=enoECMChangeOrder:massHoldCO&HelpMarker=emxhelpchangeorderhold";
                            }else{
                                action+= "&form=type_HoldCR&formHeader=EnterpriseChangeMgt.Heading.HoldCR&postProcessJPO=enoECMChangeRequest:massHoldChangeRequest&HelpMarker=emxhelpchangerequesthold";
                            }
                        %>
                        <body>
                            <form name=MassHoldCOForm id=MassHoldCOForm method="post">
                            <script language="Javascript" >
                                var MassHoldCOForm=document.getElementById("MassHoldCOForm");
                                	MassHoldCOForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                    MassHoldCOForm.submit();            
                            </script>
                            </form>
                            </body>
                        <%}
                        }
                 
            
                    //Mass Cancel COs
                    else if(ChangeConstants.CANCELCO.equals(functionality) || ChangeConstants.CANCELCR.equals(functionality)){
                        boolean isSuccess;
                        if(ChangeConstants.CANCELCO.equals(functionality)){
                            isSuccess = ChangeTemplate.checkConnectedType(context, slObjectIds);
                        } else{
                            isSuccess = ChangeTemplate.checkConnectedTypeForCR(context, slObjectIds);
                        }
                        
                        String isMassHold = emxGetParameter(request, "MassCancel");
                        StringBuffer sb = new StringBuffer();
                        
                        for(int i= 0; i<slObjectIds.size(); i++)
                        {
                            String single = (String)slObjectIds.get(i);
                            sb.append(single);
                            if(i!=slObjectIds.size()-1)
                                sb.append(",");
                        }
                        if(!isSuccess){
                            if(ChangeConstants.CANCELCO.equals(functionality)){
                            %>
                            <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCOMsg) %>");
                            getTopWindow().closeSlideInDialog();
                            </script>
                            <%} else{
                                %>  
                                <script language="javascript">          
                                alert("<%=XSSUtil.encodeForJavaScript(context,strValidCRMsg) %>");
                                getTopWindow().closeSlideInDialog();
                                </script>
                            <%} 
                        }
                        else{
                        String sInValidObject = ChangeTemplate.getInvalidObject(context, slObjectIds, functionality);
                        if(!UIUtil.isNullOrEmpty(sInValidObject)){
                            if(ChangeConstants.CANCELCO.equals(functionality)){
                                sInValidObject+=strCOCancelMsg;
                                %>
                                <script language="javascript">          
                              //XSSOK
                                alert("<%=sInValidObject%>");
                                getTopWindow().closeSlideInDialog();
                                </script>
                            <%}else{
                                sInValidObject+=strCRCancelMsg;
                                %>
                                <script language="javascript">          
                              //XSSOK
                                alert("<%=sInValidObject%>");
                                getTopWindow().closeSlideInDialog();
                                </script>
                            <%}
                        }
                        else{
                        String action = "../common/emxForm.jsp?objectsToCancel="+sb.toString()+"&mode=edit&submitAction=refreshCaller&preProcessJavaScript=preProcessForCancelandHoldCO&targetLocation=slidein&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt&openerFrame="+ openerFrame +"";
                        if (ChangeConstants.CANCELCO.equals(functionality)){
                            action+= "&form=type_CancelCO&formHeader=EnterpriseChangeMgt.Heading.CancelCO&postProcessJPO=enoECMChangeOrder:massHoldCancelCO&HelpMarker=emxhelpchangeordercancel";
                        }else{
                            action+= "&form=type_CancelCR&formHeader=EnterpriseChangeMgt.Heading.CancelCR&postProcessJPO=enoECMChangeRequest:massCancelChangeRequest&HelpMarker=emxhelpchangerequestcancel";
                        }
                        %>
                        <body>
                            <form name=MassCancelCOForm id=MassCancelCOForm method="post">
                            <script language="Javascript" >
                                var MassCancelCOForm=document.getElementById("MassCancelCOForm");
                                MassCancelCOForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                MassCancelCOForm.submit();          
                            </script>
                            </form>
                            </body>
                        <%}
                        }
                        }
            
            
                    //CO Mass Transfer Ownership to Change Coordinator
                    else if(ChangeConstants.TRANSFEROWNERSHIPTOCOORDINATOR.equals(functionality) || ChangeConstants.TRANSFEROWNERSHIPTOCOORDINATORFORCR.equals(functionality)){
                        boolean isSuccess;
                        if(ChangeConstants.TRANSFEROWNERSHIPTOCOORDINATOR.equals(functionality)){
                            isSuccess = ChangeTemplate.checkConnectedType(context, slObjectIds);
                        } else{
                            isSuccess = ChangeTemplate.checkConnectedTypeForCR(context, slObjectIds);
                        }
                        boolean isMassTransfer = false;
                        
                        String isTransferOwnership = emxGetParameter(request, "TransferOwnership");
                        StringBuffer sb = new StringBuffer();
                        
                        String single = "";
                        if(slObjectIds.size() > 1)
                            isMassTransfer = true;
                        for(int i= 0; i<slObjectIds.size(); i++)
                        {
                            single = (String)slObjectIds.get(i);
                            sb.append(single);
                            if(i!=slObjectIds.size()-1)
                                sb.append(",");
                        }
                        if(!isSuccess){
                            if(ChangeConstants.TRANSFEROWNERSHIPTOCOORDINATOR.equals(functionality)){
                            %>
                            <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCOMsg) %>");
                            //getTopWindow().closeSlideInDialog();
                            </script>
                            <%} else{
                                %>  
                                <script language="javascript">          
                                 alert("<%=XSSUtil.encodeForJavaScript(context,strValidCRMsg) %>");
                                getTopWindow().closeSlideInDialog();
                                </script>
                            <%} 
                        }
                        else{
                            String sInValidObject = ChangeTemplate.getInvalidObject(context, slObjectIds, functionality);
                            if(!UIUtil.isNullOrEmpty(sInValidObject)){
                                if(ChangeConstants.TRANSFEROWNERSHIPTOCOORDINATOR.equals(functionality)){
                                    sInValidObject+=strInvalidTransferMsgForCO;
                                    %>
                                    <script language="javascript">          
                                  //XSSOK
                                    alert("<%=sInValidObject%>");
                                    getTopWindow().closeSlideInDialog()
                                    </script>
                                    <%
                                }else{
                                    sInValidObject+=strInvalidTransferMsgForCR;
                                    %>
                                    <script language="javascript">          
                                  //XSSOK
                                    alert("<%=sInValidObject%>");
                                    getTopWindow().closeSlideInDialog();
                                    </script>
                                    <%
                                }
                            }
                            else{
                                //String action = "../common/emxForm.jsp?form=type_CancelCO&formHeader=EnterpriseChangeMgt.Heading.CancelCO&objectsToCancel="+sb.toString()+"&toolbar=ECMReviewAffectedItemsToolbar&HelpMarker=emxhelpecocancel&mode=edit&submitAction=refreshCaller&preProcessJavaScript=preProcessForCancelandHoldCO&postProcessJPO=enoECMChangeOrder:massHoldCancelCO&targetLocation=popup&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt";
                                String action="";
                                if(isMassTransfer)
                                action = "../common/emxForm.jsp?form=type_TransferOwnership&parentOID="+single+"&formHeader=EnterpriseChangeMgt.Heading.CRCOTransferOwnership&objectId="+sb.toString()+"&HelpMarker=emxhelptransferowner&mode=edit&submitAction=refreshCaller&postProcessJPO=enoECMChangeOrder:massTransferOwnershipToChangeCoordinator&targetLocation=slidein&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt&openerFrame="+ openerFrame +"";
                                else
                                action = "../common/emxForm.jsp?form=type_TransferOwnership&parentOID="+single+"&formHeader=EnterpriseChangeMgt.Heading.CRCOTransferOwnership&objectId="+sb.toString()+"&HelpMarker=emxhelptransferowner&mode=edit&submitAction=refreshCaller&postProcessJPO=enoECMChangeOrder:massTransferOwnershipToChangeCoordinator&targetLocation=slidein&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt&sfunctionality="+functionality+"&preProcessJavaScript=AutoFillUserName&openerFrame="+ openerFrame +"";
                        
                                %>
                                <body>
                                <form name=MassTransferOwnershipCOForm id=MassTransferOwnershipCOForm method="post">
                                <script language="Javascript" >
                               // var MassTransferOwnershipCOForm=document.getElementById("MassTransferOwnershipCOForm");
                                //MassTransferOwnershipCOForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                //MassTransferOwnershipCOForm.target = "slideIn";                                
                               // MassTransferOwnershipCOForm.submit();         
                                getTopWindow().showSlideInDialog("<%=XSSUtil.encodeForJavaScript(context,action)%>", "true");
                                </script>
                                </form>
                                </body>
                                <%}
                                }
                        }
            
            
            
                    //CO Mass Transfer Ownership to Change Initiator
                    else if(ChangeConstants.TRANSFEROWNERSHIPTOINITIATOR.equals(functionality) || ChangeConstants.TRANSFEROWNERSHIPTOINITIATORFORCR.equals(functionality)){
                        boolean isSuccess;
                        if(ChangeConstants.TRANSFEROWNERSHIPTOINITIATOR.equals(functionality)){
                            isSuccess = ChangeTemplate.checkConnectedType(context, slObjectIds);
                        } else{
                            isSuccess = ChangeTemplate.checkConnectedTypeForCR(context, slObjectIds);
                        }                   
                        String isTransferOwnership = emxGetParameter(request, "TransferOwnership");
                        
                        if(!isSuccess){
                            if(ChangeConstants.TRANSFEROWNERSHIPTOINITIATOR.equals(functionality)){
                            %>
                            <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCOMsg) %>");
                           // getTopWindow().closeWindow();
                            </script>
                            <%} else{
                                %>  
                                <script language="javascript">          
                                alert("<%=XSSUtil.encodeForJavaScript(context,strValidCRMsg) %>");
                                //getTopWindow().closeSlideInDialog();
                                </script>
                            <%} 
                        }
                        else{
                            String sInValidObject = ChangeTemplate.getInvalidObject(context, slObjectIds, functionality);
                            if(!UIUtil.isNullOrEmpty(sInValidObject)){
                                if(ChangeConstants.TRANSFEROWNERSHIPTOINITIATOR.equals(functionality)){
                                    sInValidObject+=strInvalidTransferMsgForCO;
                                    %>
                                    <script language="javascript">          
                                  //XSSOK
                                    alert("<%=sInValidObject%>");
                                    getTopWindow().closeSlideInDialog()
                                    </script>
                                    <%
                                }else{
                                    sInValidObject+=strInvalidTransferMsgForCR;
                                    %>
                                    <script language="javascript">          
                                  //XSSOK
                                    alert("<%=sInValidObject%>");
                                    getTopWindow().closeSlideInDialog()
                                    </script>
                                    <%
                                }
                            }else{
                                Iterator objItr = slObjectIds.iterator();
                                while(objItr.hasNext()){
                                    String id = (String)objItr.next();
                                    changeOrder.setId(id);
                                    String sOriginator = changeOrder.getInfo(context, DomainConstants.SELECT_ORIGINATOR);
                                    if(!sOriginator.equalsIgnoreCase(context.getUser()))
                                    changeOrder.transferBackToInitiator(context);   
                                }
                                %>
                                <script language=javascript>
                                    parent.location.href = parent.location.href;
                                </script>
                                <%
                            }
                          }
                        }
                        
                    //CA Mass Transfer Ownership to Technical Assignee
                    else if(ChangeConstants.TRANSFEROWNERSHIPTOSRTECHNICALASSIGNEE.equals(functionality)){
                        boolean isSuccess = ChangeTemplate.checkSelectedCAType(context, slObjectIds);
                        String isTransferOwnership = emxGetParameter(request, "TransferOwnership");
                        StringBuffer sb = new StringBuffer();
                        String single = "";
                        for(int i= 0; i<slObjectIds.size(); i++)
                        {
                            single = (String)slObjectIds.get(i);
                            sb.append(single);
                            if(i!=slObjectIds.size()-1)
                                sb.append(",");
                        }
                        if(!isSuccess){%>
                        <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCAMsg) %>");
                            getTopWindow().closeSlideInDialog();
                            </script>
                        <%}
                        else{
                            String sInValidObject = ChangeTemplate.getInvalidObject(context, slObjectIds, functionality);
                            if(!UIUtil.isNullOrEmpty(sInValidObject)){
                                sInValidObject+=strInvalidTransferMsgForCA;
                                %>
                                <script language="javascript">          
                              //XSSOK
                                alert("<%=sInValidObject%>");
                                getTopWindow().closeSlideInDialog()
                                </script>
                                <%
                            }else{
                                String action = "../common/emxForm.jsp?form=type_TransferOwnershipCA&parentOID="+single+"&formHeader=EnterpriseChangeMgt.Heading.CATransferOwnership&objectId="+sb.toString()+"&HelpMarker=emxhelptransferowner&mode=edit&submitAction=refreshCaller&postProcessJPO=enoECMChangeOrder:massTransferOwnershipToTechnicalAssignee&targetLocation=slidein&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt&sfunctionality="+functionality+"&preProcessJavaScript=AutoFillUserName";
                        %>
                        <body>
                            <form name=MassTransferOwnershipCAForm id=MassTransferOwnershipCAForm method="post">
                            <script language="Javascript" >
                                var MassTransferOwnershipCOForm=document.getElementById("MassTransferOwnershipCAForm");
                                MassTransferOwnershipCOForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                MassTransferOwnershipCOForm.submit();           
                            </script>
                            </form>
                            </body>
                        <%}
                        }
                    }
            		// new transfer Ownership
                    else if(ChangeConstants.TRANSFEROWNERSHIP.equals(functionality)){
                        boolean isSuccess = ChangeTemplate.checkSelectedCAType(context, slObjectIds);
                        String isTransferOwnership = emxGetParameter(request, "TransferOwnership");
                        StringBuffer sb = new StringBuffer();
                        String single = "";
                        for(int i= 0; i<slObjectIds.size(); i++)
                        {
                            single = (String)slObjectIds.get(i);
                            sb.append(single);
                            if(i!=slObjectIds.size()-1)
                                sb.append(",");
                        }
                        if(!isSuccess){%>
                        <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCAMsg) %>");
                            getTopWindow().closeSlideInDialog();
                            </script>
                        <%}
                        else{
                        	
                        	StringBuffer objBuff = new StringBuffer();
                        	for(int index=0;index<slObjectIds.size();index++){
                        		String strCAid = (String) slObjectIds.get(index);
                        		if(!ChangeAction.getAccess(context, "Transfer", strCAid)){
                        			String strCAName = new DomainObject(strCAid).getInfo(context, DomainConstants.SELECT_NAME);
                        			if(objBuff.length()>0)
                        				objBuff.append(", ");
                        			objBuff.append(strCAName);
                        			objBuff.append(" ");
                        		                        			
                        		}
                        	}
                            String sInValidObject = objBuff.toString();
                            if(!UIUtil.isNullOrEmpty(sInValidObject)){
                                sInValidObject+=strTransferAccessMsgForCA;
                                %>
                                <script language="javascript">          
                              //XSSOK
                                alert("<%=sInValidObject%>");
                                getTopWindow().closeSlideInDialog()
                                </script>
                                <%
                            }else{
                               
                                String action = "../common/emxForm.jsp?form=type_CATransferOwnership&parentOID="+single+"&formHeader=EnterpriseChangeMgt.Heading.TransferOwnership&objectIds="+sb.toString()+"&HelpMarker=emxhelptransferowner&mode=edit&submitAction=refreshCaller&postProcessJPO=enoECMChangeAction:transferOwnerShipCASummary&targetLocation=slidein&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt&sfunctionality="+functionality;
                        %>
                        <body>
                            <form name=MassTransferOwnershipCAForm id=MassTransferOwnershipCAForm method="post">
                            <script language="Javascript" >
                                var MassTransferOwnershipCOForm=document.getElementById("MassTransferOwnershipCAForm");
                                MassTransferOwnershipCOForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                MassTransferOwnershipCOForm.submit();           
                            </script>
                            </form>
                            </body>
                        <%}
                        }
                    }
            
            
                    //CO Mass Transfer Ownership to Change Initiator
                    else if(ChangeConstants.TRANSFEROWNERSHIPTOTECHNICALASSIGNEE.equals(functionality)){
                        boolean isSuccess = ChangeTemplate.checkSelectedCAType(context, slObjectIds);                   
                        String isTransferOwnership = emxGetParameter(request, "TransferOwnership");
                        StringBuffer sb = new StringBuffer();
                        String single = "";
                        for(int i= 0; i<slObjectIds.size(); i++)
                        {
                            single = (String)slObjectIds.get(i);
                            sb.append(single);
                            if(i!=slObjectIds.size()-1)
                                sb.append(",");
                        }
                        if(!isSuccess){%>
                        <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCAMsg) %>");
                            getTopWindow().closeSlideInDialog();
                            </script>
                        <%}
                        else{
                            String sInValidObject = ChangeTemplate.getInvalidObject(context, slObjectIds, functionality);
                            if(!UIUtil.isNullOrEmpty(sInValidObject)){
                                sInValidObject+=strInvalidTransferMsgForCA;
                                %>
                                <script language="javascript">          
                              //XSSOK
                                alert("<%=sInValidObject%>");
                                getTopWindow().closeSlideInDialog()
                                </script>
                                <%
                            }else{
                                String action = "../common/emxForm.jsp?form=type_TransferOwnershipCA&parentOID="+single+"&formHeader=EnterpriseChangeMgt.Heading.CATransferOwnership&objectId="+sb.toString()+"&HelpMarker=emxhelptransferowner&mode=edit&submitAction=refreshCaller&postProcessJPO=enoECMChangeOrder:massTransferOwnershipToTechnicalAssignee&targetLocation=slidein&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=enterprisechangemgt&sfunctionality="+functionality+"&preProcessJavaScript=AutoFillUserName";
                            %>
                        <body>
                            <form name=MassTransferOwnershipCAForm id=MassTransferOwnershipCAForm method="post">
                            <script language="Javascript" >
                                var MassTransferOwnershipCOForm=document.getElementById("MassTransferOwnershipCAForm");
                                MassTransferOwnershipCOForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
                                MassTransferOwnershipCOForm.submit();           
                                </script>
                            </form>
                            </body>
                        <%}
                            }
                        }
            
            
                    //Delete CO, selection multiple COs 
                    else if("massCODelete".equals(functionality) || "massCRDelete".equals(functionality)){
                        boolean isSuccess;
                        boolean sAccessCheck 	= false;
                        if("massCODelete".equals(functionality)){
                            isSuccess = ChangeTemplate.checkConnectedType(context, slObjectIds);
                        } else{
                            isSuccess = ChangeTemplate.checkConnectedTypeForCR(context, slObjectIds);
                        }
                        String isMassDelete = emxGetParameter(request, "MassDelete");
                        StringList objectsToDelete = new StringList();
                        
                        StringList sSelectList = new StringList();
                        sSelectList.addElement(DomainConstants.SELECT_CURRENT);
                                        
                        
                        if(!isSuccess){
                            if("massCODelete".equals(functionality)){
                            %>
                            <script language="javascript">          
                            alert("<%=XSSUtil.encodeForJavaScript(context,strValidCOMsg) %>");
                            //getTopWindow().closeWindow();
                            </script>
                            <%} else{
                                %>  
                                <script language="javascript">          
                                alert("<%=XSSUtil.encodeForJavaScript(context,strValidCRMsg) %>");
                                //getTopWindow().closeWindow();
                                </script>
                            <%} 
                        }
                        else{
                        
                        	String[] saObjectIds =(String[])slObjectIds.toArray(new String[slObjectIds.size()]);
                        	try{
                        		if("massCODelete".equals(functionality)){
                        			if(strTableRowIds[0].endsWith("|0")){
                        				 %>
                        		           <script language="javascript" type="text/javaScript">
                        		           alert("<%=XSSUtil.encodeForJavaScript(context,strCannotPerformOnRootMsg) %>");                
                        		           </script>
                        		        <%
                        			}
                        			else{
                        			
                        			mChangeOrder.delete(context,saObjectIds);
                        			}
                        		}else{
                        			
                        			mChangeRequest.delete(context,saObjectIds);
                        		}
                        		
                        		 %>
                                 <script language=javascript>
                                     parent.location.href = parent.location.href;
                                     </script>
                                 <%
                        		
                        	}catch(Exception Ex){   
                        		ContextUtil.abortTransaction(context);
                                session.putValue("error.message", Ex.getMessage().toString());
                            }
                        	
                        	/*
                        	StringList slCOSelectable = new StringList(DomainConstants.SELECT_CURRENT);
                        	slCOSelectable.add(DomainConstants.SELECT_OWNER);
                        	slCOSelectable.add(DomainConstants.SELECT_NAME);
                        	
                            Iterator itrObj = slObjectIds.iterator();
                            while(itrObj.hasNext()){
                                String id = (String)itrObj.next();
                                changeOrder.setId(id);
                                Map mInfoMap = changeOrder.getInfo(context, slCOSelectable);
                                String sInfo = (String)mInfoMap.get(DomainConstants.SELECT_CURRENT);
                                String ownerInfo = (String)mInfoMap.get(DomainConstants.SELECT_OWNER);
                                String changeOrderName = (String)mInfoMap.get(DomainConstants.SELECT_NAME);
                                
                                String contextUser = context.getUser();
                                if(!ownerInfo.equalsIgnoreCase(contextUser))
                                {
                                	sAccessCheck = changeOrder.getAccessMask(context).hasDeleteAccess();
                                	if(sAccessCheck)
                					{
                                		changeOrder.deleteObject(context);
                					}
                                	else
                                	{	
                                		%>
                                    	<script language="javascript">          
                                    	alert("<%=XSSUtil.encodeForJavaScript(context,strCODeleteErrorMsg) %>" + " <%=changeOrderName%>");
                                    	</script>
                                    	<%
                                	}
                                }
                                else if(!sInfo.equalsIgnoreCase("In Work")||!sInfo.equalsIgnoreCase("In Approval"))
                                {
                                    changeOrder.deleteObject(context);
                                }
                            }
                            */
                            
                           
                                }
                            }
                        
                        
                                
                    //Delete Change Template  
                    else if("deleteTemplate".equals(functionality)){
                        try{
                                String sAlertMsg = ChangeTemplate.delete(context, slObjectIds); 
                                if(null!= sAlertMsg && "".equals(sAlertMsg)){%>
                                        <script language=javascript>
                                            parent.location.href = parent.location.href;
                                        </script>
                                <%}
                                else{%>
                                <script language=javascript>
                                    alert("<%=XSSUtil.encodeForJavaScript(context,sAlertMsg)%>");
                                    parent.location.href = parent.location.href;
                                    </script>
                                <%}
                            }catch(Exception Ex){   
                                session.putValue("error.message",Ex.getMessage());
                            }
                    }
            //Add Attributes to Change Template Object Interface
                    else if("addAttributeGroup".equals(functionality)){
                        try{
                        boolean isSuccess = ChangeTemplate.addAttributeGroupToChangeTemplate(context, slObjectIds, parentOID);
                        if(isSuccess){%>
                            <script language="javascript">
                                getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
                                getTopWindow().closeWindow();
                            </script>
                        <%}
                        }catch(Exception Ex){
                            session.putValue("error.message",Ex.getMessage());
                            throw new Exception(Ex.getMessage());
                        }
                    }
                    else if("removeAttributeGroup".equals(functionality)){
                        try{
                        boolean isSuccess = ChangeTemplate.removeAttributeGroupFromChangeTemplate(context, slObjectIds, parentOID);
                        if(isSuccess){%>
                            <script language="javascript">
                            getTopWindow().refreshTablePage();
                            </script>
                        <%}
                        }catch(Exception Ex){
                            session.putValue("error.message",Ex.getMessage());
                            throw new Exception(Ex.getMessage());
                        }
                    }
                    else if("AddAttributesToAttributeGroup".equals(functionality)){
                        String AGName = emxGetParameter(request,"AGName");
                        try{
                        boolean isSuccess = ChangeTemplate.AddRemoveAttributesToAttributeGroup(context, slObjectIds, AGName, "add");
                        
                        if(isSuccess){%>
                            <script language="javascript">
                            getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
                            getTopWindow().closeWindow();
                            </script>
                        <%}
                        }catch(Exception Ex){
                            session.putValue("error.message",Ex.getMessage());
                            throw new Exception(Ex.getMessage());
                        }
                    }
                    else if("RemoveAttributesFromAttributeGroup".equals(functionality)){
                        String AGName = emxGetParameter(request,"AGName");
                        try{
                        boolean isSuccess = ChangeTemplate.AddRemoveAttributesToAttributeGroup(context, slObjectIds, AGName, "remove");
                        if(isSuccess){%>
                            <script language="javascript">
                                getTopWindow().refreshTablePage();
                            </script>
                        <%}
                        }catch(Exception Ex){
                            session.putValue("error.message",Ex.getMessage());
                        }
                    }
                    //Add Attributes to Change Template Object Interface
                    else if("addAttribute".equals(functionality)){
                        boolean isSuccess = ChangeTemplate.addAttributeToInterface(context, slObjectIds, parentOID);
                        try{
                        if(isSuccess){%>
                            <script language="javascript">
                                getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
                                getTopWindow().closeWindow();
                            </script>
                        <%}
                        }catch(Exception Ex){
                            session.putValue("error.message",Ex.getMessage());
                        }
                    }
                    
                    //Remove Attributes from Change Template Object Interface
                    else if("removeAttribute".equals(functionality)){
                        boolean isSuccess = ChangeTemplate.removeInterfaceAttributes(context, slObjectIds, parentOID);
                        try{
                        if(isSuccess){%>
                            <script language="javascript">
                                getTopWindow().refreshTablePage();
                            </script>
                         <%}
                        }catch(Exception Ex){
                            session.putValue("error.message",Ex.getMessage());
                        }
                    }
                    
                    //Change Template Interface's Attribute filter process 
                    else if("filterAttribute".equals(functionality)){
                        try {
                            String strDoFilter          = emxGetParameter(request,"filter");
                            String strnameMatches       = emxGetParameter(request,"ECMAttributeNameMatches");
                            String strTypeFilter        = emxGetParameter(request,"ECMAttributeType");
                            String sTableName           = emxGetParameter(request,"table");
                        %>
                        <html>
                        <head></head>
                        <body>
                        <script language="JavaScript">
                     	 	parent.resetParameter("filter","<%=XSSUtil.encodeForJavaScript(context,strDoFilter)%>");
                            parent.resetParameter("ECMAttributeNameMatches","<%=XSSUtil.encodeForJavaScript(context,strnameMatches)%>");
                            parent.resetParameter("ECMAttributeType","<%=XSSUtil.encodeForJavaScript(context,strTypeFilter)%>");
                            parent.resetParameter("parentOID","<%=XSSUtil.encodeForJavaScript(context,parentOID)%>");
                            parent.resetParameter("submitLabel","emxFramework.Common.Done");
                            parent.resetParameter("cancelLabel","emxFramework.Common.Cancel");
                            parent.refreshSBTable("<%=XSSUtil.encodeForJavaScript(context,sTableName)%>","Name","ascending");
                        </script>
                        <%} catch (Exception ex){
                            session.putValue("error.message",ex.getMessage());
                        }%>
                        </body>
                        </html>
            <% }
                    else if ("attributeChooser".equalsIgnoreCase(functionality)){
                        String typeAhead = emxGetParameter(request, "typeAhead");
                        String strLanguageStr = emxGetParameter(request, "languageStr");
                        
                        Map testMap = (Map)changeUXUtil.getObjectIdsRelIdsMapFromTableRowID(strTableRowIds);
                        slObjectIds = (StringList)testMap.get("ObjId");
                        StringBuffer attrDisplay = new StringBuffer();
                        StringBuffer attrActual = new StringBuffer();
                        Iterator itr = slObjectIds.iterator();
                        while(itr.hasNext()){
                            String attrName = (String)itr.next();
                            attrActual.append(attrName);
                            attrDisplay.append(i18nNow.getAttributeI18NString(attrName, strLanguageStr));
                            if(itr.hasNext()){
                                attrActual.append("|");
                                attrDisplay.append(",");
                            }
                        }
                %>
                        <script language="javascript" type="text/javaScript">
                      //XSSOK
                        var form="<%=XSSUtil.encodeForJavaScript(context,"editDataForm")%>";
                      //XSSOK
                        var typeAhead = "<%=XSSUtil.encodeForJavaScript(context,typeAhead)%>";
                        var vfieldNameActual;
                        var vfieldNameDisplay;
                        if(typeAhead != "true")
                            //parent.getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                        	getTopWindow().closeWindow();
                      //XSSOK
                        getTopWindow().getWindowOpener().document.forms["editDataForm"].Attributes.value = "<%=XSSUtil.encodeForJavaScript(context,attrActual.toString())%>";
                      //XSSOK
                        getTopWindow().getWindowOpener().document.forms["editDataForm"].AttributesDisplay.value = "<%=attrDisplay.toString()%>";
                      //XSSOK
                        getTopWindow().getWindowOpener().document.forms["editDataForm"].AttributesOID.value = "<%=XSSUtil.encodeForJavaScript(context,attrActual.toString())%>";
                        <%-- if(parent.getTopWindow().getWindowOpener().document.forms.length== 1){
                        //XSSOK
                             vfieldNameActual =parent.getTopWindow().getWindowOpener().document.forms[0].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>"];
                           //XSSOK
                             vfieldNameDisplay = parent.getTopWindow().getWindowOpener().document.forms[0].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>"];
                        }else
                          {
                        //XSSOK
                          vfieldNameActual =parent.getTopWindow().getWindowOpener().document.forms[1].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>"];
                        //XSSOK
                            vfieldNameDisplay = parent.getTopWindow().getWindowOpener().document.forms[1].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>"];
                        }
                      //XSSOK
                            vfieldNameDisplay.value ="<%=strAttributesName%>" ;
                          //XSSOK
                            vfieldNameActual.value ="<%=XSSUtil.encodeForJavaScript(context,strAttributesName)%>"; --%>
                              
                        </script>
                        <%
                    }
             // Move to Change Functionality      
            else if ("MoveToChange".equalsIgnoreCase(strMode))
            {     
                StringList slCODetails = FrameworkUtil.split(strTableRowIds[0], "|");
                StringList slConnectingObjects = FrameworkUtil.split(strObjectIds, "|");
                HashMap hmHashMap = instance.excludingConnectedAIAndCI(context, (String)slCODetails.get(0), slConnectingObjects, strContextCOId);
                String strStatus = (String) hmHashMap.get("status");
                StringList slObjectConnect = (StringList) hmHashMap.get("ObjectIds");
                StringList slNotConnectedObjNames = (StringList) hmHashMap.get("NotConnectedObjNames");
                String[] RelArr = (String[]) hmHashMap.get("RelIds");
                String[] ObjArr = (String[])slObjectConnect.toArray(new String[slObjectConnect.size()]);
                
                if(strStatus != null && strStatus.equals("true") && !slObjectConnect.isEmpty())
                {
                %>
                <script>
              //XSSOK
                    if(confirm("<%=strSomeCandidate%>"))
                    {
						
                        <%
                            instance.MoveCandidateItem(context, RelArr, ObjArr, (String)slCODetails.get(0));
                        %>
						//getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                       //getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
                       
							var ECMCandidateItemsFrame = findFrame(getTopWindow() ,"ECMCandidateItems");
                if(ECMCandidateItemsFrame){
                    ECMCandidateItemsFrame.location.href = ECMCandidateItemsFrame.location.href;
                }
                        getTopWindow().closeWindow();
                    }
                    else
                    {
                        //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    	getTopWindow().closeWindow();
                    }
                </script>
                <%
                }
                else if(strStatus.equals("false") && !slObjectConnect.isEmpty())
                {
                    instance.MoveCandidateItem(context, RelArr, ObjArr, (String)slCODetails.get(0));
                    %>
                    <script>
					
                    alert("<%=XSSUtil.encodeForJavaScript(context,strCandidateItemsSuccessful)%>");              
                    var ECMCandidateItemsFrame = findFrame(getTopWindow() ,"ECMCandidateItems");
                if(ECMCandidateItemsFrame){
                    ECMCandidateItemsFrame.location.href = ECMCandidateItemsFrame.location.href;
                }
                    //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    getTopWindow().closeWindow();
                    </script>
                    <%
                }
                else
                {
                    %>
                    <script>  
                    alert("<%=XSSUtil.encodeForJavaScript(context,strAlreadyCandidate)%>");
                    //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    getTopWindow().closeWindow();
                    </script>
                    <%
                }
            }
            
           // Remove Candidate Item
            else if ("Remove".equalsIgnoreCase(strMode))
            {           
                String[] relArr = (String[])slRelIds.toArray(new String[slRelIds.size()]);
                instance.RemoveCandidateItem(context, relArr);
                %>
                <script>
                parent.location.href = parent.location.href;
                </script>
                <%
            }
            
           // Move As Affected Item
            else if ("MoveAsAffected".equalsIgnoreCase(strMode))
            {   
                HashMap hmHashMap = instance.excludingConnectedAI(context, objectId, slObjectIds);
                String strStatus = (String) hmHashMap.get("status");
                StringList slObjectConnect = (StringList) hmHashMap.get("ObjectIds");
                StringList slNotConnectedObjNames = (StringList) hmHashMap.get("NotConnectedObjNames");
                String[] relArr = (String[]) hmHashMap.get("RelIds");
                ChangeOrder changeOrderInstance = new ChangeOrder(objectId);
                
                if(strStatus != null && strStatus.equals("true") && !slObjectConnect.isEmpty())
                {
                %>
                <script>
                    var contentFrame;
                    if(confirm("<%=strSomeAffected%>"))
                    {
                        <%
                            changeOrderInstance.connectAffectedItems(context, slObjectIds);  
                            instance.RemoveCandidateItem(context, relArr); 
                        %>
                        var tabcommands = findFrame(getTopWindow(),"portalDisplay").objPortal.rows[0].containers[0].tabset.tabs;
                        for (var i = 0; i < tabcommands.length; i++) {
                            if(tabcommands[i].tabName =="ECMCRCOAffectedItems") {
                                tabcommands[i].click();     
                            }                               
                        }                                               
                    }
                </script>
                <%
                }
                else if(strStatus.equals("false") && !slObjectConnect.isEmpty())
                {
                    changeOrderInstance.connectAffectedItems(context, slObjectIds);  
                    instance.RemoveCandidateItem(context, relArr); 
                    %>
                    <script>
                    alert("<%=XSSUtil.encodeForJavaScript(context,strAffectedItemsSuccessful)%>");
                    var tabcommands = findFrame(getTopWindow(),"portalDisplay").objPortal.rows[0].containers[0].tabset.tabs;
                    for (var i = 0; i < tabcommands.length; i++) {
                        if(tabcommands[i].tabName =="ECMCRCOAffectedItems") {
                            tabcommands[i].click();     
                        }                               
                    }                                               
                    var changeActionFrame = findFrame(getTopWindow(), "ECMCRCOAffectedChangeActions");
                    changeActionFrame.editableTable.loadData();
                    changeActionFrame.rebuildView(); 
                    </script>                   
                
                    <%
                }
                else
                {
                    %>
                    <script>  
                    alert("<%=XSSUtil.encodeForJavaScript(context,strAlreadyAffected)%>");
                    </script>
                    <%
                }
            }
            
              // Add Existing Candidate Item
            else if ("AddExisting".equalsIgnoreCase(strMode))
            {     
                String[] objectArr = new String[strTableRowIds.length];
                
                for(int i = 0; i < strTableRowIds.length; i++)
                {
                    strTemp = strTableRowIds[i];
                    StringTokenizer strTokens = new StringTokenizer(strTableRowIds[i], "|");
                    if (strTokens.hasMoreTokens()) 
                    {
                        strTemp = strTokens.nextToken();
                        objectArr[i] = strTemp;
                    }
                }
                
                String strInvalidObjectts = instance.addCandidateItem(context, objectId, objectArr);
                if(!ChangeUtil.isNullOrEmpty(strInvalidObjectts)){
                    strInvalidAffectedItems += strInvalidObjectts;
                %>
                <script>
              //XSSOK
                alert("<%=strInvalidAffectedItems%>");
                </script>
                <%
                }
                %>
                <script>
                var contentFrame = parent.openerFindFrame(getTopWindow(), "ECMCandidateItems");
                if(contentFrame){
                    contentFrame.location.href = contentFrame.location.href;
                }
                getTopWindow().closeWindow();
//              getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                </script>
                <%
            }
              
             // Add Related Item As Affected item
            else if ("AddRelatedAsAffected".equalsIgnoreCase(strMode))
            { 
                HashMap hmHashMap = instance.excludingConnectedAI(context, strContextCOId, slObjectIds);
                String strStatus = (String) hmHashMap.get("status");
                StringList slObjectConnect = (StringList) hmHashMap.get("ObjectIds");
                StringList slNotConnectedObjNames = (StringList) hmHashMap.get("NotConnectedObjNames");
                String[] ObjArr = (String[])slObjectConnect.toArray(new String[slObjectConnect.size()]);
                ChangeOrder changeOrderInstance = new ChangeOrder(strContextCOId);
                
                if(strStatus != null && strStatus.equals("true") && !slObjectConnect.isEmpty())
                {
                %>
                <script>
              //XSSOK
                    if(confirm("<%=strSomeAffected%>"))
                    {
                        <%
                        changeOrderInstance.connectAffectedItems(context, slObjectConnect); 
                        %>                          
                        var contentFrame = findFrame(getTopWindow(), "ECMCRCOAffectedItems");
                        contentFrame.location.href = contentFrame.location.href;
                        getTopWindow().closeWindow();
                    }
                </script>
                <%
                }
                else if(strStatus.equals("false") && !slObjectConnect.isEmpty())
                {
                    Map mpInvalidObjects = changeOrderInstance.connectAffectedItems(context, slObjectConnect);
                    String strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
                    
                    if(!ChangeUtil.isNullOrEmpty(strInvalidObjectts)){
                        strInvalidAffectedItems += strInvalidObjectts;
                        %>
                        <script>
                      //XSSOK
                        alert("<%=strInvalidAffectedItems%>");
                        </script>
                        <%
                    }
                    else{
                    %>
                    <script>
                    alert("<%=XSSUtil.encodeForJavaScript(context,strAffectedItemsSuccessful)%>"); 
                    </script>
                    <%}%>
                    <script>
                    var contentFrame = getTopWindow().openerFindFrame(getTopWindow(), "portalDisplay");
                    contentFrame.location.href = contentFrame.location.href;                    
                    getTopWindow().closeWindow();
                    </script>
                    <%
                }
                else
                {
                    %>
                    <script>  
                    alert("<%=XSSUtil.encodeForJavaScript(context,strAlreadyAffected)%>");
                    getTopWindow().closeWindow();
                    </script>
                    <%
                }
            }
              
           // Add Related Item As Candidate item
            else if ("AddRelatedAsCandidate".equalsIgnoreCase(strMode))
            { 
                HashMap hmHashMap = instance.excludingConnectedAIAndCI(context, strContextCOId, slObjectIds, "");
                String strStatus = (String) hmHashMap.get("status");
                StringList slObjectConnect = (StringList) hmHashMap.get("ObjectIds");
                StringList slNotConnectedObjNames = (StringList) hmHashMap.get("NotConnectedObjNames");
                String[] ObjArr = (String[])slObjectConnect.toArray(new String[slObjectConnect.size()]);
                
                
                if(strStatus != null && strStatus.equals("true") && !slObjectConnect.isEmpty())
                {
                %>
                <script>
              //XSSOK
                    if(confirm("<%=strSomeCandidate%>"))
                    {
                        <%
                            instance.addCandidateItem(context, strContextCOId, ObjArr);
                        %>
                        getTopWindow().closeWindow();
                        var tabcommands = findFrame(getTopWindow(),"portalDisplay").objPortal.rows[0].containers[0].tabset.tabs;
                        for (var i = 0; i < tabcommands.length; i++) {
                            if(tabcommands[i].tabName =="ECMCandidateItems") {
                                tabcommands[i].click();     
                            }                               
                        }                                               
                    }
                </script>
                <%
                }
                else if(strStatus.equals("false") && !slObjectConnect.isEmpty())
                {
                    String strInvalidObjectts = instance.addCandidateItem(context, strContextCOId, ObjArr);
                    if(!ChangeUtil.isNullOrEmpty(strInvalidObjectts)){
                        strInvalidAffectedItems += strInvalidObjectts;
                        %>
                        <script>
                      //XSSOK
                        alert("<%=strInvalidAffectedItems%>");
                        </script>
                        <%
                    }
                    else{
                    %>
                    <script>
                     alert("<%=XSSUtil.encodeForJavaScript(context,strCandidateItemsSuccessful)%>");              
                    </script>
                    <%
                    }
                    %>
                    <script>
                    getTopWindow().closeWindow();
					var tabcommands = getTopWindow().openerFindFrame(getTopWindow(),"portalDisplay").objPortal.rows[0].containers[0].tabset.tabs;
                    for (var i = 0; i < tabcommands.length; i++) {
                        if(tabcommands[i].tabName =="ECMCandidateItems") {
                            tabcommands[i].click();     
                        }                               
                    }                                               
                    </script>
                    <%
                }
                else
                {
                    %>
                    <script>  
                    alert("<%=XSSUtil.encodeForJavaScript(context,strAlreadyCandidate)%>");
                    getTopWindow().closeWindow();
                    </script>
                    <%
                }           
            }
            
            // Impact Analysis Delete Logic

            if("delete".equalsIgnoreCase(strMode))
             {
                  //getting object ids for the corresponding row ids
                  String isInValid = ChangeTemplate.getInvalidObject(context,slObjectIds, strMode);
                  if(UIUtil.isNullOrEmpty(isInValid)){
                      String[] ObjArr = (String[])slObjectIds.toArray(new String[slObjectIds.size()]);
                      DomainObject.deleteObjects(context, ObjArr);
                      %>
                        <script>
                        parent.location.href = parent.location.href;
                        </script>
                      <%
                   }else{
                       isInValid+=strInvalidMsgForIADelete;
                       %>
                        <script>
                      //XSSOK
                        alert("<%=isInValid%>");
                        </script>
                      <%
                   }
              }
              
              // Impact Analysis Remove / Disconnect Logic
            
             else if ("disconnect".equalsIgnoreCase(strMode))
              {
                  String[] relArr = (String[])slRelIds.toArray(new String[slRelIds.size()]);
                  DomainRelationship.disconnect(context, relArr);
                  %>
                <script>
                parent.location.href = parent.location.href;
                </script>
                <%
              }
              
              // Add Existing Impact Analysis Logic
              else if("AddExistingIA".equalsIgnoreCase(strMode)) 
              {
                String[] strArrObjectIds = EngineeringChange.getObjectIds(strTableRowIds);
                for (Object var : strArrObjectIds)
                {
                    String IAId = (String)var;
                    DomainRelationship.connect(context, new DomainObject(objectId), new RelationshipType(strRelImpactAnalysis), new DomainObject(IAId));
                }
                %>
                <script>
                getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
                //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                getTopWindow().closeWindow();
                </script>
                <%
              }
              else if ("searchUtilReviewer".equalsIgnoreCase(strMode)) {
					String targetTag = emxGetParameter(request, "targetTag");
					if (targetTag!=null && !targetTag.isEmpty()) {
						if (targetTag.equalsIgnoreCase("select")) {
							String selectName = emxGetParameter(request, "selectName");
							String emxTableRowIds[] = emxGetParameterValues(request,"emxTableRowId");
							if (emxTableRowIds!=null && emxTableRowIds.length>0) {
								String reviewersHiddenNewValue = "";
								String reviewersHiddenNewTypeValue = "";
								String reviewersNotHideType = "";
								for (int i=0;i<emxTableRowIds.length;i++) {
									String emxTableRowId = emxTableRowIds[i];
									if (emxTableRowId!=null && !emxTableRowId.isEmpty()) {
										// For most webform choosers, default to the object id/name...
							            String emxTableRowObjId = emxTableRowId.split("[|]")[1];
							            DomainObject emxTableRowDom = new DomainObject(emxTableRowObjId);
							            String emxTableRowObjName = emxTableRowDom.getInfo(context, DomainConstants.SELECT_NAME);
							            String emxTableRowObjFullName = PersonUtil.getFullName(context, emxTableRowObjName);
							            String emxTableRowObjTYPE = emxTableRowDom.getInfo(context, DomainConstants.SELECT_TYPE);
							            if (reviewersHiddenNewValue!=null && !reviewersHiddenNewValue.isEmpty()) {
							            	reviewersHiddenNewValue += ",";
							            	reviewersHiddenNewTypeValue += ",";
							            }
							            reviewersHiddenNewValue += emxTableRowObjId;
							            reviewersHiddenNewTypeValue+=emxTableRowObjTYPE;
							            reviewersNotHideType=emxTableRowObjTYPE;
							            %>
										<script language="javascript" type="text/javaScript">
											var selectTag = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,selectName)%>");
											//To make the decision of calling connect/disconnect method only on field modification.
											var isReviewerFieldModified = getTopWindow().getWindowOpener().document.getElementById("IsReviewerFieldModified");
											isReviewerFieldModified.value = "true";
											var reviewersNotHideType="<%=XSSUtil.encodeForJavaScript(context,reviewersNotHideType)%>";
											var option = getTopWindow().getWindowOpener().document.createElement("option");
											option.value = "<%=XSSUtil.encodeForJavaScript(context,emxTableRowObjId)%>";
											option.text = "<%=XSSUtil.encodeForJavaScript(context,emxTableRowObjFullName)%>";
											if(reviewersNotHideType=="Route Template")
											{
												var connectedRTLength = selectTag[0].children.length;
												for(var i=0; i<connectedRTLength; i++){											      	  
												selectTag[0].remove(0);
											}
											}
											selectTag[0].add(option);
										</script>
										<%
									}
								}
								if (reviewersHiddenNewValue!=null && !reviewersHiddenNewValue.isEmpty()) {
									%>
									<script language="javascript" type="text/javaScript">

									
									var reviewersHidden = getTopWindow().getWindowOpener().document.getElementById("ReviewersHidden");
									var reviewersHiddenType = getTopWindow().getWindowOpener().document.getElementById("ReviewersHiddenType");
									var reviewersHiddenValue = reviewersHidden.value;
									var reviewersHiddenTypeValue = reviewersHiddenType.value;
									var hideReviewerPerson = getTopWindow().getWindowOpener().document.getElementById("ReviewrHidePerson");
									var hideReviewerRouteTemplate = getTopWindow().getWindowOpener().document.getElementById("ReviewrHideRouteTemplate");
									var reviewersNotHideType="<%=XSSUtil.encodeForJavaScript(context,reviewersNotHideType)%>";
									if (reviewersHiddenValue!="" && reviewersNotHideType =="Person") {
										reviewersHiddenValue += ",";
									}
									if (reviewersHiddenTypeValue!="" && reviewersNotHideType =="Person") {
										reviewersHiddenTypeValue += ",";
									}
									if(reviewersNotHideType =="Route Template"){
										reviewersHiddenValue = "<%=XSSUtil.encodeForJavaScript(context,reviewersHiddenNewValue)%>";
										reviewersHiddenTypeValue = "<%=XSSUtil.encodeForJavaScript(context,reviewersHiddenNewTypeValue)%>";
										hideReviewerPerson.style.display= "none";
										}
									else{
										reviewersHiddenValue += "<%=XSSUtil.encodeForJavaScript(context,reviewersHiddenNewValue)%>";
										reviewersHiddenTypeValue += "<%=XSSUtil.encodeForJavaScript(context,reviewersHiddenNewTypeValue)%>";
										hideReviewerRouteTemplate.style.display= 'none';
										}									
									reviewersHidden.value = reviewersHiddenValue;								
									reviewersHiddenType.value = reviewersHiddenTypeValue;
									</script>
									<%
								}
							}
						}
					} else {
						throw new Exception("Target Tag is null or empty");
					}
		            
					%>
					<script language="javascript" type="text/javaScript">
						window.getTopWindow().closeWindow();
					</script>
					<%
					
				}
              else if ("searchUtilPerson".equalsIgnoreCase(strMode)) {
					String targetTag = emxGetParameter(request, "targetTag");
					if (targetTag!=null && !targetTag.isEmpty()) {
						if (targetTag.equalsIgnoreCase("select")) {
							String selectName = emxGetParameter(request, "selectName");
							String strModifiedFieldId = "Follower".equalsIgnoreCase(selectName)?"IsFollowerFieldModified":"IsContributorFieldModified";
							String inputFieldHidden = emxGetParameter(request, "inputFieldHidden");
							String emxTableRowIds[] = emxGetParameterValues(request,"emxTableRowId");
							if (emxTableRowIds!=null && emxTableRowIds.length>0) {
								String personHiddenNewValue = "";
								for (int i=0;i<emxTableRowIds.length;i++) {
									String emxTableRowId = emxTableRowIds[i];
									if (emxTableRowId!=null && !emxTableRowId.isEmpty()) {
										// For most webform choosers, default to the object id/name...
							            String emxTableRowObjId = emxTableRowId.split("[|]")[1];
							            DomainObject emxTableRowDom = new DomainObject(emxTableRowObjId);
							            String emxTableRowObjName = emxTableRowDom.getInfo(context, DomainConstants.SELECT_NAME);
							            String emxTableRowObjFullName = PersonUtil.getFullName(context, emxTableRowObjName);
							            if (personHiddenNewValue!=null && !personHiddenNewValue.isEmpty()) {
							            	personHiddenNewValue += ",";
							            }
							            personHiddenNewValue += emxTableRowObjId;
							            %>
										<script language="javascript" type="text/javaScript">
											var selectTag = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,selectName)%>");
											//To make the decision of calling connect/disconnect method only on field modification.
											var isFieldModified = getTopWindow().getWindowOpener().document.getElementById("<%=XSSUtil.encodeForJavaScript(context,strModifiedFieldId)%>");
											isFieldModified.value = "true";
											var option = getTopWindow().getWindowOpener().document.createElement("option");
											option.value = "<%=XSSUtil.encodeForJavaScript(context,emxTableRowObjId)%>";
											option.text = "<%=XSSUtil.encodeForJavaScript(context,emxTableRowObjFullName)%>";
											selectTag[0].add(option);
										</script>
										<%
									}
								}
								if (personHiddenNewValue!=null && !personHiddenNewValue.isEmpty()) {
									%>
									<script language="javascript" type="text/javaScript">
									var personHidden = getTopWindow().getWindowOpener().document.getElementById("<%=XSSUtil.encodeForJavaScript(context,inputFieldHidden)%>");
									var personHiddenValue = personHidden.value;
									if (personHiddenValue!="") {
										personHiddenValue += ",";
									}
									personHiddenValue += "<%=XSSUtil.encodeForJavaScript(context,personHiddenNewValue)%>";
									personHidden.value = personHiddenValue;								
									</script>
									<%
								}
							}
						}
					} else {
						throw new Exception("Target Tag is null or empty");
					}
		            
					%>
					<script language="javascript" type="text/javaScript">
						window.getTopWindow().closeWindow();
					</script>
					<%
					
				}
            //ECM Related CA
              else if("ECMRelatedCA".equals(functionality)) {
            	  boolean isEditable = true;
            	  isEditable=ChangeUtil.hasLicenseOfECM(context);                     
            	  String strPortalName = emxGetParameter(request, "portal");
            	  String strPortalMode = emxGetParameter(request, "portalMode");
            	     String strURL = "../common/emxIndentedTable.jsp?program=enoECMChangeAction:getPrerequisites"
            	             +"&table=ECMCAPrerequisiteSummary&header=EnterpriseChangeMgt.Heading.RelatedCAs"
            	             +"&selection=multiple&sortColumnName=Name&HelpMarker=emxhelperelatedchangeAction"
            	             +"&toolbar=ECMAddRemoveCARelatedCAsToolbar&emxSuiteDirectory=enterprisechangemgt"
            	             +"&suiteKey=EnterpriseChangeMgt&SuiteDirectory=enterprisechangemgt"
            	             +"&StringResourceFileId=";
            	     strURL = strURL + stringResFileId;
            	     strURL = strURL + "&objectId="+ objectId;
            	     strURL = strURL + "&parentOID=" + parentOID;
            	     strURL = strURL + "&jsTreeID=" + jsTreeID;
            	     strURL = strURL + "&portal=" +  strPortalName;
            	     strURL = strURL + "&portalCmdName=" +  strPortalCommandName;
            	     strURL = strURL + "&portalMode=" +  strPortalMode;
            	     //strURL = strURL + "&editLink=" + isEditable;
            	     strURL = XSSUtil.encodeURLForServer(context, strURL);
            	     %>
            	     <script language="javascript">
            			var strUrl = "<%=strURL%>";
            	        window.location.href = strUrl;
            	     </script>
            	 <%             
                  }
              else if("COSummary".equals(functionality)) {
            	  boolean isEditable = true;
            	  DomainObject obj = new DomainObject(objectId);
          		  String strCurrent = obj.getInfo(context, "current");
            	  isEditable=ChangeUtil.hasLicenseOfECM(context);
            	  String strmode="view";
				  if(isEditable && ChangeConstants.STATE_CHANGEREQUEST_INPROCESSCO.equalsIgnoreCase(strCurrent))
				  {
					 strmode="edit";
				  }
            	
            	     String strURL = "../common/emxIndentedTable.jsp?program=enoECMChangeRequest:getChangeOrders"
            	             +"&table=ECMCOSummary&header=EnterpriseChangeMgt.Heading.ChangeOrderSummary"
            	             +"&selection=multiple&sortColumnName=Name&HelpMarker=emxhelpeChangeOrdersummenry"
            	             +"&toolbar=ECMCOSummaryMenuToolbar&emxSuiteDirectory=enterprisechangemgt"
            	             +"&suiteKey=EnterpriseChangeMgt&SuiteDirectory=enterprisechangemgt"
            	             +"&StringResourceFileId=";
            	     strURL = strURL + stringResFileId;
            	     strURL = strURL + "&objectId="+ objectId;
            	     strURL = strURL + "&parentOID=" + parentOID;
            	     strURL = strURL + "&jsTreeID=" + jsTreeID;
            	     strURL = strURL + "&mode=" + strmode;
	            	     strURL = strURL + "&relationship=" + "relationship_ChangeBreakdown";
	            	     strURL = strURL + "&direction=" + "from";
            	     strURL = XSSUtil.encodeURLForServer(context, strURL);
            	     %>
            	     <script language="javascript">
            			var strUrl = "<%=strURL%>";
            	        window.location.href = strUrl;
            	     </script>
            	 <%  
              }
              else if("CloseSlideIn".equalsIgnoreCase(functionality)){
	            	  %>  
	             	 <script language="javascript">
	             			getTopWindow().closeSlideInDialog();
	             	 </script>    
	 	            <% 
              }
        } 
    catch(Exception e) 
    {
            ContextUtil.abortTransaction(context);
            e.printStackTrace();
            session.putValue("error.message", e.getMessage());
            bIsError=true;
    }
    ContextUtil.commitTransaction(context);
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript" type="text/javaScript">
<%
if(!ChangeUtil.isNullOrEmpty(targetFrame)) 
{
%>  
    var targetFrame = findFrame(getTopWindow(),"<%=XSSUtil.encodeForJavaScript(context,targetFrame)%>");
    targetFrame.document.location.href = targetFrame.document.location.href;
<%
}
if("portalRefresh".equalsIgnoreCase(functionality)) 
{
%>  
    var sobjectId = "<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
    var targetFrame = openerFindFrame(getTopWindow(),"detailsDisplay");
    
    <% if(strPortalCommandName != null && (strPortalCommandName.equalsIgnoreCase("AEFLifecycleBasic") || strPortalCommandName.equalsIgnoreCase("ECMLifecycle"))) {%>
   		 targetFrame.location.href =  targetFrame.location.href;
    <%}else{%>
    	targetFrame.location.href = "../common/emxTree.jsp?objectId="+sobjectId;
    <%}%>
<%
}
%>
</script>

<%
	//if("validateRequestedChange".equalsIgnoreCase(functionality)){
	  //String requestedChangeValue = emxGetParameter(request, "requestedChangeValue");
	  //String affectedItemId = emxGetParameter(request, "affectedItemId");
	  //String changeId = emxGetParameter(request, "changeId");
	  //String strContext = emxGetParameter(request, "context");
	  //String alrtMsg = changeAction.checkIfRequestedChangeValid(context, changeId, affectedItemId, //requestedChangeValue, strContext);
	  //JsonObject jsonValue = Json.createObjectBuilder().add("message", alrtMsg).build();

	  //out.clear();
      //out.write(jsonValue.toString());
      //out.flush();
	//} 
	if ("validateUserAccess".equalsIgnoreCase(functionality)) {
		String changeOrderId = emxGetParameter(request, "changeOrderId");
		String changeRequestId = emxGetParameter(request,
		"changeRequestId");
		String strcontext = emxGetParameter(request, "context");
		String alrtMsg = "";
		StringList selectList = new StringList();
		selectList.add("current");
		selectList.add("owner");
		selectList.add("policy");
		String sState = "";
		String sOwner = "";
		String sPolicy = "";
		DomainObject obj = new DomainObject(changeOrderId);
		Map tempMap = obj.getInfo(context, selectList);
		sState = (String) tempMap.get("current");
		sOwner = (String) tempMap.get("owner");
		sPolicy = (String) tempMap.get("policy");
		if (ChangeConstants.FASTTRACK_CHANGE.equalsIgnoreCase(sPolicy)
				&& "CCContext".equalsIgnoreCase(strcontext)) {
			alrtMsg = strInvalidPolicyCChangerMsg;
		} else {
			if (!sOwner.equals(context.getUser())) {
			alrtMsg = strInvalidUseOwnerChangeMsg;
			} else if (ChangeConstants.STATE_FORMALCHANGE_HOLD
		.equals(sState)
		|| ChangeConstants.STATE_FORMALCHANGE_CANCEL
				.equals(sState)
		|| ChangeConstants.STATE_FORMALCHANGE_INWORK
				.equals(sState)
		|| ChangeConstants.STATE_FORMALCHANGE_INAPPROVAL
				.equals(sState)
		|| ChangeConstants.STATE_FORMALCHANGE_COMPLETE
				.equals(sState)
		|| ChangeConstants.STATE_FORMALCHANGE_IMPLEMENTED
				.equals(sState)
		|| ChangeConstants.STATE_FORMALCHANGE_INREVIEW
							.equals(sState)) {
				if ("CCContext".equalsIgnoreCase(strcontext)) {
				alrtMsg=strInvalidStateCCChangerMsg;
				
				} else if (!ChangeConstants.STATE_FORMALCHANGE_INREVIEW
						.equals(sState)) {
				alrtMsg = strInvalidStateOwnerChangerMsg;
				}
			}
		}
		JsonObject jsonValue = Json.createObjectBuilder().add("message", alrtMsg).build();
		out.clear();
	    out.write(jsonValue.toString());
		out.flush();
	} else if ("validateEffortDaysGetKeyVaule"
			.equalsIgnoreCase(functionality)) {
		String strKey = emxGetParameter(request, "key");
		String strValueOfKey = EnoviaResourceBundle.getProperty(
				context, stringResFileId, context.getLocale(), strKey);
		JsonObject jsonValue = Json.createObjectBuilder().add("valueofkey", strValueOfKey).build();
		out.clear();
		out.write(jsonValue.toString());
		out.flush();
	}
%>




