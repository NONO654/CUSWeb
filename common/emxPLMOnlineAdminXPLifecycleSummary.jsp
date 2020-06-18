<html>
<head>

<!--
//@fullReview  ZUR 11/11/03 HL Lifecycle Customization
-->

		<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css"> 
		<link rel=stylesheet type="text/css" href="styles/emxUIParamOnline.css"> 
		
		<link rel="stylesheet" href="styles/emxPLMOnlineXPParamLCDiv.css"></link>
		<link rel="stylesheet" href="styles/emxPLMOnlineXPParamLCEditor.css"></link>

		<%@ page import="com.dassault_systemes.vplmposadminservices.HtmlCatalogHandler" %>
		<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.PreferencesUtil" %>
		<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.TeamAttributeCustomize"%>
		<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.AttributeProperties"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.LifecycleCustoHandler"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.StateCustoExchange"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.TransitionCustoExchange"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.PolicyCustoDescription"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.RuleDescription"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.TypeCustoDescription"%>
		<%@ page import ="com.matrixone.vplm.parameterizationUtilities.NLSUtilities.ParameterizationNLSCatalog"%>
						
		<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
		<script src="scripts/expand.js" type="text/javascript"></script> 
		<script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
				
		<%@include file = "../common/emxNavigatorInclude.inc"%>
		<%@include file = "../emxTagLibInclude.inc"%>

		<%
		Locale currentLocale = request.getLocale();
		//Context ctx = Framework.getFrameContext(session);
		ParameterizationNLSCatalog myNLS = new ParameterizationNLSCatalog(context, currentLocale, "myMenu");
		
		String NonAppropriateContext	= myNLS.getMessage("NonAppropriateContext");
		String NonAppropriateSolution	= myNLS.getMessage("NonAppropriateSolution");
		String DeployedParameter 		= myNLS.getMessage("DeployedParameter");
		String NotYetDeployedParameter  = myNLS.getMessage("NotYetDeployedParameter");		
		String DeployedTitle 			= DeployedParameter;
		String NotYetDeployedTitle 		= NotYetDeployedParameter;
		String FrozenLine				= myNLS.getMessage("FrozenLine");
		
		String ApplicativeTypeLabel 	= myNLS.getMessage("ApplicativeTypeLabel");
		String FromStatusLabel 			= myNLS.getMessage("FromStatusLabel");
		String ToStatusLabel 			= myNLS.getMessage("ToStatusLabel");
		String AdditionalInfoTitle 		= myNLS.getMessage("AdditionalInfoTitle");
		String DataTypeLabel 			= myNLS.getMessage("DataTypeLabel");
		String Rulelabel 				= myNLS.getMessage("RuleLabel");
		String CurrentSetCheckslabel 	= myNLS.getMessage("CurrentSetChecks");
		String RulesTableToolTip 		= DataTypeLabel +" - "+FromStatusLabel+" - "+ToStatusLabel+" - "+Rulelabel+" - "+ApplicativeTypeLabel+" - "+AdditionalInfoTitle;
		String ConsiderDisciplineLabel	= myNLS.getMessage("ConsiderDisciplineKeyword");		 
		String forAttributesLabel 		= myNLS.getMessage("forAttributesLabel");	
				
		String CurrentSupportedPolicies		= myNLS.getMessage("CurrentSupportedPolicies");	
		String policyNameTitle				= myNLS.getMessage("policyNameTitle");
		String canStatebeRenamedTitle		= myNLS.getMessage("canStatebeRenamedTitle");
		String areTransitionEditableTitle	= myNLS.getMessage("areTransitionEditableTitle");
		String canLCChecksbeAddedTitle		= myNLS.getMessage("canLCChecksbeAddedTitle");
		
		String admincontext="VPLMAdmin";
		String displayhidediv ="block";
		String displayhidecontrol="none";

		String currentcontext = context.getRole();

		String CurrentUISolution="";
		PreferencesUtil utilpref = new PreferencesUtil();
		CurrentUISolution =  utilpref.getUserPreferredUISolution(context);

		//the Administration console will be accessible only if the Current Solution is TEAM
		if (CurrentUISolution.equalsIgnoreCase("TEAM")==false)
			NonAppropriateContext = NonAppropriateSolution;
	
		//the Administration is accessible only for Admin with appropriate context
		if ( ( currentcontext.indexOf(admincontext) >=0) && ( CurrentUISolution.equalsIgnoreCase("TEAM")) ) 
		{
			displayhidediv ="none";
			displayhidecontrol="block";
		}

