<%--emxEngBOMGoToProductionUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
  --%>

<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.util.ECMUtil"%>
<%@page import="com.dassault_systemes.enovia.changeaction.interfaces.IChangeAction"%>
<%@page import="com.dassault_systemes.enovia.bom.ReleasePhase"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<!--
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="com.matrixone.apps.engineering.ReleasePhaseManager"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.services.IPartService"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.factory.PartMgtFactory"%>
<%@page import="matrix.util.SelectList"%>

emxUIConstants.js is included to call the findFrame() method to get a frame-->

<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>


<%
	String functionality    = emxGetParameter(request,"functionality");
	String objectId         = emxGetParameter(request, "objectId");
	String frameName         = emxGetParameter(request, "frameName");
	String tableName         = emxGetParameter(request, "table");
	

	 String strChildStateNotHigherThanParentErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.BOMChildStatesHigherThanParentPart");
	 String strBOMChildReleasePhaseDevErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.BOMChildReleasePhaseDevelopment");
	 String strReleaseChangeAssociatedWithPartErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.ReleaseCAAssociatedWithPart");
	String strBomGotoProductionFromPartPropertiesOnly = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.BomGotoProductionFromPartPropertiesOnly");
	 String strCAConnected   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.CAConnected");
	 String strNextRevisionAssociatedWithChildPartErrorMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.NextRevisionAssociatedWithChildPart");
	 String strPublishToVPMAlert = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.PublishToVPM");
	 String strMarkupShouldBeApprovedORRejected = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.MarkupIsInProposedState");
	 String reviseSequence = MqlUtil.mqlCommand(context,"print policy $1 select $2 dump",DomainConstants.POLICY_EC_PART,"property[ResetRevision].value");
	 String strPartIsInObsoleteState = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.PartInObsoleteStateBlockBGTP");
	 String strEffectivitySet = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.DragDrop.Alert.EmptyEffectivity");
	 String strPartInApprovedState = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.PartInApprovedStateBlockBGTP");
	 String strChildPartInApprovedState = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.ChildPartInApprovedStateBlockBGTP");
	 String strVPLMControlled = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.ENCBOMGoToProduction.Alert.VPLMControlled");
	 String strVPLMControlledConfiguredPart = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.ENCBOMGoToProduction.Alert.VPLMControlledConfiguredPart");
	 
	 String workUnderChangeSetToProdValidation = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.WorkUnderChange.Validation.SetToProduction");	 
	 
	 String unReleasedChangeConnectedAsForRevise = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.ENCBOMGoToProduction.Alert.CAConnectedNotWithForUpdate");
	 
	  
	
	  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
	  
	  String sRMBObjectId = "";
	  String sRowId = "";
	  String results = "";
	  if (null != tableRowIdList) {
	  
		  boolean rootNodeFail = false;
	      String tableRowId = " "+tableRowIdList[0];
	      StringList slList = FrameworkUtil.split(tableRowId, "|");
	      
      	  sRMBObjectId    = ((String)slList.get(1)).trim();
          sRowId  = ((String)slList.get(3)).trim();
      	
	  }
	boolean transIsActive =context.isTransactionActive();
	if (!transIsActive) {
		context.start(true);
	}
	  try {
		  ContextUtil.pushContext(context);	
	if("updatePart".equals(functionality))
	{
		
			
			DomainObject domObj = DomainObject.newInstance(context,objectId);
			StringList affectedItems = new StringList();
			boolean isStateLTFrozen = false;
			boolean isStateEqual = false;
			
			SelectList sPartSelStmts = new SelectList(4);
	    	sPartSelStmts.addElement(DomainObject.SELECT_TYPE);
	    	sPartSelStmts.addElement(DomainObject.SELECT_POLICY);
	    	sPartSelStmts.addElement(DomainConstants.SELECT_CURRENT);
	    	sPartSelStmts.addElement("from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
	    	
	    	IPartService iPartService = PartMgtFactory.getPartService(context, objectId);
	    	
	    	if ( iPartService.getInfo(context).isFrozen() && iPartService.isChangeControlled(context) ) {
	    		
	    		%>
		          <script>
		          //XSSOK
		    	      alert("<%= workUnderChangeSetToProdValidation %>");
		          </script>
		       <%	
		         return;
	    	}
	    	
	    	Map objMap = domObj.getInfo(context, (StringList)sPartSelStmts);

			String sCurrentState = (String)objMap.get(DomainConstants.SELECT_CURRENT);
			
			if(DomainConstants.STATE_PART_OBSOLETE.equals(sCurrentState))
			  {
				%>
		          <script>
		          //XSSOK
		    	      alert("<%=strPartIsInObsoleteState%>");
		          </script>
		       <%	
		         return;
			  }
			if(DomainConstants.STATE_PART_APPROVED.equals(sCurrentState))
			  {
				%>
		          <script>
		          //XSSOK
		    	      alert("<%=strPartInApprovedState%>");
		          </script>
		       <%	
		         return;
			  }
			
			String isVPLMControlled = (String)objMap.get("from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
			if("TRUE".equalsIgnoreCase(isVPLMControlled) && DomainConstants.STATE_PART_RELEASE.equals((String)objMap.get(DomainConstants.SELECT_CURRENT)))
			{
				%>
		          <script>
		          //XSSOK
		    	      alert("<%=strVPLMControlled%>");
		          </script>
		       <%	
		         return;
			 }
			
	    	String changeRequiredState = ReleasePhase.getChangeRequiredState(context,(String)objMap.get(DomainObject.SELECT_TYPE),EngineeringConstants.DEVELOPMENT);
			StringList states = new StringList();
			
			states = EngineeringUtil.getOCDXStateMappingForDisplayStatePart(context,changeRequiredState);
			
			if((String)states.get(0)!=null && (String)states.get(0)!="")
				 changeRequiredState = (String)states.get(0);	
			
			if(changeRequiredState != null && !"".equals(changeRequiredState))
				isStateLTFrozen = com.matrixone.apps.domain.util.PolicyUtil.checkState(context, objectId, changeRequiredState, com.matrixone.apps.domain.util.PolicyUtil.LT);
			
			if(EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)))
			{
				
				if("TRUE".equalsIgnoreCase(isVPLMControlled))
				{
					%>
			          <script>
			          //XSSOK
			    	      alert("<%=strVPLMControlledConfiguredPart%>");
			          </script>
			       <%	
			         return;
				 }
				boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
				if(!retVal)
		    	{
			    	%>
			    	<script>
			    	//XSSOK
			    	alert("<%=strPublishToVPMAlert%>");
			    	</script>
			    	<%	
			    	return;
		       	}
				StringList busSelects = new StringList(DomainObject.SELECT_POLICY);
			    busSelects = new StringList(DomainObject.SELECT_ID);
				String objWhere = "(attribute[" + EngineeringConstants.ATTRIBUTE_RELEASE_PHASE + "]=="+EngineeringConstants.DEVELOPMENT+")" ;
				if("ENCPartProperty".equals(frameName)) {
					MapList mapList = domObj.getRelatedObjects(context,
					DomainConstants.RELATIONSHIP_EBOM, DomainConstants.TYPE_PART, busSelects,
					null, false, true, (short) 0, objWhere, null, 0);
					 if(!mapList.isEmpty()){
							%>
						    <script>
						    //XSSOK
						    	alert("<%=strBOMChildReleasePhaseDevErrorMsg%>");
						    </script>
						    <%	
						    return;
						    }
				}
					%>
					<script>
					//XSSOK
	 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=ENCBOMGoToProduction.CommandLabel.UnderFormalChange&HelpMarker=emxhelppartgotoproduction&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
	 				   showModalDialog(sURL, 850,630, true);
	 				</script>
	 				<%
				}
			else if("ENCPartProperty".equals(frameName) || "GLSPartTypePropertiesPage".equals(frameName) || "PRSPPartSpecView".equals(frameName))
			{
				String sChildPartId = "";
				affectedItems.add(objectId);
			  	StringList busSelects = new StringList(DomainObject.SELECT_POLICY);
			    busSelects = new StringList(DomainObject.SELECT_ID);
				String objWhere = "(attribute[" + EngineeringConstants.ATTRIBUTE_RELEASE_PHASE + "]=="+EngineeringConstants.DEVELOPMENT+")" ;

				MapList mapList = domObj.getRelatedObjects(context,
				DomainConstants.RELATIONSHIP_EBOM, DomainConstants.TYPE_PART, busSelects,
				null, false, true, (short) 0, objWhere, null, 0);
				
				//check for VPM product is attached to the parts
				String vplmVisible = domObj.getInfo(context, "attribute["+EngineeringConstants.ATTRIBUTE_VPM_VISIBLE+"].value");
				if("true".equalsIgnoreCase(vplmVisible))
				{
					boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
					if(!retVal)
			    	{
			    	%>
			    	<script>
			    	//XSSOK
			    	alert("<%=strPublishToVPMAlert%>");
			    	</script>
			    	<%	
			    	return;
			       	}
				}
				 if(!mapList.isEmpty()){
						%>
					    <script>
					    //XSSOK
					    	alert("<%=strBOMChildReleasePhaseDevErrorMsg%>");
					    </script>
					    <%	
					    return;
					    }
				 isStateEqual = ReleasePhaseManager.checkIfBOMChildStatesHigherThanParent(context,objectId);
			    	if(!isStateEqual)
			    	{
			    	%>
			    	<script language="JavaScript" type="text/javascript">
			    	//XSSOK
			    		alert("<%=strChildStateNotHigherThanParentErrorMsg%>");
			    		</script>
			    	<%	
			    	return;
			       	}
			    	
			    boolean markUpRetVal = ReleasePhaseManager.checkIfPartHasProposedMarkups(context,objectId);
				 if(!markUpRetVal)
					 {
					  	%>
						   <script>
						   //XSSOK
							    alert("<%=strMarkupShouldBeApprovedORRejected%>");
						 </script>
						<%	
					   return;
						}
			if(isStateLTFrozen){
				MapList changeConnected = domObj.getRelatedObjects(context,
 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
 						null, true, false, (short) 1, "Current != "+EngineeringConstants.STATE_ECO_RELEASE, null, 0);
 				if(changeConnected.size()>0 && !EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY))){
 			    	%>
 					    <script>
 					    //XSSOK
 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
 					    </script>
 					<%	
 					    return;
 				}
				
		  		affectedItems.add(objectId);
		  		ReleasePhaseManager.setAttributesOnPartObj(context,affectedItems);
		  		if(!EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)) && "True".equals(reviseSequence))
		  			ReleasePhaseManager.resetRevision(context,affectedItems);
		  		
			%>

			<script>
			//Fix promoted as part of IR-575823
			var frameName = "<%=frameName%>";
			var targetFrame;
			if("ENCPartProperty"==frameName){
				targetFrame = findFrame(getTopWindow(), frameName);
				targetFrame.location.href = targetFrame.location.href;
			}
			else{
				targetFrame = findFrame(getTopWindow(), "content");
				getTopWindow().location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>";
			}
 			</script>
			<%	
			}
			else
 			{
				MapList changeConnected = domObj.getRelatedObjects(context,
 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
 						null, true, false, (short) 1, "Current != " +EngineeringConstants.STATE_ECO_RELEASE, null, 0);
 				if(changeConnected.size()>0){
 			    	%>
 					    <script>
 					    //XSSOK
 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
 					    </script>
 					<%	
 					    return;
 				}
 				
 				if ( !ECMUtil.isAllowedToPerformGoToProduction(context, objectId) ) {
                    %>
                        <script>
                            alert("<%= unReleasedChangeConnectedAsForRevise %>");
                        </script>
                    <%  
                        return;
                }
 				
 				StringList busSelectable = new StringList(DomainObject.SELECT_POLICY);
 				busSelectable.addElement(DomainObject.SELECT_ID);
 				busSelectable.addElement(DomainConstants.SELECT_CURRENT);
 				
				Map proposedCAData  = com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil.getChangeObjectsInProposed(context, busSelectable, new String[]{objectId}, 1);
				MapList proposedchangeActionList = (MapList)proposedCAData.get(objectId);
				MapList activeCAList = new MapList();
 				for(int i =0;i<proposedchangeActionList.size();i++){
 					Map caMap = (Map)proposedchangeActionList.get(i);
 					String sCurrentCAState = (String)caMap.get(DomainConstants.SELECT_CURRENT);
 					if(!ChangeConstants.STATE_CHANGE_ACTION_COMPLETE.equals(sCurrentCAState) && !ChangeConstants.STATE_CHANGE_ACTION_CANCEL.equals(sCurrentCAState) ){
 						activeCAList.add(caMap);
 					}
 				}
 				String sChangeId = "";
 				if(activeCAList.size()>0){
 					sChangeId = (String)((Map)activeCAList.get(0)).get(DomainObject.SELECT_ID);
 					IChangeAction iCA = EngineeringUtil.getChangeAction(context, sChangeId);
 					BusinessObjectWithSelect bCO = iCA.getChangeOrder(context);
 					String sCOId = bCO.getObjectId();

 					
 					%>
 			    	<script language="JavaScript" type="text/javascript">
 			    		var caId = "<%=sChangeId%>";
 			    		//XSSOK
 			    		var coId = "<%=sCOId%>";
 			    		var partId = "<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
 			    		//XSSOK
 			    		var confirmMessage = confirm("<%=strCAConnected%>");
 			    		if(confirmMessage == true) {
 			    			sendInfo();
 			    		}
	    		
 			    		var request;  
 			    		function sendInfo()  
 			    		{
	 			    		var url="../engineeringcentral/emxEngrUseExistingCO.jsp?CAId="+caId+"&COId="+coId+"&partId="+partId;  
	 			    		  
	 			    		if(window.XMLHttpRequest){  
	 			    			request=new XMLHttpRequest();  
	 			    		}  
	 			    		else if(window.ActiveXObject){  
	 			    			request=new ActiveXObject("Microsoft.XMLHTTP");  
	 			    		}  
	 			    		  
	 			    		try{  
		 			    		request.onreadystatechange=getInfo;   
		 			    		request.open("GET",url,true);  
		 			    		request.send();  
	 			    		}catch(e){alert("Unable to connect to server");}  
 			    		}  
 			    		  
 			    		function getInfo(){  
	 			    		if(request.readyState==4){  
	 			    			var val=request.responseText;  
	 			    		}  
 			    		}  
 			    		</script>
 			    	<%
 			       	return;
 				}
 				%>
 				<script>
 				//XSSOK
 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=ENCBOMGoToProduction.CommandLabel.UnderFormalChange&HelpMarker=emxhelppartgotoproduction&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
 				   showModalDialog(sURL, 850,630, true);
 				</script>
 <%	
 			}
		}
			else if("ENCEBOMIndentedSummarySB".equals(tableName)){
					boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
					if(!retVal)
			    	{
			    	%>
			    	<script>
			    	//XSSOK
			    	alert("<%=strPublishToVPMAlert%>");
			    	</script>
			    	<%	
			    	return;
			       	}
					boolean isChildInApprovedState = ReleasePhaseManager.checkIfChildInApprovedState(context,objectId);
					if(isChildInApprovedState)
			    	{
			    	%>
			    	<script>
			    	//XSSOK
			    	alert("<%=strChildPartInApprovedState%>");
			    	</script>
			    	<%	
			    	return;
			       	}
				
	    	isStateEqual = ReleasePhaseManager.checkIfBOMChildStatesHigherThanParent(context,objectId);
	    	if(!isStateEqual)
	    	{
	    	%>
	    	<script language="JavaScript" type="text/javascript">
	    	//XSSOK
	    		alert("<%=strChildStateNotHigherThanParentErrorMsg%>");
	    		</script>
	    	<%	
	    	return;
	       	}
		//Fix for IR-648228-3DEXPERIENCER2019x
			String mEBOMList  = DomainObject.newInstance(context, objectId).getInfo(context, "from["+EngineeringConstants.RELATIONSHIP_EBOM+"]" );
				    if(mEBOMList.equalsIgnoreCase("False"))
				    {
				    	%>
						    <script>
						    	alert("<%=strBomGotoProductionFromPartPropertiesOnly%>");
						    </script>
						<%	
						    return;
					}
	    	
	    	String message = ReleasePhaseManager.checkIfChildAssociatedWithChange(context,objectId,true);
		    if("ChangeExistsForChildParts".equalsIgnoreCase(message))
		    {
		    	%>
				    <script>
				    //XSSOK
				    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
				    </script>
				<%	
				    return;
			}
		    if("NextRevExists".equalsIgnoreCase(message))
		    {
		    	%>
				    <script>
				    //XSSOK
				    	alert("<%=strNextRevisionAssociatedWithChildPartErrorMsg%>");
				    </script>
				<%	
				    return;
			}
		    
		    boolean markUpRetVal = ReleasePhaseManager.checkIfPartHasProposedMarkups(context,objectId);
		    if(!markUpRetVal)
		    {
		    	%>
				    <script>
				    //XSSOK
				    	alert("<%=strMarkupShouldBeApprovedORRejected%>");
				    </script>
				<%	
				    return;
			}
		    
	    	if(isStateLTFrozen){
	    		   	StringList childList = ReleasePhaseManager.getChildStateStatus(context,objectId);					
 						if(!childList.isEmpty()){
 							ReleasePhaseManager.setAttributesOnPartObj(context,childList);
 							if(!EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)domObj.getInfo(context,DomainObject.SELECT_POLICY)) && "True".equals(reviseSequence))
 								ReleasePhaseManager.resetRevision(context,childList);
 							%>
 			 				<script>
 			 				var targetENCFrame = emxUICore.findFrame(getTopWindow(),"ENCBOM");
 			 				targetENCFrame.location.href = targetENCFrame.location.href;
 			 				</script>
 			                <%
 			            }
 							else
 						{
 							%>
 				<script>
 				//XSSOK
 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=ENCBOMGoToProduction.CommandLabel.UnderFormalChange&HelpMarker=emxhelppartgotoproduction&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
 				   showModalDialog(sURL, 850,630, true); 				
 				</script>
 				<%
 				}
 				%>
 				<script>
 				//var targetENCFrame = emxUICore.findFrame(getTopWindow(),"ENCBOM");
 				//targetENCFrame.location.href = targetENCFrame.location.href;
 				</script>
 <%	
			}
 			else
 			{
				%>
 				<script>
 				//XSSOK
 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=ENCBOMGoToProduction.CommandLabel.UnderFormalChange&HelpMarker=emxhelppartgotoproduction&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
 				   showModalDialog(sURL, 850,630, true); 				
 				</script>
 <%	
 			}
	}
			
		
	}
	else if("fromRMB".equals(functionality))
	{
		
					
				DomainObject domObj = DomainObject.newInstance(context,sRMBObjectId);
				SelectList sPartSelStmts = new SelectList(2);
				StringList affectedItems = new StringList();
				StringList states = new StringList();
				affectedItems.add(sRMBObjectId);
				sPartSelStmts.addElement(DomainObject.SELECT_TYPE);
				sPartSelStmts.addElement(DomainObject.SELECT_POLICY);
				sPartSelStmts.addElement(DomainConstants.SELECT_CURRENT);
		    	sPartSelStmts.addElement("from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");

				
			    Map objMap = domObj.getInfo(context, (StringList)sPartSelStmts);
			    
			    
			    String sCurrentState = (String)objMap.get(DomainConstants.SELECT_CURRENT);
				
				if(DomainConstants.STATE_PART_OBSOLETE.equals(sCurrentState))
				  {
					%>
			          <script>
			          //XSSOK
			    	      alert("<%=strPartIsInObsoleteState%>");
			          </script>
			       <%	
			         return;
				  }
				if(DomainConstants.STATE_PART_APPROVED.equals(sCurrentState))
				  {
					%>
			          <script>
			          //XSSOK
			    	      alert("<%=strPartInApprovedState%>");
			          </script>
			       <%	
			         return;
				  }
				
				String isVPLMControlled = (String)objMap.get("from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
				if("TRUE".equalsIgnoreCase(isVPLMControlled) && DomainConstants.STATE_PART_RELEASE.equals((String)objMap.get(DomainConstants.SELECT_CURRENT)))
				{
					%>
			          <script>
			          //XSSOK
			    	      alert("<%=strVPLMControlled%>");
			          </script>
			       <%	
			         return;
				 }
			    
			    boolean isStateLTFrozen =false;

			    StringList busSelects = new StringList(DomainObject.SELECT_POLICY);
				String objWhere = "(attribute[" + EngineeringConstants.ATTRIBUTE_RELEASE_PHASE + "]=="+EngineeringConstants.DEVELOPMENT+")" ;

				MapList mapList = domObj.getRelatedObjects(context,
				DomainConstants.RELATIONSHIP_EBOM, DomainConstants.TYPE_PART, busSelects,
				null, false, true, (short) 0, objWhere, null, 0);
				 if(!mapList.isEmpty()){
						%>
					    <script>
					    //XSSOK
					    	alert("<%=strBOMChildReleasePhaseDevErrorMsg%>");
					    </script>
					    <%	
					    return;
					    }
				 
				//check for VPM product is attached to the parts
					String vplmVisible = domObj.getInfo(context, "attribute["+EngineeringConstants.ATTRIBUTE_VPM_VISIBLE+"].value");
					if("true".equalsIgnoreCase(vplmVisible))
					{
						boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
						if(!retVal)
				    	{
				    	%>
				    	<script>
				    	//XSSOK
				    	alert("<%=strPublishToVPMAlert%>");
				    	</script>
				    	<%	
				    	return;
				       	}
					}
					
					if(EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)))
					{
						if("TRUE".equalsIgnoreCase(isVPLMControlled))
						{
							%>
					          <script>
					          //XSSOk
					    	      alert("<%=strVPLMControlledConfiguredPart%>");
					          </script>
					       <%	
					         return;
						 }
							%>
							<script>
							//XSSOK
			 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=ENCBOMGoToProduction.CommandLabel.UnderFormalChange&HelpMarker=emxhelppartgotoproduction&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
			 				   showModalDialog(sURL, 850,630, true);
			 				</script>
			 				<%
						}else{
				boolean isStateEqual = ReleasePhaseManager.checkIfBOMChildStatesHigherThanParent(context,sRMBObjectId);
		    	if(!isStateEqual)
		    	{
		    	%>
		    	<script language="JavaScript" type="text/javascript">
		    	//XSSOK
		    		alert("<%=strChildStateNotHigherThanParentErrorMsg%>");
		    		</script>
		    	<%	
		    	return;
		       	}
		    	String message = ReleasePhaseManager.checkIfChildAssociatedWithChange(context,sRMBObjectId,false);
			    if("ChangeExistsForChildParts".equalsIgnoreCase(message))
			    {
			    	%>
					    <script>
					    //XSSOK
					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
					    </script>
					<%	
					    return;
				}
			    if("NextRevExists".equalsIgnoreCase(message))
			    {
			    	%>
					    <script>
					    //XSSOK
					    	alert("<%=strNextRevisionAssociatedWithChildPartErrorMsg%>");
					    </script>
					<%	
					    return;
				}
			    
			    boolean markUpRetVal = ReleasePhaseManager.checkIfPartHasProposedMarkups(context,sRMBObjectId);
			    if(!markUpRetVal)
			    {
			    	%>
					    <script>
					    //XSSOk
					    	alert("<%=strMarkupShouldBeApprovedORRejected%>");
					    </script>
					<%	
					    return;
				}			
				
			    
			    String changeRequiredState = ReleasePhase.getChangeRequiredState(context,(String)objMap.get(DomainObject.SELECT_TYPE),EngineeringConstants.DEVELOPMENT);
				if("Frozen".equals(changeRequiredState))
					states = EngineeringUtil.getOCDXStateMappingForDisplayStatePart(context,changeRequiredState);
				
				if((String)states.get(0)!=null && (String)states.get(0)!="")
					 changeRequiredState = (String)states.get(0);	
				
				if(changeRequiredState != null && !"".equals(changeRequiredState))
					isStateLTFrozen = com.matrixone.apps.domain.util.PolicyUtil.checkState(context, sRMBObjectId, changeRequiredState, com.matrixone.apps.domain.util.PolicyUtil.LT);
				
	
				if(isStateLTFrozen)
				{
					MapList changeConnected = domObj.getRelatedObjects(context,
	 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
	 						null, true, false, (short) 1, "Current != "+EngineeringConstants.STATE_ECO_RELEASE, null, 0);
	 				if(changeConnected.size()>0){
	 			    	%>
	 					    <script>
	 					    //XSSOk
	 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
	 					    </script>
	 					<%	
	 					    return;
	 				}
					ReleasePhaseManager.setAttributesOnPartObj(context,affectedItems);
					if("True".equals(reviseSequence))
						ReleasePhaseManager.resetRevision(context,affectedItems);
%>
				<script>
				var frameName = emxUICore.findFrame(getTopWindow(),"ENCBOM")?emxUICore.findFrame(getTopWindow(),"ENCBOM"):emxUICore.findFrame(getTopWindow(),"PUEUEBOM")
				frameName.location.href = frameName.location.href;
 				</script>
 <%	
				}
				else
				{
					MapList changeConnected = domObj.getRelatedObjects(context,
	 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
	 						null, true, false, (short) 1, "Current != "+EngineeringConstants.STATE_ECO_RELEASE, null, 0);
	 				if(changeConnected.size()>0){
	 			    	%>
	 					    <script>
	 					    //XSSOK
	 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
	 					    </script>
	 					<%	
	 					    return;
	 				}
					
	 				StringList busSelectable = new StringList(DomainObject.SELECT_POLICY);
	 				busSelectable.addElement(DomainObject.SELECT_ID);
	 				busSelectable.addElement(DomainConstants.SELECT_CURRENT);
					
					Map proposedCAData  = com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil.getChangeObjectsInProposed(context, busSelectable, new String[]{objectId}, 1);
					MapList proposedchangeActionList = (MapList)proposedCAData.get(objectId);
					MapList activeCAList = new MapList();
	 				for(int i =0;i<proposedchangeActionList.size();i++){
	 					Map caMap = (Map)proposedchangeActionList.get(i);
	 					String sCurrentCAState = (String)caMap.get(DomainConstants.SELECT_CURRENT);
	 					if(!ChangeConstants.STATE_CHANGE_ACTION_COMPLETE.equals(sCurrentCAState) && !ChangeConstants.STATE_CHANGE_ACTION_CANCEL.equals(sCurrentCAState) ){
	 						activeCAList.add(caMap);
	 					}
	 				}
	 				String sChangeId = "";
	 				if(activeCAList.size()>0){
	 					sChangeId = (String)((Map)activeCAList.get(0)).get(DomainObject.SELECT_ID);
	 					IChangeAction iCA = EngineeringUtil.getChangeAction(context, sChangeId);
	 					BusinessObjectWithSelect bCO = iCA.getChangeOrder(context);
	 					String sCOId = bCO.getObjectId();

	 					
	 					%>
	 			    	<script language="JavaScript" type="text/javascript">
	 			    		var caId = "<%=sChangeId%>";
	 			    		//XSSOK
	 			    		var coId = "<%=sCOId%>";
	 			    		//XSSOK
	 			    		var partId = "<%=sRMBObjectId%>";
	 			    		//XSSOK
	 			    		var confirmMessage = confirm("<%=strCAConnected%>");
	 			    		if(confirmMessage == true) {
	 			    			sendInfo();
	 			    		}
		    		
	 			    		var request;  
	 			    		function sendInfo()  
	 			    		{
		 			    		var url="../engineeringcentral/emxEngrUseExistingCO.jsp?CAId="+caId+"&COId="+coId+"&partId="+partId;  
		 			    		  
		 			    		if(window.XMLHttpRequest){  
		 			    			request=new XMLHttpRequest();  
		 			    		}  
		 			    		else if(window.ActiveXObject){  
		 			    			request=new ActiveXObject("Microsoft.XMLHTTP");  
		 			    		}  
		 			    		  
		 			    		try{  
			 			    		request.onreadystatechange=getInfo;   
			 			    		request.open("GET",url,true);  
			 			    		request.send();  
		 			    		}catch(e){alert("Unable to connect to server");}  
	 			    		}  
	 			    		  
	 			    		function getInfo(){  
		 			    		if(request.readyState==4){  
		 			    			var val=request.responseText;  
		 			    		}  
	 			    		}  
	 			    		</script>
	 			    	<%
	 			       	return;
	 				}
					%>
					<script>
					//XSSOK
					 var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=ENCBOMGoToProduction.CommandLabel.UnderFormalChange&HelpMarker=emxhelppartgotoproduction&mode=edit&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=sRMBObjectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
	 			     top.showModalDialog(sURL, 850,630, true);
					</script>
					<%	
				}
		}
					
		
		%>
		<script>
		   emxUICore.findFrame(getTopWindow(),"ENCBOM").emxEditableTable.refreshRowByRowId(sRowId);
		</script>
		<%		
	}
  }
	catch (Exception e) {
		ContextUtil.popContext(context);
		 // session.setAttribute("error.message", e.getMessage());
		throw e;
	} 
	finally {
		ContextUtil.popContext(context);
		if (!transIsActive) {
			context.commit();
		}
	}
	 

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
