<%--
  ECMSearchUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="changeUXUtil" class="com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeUXUtil" scope="session"/>

<%
	String languageStr     	= request.getHeader("Accept-Language");
	boolean bIsError 	= false;
	String typeAhead 	= emxGetParameter(request, "typeAhead");
	String frameName 	= emxGetParameter(request, "frameName");
	String openerFrame = emxGetParameter(request, "openerFrame"); 
	String strMode 		= emxGetParameter(request, "mode");
	String strObjId 	= emxGetParameter(request, "objectId");
	String strRelName 	= request.getParameter("relName");
	String strDirection 	= request.getParameter("direction");
	String[] strRowId 	= emxGetParameterValues(request, "emxTableRowId");
	String stringResFileId = "emxEnterpriseChangeMgtStringResource";
	String strCOActionsError = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.COActions");
	String strCRActionsError = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.CRActions");
	String strSearchMode 	= emxGetParameter(request,"chooserType");
    String fieldNameActual 	= emxGetParameter(request,"fieldNameActual");
	String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
	String fieldNameOID 	= emxGetParameter(request,"fieldNameOID");
	try {
		
		if("IAChooser".equals(strSearchMode)){
			
			String SELECT_SEVERITY 				= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_SEVERITY);
			String SELECT_QUALITYIMPACT			= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_QUALITY_IMPACT);
			String SELECT_LIFECYCLECOST			= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_LIFE_CYCLE_COST_ISSUES);
			String SELECT_PRIOTIRIZATIONBENEFIT = DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_PRIORITIZATION_BENEFIT);
			String SELECT_RELATIVECOST 			= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_RELATIVE_COST);
			String SELECT_RELATIVEPENALTY 		= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_RELATIVE_PENALTY);
			String SELECT_RELATIVERISK			= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_RELATIVE_RISK);
			String SELECT_IAEFFORT			    = DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_IMPACT_ANALYSIS_EFFORT);
			String SELECT_EST_SCHEDULEDIMPACT	= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_ESTIMATED_SCHEDULE_IMPACT);
			String SELECT_IMPL_EFFORT			= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_IMPLEMENTATION_EFFORT);
			String SELECT_VALIDATION_EFFORT		= DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_VALIDATION_EFFORT);
			
			StringTokenizer strTokenizer 	= new StringTokenizer(strRowId[0], "|");
			String strObjectId 		= strTokenizer.nextToken();
			DomainObject IAobj 	= new DomainObject(strObjectId); 
			
			
			
			SelectList selectStmts = new SelectList();
			selectStmts.addElement(DomainConstants.SELECT_NAME);
			selectStmts.addElement(DomainConstants.SELECT_DESCRIPTION);
			selectStmts.addElement(SELECT_SEVERITY);
			selectStmts.addElement(SELECT_QUALITYIMPACT);
			selectStmts.addElement(SELECT_LIFECYCLECOST);
			selectStmts.addElement(SELECT_PRIOTIRIZATIONBENEFIT);
			selectStmts.addElement(SELECT_RELATIVECOST);
			selectStmts.addElement(SELECT_RELATIVEPENALTY);
			selectStmts.addElement(SELECT_RELATIVERISK);
			selectStmts.addElement(SELECT_IAEFFORT);
			selectStmts.addElement(SELECT_EST_SCHEDULEDIMPACT);
			selectStmts.addElement(SELECT_IMPL_EFFORT);
			selectStmts.addElement(SELECT_VALIDATION_EFFORT);
			
			Map resultMap 	= IAobj.getInfo(context, selectStmts);
			String IAName 			= (String) resultMap.get(DomainConstants.SELECT_NAME);
			String description 	= (String) resultMap.get(DomainConstants.SELECT_DESCRIPTION);
			String severity 		= (String) resultMap.get(SELECT_SEVERITY);
			String qualityImpact   = (String) resultMap.get(SELECT_QUALITYIMPACT);
			String lifecyclecost   = (String) resultMap.get(SELECT_LIFECYCLECOST);
			String prioritizationBenefit	= (String) resultMap.get(SELECT_PRIOTIRIZATIONBENEFIT);
			String relativecost	= (String) resultMap.get(SELECT_RELATIVECOST);
			String relativepenalty	= (String) resultMap.get(SELECT_RELATIVEPENALTY);
			String relativerisk	= (String) resultMap.get(SELECT_RELATIVERISK);
			String IAeffort	= (String) resultMap.get(SELECT_IAEFFORT);
			String estScheduledImpact	= (String) resultMap.get(SELECT_EST_SCHEDULEDIMPACT);
			String implemntationEffort	= (String) resultMap.get(SELECT_IMPL_EFFORT);
			String validationEffort	= (String) resultMap.get(SELECT_VALIDATION_EFFORT);
			%>
			<script language="javascript" type="text/javaScript">
			//XSSOK
			var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
			var targetWindow = null;
			if(typeAhead == "true")	{
				var frameName = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
				if(frameName == null || frameName == "null" || frameName == "") {
					targetWindow = window.parent;
				} else {
					targetWindow = getTopWindow().findFrame(window.parent, frameName);
				}
			} else	{
					targetWindow = getTopWindow().getWindowOpener();
			}
			
			//XSSOK
			var vfieldNameDisplay = targetWindow.document.getElementById("<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>");
			//XSSOK
            var vfieldDesc 			 = targetWindow.document.getElementsByName("Description")[0];
			//XSSOK
            var vfieldseverity 			 = targetWindow.document.getElementsByName("Severity")[0];
			//XSSOK
            var vfieldqualityimpact = targetWindow.document.getElementsByName("Quality Impact")[0];
			//XSSOK
			var vfieldlifecyclecost		= targetWindow.document.getElementsByName("Life Cycle Cost Issue")[0];
			//XSSOK
			var vfieldprioritization	= targetWindow.document.getElementsByName("Prioritization Benefit")[0];
			//XSSOK
			var vfieldrelativecost		= targetWindow.document.getElementsByName("Relative Cost")[0];
			//XSSOK
			var vfieldrelativepenalty		= targetWindow.document.getElementsByName("Relative Penalty")[0];
			//XSSOK
			var vfieldrelativerisk		= targetWindow.document.getElementsByName("Relative Risk")[0];
			//XSSOK
			var vfieldIAeffort		= targetWindow.document.getElementsByName("Impact Analysis Effort")[0];
			//XSSOK
			var vfieldestScheduledImpact	= targetWindow.document.getElementsByName("Estimated Schedule Impact")[0];
			//XSSOK
			var vfieldimplemntationEffort		= targetWindow.document.getElementsByName("Implementation Effort")[0];
			//XSSOK
			var vfieldvalidationEffort		= targetWindow.document.getElementsByName("Validation Effort")[0];
			
			//XSSOK
            vfieldNameDisplay 				= vfieldNameDisplay == null ? targetWindow.document.forms[0]["<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>"] : vfieldNameDisplay;;
          //XSSOK
            vfieldNameDisplay.value 		=	"<%=IAName%>" ;
            
          //XSSOK
            vfieldDesc 						= vfieldDesc == null ? targetWindow.document.forms[0]["Description"] : vfieldDesc;
          //XSSOK
			vfieldDesc.value 				=	"<%=XSSUtil.encodeForJavaScript(context, description)%>";
          //XSSOK
			vfieldseverity.value 			=	"<%=severity%>" ;
            //XSSOK
			vfieldqualityimpact.value		= 	"<%=qualityImpact%>" ;
            //XSSOK
			vfieldlifecyclecost.value		=	"<%=lifecyclecost%>" ;
            //XSSOK
			vfieldprioritization.value		=	"<%=prioritizationBenefit%>" ;
            //XSSOK
			vfieldrelativecost.value		=	"<%=relativecost%>" ;
            //XSSOK
			vfieldrelativepenalty.value		=	"<%=relativepenalty%>" ;
            //XSSOK
			vfieldrelativerisk.value		=	"<%=relativerisk%>" ;
            //XSSOK
			vfieldIAeffort.value			=	"<%=IAeffort%>" ;
            //XSSOK
			vfieldestScheduledImpact.value	=	"<%=estScheduledImpact%>" ;
            //XSSOK
			vfieldimplemntationEffort.value	=	"<%=implemntationEffort%>" ;
            //XSSOK
			vfieldvalidationEffort.value	=	"<%=validationEffort%>" ;
			
			
			if(typeAhead != "true")
                //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
				getTopWindow().closeWindow();
          </script>
			
            
			<%
		}
		//Change Template search code starts from here
		else if ("CustomChooser".equals(strSearchMode)){

			StringList list 		= FrameworkUtil.split(strRowId[0], "|");
			String strObjectId 		= (String)list.get(0);
			DomainObject objContext = new DomainObject(strObjectId); //Change Template Object
			if(null!= strObjectId && !"null".equals(strObjectId) && !"".equals(strObjectId))
			{
						String ctObjectID = objContext.getInfo(context,DomainConstants.SELECT_ID);
						session.setAttribute("tmplObjectID", ctObjectID);
						session.setAttribute("CustomChooser", strSearchMode);
						%>
						
						<script language="Javascript" >
						//XSSOK
						var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
						var targetWindow = null;
						if(typeAhead == "true")	{
							var frameName = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
							if(frameName == null || frameName == "null" || frameName == "") {
								targetWindow = window.parent;
							} else {
								targetWindow = getTopWindow().findFrame(window.parent, frameName);
							}
						} else	{
								targetWindow = getTopWindow().getWindowOpener();
						}
		    			
		    			var url = targetWindow.location.href;
		    			
		    			if(url.search("tmplId")!=-1){
		    				var urlStart = url.substring(0,url.search("tmplId=")+7);
		    				var urlEnd = url.substring(url.search("tmplId=")+7,url.length);
		    				urlEnd = urlEnd.substring(urlEnd.indexOf("&"),urlEnd.length);
		    				if(urlEnd.search("&")==-1)urlEnd="";						
							url = urlStart+"<%=XSSUtil.encodeForJavaScript(context,ctObjectID)%>"+urlEnd;
		    			}
		    			else{
		    			url = url+"&tmplId="+"<%=XSSUtil.encodeForJavaScript(context,ctObjectID)%>";
		    			}		    			
							 
		    			targetWindow.location.href = url;
						</script>
						<%	
					}
			
					%>
							<script language="Javascript" >
							//XSSOK
								var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
								if(typeAhead != "true" && (getTopWindow().getWindowOpener() && (!getTopWindow().SnN || !getTopWindow().SnN.FROM_SNN)))
									//getTopWindow().location.href = "../common/emxCloseWindow.jsp";
									getTopWindow().closeWindow();
							</script>
			<%}//Change Template search code ends
			
			else if("AssigneeChooser".equals(strSearchMode)){
				String actualValue = "";
				String displayValue = "";
				frameName = "ECMCRCOAffectedChangeActions";
				StringList list 		= FrameworkUtil.split(strRowId[0], "|");
				String strObjectId 		= (String)list.get(0);
				DomainObject objContext = new DomainObject(strObjectId);
			    StringList strList = new StringList();
			    strList.addElement(DomainConstants.SELECT_NAME);
			    Map resultList = objContext.getInfo(context, strList);
			    String strContextObjectName = (String)resultList.get("name");
			   	actualValue = strContextObjectName;
			    displayValue = PersonUtil.getFullName(context, strContextObjectName);
			    
				%>
				<script language="Javascript" >
				//XSSOK
					var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
					var targetWindow = "";
					var frameName = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
					//XSSOK
					var tmpFieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>";
					//XSSOK
					var tmpFieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>";
									   
					targetWindow = getTopWindow().openerFindFrame(getTopWindow(), frameName);
				    
				    var vfieldNameActual = targetWindow.document.forms[0][tmpFieldNameActual];
				    var vfieldNameDisplay = targetWindow.document.forms[0][tmpFieldNameDisplay];
				    
				  //XSSOK
				    vfieldNameDisplay.value ="<%=displayValue%>" ;
				  //XSSOK 
				    vfieldNameActual.value ="<%=actualValue%>" ;
				    
					if(typeAhead != "true")
						//getTopWindow().location.href = "../common/emxCloseWindow.jsp";
						getTopWindow().closeWindow();
				</script>
				<%
			}
			
			else if("GoverningCOChooser".equals(strSearchMode)){
				String actualValue = "";
				String displayValue = "";
				frameName = "ECMCRCOAffectedChangeActions";
				StringList list 		= FrameworkUtil.split(strRowId[0], "|");
				String strObjectId 		= (String)list.get(0);
				DomainObject objContext = new DomainObject(strObjectId);
			    StringList strList = new StringList();
			    strList.addElement(DomainConstants.SELECT_NAME);
			    Map resultList = objContext.getInfo(context, strList);
			    String strContextObjectName = (String)resultList.get("name");
			   	//actualValue = strContextObjectName;
			    //displayValue = PersonUtil.getFullName(context, strContextObjectName);
			    actualValue = strObjectId;
			    displayValue = strContextObjectName;
			    		
				%>
				<script language="Javascript" >
				//XSSOK
					var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
					var targetWindow = "";
					var frameName = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
					//XSSOK
					var tmpFieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>";
					//XSSOK
					var tmpFieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>";
								
				    if(typeAhead == "true")	{
					
				    	targetWindow = window.parent;
				    }
				    else
				    {
				    	targetWindow = getTopWindow().getWindowOpener();
				    }
				    
				    var vfieldNameActual = targetWindow.document.getElementsByName(tmpFieldNameActual);
				    var vfieldNameDisplay = targetWindow.document.getElementsByName(tmpFieldNameDisplay);
				    
				  //XSSOK
				    vfieldNameDisplay[0].value ="<%=displayValue%>" ;
				  //XSSOK 
				    vfieldNameActual[0].value ="<%=actualValue%>" ;

				    if(typeAhead != "true")
                                                getTopWindow().closeWindow();
				    
				</script>
				<%
			}
			
			if ("copyCO".equals(strSearchMode) || "copyCR".equals(strSearchMode)){
			// Getting All the Object Ids and Rel Ids
			Map map = (Map)changeUXUtil.getObjectIdsRelIdsMapFromTableRowID(strRowId);
		  	StringList slRelIds = (StringList)map.get("RelId");
		  	StringList slObjectIds = (StringList)map.get("ObjId");
		  	String sCopyObjectId = (String)slObjectIds.get(0);
			ChangeOrder changeOrderObj = new ChangeOrder(sCopyObjectId);
			String id = changeOrderObj.getId(context);
			boolean isSuccess;
			if("copyCO".equals(strSearchMode)){
				isSuccess = ChangeTemplate.checkConnectedType(context, new StringList(id));
			} else{
				isSuccess = ChangeTemplate.checkConnectedTypeForCR(context, new StringList(id));
			}
			
			
			String action = "";
			if("copyCO".equals(strSearchMode)){
				action = "../common/emxCreate.jsp?form=type_CreateChangeOrderSlidein&header=EnterpriseChangeMgt.Heading.Copy&formHeader=EnterpriseChangeMgt.Heading.Copy&nameField=autoname&typeChooser=true&CreateMode=CloneCO&type=type_ChangeOrder&copyObjectId="+sCopyObjectId+"&HelpMarker=emxhelpecocancel&submitAction=refreshCaller&createJPO=enoECMChangeOrder:createChange&targetLocation=slidein&preProcessJavaScript=preProcessInCloneCO&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=EnterpriseChangeMgt";
			}else{
				action = "../common/emxCreate.jsp?form=type_CreateChangeRequest&header=EnterpriseChangeMgt.Heading.CopyCR&formHeader=EnterpriseChangeMgt.Heading.Copy&nameField=autoname&typeChooser=true&CreateMode=CloneCO&type=type_ChangeRequest&copyObjectId="+sCopyObjectId+"&HelpMarker=emxhelpecrcancel&submitAction=refreshCaller&createJPO=enoECMChangeRequest:createChangeRequest&targetLocation=slidein&preProcessJavaScript=preProcessInCloneCR&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=EnterpriseChangeMgt&openerFrame="+ openerFrame +"";
			}
			
			session.setAttribute("copyObjectId", sCopyObjectId);
			session.setAttribute("functionality", strSearchMode);
						
			if(isSuccess)
						{%>
						<body>
	    					<form name=CopyCOForm id=CopyCOForm method="post">
	    				<!-- XSSOK -->
	    					<input type = "hidden" id ="copyObjectId" name ="copyObjectId"  value="<xss:encodeForHTMLAttribute><%=sCopyObjectId%></xss:encodeForHTMLAttribute>"/>
							<script language="Javascript" >
			    				var CopyCOForm=document.getElementById("CopyCOForm");
			    				CopyCOForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
			    					CopyCOForm.submit();	        
							</script>
							</form>
							</body>
						<%}
			else{
				if("copyCO".equals(strSearchMode)){
				%>
				<script language="javascript">  
				//XSSOK
				alert("<%=XSSUtil.encodeForJavaScript(context,strCOActionsError)%>");
				getTopWindow().closeSlideInDialog();
				</script>
	    		<%} else{
	    			%>
					<script language="javascript">  
					//XSSOK
					alert("<%=XSSUtil.encodeForJavaScript(context,strCRActionsError)%>");
					getTopWindow().closeSlideInDialog();
					</script>
		    		<%}
	    		}
		}
			else if ("addChangeActionUnderChangeOrder".equals(strSearchMode)){
				String action = "../common/emxCreate.jsp?form=type_CreateChangeActionSlidein&header=EnterpriseChangeMgt.Command.CreateChangeAction&parentOID="+strObjId+"&objectId="+strObjId+"&type=type_ChangeAction&submitAction=refreshCaller&targetLocation=slidein&preProcessJavaScript=preProcessCreateCAUnderCO&policy=policy_ChangeAction&nameField=autoname&createJPO=enoECMChangeAction:createChangeAction&CreateMode=CreateCA&mode=create&functionality=addChangeActionUnderChangeOrder&HelpMarker=emxhelpchangeactioncreate&postProcessJPO=enoECMChangeOrder:connectChangeActionUnderCO&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEnterpriseChangeMgtStringResource&SuiteDirectory=EnterpriseChangeMgt";
				session.setAttribute("ObjectId", strObjId);
				session.setAttribute("functionality", strSearchMode);
				%>
				<body>
					<form name=CreateCAForm id=CreateCAForm method="post">
				<!-- XSSOK -->
					<input type = "hidden" id ="COObjectId" name ="COObjectId"  value="<xss:encodeForHTMLAttribute><%=strObjId%></xss:encodeForHTMLAttribute>"/>
					<script language="Javascript" >
	    				var CreateCAForm=document.getElementById("CreateCAForm");
	    				CreateCAForm.action = "<%=XSSUtil.encodeForJavaScript(context,action)%>";
	    				CreateCAForm.submit();	        
					</script>
					</form>
					</body>
				<%
			}
	}catch (Exception e) {
		bIsError = true;
		session.putValue("error.message", "" + e);
		
	}// End of main Try-catck block
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