%>
</head>

	<script>
	
	var listofRulesArray 	= new Array();
	var listofPoliciesArray	= new Array();	
	var listofStatesArray	= new Array();
	var listofTypesArray	= new Array();
		
	//Struct Factory
	function structBuilder(names) 
	{
		var names = names.split(',');
		var count = names.length;
		
		function constructor() 
		{
			for (var i = 0; i < count; i++)
				this[names[i]] = arguments[i];
		}
		return constructor;
	}
	
	var policyDescriptor	= structBuilder("policyID,areTransitionsEditable,areStatesRenamable,listofTypes");
	var ruleDescriptor 		= structBuilder("ruleID,ruleNLS,ruleNLSTooltip");
	var stateDescriptor 	= structBuilder("policyID,stateSysName,stateUserName");
	var typeDescriptor 		= structBuilder("typeENOID,typeNLS,listofDisciplines");
	
	
	function addRuletoList(_ruleID, _ruleNLS, _ruleNLSTooltip, icounter)
	{							
		listofRulesArray [icounter] = new ruleDescriptor(_ruleID,_ruleNLS,_ruleNLSTooltip);
	}
		
	function addPolicytoList(_policyID,_policyUI,_TransitionEditable,_StatesRenamable,_FunctionalTypes, icounter)
	{			
		listofPoliciesArray[icounter] = new policyDescriptor(_policyID,_TransitionEditable,_StatesRenamable,_FunctionalTypes);
		BuildPoliciesTable(_policyID,_policyUI,_StatesRenamable,_TransitionEditable);
	}
	
	function addStatetoList(_policyID,_userSysName,_userStateName,icounter)
	{
		listofStatesArray[icounter] = new stateDescriptor(_policyID,_userSysName,_userStateName);		
	}
				 
	function addTypestoList(_typeENOID, _NLStypeID , _applicativeTypes, icounter)
	{
		listofTypesArray [icounter] = new typeDescriptor(_typeENOID,_NLStypeID,_applicativeTypes);
	}	
	
	function BuildLCTable(newObjTypeNLS,nSourceNLS,nDestNLS,nRuleNLS,nDiscipline,nAdditionalInfo,remBehave)
    {
		var newRow = document.getElementById('rulestable').insertRow(-1);
       	
	   	newCell = newRow.insertCell(0);	   
       	newCell.className="MatrixFeelNxG";	             	    	        	
       	newCell.innerHTML=newObjTypeNLS;	
       		        	
       	newCell = newRow.insertCell(-1);
       	newCell.align = "left";
       	newCell.className="MatrixFeelNxG";
       	newCell.innerHTML=nSourceNLS;       	 

        newCell = newRow.insertCell(-1);
       	newCell.align = "left";
       	newCell.className="MatrixFeelNxG";
       	newCell.innerHTML=nDestNLS; 	     

 	    newCell = newRow.insertCell(-1);	   
       	newCell.className="MatrixFeelNxG";	             	    	        	
       	newCell.innerHTML=nRuleNLS;
       	
       	newCell = newRow.insertCell(-1);
        newCell.align = "left";
       	newCell.className="MatrixFeelNxG";
 	    newCell.innerHTML=nDiscipline;    
 	        
 	    newCell = newRow.insertCell(-1); 	     
   		newCell.align = "left";
   		newCell.className="MatrixFeelNxG";
       	   	
 	   	if (nAdditionalInfo!="")
 	   		newCell.innerHTML='<INPUT type=text size="30" Maxlength="150" readonly="readonly" value="'+nAdditionalInfo+'">';
		else
			newCell.innerHTML="";   
 	  
 	   	newCell = newRow.insertCell(-1);
		newCell.align = "right";
		newCell.style.width="5%";	  	   	   	
 	   	  	
 	   	if (remBehave=="Frozen")
 	   		newCell.innerHTML='<img src="images/iconSetAttribute.gif" title="'+"<%=FrozenLine%>"+'"> </td></tr>';
 	 	else if (remBehave=="NotDeployed")
			newCell.innerHTML='<img src="images/iconSavedParameter.gif" title="'+"<%=NotYetDeployedTitle%>"+'" > </td></tr>';
		else			
			newCell.innerHTML='<img src="images/iconLicenseAvailable.gif" title="'+"<%=DeployedTitle%>"+'" ></td></tr>';
	 
    }
		
	function BuildPoliciesTable(policyName,policyUIName,areStatesRenamable,areTransitionsRenamable)
    {	 
		var newRow = document.getElementById('policiestable').insertRow(-1);  	
       	 
       	newCell = newRow.insertCell(0);	   
       	newCell.className="MatrixFeelNxG";	             	    	        	
       	newCell.value=policyName;
       	newCell.innerHTML=policyUIName;	  
       		        	
        
       	newCell = newRow.insertCell(-1);
       	newCell.align = "left";
      //newCell.className="MatrixFeelNxG";
       	
       	if (areStatesRenamable == true)
       		newCell.innerHTML='<img src="images/iconActionComplete.gif" title="" ></td></tr>';
       	else
       		newCell.innerHTML='<img src="images/iconParamDelete.gif" title="" ></td></tr>';
       		
       	//canStatebeRenamedTitle	
       	       	     	 
        newCell = newRow.insertCell(-1);
       	newCell.align = "left";      	
       	//newCell.className="MatrixFeelNxG";
      
     	if (areTransitionsRenamable == true)
       		newCell.innerHTML='<img src="images/iconActionComplete.gif" title="" ></td></tr>';
       	else
       		newCell.innerHTML='<img src="images/iconParamDelete.gif" title="" ></td></tr>';
 	    	
 	    newCell = newRow.insertCell(-1);	   
       	//newCell.className="MatrixFeelNxG";
       	newCell.align = "left";
       	newCell.innerHTML='<img src="images/iconActionComplete.gif" title="" ></td></tr>';      	
       
    }
	 
	function getPolicyFromObjectType(iobjectType)
	{	
		var listofPoliciesHandlingType = new Array(); 		
		var policyListLen = listofPoliciesArray.length;		
		var j=0;
	
		for ( var i =0; i< policyListLen ; i++)
			if ( listofPoliciesArray[i].listofTypes.indexOf(iobjectType)>=0 ) 			
					listofPoliciesHandlingType[j++] = listofPoliciesArray[i].policyID;

		return listofPoliciesHandlingType;	
	}
	 
	function getUserStateName(objectType,stateSysName)
	{		
		
		var stateListLen = listofStatesArray.length;		
		var policyIDs = getPolicyFromObjectType(objectType);		
	
		for ( var i =0; i< stateListLen ; i++)		
			if ( listofStatesArray[i].stateSysName == stateSysName)
			{					
				for (var j=0; j<policyIDs.length; j++)				
					if (listofStatesArray[i].policyID == policyIDs[j])			
						return listofStatesArray[i].stateUserName;
			}
			
		return -1;
	}
	
	function getNLSType(objectENOType)
	{		
		var typesListLen = listofTypesArray.length;
		
		for ( var i =0; i< typesListLen ; i++)			
			if (  listofTypesArray[i].typeENOID == objectENOType)
					return (listofTypesArray[i].typeNLS);

		return -1;	
	}
	
	</script>

<body>

<div id="GlobalLCDiv"  style="width: 100%;  height:100%; background-color: #eeeeee;">

<script type="text/javascript">
addTransparentLoadingInSession("none","LoadingDiv");
addDivForNonAppropriateContext("<%=displayhidediv%>","<%=NonAppropriateContext%>","100%","100%");
</script>

<div id="handledPolicies" style="display:inline-block; min-height: 40%; overflow-y:auto">

 <table id="policiestable" width="100%" height="20%" cellspacing="2" cellpadding="0" style="none" bgcolor="white">
 <tr bgcolor="#659ac2" >
 <td class="TitleInParam" colspan=4 height="20"><%=CurrentSupportedPolicies%></td>
 </tr>
 <tr bgcolor="#CDD8EB">
	<td class="TitleSecParam" width="10%" align="center"><%=policyNameTitle%></td>
	<td class="TitleSecParam" width="10%" align="center"><%=canStatebeRenamedTitle%></td>
 	<td class="TitleSecParam" width="10%" align="center"><%=areTransitionEditableTitle%></td>
 	<td class="TitleSecParam" width="10%" align="center"><%=canLCChecksbeAddedTitle%></td>
 </tr> 
 </table>

</div>

	
 		
 			<script>
			var iRulesCounter = 0;
			var iChecksListBuffer = new Array();
			var iChecksListCounter = 0;	
			</script>
			
			<%					
			//LifeCycle Handler		
			LifecycleCustoHandler myLifeCycleHandler = new LifecycleCustoHandler(context);
			
			//Getting policies Descriptions			
			PolicyCustoDescription[] policyDesc = myLifeCycleHandler.getAllHandledPolicies();
							
			for (int i=0; i<policyDesc.length; i++)
			{
				String policyID  = policyDesc[i].getPolicyID();							
				String iPolicyUI = policyID;
				
				ParameterizationNLSCatalog iNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, policyDesc[i].getPolicyNLSFileName());
				iPolicyUI = iNLSCatalog.getMessage(policyDesc[i].getPolicyNLSKey());
						
				boolean iTransitionEditable = policyDesc[i].areTransitionsEditable();
				boolean iStatesRenamable	= policyDesc[i].areStatesRenamable();
				String supportedTypes		= policyDesc[i].getHandledObjTypeChecks();	
				%>
				<script>
				addPolicytoList("<%=policyID%>","<%=iPolicyUI%>",<%=iTransitionEditable%>,<%=iStatesRenamable%>,"<%=supportedTypes%>",<%=i%>);				
				</script>				
				<%			
			}
					
			/*
			
			//retreiving all states
			StateCustoExchange[] allStates = myLifeCycleHandler.getAllStates(context);
				
			for (int i=0; i<allStates.length; i++)
			{
				String policyID 	= allStates[i].getPolicy();
				String stateSysName	= allStates[i].getStateSysName();
				String stateUserName= allStates[i].getStateUserName();
				>>
				//script
				addStatetoList("<=policyID>","<=stateSysName>","<=stateUserName>",<=i>);
				//script				
				<<	
			}			
			
			
			String[] Splitstring = new String[7];
			String currentString;
			String InfotoAdd="";
	
			RuleDescription[] listofAvailableRules = myLifeCycleHandler.getRulesList();
	
			for (int i=0; i<listofAvailableRules.length; i++)
			{		
				String ruleID		= listofAvailableRules[i].getRuleID();
				String ruleNLS 		= myNLS.getMessage(listofAvailableRules[i].getRuleNLSKey());
				String ruleTooltip	= myNLS.getMessage(listofAvailableRules[i].getRuleNLSTooltipKey());	
				>>
				//script
				addRuletoList("<=ruleID>", "<=ruleNLS>", "<=ruleTooltip>", <=i>);
				//script
				<<
			}
			
			TypeCustoDescription[] listofhandledTypes = myLifeCycleHandler.getAllSupportedTypes();
				
			for (int i=0; i<listofhandledTypes.length; i++)
			{		
				TypeCustoDescription currHandledType = listofhandledTypes[i];
				String currEnoType = currHandledType.getTypeENOID();
		
				ParameterizationNLSCatalog currNLSCatalog = new ParameterizationNLSCatalog(ctx, currentLocale, currHandledType.getNLSFileName());				
				String NLSTypeID = currNLSCatalog.getMessage(currHandledType.getTypeNLSKey());	
				
				//String NLSTypeID = myNLS.getMessage(currHandledType.getTypeNLSKey());	
				String currApplicativeTypes = currHandledType.getApplicativeTypes();		
				>>			
				//script			
				addTypestoList("<=currEnoType>", "<=NLSTypeID>", "<=currApplicativeTypes>",<=i>);
				//script
				<<
			}	
			
			
			//Retrieving LifeCycle Checks
		
			StringList iGetList = myLifeCycleHandler.getLifecycleChecks(context);	
		
			if (iGetList!=null)
			{	
				for(int i=0;i<iGetList.size();i++)
				{
					currentString = (String) iGetList.elementAt(i);
					Splitstring = currentString.split(":", 7);//split into 7 parts					
					String iAdditionalInfotoShow="";
					String iAdditionalInfoCell="";	
					String CurrentHandledCheck="";	
					InfotoAdd="";
			
					CurrentHandledCheck=Splitstring[3];		
	
					for ( int k = 0; k < listofAvailableRules.length; k++)								
						if (Splitstring[3].equalsIgnoreCase(listofAvailableRules[k].getRuleID()))
							Splitstring[3]= myNLS.getMessage(listofAvailableRules[k].getRuleNLSKey());		
				
					if (!(Splitstring[5].equalsIgnoreCase("NOINFO")) )			
					{
						InfotoAdd=Splitstring[5];
						
						if (CurrentHandledCheck.equalsIgnoreCase("RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState"))
						{
							String additionnalInfoInput = Splitstring[5];
										
							if ( (!additionnalInfoInput.equalsIgnoreCase("ALL") ) 
							&&(!additionnalInfoInput.equalsIgnoreCase("")) )
							{						
								String ChildType="", InfotoKeep="";				
						
								int detectDelimitingchar = additionnalInfoInput.indexOf("/");
						
								if (detectDelimitingchar>0)		
									ChildType=additionnalInfoInput.substring(0,detectDelimitingchar);
							
								InfotoKeep=additionnalInfoInput.substring(detectDelimitingchar);						
														
								//ex. :ENOSTFunctionalRepReference/ALL
								//ENOSTFunctionalRepReference/Schema,Picture,Schema_Snapshot
								//ALL								
																
								TypeCustoDescription govType = myLifeCycleHandler.getTypeDescription(ChildType);
								
								ParameterizationNLSCatalog currNLSCatalog = new ParameterizationNLSCatalog(ctx, currentLocale, govType.getNLSFileName());
								ChildType = currNLSCatalog.getMessage(govType.getTypeNLSKey());			
								//ChildType = myNLS.getMessage(govType.getTypeNLSKey());
																
								additionnalInfoInput=ChildType+InfotoKeep;
							}
										
							iAdditionalInfotoShow=ConsiderDisciplineLabel+" :"+additionnalInfoInput;
						}
						else if (CurrentHandledCheck.equalsIgnoreCase("RejectIfAttributeNotValuated"))					
							iAdditionalInfotoShow=forAttributesLabel+" :"+Splitstring[5];

						iAdditionalInfoCell="<INPUT type=text size=\"30\" Maxlength=\"150\" readonly=\"readonly\"  value=\""+iAdditionalInfotoShow+"\">";
					}							
		
					String remBehave="";				
					
					if (Splitstring[6].equalsIgnoreCase("false"))
						remBehave="NotDeployed";		
					else
						remBehave="Deployed";
													
					>>
		
			//		script				
					
			//		var state_SourceNLS = getUserStateName("<=Splitstring[0]>","<=Splitstring[1]>");
			//		var state_TargetNLS = getUserStateName("<=Splitstring[0]>","<=Splitstring[2]>");	
			//		var typeNLS = getNLSType("<=Splitstring[0]>");						
					
			//		BuildLCTable(typeNLS,state_SourceNLS,state_TargetNLS,"<=Splitstring[3]>",
			//				"<=Splitstring[4]>","<=iAdditionalInfotoShow>","<=remBehave>");
			//		/script			
					<<							
			}	
		}	
		*/
		
		
		%>   		
 

</div>

</body>

</html>
